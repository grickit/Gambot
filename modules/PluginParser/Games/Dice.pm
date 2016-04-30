package PluginParser::Games::Dice;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^d([0-9]+)$/) {
    return roll_dice($core,$core->{'receiver_chan'},$core->{'target'},$1,1);
  }

  elsif($core->{'message'} =~ /^([0-9]{1,4})d([0-9]+)$/) {
    return roll_dice($core,$core->{'receiver_chan'},$core->{'target'},$2,$1);
  }


  return '';
}

sub roll_dice {
  my ($core,$chan,$target,$size,$number) = @_;
  
  my $total = 0;
  for(my $rolls = 0; $rolls < $number; $rolls++) {
    $total += int(rand($size))+1;
  }

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: Rolled ${number} d${size} dice and got ${total}.");
}
