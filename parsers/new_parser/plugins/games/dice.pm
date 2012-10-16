if ($message =~ /^${sl}${cm}d([0-9]+)$/i) {
  my $answer = int(rand($1))+1;
  actOut('MESSAGE',$target,"$receiver: The roll is $answer");
}

if ($message =~ /^${sl}${cm}([0-9]+)d([0-9]+)$/) {
  if ($1 <= 9000) {
    my ($i, $rand, $answer) = (0,0,0);
    while($i < $1) {
      $rand = int(rand($2))+1;
      $answer += $rand;
      $i += 1;
      #actOut('MESSAGE',"$target","$receiver: roll $i yielded $rand");
    }
    actOut('MESSAGE',$target,"$receiver: The total is $answer");
  }
  else {
    actOut('MESSAGE',$target,"Help! $sender is trying to attack me! Their power level is OVER NINE THOUSAND!");
  }
}
