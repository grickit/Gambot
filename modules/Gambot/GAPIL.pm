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


  if ($command =~ /^send_server_message>(.+)$/) {
    send_server_message($1);
    if ($1 =~ /^NICK (.+)$/) { set_core_value('nick',$1); }
  }
  elsif ($command =~ /^send_pipe_message>([a-zA-Z0-9_#-]+)>(.+)$/) {
    send_pipe_message($1,$2);
  }



  elsif ($command =~ /^get_core_value>([a-zA-Z0-9_#-]+)$/) {
    if (my $value = &get_core_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }
  elsif ($command =~ /^get_config_value>([a-zA-Z0-9_#-]+)$/) {
    if (my $value = &get_config_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }
  elsif ($command =~ /^get_variable_value>([a-zA-Z0-9_#-]+)$/) {
    if (my $value = &get_variable_value($1)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }



  elsif ($command =~ /^set_core_value>([a-zA-Z0-9_#-]+)>(.+)$/) {
    &set_core_value($1,$2);
  }
  elsif ($command =~ /^set_config_value>([a-zA-Z0-9_#-]+)>(.+)$/) {
    &set_config_value($1,$2);
  }
  elsif ($command =~ /^set_variable_value>([a-zA-Z0-9_#-]+)>(.+)$/) {
    &set_variable_value($1,$2);
  }



  elsif ($command =~ /^check_pipe_exists>([a-zA-Z0-9_#-]+)$/) {
    if (&check_pipe_exists($1)) {
      &send_pipe_message($pipeid,"1");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }
  elsif ($command =~ /^kill_pipe>([a-zA-Z0-9_#-]+)$/) {
    &kill_pipe($1);
  }
  elsif ($command =~ /^run_command>([a-zA-Z0-9_#-]+)>(.+)$/) {
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
  elsif ($command =~ /^log>([a-zA-Z0-9_#-]+)>(.+)$/) {
    &normal_output($1,$2);
  }

  elsif ($command =~ /^get_persistent_value>([a-zA-Z0-9_#-]+)>([a-zA-Z0-9_#-]+)$/) {
    if (my $value = &get_persistent_value($1,$2)) {
      &send_pipe_message($pipeid,"$value");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }
  elsif ($command =~ /^set_persistent_value>([a-zA-Z0-9_#-]+)>([a-zA-Z0-9_#-]+)>(.+)$/) {
    &set_persistent_value($1,$2,$3);
  }
  elsif ($command =~ /^del_persistent_value>([a-zA-Z0-9_#-]+)>([a-zA-Z0-9_#-]+)$/) {
    &del_persistent_value($1,$2);
  }
  elsif ($command =~ /^read_persistence_file>([a-zA-Z0-9_#-]+)$/) {
    &read_persistence_file($1);
  }
  elsif ($command =~ /^load_persistence_file>([a-zA-Z0-9_#-]+)$/) {
    &read_persistence_file($1);
  }
  elsif ($command =~ /^save_persistence_file>([a-zA-Z0-9_#-]+)$/) {
    &save_persistence_file($1);
  }
  elsif ($command =~ /^save_all_persistence_files>$/) {
    &save_all_persistence_files();
  }
  elsif ($command =~ /^check_persistence_domain_exists>([a-zA-Z0-9_#-]+)$/) {
    if (&check_persistence_domain_exists($1)) {
      &send_pipe_message($pipeid,"1");
    }
    else {
      &send_pipe_message($pipeid,"0");
    }
  }


  else {
    &error_output("Unknown API call: $command");
  }
}

1;
