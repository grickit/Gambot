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

### This file provides an object to store and manage the various bot
### core resources

package Gambot::GAPIL::CommandCore;
use strict;
use warnings;

use Gambot::IO;
use Gambot::GAPIL::Dictionary;
use Gambot::GAPIL::Child;
use Gambot::GAPIL::Event;
use Gambot::GAPIL::Delay;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

## Constructor
sub new {
  my $class = shift;
  my $self = {};

  $self->{'dictionaries'} = {};
  $self->{'children'} = {};
  $self->{'events'} = {};
  $self->{'delays'} = {};
  $self->{'logger'} = '';
  $self->{'ircserver'} = '';
  $self->{'parser'} = '';

  bless($self,$class);
  return $self;
}


## Server manipulation
sub server_send {
  my ($self,$message) = @_;

  return $self->{'ircserver'}->send($message);
}

sub server_connect {
  my ($self) = @_;

  return $self->{'ircserver'}->connect();
}

sub server_disconnect {
  my ($self) = @_;

  return $self->{'ircserver'}->disconnect();
}


## Logging
sub log_error() {
  my ($self,$message) = @_;

  return $self->{'logger'}->log_error($message);
}

sub log_event() {
  my ($self,$message) = @_;

  return $self->{'logger'}->log_event($message);
}

sub log_normal() {
  my ($self,$prefix,$message) = @_;

  return $self->{'logger'}->log_normal($prefix,$message);
}

sub log_debug() {
  my ($self,$message) = @_;

  return $self->{'logger'}->log_debug($message);
}


## Dictionary manipulation
sub dictionary_exists {
  my ($self,$dict) = @_;

  if(exists $self->{'dictionaries'}{$dict}) {
    return 1;
  }
  return '';
}

sub dictionary_list {
  my ($self) = @_;

  my @list;
  foreach my $dictionary (keys $self->{'dictionaries'}) {
    push(@list,$dictionary);
  }
  return @list;
}

sub dictionary_get {
  my ($self,$dict) = @_;

  if(!$self->dictionary_exists($dict)) {
    $self->{'dictionaries'}{$dict} = new Gambot::GAPIL::Dictionary($self,$dict);
  }
  return $self->{'dictionaries'}{$dict};
}

sub dictionary_delete {
  my ($self,$dict) = @_;

  if($self->dictionary_exists($dict)) {
    $self->{'dictionaries'}{$dict} = undef;
    delete $self->{'dictionaries'}{$dict};
    return $dict;
  }
  return '';
}

sub dictionary_load {
  my ($self,$dict) = @_;
  my $filename = $self->value_get('core','home_directory').'/persistent/'.$dict.'.txt';

  $self->dictionary_get($dict)->{'values'} = {};
  $self->dictionary_get($dict)->load($filename);
  $self->value_add($dict,'autosave',1);

  return 1;
}

sub dictionary_save {
  my ($self,$dict) = @_;
  my $filename = $self->value_get('core','home_directory').'/persistent/'.$dict.'.txt';
  $self->value_delete($dict,'autosave');
  $self->dictionary_get($dict)->save($filename);
  $self->value_add($dict,'autosave',1);

  return 1;
}


## Value manipulation
sub value_exists {
  my ($self,$dict,$key) = @_;

  return $self->dictionary_get($dict)->value_exists($key);
}

sub value_list {
  my ($self,$dict) = @_;

  return $self->dictionary_get($dict)->value_list();
}

sub value_get {
  my ($self,$dict,$key) = @_;

  return $self->dictionary_get($dict)->value_get($key);
}

sub value_set {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_set($key,$value);
}

sub value_delete {
  my ($self,$dict,$key) = @_;

  return $self->dictionary_get($dict)->value_delete($key);
}

sub value_add {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_add($key,$value);
}

sub value_replace {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_replace($key,$value);
}

sub value_append {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_append($key,$value);
}

sub value_prepend {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_prepend($key,$value);
}

sub value_increment {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_increment($key,$value);
}

sub value_decrement {
  my ($self,$dict,$key,$value) = @_;

  return $self->dictionary_get($dict)->value_decrement($key,$value);
}


## Child manipulation
sub child_exists {
  my ($self,$name) = @_;

  if(exists $self->{'children'}{$name}) {
    return 1;
  }
  return '';
}

sub child_list {
  my ($self) = @_;

  my @list;
  foreach my $name (keys $self->{'children'}) {
    push(@list,$name);
  }
  return @list;
}

sub child_get {
  my ($self,$name) = @_;

  if($self->child_exists($name)) {
    return $self->{'children'}{$name};
  }
  return '';
}

sub child_status {
  my ($self,$name) = @_;

  if($self->child_exists($name)) {
    return $self->{'children'}{$name}->status();
  }
  else {
    $self->log_error("Tried to check the status of child named $name, but it doesn't exist.");
  }
  return '';
}

sub child_add {
  my ($self,$name,$command) = @_;

  if(!$self->child_exists($name)) {
    $self->log_debug("Adding child named $name with the command: \"$command\"");
    $self->{'children'}{$name} = new Gambot::GAPIL::Child($name,$command);
    $self->child_send($name,$name);
    if($self->event_exists('child_added:'.$name)) {
      $self->event_fire('child_added:'.$name);
    }
    return 1;
  }
  else {
    $self->log_error("Tried to add child named $name, but one already exists.");
  }
  return '';
}

sub child_delete {
  my ($self,$name) = @_;

  if($self->child_exists($name)) {
    $self->log_debug("Deleting child named $name.");
    $self->{'children'}{$name}->kill();
    delete $self->{'children'}{$name};
    if($self->event_exists('child_deleted:'.$name)) {
      $self->event_fire('child_deleted:'.$name);
    }
    return 1;
  }
  else {
    $self->log_error("Tried to delete child named $name, but it doesn't exist.");
  }
  return '';
}

sub child_read {
  my ($self,$name) = @_;

  my @received_messages = ();
  if($self->child_exists($name)) {
    @received_messages = $self->{'children'}{$name}->read();
  }
  else {
    $self->log_error("Tried to read from child named $name, but it doesn't exist.");
  }
  return @received_messages;
}

sub child_send {
  my($self,$name,$message) = @_;

  if($self->child_exists($name) && pipe_status($name,$self->{'children'}{$name}{'read_pipe'}) ne 'dead') {
    $self->log_debug("Sending \"$message\" to child named $name.");
    $self->{'children'}{$name}->send($message);
    return 1;
  }
  else {
    $self->log_error("Tried to send a message to child named $name, but it doesn't exist.");
  }
  return '';
}


## Event manipulation
sub event_exists {
  my ($self,$name) = @_;

  if($self->value_exists('events',$name)) {
    return 1;
  }
  return '';
}

sub event_list {
  my ($self) = @_;

  my @list;
  foreach my $name (keys $self->{'events'}) {
    push(@list,$name);
  }
  return @list;
}

sub event_get {
  my ($self,$name) = @_;

  if(!$self->event_exists($name)) {
    $self->{'events'}{$name} = new Gambot::GAPIL::Event($self,$name);
  }
  return $self->{'events'}{$name};
}

sub event_delete {
  my ($self,$name) = @_;

  if($self->event_exists($name)) {
    $self->{'events'}{$name} = undef;
    delete $self->{'events'}{$name};
    return $name;
  }
  return '';
}

sub event_subscribe {
  my ($self,$name,$childname,$message) = @_;

  return $self->event_get($name)->subscribe($childname,$message);
}

sub event_unsubscribe {
  my ($self,$name,$number) = @_;

  return $self->event_get($name)->unsubscribe($number);
}

sub event_fire {
  my ($self,$name) = @_;

  return $self->event_get($name)->fire();
}


## Delay manipulation
sub delay_exists {
  my ($self,$timestamp) = @_;

  if($self->value_exists('delays',$timestamp)) {
    return 1;
  }
  return '';
}

sub delay_list {
  my ($self) = @_;

  my @list;
  foreach my $timestamp (keys $self->{'delays'}) {
    push(@list,$timestamp);
  }
  return @list;
}

sub delay_get {
  my ($self,$timestamp) = @_;

  if(!$self->delay_exists($timestamp)) {
    $self->{'delays'}{$timestamp} = new Gambot::GAPIL::Delay($self,$timestamp);
  }
  return $self->{'delays'}{$timestamp};
}

sub delay_delete {
  my ($self,$timestamp) = @_;

  if($self->delay_exists($timestamp)) {
    $self->{'delays'}{$timestamp} = undef;
    delete $self->{'delays'}{$timestamp};
    return $timestamp;
  }
  return '';
}

sub delay_subscribe {
  my ($self,$timestamp,$childname,$message) = @_;

  # If it's less than a year, assume it's an offset
  if($timestamp <= 31536000) { $timestamp += time; }

  return $self->delay_get($timestamp)->subscribe($childname,$message);
}

sub delay_unsubscribe {
  my ($self,$timestamp,$number) = @_;

  return $self->delay_get($timestamp)->unsubscribe($number);
}

sub delay_fire {
  my ($self,$timestamp) = @_;

  if($timestamp > time) { $self->log_debug('Firing delay '.$timestamp.' early.'); }
  elsif($timestamp < time) { $self->log_debug('Firing delay '.$timestamp.' late.'); }
  else { $self->log_debug('Firing delay '.$timestamp.' on schedule.'); }

  my $result = $self->delay_get($timestamp)->fire();
  $self->delay_delete($timestamp);
  return $result;
}


1;