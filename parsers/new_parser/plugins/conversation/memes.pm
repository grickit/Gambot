if ($message =~ /^${sl}${cm}yuno (.+)$/i) {
  actOut('MESSAGE',$target,uc($receiver).'! ლ(ಠ益ಠლ) Y U NO '.uc($1).'?');
}

if ($message =~ /^${sl}${cm}dolan$/i) {
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
  actOut('MESSAGE',$target,"fak u $answer");
}

if ($message =~ /^${sl}${cm}gooby$/i) {
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
  actOut('MESSAGE',$target,"$answer pls");
}

if ($message =~ /^${sl}${cm}Ausmerica$/i) {
  actOut('MESSAGE',$target,"$receiver: Lemon lemon lemon lemon lemon lemon lemon lemon. http://i.imgur.com/5C4Gi.png");
}