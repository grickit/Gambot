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

use URI::Escape;
use FindBin;
use lib "$FindBin::Bin";
my $home_folder = $FindBin::RealBin;
$| = 1;



#####-------------------------Setup Variables-------------------------#####
  #Variables related to the script input
    my ($incoming_message, $self) = @ARGV; #Grab the command line arguments
    $incoming_message = uri_unescape($incoming_message,"A-Za-z0-9\0-\377");
    $incoming_message =~ s/(\n|\r)+//;

  #Variables related to input parsing
    my $have_output; #Track if we've printed anything yet.
    my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-'; #Valid character for a nick name
    my $valid_chan_characters = "#$valid_nick_characters"; #Valid characters for a channel name
    my $valid_human_sender_regex = "([.$valid_nick_characters]+)!~?([$valid_nick_characters]+)@(.+?)"; #Matches nick!~user@hostname
    my $sl = "$self" . '[:,]'; #$sl stands for "start of line". It matches, for example, "bobbot:" or "bobbot,"

  #Variables related to the incoming message
    my ($sender, $account, $hostname, $command, $target, $message); #Basic parts of a typical IRC message
    my $event; #Based on $command. For example a $command of PRIVMSG could be an $event of public_message or private_message
    my $receiver; #Feedback will not necessarily highlight $sender. They might want to redirect it.

  #Variables related to plugins
    my $plugin_list; #A long string of all the plugin code to be eval()uated
    my @commands_helps;
    my $version = "Gambot 0.12 | Example Processor | Perl 5.10.1 | Ubuntu 11.04";
    my $about = "I am an IRC bot developed by Gambit. For more information, try my !help command, or visit my home channel: ##Gambot";

  #A container for persistent variables that plugins may useful
    my %variables;



#####-------------------------Action Subroutines-------------------------#####
  #Sends the data back to the connection script in the proper API and/or raw IRC format
  sub ACT {
    if ($_[0] eq 'MESSAGE') { print "send>PRIVMSG $_[1] :$_[2]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'ACTION') { print "send>PRIVMSG $_[1] :ACTION $_[2]\nsleep>0.5\n"; }
    elsif (($_[0] eq 'NOTICE') || ($_[0] eq 'PART') || ($_[0] eq 'KICK') || ($_[0] eq 'INVITE')) { print "send>$_[0] $_[1] :$_[2]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'JOIN') { print "send>JOIN $_[1]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'LITERAL') { print "$_[2]\n"; }
    $have_output = 1;
  }



  #Loads the specified plugin file into the plugin list
  sub LoadPlugin {
    my $plugin_name = shift;
    open(PLUGIN_FILE, $plugin_name) or die ACT('LITERAL',undef,"error>Could not load plugin file: $plugin_name");
    while(<PLUGIN_FILE>) { $plugin_list .= $_; }
    close(PLUGIN_FILE);
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



#####-------------------------Parsing Subroutines-------------------------#####
  #Sets up the various event types and variables.
  sub Preparse {
    if ($incoming_message =~ /^PING(.*)$/i) {
      ACT("LITERAL",undef,"send>PONG$1");
      ($sender, $account, $hostname, $command, $target, $message) = ('', '', '', '', '', '');
      $event = 'server_ping';
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (PRIVMSG) ([$valid_chan_characters]+) :(.+)$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
      if ($target eq $self) { $event = 'private_message'; $target = $sender; $message = "$self: $message"; }
      else { $event = 'public_message'; }
      $receiver = $sender;
      if ($message =~ /@ ?([, $valid_nick_characters]+)$/) { 
	$receiver = $1; 
	$message =~ s/ ?@ ?([, $valid_nick_characters]+)$//;
      }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (NOTICE) ([$valid_chan_characters]+) :(.+)$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
      if ($target eq $self) { $event = 'private_notice'; $target = $sender; $message = "$self: $message"; }
      else { $event = 'public_notice'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (JOIN) :([$valid_chan_characters]+)$/) {
      ($sender, $account, $hostname, $command, $target) = ($1, $2, $3, $4, $5);
      $message = '';
      if ($sender eq $self) { $event = 'self_join'; }
      else { $event = 'other_join'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (PART) ([$valid_chan_characters]+) ?:?(.+)?$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
      $message = '' unless $message;
      if ($sender eq $self) { $event = 'self_part'; }
      else { $event = 'other_part'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (QUIT) :(.+)$/) {
      ($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
      $target = '';
      if ($sender eq $self) { $event = 'self_quit'; }
      else { $event = 'other_quit'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (MODE) ([$valid_chan_characters]+) (.+)$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
      if ($sender eq $self) { $event = 'self_mode'; }
      else { $event = 'other_mode'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (NICK) :(.+)$/) {
      ($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
      $target = '';
      if ($sender eq $self) { $event = 'self_nick'; }
      else { $event = 'other_nick'; }
    }

    elsif ($incoming_message =~ /^:$valid_human_sender_regex (KICK) ([$valid_chan_characters]+) ?:?(.+)?$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
      $message = '' unless $message;
      if ($sender eq $self) { $event = 'self_kick'; }
      else { $event = 'other_kick'; }
    }

    elsif ($incoming_message =~ /^:(.+?) ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ($1, $1, $1, $2, $3, $4);
      $event = 'server_message';
    }

    elsif ($incoming_message =~ /^ERROR :(.+)$/) {
      ($sender, $account, $hostname, $command, $target, $message) = ('','','','','','');
      $event = 'error';
      ACT('LITERAL',undef,"error>$1");
    }
    
    else {
      ACT('LITERAL',undef,"error>Message did not match preparser.");
      ACT('LITERAL',undef,"error>$incoming_message");
    }
  }



  #Loads plugins based on $event
  sub Parse {
    LoadPlugin("$home_folder/plugins/nick_bump.pm");
    LoadPlugin("$home_folder/plugins/about.pm");
    LoadPlugin("$home_folder/plugins/ctcp.pm");
    LoadPlugin("$home_folder/plugins/hug.pm");
    LoadPlugin("$home_folder/plugins/encode.pm");
    LoadPlugin("$home_folder/plugins/version.pm");
    LoadPlugin("$home_folder/plugins/time.pm");

    LoadPlugin("$home_folder/plugins/staff/joinpart.pm");
    LoadPlugin("$home_folder/plugins/staff/literal.pm");
    LoadPlugin("$home_folder/plugins/staff/op.pm");
    LoadPlugin("$home_folder/plugins/staff/quiet.pm");
    LoadPlugin("$home_folder/plugins/staff/voice.pm");

    LoadPlugin("$home_folder/plugins/conversation/quote.pm");

    LoadPlugin("$home_folder/plugins/games/dice.pm");
    LoadPlugin("$home_folder/plugins/games/eightball.pm");
    LoadPlugin("$home_folder/plugins/games/reverse.pm");

    LoadPlugin("$home_folder/plugins/internet/ticket.pm");
    LoadPlugin("$home_folder/plugins/internet/url-check.pm");
    LoadPlugin("$home_folder/plugins/internet/youtube.pm");

    LoadPlugin("$home_folder/plugins/temperature/temp-basic.pm");

    LoadPlugin("$home_folder/plugins/conversation/QMarkAPI.pm");
    eval($plugin_list);
  }



#####-------------------------Actual Execution-------------------------#####
  Preparse();
  Parse();
  print "end>\n";