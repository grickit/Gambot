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
use Term::ANSIColor;
$Term::ANSIColor::AUTORESET = 1;
use POSIX qw/strftime/;
use File::Path qw(make_path);

my $home_folder = $FindBin::RealBin;
our ($config_vers, $config_file, $server, $port, $self, $pass, $user, $logdir, $processor_name, $sock);
my @cmd_args = @ARGV;
$config_file = 'config.txt';
$config_file = $cmd_args[0] if @cmd_args;
$config_file = "$home_folder/$config_file" if defined $home_folder;
$user = "Gambot";
my $sockqueue = Thread::Queue->new();

unless (-e $config_file) {
  #This sets up all the variable values for the bot such as its name and what channels/rooms it uses.
  CONFIGURE:
    system("reset");
    $config_vers = 3;
    print "Hello. It appears you have never run Gambot before.\n";
    print "You need to answer a few questions to setup the bot.\n----------\n";
    print "1/7 What server should the bot connect to?\n";
      $server = <STDIN>;
      chop $server;
    print "2/7 What port should it connect on?\n";
      $port = <STDIN>;
      chop $port;
    print "3/7 What should the bot's nickname be?\n";
      $self = <STDIN>;
      chop $self;
    print "4/7 What password should it login with?\n";
      $pass = <STDIN>;
      chop $pass;
    print "6/7 Where should the bot's logs be stored? Enter the full path. If any folders do not exist, they will be created.\n";
      $logdir = <STDIN>;
      chop $logdir;
    print "7/7 What is the name of the bot's message processing script? If you don't have one you can use 'example_processor.pl'.\n";
      $processor_name = <STDIN>;
      chop $processor_name;
    print "----------\nConnect to: $server:$port\nLogin as: $self\nUse password: $pass\nStore logs in $logdir\nProcessor: $processor_name\n";
    print "You can change any of these settings later by editing or deleting 'config.txt'.\n";
 
  File::Path::mkpath("$logdir") unless(-d $logdir);
  open (CONFIGW, ">$config_file");
    print CONFIGW "$config_vers\n";
    print CONFIGW "$server\n";
    print CONFIGW "$port\n";
    print CONFIGW "$self\n";
    print CONFIGW "$pass\n";
    print CONFIGW "$logdir\n";
    print CONFIGW "$processor_name\n";
  close (CONFIGW);
}

#Open and read the config file; even if it was just created.
open (CONFIGR, "$config_file");
  $config_vers=<CONFIGR>;
  chop $config_vers;
#If the version for which the config file was made is too far out of date, then it needs to be regenerated.
#If changes are made to the config file syntax then this number should be incremented here and at line 46.
goto CONFIGURE unless ($config_vers >= 3);
  $server = <CONFIGR>;
  $port = <CONFIGR>;
  $self = <CONFIGR>;
  $pass = <CONFIGR>;
  $logdir = <CONFIGR>;
  $processor_name = <CONFIGR>;

  chop $server;
  chop $port;
  chop $self;
  chop $pass;
  chop $logdir;
  chop $processor_name;
close (CONFIGR);

require gamb_output;
require gamb_terminal;
require gamb_connect;

sub process_message {
  while (my $inbound = $sockqueue->dequeue()) {
    chop $inbound; 

    #Highlighted?
    unless ($inbound =~ /^:([a-zA-Z0-9-_\w]+\.)+(net|com|org|gov|edu) 372 $self :.+/) {
      if ($inbound =~ /[ :]$self/) { colorOutput("INCOMING","$inbound",'dark yellow'); }
      else { colorOutput("INCOMING","$inbound",''); }
 
      my $string = uri_escape($inbound,"A-Za-z0-9\0-\377");
      my $content = `perl $home_folder/processors/$processor_name "$string" "$self" 2>/dev/null`;
    
      colorOutput("BOTERROR","Couldn't get the page.",'bold blue') unless defined $content;
      my @lines = split(' :nlsh: ', $content);
	
      foreach my $current_line (@lines) {
	$current_line =~ s/\s+$//;
	print $sock "$current_line\n";
	colorOutput("OUTGOING","$current_line",'red');
	select(undef, undef, undef, 0.5);
      }
    }
  }
}

&connect();
my $thr1 = threads->create(\&terminal_input);
my $thr2 = threads->create(\&process_message);
my $thr3 = threads->create(\&process_message);
my $thr4 = threads->create(\&process_message);
my $thr5 = threads->create(\&process_message);

$thr1->detach();
$thr2->detach();
$thr3->detach();
$thr4->detach();
$thr5->detach();

#Grab socket input
while(my $incoming_message = <$sock>) { 
  $sockqueue->enqueue($incoming_message);
  }
