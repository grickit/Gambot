if ($message =~ /^$sl !voice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT('MESSAGE','chanserv',"voice $1 $2") : AuthError($sender,$target,$1);
}

if ($message =~ /^$sl !devoice ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT('MESSAGE','chanserv',"devoice $1 $2") : AuthError($sender,$target,$1);
}

if ($message =~ /^$sl !voiceme$/) {
  CheckAuth($target,$hostname) ? ACT('MESSAGE','chanserv',"voice $target $receiver") : AuthError($sender,$target,$target);
}

if ($message =~ /^$sl !devoiceme$/) {
  CheckAuth($target,$hostname) ? ACT('MESSAGE','chanserv',"devoice $target $receiver") : AuthError($sender,$target,$target);
}

if ($message =~ /^$sl !voiceyou$/) {
  CheckAuth($target,$hostname) ? ACT('MESSAGE','chanserv',"voice $target $self") : AuthError($sender,$target,$target);
}

if ($message =~ /^$sl !devoiceyou$/) {
  CheckAuth($target,$hostname) ? ACT('MESSAGE','chanserv',"devoice $target $self") : AuthError($sender,$target,$target);
}

