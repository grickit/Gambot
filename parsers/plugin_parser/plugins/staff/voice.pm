if ($message =~ /^$sl !voice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","voice $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !devoice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","devoice $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !voiceme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !devoiceme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !voiceyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","voice $target $self") : AuthError($target);
}

if ($message =~ /^$sl !devoiceyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","devoice $target $self") : AuthError($target);
}

