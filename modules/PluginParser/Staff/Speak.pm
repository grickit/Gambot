package PluginParser::Staff::Speak;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^tell $validChanStrict (.+)$/) {
    return order_message($core,$1,$2);
  }
 
  elsif($core->{'message'} =~ /^act $validChanStrict (.+)$/) {
    return order_act($core,$1,$2);
  }

  elsif($core->{'message'} =~ /^notify $validChanStrict (.+)$/) {
    return order_notice($core,$1,$2);
  }

  return '';
}

sub order_message {
  my ($core,$chan,$message) = @_;
  if(!$core->{'auth'}->test_sender($core,$chan)) { $core->{'auth'}->error($core,$chan); return ''; }

  $core->{'output'}->parse("MESSAGE>${chan}>${message}");
}

sub order_act {
  my ($core,$chan,$message) = @_;
  if(!$core->{'auth'}->test_sender($core,$chan)) { $core->{'auth'}->error($core,$chan); return ''; }

  $core->{'output'}->parse("ACTION>${chan}>${message}");
}

sub order_notice {
  my ($core,$chan,$message) = @_;
  if(!$core->{'auth'}->test_sender($core,$chan)) { $core->{'auth'}->error($core,$chan); return ''; }

  $core->{'output'}->parse("NOTICE>${chan}>${message}");
}
