push (@commands_regexes, "$sl !?about");
push (@commands_subs, sub {
  ACT("MESSAGE",$target,"$receiver: $about"); 
});