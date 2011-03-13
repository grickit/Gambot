push (@commands_regexes, "$sl !literal (.+)\$");
push (@commands_subs, sub {
  (CheckAuth($sender,$hostname) == 2) ? $output = $1 : ACT("MESSAGE","$target","$sender: Who the hell do you think you are?"); ; 
});