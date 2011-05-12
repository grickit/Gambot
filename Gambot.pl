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
use IO::Select;
use Fcntl qw(F_SETFL O_NONBLOCK);
use Errno qw( EAGAIN EINTR );
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
###%read_pipes is mostly worthless. It stores the pipes that the message forks would theoretically read from.
my %read_pipes;
###%write_pipes stores the end of the pipes that the fork will write to, to send messages back to the main process
my %write_pipes;

my $selector = new IO::Select;
my $socket_connection = new IO::Select;

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
  pipe $read_pipes{$forks}, $write_pipes{$forks};
  $selector->add($read_pipes{$forks});
    unless (my $pid = fork()) {

      ###CHILD PROCESS {
	my $write_pipe = $write_pipes{$forks};
	#Filter MotD spam
	if ($inbound_message !~ /^:([a-zA-Z0-9-_\w]+\.)+(net|com|org|gov|edu) (372|375|376) $core{'nick'} :.+/) {
	  #Highlighted?
	  if ($inbound_message =~ /$core{'nick'}/) {
	    colorOutput("INCOMING","$inbound_message",'bold yellow');
	  }
	  else {
	    colorOutput("INCOMING","$inbound_message",'');
	  }
      
	  my $encoded_string = uri_escape($inbound_message,"A-Za-z0-9\0-\377");
	
	  open(RESPONSE, "perl $core{'home_directory'}/processors/$config{'processor_file_name'} \"$encoded_string\" \"$core{'nick'}\" |");
	  while (my $current_line = <RESPONSE>) {
	    print $write_pipe "$current_line\n";
	  }              
	  close(RESPONSE);
	}
	exit;
      ###CHILD PROCESS }

    }
  $forks++;
}

get_command_arguments();
read_configuration_file($core{'home_directory'} . '/configurations/' . $core{'configuration_file'});
$core{'nick'} = $config{'base_nick'};

$socket_connection = create_socket_connection($config{'server'}, $config{'port'}, $core{'nick'}, $config{'password'});
fcntl($socket_connection, F_SETFL(), O_NONBLOCK());
fcntl(\*STDIN, F_SETFL(), O_NONBLOCK());

my $buffer = '';
while(defined select(undef,undef,undef,0.1)) {
  my @full_messages = ();
  my $bytes_read = sysread($socket_connection, $buffer, 1024, length($buffer));
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
	my @buffered_lines = split(/\x0D\x0A/,$buffer);
	foreach my $buffed_line (@buffered_lines) {
	  push(@full_messages,$buffed_line);
	}
	if ($buffer !~ /\x0D\x0A$/) {
	  $buffer = $buffered_lines[-1];
	  pop(@full_messages);
	}
	else { $buffer = ''; }
      }
    }
    else {
      ###Read some other time
    }

    while(my $current_line = <STDIN>) {
      $current_line =~ s/\s+$//g;
      parse_command($current_line) if ($current_line);
    }

    foreach my $current_line (@full_messages) {
      #print "socket has message. spawning fork.\n";
      create_processing_fork($current_line) if ($current_line);
    }
  

  if(my @ready_forks = $selector->can_read(0)) {
    foreach my $current_fork (@ready_forks) {
      fcntl($current_fork, F_SETFL(), O_NONBLOCK());
      while(my $current_line = <$current_fork>) {
	$current_line =~ s/\s+$//g;
	parse_command($current_line) if ($current_line);
      }
      $selector->remove($current_fork);
      close($current_fork);
    }
  }
}
print "Done\n";