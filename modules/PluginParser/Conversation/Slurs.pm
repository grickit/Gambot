package PluginParser::Conversation::Slurs;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /\b(bitch|cunt)/i) {
    return shout($core,$core->{'receiver_chan'},$core->{'sender_nick'},$1);
  }

  return '';
}

sub shout {
  my ($core,$chan,$nick,$word) = @_;

  my @response;
  $response[0] = "I'm so edgy and cool. I use slurs like \"${word}\".";
  $response[1] = "Look at me. I use grown-up words like \"${word}\" even though I'm only 12.";
  $response[2] = "I say \"${word}\". I'm so fuckin hardcore. Pay attention to me.";
  $response[3] = "My 12 year old vocabulary contains very few words, but at least I can say \"${word}\".";
  $response[4] = "EVERYONE LOOK AT ME! I said \"${word}\"! Am I cool now?";
  my $answer = $response[int(rand(5))];

  $core->{'output'}->parse("MESSAGE>${chan}><${nick}> $answer");
}