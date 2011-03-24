push (@commands_regexes, "$sl !?kiss (.+)");
push (@commands_subs, sub {
  $answer = $1; 
  if ($answer =~ /\bme\b/i) {
    if (CheckAuth($sender,$hostname) == 2) {
      ACT("ACTION",$target,"hugs $sender instead");
    }
    else {
      ACT("ACTION",$target,"slaps $sender");
    }
  }
  else {
    ACT("MESSAGE",$target,"No offense to $answer, but no thanks.");
  }
});