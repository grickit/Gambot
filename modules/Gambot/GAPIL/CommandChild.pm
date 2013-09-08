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

### This file provides an object to help child processes make GAPIL
### calls to the bot core.

package Gambot::GAPIL::CommandChild;
use strict;
use warnings;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  strip_newlines
  stdin_read
  gapil_call
);
our @EXPORT_OK = qw();

sub strip_newlines {
  my $string = shift;

  if($string) {
    $string =~ s/[\r\n\s\t]+$//;
    return $string;
  }
  return '';
}

sub stdin_read {
  my $message = <STDIN>;
  return strip_newlines($message);
}

sub gapil_call {
  my ($call) = @_;

  print 'return '.$call."\n";
  return stdin_read();
}


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

  return gapil_call('server_send>'.$message);
}

sub server_connect {
  my ($self) = @_;

  return gapil_call('server_connect>');
}

sub server_disconnect {
  my ($self) = @_;

  return gapil_call('server_disconnect>');
}


## Logging
sub log_error() {
  my ($self,$message) = @_;

  return gapil_call('log_error>'.$message);
}

sub log_event() {
  my ($self,$message) = @_;

  return gapil_call('log_event>'.$message);
}

sub log_normal() {
  my ($self,$prefix,$message) = @_;

  return gapil_call('log_normal>'.$prefix.'>'.$message);
}

sub log_debug() {
  my ($self,$message) = @_;

  return gapil_call('log_debug>'.$message);
}


## Dictionary manipulation
sub dictionary_exists {
  my ($self,$dict) = @_;

  return gapil_call('dictionary_exists>'.$dict);
}

sub dictionary_list {
  my ($self) = @_;

  return gapil_call('dictionary_list>');
}

sub dictionary_delete {
  my ($self,$dict) = @_;

  return gapil_call('dictionary_delete>');
}

sub dictionary_load {
  my ($self,$dict) = @_;

  return gapil_call('dictionary_load>'.$dict);
}

sub dictionary_save {
  my ($self,$dict) = @_;

  return gapil_call('dictionary_save>'.$dict);
}


## Value manipulation
sub value_exists {
  my ($self,$dict,$key) = @_;

  return gapil_call('value_exists>'.$dict.'>'.$key);
}

sub value_list {
  my ($self,$dict) = @_;

  return gapil_call('value_list>'.$dict);
}

sub value_get {
  my ($self,$dict,$key) = @_;

  return gapil_call('value_get>'.$dict.'>'.$key);
}

sub value_set {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_set>'.$dict.'>'.$key.'>'.$value);
}

sub value_delete {
  my ($self,$dict,$key) = @_;

  return gapil_call('value_delete>'.$dict.'>'.$key);
}

sub value_add {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_add>'.$dict.'>'.$key.'>'.$value);
}

sub value_replace {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_replace>'.$dict.'>'.$key.'>'.$value);
}

sub value_append {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_append>'.$dict.'>'.$key.'>'.$value);
}

sub value_prepend {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_prepend>'.$dict.'>'.$key.'>'.$value);
}

sub value_increment {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_increment>'.$dict.'>'.$key.'>'.$value);
}

sub value_decrement {
  my ($self,$dict,$key,$value) = @_;

  return gapil_call('value_decrement>'.$dict.'>'.$key.'>'.$value);
}


## Child manipulation
sub child_exists {
  my ($self,$name) = @_;

  return gapil_call('child_exists>'.$name);
}

sub child_list {
  my ($self) = @_;

  return gapil_call('child_list>');
}

sub child_add {
  my ($self,$name,$command) = @_;

  return gapil_call('child_add>'.$name.'>'.$command);
}

sub child_delete {
  my ($self,$name) = @_;

  return gapil_call('child_delete>'.$name);
}

sub child_send {
  my($self,$name,$message) = @_;

  return gapil_call('child_send>'.$name.'>'.$message);
}


## Event manipulation
sub event_exists {
  my ($self,$name) = @_;

  return gapil_call('event_exists>'.$name);
}

sub event_list {
  my ($self) = @_;

  return gapil_call('event_list>');
}

sub event_delete {
  my ($self,$name) = @_;

  return gapil_call('event_delete>'.$name);
}

sub event_subscribe {
  my ($self,$name,$message) = @_;

  return gapil_call('event_subscribe>'.$name.'>'.$message);
}

sub event_unsubscribe {
  my ($self,$name,$number) = @_;

  return gapil_call('event_unsubscribe>'.$name.'>'.$number);
}

sub event_fire {
  my ($self,$name) = @_;

  return gapil_call('event_fire>'.$name);
}


## Delay manipulation
sub delay_exists {
  my ($self,$timestamp) = @_;

  return gapil_call('delay_exists>'.$timestamp);
}

sub delay_list {
  my ($self) = @_;

  return gapil_call('delay_list>');
}

sub delay_delete {
  my ($self,$timestamp) = @_;

  return gapil_call('delay_delate>'.$timestamp);
}

sub delay_subscribe {
  my ($self,$timestamp,$message) = @_;

  return gapil_call('delay_subscribe>'.$timestamp.'>'.$message);
}

sub delay_unsubscribe {
  my ($self,$timestamp,$number) = @_;

  return gapil_call('delay_unsubscribe>'.$timestamp.'>'.$number);
}

sub delay_fire {
  my ($self,$timestamp) = @_;

  return gapil_call('delay_fire>'.$timestamp);
}


1;