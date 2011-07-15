if ($message =~ /^$sl !op ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","op $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !deop ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","deop $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !opme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !deopme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !opyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","op $target $self") : AuthError($target);
}

if ($message =~ /^$sl !deopyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","deop $target $self") : AuthError($target);
}
