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

###This file reads configuration files into variables and processes switches

use strict;
use warnings;

sub read_configuration_file {
  my $filename = shift;
  if (-e $filename) {
    open (my $config, $filename);
    my @config_lines = <$config>;

    foreach my $current_line (@config_lines) {
      $current_line =~ s/[\r\n\s]+$//;
      $current_line =~ s/^[\t\s]+//;
      if ($current_line =~ /^([a-zA-Z0-9_-]+) = "(.+)"$/) {
	&set_config_value($1,$2);
      }
    }
  }
  else {
    set_core_value('unlogged',1);
    set_config_value('server','chat.freenode.net');
    set_config_value('port',6667);
    set_config_value('base_nick','aGambot');
    set_config_value('password','');
    set_config_value('log_directory',&get_core_value('home_directory'));
    set_config_value('processor',"perl " . &get_core_value('home_directory') . "/parsers/plugin_parser/example.pl");
    error_output("Config file \"$filename\" does not exist.");
    error_output("I am filling it with sample values.");
    error_output("Edit it later to suit your needs.");
    error_output("File logging will be disabled until you do this.");
    open(my $config, ">$filename");
    print $config "Keep these values wrapped in quotes.\015\012";
    print $config "server = \"chat.freenode.net\"\015\012";
    print $config "port = \"6667\"\015\012";
    print $config "base_nick = \"aGambot\"\015\012";
    print $config "password = \"\"\015\012";
    print $config "log_directory = \"" . &get_core_value('home_directory') . "\"\015\012";
    print $config "processor = \"perl " . &get_core_value('home_directory') . "/parsers/plugin_parser/example.pl\"\015\012";
  }
}

sub load_switches {
  for (my $current_arg = 0; $current_arg < @ARGV; $current_arg++) {
    my $current_arg_value = $ARGV[$current_arg];

    if (($current_arg_value eq "-v") || ($current_arg_value eq "--verbose")) {
      set_core_value('verbose',1);
    }

    elsif ($current_arg_value eq "--debug") {
      set_core_value('debug',1);
    }

    elsif ($current_arg_value eq "--unlogged") {
      set_core_value('unlogged',1);
    }

    elsif ($current_arg_value eq "--config") {
      $current_arg++;
      set_core_value('configuration_file',$ARGV[$current_arg]);
    }

    elsif ($current_arg_value eq "--staydead") {
      set_core_value('staydead',1);
    }

    elsif ($current_arg_value eq "--help") {
      print "Usage: perl Gambot.pl [OPTION]...\n";
      print "A flexible IRC bot framework that can be updated and fixed while running.\n\n";
      print "-v, --verbose	Prints all messages to the terminal.\n";
      print "		perl gambot.pl --verbose\n\n";
      print "--debug		Enables debug message logging\n";
      print "		perl gambot.pl --debug\n\n";
      print "--unlogged	Disables logging of messages to files.\n";
      print "		perl gambot.pl --unlogged\n\n";
      print "--config	The argument after this specifies the configuration file to use.\n";
      print "		These are stored in \$script_location/configurations/\n";
      print "		Only give a file name. Not a path.\n";
      print "		perl gambot.pl --config foo.txt\n\n";
      print "--staydead	The bot will not automatically reconnect.\n";
      print "		perl gambot.pl --staydead\n\n";
      print "--help		Displays this help.\n";
      print "		perl gambot.pl --help\n\n";
      print "Ordinarily Gambot will not print much output to the terminal, but will log everything to files.\n";
      print "\$script_location/configurations/config.txt is the default configuration file.\n\n";
      print "For more help, try our IRC channel: ##Gambot at chat.freenode.net\n";
      print "<http://webchat.freenode.net/?channels=\%23\%23Gambot>\n";
      exec('true');
    }
  }
}

1;
