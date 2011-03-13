push (@commands_regexes, "$sl !?about");
push (@commands_helps, "about - Displays information about the bot.");
push (@commands_subs, sub {
  ACT("MESSAGE",$target,"$receiver: $about"); 
});