package PluginParser::Basic::About;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if(!$core->{'pinged'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^about$/) {
    return about($core,$core->{'chan'});
  }
  elsif($core->{'message'} =~ /^version$/) {
    return version($core,$core->{'chan'});
  }

  return '';
}

sub about {
  my ($core,$chan) = @_;
  my $about = $core->{'about'};

  $core->{'output'}->parse("MESSAGE>${chan}>${about}");
}

sub version {
  my ($core,$chan) = @_;
  my $version = $core->{'version'};

  $core->{'output'}->parse("MESSAGE>${chan}>${version}");
}
