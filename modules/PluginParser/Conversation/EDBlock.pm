package PluginParser::Conversation::EDBlock;
use strict;
use warnings;
use POSIX;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  #http://encyclopediadramatica.ch/Accidentally
  if($core->{'message'} =~ /encyclopediadramatica\.[a-z]{2,3}+/i) {
    return shout($core,$core->{'chan'},uc($core->{'nick'}));
  }

  return '';
}

sub shout {
  my ($core,$chan,$nick) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>NOBODY TOUCH THAT LINK FROM ${nick}");
}