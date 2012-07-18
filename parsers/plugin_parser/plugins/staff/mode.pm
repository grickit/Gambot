if($message =~ /^\+o $self$/) {
  ACT('LITERAL',undef,"event_fire>op$target");
}