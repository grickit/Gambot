package PluginParser::Basic::Hug;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^hug (.+)$/) {
    return hug($core,$core->{'receiver_chan'},$1);
  }

  return '';
}

sub hug {
  my ($core,$chan,$string) = @_;
  my $sender = $core->{'sender_nick'};
  $string =~ s/\bme\b/${sender}/;

  $core->{'output'}->parse("ACTION>${chan}>hugs ${string}");
}
