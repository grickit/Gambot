#!/usr/bin/perl
# Copyright (C) 2010-2013 by Derek Hoagland <grickit@gmail.com>
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

### This file provides an implementation of the Gambot API Language.

package Gambot::GAPILCore;
use strict;
use warnings;
use IPC::Open2;
use FindBin;
use lib "$FindBin::Bin";

use Gambot::IO;
use Gambot::Logging;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  server_send
  server_reconnect
  dict_exists
  dict_save
  dict_load
  dict_save_all
  dict_delete
  value_exists
  value_get
  value_add
  value_replace
  value_set
  value_append
  value_prepend
  value_increment
  value_decrement
  value_delete
  child_send
  child_delete
  child_exists
  child_add
  event_schedule
  event_fire
  event_exists
  delay_schedule
  delay_fire
  %dicts
  %pid_pipes
  %read_pipes
  %write_pipes
  $irc_connection
  $last_received_IRC_message_time
  $last_sent_IRC_message_time
  $IRC_messages_sent_this_second
  $IRC_messages_received_this_connection
  @pending_outgoing_IRC_messages
);
our @EXPORT_OK = qw();

## %dict{config} stores stuff from the config file.
## %dict{core} stores other core data.
## %events allows children to schedule GAPIL calls to be run when an event is fired
## %delays allows children to schedule GAPIL calls to be run a certain number of seconds in the future
## %autosave contains a list of all manually saved and loaded members of %dict to be autosaved at shutdown
our %dicts;
$dicts{'core'} = {};
$dicts{'config'} = {};
$dicts{'events'} = {};
$dicts{'delay_timers'} = {};
$dicts{'delay_events'} = {};

## %pid_pipes store the process ids of child processes
## %read_pipes are for getting data from child processes
## %write_pipes are for sending data to child processes
our %pid_pipes;
our %read_pipes;
our %write_pipes;

our $irc_connection; # The connection to the IRC server

our $last_received_IRC_message_time = time; # Used for client-side ping timeout
our $last_sent_IRC_message_time = time; # Used for throttling IRC messages
our $IRC_messages_sent_this_second = 0; # Used for throttling IRC messages
our $IRC_messages_received_this_connection = 0; # Used for naming child processes
our @pending_outgoing_IRC_messages; # Used to hold messages that are being throttled


my %autosave;

sub server_send {
  push(@pending_outgoing_IRC_messages,$_[0]);
}

sub server_reconnect {
  $irc_connection->close();
  event_log('Reconnecting.');
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
    error_log("Tried to load persistence file \"$filename\", but it doesn't exist.");
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
  if(&child_exists($childid) && filehandle_status($read_pipes{$childid}) ne 'dead') {
    debug_log("Sending \"$message\" to child named $childid.");
    my $write_pipe = $write_pipes{$childid};
    print $write_pipe $message."\n";
  }
  else {
    error_log("Tried to send a message to child named $childid, but it doesn't exist.");
  }
}

sub child_delete {
  my $childid = shift;
  if(&child_exists($childid)) {
    debug_log("Deleting child named $childid.");
    kill 1, $pid_pipes{$childid};
    delete $pid_pipes{$childid};
    delete $read_pipes{$childid};
    delete $write_pipes{$childid};
  }
  else {
    error_log("Tried to delete child named $childid, but it doesn't exist.");
  }
}

sub child_exists {
  my $childid = shift;
  return (defined $pid_pipes{$childid});
}

sub child_add {
  my ($childid, $command) = @_;
  if(&child_exists($childid)) {
    error_log("Tried to add child named $childid, but one already exists.");
  }
  else {
    debug_log("Adding child named $childid with the command: $command");
    $pid_pipes{$childid} = open2($read_pipes{$childid},$write_pipes{$childid},$command);
    &child_send($childid,$childid);
  }
}

sub event_schedule {
  my ($name, $call) = @_;
  debug_log("Scheduling a call for $name.");
  if(value_exists('events',$name)) { value_append('events',$name,"$call\n"); }
  else { value_set('events',$name,"$call\n"); }
}

sub event_fire {
  my $name = shift;
  debug_log("Firing event: $name.");
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
  debug_log("Scheduling a call at $time.");
  if(value_exists('delay_events',$hash)) { error_log("Delayed event collision at time: $time with call: $call"); }
  else { value_set('delay_events',$hash,$call); }
  if(value_exists('delay_timers',$time)) { value_append('delay_timers',$time,"$hash,"); }
  else { value_set('delay_timers',$time,"$hash,"); }
}

sub delay_fire {
  my $time = shift;
  debug_log("Firing delay $time at ".time."; ".(time-$time)." seconds late.");
  foreach my $hash (split(/[,]+/,value_get('delay_timers',$time))) {
    parse_command(value_get('delay_events',$hash));
    value_delete('delay_events',$hash);
  }
  value_delete('delay_timers',$time);
}

1;