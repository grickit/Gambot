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
    if ($1 =~ /^NICK (.+)$/) { set_core_value('nick',$1); }
  }
  elsif ($command =~ /^send_pipe_message>($validkey)>(.+)$/) {
    send_pipe_message($1,$2);
  }



  elsif ($command =~ /^get_core_value>($validkey)$/) {
    if (my $value = &get_core_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }
  elsif ($command =~ /^get_config_value>($validkey)$/) {
    if (my $value = &get_config_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }
  elsif ($command =~ /^get_variable_value>($validkey)$/) {
    if (my $value = &get_variable_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }



  elsif ($command =~ /^set_core_value>($validkey)>(.+)$/) {
    &set_core_value($1,$2);
  }
  elsif ($command =~ /^set_config_value>($validkey)>(.+)$/) {
    &set_config_value($1,$2);
  }
  elsif ($command =~ /^set_variable_value>($validkey)>(.+)$/) {
    &set_variable_value($1,$2);
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

  elsif ($command =~ /^get_persistent_value>($validkey)>($validkey)$/) {
    if (my $value = &get_persistent_value($1,$2)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
  }
  elsif ($command =~ /^set_persistent_value>($validkey)>($validkey)>(.+)$/) {
    &set_persistent_value($1,$2,$3);
  }
  elsif ($command =~ /^del_persistent_value>($validkey)>($validkey)$/) {
    &del_persistent_value($1,$2);
  }
  elsif ($command =~ /^read_persistence_file>($validkey)$/) {
    &read_persistence_file($1);
  }
  elsif ($command =~ /^save_persistence_file>($validkey)$/) {
    &save_persistence_file($1);
  }
  elsif ($command =~ /^save_all_persistence_files>$/) {
    &save_all_persistence_files();
  }
  elsif ($command =~ /^check_persistence_domain_exists>($validkey)$/) {
    if (&check_persistence_domain_exists($1)) {
      &send_pipe_message($pipeid,"1");
    }
    else {
      &send_pipe_message($pipeid,"");
    }
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
