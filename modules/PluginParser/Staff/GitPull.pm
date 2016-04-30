package PluginParser::Staff::GitPull;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^gitpull$/) {
    return git_pull($core);
  }

  return '';
}

sub git_pull {
  my ($core,$chan) = @_;
  if(!$core->{'auth'}->test_sender($core,'global_staff')) { $core->{'auth'}->error($core,'global_staff'); return ''; }

  my $home_directory = $core->value_get('core','home_directory');
  $core->child_add('gitpull',"git pull ${home_directory} 1>&2 ");
}

