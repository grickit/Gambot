package PluginParser::Basic::About;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^about$/) {
    return info_about($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^version$/) {
    return info_version($core,$core->{'receiver_chan'},$core->{'target'});
  }


  return '';
}

sub info_about {
  my ($core,$chan,$target) = @_;
  my $about = $core->{'about'};

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${about}");
}

sub info_version {
  my ($core,$chan,$target) = @_;
  my $version = $core->{'version'};

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${version}");
}
