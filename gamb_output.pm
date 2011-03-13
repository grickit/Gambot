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

sub colorOutput {
  #Get the current date and time. This is done every time in case the day changes while the bot is live.
  my $datestamp = strftime('%Y-%m-%d',localtime);
  my $timestamp = strftime('%m-%d-%Y %H:%M:%S',localtime);
  
  #Grab the parameters.
  my ($prefix, $message, $formatting) = @_;
 
  #Print the message to the terminal output.
  print colored ("$prefix $timestamp $message", "$formatting"), "\n";
  #Print the message in the logs.
  open FILE, ">>$main::logdir/$datestamp-$main::self.txt" or die "unable to open logfile \"$main::logdir/$datestamp-$main::self.txt\"";
  print FILE "$prefix $timestamp $message\n";
  close FILE;
}

return 1;