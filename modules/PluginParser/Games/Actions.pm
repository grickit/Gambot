package PluginParser::Games::Actions;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  my $botname = $core->{'botname'};
  if($core->{'event'} ne 'on_public_action' and $core->{'event'} ne 'on_private_action') { return ''; }


  if($core->{'message'} =~ /^slaps ${botname} around a bit/) {
    return act_nineties($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^(hugs|loves|pats|pets) ${botname}/) {
    return act_love($core,$core->{'receiver_chan'});
  }

  elsif($core->{'message'} =~ /^slaps ${botname}/) {
    return act_slapped($core,$core->{'receiver_chan'});
  }

  elsif($core->{'message'} =~ /^(murders|kills|stabs) ${botname}/) {
    return act_death($core,$core->{'receiver_chan'});
  }

  elsif($core->{'message'} =~ /^(kisses|licks) ${botname}/) {
    return act_police($core,$core->{'receiver_chan'});
  }


  return '';
}

sub act_nineties {
  my ($core,$chan,$target) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: The 90s called. They want their IRC client back.");
}

sub act_love {
  my ($core,$chan) = @_;

  $core->{'output'}->parse("ACTION>${chan}>♥");
}

sub act_slapped {
  my ($core,$chan) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>I may have deserved that.");
}

sub act_death {
  my ($core,$chan) = @_;

  $core->{'output'}->parse("ACTION>${chan}>dies. RIPIP in peace.");
}


sub police {
  my ($core,$chan) = @_;

  $core->{'output'}->parse("ACTION>${chan}>calls the police.");
}
