if ($message =~ /^$sl !?about$/) {
  ACT('MESSAGE',$target,"$receiver: $about");
}
