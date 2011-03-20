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

use strict;
use warnings;

sub read_configuration {
  if (-e $main::config_file) {
    open (CONFIGR, "$main::config_file");
    my @config_lines = <CONFIGR>;

    foreach my $current_line (@config_lines) {
      chop $current_line;
      if ($current_line =~ /^\s*config_version *= *([0-9]+)/) { $main::config_vers = $1 }
      elsif ($current_line =~ /^\s*server *= *(.+)/) { $main::server = $1 }
      elsif ($current_line =~ /^\s*port *= *([0-9]+)/) { $main::port = $1 }
      elsif ($current_line =~ /^\s*nick *= *(.+)$/) { $main::self = $1 }
      elsif ($current_line =~ /^\s*password *= *(.+)/) { $main::pass = $1 }
      elsif ($current_line =~ /^\s*log_dir *= *(.+)/) { $main::logdir = $1 }
      elsif ($current_line =~ /^\s*processor *= *(.+)/) { $main::processor_name = $1 }
      elsif ($current_line =~ /^\s*terminal_enabled *= *([0-9]+)/) { $main::term_enabled = $1 }
      elsif ($current_line =~ /^\s*processor_threads *= *([0-9]+)/) { $main::num_threads = $1 }
    }

    unless ($main::config_vers == $main::needed_config_vers) {
      print "Wrong configuation version in \"$main::config_file\"\n";
      exit;
    }
  }
  else {
    print "Config file \"$main::config_file\" does not exist. Run setup.pl\n";
    exit;
  }
}

return 1;