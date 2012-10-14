if($message =~ /^\+o $botName/) {
  actOut('LITERAL',undef,"event_fire>op$target");
}