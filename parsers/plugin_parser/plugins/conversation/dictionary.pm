if ($message =~ /^$sl !define ([a-zA-Z0-9_#-]+)$/) {
  my $word = $1;
  my $upper = uc $word;

  ACT('LITERAL',undef,"check_persistence_domain_exists>dictionary");
  my $dictloaded = <STDIN>;
  $dictloaded =~ s/[\r\n\t\s]+$//;
  if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>dictionary"); }

  ACT('LITERAL',undef,"get_persistent_value>dictionary>$upper");
  my $definition = <STDIN>;
  $definition =~ s/[\r\n\t\s]+$//;
  if ($definition) {
    ACT('MESSAGE',$target,"$receiver: $word means: $definition");
  }
  else {
    ACT('MESSAGE',$target,"$receiver: No definition found for $word.");
  }
}

if ($message =~ /^$sl !set-define ([a-zA-Z0-9_#-]+) (.+)$/) {
  my $word = uc $1;
  my $definition = $2;

  ACT('LITERAL',undef,"check_persistence_domain_exists>dictionary");
  my $dictloaded = <STDIN>;
  $dictloaded =~ s/[\r\n\t\s]+$//;
  if (!$dictloaded) { ACT('LITERAL',undef,"load_persistence_file>dictionary"); }

  ACT('LITERAL',undef,"set_persistent_value>dictionary>$word>$definition");
  ACT('MESSAGE',$target,"$receiver: Done.");
}
