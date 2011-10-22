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
use IO::Socket;

sub create_socket_connection {
  my ($server, $port, $nick, $pass) = @_;
  &event_output('I am attempting to connect.');

  my $sock = new IO::Socket::INET(
    PeerAddr => $server,
    PeerPort => $port,
    Proto => 'tcp',
    timeout => 1)
    or die "Error while connecting to $server:$port";

  &event_output('I am attempting to login.');
  print $sock "PASS $nick:$pass\015\012" if($pass);
  print $sock "NICK $nick\015\012";
  print $sock "USER Gambot 8 * :Perl Gambot\015\012";

  return $sock;
}

1;
