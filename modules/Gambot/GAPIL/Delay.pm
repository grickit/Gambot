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

### This file provides an object for storing and managing delayed
### GAPIL calls to be run at a given time.

package Gambot::GAPIL::Delay;
use strict;
use warnings;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

## Constructor
sub new {
  my $class = shift;
  my $self = {};

  $self->{'core'} = shift;
  $self->{'timestamp'} = shift;
  $self->{'core'}->value_set('delays',$self->{'timestamp'},0);

  bless($self,$class);
  return $self;
}

sub subscribe {
  my ($self,$childname,$message) = @_;

  my $number = $self->{'core'}->value_increment('delays',$self->{'timestamp'},1);
  $self->{'core'}->value_set('delayChildren:'.$self->{'timestamp'},$number,$childname);
  $self->{'core'}->value_set('delayMessages:'.$self->{'timestamp'},$number,$message);
  return $number;
}

sub unsubscribe {
  my ($self,$number) = @_;

  my $message = $self->{'core'}->value_get('delayMessages:'.$self->{'timestamp'},$number);
  $self->{'core'}->value_delete('delayChildren:'.$self->{'timestamp'},$number);
  $self->{'core'}->value_delete('delayMessages:'.$self->{'timestamp'},$number);
  return $message;
}

sub fire {
  my ($self) = @_;

  my @subscribers = $self->{'core'}->value_list('delayChildren:'.$self->{'timestamp'});
  foreach my $current_subscriber (@subscribers) {
    my $childname = $self->{'core'}->value_get('delayChildren:'.$self->{'timestamp'},$current_subscriber);
    my $message = $self->{'core'}->value_get('delayMessages:'.$self->{'timestamp'},$current_subscriber);
    $self->{'core'}->{'parser'}->parse_message($childname,$message);
    $self->unsubscribe($current_subscriber);
  }
  return '';
}

1;