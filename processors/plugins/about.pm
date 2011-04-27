if (($event =~ /message/) && ($message =~ /^$sl !?about$/)) {
  ACT('MESSAGE',$target,"$receiver: $about"); 
}
