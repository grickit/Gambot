push (@commands_regexes, "$sl !?version");
push (@commands_subs, sub { 
    ACT("MESSAGE",$target,"$receiver: $version"); 
});
