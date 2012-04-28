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

###This file handles parsing of the Gambot API Language

use strict;
use warnings;

sub parse_command {
  my ($command, $pipeid) = @_;
  $command =~ s/[\r\n]+$//;
  debug_output("Received API call: $command");

  my $validkey = '[a-zA-Z0-9_#-]+';


  if ($command =~ /^send_server_message>(.+)$/) {
    send_server_message($1);
    if ($1 =~ /^NICK (.+)$/) { value_set('core','nick',$1); }
  }
  elsif ($command =~ /^send_pipe_message>($validkey)>(.+)$/) {
    send_pipe_message($1,$2);
  }

  elsif($command =~ /^dict_exists>($validkey)$/) {
    send_pipe_message($pipeid,dict_exists($1));
  }
  elsif($command =~ /^dict_save>($validkey)$/) {
    dict_save($1);
  }
  elsif($command =~ /^dict_load>($validkey)$/) {
    dict_load($1);
  }
  elsif($command =~ /^value_get>($validkey)>($validkey)$/) {
    send_pipe_message($pipeid,value_get($1,$2));
  }
  elsif($command =~ /^(return )?value_add>($validkey)>($validkey)>(.+)$/) {
    my $result = value_add($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_replace>($validkey)>($validkey)>(.+)$/) {
    my $result = value_replace($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_set>($validkey)>($validkey)>(.+)$/) {
    my $result = value_set($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_append>($validkey)>($validkey)>(.+)$/) {
    my $result = value_append($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_prepend>($validkey)>($validkey)>(.+)$/) {
    my $result = value_prepend($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_increment>($validkey)>($validkey)>(.+)$/) {
    my $result = value_increment($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_decrement>($validkey)>($validkey)>(.+)$/) {
    my $result = value_decrement($2,$3,$4);
    send_pipe_message($pipeid,$result) if($1);
  }
  elsif($command =~ /^(return )?value_delete>($validkey)>($validkey)$/) {
    my $result = value_delete($2,$3);
    send_pipe_message($pipeid,$result) if($1);
  }

  elsif ($command =~ /^check_pipe_exists>($validkey)$/) {
    if (&check_pipe_exists($1)) {
      &send_pipe_message($pipeid,"1");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }
  elsif ($command =~ /^kill_pipe>($validkey)$/) {
    &kill_pipe($1);
  }
  elsif ($command =~ /^run_command>($validkey)>(.+)$/) {
    &run_command($1,$2);
  }

  elsif ($command =~ /^sleep>([0-9.]+)$/) {
    select(undef,undef,undef,$1);
  }
  elsif ($command =~ /^shutdown>$/) {
    &event_output("API call from $pipeid asked for a shutdown.");
    exit;
  }
  elsif ($command =~ /^reconnect>$/) {
    &event_output("API call from $pipeid asked for a reconnection.");
    &reconnect();
  }
  elsif ($command =~ /^reload_config>$/) {
    event_output("API call from $pipeid asked for a configuration reload.");
    &read_configuration_file(&get_core_value('home_directory') . '/configurations/' . &get_core_value('configuration_file'));
  }
  elsif ($command =~ /^log>($validkey)>(.+)$/) {
    &normal_output($1,$2);
  }

  elsif ($command =~ /^event_lock>($validkey)$/) {
    event_lock($pipeid,$1);
  }
  elsif ($command =~ /^event_unlock>($validkey)$/) {
    event_unlock($1);
  }
  elsif ($command =~ /^check_event_lock_exists>($validkey)$/) {
    if (&check_event_lock_exists($1)) {
      &send_pipe_message($pipeid,"1");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }

  else {
    &error_output("Unknown API call: $command");
  }
}

1;
