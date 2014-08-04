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
  my ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ('','','','','','','','');

  if ($string =~ /^(PING) :$validSenderServer$/i) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($2,$2,$2,$botname,'',$1,'','on_server_ping');
  }

  elsif($string =~ /^:$validSenderHuman (NOTICE|PRIVMSG) $validChan :(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_public_ctcp');
    if($receiver_chan eq $botname) { ($receiver_nick,$receiver_chan,$event) = ($botname,$sender_nick,'on_private_ctcp'); }
  }

  elsif($string =~ /^:$validSenderHuman (PRIVMSG) $validChan :ACTION (.*)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_public_action');
    if($receiver_chan eq $botname) { ($receiver_nick,$receiver_chan,$event) = ($botname,$sender_nick,'on_private_action'); }
  }

  elsif($string =~ /^:$validSenderHuman (PRIVMSG) $validChan :(.*)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_public_message');
    if($receiver_chan eq $botname) { ($receiver_nick,$receiver_chan,$event) = ($botname,$sender_nick,'on_private_message'); }
  }

  elsif($string =~ /^:$validSenderHuman (NOTICE) $validChan :(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_public_notice');
    if($receiver_chan eq $botname) { ($receiver_nick,$receiver_chan,$event) = ($botname,$sender_nick,'on_private_notice'); }
  }

  elsif($string =~ /^:$validSenderHuman (JOIN) $validChan$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,'','on_join');
  }

  elsif ($string =~ /^:$validSenderHuman (PART) $validChan ?:?(.+)?$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_part');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (QUIT) ?:?(.+)?$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'','',$4,$5,'on_quit');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (MODE) $validChan :?(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_mode');
  }

  elsif ($string =~ /^:$validNick (MODE) $validNick :?(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,'','','',$3,'',$4,'on_user_mode');
  }

  elsif ($string =~ /^:$validSenderHuman (NICK) :?$validNick$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,$5,'',$4,'','on_nick');
  }

  elsif ($string =~ /^:$validSenderHuman (KICK) $validChan $validNick ?:?(.+)?$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,$6,$5,$4,$7,'on_kick');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderHuman (TOPIC) $validChan ?:?(.+)?$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$2,$3,'',$5,$4,$6,'on_topic');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validNick = $validChan :?(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$1,$1,$3,$4,$2,$5,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validChan :?(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$1,$1,$3,'',$2,$4,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^:$validSenderServer ([a-zA-Z0-9]+) $validNick $validChan :?(.+)$/) {
    ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event) = ($1,$1,$1,$3,$4,$2,$5,'on_server_message');
    $message = '' unless $message;
  }

  elsif ($string =~ /^ERROR :(.+)$/) {
    ($message) = ($1);
    $event = 'on_server_error';
  }

  else {
    $self->{'core'}->log_error('IRC message did not match parser.');
    $self->{'core'}->log_error($string);
  }

  return ($sender_nick,$sender_user,$sender_host,$receiver_nick,$receiver_chan,$command,$message,$event);
}

1;