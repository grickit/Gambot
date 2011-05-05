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

###This file connects to the server.

use strict;
use warnings;

sub connect_to_server {
  my ($server, $port, $nick, $pass) = @_;
  #Create the socket and connect.
  colorOutput("BOTEVENT","I am attempting to connect.",'bold blue');
  use IO::Socket; 
  my $sock = new IO::Socket::INET( 
    PeerAddr => "$server", 
    PeerPort => $port, 
    Proto => 'tcp') 
    or die "Error while connecting to $server:$port";

  #Login with services.
  colorOutput("BOTEVENT","I am attempting to login.",'bold blue');
  print $sock "PASS $nick:$pass\x0D\x0A";
  print $sock "NICK $nick\x0D\x0A"; 
  print $sock "USER Gambot 8 * :Perl Gambot\x0D\x0A";

  return $sock;
}

1;