if (($event =~ /message/) && ($message =~ /^$sl !voice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","voice $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !devoice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","devoice $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !voiceme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $receiver") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !devoiceme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $receiver") : Error($target); 
}

if (($event =~ /message/) && ($message =~ /^$sl !voiceyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $self") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !devoiceyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $self") : Error($target);
}
