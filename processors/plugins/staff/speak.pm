push (@commands_regexes, "$sl !tell ([$valid_chan_characters]+) (.+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE",$1,$2) : Error($1); 
});

push (@commands_regexes, "$sl !do ([$valid_chan_characters]+) (.+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("ACTION",$1,$2) : Error($1);
});

push (@commands_regexes, "$sl !notify ([$valid_chan_characters]+) (.+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("NOTICE",$1,$2) : Error($1);
});