if ($message =~ /^${sl}${cm}roulette$/i) {
  my $chamber = $core->value_get('roulette',$target.':chamber');

  if (!$chamber) {
    actOut('MESSAGE',$target,'Starting new game of Russian Roulette for this channel.');
    $chamber = int(rand(6))+1;
    $core->value_set('roulette',$target.':chamber',$chamber);
    $core->value_set('roulette',$target.':index',0);
  }

  my $index = $core->value_increment('roulette',$target.':index',1);

  actOut('MESSAGE',$target,"Pulling the trigger on chamber $index.");
  if ($chamber eq $index) {
    actOut('MESSAGE',$target,"BANG! $sender is dead.");
    $core->value_set('roulette',$target.':chamber',0);
    $core->value_set('roulette',$target.':index',0);
  }
  else { actOut('MESSAGE',$target,"Click. $sender lives this time."); }
}
