package PluginParser::Games::Memes;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^yuno (.+)$/i) {
    return yuno($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^Ausmerica$/i) {
    return ausmerica($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^Nikon$/i) {
    return nikon($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^Bep$/i) {
    return bep($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^What is love\?$/i) {
    return haddaway($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^dolan$/i) {
    return dolan($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^gooby$/i) {
    return gooby($core,$core->{'receiver_chan'},$core->{'target'});
  }


  return '';
}

sub yuno {
  my ($core,$chan,$target,$string) = @_;
  my $sender = $core->{'sender_nick'};
  $string =~ s/\bme\b/${sender}/;

  $string = uc($string);
  $target = uc($target);

  $core->{'output'}->parse("MESSAGE>${chan}>${target}! ლ(ಠ益ಠლ) Y U NO ${string}?");
}

sub ausmerica {
  my ($core,$chan,$target) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: Lemon lemon lemon lemon lemon lemon lemon lemon. http://i.imgur.com/5C4Gi.png");
}

sub nikon {
  my ($core,$chan,$target) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: http://i.imgur.com/nikon.png");
}

sub bep {
  my ($core,$chan,$target) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ADD &BEP COMMAND NAO it go here http://i.imgur.com/BEPSY.png");
}

sub haddaway {
  my ($core,$chan,$target) = @_;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: Baby don't hurt me. Don't hurt me. No more.");
}

sub memeify_names {
  my $target = shift;

  $target =~ s/\s//g;
  my @targets = split(/[,]+?/,$target);
  my $delim = '';
  my $string = '';
  foreach my $gooby (@targets) {
    my @letters = split(//,$gooby);
    my $name = shift(@letters);
    my $last_letter = pop @letters;
    while(@letters) {
      $name .= splice(@letters,rand @letters,1);
    }
    $string .= $delim.$name.$last_letter;
    $delim = ' and ';
  }

  return $string;
}

sub dolan {
  my ($core,$chan,$target) = @_;

  $target = memeify_names($target);

  $core->{'output'}->parse("MESSAGE>${chan}>fak u ${target}");
}

sub gooby {
  my ($core,$chan,$target) = @_;

  $target = memeify_names($target);

  $core->{'output'}->parse("MESSAGE>${chan}>${target} pls");
}
