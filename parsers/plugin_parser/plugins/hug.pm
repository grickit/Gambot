if ($message =~ /^${sl}${cm}hug (.+)$/i) {
  my $person = $1;
  $person =~ s/\bme\b/$sender/;
  actOut('ACTION',$target,"hugs $person");
}
