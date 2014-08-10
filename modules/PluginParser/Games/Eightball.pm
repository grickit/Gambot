package PluginParser::Games::Eightball;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^eightball (.+)\?$/) {
    return roll_eightball($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^8ball (.+)\?$/) {
    return roll_eightball($core,$core->{'receiver_chan'},$core->{'target'});
  }

  return '';
}

sub roll_eightball {
  my ($core,$chan,$target) = @_;

  my @response;
  $response[0] = 'As I see it, yes.';
  $response[1] = 'It is certain.';
  $response[2] = 'It is decidedly so.';
  $response[3] = 'Most likely.';
  $response[4] = 'Outlook good.';
  $response[5] = 'Signs point to yes.';
  $response[6] = 'Without a doubt.';
  $response[7] = 'Yes.';
  $response[8] = 'Yes — definitely.';
  $response[9] = 'You may rely on it.';
  $response[10] = 'Reply hazy. Try again.';
  $response[11] = 'Ask again later.';
  $response[12] = 'Better not tell you now.';
  $response[13] = 'Cannot predict now.';
  $response[14] = 'Concentrate and ask again.';
  $response[15] = 'Don\'t count on it.';
  $response[16] = 'My reply is no.';
  $response[17] = 'My sources say no.';
  $response[18] = 'Outlook not so good.';
  $response[19] = 'Very doubtful.';
  my $answer = $response[int(rand(19))];

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${answer}.");
}