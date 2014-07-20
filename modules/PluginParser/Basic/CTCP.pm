package PluginParser::Basic::CTCP;
use strict;
use warnings;
use POSIX;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} ne 'on_private_ctcp') { return ''; }

  if($core->{'message'} =~ /^VERSION$/i) {
    return ctcp_clientinfo($core,$core->{'chan'},'VERSION');
  }
  elsif($core->{'message'} =~ /^CLIENTINFO$/i) {
    return ctcp_clientinfo($core,$core->{'chan'},'CLIENTINFO');
  }
  elsif($core->{'message'} =~ /^TIME$/i) {
    return ctcp_time($core,$core->{'chan'});
  }
  elsif($core->{'message'} =~ /^PING ([0-9]+)$/i) {
    return ctcp_pong($core,$core->{'chan'},$1);
  }
  elsif($core->{'message'} =~ /^FINGER$/i) {
    return ctcp_finger($core,$core->{'chan'});
  }

  return '';
}

sub ctcp_clientinfo {
  my ($core,$chan,$command) = @_;

  $core->{'output'}->parse("CTCP>${chan}>${command} Gambot PluginParser");
}

sub ctcp_time {
  my ($core,$chan) = @_;
  my $time = POSIX::strftime('%Y-%m-%d %H:%M:%S',localtime);

  $core->{'output'}->parse("CTCP>${chan}>TIME ${time}");
}

sub ctcp_pong {
  my ($core,$chan,$time) = @_;

  $core->{'output'}->parse("CTCP>${chan}>PING ${time}");
}

sub ctcp_finger {
  my ($core,$chan) = @_;
  my $time = time;

  $core->{'output'}->parse("CTCP>${chan}>FINGER Take your fingers off me!");
}