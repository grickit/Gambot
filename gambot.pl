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

use IPC::Open2;
use Fcntl qw(F_SETFL O_NONBLOCK);
use Digest::MD5 qw(md5_hex);
use FindBin;
use lib "$FindBin::Bin/modules/";

use Gambot::IO;
use Gambot::Configure;
use Gambot::Connect;
use Gambot::GAPIL;

####-----#----- Setup -----#-----####
$| = 1; # Unbuffered IO
$SIG{CHLD} = 'IGNORE'; # Reap zombie child processes
$SIG{INT} = sub { exit; }; # Exit gracefully and save data on SIGINT
$SIG{HUP} = sub { exit; }; # Exit gracefully and save data on SIGHUP
$SIG{TERM} = sub { exit; }; # Exit gracefully and save data on SIGTERM

## %dict{config} stores stuff from the config file.
## %dict{core} stores other core data.
## %events allows children to schedule GAPIL calls to be run when an event is fired
## %delays allows children to schedule GAPIL calls to be run a certain number of seconds in the future
## %autosave contains a list of all manually saved and loaded members of %dict to be autosaved at shutdown
my %dicts;
$dicts{'core'} = {};
$dicts{'config'} = {};
$dicts{'events'} = {};
$dicts{'delay_timers'} = {};
$dicts{'delay_events'} = {};
my %autosave;

## Set some default values necessary for the bot to function.
## Any of these might be overwritten by the config file or command line arguments.
value_set('core','home_directory',$FindBin::Bin);
value_set('core','configuration_file','config.txt');
value_set('config','iterations_per_second',10);
value_set('config','messages_per_second',3);
value_set('config','ping_timeout',600);

## %pid_pipes store the process ids of child processes
## %read_pipes are for getting data from child processes
## %write_pipes are for sending data to child processes
my %pid_pipes;
my %read_pipes;
my %write_pipes;

my $irc_connection; # The connection to the IRC server

my $last_received_IRC_message_time = time; # Used for client-side ping timeout
my $last_sent_IRC_message_time = time; # Used for throttling IRC messages
my $IRC_messages_sent_this_second = 0; # Used for throttling IRC messages
my $IRC_messages_received_this_connection = 0; # Used for naming child processes
my @pending_outgoing_IRC_messages; # Used to hold messages that are being throttled


####-----#----- Subroutines -----#-----####
sub server_send {
  push(@pending_outgoing_IRC_messages,$_[0]);
}

sub server_reconnect {
  $irc_connection->close();
  event_output('Reconnecting.');
  $irc_connection = &create_socket_connection(value_get('config','server'),value_get('config','port'),value_get('core','nick'),value_get('config','password'));
  fcntl($irc_connection, F_SETFL(), O_NONBLOCK());
  $IRC_messages_received_this_connection = 0;
}

sub dict_exists {
  my $dict = shift;
  return exists $dicts{$dict};
}

sub dict_save {
  my $dict = shift;
  open(my $file, '>' .value_get('core','home_directory') . '/persistent/' . $dict);
  while (my ($key, $value) = each %{$dicts{$dict}}) {
    print $file "$key = \"$value\"\n";
  }
  close($file);
  $autosave{$dict} = 1; # Mark the dict as manually saved
}

sub dict_load {
  my $dict = shift;
  my $filename = value_get('core','home_directory') . '/persistent/' . $dict;
  if (-e $filename) {
    open (my $file, $filename);
    my @lines = <$file>;

    foreach my $current_line (@lines) {
      $current_line =~ s/[\r\n\s]+$//;
      $current_line =~ s/^[\t\s]+//;
      if ($current_line =~ /^([a-zA-Z0-9_#:-]+) = "(.+)"$/) {
        &value_set($dict,$1,$2);
      }
    }
  }
  else {
    error_output("Tried to load persistence file \"$filename\", but it doesn't exist.");
  }
  $autosave{$dict} = 1; # Mark the dict as manually opened
}

sub dict_save_all {
  while(my ($dict, $bool) = each %autosave) {
    if($bool) { dict_save($dict); }
  }
}

sub dict_delete {
  my $dict = shift;
  delete $dicts{$dict};
}

sub value_exists {
  my ($dict,$key) = @_;
  return (dict_exists($dict) && exists $dicts{$dict}{$key});
}

sub value_get {
  my ($dict,$key) = @_;
  if(value_exists($dict,$key)) { return $dicts{$dict}{$key}; }
  else { return ''; }
}

sub value_add {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key)) { return ''; }
  else { $dicts{$dict}{$key} = $value; return $dicts{$dict}{$key}; }
}

sub value_replace {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key)) { $dicts{$dict}{$key} = $value; return $dicts{$dict}{$key}; }
  else { return ''; }
}

sub value_set {
  my ($dict,$key,$value) = @_;
  $dicts{$dict}{$key} = $value; return $dicts{$dict}{$key};
}

sub value_append {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key)) { $dicts{$dict}{$key} .= $value; return $dicts{$dict}{$key}; }
  else { return ''; }
}

sub value_prepend {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key)) { $dicts{$dict}{$key} = $value . $dicts{$dict}{$key}; return $dicts{$dict}{$key}; }
  else { return ''; }
}

sub value_increment {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key) && $value =~ /^[0-9]+$/) {
    if($dicts{$dict}{$key} =~ /^-?[0-9]+$/) { $dicts{$dict}{$key} += $value; }
    else { $dicts{$dict}{$key} = 0; }
    return $dicts{$dict}{$key};
  }
  else { return ''; }
}

sub value_decrement {
  my ($dict,$key,$value) = @_;
  if(value_exists($dict,$key) && $value =~ /^[0-9]+$/) {
    if($dicts{$dict}{$key} =~ /^-?[0-9]+$/) { $dicts{$dict}{$key} -= $value; }
    else { $dicts{$dict}{$key} = 0; }
    return $dicts{$dict}{$key};
  }
  else { return ''; }
}

sub value_delete {
  my ($dict,$key) = @_;
  if(value_exists($dict,$key)) { my $value = $dicts{$dict}{$key}; delete $dicts{$dict}{$key}; return $value; }
  else { return ''; }
}

sub child_send {
  my ($childid, $message) = @_;
  if(&child_exists($childid) && pipe_status($read_pipes{$childid}) ne 'dead') {
    debug_output("Sending \"$message\" to child named $childid.");
    my $write_pipe = $write_pipes{$childid};
    print $write_pipe $message."\n";
  }
  else {
    error_output("Tried to send a message to child named $childid, but it doesn't exist.");
  }
}

sub child_delete {
  my $childid = shift;
  if(&child_exists($childid)) {
    debug_output("Deleting child named $childid.");
    kill 1, $pid_pipes{$childid};
    delete $pid_pipes{$childid};
    delete $read_pipes{$childid};
    delete $write_pipes{$childid};
  }
  else {
    error_output("Tried to delete child named $childid, but it doesn't exist.");
  }
}

sub child_exists {
  my $childid = shift;
  return (defined $pid_pipes{$childid});
}

sub child_add {
  my ($childid, $command) = @_;
  if(&child_exists($childid)) {
    error_output("Tried to add child named $childid, but one already exists.");
  }
  else {
    debug_output("Adding child named $childid with the command: $command");
    $pid_pipes{$childid} = open2($read_pipes{$childid},$write_pipes{$childid},$command);
    &child_send($childid,$childid);
  }
}

sub event_schedule {
  my ($name, $call) = @_;
  debug_output("Scheduling a call for $name.");
  if(value_exists('events',$name)) { value_append('events',$name,"$call\n"); }
  else { value_set('events',$name,"$call\n"); }
}

sub event_fire {
  my $name = shift;
  debug_output("Firing event: $name.");
  foreach my $call (split(/[\r\n]+/,value_get('events',$name))) {
    parse_command($call);
  }
  value_delete('events',$name);
}

sub event_exists {
  return value_exists('events',$_[0]);
}

sub delay_schedule {
  my ($delay, $call) = @_;
  my $time = time + $delay;
  my $hash = time.md5_hex($call.rand);
  debug_output("Scheduling a call at $time.");
  if(value_exists('delay_events',$hash)) { error_output("Delayed event collision at time: $time with call: $call"); }
  else { value_set('delay_events',$hash,$call); }
  if(value_exists('delay_timers',$time)) { value_append('delay_timers',$time,"$hash,"); }
  else { value_set('delay_timers',$time,"$hash,"); }
}

sub delay_fire {
  my $time = shift;
  debug_output("Firing delay $time at ".time."; ".(time-$time)." seconds late.");
  foreach my $hash (split(/[,]+/,value_get('delay_timers',$time))) {
    parse_command(value_get('delay_events',$hash));
    value_delete('delay_events',$hash);
  }
  value_delete('delay_timers',$time);
}

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
  my $irc_connection_status = &pipe_status($irc_connection);

  if ($irc_connection_status eq 'dead') {
    error_output('IRC connection died.');
    if(&value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { server_reconnect(); } # Otherwise automatically reconnect
  }

  elsif($irc_connection_status eq 'later' && time - $last_received_IRC_message_time >= value_get('config','ping_timeout')) {
    error_output('IRC connection timed out.');
    if(&value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { server_reconnect(); } # Otherwise automatically reconnect
  }

  elsif ($irc_connection_status eq 'ready') {
    my @received_IRC_messages = read_lines($irc_connection,$irc_connection_status);
    foreach my $current_received_IRC_message (@received_IRC_messages) {
      normal_output('INCOMING',$current_received_IRC_message);
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
    my $pipe_status = &pipe_status($pipe);

    ## Clean up dead children
    if ($pipe_status eq 'dead') { child_delete($id); }

    ## Run responses from living children through the GAPIL parser
    elsif ($pipe_status eq 'ready') {
      my @commands = read_lines($pipe);
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
  while(my $current_pending_IRC_message = shift(@pending_outgoing_IRC_messages)) { # Do we have pending outgoing IRC messages?
    if($IRC_messages_sent_this_second < value_get('config','messages_per_second')) { # Are we under the flood limit?
      debug_output("Sent $IRC_messages_sent_this_second IRC messages this second so far during ".time);
      normal_output('OUTGOING',$current_pending_IRC_message);
      print $irc_connection $current_pending_IRC_message."\015\012";
      $IRC_messages_sent_this_second++;
    }
  }

  ## Keep track of how many messages we've sent to the IRC server this second
  if($last_sent_IRC_message_time != time) {
    $IRC_messages_sent_this_second = 0;
    $last_sent_IRC_message_time = time;
  }

}

END {
  &event_output("Saving persistent dicts.");
  &dict_save_all();
  &event_output("Shutting down.");
}
