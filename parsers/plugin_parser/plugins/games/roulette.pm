if ($message =~ /^$sl !roulette$/) {
  ACT('LITERAL',undef,'value_get>roulette>'.$target.'chamber');
  my $chamber = <STDIN>;
  $chamber =~ s/[\r\n\t\s]+$//;

  if (!$chamber) {
    ACT('MESSAGE',$target,'Starting new game of Russian Roulette for this channel.');
    $chamber = int(rand(6))+1;
    ACT('LITERAL',undef,'value_set>roulette>'.$target.'chamber>'.$chamber);
    ACT('LITERAL',undef,'value_set>roulette>'.$target.'index>0');
  }

  ACT('LITERAL',undef,'return value_increment>roulette>'.$target.'index>1');
  my $index = <STDIN>;
  $index =~ s/[\r\n\t\s]+$//;

  ACT('MESSAGE',$target,"Pulling the trigger on chamber $index.");
  if ($chamber eq $index) {
    ACT('MESSAGE',$target,"BANG! $sender is dead.");
    ACT('LITERAL',undef,'value_set>roulette>'.$target.'chamber>0');
    ACT('LITERAL',undef,'value_set>roulette>'.$target.'index>0');
  }
  else { ACT('MESSAGE',$target,"Click. $sender lives this time."); }
}
