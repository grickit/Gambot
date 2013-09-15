if ($message =~ /^${sl}${cm}d([0-9]+)$/i) {
  my $answer = int(rand($1))+1;
  actOut('MESSAGE',$target,"$receiver: The roll is $answer");
}

if ($message =~ /^${sl}${cm}([0-9]+)d([0-9]+)$/) {
  my $answer = int(rand($1*$2-$1))+$1;
  actOut('MESSAGE',$target,"$receiver: The total is $answer");
}
