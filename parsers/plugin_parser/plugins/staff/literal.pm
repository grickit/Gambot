if ($message =~ /^$sl !literal (.+)$/) {
  if($message =~ /run_command>/) {
    ACT('MESSAGE',$target,"$sender: Sorry. Not even administrators may use the run_command API call. It's just too dangerous.");
  }
  else {
    if (CheckAdmin()) {
      ACT('LITERAL',undef,$1);
    }
    else {
      ACT('MESSAGE',$target,"$sender: Who the hell do you think you are?");
    }
  }
}
