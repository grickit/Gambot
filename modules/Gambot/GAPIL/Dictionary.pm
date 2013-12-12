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

### This file provides an object for storing and managing variables
### and provides a consistent interface for various other core bot
### systems to interact with them.

package Gambot::GAPIL::Dictionary;
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
  $self->{'name'} = shift;
  $self->{'values'} = {};

  bless($self,$class);
  return $self;
}

sub load {
  my ($self,$filename) = @_;

  $self->{'core'}->log_debug('Loading '.$filename);
  if (-e $filename) {
    open(my $file,$filename);
    my @lines = <$file>;

    foreach my $current_line (@lines) {
      $current_line =~ s/[\r\n\s]+$//;
      $current_line =~ s/^[\t\s]+//;
      if($current_line =~ /^([a-zA-Z0-9_#:-]+) = "(.+)"$/) {
        $self->{'core'}->log_debug($1.' = '.$2);
        $self->value_set($1,$2);
      }
    }
    close($file);
  }
}

sub save {
  my ($self,$filename) = @_;

  $self->{'core'}->log_debug('Saving '.$filename);
  open(my $file,'>'.$filename);
  foreach my $key ($self->value_list()) {
    my $value = $self->value_get($key);
    $self->{'core'}->log_debug($key.' = '.$value);
    print $file $key.' = "'.$value.'"'."\n";
  }
  close($file);
}

## Value manipulation
sub value_exists {
  my ($self,$key) = @_;

  if(exists $self->{'values'}{$key}) {
    return 1;
  }
  return '';
}

sub value_list {
  my ($self) = @_;

  my @list;
  foreach my $key (keys $self->{'values'}) {
    push(@list,$key);
  }
  return @list;
}

sub value_get {
  my ($self,$key) = @_;

  if($self->value_exists($key)) {
    return $self->{'values'}{$key};
  }
  return '';
}

sub value_set {
  my ($self,$key,$value) = @_;

  $self->{'values'}{$key} = $value;
  return $self->value_get($key);
}

sub value_delete {
  my ($self,$key) = @_;

  if($self->value_exists($key)) {
    my $value = $self->value_get($key);
    $self->{'values'}{$key} = undef;
    delete $self->{'values'}{$key};
    return $value;
  }
  return '';
}

sub value_add {
  my ($self,$key,$value) = @_;

  if(!$self->value_exists($key)) {
    $self->value_set($key,$value);
    return $self->value_get($key);
  }
  return '';
}

sub value_replace {
  my ($self,$key,$value) = @_;

  if($self->value_exists($key)) {
    $self->value_set($key,$value);
    return $self->value_get($key);
  }
  return '';
}

sub value_append {
  my ($self,$key,$value) = @_;

  if(!$self->value_exists($key)) {
    $self->value_set($key,'');
  }

  $self->value_set($key,$self->value_get($key).$value);
  return $self->value_get($key);
}

sub value_prepend {
  my ($self,$key,$value) = @_;

  if(!$self->value_exists($key)) {
    $self->value_set($key,'');
  }

  $self->value_set($key,$value.$self->value_get($key));
  return $self->value_get($key);
}

sub value_increment {
  my ($self,$key,$value) = @_;
  if(!$value || $value !~ /^-?[0-9]+$/) { $value = 1; }

  if(!$self->value_exists($key) || $self->value_get($key) !~ /^-?[0-9]+$/) {
    $self->value_set($key,0);
  }

  $self->value_set($key,($self->value_get($key)+$value));
  return $self->value_get($key);
}

sub value_decrement {
  my ($self,$key,$value) = @_;
  if(!$value || $value !~ /^-?[0-9]+$/) { $value = 1; }

  if(!$self->value_exists($key) || $self->value_get($key) !~ /^-?[0-9]+$/) {
    $self->value_set($key,0);
  }

  $self->value_set($key,($self->value_get($key)-$value));
  return $self->value_get($key);
}

1;