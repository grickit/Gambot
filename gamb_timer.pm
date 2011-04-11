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

###This file executes a script at certain time intervals.

use strict;
use warnings;

sub timer_clock {
  colorOutput("BOTEVENT","Timer started.",'bold blue');
  while (1) {
    my ($sec,$min,$hour,undef,undef,undef,undef,undef,undef) = localtime(time);
    if ("$hour:$min:$sec" =~ /$main::timer_regex/) {
      timer_action();
    }
    else {
      sleep(1);
    }
  }
}

sub timer_action {
  colorOutput("BOTEVENT","Timer triggered.",'bold blue');
  open(TIMER, "perl $main::home_folder/processors/timers/$main::timer_action |");
  while (my $current_line = <TIMER>) {
    parse_command($current_line);
  }              
  close(TIMER);
}

return 1;