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

###This file reads configuration files into variables.

use strict;
use warnings;

sub read_configuration {
  my $configuration_file = shift;
  if (-e $configuration_file) {
    open (CONFIGR, $configuration_file);
    my @config_lines = <CONFIGR>;

    foreach my $current_line (@config_lines) {
      chop $current_line;
      line_check('configuration_version', $current_line);
      line_check('server', $current_line);
      line_check('port', $current_line);
      line_check('base_nick', $current_line);
      line_check('password', $current_line);
      line_check('log_directory', $current_line);
      line_check('processor_file_name', $current_line);
      line_check('number_of_processors', $current_line);
      line_check('enable_terminal', $current_line);
      line_check('enable_timer', $current_line);
      line_check('timer_regex', $current_line);
      line_check('timer_file_name', $current_line);
    }

    unless (get_config_value('configuration_version') == 6) {
      print "Wrong configuation version in \"$configuration_file\". Run setup.pl\n";
      print $main::core{'home_directory'} . "\n";
      exit;
    }
  }
  else {
    print "Config file \"$configuration_file\" does not exist. Run setup.pl\n";
    exit;
  }
}

sub line_check {
  my ($value, $line) = @_;
  if ($line =~ /^\s*$value *= *(.+)$/) {
    set_config_value($value, $1);
  }
}

1;