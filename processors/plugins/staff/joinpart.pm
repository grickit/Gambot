if (($event =~ /message/) && ($message =~ /^$sl !join ([$valid_chan_characters]+)$/)) {
  CheckAuth($1,$hostname) ? ACT("JOIN",$1) : Error($1);
}

if (($event =~ /message/) && ($message =~ /^$sl !part ([$valid_chan_characters]+) ?(.+)?$/)) {
  CheckAuth($1,$hostname) ? ACT("PART",$1,$2) : Error($1);
}
