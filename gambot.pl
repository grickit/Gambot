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
use FindBin;
use lib "$FindBin::Bin/modules/";

use Gambot::IO;
use Gambot::Configure;
use Gambot::Connect;
use Gambot::GAPIL;


####-----#----- Setup -----#-----####
$| = 1;
$SIG{CHLD} = 'IGNORE';
$SIG{INT} = sub { exit; }; #Exit gracefully and save data on SIGINT
$SIG{HUP} = sub { exit; }; #Exit gracefully and save data on SIGHUP
$SIG{TERM} = sub { exit; }; #Exit gracefully and save data on SIGTERM

##%config stores stuff from the config file.
##%core stores other core data.
##%variables allows message processors to store strings
##%persistent is just like variables, but is saved to disk on shutdown>
my %config;
my %core;
my %variables;
my %persistent;

$core{'home_directory'} = $FindBin::Bin;
$core{'configuration_file'} = 'config.txt';
$core{'message_count'} = 0;
$config{'delay'} = 0.1;

##%pid_pipes store the process ids of processors and scripts
##%read_pipes are for getting data from processors and scripts
##%write_pipes are for sending data to processors and scripts
my %pid_pipes;
my %read_pipes;
my %write_pipes;

##The connection to the IRC server
my $socket_connection;
my $socket_buffer;


####-----#----- Subroutines -----#-----####
sub get_config_value { return $config{$_[0]}; }
sub get_core_value { return $core{$_[0]}; }
sub get_variable_value { return $variables{$_[0]}; }

sub set_config_value { $config{$_[0]} = $_[1]; }
sub set_core_value { $core{$_[0]} = $_[1]; }
sub set_variable_value { $variables{$_[0]} = $_[1]; }

sub send_server_message {
  my $message = shift;
  normal_output('OUTGOING',$message);
  print $socket_connection $message . "\015\012";
}
sub send_pipe_message {
  my ($pipeid, $message) = @_;
  if(&check_pipe_exists($pipeid)) {
    debug_output("Sending \"$message\" to a pipe named $pipeid.");
    my $write_pipe = $write_pipes{$pipeid};
    print $write_pipe $message."\n";
    return 1;
  }
  else {
    error_output("Tried to send a message to a pipe named $pipeid, but it doesn't exist.");
    return 0;
  }
}

sub check_pipe_exists {
  my $pipeid = shift;
  return defined $pid_pipes{$pipeid};
}

sub kill_pipe {
  my $pipeid = shift;
  if(&check_pipe_exists($pipeid)) {
    debug_output("Killing pipe named $pipeid.");
    kill 1, $pid_pipes{$pipeid};
    delete $pid_pipes{$pipeid};
    delete $read_pipes{$pipeid};
    delete $write_pipes{$pipeid};
    return 1;
  }
  else {
    error_output("Tried to kill a pipe named $pipeid, but it doesn't exist.");
    return 0;
  }
}

sub run_command {
  my ($pipeid, $command) = @_;
  if(&check_pipe_exists($pipeid)) {
    error_output("Tried to start a pipe named $pipeid, but one already exists.");
    return 0;
  }
  else {
    debug_output("Starting a pipe named $pipeid with the command: $command");
    $pid_pipes{$pipeid} = open2($read_pipes{$pipeid},$write_pipes{$pipeid},$command);
    &send_pipe_message($pipeid,$pipeid);
    return 1;
  }
}

sub reconnect {
  $socket_connection->close();
  event_output('Reconnecting.');
  $socket_connection = &create_socket_connection($config{'server'},$config{'port'},$core{'nick'},$config{'password'});
  fcntl($socket_connection, F_SETFL(), O_NONBLOCK());
  $core{'message_count'} = 0;
}

sub get_persistent_value { return $persistent{$_[0]}{$_[1]}; }
sub set_persistent_value { $persistent{$_[0]}{$_[1]} = $_[2]; }
sub del_persistent_value { delete $persistent{$_[0]}{$_[1]}; }
sub read_persistence_file {
  my $domain = shift;
  my $filename = get_core_value('home_directory') . '/persistent/' . $domain;
  if (-e $filename) {
    open (my $file, $filename);
    my @lines = <$file>;

    foreach my $current_line (@lines) {
      $current_line =~ s/[\r\n\s]+$//;
      $current_line =~ s/^[\t\s]+//;
      if ($current_line =~ /^([a-zA-Z0-9_-]+) = "(.+)"$/) {
	&debug_output("Loaded $2 into $1 from domain: $domain.");
	&set_persistent_value($domain,$1,$2);
      }
    }
  }
  else {
    error_output("Tried to load persistence file \"$filename\", but it doesn't exist.");
  }
}
sub save_persistence_file {
  my $domain = shift;
  open(my $persist, '>' . get_core_value('home_directory') . '/persistent/' . $domain);
  while (my ($key, $value) = each %{$persistent{$domain}}) {
    print $persist "$key = \"$value\"\n";
  }
  close($persist);
}
sub save_all_persistence_files {
  while (my ($key, $value) = each %persistent) {
    save_persistence_file($key);
  }
}
sub check_persistence_domain_exists {
  my $domain = shift;
  return defined $persistent{$domain};
}

####-----#----- Actual Work -----#-----####
&load_switches();
&read_configuration_file($core{'home_directory'} . '/configurations/' . $core{'configuration_file'});
$core{'nick'} = $config{'base_nick'};
$socket_connection = &create_socket_connection($config{'server'},$config{'port'},$core{'nick'},$config{'password'});
fcntl(\*STDIN, F_SETFL(), O_NONBLOCK());
fcntl($socket_connection, F_SETFL(), O_NONBLOCK());

#An awesome trick to register STDIN and STDOUT as children just like the message parsers and scripts
#No extra work involved in reading STDIN now.
$pid_pipes{'main'} = 1;
$read_pipes{'main'} = \*STDIN;
$write_pipes{'main'} = \*STDOUT;

while(defined select(undef,undef,undef,$config{'delay'})) {
  ####-----#----- Read from the socket -----#-----####
  my $socket_status = &pipe_status($socket_connection);

  if ($socket_status eq 'dead') {
    error_output('IRC connection died.');
    if(&get_core_value('staydead')) {
      exit;
    }
    else {
      reconnect();
    }
  }

  elsif (length($socket_status) == 1) {
    my @messages = read_lines($socket_connection, $socket_status);
    foreach my $current_message (@messages) {
      normal_output('INCOMING',$current_message);
      my $id = "fork$core{'message_count'}";
      &run_command($id,$config{'processor'});
      &send_pipe_message($id,$core{'nick'});
      &send_pipe_message($id,$current_message);
      $core{'message_count'}++;
    }
  }

  ####-----#----- Read from children -----#-----####
  while(my ($id, $pipe) = each %read_pipes) {
    my $pipe_status = &pipe_status($pipe);

    if ($pipe_status eq 'dead') {
      kill_pipe($id);
    }
    elsif (length($pipe_status) == 1) {
      my @commands = read_lines($pipe,$pipe_status);
      foreach my $current_command (@commands) {
	parse_command($current_command,$id) if $current_command;
      }
    }
  }
}

END {
  &event_output("Saving persistent variables.");
  &save_all_persistence_files();
  &event_output("Shutting down.");
}
