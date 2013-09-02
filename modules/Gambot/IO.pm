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

### This provides functions for handling read/write operations
### on filehandles.

package Gambot::IO;
use strict;
use warnings;
use Fcntl qw(F_SETFL O_NONBLOCK);

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  pipe_status
  pipe_multiread
);
our @EXPORT_OK = qw();

my %back_buffers;

sub pipe_status {
  no warnings 'unopened';
  my($name,$pipe) = @_;
  my $buffer = '';
  fcntl($pipe, F_SETFL(), O_NONBLOCK()); # Set the pipe to nonblocking

  my $bytes_read = sysread($pipe,$buffer,1,0); # Attempt to read 1 byte from the pipe

  if(defined $bytes_read) {
    if($bytes_read == 0) { # Successfully read empty byte; pipe is dead
      return 'dead';
    }
    else { # Successfully read non-empty byte; pipe has data
      if($back_buffers{$name}) { $back_buffers{$name} .= $buffer; }
      else { $back_buffers{$name} = $buffer; }
      return 'ready';
    }
  }

  # Failed to read any bytes; pipe is empty
  return 'later';
}

sub pipe_multiread {
  my ($name,$pipe) = @_;
  my $buffer = '';
  fcntl($pipe,F_SETFL(),O_NONBLOCK()); # Set the pipe to nonblocking

  if($back_buffers{$name}) { # We already have some data stored
    $buffer = $back_buffers{$name};
  }

  while(my $bytes_read = sysread($pipe,$buffer,1024,length($buffer))) { 1; } # Read as much data as we can

  my @lines = split(/[\r\n]+/,$buffer); # Split the data we read into lines

  if($buffer =~ /[\r\n]+$/) { # Clear the buffer if it ends on a complete line
    $back_buffers{$name} = undef;
    delete $back_buffers{$name};
  }
  else { # Stick and incomplete line back into the buffer
    $back_buffers{$name} = pop(@lines);
  }

  return @lines;
}

1;
