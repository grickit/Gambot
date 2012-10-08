if ($message =~ /^${sl}${cm}hug (.+)$/) {
  my $person = $1;
  $person =~ s/\bme\b/$sender/;
  actOut('ACTION',$target,"hugs $person");
}
