#!/usr/bin/perl
# Copyright (C) 2010-2013 by Derek Hoagland <grickit@gmail.com>
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

### This file provides an object capable of parsing IRC received
### from Freenode.

package IRC::Freenode::Parser;
use strict;
use warnings;

use IRC::Freenode::Specifications;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub new {
  my $class = shift;
  my $self = {};

  $self->{'core'} = shift;

  bless($self,$class);
  return $self;
}

sub parse {
  my ($self,$botname,$string) = @_;
  my ($nick,$user,$host,$chan,$command,$message,$event,$redirect) = ('','','','','','','','');

  if ($string =~ /^PING :$validSenderServer$/i) {
    ($nick,$event) = ($1,'on_server_ping');
  }

  elsif($string =~ /^:$validSenderHuman (NOTICE|PRIVMSG) $validChan :(.+)$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_public_ctcp');
    if($chan eq $botname) { $event = 'on_private_ctcp'; $chan = $nick; }
  }

  elsif($string =~ /^:$validSenderHuman (PRIVMSG) $validChan :ACTION (.*)$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_public_action');
    if($chan eq $botname) { $event = 'on_private_action'; $chan = $nick; }
  }

  elsif($string =~ /^:$validSenderHuman (PRIVMSG) $validChan :(.*)$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_public_message');
    if($chan eq $botname) { $event = 'on_private_message'; $chan = $nick; }
  }

  elsif($string =~ /^:$validSenderHuman (NOTICE) $validChan :(.+)$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_public_notice');
    if($chan eq $botname) { $event = 'on_private_notice'; $chan = $nick; }
  }

  elsif($string =~ /^:$validSenderHuman (JOIN) :?$validChan$/) {
    ($nick,$user,$host,$chan,$command,$event) = ($1,$2,$3,$5,$4,'on_join');
  }

  elsif ($string =~ /^:$validSenderHuman (PART) $validChan ?:?(.+)?$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_part');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (QUIT) ?:?(.+)?$/) {
    ($nick,$user,$host,$command,$message,$event) = ($1,$2,$3,$4,$5,'on_quit');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (MODE) $validChan :?(.+)$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_user_mode');
  }

  elsif ($string =~ /^:$validSenderHuman (NICK) :?$validNick$/) {
    ($nick,$user,$host,$command,$message,$event) = ($1,$2,$3,$4,$5,'on_nick');
  }

  elsif ($string =~ /^:$validSenderHuman (KICK) $validChan ?:?(.+)?$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$5,$4,$6,'on_kick');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (TOPIC) $validChan ?:?(.+)?$/) {
    ($nick,$user,$host,$chan,$command,$message,$event) = ($1,$2,$3,$4,$5,$6,'on_topic');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validNick = $validChan :?(.+)$/) {
    ($nick,$chan,$command,$message,$event) = ($1,$4,$2,$5,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validChan :?(.+)$/) {
    ($nick,$chan,$command,$message,$event) = ($1,$3,$2,$4,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validNick $validChan :?(.+)$/) {
    ($nick,$chan,$command,$message,$event) = ($1,$4,$2,$5,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^ERROR :(.+)$/) {
    ($message) = ($1);
    $event = 'on_server_error';
  }

  else {
    $self->{'core'}->log_error('IRC message did not match parser.');
    $self->{'core'}->log_error($string);
    return '';
  }

  return ($nick,$user,$host,$chan,$command,$message,$event,$redirect);
}

1;