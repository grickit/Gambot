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
# along with Gambot. If not, see <http://www.gnu.org/licenses/>.

### This file provides an object capable of producing valid IRC
### output for Freenode as parsed from an easy GAPIL-like language.

package IRC::Freenode::AuthBasic;
use strict;
use warnings;

use IRC::Freenode::Specifications;
use Gambot::GAPIL::CommandChild;

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

sub test_sender {
  my ($self,$core,$chan) = @_;

  my $botname = $core->{'botname'};
  $botname =~ s/_+$//;

  my $auth_list = $core->value_get("${botname}:channels_permissions",lc($chan));
  my $admin_list = $core->value_get('config','global_staff');
  foreach my $current_auth (split(',',$admin_list),split(',',$auth_list)) {
    $current_auth =~ s/\./\./;
    $current_auth =~ s/\*/.*/;
    if($current_auth =~ /^N:$validNick$/ and $core->{'sender_nick'} =~ /^$1$/) { return 1; }
    elsif($current_auth =~ /^U:$validUser$/ and $core->{'sender_user'} =~ /^$1$/) { return 1; }
    elsif($current_auth =~ /^H:$validHost$/ and $core->{'sender_host'} =~ /^$1$/) { return 1; }
  }

  return '';
}

sub error {
  my ($self,$core,$chan) = @_;
  my ($sender_nick,$receiver_chan) = ($core->{'sender_nick'},$core->{'receiver_chan'});

  $core->{'output'}->parse("MESSAGE>${receiver_chan}>${sender_nick}: You are not authorized as staff in ${chan}.");
}

1;