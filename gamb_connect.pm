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

sub connect { 
  #Create the socket and connect.
  colorOutput("BOTERROR","I am attempting to connect.",'bold blue');
  use IO::Socket; 
    $main::sock = new IO::Socket::INET( 
    PeerAddr => "$main::server", 
    PeerPort => $main::port, 
    Proto => 'tcp') 
    or die "Error while connecting.";

  #Login with services.
  colorOutput("BOTERROR","I am attempting to login.",'bold blue');
  ###Uncomment this line below if you have an account.
  print $main::sock "PASS $main::user:$main::pass\x0D\x0A";
  print $main::sock "NICK $main::self\x0D\x0A"; 
  print $main::sock "USER $main::user 8 * :Perl Gambot\x0D\x0A"; 
}

return 1;