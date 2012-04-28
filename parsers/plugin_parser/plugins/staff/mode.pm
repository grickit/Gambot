if($message =~ /^\+o $self$/) {
  ACT('LITERAL',undef,"fire_event>op$target");
}