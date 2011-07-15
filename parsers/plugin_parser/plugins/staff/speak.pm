if ($message =~ /^$sl !tell ([$valid_chan_characters]+) (.+)$/) {
  CheckAuth($1,$hostname) ? ACT('MESSAGE',$1,$2) : AuthError($1);
}

if ($message =~ /^$sl !do ([$valid_chan_characters]+) (.+)$/) {
  CheckAuth($1,$hostname) ? ACT('ACTION',$1,$2) : AuthError($1);
}

if ($message =~ /^$sl !notify ([$valid_chan_characters]+) (.+)$/) {
  CheckAuth($1,$hostname) ? ACT('NOTICE',$1,$2) : AuthError($1);
}