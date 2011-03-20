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

use FindBin;
use lib "$FindBin::Bin";

sub ask_question {
  my $question = shift;
  print "\n$question\n";
  my $answer = <STDIN>;
  chop $answer;
  return $answer;
}

my $home_folder = $FindBin::RealBin;
my $config_file = 'config.txt';
my $config_vers = 4;

my @cmd_args = @ARGV;
$config_file = "$home_folder/$cmd_args[0]" if @cmd_args;

print "Welcome to the Gambot setup.\n";
print "You just need to answer a few simple questions to setup the bot.\n";
my $server = &ask_question("What server should the bot connect to?");
my $port = &ask_question("What port should it connect on?");
my $nick = &ask_question("What should the bot's nick be?");
my $pass = &ask_question("What password should the bot use? (Leave blank if no password.)");
my $logdir = &ask_question("Where should the bot's logs be stored?\nEnter a full path. This directory should already exist.");
my $processor = &ask_question("What processor should the bot use?\nIf you don't know just enter \"example_processor.pl\"");
my $terminal = &ask_question("Do you want to enable the termianl thread? (Y/N)\nThe terminal thread allows you to enter raw IRC in the terminal.\nThis feature costs ~2MB of extra memory.");
my $num_processors = &ask_question("How many message processing threads do you want? (2-10 recommended)");

if ($terminal =~ /y/i) { $terminal = 1; }
else { $terminal = 0; }

open (CONFIGW, ">$config_file");
  print CONFIGW "[bot]
  config_version = $config_vers

  [server]
    server = $server
    port = $port
  [/server]

  [account]
    nick = $nick
    password = $pass
  [/account]

  [local]
    log_dir = $logdir
    processor = $processor
  [/local]

  [logic]
    terminal_enabled = $terminal
    processor_threads = $num_processors
  [/logic]
[/bot]
";
close (CONFIGW);