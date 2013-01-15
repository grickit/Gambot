if ($message =~ /^ACTION ([a-zA-Z]+) $botName$/i) {
  if ($1 =~ /^kicks$/i) {
    actOut('ACTION',$target,"kicks $sender");
  }
  elsif ($1 =~ /^hugs$/) {
    actOut('ACTION',$target,"♥");
  }
  elsif ($1 =~ /^kisses$/) {
    actOut('ACTION',$target,'calls the police');
  }
  elsif ($1 =~ /^slaps$/) {
    actOut('MESSAGE',$target,'I may have deserved that.');
  }
  elsif ($1 =~ /^murders$/) {
    actOut('ACTION',$target,'dies... I guess?');
  }
}

if ($message =~ /^ACTION slaps $botName around a bit with a large trout$/) {
  actOut('MESSAGE',$target,"$receiver: The 90's called. They want their IRC client back.");
}