package PluginParser::Maintenance::Autojoin;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'childid'} eq 'fork10') {
    return autojoin($core,$core->{'botname'});
  }

  return '';
}

sub autojoin {
  my ($core,$botname) = @_;
  $botname =~ s/_+$//;
  my $channels = $core->value_list("channels_autojoin:${botname}");

  foreach my $channel (split(',',$channels)) {
    if($channel =~ /^$validChan$/) {
      $core->{'output'}->parse("JOIN>${channel}");
    }
  }
}
