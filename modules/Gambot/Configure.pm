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

sub read_configuration_file {
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
      line_check('processor', $current_line);
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

sub get_command_arguments {
  for (my $current_arg = 0; $current_arg < @ARGV; $current_arg++) {
    my $current_arg_value = $ARGV[$current_arg];

    if (($current_arg_value =~ /^-v$/) || ($current_arg_value =~ /^--verbose$/)) {
      set_core_value('verbose',1);
    }

    elsif ($current_arg_value =~ /^--unlogged$/) {
      set_core_value('unlogged',1);
    }

    elsif ($current_arg_value =~ /^--config$/) {
      $current_arg++;
      set_core_value('configuration_file',$ARGV[$current_arg]);
    }

    elsif ($current_arg_value =~ /^--staydead$/) {
      $current_arg++;
      set_core_value('staydead',1);
    }

    elsif ($current_arg_value =~ /^--help$/) {
      print "Usage: perl Gambot.pl [OPTION]...\n";
      print "A flexible IRC bot framework that can be updated and fixed while running.\n\n";
      print "-v, --verbose	Prints all messages to the terminal.\n";
      print "		perl Gambot.pl --verbose\n\n";
      print "--unlogged	Disables logging of messages to files.\n";
      print "		perl Gambot.pl --unlogged\n\n";
      print "--config	The argument after this specifies the configuration file to use.\n";
      print "		These are stored in \$script_location/configurations/\n";
      print "		Only give a file name. Not a path.\n";
      print "		perl Gambot.pl --config foo.txt\n\n";
      print "--staydead	The bot will not automatically reconnect.\n";
      print "		perl Gambot.pl --staydead\n\n";
      print "--help		Displays this help.\n";
      print "		perl Gambot.pl --help\n\n";
      print "Ordinarily Gambot will not print output to the terminal, but will log everything to log files.\n";
      print "\$script_location/configurations/config.txt is the default configuration file.\n\n";
      print "For more help, try our IRC channel: ##Gambot at chat.freenode.net\n";
      print "<http://webchat.freenode.net/?channels=\%23\%23Gambot>\n";
      exit;
    }
  }
}

1;