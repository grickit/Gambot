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

#####----------Setup----------#####

use Switch;
use CGI;
use URI::Escape;
use POSIX qw/strftime/;
use LWP::Simple;
use FindBin;
use lib "$FindBin::Bin";
my $home_folder = $FindBin::RealBin;

#The arguments for running this as a cgi page or a script
my $url_args = CGI->new;
my @cmd_args = @ARGV;
my ($incoming_message, $self);

#If it's run as a script
if (@cmd_args > 0) {
  $incoming_message = $cmd_args[0];
  $self = $cmd_args[1]; }

#If it's run as a webpage
else {
  $incoming_message = $url_args->param('msg');
  $self=$url_args->param('self');
  print "Content-type: text/html\r\n\r\n"; }

#Messages are sent in a heavily uri_escaped form. We need to undo that before we can parse them.
$incoming_message = uri_unescape($incoming_message,"A-Za-z0-9\0-\377");

#general variables
my $output = '';
my($sender, $account, $hostname, $command, $target, $message, $receiver, $authed_channels, $answer, $plugin_list);
my $nl = " :nlsh: ";
my $sl = "^" . $self . "[:,]";
my $version = "Gambot 5.0 | Example Processor | Perl 5.10.1 | Ubuntu 10.10";
my $about = "I am an IRC bot developed by Gambit. For more information, try my !help command, or visit my home channel: ##Gambot";

#Sanitize any artificial end-of-message strings in the input
chop $incoming_message;
$incoming_message =~ s/$nl//;

#####----------Parsing----------#####

sub message_processor {
  my $valid_name_characters = 'A-Za-z0-9[\]\\`_^{}|-';
  my $valid_chan_characters = '\w#-_|';
  my @commands_regexes;
  my @commands_subs;
  my @commands_helps;

  #Pre-pre-parsing{
  if ($incoming_message =~ m/^:([$valid_name_characters]+)!~?([$valid_name_characters]+)@(.+?) ([A-Z]+) ?(#*.+? )?:?(.+?)?$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $receiver = $sender;
    $target =~ s/ $//;
  }
  elsif ($incoming_message =~ /^:(.+?) MODE $self :?\+i/i) { 
	$output = "JOIN ##Gambot"; }
  elsif ($incoming_message =~ /^PING(.*)$/i) { $output = "PONG$1"; return; }
  else { return; }
  #}
  
  #Pre-parsing{
  if ($command eq 'QUIT') { ($target, $message) = ('undefined', ($target . ' ' . $message)); }
  elsif ($command eq 'JOIN') { $target =~ s/^://; }
  elsif (($command eq 'PRIVMSG') && ($target eq $self)) { $target = $sender; $message = "$self: $message"; }
  elsif (($command eq 'PRIVMSG') && ($target ne $self)) { $command = 'MSG'; }
  elsif (($command eq 'NOTICE') && ($target eq $self)) { $command = 'PRIVNOTICE'; }

  if ($message =~ /@ ?([$valid_name_characters]+)$/) { $receiver = $1; $message =~ s/ ?@ ?([$valid_name_characters]+)$//; };
  #}

  if (($command eq 'MSG') || ($command eq 'PRIVMSG')) { 
    LoadPlugin("$home_folder/plugins/ctcp.pm");
    LoadPlugin("$home_folder/plugins/version.pm");
    LoadPlugin("$home_folder/plugins/help.pm");
    LoadPlugin("$home_folder/plugins/about.pm");
    LoadPlugin("$home_folder/plugins/time.pm");
    LoadPlugin("$home_folder/plugins/hug.pm");
    LoadPlugin("$home_folder/plugins/temperature/temp-basic.pm");
    LoadPlugin("$home_folder/plugins/internet/translate.pm");
    LoadPlugin("$home_folder/plugins/internet/url-check.pm");
    LoadPlugin("$home_folder/plugins/games/dice.pm");
    LoadPlugin("$home_folder/plugins/games/eightball.pm");
    LoadPlugin("$home_folder/plugins/encode.pm");

    LoadPlugin("$home_folder/plugins/conversation/always-here.pm");
    LoadPlugin("$home_folder/plugins/conversation/ed-block.pm");
    LoadPlugin("$home_folder/plugins/conversation/quote.pm");

    LoadPlugin("$home_folder/plugins/staff/joinpart.pm");
    LoadPlugin("$home_folder/plugins/staff/op.pm");
    LoadPlugin("$home_folder/plugins/staff/voice.pm");
    LoadPlugin("$home_folder/plugins/staff/quiet.pm");
    LoadPlugin("$home_folder/plugins/staff/speak.pm");
    LoadPlugin("$home_folder/plugins/staff/checkauth.pm");
    
    LoadPlugin("$home_folder/plugins/staff/literal.pm");

    LoadPlugin("$home_folder/plugins/conversation/QMarkAPI.pm");
    eval($plugin_list);

    my $i = 0;
    foreach my $current_regex (@commands_regexes) {
      if ($message =~ /$current_regex/i) {
	my $command = $commands_subs[$i];
	&$command;
      }
      $i++;
    }
  }
}
 
#####----------Subroutines----------#####

sub ACT {
  switch ($_[0]) {

    case /MESSAGE/ { $output = $output . "PRIVMSG $_[1] :$_[2]"; }

    case /ACTION/ { $output = $output . "PRIVMSG $_[1] :ACTION $_[2]"; }

    case /(NOTICE|PART|KICK|INVITE)/ { $output = $output . "$_[0] $_[1] :$_[2]"; }

    case /JOIN/ { $output = $output . "JOIN $_[1]"; }
  }
}

sub CheckAuth {
  my $channel = shift;
  my $subject = shift;
  my ($channels, $authed);

#This list has many different kinds of examples for you to use to create your own permissions lists.
#Be warned that these are examples of actual channels and users on freenode. You should change them
#to suit your own network/project.
if ($subject =~ m!^wesnoth/(developer|artist|forumsith)/.+$!i) { $channels = "(#wesnoth.*)"; }
if ($subject =~ m!^wesnoth/developer/crimson_penguin$!i) { $channels = "(#frogatto.*)|(#wesnoth.*)"; }
if ($subject =~ m!^wesnoth/developer/dave$!i) { $channels = "(#frogatto.*)|(#wesnoth.*)"; }
if ($subject =~ m!^wesnoth/artist/jetrel$!i) { $channels = "(#frogatto.*)|(#wesnoth.*)"; }
if ($subject =~ m!^unaffiliated/marcavis$!i) { $channels = "(#frogatto.*)"; }
if ($subject =~ m!^unaffiliated/dreadknight$!i) { $channels = "(#AncientBeast.*)"; }
if ($subject =~ m!^unaffiliated/gambit/bot/.+$!i) { $channels = ".+"; }
if ($subject =~ m!^wesnoth/developer/grickit$!i) { $channels = ".+"; }
if ($subject =~ m!^wesnoth/developer/shadowmaster$!i) { $channels = ".+"; }

  if ($channel =~ /^$channels$/i) {
    $authed = 1; }
  else {
    $authed = 0; 
  }

  if ($hostname eq "wesnoth/developer/grickit") { $authed = 2; }
  return $authed;
}

sub Error {
  my $channel = shift;
  ACT("MESSAGE","$target","$sender: Sorry. You don't have permission to do that in $channel.");
}

sub LoadPlugin {
  my $plugin = shift;
  open(DAT, $plugin) || die("Could not open file!");
  my @raw_data=<DAT>;
  close(DAT);

  foreach my $current_line (@raw_data) {
    $plugin_list = $plugin_list . $current_line;
  }
}

message_processor();
#Replace any newlines in the output with the artificial end-of-message string
$output =~ s/\n/$nl/;
print "$output";
