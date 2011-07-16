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
$version = "Gambot 1.0 | Wolfgame Parser | Perl 5.10.1 | Ubuntu 11.04";
$about = "I am a Gambot that moderates games of Wolfgame - a Mafia Party Game variant.";

if ($script_id eq 'fork20') {
  ACT('JOIN','##Gambot',undef);
}

sub on_ping {
  ACT('LITERAL',undef,'check_pipe_exists>wolfstate');
  my $state_status = <STDIN>;
  $state_status =~ s/[\r\n\t\s]+$//;
  if ($state_status) {
    ACT('LITERAL',undef,'send_pipe_message>wolfstate>check_time>');
  }
}

sub on_private_message {
  if ($message =~ /^see ([A-Za-z0-9[\]\\`_^{}|-]+)$/) {
    ACT('LITERAL',undef,"send_pipe_message>wolfstate>see>$sender>$1");
  }

  if ($message =~ /^visit ([A-Za-z0-9[\]\\`_^{}|-]+)$/) {
    ACT('LITERAL',undef,"send_pipe_message>wolfstate>visit>$sender>$1");
  }

  if ($message =~ /^eat ([A-Za-z0-9[\]\\`_^{}|-]+)$/) {
    ACT('LITERAL',undef,"send_pipe_message>wolfstate>eat>$sender>$1");
  }
}

sub on_public_message {
  if ($target eq '##Gambot') {
    if ($message =~ /^\.join$/) {
      ACT('LITERAL',undef,'check_pipe_exists>wolfstate');
      my $state_status = <STDIN>;
      $state_status =~ s/[\r\n\t\s]+$//;
      if ($state_status) {
	ACT('LITERAL',undef,"send_pipe_message>wolfstate>join>$sender");
      }
      else {
	ACT('MESSAGE',$target,"$sender started a new game.");
	ACT('MESSAGE','chanserv',"op $target $self");
	ACT('LITERAL',undef,"run_command>wolfstate>perl $home_folder/scripts/wolfstate.pl");
	ACT('LITERAL',undef,"send_pipe_message>wolfstate>join>$sender");
      }
    }

    if ($message =~ /^\.leave$/) {
      ACT('LITERAL',undef,"send_pipe_message>wolfstate>leave>$sender");
    }

    if ($message =~ /^\.wait$/) {
      ACT('LITERAL',undef,"send_pipe_message>wolfstate>wait>");
    }

    if ($message =~ /^\.start$/) {
      ACT('LITERAL',undef,"send_pipe_message>wolfstate>start>");
    }

    if ($message =~ /^\.lynch ([A-Za-z0-9[\]\\`_^{}|-]+)/) {
      ACT('LITERAL',undef,"send_pipe_message>wolfstate>lynch>$sender>$1");
    }

    if ($message =~ /^\.retract/) {
      ACT('LITERAL',undef,"send_pipe_message>wolfstate>retract>$sender");
    }
  }
}

sub on_private_notice { }

sub on_public_notice { }

sub on_join { }

sub on_part {
  ACT('LITERAL',undef,"send_pipe_message>wolfstate>leave>$sender");
}

sub on_quit {
  ACT('LITERAL',undef,"send_pipe_message>wolfstate>leave>$sender");
}

sub on_mode { }

sub on_nick {
  ACT('LITERAL',undef,"send_pipe_message>wolfstate>leave>$sender");
}

sub on_kick { }

sub on_server_message {
  LoadPlugin("$home_folder/plugins/basic/nick_bump.pm");
}

sub on_error {
  ACT('LITERAL',undef,"log>APIERROR>$message");
}

####-----#----- ################# -----#-----####
####-----#----- STOP EDITING HERE -----#-----####
####-----#----- ################# -----#-----####
&fire_event($event);
