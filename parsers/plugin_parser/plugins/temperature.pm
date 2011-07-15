if ($message =~ /^$sl !ftc (-?[0-9]*.*[0-9]*)$/) {
  my $answer = (5/9) * ($1 - 32);
  ACT('MESSAGE',$target,"$receiver: $answer°C");
}

if ($message =~ /^$sl !ctf (-?[0-9]*.*[0-9]*)$/) {
  my $answer = (9/5) * $1 + 32;
  ACT('MESSAGE',$target,"$receiver: $answer°F");
}
