if (($event =~ /message/) && ($message =~ /^$sl !?hug (.+)$/)) {
  my $person = $1; 
  $person =~ s/\bme\b/$sender/; 
  ACT('ACTION',$target,"hugs $person"); 
}
