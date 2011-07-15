if ($message =~ /^$sl !quiet ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","quiet $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !unquiet ([$valid_chan_characters]+) ([$valid_nick_characters]+)$/) {
  CheckAuth($1,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $1 $2") : AuthError($1);
}

if ($message =~ /^$sl !quietme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !unquietme$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $receiver") : AuthError($target);
}

if ($message =~ /^$sl !quietyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","quiet $target $self") : AuthError($target);
}

if ($message =~ /^$sl !unquietyou$/) {
  CheckAuth($target,$hostname) ? ACT("MESSAGE","Chanserv","unquiet $target $self") : AuthError($target);
}

