if(!$core->dictionary_exists('buttcoins')) {
  $core->dictionary_load('buttcoins');
}

my $word_chosen = $core->value_get('buttcoins','word');
$word_chosen = 'the' unless $word_chosen;

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

if ($message =~ /\b$word_chosen\b/i and $event eq 'on_public_message') {
  $core->value_increment('buttcoins','balance:'.$sender,1);
  my $timestamp = $core->value_get('buttcoins','timestamp');
  $timestamp = time unless $timestamp;
  my $difference = (time-$timestamp);

  my $count = $core->value_increment('buttcoins','count:'.$word_chosen,1);
  my $time = $core->value_increment('buttcoins','time:'.$word_chosen,$difference);
  my $average = ($time/$count);

  my $sender_censored = $sender;
  $sender_censored =~ s/[aeiou]/*/ig;

  actOut('DEBUG','##Gambot',"DEBUG: $sender_censored just earned a buttcoin in $target. The word was \"$word_chosen\" and took $difference seconds (word average is $average).");

  my @word_list;
  push(@word_list,'the');
 #push(@word_list,'this');
  push(@word_list,'that');
  push(@word_list,'a');
 #push(@word_list,'an');
  push(@word_list,'and');
 #push(@word_list,'but');
 #push(@word_list,'or');
  push(@word_list,'for');
 #push(@word_list,'so');

  $word_chosen = $word_list[int(rand(5))];
  $core->value_set('buttcoins','word',$word_chosen);
  $core->value_set('buttcoins','timestamp',time);
}

$core->dictionary_save('buttcoins');