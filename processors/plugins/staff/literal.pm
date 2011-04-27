if (($event =~ /message/) && ($message =~ /^$sl !literal (.+)$/)) {
  (CheckAuth($sender,$hostname) == 2) ? ACT("LITERAL",'',"$1") : ACT("MESSAGE",$target,"$sender: Who the hell do you think you are?"); 
}
