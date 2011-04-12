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

use threads;
use Thread::Queue;
use FindBin;
use lib "$FindBin::Bin";
use URI::Escape;

use gamb_output;
use gamb_connect;
use gamb_terminal;
use gamb_timer;
use gamb_parser;
use gamb_configure;

our $home_folder = $FindBin::RealBin;

#Connection variables
our ($server, $port, $self);
our $pass = '';
#Management variables
our ($logdir, $processor_name, $term_enabled, $timer_enabled, $timer_regex, $timer_action, $num_threads);
our $config_file = 'config.txt';
our $config_vers = 0;
our $needed_config_vers = 5;
#Socket connection
our $sock;

my @cmd_args = @ARGV;
$config_file = $cmd_args[0] if @cmd_args;
$config_file = "$home_folder/$config_file" if defined $home_folder;

my $sockqueue = Thread::Queue->new();
my @threads = ();

&read_configuration();
&connect_to_server();

sub process_message {
  while (my $inbound = $sockqueue->dequeue()) {
    chop $inbound; 

    #Filter MotD spam
    if ($inbound !~ /^:([a-zA-Z0-9-_\w]+\.)+(net|com|org|gov|edu) (372|375|376) $self :.+/) {
      #Highlighted?
      if ($inbound =~ /$self/) { colorOutput("INCOMING","$inbound",'bold yellow'); }
      else { colorOutput("INCOMING","$inbound",''); }
 
      my $string = uri_escape($inbound,"A-Za-z0-9\0-\377");
   
      open(MESSAGE, "perl $home_folder/processors/$processor_name \"$string\" \"$self\" 2>/dev/null |");
      while (my $current_line = <MESSAGE>) {
	parse_command($current_line);
      }              
      close(MESSAGE);
    }
  }
}

if ($term_enabled) {
  push(@threads,threads->create(\&terminal_input));
  $threads[-1]->detach();
}

if ($timer_enabled) {
  push(@threads,threads->create(\&timer_clock));
  $threads[-1]->detach();
}

for my $i (1..$num_threads) {
  push(@threads,threads->create(\&process_message));
  $threads[-1]->detach();
}

#Grab socket input
while(my $incoming_message = <$sock>) { 
  $sockqueue->enqueue($incoming_message);
}
