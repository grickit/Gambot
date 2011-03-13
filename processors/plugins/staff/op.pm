push (@commands_regexes, "$sl !op ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","op $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !deop ([$valid_chan_characters]+) ([$valid_name_characters]+)\$");
push (@commands_subs, sub {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","deop $1 $2") : Error($1); 
});

push (@commands_regexes, "$sl !opme\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $receiver") : Error($target);
});

push (@commands_regexes, "$sl !deopme\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $receiver") : Error($target); 
});

push (@commands_regexes, "$sl !opyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $self") : Error($target);
});

push (@commands_regexes, "$sl !deopyou\$");
push (@commands_subs, sub {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $self") : Error($target);
});