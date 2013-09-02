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

### This file provides an object for storing and managing child
### processes.

package Gambot::GAPIL::Child;
use strict;
use warnings;
use IPC::Open2;

use Gambot::IO;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

## Constructor
sub new {
  my $class = shift;
  my $self = {};

  $self->{'name'} = shift;
  $self->{'command'} = shift;
  $self->{'pid'} = open2($self->{'read_pipe'},$self->{'write_pipe'},$self->{'command'});
  $self->{'status'} = 'later';

  bless($self,$class);
  return $self;
}

sub status {
  my($self) = @_;

  $self->{'status'} = pipe_status($self->{'name'},$self->{'read_pipe'});
  return $self->{'status'};
}

sub kill {
  my($self) = @_;

  close $self->{'read_pipe'};
  close $self->{'write_pipe'};
  kill 1, $self->{'pid'};
  return 1;
}

sub read {
  my ($self) = @_;

  my @received_messages = ();
  $self->status();

  if($self->{'status'} eq 'ready') {
    @received_messages = pipe_multiread($self->{'name'},$self->{'read_pipe'});
  }

  return @received_messages;
}

sub send {
  my ($self,$message) = @_;

  my $write_pipe = $self->{'write_pipe'};
  print $write_pipe $message."\n";
}

1;