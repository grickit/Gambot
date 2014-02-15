if ($message =~ /\b(bitch|cunt)+/i) {
  my @response;
  $response[0] = "I'm so edgy and cool. I use slurs like \"$1\".";
  $response[1] = "Look at me. I use grown-up words like \"$1\" even though I'm only 12.";
  $response[2] = "I say \"$1\". I'm so fuckin hardcore. Pay attention to me.";
  $response[3] = "My 12 year old vocabulary contains very few words, but at least I can say \"$1\".";
  $response[4] = "EVERYONE LOOK AT ME! I said \"$1\"! Am I cool now?";
  my $answer = int(rand(5));
  $answer = $response[$answer];

  actOut('MESSAGE',$target,"<$sender> $answer");
}