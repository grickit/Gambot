if ($message =~ /^${sl}${cm}roulette$/i) {
  actOut('LITERAL',undef,'value_get>roulette>'.$target.'chamber');
  my $chamber = readInput();

  if (!$chamber) {
    actOut('MESSAGE',$target,'Starting new game of Russian Roulette for this channel.');
    $chamber = int(rand(6))+1;
    actOut('LITERAL',undef,'value_set>roulette>'.$target.'chamber>'.$chamber);
    actOut('LITERAL',undef,'value_set>roulette>'.$target.'index>0');
  }

  actOut('LITERAL',undef,'return value_increment>roulette>'.$target.'index>1');
  my $index = readInput();

  actOut('MESSAGE',$target,"Pulling the trigger on chamber $index.");
  if ($chamber eq $index) {
    actOut('MESSAGE',$target,"BANG! $sender is dead.");
    actOut('LITERAL',undef,'value_set>roulette>'.$target.'chamber>0');
    actOut('LITERAL',undef,'value_set>roulette>'.$target.'index>0');
  }
  else { actOut('MESSAGE',$target,"Click. $sender lives this time."); }
}
