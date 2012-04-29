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

##%dict{config} stores stuff from the config file.
##%dict{core} stores other core data.
##%events allows children to schedule GAPIL calls to be run when an event is fired
##%delays allows children to schedule GAPIL calls to be run a certain number of seconds in the future
##%autosave contains a list of all manually saved and loaded members of %dict to be autosaved at shutdown
my %dicts;
$dicts{'core'} = {};
$dicts{'config'} = {};
my %events;
my %delays;
my %autosave;

value_set('core','home_directory',$FindBin::Bin);
value_set('core','configuration_file','config.txt');
value_set('core','message_count',0);
value_set('config','delay',0.1);

##%pid_pipes store the process ids of processors and scripts
##%read_pipes are for getting data from processors and scripts
##%write_pipes are for sending data to processors and scripts
my %pid_pipes;
my %read_pipes;
my %write_pipes;

##The connection to the IRC server
my $socket_connection;
my $socket_buffer;

my @pending_outgoing;
my $last_second = time;
my $messages_this_second = 0;


####-----#----- Subroutines -----#-----####
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
  $autosave{$dict} = 1;
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
      if ($current_line =~ /^([a-zA-Z0-9_-]+) = "(.+)"$/) {
	&value_set($dict,$1,$2);
      }
    }
    $autosave{$dict} = 1;
  }
  else {
    error_output("Tried to load persistence file \"$filename\", but it doesn't exist.");
  }
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
  return (dict_exists($dict) && exists $dicts{$dict}{$key}) ;
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

sub send_server_message {
  push(@pending_outgoing,$_[0]);
}
sub send_pipe_message {
  my ($pipeid, $message) = @_;
  if(&check_pipe_exists($pipeid) && pipe_status($read_pipes{$pipeid}) ne 'dead') {
    debug_output("Sending \"$message\" to a pipe named $pipeid.");
    my $write_pipe = $write_pipes{$pipeid};
    print $write_pipe $message."\n";
  }
  else {
    error_output("Tried to send a message to a pipe named $pipeid, but it doesn't exist.");
  }
}

sub check_pipe_exists {
  my $pipeid = shift;
  return (defined $pid_pipes{$pipeid});
}

sub kill_pipe {
  my $pipeid = shift;
  if(&check_pipe_exists($pipeid)) {
    debug_output("Killing pipe named $pipeid.");
    kill 1, $pid_pipes{$pipeid};
    delete $pid_pipes{$pipeid};
    delete $read_pipes{$pipeid};
    delete $write_pipes{$pipeid};
  }
  else {
    error_output("Tried to kill a pipe named $pipeid, but it doesn't exist.");
  }
}

sub run_command {
  my ($pipeid, $command) = @_;
  if(&check_pipe_exists($pipeid)) {
    error_output("Tried to start a pipe named $pipeid, but one already exists.");
  }
  else {
    debug_output("Starting a pipe named $pipeid with the command: $command");
    $pid_pipes{$pipeid} = open2($read_pipes{$pipeid},$write_pipes{$pipeid},$command);
    &send_pipe_message($pipeid,$pipeid);
  }
}

sub reconnect {
  $socket_connection->close();
  event_output('Reconnecting.');
  $socket_connection = &create_socket_connection(value_get('config','server'),value_get('config','port'),value_get('core','nick'),value_get('config','password'));
  fcntl($socket_connection, F_SETFL(), O_NONBLOCK());
  value_set('core','message_count',0);
}

sub schedule_event {
  my ($name, $call) = @_;
  debug_output("Scheduling a call for $name.");
  if(!defined $events{$name}) { $events{$name} = (); }
  push(@{$events{$name}},$call);
}
sub fire_event {
  my $name = shift;
  debug_output("Firing event: $name.");
  foreach my $call (@{$events{$name}}) {
    parse_command($call);
  }
  delete $events{$name};
}
sub check_event_exists {
  my $name = shift;
  if(defined $events{$name}) { return $name; }
  else { return ''; }
}
sub schedule_delay {
  my ($name, $delay, $call) = @_;
  my $time = time + $delay;
  debug_output("Scheduling $name at $time.");
  $delays{$name} = [$time,$call];
}
sub fire_delay {
  my $name = shift;
  my $time = $delays{$name}[0];
  debug_output("Firing delay $name at ".time."; ".(time-$time)." seconds late.");
  parse_command($delays{$name}[1]);
  delete $delays{$name};
}

####-----#----- Actual Work -----#-----####
&load_switches();
&read_configuration_file(value_get('core','home_directory') . '/configurations/' . value_get('core','configuration_file'));
value_set('core','nick',value_get('config','base_nick'));
$socket_connection = &create_socket_connection(value_get('config','server'),value_get('config','port'),value_get('core','nick'),value_get('config','password'));
fcntl(\*STDIN, F_SETFL(), O_NONBLOCK());
fcntl($socket_connection, F_SETFL(), O_NONBLOCK());

#An awesome trick to register STDIN and STDOUT as children just like the message parsers and scripts
#No extra work involved in reading STDIN now.
$pid_pipes{'main'} = 1;
$read_pipes{'main'} = \*STDIN;
$write_pipes{'main'} = \*STDOUT;

while(defined select(undef,undef,undef,value_get('config','delay'))) {
  ####-----#----- Read from the socket -----#-----####
  my $socket_status = &pipe_status($socket_connection);

  if ($socket_status eq 'dead') {
    error_output('IRC connection died.');
    if(&value_get('core','staydead')) {
      exit;
    }
    else {
      reconnect();
    }
  }

  elsif ($socket_status eq 'ready') {
    my @messages = read_lines($socket_connection, $socket_status);
    foreach my $current_message (@messages) {
      normal_output('INCOMING',$current_message);
      my $id = 'fork'.value_get('core','message_count');
      &run_command($id,value_get('config','processor'));
      &send_pipe_message($id,value_get('core','nick'));
      &send_pipe_message($id,$current_message);
      value_increment('core','message_count',1);
    }
  }

  ####-----#----- Read from children -----#-----####
  while(my ($id, $pipe) = each %read_pipes) {
    my $pipe_status = &pipe_status($pipe);

    if ($pipe_status eq 'dead') {
      kill_pipe($id);
    }
    elsif ($pipe_status eq 'ready') {
      my @commands = read_lines($pipe);
      foreach my $current_command (@commands) {
	parse_command($current_command,$id) if $current_command;
      }
    }
  }

  ####-----#----- Check delay events -----#-----####
  while(my ($name, $array) = each %delays) {
    if(time >= @{$array}[0]) {
      fire_delay($name);
    }
  }

  ####-----#----- Send outgoing messages -----#-----####
  for (1; ($messages_this_second < 3) && (my $message = shift(@pending_outgoing)); $messages_this_second++) {
    normal_output('OUTGOING',$message);
    print $socket_connection $message . "\015\012";
  }
  if ($messages_this_second >= 3 && $last_second != time) {
    $messages_this_second = 0;
    $last_second = time;
  }
}

END {
  &event_output("Saving persistent dicts.");
  &dict_save_all();
  &event_output("Shutting down.");
}
