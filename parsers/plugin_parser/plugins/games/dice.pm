if ($message =~ /^$sl !d([0-9]+)$/) {
  my $answer = int(rand($1))+1;
  ACT('MESSAGE',"$target","$receiver: The roll is $answer");
}


if ($message =~ /^$sl !([0-9]+)d([0-9]+)$/) {
  if ($1 <= 9000) {
    my ($i, $rand, $answer) = (0,0,0);
    while($i < $1) {
      $rand = int(rand($2))+1;
      $answer += $rand;
      $i += 1;
      #ACT('MESSAGE',"$target","$receiver: roll $i yielded $rand");
    }
    ACT('MESSAGE',$target,"$receiver: The total is $answer");
  }
  else {
    ACT('MESSAGE',$target,"Help! $sender is trying to attack me! Their power level is OVER NINE THOUSAND!");
  }
}
