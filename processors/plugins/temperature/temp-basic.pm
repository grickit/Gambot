push (@commands_regexes, "$sl !ftc (-?[0-9]*.*[0-9]*)");
push (@commands_subs, sub { 
  $answer = (5/9) * ($1 - 32); ACT("MESSAGE","$target","$receiver: $answer°C"); 
});

push (@commands_regexes, "$sl !ctf (-?[0-9]*.*[0-9]*)");
push (@commands_subs, sub { 
  $answer = (9/5) * $1 + 32 ; ACT("MESSAGE","$target","$receiver: $answer°F"); 
});
