#===== LOADING =====#
if(!$core->dictionary_exists('buttcoin:bank')) { $core->dictionary_load('buttcoin:bank'); }
if(!$core->dictionary_exists('buttcoin:stats')) { $core->dictionary_load('buttcoin:stats'); }
my $word_chosen = $core->value_get('buttcoin:stats','word') || 'the';



#===== BASIC FUNCS =====#
sub buttcoinAccountCheck {
  return $core->value_get('buttcoin:stats','active:'.uc($_[0])) || 0;
}

sub buttcoinAccountActivate {
  return $core->value_set('buttcoin:stats','active:'.uc($_[0]),1);
}

sub buttcoinBalanceGet {
  return $core->value_get('buttcoin:bank','balance:'.uc($_[0])) || 0;
}

sub buttcoinBalanceAdd {
  return $core->value_increment('buttcoin:bank','balance:'.uc($_[0]),$_[1]);
}

sub buttcoinBalanceSub {
  return $core->value_decrement('buttcoin:bank','balance:'.uc($_[0]),$_[1]);
}



#===== COMPLEX FUNCS =====#
sub buttcoinMine {
  $core->value_increment('buttcoin:bank','balance:'.uc($_[0]),1);
  $core->value_increment('buttcoin:stats','mined:'.uc($_[0]),1);

  my @word_list = ('the','that','a','and','for');
  $word_chosen = $word_list[int(rand(5))];
  $core->value_set('buttcoin:stats','word',$word_chosen);
  $core->value_set('buttcoin:stats','timestamp',time);
}

sub buttcoinTransfer {
  my $receiver = $_[0];
  my $value = $_[1];
  my $sender_balance = buttcoinBalanceGet($sender);

  if(!buttcoinAccountCheck($receiver)) { actOut('MESSAGE',$target,"$receiver\'s account is not active."); return 0; }
  if($sender_balance < $value) { actOut('MESSAGE',$target,"$sender only has $sender_balance buttcoins."); return 0; }

  buttcoinBalanceSub($sender,$value);
  buttcoinBalanceAdd($receiver,$value);
  actOut('MESSAGE',$target,"$sender transferred $value buttcoins to $receiver.");
}

sub buttcoinBalance {
  my $receiver = $_[0] || $sender;

  my $balance = buttcoinBalanceGet($receiver);
  my $active = (buttcoinAccountCheck($receiver) ? 'active' : 'inactive');

  actOut('MESSAGE',$target,"$receiver has $balance buttcoins (account $active).");
}



#===== COMMANDS =====#
if ($message =~ /^${sl}${cm}buttcoin balance ?($validNick)?$/i) {
  buttcoinAccountActivate($sender);
  buttcoinBalance($1);
}

if ($message =~ /^${sl}${cm}buttcoin transfer ([0-9]+) ($validNick)$/i) {
  buttcoinAccountActivate($sender);
  buttcoinTransfer($2,$1);
}

if ($message =~ /\b$word_chosen\b/i and $event eq 'on_public_message') {
  my $timestamp = $core->value_get('buttcoin:stats','timestamp') || time;
  my $difference = (time-$timestamp);

  my $count = $core->value_increment('buttcoin:stats','count:'.$word_chosen,1);
  my $time = $core->value_increment('buttcoin:stats','time:'.$word_chosen,$difference);
  my $average = ($time/$count);

  actOut('DEBUG','##Gambot',"DEBUG: Buttcoin mined from \"$word_chosen\".");

  buttcoinMine($sender);
}



#===== EXIT =====#
$core->dictionary_save('buttcoin:bank');
$core->dictionary_save('buttcoin:stats');