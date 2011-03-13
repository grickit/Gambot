push (@commands_regexes, "$sl !encode (.*)");
push (@commands_subs, sub {
  $answer = uri_escape_utf8($1,"A-Za-z0-9\0-\377") if $1; ACT("MESSAGE",$target,"$receiver: $answer"); 
});