push (@commands_regexes, "$sl !voice ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","voice $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !devoice ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","devoice $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !voiceme\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $receiver") : Error($target);
});

push (@commands_regexes, "$sl !devoiceme\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $receiver") : Error($target); 
});

push (@commands_regexes, "$sl !voiceyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $self") : Error($target);
});

push (@commands_regexes, "$sl !devoiceyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $self") : Error($target);
});