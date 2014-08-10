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
use FindBin;
use lib "$FindBin::Bin/modules/";

use Gambot::IO;
use Gambot::ServerIRC;
use Gambot::LoggerBasic;
use Gambot::GAPIL::CommandCore;
use Gambot::GAPIL::CommandParser;
use Gambot::GAPIL::Dictionary;


####-----#----- Setup -----#-----####
$| = 1; # Unbuffered IO
$SIG{CHLD} = 'IGNORE'; # Reap zombie child processes
$SIG{INT} = sub { exit; }; # Exit gracefully and save data on SIGINT
$SIG{HUP} = sub { exit; }; # Exit gracefully and save data on SIGHUP
$SIG{TERM} = sub { exit; }; # Exit gracefully and save data on SIGTERM

my $core = new Gambot::GAPIL::CommandCore();


# Set up the logger
my $logger = new Gambot::LoggerBasic($core);
$core->{'logger'} = $logger;
$core->log_event('Basic logging online.');


# Set up the parser
my $parser = new Gambot::GAPIL::CommandParser($core);
$core->{'parser'} = $parser;
$core->log_event('GAPIL parser online.');


# Load command line arguments
for (my $current_arg = 0; $current_arg < @ARGV; $current_arg++) {
  my $current_arg_value = $ARGV[$current_arg];

  if($current_arg_value eq '-v' || $current_arg_value eq '--verbose') {
    $core->value_set('core','verbose',1);
  }

  elsif($current_arg_value eq '--debug') {
    $core->value_set('core','debug',1);
  }

  elsif($current_arg_value eq '--unlogged') {
    $core->value_set('core','unlogged',1);
  }

  elsif($current_arg_value eq '--staydead') {
    $core->value_set('core','staydead',1);
  }

  elsif($current_arg_value eq '--config') {
    $current_arg++;
    $core->value_set('core','configuration_file',$ARGV[$current_arg]);
  }

  elsif($current_arg_value eq '-h' || $current_arg_value eq '--help') {
    print "Usage: perl Gambot.pl [OPTION]...\n";
    print "A flexible IRC bot framework that can be updated and fixed while running.\n\n";
    print "-v, --verbose        Prints all messages to the terminal.\n";
    print "                     perl gambot.pl --verbose\n\n";
    print "--debug              Enables debug message logging\n";
    print "                     perl gambot.pl --debug\n\n";
    print "--unlogged           Disables logging of messages to files.\n";
    print "                     perl gambot.pl --unlogged\n\n";
    print "--config             The argument after this specifies the configuration file to use.\n";
    print "                     These are stored in \$script_location/configuration/\n";
    print "                     Only give a file name. Not a path.\n";
    print "                     perl gambot.pl --config foo.txt\n\n";
    print "--staydead           The bot will not automatically reconnect.\n";
    print "                     perl gambot.pl --staydead\n\n";
    print "-h, --help           Displays this help.\n";
    print "                     perl gambot.pl --help\n\n";
    print "Ordinarily Gambot will not print much output to the terminal, but will log everything to files.\n";
    print "\$script_location/configuration/config.txt is the default configuration file.\n\n";
    print "For more help, try our IRC channel: ##Gambot at chat.freenode.net\n";
    print "<http://webchat.freenode.net/?channels=\%23\%23Gambot>\n";
    exec('true');
  }
}
$core->log_event('Command line switches loaded.');


# Set up the irc server
my $ircserver = new Gambot::ServerIRC($core);
$core->{'ircserver'} = $ircserver;
$core->log_event('IRC online.');


# Ugly hack to register the terminal as a pseudo child process
$core->child_add('terminal','cat');
$core->{'children'}->{'terminal'}->kill();
$core->{'children'}->{'terminal'}->{'read_pipe'} = \*STDIN;
$core->{'children'}->{'terminal'}->{'write_pipe'} = \*STDOUT;
$core->log_event('Terminal pseudo child online.');


# Set up default core values
$core->value_add('core','home_directory',$FindBin::Bin); # Default location to store files
$core->value_add('core','configuration_file','config.txt'); # Default name for the bot config file
$core->value_add('core','nick','aGambot');
$core->log_event('Default core values set.');


# Load the config file
my $config = new Gambot::GAPIL::Dictionary($core,'config');
$config->load($core->value_get('core','home_directory').'/configuration/'.$core->value_get('core','configuration_file'));
$core->{'dictionaries'}->{'config'} = $config;
$core->value_set('core','nick',$core->value_get('config','base_nick'));
$core->log_event('Config file loaded.');


# Set up default config values
$core->value_add('config','server','chat.freenode.net');
$core->value_add('config','port',6667);
$core->value_add('config','base_nick','aGambot');
$core->value_add('config','password','');
$core->value_add('config','log_directory',$core->value_get('core','home_directory'));
$core->value_add('config','irc_parser','perl '.$core->value_get('core','home_directory').'/parsers/plugin_parser/example.pl');
$core->value_add('config','iterations_per_second',10); # Default max number of times to run the main loop per second
$core->value_add('config','messages_per_second',3); # Default max number of IRC messages to send per second
$core->value_add('config','ping_timeout',300); # Default max number of seconds between received IRC messages
$core->value_add('config','key_characters','A-Za-z0-9_:.#|`[\]{}()\\/\^\-'); # Default allowed characters for stored values and such
#A-Z a-z 0-9 _ : . # | | ` [ ] { } ( ) / \ ^ -
$core->log_event('Default config values set.');


# Set up default IRC stats
$core->value_add('ircserver','last_received_IRC_message_time',time); # Used for client-side ping timeout
$core->value_add('ircserver','last_sent_IRC_message_time',time); # Used for throttling IRC messages
$core->value_add('ircserver','IRC_messages_received_this_connection',0); # Used for naming child processes
$core->value_add('ircserver','IRC_messages_sent_this_second',0); # Used for throttling IRC messages
$core->log_event('Default IRC stats set.');


# Set up core dictionaries
$core->value_add('core','NOSAVE',1);
$core->value_add('config','NOSAVE',1);
$core->value_add('ircserver','NOSAVE',1);
$core->dictionary_load('events');
$core->dictionary_load('delays');


$core->value_add('core','setup_complete',1);
$core->log_event('Setup complete.');

$ircserver->connect();

####-----#----- Main Loop -----#-----####
while(defined select(undef,undef,undef,(1/$core->value_get('config','iterations_per_second')))) {

  ####-----#----- Read from the IRC server -----#-----####
  foreach my $current_received_message ($core->{'ircserver'}->read()) {
    $core->log_normal('INCOMING',$current_received_message);

    my $name = 'fork'.$core->value_get('ircserver','IRC_messages_received_this_connection');
    $core->child_add($name,$core->value_get('config','irc_parser'));
    ## Message parsers need to know the nickname the bot is using, and the incoming message
    $core->child_send($name,$core->value_get('core','nick'));
    $core->child_send($name,$current_received_message);
    $core->value_increment('ircserver','IRC_messages_received_this_connection',1);
    $core->value_set('ircserver','last_received_IRC_message_time',time);
  }


  ####-----#----- Read from children -----#-----####
  foreach my $name ($core->child_list()) {
    my $status = $core->child_status($name);

    ## Clean up dead children
    if($status eq 'dead') { $core->child_delete($name); }

    ## Run responses from living children through the GAPIL parser
    elsif($status eq 'ready') {
      foreach my $current_received_message ($core->child_read($name)) {
        if($current_received_message) {
          $logger->log_debug($name.': '.$current_received_message);
          $core->{'parser'}->parse_message($name,$current_received_message);
        }
      }
    }
  }

  ####-----#----- Read from delays -----#-----####
  foreach my $timestamp ($core->delay_list()) {
    if($timestamp <= time) {
      $core->delay_fire($timestamp);
    }
  }

  ####-----#----- Send to the IRC server -----#-----####
  $core->{'ircserver'}->spool();

}

END {
  $core->log_event('Saving persistent dictionaries.');
  my @dictionaries = $core->dictionary_list();
  foreach my $current_dictionary (@dictionaries) {
    if(!$core->value_exists($current_dictionary,'NOSAVE')) {
      $core->dictionary_save($current_dictionary);
    }
  }
  $core->log_event('Shutting down.');
}


