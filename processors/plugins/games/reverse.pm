push (@commands_regexes, "$sl !reverse (.+)");
push (@commands_helps, "!reverse - Reverses a string");
push (@commands_subs, sub {
  $answer = scalar reverse($1);
  ACT("MESSAGE","$target","$receiver: $answer"); 
});