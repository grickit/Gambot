if (($event =~ /message/) && ($message =~ /^$sl !quiet ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","quiet $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !unquiet ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !quietme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $receiver") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !unquietme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $receiver") : Error($target); 
}

if (($event =~ /message/) && ($message =~ /^$sl !quietyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $self") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !unquietyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $self") : Error($target);
}
