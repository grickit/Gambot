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

###This file handles logging and read/write operations on filehandles.

use strict;
use warnings;

my %back_buffers;

sub pipe_status {
  no warnings 'unopened';
  my $pipe = shift;
  fcntl($pipe, F_SETFL(), O_NONBLOCK());
  my $bytes_read = sysread($pipe,my $buffer,1,0);
  if (defined $bytes_read) {
    if ($bytes_read == 0) {
      return 'dead';
    }
    else {
      if(defined $back_buffers{$pipe}) { $back_buffers{$pipe} = $buffer . $back_buffers{$pipe}; }
      else { $back_buffers{$pipe} = $buffer; }
      return 'ready';
    }
  }
  else {
    return 'later';
  }
}

sub read_lines {
  my ($pipe, $buffer) = (shift,'');
  fcntl($pipe, F_SETFL(), O_NONBLOCK());

  if($back_buffers{$pipe}) {
    $buffer = $back_buffers{$pipe};
  }

  while(my $bytes_read = sysread($pipe,$buffer,1024,length($buffer))) { 1; }
  my @lines = split(/[\r\n]+/,$buffer);

  if($buffer !~ /[\r\n]+$/) { $back_buffers{$pipe} = pop(@lines); }
  else { delete $back_buffers{$pipe}; }

  return @lines;
}



sub generate_timestamps {
  my ($sec,$min,$hour,$mday,$mon,$year,undef,undef,undef) = localtime(time);
  $mon += 1;
  $year += 1900;
  $hour = sprintf("%02d", $hour);
  $min = sprintf("%02d", $min);
  $sec = sprintf("%02d", $sec);
  my $datestamp = "$year-$mon-$mday";
  my $timestamp = "$hour:$min:$sec";
  return $datestamp, $timestamp;
}

sub log_output {
  my ($prefix, $datestamp, $timestamp, $message) = @_;

  unless (&value_get('core','unlogged')) {
    my $filename = &value_get('config','log_directory') . '/' . &value_get('config','base_nick') . "-$datestamp.txt";
    open my $logfile, '>>' . $filename
      or print 'Unable to open logfile "' . $filename . "\".\n" . "Does that directory structure exist?\n";
    print $logfile "$prefix $timestamp $message\015\012";
    close $logfile;
  }
}

sub stdout_output {
  my ($prefix, $timestamp, $message) = @_;
  print "$prefix $timestamp $message\n";
}


#Always logged and displayed
sub error_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output('BOTERROR',$datestamp,$timestamp,$message);
  stdout_output('BOTERROR',$timestamp,$message);
}

#Always logged and displayed
sub event_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output('BOTEVENT',$datestamp,$timestamp,$message);
  stdout_output('BOTEVENT',$timestamp,$message);
}

#Always logged, but only displayed if --verbose
sub normal_output {
  my ($prefix,$message) = @_;
  my ($datestamp, $timestamp) = &generate_timestamps();
  log_output($prefix,$datestamp,$timestamp,$message);
  if (&value_get('core','verbose')) {
    stdout_output($prefix,$timestamp,$message);
  }
}

#Logged if --debug. Displayed if --verbose and --debug
sub debug_output {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  if (&value_get('core','debug')) {
    log_output('BOTDEBUG',$datestamp,$timestamp,$message);
    if(&value_get('core','verbose')) {
      stdout_output('BOTDEBUG',$timestamp,$message);
    }
  }
}

1;
