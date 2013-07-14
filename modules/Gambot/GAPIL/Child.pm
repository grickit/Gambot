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

### This file provides functions making GAPIL calls to the core.

package Gambot::GAPIL::Child;
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
  my ($call,$returns) = @_;

  print "$call\n";
  if($returns) { return stdin_read(); }
  return 1;
}

1;