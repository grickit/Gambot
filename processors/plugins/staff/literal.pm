if (($event =~ /message/) && ($message =~ /^$sl !literal (.+)$/)) {
  if($message =~ /start_script>/) {
    ACT("MESSAGE",$target,"$sender: Sorry. Not even administrators may use the start_script API call. It's just too dangerous.");
  }
  else {
    (CheckAuth($sender,$hostname) == 2) ? ACT("LITERAL",'',"$1") : ACT("MESSAGE",$target,"$sender: Who the hell do you think you are?");
  }
}
