if($message =~ /^\+o $botName/i) {
  actOut('LITERAL',undef,"event_fire>op:$target");
}