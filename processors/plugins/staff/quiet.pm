push (@commands_regexes, "$sl !quiet ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","quiet $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !unquiet ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !quietme\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $receiver") : Error($target);
});

push (@commands_regexes, "$sl !unquiet\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $receiver") : Error($target); 
});

push (@commands_regexes, "$sl !quietyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $self") : Error($target);
});

push (@commands_regexes, "$sl !unquietyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $self") : Error($target);
});