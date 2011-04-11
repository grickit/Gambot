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

###This file parses the Gambot API

use strict;
use warnings;

sub parse_command {
  my $command = shift;

  if ($command =~ /^send>(.+)$/) {
    print $main::sock "$1\n";
    colorOutput("OUTGOING","$1",'red');
    select(undef, undef, undef, 0.5);
  }

  elsif ($command =~ /^timer>$/) {
    timer_action();
  }

  elsif ($command =~ /^quit>$/) {
    colorOutput("BOTERROR","Shut down by API call.",'bold red');
    exit;
  }

  elsif ($command =~ /^log>(.+)$/) {
    colorOutput("APIEVENT","$1",'bold green');
  }

  else {
    colorOutput("BOTERROR","Unknown API call.",'bold red');
    colorOutput("BOTERROR","$command",'bold red');
  }
}

return 1;