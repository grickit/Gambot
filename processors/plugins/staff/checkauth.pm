push (@commands_regexes, "$sl !checkme\$");
push (@commands_subs, sub {
  $answer = CheckAuth($target,$hostname);
  ACT("MESSAGE",$target,"$sender: Authorization of $hostname in $target is $answer.");
});

push (@commands_regexes, "$sl !check (.+) ([$valid_chan_characters]+)\$");
push (@commands_subs, sub {
  $answer = CheckAuth($1,$2);
  ACT("MESSAGE",$target,"$sender: Authorization of $1 in $2 is $answer.");
});