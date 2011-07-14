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

use FindBin;
use lib "$FindBin::Bin/modules/";
use URI::Escape;
use Fcntl qw(F_SETFL O_NONBLOCK);
use IO::Select;
use Term::ANSIColor;

use Gambot::Output;
use Gambot::Connect;
use Gambot::Parser;
use Gambot::Configure;

$| = 1;
my $main = $$;
$SIG{CHLD} = 'IGNORE';
$Term::ANSIColor::AUTORESET = 1;

###$forks tracks the number of message processing forks that have been spawned
my $forks = 0;
###%config will be for variables specifically related to the configuration files (server, nick, password, log location, and so on)
my %config;
###%core will be for things related to the program (where the script is located, special flags and options)
my %core;
###These two hashes will store information about started scripts
my %script_pipes;
my %script_pids;

my $socket_connection;
my $selector = new IO::Select;

###This stores the script location and the default name of the configuration file.
$core{'home_directory'} = $FindBin::Bin;
$core{'configuration_file'} = 'config.txt';

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

sub send_server_message {
  print $socket_connection "$_[0]\n";
}

sub create_processing_fork {
  my $inbound_message = shift;

  #Filter MotD spam
  if ($inbound_message !~ /^:([a-zA-Z0-9-_\w]+\.)+(net|com|org|gov|edu) (372|375|376) $core{'nick'} :.+/) {
    #Highlighted?
    if ($inbound_message =~ /$core{'nick'}/) { colorOutput("INCOMING","$inbound_message",'bold yellow'); }
    else { colorOutput("INCOMING","$inbound_message",''); }
    my $encoded_string = uri_escape($inbound_message,"A-Za-z0-9\0-\377");

    open(my $response, "$config{'processor'} \"$encoded_string\" \"$core{'nick'}\" |");
    $selector->add($response);
  }
}

sub create_script_fork {
  my ($script_name, $script_filename) = @_;
  unless($script_pids{$script_name}) {
    colorOutput("STTSCRPT","Starting script: $script_name with command: $script_filename",'bold green');
    $script_pids{$script_name} = open($script_pipes{$script_name}, "$script_filename |");
    $selector->add($script_pipes{$script_name});
  }
  else {
    colorOutput("BOTERROR","Attempted to start script with a taken name: $script_name",'bold red');
  }
}

sub end_script_fork {
  my $script_name = shift;
  if($script_pids{$script_name}) {
    $selector->remove($script_pipes{$script_name});
    kill 1, $script_pids{$script_name};
    close($script_pipes{$script_name});
    delete $script_pipes{$script_name};
    delete $script_pids{$script_name};
    colorOutput("ENDSCRPT","Ended script: $script_name",'bold green');
  }
  else {
    colorOutput("BOTERROR","Attempted to terminate nonexistant script: $script_name",'bold red');
  }
}

get_command_arguments();
read_configuration_file($core{'home_directory'} . '/configurations/' . $core{'configuration_file'});
$core{'nick'} = $config{'base_nick'};

$socket_connection = create_socket_connection($config{'server'}, $config{'port'}, $core{'nick'}, $config{'password'});
fcntl($socket_connection, F_SETFL(), O_NONBLOCK());
fcntl(\*STDIN, F_SETFL(), O_NONBLOCK());

my $socket_buffer = '';
while(defined select(undef,undef,undef,0.2)) {
  my @full_messages = ();
  my $bytes_read = sysread($socket_connection, $socket_buffer, 1024, length($socket_buffer));
    if (defined($bytes_read)) {
      if ($bytes_read == 0) {
	###The connection is dead
	print "Connection to IRC server died.\n";
	if ($core{'staydead'}) {
	  exit;
	}
	else {
	  $socket_connection = create_socket_connection($config{'server'}, $config{'port'}, $core{'nick'}, $config{'password'});
	  fcntl($socket_connection, F_SETFL(), O_NONBLOCK());
	}
      }
      else {
	###We have content
	@full_messages = split(/\x0D\x0A/,$socket_buffer);
	if ($socket_buffer !~ /\x0D\x0A$/) {
	  $socket_buffer = $full_messages[-1];
	  pop(@full_messages);
	}
	else { $socket_buffer = ''; }
      }
    }
    else {
      ###Read some other time
    }

  foreach my $current_line (@full_messages) {
    #print "socket has message. spawning fork.\n";
    create_processing_fork($current_line) if ($current_line);
  }

  while(my $current_line = <STDIN>) {
    $current_line =~ s/\s+$//g;
    parse_command($current_line) if ($current_line);
  }

  my @ready_forks = $selector->handles();
  foreach my $current_fork (@ready_forks) {
    my $fork_buffer = '';
    fcntl($current_fork, F_SETFL(), O_NONBLOCK());
    while(1) {
      my $bytes_read = sysread($current_fork, $fork_buffer, 1024, length($fork_buffer));
      if(defined $bytes_read) {
	if($bytes_read == 0) { last; }
	else {
	  #We have content
	}
      }
      else { last; }
    }
    my @full_commands = split(/[\r\n]+/,$fork_buffer);
    foreach my $current_command (@full_commands) {
      if($current_command =~ /^end>/) {
	$selector->remove($current_fork);
	close($current_fork);
	$current_command = 0;
      }
      parse_command($current_command) if ($current_command);
    }
  }
}
print "Done\n";