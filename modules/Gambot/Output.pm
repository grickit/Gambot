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

###This file handles terminal output and logging.

use strict;
use warnings;
use Term::ANSIColor;
$Term::ANSIColor::AUTORESET = 1;

sub colorOutput {
  #Get the current date and time. This is done every time in case the day changes while the bot is live.
  my ($sec,$min,$hour,$mday,$mon,$year,undef,undef,undef) = localtime(time);
  $mon += 1;
  $year += 1900;
  $hour = sprintf("%02d", $hour);
  $min = sprintf("%02d", $min);
  $sec = sprintf("%02d", $sec);
  my $datestamp = "$year-$mon-$mday";
  my $timestamp = "$hour:$min:$sec";

  #Grab the parameters.
  my ($prefix, $message, $formatting) = @_;

  #Print the message to the terminal output.
  if (&get_core_value('verbose')) {
    print colored ("$prefix $timestamp $message", "$formatting"), "\n";
  }
  #Print the message in the logs.
  if (!(&get_core_value('unlogged'))) {
    open LOGFILE, ">>" . &get_config_value('log_directory') . "/" . &get_config_value('base_nick') . "-$datestamp.txt"
      or die "unable to open logfile \"" . &get_config_value('log_directory') . "/" . &get_config_value('base_nick') . "-$datestamp.txt\n" . "Does that directory structure exist?\n";
    print LOGFILE "$prefix $timestamp $message\n";
    close LOGFILE;
  }
}

1;