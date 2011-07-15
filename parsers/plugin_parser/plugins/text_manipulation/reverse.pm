if ($message =~ /^$sl !reverse (.+)$/) {
  my $string = scalar reverse($1);
  ACT('MESSAGE',$target,"$receiver: $string");
}
