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

### This file provides an object for connecting to and interacting
### with an IRC server.

package Gambot::ServerIRC;
use strict;
use warnings;
use IO::Socket;

use Gambot::IO;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw();

sub new {
  my $class = shift;
  my $self = {};

  $self->{'core'} = shift;
  $self->{'connection'} = '';
  $self->{'status'} = 'later';
  $self->{'pending_outgoing_messages'} = ();

  bless($self,$class);
  return $self;
}

sub connect {
  my ($self) = @_;
  my $addr = $self->{'core'}->value_get('config','server');
  my $port = $self->{'core'}->value_get('config','port');
  my $nick = $self->{'core'}->value_get('core','nick');
  my $pass = $self->{'core'}->value_get('config','password');

  $self->{'core'}->log_event('Connecting to IRC.');

  $self->{'core'}->value_set('ircserver','IRC_messages_received_this_connection',0);
  $self->{'core'}->value_set('ircserver','last_received_IRC_message_time',time);
  $self->{'connection'} = new IO::Socket::INET(
    PeerAddr => $addr,
    PeerPort => $port,
    Proto => 'tcp',
    timeout => 1
  );

  if($self->{'connection'}) {
    $self->{'core'}->log_event('Logging in to IRC.');
    my $connection = ${$self->{'connection'}};
    print $connection "PASS $nick:$pass\015\012" if($pass);
    print $connection "NICK $nick\015\012";
    print $connection "USER Gambot 8 * :Perl Gambot\015\012";
    return 1;
  }

  $self->{'core'}->log_event('Error while connecting to IRC.');
  return '';
}

sub disconnect {
  my ($self) = @_;

  if($self->{'connection'}) {
    $self->{'core'}->log_event('Disconnecting from IRC.');
    $self->{'connection'}->close();
    return 1;
  }

  $self->{'core'}->log_event('Error wihle disconnecting from IRC.');
  return '';
}

sub read {
  my ($self) = @_;
  my @received_IRC_messages;

  my $status = pipe_status('ircserver',$self->{'connection'});

  ## irc connection died
  if($status eq 'dead') {
    $self->{'core'}->log_error('IRC connection died.');

    if($self->{'core'}->value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { # Otherwise automatically reconnect
      $self->disconnect();
      $self->connect();
    }
  }

  ## irc connection timed out
  elsif($status eq 'later' && time - $self->{'core'}->value_get('ircserver','last_received_IRC_message_time') >= $self->{'core'}->value_get('config','ping_timeout')) {
    $self->{'core'}->log_error('IRC connection timed out.');

    if($self->{'core'}->value_get('core','staydead')) { exit; } # Exit if the bot was started with --staydead
    else { # Otherwise automatically reconnect
      $self->disconnect();
      $self->connect();
    }
  }

  ## irc connection has content
  elsif($status eq 'ready') {
    @received_IRC_messages = pipe_multiread('ircserver',$self->{'connection'},$status);
  }

  return @received_IRC_messages;
}

sub send {
  my ($self,$message) = @_;

  push(@{$self->{'pending_outgoing_messages'}},$message);
  return 1;
}

sub spool {
  my ($self) = @_;

  while(my $current_pending_IRC_message = shift(@{$self->{'pending_outgoing_messages'}})) {
    my $IRC_messages_sent_this_second = $self->{'core'}->value_get('ircserver','IRC_messages_sent_this_second');
    my $messages_per_second = $self->{'core'}->value_get('config','messages_per_second');

    if($IRC_messages_sent_this_second < $messages_per_second) {
      $self->{'core'}->log_debug('Sent '.$IRC_messages_sent_this_second.'/'.$messages_per_second.' messages so far during '.time);
      $self->{'core'}->log_normal('OUTGOING',$current_pending_IRC_message);

      my $write_pipe = $self->{'connection'};
      print $write_pipe $current_pending_IRC_message."\015\012";

      $self->{'core'}->value_increment('ircserver','IRC_messages_sent_this_second',1);
    }
    else {
      unshift(@{$self->{'pending_outgoing_messages'}},$current_pending_IRC_message);
      last;
    }
  }

  ## Keep track of how many messages we've sent to the IRC server this second
  if($self->{'core'}->value_get('ircserver','last_sent_IRC_message_time') != time) {
    $self->{'core'}->value_set('ircserver','IRC_messages_sent_this_second',0);
    $self->{'core'}->value_set('ircserver','last_sent_IRC_message_time',time);
  }
  return 1;
}

1;