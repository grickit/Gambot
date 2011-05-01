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

use threads;
use threads::shared;
use Thread::Queue;

use FindBin;
use lib "$FindBin::Bin/modules/";

use URI::Escape;

use Gambot::Actions::Output;
use Gambot::Actions::Connect;
use Gambot::Threads::Terminal;
use Gambot::Threads::Timer;
use Gambot::Parser;
use Gambot::Configure;

##%config will be for variables specifically related to the configuration files (server, nick, password, log location, and so on)
##%core will be for things related to the program (where the script is located, special flags and options)
my (%core, %config) = ({}, {});
share(%core);
share(%config);

$core{'home_directory'} = $FindBin::Bin;
$core{'configuration_file'} = 'config.txt';

for (my $current_arg = 0; $current_arg < @ARGV; $current_arg++) {
  my $current_arg_value = $ARGV[$current_arg];

  if (($current_arg_value =~ /^-v$/) || ($current_arg_value =~ /^--verbose$/)) {
    $core{'verbose'} = 1;
  }

  elsif ($current_arg_value =~ /^--silent$/) {
    $core{'silent'} = 1;
  }

  elsif ($current_arg_value =~ /^--config$/) {
    $current_arg++;
    $core{'configuration_file'} = $ARGV[$current_arg];
  }

  elsif ($current_arg_value =~ /^--help$/) {
    print "Usage: perl Gambot.pl [OPTION]...\n";
    print "A flexible IRC bot framework that can be updated and fixed while running.\n\n";
    print "-v, --verbose	Prints all messages to the terminal.\n";
    print "		perl Gambot.pl --verbose\n\n";
    print "--silent	Disables logging of messages to files.\n";
    print "		perl Gambot.pl --silent\n\n";
    print "--config	The argument after this specifies the configuration file to use.\n";
    print "		These are stored in \$script_location/configurations/\n";
    print "		Only give a file name. Not a path.\n";
    print "		perl Gambot.pl --config foo.txt\n\n";
    print "--help		Displays this help.\n";
    print "		perl Gambot.pl --help\n\n";
    print "Ordinarily Gambot will not print output to the terminal, but will log everything to log files.\n";
    print "\$script_location/configurations/config.txt is the default configuration file.\n\n";
    print "For more help, try our IRC channel: ##Gambot at chat.freenode.net\n";
    print "<http://webchat.freenode.net/?channels=\%23\%23Gambot>\n";
  }
}

##These subroutines give the other modules access to %core and %config
sub get_config_value {
  my $name = shift;
  return $config{$name};
}

sub set_config_value {
  my ($name, $value) = @_;
  $config{$name} = $value;
}

sub get_core_value {
  my $name = shift;
  return $core{$name};
}

sub set_core_value {
  my ($name, $value) = @_;
  $core{$name} = $value;
}

read_configuration($core{'home_directory'} . '/configurations/' . $core{'configuration_file'});
$core{'nick'} = $config{'base_nick'};

our $socket_connection = connect_to_server($config{'server'}, $config{'port'}, $core{'nick'}, $config{'password'});

my $sockqueue = Thread::Queue->new();
my @threads = ();

sub process_message {
  while (my $inbound = $sockqueue->dequeue()) {
    chop $inbound; 

    #Filter MotD spam
    if ($inbound !~ /^:([a-zA-Z0-9-_\w]+\.)+(net|com|org|gov|edu) (372|375|376) $core{'nick'} :.+/) {
      #Highlighted?
      if ($inbound =~ /$core{'nick'}/) { colorOutput("INCOMING","$inbound",'bold yellow'); }
      else { colorOutput("INCOMING","$inbound",''); }
 
      my $string = uri_escape($inbound,"A-Za-z0-9\0-\377");
   
      open(MESSAGE, "perl $core{'home_directory'}/processors/$config{'processor_file_name'} \"$string\" \"$core{'nick'}\" |");
      while (my $current_line = <MESSAGE>) {
	parse_command($current_line);
      }              
      close(MESSAGE);
    }
  }
}

if ($config{'enable_terminal'}) {
  push(@threads,threads->create(\&terminal_input));
  $threads[-1]->detach();
}

if ($config{'enable_timer'}) {
  push(@threads,threads->create(\&timer_clock));
  $threads[-1]->detach();
}

for my $i (1..$config{'number_of_processors'}) {
  push(@threads,threads->create(\&process_message));
  $threads[-1]->detach();
}

#Grab socket input
while(my $incoming_message = <$socket_connection>) { 
  $sockqueue->enqueue($incoming_message);
}

