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

### This file provides functions for logging.

package Gambot::Logging;
use strict;
use warnings;

use Gambot::GAPILCore;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  error_log
  event_log
  normal_log
  debug_log
);
our @EXPORT_OK = qw(
  generate_timestamps
  file_log
  stdout_log
);

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

sub file_log {
  my ($prefix, $datestamp, $timestamp, $message) = @_;

  my $unlogged = &Gambot::GAPILCore::value_get('core','unlogged');
  my $log_directory = &Gambot::GAPILCore::value_get('config','log_directory');
  my $base_nick = &Gambot::GAPILCore::value_get('config','base_nick');

  unless ($unlogged) {
    my $filename = "$log_directory/$base_nick-$datestamp.txt";
    open my $logfile,">>$filename"
      or print "Unable to open logfile \"$filename\"\nDoes that directory structure exist?\n";
    print $logfile "$prefix $timestamp $message\015\012";
    close $logfile;
  }
}

sub stdout_log {
  my ($prefix, $timestamp, $message) = @_;
  print "$prefix $timestamp $message\n";
}


#Always logged and displayed
sub error_log {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  file_log('BOTERROR',$datestamp,$timestamp,$message);
  stdout_log('BOTERROR',$timestamp,$message);
}

#Always logged and displayed
sub event_log {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  file_log('BOTEVENT',$datestamp,$timestamp,$message);
  stdout_log('BOTEVENT',$timestamp,$message);
}

#Always logged, but only displayed if --verbose
sub normal_log {
  my ($prefix,$message) = @_;
  my ($datestamp, $timestamp) = &generate_timestamps();
  my $verbose = &Gambot::GAPILCore::value_get('core','verbose');

  file_log($prefix,$datestamp,$timestamp,$message);
  if ($verbose) {
    stdout_log($prefix,$timestamp,$message);
  }
}

#Logged if --debug. Displayed if --verbose and --debug
sub debug_log {
  my $message = shift;
  my ($datestamp, $timestamp) = &generate_timestamps();
  my $verbose = &Gambot::GAPILCore::value_get('core','verbose');
  my $debug = &Gambot::GAPILCore::value_get('core','debug');

  if ($debug) {
    file_log('BOTDEBUG',$datestamp,$timestamp,$message);
    if($verbose) {
      stdout_log('BOTDEBUG',$timestamp,$message);
    }
  }
}

1;
