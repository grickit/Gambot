package PluginParser::Maintenance::NickBump;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} ne 'on_server_message') { return ''; }

  if($core->{'command'} eq '433') {
    return bump($core,$core->{'botname'});
  }

  return '';
}

sub bump {
  my ($core,$botname) = @_;

  $core->{'output'}->parse("RENAME>${botname}_");
}
