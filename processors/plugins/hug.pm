push (@commands_regexes, "$sl !?hug (.+)");
push (@commands_helps, "hug - Hugs someone.");
push (@commands_subs, sub {
  $answer = $1; 
  $answer =~ s/\bme\b/$sender/; 
  ACT("ACTION",$target,"hugs $answer"); 
});