package PluginParser::Maintenance::Autojoin;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;


  if($core->{'forkid'} == 10) {
    return autojoin($core,$core->{'botname'});
  }


  return '';
}

sub autojoin {
  my ($core,$botname) = @_;
  $botname =~ s/_+$//;
  my $channel_list = $core->value_list("${botname}:channels_autojoin");

  foreach my $current_channel (split(',',$channel_list)) {
    if($current_channel =~ /^$validChanStrict$/) {
      $core->{'output'}->parse("JOIN>${current_channel}");
    }
  }
}
