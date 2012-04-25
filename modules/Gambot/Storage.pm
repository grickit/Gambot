#!/usr/bin/perl
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

###This file handles abstracted manipulation of values stored in the core

use strict;
use warnings;

sub value_exists {
  my ($hash,$key) = @_;
  return exists ${$hash}{$key};
}

sub value_get {
  my ($hash,$key) = @_;
  if(value_exists($hash,$key)) { return ${$hash}{$key}; }
  else { return ''; }
}

sub value_add {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key)) { return ''; }
  else { ${$hash}{$key} = $value; return ${$hash}{$key}; }
}

sub value_replace {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key)) { ${$hash}{$key} = $value; return ${$hash}{$key}; }
  else { return ''; }
}

sub value_set {
  my ($hash,$key,$value) = @_;
  ${$hash}{$key} = $value; return ${$hash}{$key};
}

sub value_append {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key)) { ${$hash}{$key} .= $value; return ${$hash}{$key}; }
  else { return ''; }
}

sub value_prepend {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key)) { ${$hash}{$key} = $value . ${$hash}{$key}; return ${$hash}{$key}; }
  else { return ''; }
}

sub value_increment {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key) && $value =~ /^[0-9]+$/) {
    if(${$hash}{$key} =~ /^[0-9]+$/ && ${$hash}{$key} >= $value) { ${$hash}{$key} += $value; }
    else { ${$hash}{$key} = 0; }
    return ${$hash}{$key};
  }
  else { return ''; }
}

sub value_decrement {
  my ($hash,$key,$value) = @_;
  if(value_exists($hash,$key) && $value =~ /^[0-9]+$/) {
    if(${$hash}{$key} =~ /^[0-9]+$/ && ${$hash}{$key} >= $value) { ${$hash}{$key} -= $value; }
    else { ${$hash}{$key} = 0; }
    return ${$hash}{$key};
  }
  else { return ''; }
}

sub value_delete {
  my ($hash,$key) = @_;
  if(value_exists($hash,$key)) { my $value = ${$hash}{$key}; delete ${$hash}{$key}; return $value; }
  else { return ''; }
}

1;