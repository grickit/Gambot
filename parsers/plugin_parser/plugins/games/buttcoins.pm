#===== LOADING =====#
if(!$core->dictionary_exists('buttcoin:bank')) { $core->dictionary_load('buttcoin:bank'); $core->value_set('buttcoin:bank','autosave',1); }
if(!$core->dictionary_exists('buttcoin:stats')) { $core->dictionary_load('buttcoin:stats'); $core->value_set('buttcoin:stats','autosave',1); }
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

  my @word_list = ('the','that','a','and','for');
  $word_chosen = $word_list[int(rand(5))];
  $core->value_set('buttcoin:stats','word',$word_chosen);
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



#===== STATS FUNCS =====#
sub buttcoinGetStatsMined {
  return $core->value_get('buttcoin:stats','mined:'.uc($_[0]));
}

sub buttcoinTrackStatsMined {
  # If this user has no mining stats, assume they are a legacy user and set their mined buttcoins to their current balance
  if(!$core->value_get('buttcoin:stats','mined:'.uc($_[0]))) { $core->value_set('buttcoin:stats','mined:'.uc($sender),buttcoinBalanceGet($sender)); }

  $core->value_increment('buttcoin:stats','mined:'.uc($_[0]),1);
}

sub buttcoinGetStatsAbuse {
  return $core->value_get('buttcoin:stats','abuse:'.uc($_[0]));
}

sub buttcoinTrackStatsAbuse {
  if($event eq 'on_public_message'
    and $message =~ /\bthe\b/i
    and $message =~ /\bthat\b/i
    and $message =~ /\ba\b/i
    and $message =~ /\band\b/i
    and $message =~ /\bfor\b/i
  ) {
    $core->value_increment('buttcoin:stats','abuse:'.uc($sender),1);
  }
}

sub buttcoinGetStatsWordAverage {
  my $count = $core->value_get('buttcoin:stats','count:'.$_[0]);
  my $time = $core->value_get('buttcoin:stats','time:'.$_[0]);
  return ($time/$count);
}

sub buttcoinTrackStatsWordAverage {
  my $timestamp = $core->value_get('buttcoin:stats','timestamp') || time;
  $core->value_set('buttcoin:stats','timestamp',time);
  $core->value_increment('buttcoin:stats','count:'.$_[0],1);
  $core->value_increment('buttcoin:stats','time:'.$_[0],(time-$timestamp));
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

if ($event eq 'on_public_message' and $message =~ /\b$word_chosen\b/i) {
  buttcoinMine($sender);
  buttcoinTrackStatsMined($sender);
  buttcoinTrackStatsAbuse($sender);
  buttcoinTrackStatsWordAverage($word_chosen);

  my $average = buttcoinGetStatsWordAverage($word_chosen);
  actOut('DEBUG','##Gambot',"DEBUG: Buttcoin mined from \"$word_chosen\" ($average seconds average).");
}
