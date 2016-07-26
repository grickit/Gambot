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
  my ($call,$silent) = @_;

  if($silent) {
    print $call."\n";
    return 1;
  }

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
  my ($self,$message,$silent) = @_;

  return gapil_call('server_send>'.$message,$silent);
}

sub server_connect {
  my ($self,$silent) = @_;

  return gapil_call('server_connect>',$silent);
}

sub server_disconnect {
  my ($self,$silent) = @_;

  return gapil_call('server_disconnect>',$silent);
}


## Logging
sub log_error {
  my ($self,$message,$silent) = @_;

  return gapil_call('log_error>'.$message,$silent);
}

sub log_event {
  my ($self,$message,$silent) = @_;

  return gapil_call('log_event>'.$message,$silent);
}

sub log_normal {
  my ($self,$prefix,$message,$silent) = @_;

  return gapil_call('log_normal>'.$prefix.'>'.$message,$silent);
}

sub log_debug{
  my ($self,$message,$silent) = @_;

  return gapil_call('log_debug>'.$message,$silent);
}


## Dictionary manipulation
sub dictionary_exists {
  my ($self,$dict,$silent) = @_;

  return gapil_call('dictionary_exists>'.$dict,$silent);
}

sub dictionary_list {
  my ($self,$silent) = @_;

  return gapil_call('dictionary_list>',$silent);
}

sub dictionary_delete {
  my ($self,$dict,$silent) = @_;

  return gapil_call('dictionary_delete>'.$dict,$silent);
}

sub dictionary_load {
  my ($self,$dict,$silent) = @_;

  return gapil_call('dictionary_load>'.$dict,$silent);
}

sub dictionary_save {
  my ($self,$dict,$silent) = @_;

  return gapil_call('dictionary_save>'.$dict,$silent);
}

sub dictionary_count {
  my ($self,$silent) = @_;

  return gapil_call('dictionary_count>',$silent);
}


## Value manipulation
sub value_exists {
  my ($self,$dict,$key,$silent) = @_;

  return gapil_call('value_exists>'.$dict.'>'.$key,$silent);
}

sub value_list {
  my ($self,$dict,$silent) = @_;

  return gapil_call('value_list>'.$dict,$silent);
}

sub value_dump {
  my ($self,$dict,$searchkey,$silent) = @_;

  my @flat = split(/\0/, gapil_call('value_dump>'.$dict.'>'.$searchkey,$silent));
  my %result = ();
  for (my $i = 0; $i < @flat; $i += 2) {
    $result{$flat[$i]} = $flat[$i+1];
  }
  return %result;
}

sub value_get {
  my ($self,$dict,$key,$silent) = @_;

  return gapil_call('value_get>'.$dict.'>'.$key,$silent);
}

sub value_set {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_set>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_delete {
  my ($self,$dict,$key,$silent) = @_;

  return gapil_call('value_delete>'.$dict.'>'.$key,$silent);
}

sub value_add {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_add>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_replace {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_replace>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_append {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_append>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_prepend {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_prepend>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_increment {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_increment>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_decrement {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_decrement>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_push {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_push>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_pull {
  my ($self,$dict,$key,$value,$silent) = @_;

  return gapil_call('value_pull>'.$dict.'>'.$key.'>'.$value,$silent);
}

sub value_count {
  my ($self,$dict,$silent) = @_;

  return gapil_call('value_count>'.$dict,$silent);
}


## Child manipulation
sub child_exists {
  my ($self,$name,$silent) = @_;

  return gapil_call('child_exists>'.$name,$silent);
}

sub child_list {
  my ($self,$silent) = @_;

  return gapil_call('child_list>',$silent);
}

sub child_add {
  my ($self,$name,$command,$silent) = @_;

  return gapil_call('child_add>'.$name.'>'.$command,$silent);
}

sub child_delete {
  my ($self,$name,$silent) = @_;

  return gapil_call('child_delete>'.$name,$silent);
}

sub child_send {
  my($self,$name,$message,$silent) = @_;

  return gapil_call('child_send>'.$name.'>'.$message,$silent);
}


## Event manipulation
sub event_exists {
  my ($self,$name,$silent) = @_;

  return gapil_call('event_exists>'.$name,$silent);
}

sub event_list {
  my ($self,$silent) = @_;

  return gapil_call('event_list>',$silent);
}

sub event_delete {
  my ($self,$name,$silent) = @_;

  return gapil_call('event_delete>'.$name,$silent);
}

sub event_subscribe {
  my ($self,$name,$message,$silent) = @_;

  return gapil_call('event_subscribe>'.$name.'>'.$message,$silent);
}

sub event_unsubscribe {
  my ($self,$name,$number,$silent) = @_;

  return gapil_call('event_unsubscribe>'.$name.'>'.$number,$silent);
}

sub event_fire {
  my ($self,$name,$silent) = @_;

  return gapil_call('event_fire>'.$name,$silent);
}


## Delay manipulation
sub delay_exists {
  my ($self,$timestamp,$silent) = @_;

  return gapil_call('delay_exists>'.$timestamp,$silent);
}

sub delay_list {
  my ($self,$silent) = @_;

  return gapil_call('delay_list>',$silent);
}

sub delay_delete {
  my ($self,$timestamp,$silent) = @_;

  return gapil_call('delay_delate>'.$timestamp,$silent);
}

sub delay_subscribe {
  my ($self,$timestamp,$message,$silent) = @_;

  return gapil_call('delay_subscribe>'.$timestamp.'>'.$message,$silent);
}

sub delay_unsubscribe {
  my ($self,$timestamp,$number,$silent) = @_;

  return gapil_call('delay_unsubscribe>'.$timestamp.'>'.$number,$silent);
}

sub delay_fire {
  my ($self,$timestamp,$silent) = @_;

  return gapil_call('delay_fire>'.$timestamp,$silent);
}


1;