if ($message =~ /^$sl !checkme$/) {
  ACT('MESSAGE',$target,"$sender: Authorization of $hostname in $target is ".&CheckAuth($target,$hostname).".");
}

if ($message =~ /^$sl !check (.+) ([$valid_chan_characters]+)$/) {
  ACT('MESSAGE',$target,"$sender: Authorization of $1 in $2 is ".&CheckAuth($2,$1).".");
}
