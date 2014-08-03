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

### This file provides an specifications for Freenode syntax.

package IRC::Freenode::Specifications;
use strict;
use warnings;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  $charactersNick
  $charactersUser
  $charactersHost
  $charactersChan
  $charactersServer
  $validNick
  $validUser
  $validHost
  $validChan
  $validSenderHuman
  $validSenderServer
);
our @EXPORT_OK = qw();

our $charactersNick = 'A-Za-z0-9[\]\\`_^{}|-';
our $charactersUser = 'A-Za-z0-9[\]\\`_^{}|.-';
our $charactersHost = ':./A-Za-z0-9[\]\\`_^{}|-';
our $charactersChan = '#A-Za-z0-9[\]\\`_^{}|-';
our $charactersServer = 'a-zA-Z0-9\.';
our $validNick = '(['.$charactersNick.']+)';
our $validUser = '(['.$charactersUser.']+)';
our $validHost = '(['.$charactersHost.']+)';
our $validChan = '(['.$charactersChan.']+|\*)';
our $validSenderHuman = $validNick.'!~?'.$validUser.'@'.$validHost;
our $validSenderServer = '(['.$charactersServer.']+)';

1;