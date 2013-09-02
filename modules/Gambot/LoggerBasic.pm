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

### This file provides functions for logging to STDOUT and files
### in a consistent manner.

package Gambot::LoggerBasic;
use strict;
use warnings;
use FindBin;

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

sub generate_timestamps {
  my ($self) = @_;

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

sub output_file {
  my ($self,$prefix,$message) = @_;
  my($datestamp,$timestamp) = $self->generate_timestamps();

  if($self->{'core'}->value_get('core','setup_complete') && !$self->{'core'}->value_get('core','unlogged')) {
    my $log_directory = $self->{'core'}->value_get('config','log_directory');
    $log_directory ||= $self->{'core'}->value_get('core','home_directory');
    $log_directory ||= $FindBin::Bin;

    my $filename = $log_directory.'/'.$self->{'core'}->value_get('config','base_nick').'-'.$datestamp.'.txt';

    open(my $file,">>$filename") or die "Unable to open logfile \"$filename\".\n";
    if($file) {
      print $file "[$prefix] [$timestamp] $message\015\012";
      close($file);
      return 1;
    }
  }
  return '';
}

sub output_stdout {
  my ($self,$prefix,$message) = @_;
  my ($datestamp,$timestamp) = $self->generate_timestamps();

  print "[$prefix] [$timestamp] $message\n";
  return 1;
}

#Always logged and displayed
sub log_error {
  my ($self,$message) = @_;

  $self->output_file('BOTERROR',$message);
  $self->output_stdout('BOTERROR',$message);
  return 1;
}

#Always logged and displayed
sub log_event {
  my ($self,$message) = @_;

  $self->output_file('BOTEVENT',$message);
  $self->output_stdout('BOTEVENT',$message);
  return 1;
}

#Always logged, but only displayed if --verbose
sub log_normal {
  my ($self,$prefix,$message) = @_;

  $self->output_file($prefix,$message);
  if($self->{'core'}->value_get('core','verbose')) {
    $self->output_stdout($prefix,$message);
  }
  return 1;
}

#Logged if --debug. Displayed if --verbose and --debug
sub log_debug {
  my ($self,$message) = @_;

  if ($self->{'core'}->value_get('core','debug')) {
    $self->output_file('BOTDEBUG',$message);
    if($self->{'core'}->value_get('core','verbose')) {
      $self->output_stdout('BOTDEBUG',$message);
    }
  }
  return 1;
}

1;