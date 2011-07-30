if ($message =~ /^$sl !yuno (.+)$/) {
  my $yuno = uc $1;
  $receiver = uc $receiver;
  ACT('MESSAGE',$target,"$receiver! (ოಠ益ಠ)ო Y U NO $yuno?");
}
