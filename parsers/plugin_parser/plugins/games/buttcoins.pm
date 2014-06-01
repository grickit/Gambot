if ($message =~ /^${sl}${cm}buttcoin balance ?($validNick)?$/i) {
  my $check = $2;
  $check = $sender unless $check;

  my $balance = $core->value_get('buttcoins','balance:'.$check,1);
  $balance = 0 unless $balance;

  actOut('MESSAGE',$target,"$check"."'s balance is $balance buttcoins.");
}

if ($message =~ /^${sl}${cm}buttcoin transfer ([0-9]+) ($validNick)$/i) {
  my $value = $1;
  my $receiver = $2;

  my $sender_balance = $core->value_get('buttcoins','balance:'.$sender);
  $sender_balance = 0 unless $sender_balance;

  if($sender_balance < $value) {
    actOut('MESSAGE',$target,"$sender only has $sender_balance buttcoins.");
  }
  else {
    $core->value_decrement('buttcoins','balance:'.$sender,$value);
    $core->value_increment('buttcoins','balance:'.$receiver,$value);
    actOut('MESSAGE',$target,"$sender transferred $value buttcoins to $receiver.");
  }
}

my $word_chosen = $core->value_get('buttcoins','word');
$word_chosen = 'the' unless $word_chosen;

if ($message =~ /\b$word_chosen\b/i) {
  $core->value_increment('buttcoins','balance:'.$sender,1);

  my @word_list;
  $word_list[0] = 'the';
  $word_list[1] = 'this';
  $word_list[2] = 'that';
  $word_list[3] = 'a';
  $word_list[4] = 'an';
  $word_list[5] = 'and';
  $word_list[6] = 'but';
  $word_list[7] = 'or';
  $word_list[8] = 'for';
  $word_list[9] = 'so';
  $word_chosen = $word_list[int(rand(10))];
  $core->value_set('buttcoins','word',$word_chosen);
  actOut('MESSAGE','##Gambot',"$sender just earned a buttcoin in $target.");
}