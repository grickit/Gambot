#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
# Copyright (C) 2010-2011 by Derek Hoagland <grickit@gmail.com>
# This file is part of Gambot.
#
# Gambot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Gambot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Gambot.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

use Fcntl qw(F_SETFL O_NONBLOCK);
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin/modules/";

use Gambot::GAPIL::Core;
use Gambot::Logging;
use Gambot::IO;
use Gambot::Configure;
use Gambot::Connect;
use Gambot::GAPIL::Parse;

####-----#----- Setup -----#-----####
$| = 1; # Unbuffered IO
$SIG{CHLD} = 'IGNORE'; # Reap zombie child processes
$SIG{INT} = sub { exit; }; # Exit gracefully and save data on SIGINT
$SIG{HUP} = sub { exit; }; # Exit gracefully and save data on SIGHUP
$SIG{TERM} = sub { exit; }; # Exit gracefully and save data on SIGTERM

## Set some default values necessary for the bot to function.
## Any of these might be overwritten by the config file or command line arguments.
value_set('core','home_directory',$FindBin::Bin);
value_set('core','configuration_file','config.txt');
value_set('config','iterations_per_second',10);
value_set('config','messages_per_second',3);
value_set('config','ping_timeout',600);

####-----#----- Actual Work -----#-----####
## Parse command line arguments
&load_switches();
## Load the config file
&read_configuration_file(value_get('core','home_directory') . '/configurations/' . value_get('core','configuration_file'));
value_set('core','nick',value_get('config','base_nick'));
$irc_connection = &create_socket_connection(value_get('config','server'),value_get('config','port'),value_get('core','nick'),value_get('config','password'));
fcntl(\*STDIN, F_SETFL(), O_NONBLOCK());
fcntl($irc_connection, F_SETFL(), O_NONBLOCK());

## Load any delayed events
dict_load('delay_timers');
dict_load('delay_events');

## An awesome trick to register STDIN and STDOUT as children just like the message parsers and scripts
## No extra work involved in reading STDIN now.
$pid_pipes{'terminal'} = 1;
$read_pipes{'terminal'} = \*STDIN;
$write_pipes{'terminal'} = \*STDOUT;

while(defined select(undef,undef,undef,(1/value_get('config','iterations_per_second')))) {

  ####-----#----- Read from the IRC connection -----#-----####
  my $irc_connection_status = &filehandle_status($irc_connection);

  if ($irc_connection_status eq 'dead') {
    error_log('IRC connection died.');
    if(&value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { server_reconnect(); } # Otherwise automatically reconnect
  }

  elsif($irc_connection_status eq 'later' && time - $last_received_IRC_message_time >= value_get('config','ping_timeout')) {
    error_log('IRC connection timed out.');
    if(&value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { server_reconnect(); } # Otherwise automatically reconnect
  }

  elsif ($irc_connection_status eq 'ready') {
    my @received_IRC_messages = filehandle_multiread($irc_connection,$irc_connection_status);
    foreach my $current_received_IRC_message (@received_IRC_messages) {
      normal_log('INCOMING',$current_received_IRC_message);
      my $new_pipe_id = 'fork'.$IRC_messages_received_this_connection;
      &child_add($new_pipe_id,value_get('config','processor'));
      ## Message parsers need to know the nickname the bot is using, and the incoming message
      &child_send($new_pipe_id,value_get('core','nick'));
      &child_send($new_pipe_id,$current_received_IRC_message);
      $IRC_messages_received_this_connection++;
      $last_received_IRC_message_time = time;
    }
  }

  ####-----#----- Read from children -----#-----####
  while(my ($id, $pipe) = each %read_pipes) {
    my $pipe_status = &filehandle_status($pipe);

    ## Clean up dead children
    if ($pipe_status eq 'dead') { child_delete($id); }

    ## Run responses from living children through the GAPIL parser
    elsif ($pipe_status eq 'ready') {
      my @commands = filehandle_multiread($pipe);
      foreach my $current_command (@commands) {
        parse_command($current_command,$id) if $current_command;
      }
    }
  }

  ####-----#----- Check delay events -----#-----####
  while(my ($time, $array) = each %{$dicts{'delay_timers'}}) {
    if(time >= $time) { delay_fire($time); }
  }

  ####-----#----- Send outgoing messages -----#-----####
  ## Are we under the throttle?
  ## Do we have pending outgoing messages?
  while($IRC_messages_sent_this_second < value_get('config','messages_per_second') && (my $current_pending_IRC_message = shift(@pending_outgoing_IRC_messages))) {
    debug_log("Sent $IRC_messages_sent_this_second IRC messages this second so far during ".time);
    normal_log('OUTGOING',$current_pending_IRC_message);
    print $irc_connection $current_pending_IRC_message."\015\012";
    $IRC_messages_sent_this_second++;
  }

  ## Keep track of how many messages we've sent to the IRC server this second
  if($last_sent_IRC_message_time != time) {
    $IRC_messages_sent_this_second = 0;
    $last_sent_IRC_message_time = time;
  }

}

END {
  &event_log("Saving persistent dicts.");
  &dict_save_all();
  &event_log("Shutting down.");
}
