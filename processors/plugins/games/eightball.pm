push (@commands_regexes, "$sl !(8|eightball) (.+)");
push (@commands_helps, "!eightball - Predicts the future!");
push (@commands_subs, sub {
  my @response;
  $response[0] = "As I see it, yes.";
  $response[1] = "It is certain.";
  $response[2] = "It is decidedly so.";
  $response[3] = "Most likely.";
  $response[4] = "Outlook good.";
  $response[5] = "Signs point to yes.";
  $response[6] = "Without a doubt.";
  $response[7] = "Yes.";
  $response[8] = "Yes — definitely.";
  $response[9] = "You may rely on it.";
  $response[10] = "Reply hazy. Try again.";
  $response[11] = "Ask again later.";
  $response[12] = "Better not tell you now.";
  $response[13] = "Cannot predict now.";
  $response[14] = "Concentrate and ask again.";
  $response[15] = "Don't count on it.";
  $response[16] = "My reply is no.";
  $response[17] = "My sources say no.";
  $response[18] = "Outlook not so good.";
  $response[19] = "Very doubtful.";
  $answer = int(rand(19));
  $answer = $response[$answer];

  ACT("MESSAGE","$target","$receiver: $answer"); 
});