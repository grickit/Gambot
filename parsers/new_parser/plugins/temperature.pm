if ($message =~ /^${sl}${cm}ftc (-?[0-9]*.*[0-9]*)$/) {
  my $answer = (5/9) * ($1 - 32);
  actOut('MESSAGE',$target,"$receiver: $answer°C");
}

if ($message =~ /^${sl}${cm}ctf (-?[0-9]*.*[0-9]*)$/) {
  my $answer = (9/5) * $1 + 32;
  actOut('MESSAGE',$target,"$receiver: $answer°F");
}
