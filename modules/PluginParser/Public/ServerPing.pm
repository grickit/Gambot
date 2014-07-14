#!/usr/bin/perl
package PluginParser::Public::ServerPing;
use strict;
use warnings;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw();
our @EXPORT_OK = qw(
  match
);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} eq 'on_server_ping') {
    return pong($core,$core->{'nick'});
  }

  return '';
}

sub pong {
  my ($core,$nick) = @_;

  $core->{'output'}->parse("LITERAL>server_send>PONG ${nick}");
}

1;
