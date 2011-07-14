if (($event =~ /message/) && ($message =~ /^ACTION (.+) $self$/)) {
  if ($1 eq 'kicks') {
    ACT('ACTION',$target,"kicks $sender");
  }
  elsif ($1 eq 'hugs') {
    ACT('ACTION',$target,"♥");
  }
  elsif ($1 eq 'kisses') {
    ACT('ACTION',$target,"calls the police");
  }
  elsif ($1 eq 'slaps') {
    ACT('MESSAGE',$target,"I may have deserved that.");
  }
  elsif ($1 eq 'murders') {
    ACT('ACTION',$target,"dies... I guess?");
  }
}
