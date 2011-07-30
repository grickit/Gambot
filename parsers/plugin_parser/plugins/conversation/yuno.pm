if ($message =~ /^$sl !yuno (.+)$/) {
  my $yuno = uc $1;
  $receiver = uc $receiver;
  ACT('MESSAGE',$target,"$receiver! ლ(ಠ益ಠლ) Y U NO $yuno?");
}
