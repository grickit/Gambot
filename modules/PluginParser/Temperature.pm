package PluginParser::Temperature;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^ftc (-?[0-9]*\.?[0-9]*)$/) {
    return ftc($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^ctf (-?[0-9]*\.?[0-9]*)$/) {
    return ctf($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^convert (-?[0-9]*\.?[0-9]*)°F$/) {
    return ftc($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^convert (-?[0-9]*\.?[0-9]*)°C$/) {
    return ctf($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^convert (-?[0-9]*\.?[0-9]*)F$/) {
    return ftc($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^convert (-?[0-9]*\.?[0-9]*)C$/) {
    return ctf($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }


  return '';
}

sub ftc {
  my ($core,$chan,$target,$temperature) = @_;
  $temperature = sprintf("%.2f",(5/9) * ($temperature - 32));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${temperature}°C");
}

sub ctf {
  my ($core,$chan,$target,$temperature) = @_;
  $temperature = sprintf("%.2f",(9/5) * $temperature + 32);

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${temperature}°F");
}
