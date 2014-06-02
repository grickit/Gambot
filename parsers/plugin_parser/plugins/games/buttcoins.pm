if(!$core->dictionary_exists('buttcoin:bank')) { $core->dictionary_load('buttcoin:bank'); }
if(!$core->dictionary_exists('buttcoin:stats')) { $core->dictionary_load('buttcoin:stats'); }

my $word_chosen = $core->value_get('buttcoin:stats','word');
$word_chosen = 'the' unless $word_chosen;

if ($message =~ /^${sl}${cm}buttcoin balance ?($validNick)?$/i) {
  my $check = $2;
  $check = $sender unless $check;
  my $check_backend = uc($check);

  my $balance = $core->value_get('buttcoin:bank','balance:'.$check_backend,1);
  $balance = 0 unless $balance;

  actOut('MESSAGE',$target,"$check"."'s balance is $balance buttcoins.");
}

if ($message =~ /^${sl}${cm}buttcoin transfer ([0-9]+) ($validNick)$/i) {
  my $value = $1;
  my $receiver = $2;
  my $sender_backend = uc($sender);
  my $receiver_backend = uc($receiver);

  my $sender_balance = $core->value_get('buttcoin:bank','balance:'.$sender_backend);
  $sender_balance = 0 unless $sender_balance;

  if($sender_balance < $value) {
    actOut('MESSAGE',$target,"$sender only has $sender_balance buttcoins.");
  }
  else {
    $core->value_decrement('buttcoin:bank','balance:'.$sender_backend,$value);
    $core->value_increment('buttcoin:bank','balance:'.$receiver_backend,$value);
    actOut('MESSAGE',$target,"$sender transferred $value buttcoins to $receiver.");
  }
}

if ($message =~ /\b$word_chosen\b/i and $event eq 'on_public_message') {
  my $timestamp = $core->value_get('buttcoin:stats','timestamp');
  $timestamp = time unless $timestamp;
  my $difference = (time-$timestamp);

  my $count = $core->value_increment('buttcoin:stats','count:'.$word_chosen,1);
  my $time = $core->value_increment('buttcoin:stats','time:'.$word_chosen,$difference);
  my $average = ($time/$count);

  my $sender_backend = uc($sender);

  my $sender_censored = $sender;
  $sender_censored =~ s/[aeiou]/*/ig;
  my $target_censored = $target;
  $target_censored =~ s/[#aeiou]/*/ig;

  $core->value_increment('buttcoin:bank','balance:'.$sender_backend,1);

  actOut('DEBUG','##Gambot',"DEBUG: $sender_censored just earned a buttcoin in $target_censored. The word was \"$word_chosen\" and took $difference seconds (word average is $average).");

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
  $core->value_set('buttcoin:stats','word',$word_chosen);
  $core->value_set('buttcoin:stats','timestamp',time);
}

$core->dictionary_save('buttcoin:bank');
$core->dictionary_save('buttcoin:stats');