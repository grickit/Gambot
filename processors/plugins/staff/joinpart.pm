push (@commands_regexes, "$sl !join ([$valid_chan_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("JOIN",$1) : Error($1);
});

push (@commands_regexes, "$sl !part ([$valid_chan_characters]+) ?(.+)?\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("PART",$1,$2) : Error($1);
});