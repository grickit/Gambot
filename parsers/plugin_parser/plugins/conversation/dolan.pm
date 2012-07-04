if ($message =~ /^$sl !dolan$/) {
  $receiver =~ s/\s//g;
  my @receivers = split(/[,]+?/,$receiver);
  my $delim = '';
  my $answer = '';
  foreach my $gooby (@receivers) {
    my @letters = split(//,$gooby);
    my $name = shift(@letters);
    my $last_letter = pop @letters;
    while(@letters) {
      $name .= splice(@letters,rand @letters,1);
    }
    $answer .= $delim.$name.$last_letter;
    $delim = ', ';
  }
  ACT('MESSAGE',$target,"fak u $answer");
}

if ($message =~ /^$sl !gooby$/) {
  $receiver =~ s/\s//g;
  my @receivers = split(/[,]+?/,$receiver);
  my $delim = '';
  my $answer = '';
  foreach my $gooby (@receivers) {
    my @letters = split(//,$gooby);
    my $name = shift(@letters);
    my $last_letter = pop @letters;
    while(@letters) {
      $name .= splice(@letters,rand @letters,1);
    }
    $answer .= $delim.$name.$last_letter;
    $delim = ', ';
  }
  ACT('MESSAGE',$target,"$answer pls");
}
