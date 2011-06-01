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
    send_server_message($1);
    colorOutput("OUTGOING","$1",'red');
    ##Are they changing their nick?
    if ($1 =~ /^NICK (.+)$/) { set_core_value('nick',$1); }
    select(undef, undef, undef, 0.5);
  }

  elsif ($command =~ /^quit>(.*)$/) {
    colorOutput("BOTERROR","Shut down by API call: $1",'bold red');
    send_server_message("QUIT :Shut down by API call: $1");
  }

  elsif ($command =~ /^timer>$/) {
    if (get_config_value('enable_timer')) { create_timer_fork(); }
    else { send_server_message("PRIVMSG ##Gambot :Timer not enabled but triggered."); }
  }

  elsif ($command =~ /^log>(.+)$/) {
    colorOutput("APIEVENT","$1",'bold green');
  }

  elsif ($command =~ /^error>(.+)$/) {
    colorOutput("APIERROR","$1",'bold red');
  }

  elsif ($command =~ /^core_value>([a-z_]+)>(.+)$/) {
    set_core_value($1,$2);
    colorOutput("APIVALUE","core $1: $2",'bold blue');
  }

  elsif ($command =~ /^config_value>([a-z_]+)>(.+)$/) {
    set_config_value($1,$2);
    colorOutput("APIVALUE","config $1: $2",'bold blue');
  }

  else {
    colorOutput("BOTERROR","Unknown API call: $command",'bold red');
  }
}

1;