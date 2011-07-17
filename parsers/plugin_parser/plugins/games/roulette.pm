if ($message =~ /^$sl !roulette$/) {
  ACT('LITERAL',undef,'get_variable_value>roulette'.$target.'chamber');
  my $chamber = <STDIN>;
  $chamber =~ s/[\r\n\t\s]+$//;

  if ($chamber <= 1) {
    ACT('MESSAGE',$target,'Starting new game of Russian Roulette for this channel.');
    $chamber = int(rand(6))+1;
    ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>'.$chamber);
    ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');
  }

  ACT('LITERAL',undef,'get_variable_value>roulette'.$target.'index');
  my $index = <STDIN>;
  $index =~ s/[\r\n\t\s]+$//;

  my $chamberstring = $index;
  if ($chamber == $index) {
    ACT('MESSAGE',$target,"Chamber number $chamberstring. BANG! $sender is dead.");
    ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'chamber>1');
    ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>1');
  }
  else {
    ACT('MESSAGE',$target,"Chamber number $chamberstring. Click. $sender lives this time.");
    $index++;
    ACT('LITERAL',undef,'set_variable_value>roulette'.$target.'index>'.$index);
  }
}
