#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
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
my $home_folder = $FindBin::RealBin;

$| = 1;

####-----#----- Setup Variables -----#-----####
  #Variables related to the script input
    my $script_id = <STDIN>;
    my $self = <STDIN>;
    my $incoming_message = <STDIN>;
    $script_id =~ s/[\r\n\s\t]+$//;
    $self =~ s/[\r\n\s\t]+$//;
    $incoming_message =~ s/[\r\n\s\t]+$//;

    if ($script_id eq 'fork20') {
      ACT('JOIN','##Gambot',undef);
    }

  #Variables related to input parsing
    my $have_output; #Track if we've printed anything yet.
    my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-'; #Valid character for a nick name
    my $valid_chan_characters = "#$valid_nick_characters"; #Valid characters for a channel name
    my $valid_human_sender_regex = "([.$valid_nick_characters]+)!~?([.$valid_nick_characters]+)@(.+?)"; #Matches nick!~user@hostname
    my $sl = $self . '[:,]'; #$sl stands for "start of line". It matches, for example, "bobbot:" or "bobbot," or "!b"

  #Variables related to the incoming message
    my ($sender, $account, $hostname, $command, $target, $message); #Basic parts of a typical IRC message
    my $event; #Based on $command. For example a $command of PRIVMSG could be an $event of public_message or private_message
    my $receiver; #Feedback will not necessarily highlight $sender. They might want to redirect it.

  #Variables related to plugins
    my $plugin_list; #A long string of all the plugin code to be eval()uated
    my $version = "Gambot 1.0 - Release Candidate 2 | Example Parser | Perl 5.10.1 | Ubuntu 11.04";
    my $about = "I am a Gambot IRC Bot. For more information, visit my home channel ##Gambot.";

####-----#----- Permissions -----#-----####
  my %permissions;

  $permissions{'wesnoth/developer/*'} 			= '#wesnoth*';
  $permissions{'wesnoth/artist/*'} 			= '#wesnoth*';
  $permissions{'wesnoth/forumsith/*'} 			= '#wesnoth*';

  $permissions{'wesnoth/developer/dave'} 		= '#frogatto*';
  $permissions{'wesnoth/developer/crimson_penguin'} 	= '#frogatto*';
  $permissions{'wesnoth/artist/jetrel'}		 	= '#frogatto*';
  $permissions{'unaffiliated/marcavis*'}	 	= '#frogatto*';

  $permissions{'unaffiliated/dreadknight'} 		= '#AncientBeast';

  $permissions{'unaffiliated/gambit/bot/*'} 		= '##Gambot*';
  $permissions{'wesnoth/developer/grickit'}	 	= '*';
  $permissions{'wesnoth/developer/shadowmaster*'} 	= '*';

  sub CheckAuth {
    my ($channel,$hostmask) = @_;

    while (my ($hostreg, $chanreg) = each %permissions) {
      $hostreg =~ s/\*/.*/;
      $chanreg =~ s/\*/.*/;

      $hostreg = qr/$hostreg/;
      $chanreg = qr/$chanreg/;

      if (($hostmask =~ /^$hostreg$/) && ($channel =~ /^$chanreg$/)) {
	return 1;
      }
    }
    return 0;
  }

  sub AuthError {
    my $location = shift;
    ACT('MESSAGE',$target,"$sender: Sorry. You don't have permission to do that in $location.");
  }

####-----#----- Action Subroutines -----#-----####
  #Sends the data back to the connection script in the proper API and/or raw IRC format
  sub ACT {
    if ($_[0] eq 'MESSAGE') { print "send_server_message>PRIVMSG $_[1] :$_[2]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'ACTION') { print "send_server_message>PRIVMSG $_[1] :ACTION $_[2]\nsleep>0.5\n"; }
    elsif (($_[0] eq 'NOTICE') || ($_[0] eq 'PART') || ($_[0] eq 'KICK') || ($_[0] eq 'INVITE')) { print "send_server_message>$_[0] $_[1] :$_[2]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'JOIN') { print "send_server_message>JOIN $_[1]\nsleep>0.5\n"; }
    elsif ($_[0] eq 'LITERAL') { print "$_[2]\n"; }
    $have_output = 1;
  }

  #Executes a plugin file
  sub LoadPlugin {
    my $plugin_name = shift;
    my $plugin_text;
    open(PLUGIN_FILE, $plugin_name) or die ACT('LITERAL',undef,"error>Could not load plugin file: $plugin_name");
    while(<PLUGIN_FILE>) { $plugin_text .= $_; }
    close(PLUGIN_FILE);
    eval($plugin_text);
  }

####-----#----- Message Parsing -----#-----####
  #Sets up the various event types and variables.
    sub Preparse {
      if ($incoming_message =~ /^PING(.*)$/i) {
	ACT("LITERAL",undef,"send_server_message>PONG$1");
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
	$event = 'join';
      }

      elsif ($incoming_message =~ /^:$valid_human_sender_regex (PART) ([$valid_chan_characters]+) ?:?(.+)?$/) {
	($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
	$message = '' unless $message;
	$event = 'part';
      }

      elsif ($incoming_message =~ /^:$valid_human_sender_regex (QUIT) :(.+)?$/) {
	($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
	$target = '';
	$event = 'quit';
      }

      elsif ($incoming_message =~ /^:$valid_human_sender_regex (MODE) ([$valid_chan_characters]+) (.+)$/) {
	($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
	$event = 'mode';
      }

      elsif ($incoming_message =~ /^:$valid_human_sender_regex (NICK) :(.+)$/) {
	($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
	$target = '';
	$event = 'nick';
      }

      elsif ($incoming_message =~ /^:$valid_human_sender_regex (KICK) ([$valid_chan_characters]+) ?:?(.+)?$/) {
	($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
	$message = '' unless $message;
	$event = 'kick';
      }

      elsif ($incoming_message =~ /^:(.+?) ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
	($sender, $account, $hostname, $command, $target, $message) = ($1, $1, $1, $2, $3, $4);
	$event = 'server_message';
      }

      elsif ($incoming_message =~ /^ERROR :(.+)$/) {
	($sender, $account, $hostname, $command, $target, $message) = ('','','','','',$1);
	$event = 'error';
      }

      else {
	ACT('LITERAL',undef,"log>APIERROR>Message did not match preparser.");
	ACT('LITERAL',undef,"log>APIERROR>$incoming_message");
	exit();
      }
    }

####-----#----- Event Handling -----#-----####

    my $events = {
      'server_ping' => \&on_ping,
      'private_message' => \&on_private_message,
      'public_message' => \&on_public_message,
      'private_notice' => \&on_private_notice,
      'public_notice' => \&on_public_notice,
      'join' => \&on_join,
      'part' => \&on_part,
      'quit' => \&on_quit,
      'mode' => \&on_mode,
      'nick' => \&on_nick,
      'kick' => \&on_kick,
      'server_message' => \&on_server_message,
      'error' => \&on_error
    };

    sub on_ping { }

    sub on_private_message {
      LoadPlugin("$home_folder/plugins/basic/ctcp.pm");
      &on_public_message();
    }

    sub on_public_message {
      LoadPlugin("$home_folder/plugins/basic/about.pm");
      LoadPlugin("$home_folder/plugins/basic/version.pm");

      LoadPlugin("$home_folder/plugins/actions.pm");
      LoadPlugin("$home_folder/plugins/hug.pm");
      LoadPlugin("$home_folder/plugins/temperature.pm");
      LoadPlugin("$home_folder/plugins/time.pm");

      LoadPlugin("$home_folder/plugins/staff/checkauth.pm");
      LoadPlugin("$home_folder/plugins/staff/speak.pm");
      LoadPlugin("$home_folder/plugins/staff/joinpart.pm");
      LoadPlugin("$home_folder/plugins/staff/op.pm");
      LoadPlugin("$home_folder/plugins/staff/voice.pm");
      LoadPlugin("$home_folder/plugins/staff/quiet.pm");

      LoadPlugin("$home_folder/plugins/conversation/quote.pm");
      LoadPlugin("$home_folder/plugins/conversation/dictionary.pm");

      LoadPlugin("$home_folder/plugins/games/dice.pm");
      LoadPlugin("$home_folder/plugins/games/eightball.pm");
      LoadPlugin("$home_folder/plugins/games/roulette.pm");

      LoadPlugin("$home_folder/plugins/internet/ticket.pm");
      LoadPlugin("$home_folder/plugins/internet/translate.pm");
      LoadPlugin("$home_folder/plugins/internet/url-check.pm");
      LoadPlugin("$home_folder/plugins/internet/youtube.pm");

      LoadPlugin("$home_folder/plugins/conversation/QMarkAPI.pm");
    }

    sub on_private_notice { &on_public_notice(); }

    sub on_public_notice { }

    sub on_join { }

    sub on_part { }

    sub on_quit { }

    sub on_mode { }

    sub on_nick { }

    sub on_kick { }

    sub on_server_message {
      LoadPlugin("$home_folder/plugins/basic/nick_bump.pm");
    }

    sub on_error {
      ACT('LITERAL',undef,"log>APIERROR>$message");
    }


####-----#----- Execution -----#-----####
  &Preparse();
  $events->{$event}->();