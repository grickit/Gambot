if (($event =~ /message/) && ($message =~ /^$sl !op ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","op $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !deop ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","deop $1 $2") : Error($1); 
}

if (($event =~ /message/) && ($message =~ /^$sl !opme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $receiver") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !deopme$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $receiver") : Error($target); 
}

if (($event =~ /message/) && ($message =~ /^$sl !opyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $self") : Error($target);
}

if (($event =~ /message/) && ($message =~ /^$sl !deopyou$/)) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $self") : Error($target);
}
