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
use lib $FindBin::Bin;
use plugin_parse;

$| = 1;
my $home_folder = $FindBin::RealBin;
my ($script_id, $self, $incoming_message) = &startup_variables();
my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-';
my $valid_chan_characters = "#$valid_nick_characters";
my $valid_human_sender_regex = "([.$valid_nick_characters]+)!~?([.$valid_nick_characters]+)@(.+?)";
my ($event, $sender, $account, $hostname, $command, $target, $message, $receiver) = &parse_message($self, $incoming_message);
my ($sl, $cm, $version, $about);
sub load_plugin {
  my $plugin_name = shift;
  my $plugin_text;
  open(PLUGIN_FILE, $plugin_name) or ACT('LITERAL',undef,"error>Could not load plugin file: $plugin_name");
  while(<PLUGIN_FILE>) { $plugin_text .= $_; }
  close(PLUGIN_FILE);
  eval($plugin_text);
}

####-----#----- ################## -----#-----####
####-----#----- BEGIN EDITING HERE -----#-----####
####-----#----- ################## -----#-----####

$sl = $self . '[:,]'; #$sl stands for "start of line". For example: "janebot:"
$cm = '!'; #$cm stands for "command marker".
$version = "Gambot 1.0 | Example Parser | Perl 5.10.1 | Ubuntu 11.04";
$about = "I am a Gambot IRC Bot. For more information, visit my home channel ##Gambot.";

if ($script_id eq 'fork20') {
  ACT('JOIN','##Gambot',undef);
}

sub on_ping { }

sub on_private_message {
  &load_plugin("$home_folder/plugins/basic/ctcp.pm");

  $message = "$self: $message";
  &on_public_message();
}

sub on_public_message {
  &load_plugin("$home_folder/plugins/basic/about.pm");
  &load_plugin("$home_folder/plugins/basic/version.pm");

  &load_plugin("$home_folder/plugins/actions.pm");
  &load_plugin("$home_folder/plugins/hug.pm");
  &load_plugin("$home_folder/plugins/temperature.pm");
  &load_plugin("$home_folder/plugins/time.pm");

  &load_plugin("$home_folder/plugins/staff/checkauth.pm");
  &load_plugin("$home_folder/plugins/staff/speak.pm");
  &load_plugin("$home_folder/plugins/staff/joinpart.pm");
  &load_plugin("$home_folder/plugins/staff/op.pm");
  &load_plugin("$home_folder/plugins/staff/voice.pm");
  &load_plugin("$home_folder/plugins/staff/quiet.pm");

  &load_plugin("$home_folder/plugins/staff/literal.pm");

  &load_plugin("$home_folder/plugins/conversation/quote.pm");
  &load_plugin("$home_folder/plugins/conversation/dictionary.pm");

  &load_plugin("$home_folder/plugins/games/dice.pm");
  &load_plugin("$home_folder/plugins/games/eightball.pm");
  &load_plugin("$home_folder/plugins/games/roulette.pm");

  &load_plugin("$home_folder/plugins/internet/ticket.pm");
  &load_plugin("$home_folder/plugins/internet/translate.pm");
  &load_plugin("$home_folder/plugins/internet/url-check.pm");
  &load_plugin("$home_folder/plugins/internet/youtube.pm");

  &load_plugin("$home_folder/plugins/conversation/QMarkAPI.pm");
}

sub on_private_notice {
  $message = "$self: $message";
  &on_public_notice();
}

sub on_public_notice { }

sub on_join { }

sub on_part { }

sub on_quit { }

sub on_mode { }

sub on_nick { }

sub on_kick { }

sub on_server_message {
  &load_plugin("$home_folder/plugins/basic/nick_bump.pm");
}

sub on_error {
  ACT('LITERAL',undef,"log>APIERROR>$message");
}

####-----#----- ################# -----#-----####
####-----#----- STOP EDITING HERE -----#-----####
####-----#----- ################# -----#-----####
&fire_event($event);
