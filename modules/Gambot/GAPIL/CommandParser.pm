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

package Gambot::GAPIL::CommandParser;
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

sub parse_message {
  my ($self,$childname,$message) = @_;
  my $validKey = '(['.$self->{'core'}->value_get('config','key_characters').']+)';
  my $result = '';
  my $return = '';

  if($message =~ /^return /) {
    $return = 1;
    $message =~ s/^return //;
  }


## Server manipulation
  if ($message =~ /^server_send>(.+)$/) {
    $self->{'core'}->server_send($1);
    if ($1 =~ /^NICK (.+)$/) { $self->{'core'}->value_set('core','nick',$1); }
  }


## Logging
  elsif($message =~ /^log_error>(.+)$/) {
    $result = $self->{'core'}->log_error($1);
  }

  elsif($message =~ /^log_event>(.+)$/) {
    $result = $self->{'core'}->log_event($1);
  }

  elsif($message =~ /^log_normal>$validKey>(.+)$/) {
    $result = $self->{'core'}->log_normal($1,$2);
  }

  elsif($message =~ /^log_debug>(.+)$/) {
    $result = $self->{'core'}->log_debug($1);
  }


## Dictionary manipulation
  elsif($message =~ /^dictionary_exists>$validKey$/) {
    $result = $self->{'core'}->dictionary_exists($1);
  }

  elsif($message =~ /^dictionary_list>$/) {
    my @list = $self->{'core'}->dictionary_list();
    $result = join(',',@list);
  }

  elsif($message =~ /^dictionary_delete>$validKey$/) {
    $result = $self->{'core'}->dictionary_delete($1);
  }

  elsif($message =~ /^dictionary_load>$validKey$/) {
    $result = $self->{'core'}->dictionary_load($1);
  }

  elsif($message =~ /^dictionary_save>$validKey$/) {
    $result = $self->{'core'}->dictionary_save($1);
  }


## Value manipulation
  elsif($message =~ /^value_exists>$validKey>$validKey$/) {
    $result = $self->{'core'}->value_exists($1,$2);
  }

  elsif($message =~ /^value_list>$validKey$/) {
    my @list = $self->{'core'}->value_list($1);
    $result = join(',',@list);
  }

  elsif($message =~ /^value_get>$validKey>$validKey$/) {
    $result = $self->{'core'}->value_get($1,$2);
  }

  elsif($message =~ /^value_set>$validKey>$validKey>(.+)$/) {
    $result = $self->{'core'}->value_set($1,$2,$3);
  }

  elsif($message =~ /^value_delete>$validKey>$validKey$/) {
    $result = $self->{'core'}->value_delete($1,$2);
  }

  elsif($message =~ /^value_add>$validKey>$validKey>(.+)$/) {
    $result = $self->{'core'}->value_add($1,$2,$3);
  }

  elsif($message =~ /^value_replace>$validKey>$validKey>(.+)$/) {
    $result = $self->{'core'}->value_replace($1,$2,$3);
  }

  elsif($message =~ /^value_append>$validKey>$validKey>(.+)$/) {
    $result = $self->{'core'}->value_append($1,$2,$3);
  }

  elsif($message =~ /^value_prepend>$validKey>$validKey>(.+)$/) {
    $result = $self->{'core'}->value_prepend($1,$2,$3);
  }

  elsif($message =~ /^value_increment>$validKey>$validKey>([0-9]+)$/) {
    $result = $self->{'core'}->value_increment($1,$2,$3);
  }

  elsif($message =~ /^value_decrement>$validKey>$validKey>([0-9]+)$/) {
    $result = $self->{'core'}->value_decrement($1,$2,$3);
  }

  elsif($message =~ /^value_push>$validKey>$validKey>$validKey$/) {
    $result = $self->{'core'}->value_push($1,$2,$3);
  }

  elsif($message =~ /^value_pull>$validKey>$validKey>$validKey$/) {
    $result = $self->{'core'}->value_pull($1,$2,$3);
  }


## Child manipulation
  elsif($message =~ /^child_exists>$validKey$/) {
    $result = $self->{'core'}->child_exists($1);
  }

  elsif($message =~ /^child_list>$/) {
    $result = $self->{'core'}->child_list();
  }

  elsif($message =~ /^child_delete>$validKey$/) {
    $result = $self->{'core'}->child_delete($1);
  }

  elsif($message =~ /^child_add>$validKey>(.+)$/) {
    $result = $self->{'core'}->child_add($1,$2);
  }

  elsif($message =~ /^child_send>$validKey>(.+)$/) {
    $result = $self->{'core'}->child_send($1,$2);
  }


## Event manipulation
  elsif($message =~ /^event_exists>$validKey/) {
    $result = $self->{'core'}->event_exists($1);
  }

  elsif($message =~ /^event_list>$/) {
    my @list = $self->{'core'}->event_list();
    $result = join(',',@list);
  }

  elsif($message =~ /^event_delete>$validKey$/) {
    $result = $self->{'core'}->event_delete($1);
  }

  elsif($message =~ /^event_subscribe>$validKey>(.+)$/) {
    $result = $self->{'core'}->event_subscribe($1,$childname,$2);
  }

  elsif($message =~ /^event_unsubscribe>$validKey>([0-9]+)$/) {
    $result = $self->{'core'}->event_unsubscribe($1,$2);
  }

  elsif($message =~ /^event_fire>$validKey$/) {
    $result = $self->{'core'}->event_fire($1);
  }


## Delay manipulation
  elsif($message =~ /^delay_exists>([0-9]+)/) {
    $result = $self->{'core'}->delay_exists($1);
  }

  elsif($message =~ /^delay_list>$/) {
    my @list = $self->{'core'}->delay_list();
    $result = join(',',@list);
  }

  elsif($message =~ /^delay_delete>([0-9]+)$/) {
    $result = $self->{'core'}->delay_delete($1);
  }

  elsif($message =~ /^delay_subscribe>([0-9]+)>(.+)$/) {
    $result = $self->{'core'}->delay_subscribe($1,$childname,$2);
  }

  elsif($message =~ /^delay_unsubscribe>([0-9]+)>([0-9]+)$/) {
    $result = $self->{'core'}->delay_unsubscribe($1,$2);
  }

  elsif($message =~ /^delay_fire>([0-9]+)/) {
    $result = $self->{'core'}->delay_fire($1);
  }


## Unknown
  else {
    $self->{'core'}->log_error('Unrecognized GAPIL call: '.$message);
  }

  if($return) {
    $self->{'core'}->child_send($childname,$result);
  }

  return $result;
}


1;