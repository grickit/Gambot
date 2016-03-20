package PluginParser::Maintenance::PersistentNick;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'forkid'} % 20 == 0) {
    return keepnick($core);
  }

  return '';
}

sub keepnick {
  my ($core) = @_;
  my $current = $core->{'botname'};
  my $target = $core->value_get('config', 'base_nick');
  if ($current ne $target) {
    $core->{'output'}->parse("RENAME>${target}");
  }
}
