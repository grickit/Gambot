push (@commands_regexes, "$sl !d([0-9]+)");
push (@commands_helps, "!d - Rolls virtual dice.");
push (@commands_subs, sub {
  $answer = int(rand($1))+1;
  ACT("MESSAGE","$target","$receiver: $answer"); 
});

push (@commands_regexes, "$sl !([0-9]+)d([0-9]+)");
push (@commands_subs, sub {
  my ($i, $rand);
  while($i < $1) {
  $rand = int(rand($1))+1;
  $answer += $rand;
  $i += 1;
  #ACT("MESSAGE","$target","$receiver: roll $i yielded $rand\n"); 
  }
  ACT("MESSAGE",$target,"$receiver: The total is $answer"); 
});