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

### This file provides an object capable of parsing GAPIL.

package Gambot::IRC::Freenode::Output;
use strict;
use warnings;

use Gambot::IRC::Freenode::Specifications;
use Gambot::GAPIL::CommandChild;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub new {
  my $class = shift;
  my $self = {};

  $self->{'core'} = shift;

  bless($self,$class);
  return $self;
}

sub parse {
  my ($self,$string) = @_;

  $string = strip_newlines($string);

  if($string =~ /^MESSAGE>$validChan>(.+)$/) {
    $self->{'core'}->server_send("PRIVMSG $1 :$2");
  }

  elsif($string =~ /^ACTION>$validChan>(.+)$/) {
    $self->{'core'}->server_send("PRIVMSG $1 :ACTION $2");
  }

  elsif($string =~ /^NOTICE>$validChan>(.+)$/) {
    $self->{'core'}->server_send("NOTICE $1 :ACTION $2");
  }

  elsif($string =~ /^JOIN>$validChan$/) {
    $self->{'core'}->server_send("JOIN $1");
  }

  elsif($string =~ /^PART>$validChan>?(.+)?$/) {
    $self->{'core'}->server_send("PART $1 :$2");
  }

  elsif($string =~ /^KICK>$validChan>$validNick>?(.+)?$/) {
    $self->{'core'}->server_send("KICK $1 $2 :$3");
  }

  elsif($string =~ /^INVITE>$validChan>$validNick$/) {
    $self->{'core'}->server_send("INVITE $1 $2");
  }

  elsif($string =~ /^KICK>$validChan>?(.+)?$/) {
    $self->{'core'}->server_send("MODE $1 $2");
  }

  elsif($string =~ /^LITERAL>(.+)$/) {
    gapil_call($1);
  }

  else {
    $self->{'core'}->log_error('Outgoing message did not match GAPIL parser.');
    $self->{'core'}->log_error($string);
    return '';
  }

  return 1;
}

1;