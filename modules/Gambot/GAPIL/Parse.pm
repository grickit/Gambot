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

### This file handles parsing of the Gambot API Language from children.

package Gambot::GAPIL::Parse;
use strict;
use warnings;

use Gambot::GAPIL::Core;
use Gambot::Logging;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  parse_command
);
our @EXPORT_OK = qw();

sub parse_command {
  my ($command, $childid) = @_;
  $command =~ s/[\r\n]+$//;
  debug_log("Received API call: $command");

  my $validkey = '[a-zA-Z0-9_#:-]+';

  if ($command =~ /^server_send>(.+)$/) {
    server_send($1);
    if ($1 =~ /^NICK (.+)$/) { value_set('core','nick',$1); }
  }

  elsif ($command =~ /^server_reconnect>$/) {
    &event_log("API call from $childid asked for a reconnection.");
    &server_reconnect();
  }

  elsif($command =~ /^dict_exists>($validkey)$/) {
    child_send($childid,dict_exists($1));
  }

  elsif($command =~ /^dict_save>($validkey)$/) {
    dict_save($1);
  }

  elsif($command =~ /^dict_load>($validkey)$/) {
    dict_load($1);
  }

  elsif($command =~ /^dict_save_all>$/) {
    dict_save_all();
  }

  elsif($command =~ /^dict_delete>($validkey)$/) {
    dict_delete($1);
  }

  elsif($command =~ /^value_exists>($validkey)>($validkey)$/) {
    child_send($childid,value_get($1,$2));
  }

  elsif($command =~ /^value_get>($validkey)>($validkey)$/) {
    child_send($childid,value_get($1,$2));
  }

  elsif($command =~ /^(return )?value_add>($validkey)>($validkey)>(.+)$/) {
    my $result = value_add($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_replace>($validkey)>($validkey)>(.+)$/) {
    my $result = value_replace($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_set>($validkey)>($validkey)>(.+)$/) {
    my $result = value_set($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_append>($validkey)>($validkey)>(.+)$/) {
    my $result = value_append($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_prepend>($validkey)>($validkey)>(.+)$/) {
    my $result = value_prepend($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_increment>($validkey)>($validkey)>(.+)$/) {
    my $result = value_increment($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_decrement>($validkey)>($validkey)>(.+)$/) {
    my $result = value_decrement($2,$3,$4);
    child_send($childid,$result) if($1);
  }

  elsif($command =~ /^(return )?value_delete>($validkey)>($validkey)$/) {
    my $result = value_delete($2,$3);
    child_send($childid,$result) if($1);
  }

  elsif ($command =~ /^child_send>($validkey)>(.+)$/) {
    child_send($1,$2);
  }

  elsif ($command =~ /^child_delete>($validkey)$/) {
    &child_delete($1);
  }

  elsif ($command =~ /^child_exists>($validkey)$/) {
    &child_send($childid,&child_exists($1));
  }

  elsif ($command =~ /^child_add>($validkey)>(.+)$/) {
    &child_add($1,$2);
  }

  elsif ($command =~ /^sleep>([0-9.]+)$/) {
    select(undef,undef,undef,$1);
  }

  elsif ($command =~ /^shutdown>$/) {
    &event_log("API call from $childid asked for a shutdown.");
    exit;
  }

  elsif ($command =~ /^reload_config>$/) {
    event_log("API call from $childid asked for a configuration reload.");
    &read_configuration_file(&value_get('core','home_directory') . '/configurations/' . &value_get('core','configuration_file'));
  }

  elsif ($command =~ /^log>($validkey)>(.+)$/) {
    &normal_log($1,$2);
  }

  elsif ($command =~ /^event_schedule>($validkey)>(.+)$/) {
    event_schedule($1,$2);
  }

  elsif ($command =~ /^event_fire>($validkey)$/) {
    event_fire($1);
  }

  elsif ($command =~ /^event_exists>($validkey)$/) {
    child_send($childid,event_exists($1));
  }

  elsif ($command =~ /^delay_schedule>([0-9]+)>(.+)$/) {
    delay_schedule($1,$2);
  }

  elsif ($command =~ /^delay_fire>([0-9]+)$/) {
    delay_fire($1);
  }

  else {
    &error_log("Unknown API call: $command");
  }
}

1;
