package PluginParser::Staff::JoinPart;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^join $validChanStrict$/) {
    return join_order($core,$1);
  }

  elsif($core->{'message'} =~ /^part$/) {
    return part_order($core,$core->{'receiver_chan'},$core->{'sender_nick'},'leaving');
  }

  elsif($core->{'message'} =~ /^part $validChanStrict$/) {
    return part_order($core,$1,$core->{'sender_nick'},'leaving');
  }

  elsif($core->{'message'} =~ /^part $validChanStrict (.+)$/) {
    return part_order($core,$1,$core->{'sender_nick'},$2);
  }

  elsif($core->{'message'} =~ /^part (.+)$/) {
    return part_order($core,$core->{'receiver_chan'},$core->{'sender_nick'},$1);
  }

  return '';
}

sub join_order {
  my ($core,$chan) = @_;

  if($core->{'auth'}->test_sender($core,$chan)) {
    $core->{'output'}->parse("JOIN>${chan}");
  }
  else {
    $core->{'auth'}->error($core,$core->{'sender_nick'},$core->{'receiver_chan'});
  }
}

sub part_order {
  my ($core,$chan,$nick,$message) = @_;

  if($core->{'auth'}->test_sender($core,$chan)) {
    $core->{'output'}->parse("PART>${chan}>${message} [requested by ${nick}]");
  }
  else {
    $core->{'auth'}->error($core,$core->{'sender_nick'},$core->{'receiver_chan'});
  }
}