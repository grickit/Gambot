push (@commands_regexes, "$sl !?version");
push (@commands_helps, "version - Displays the bot's version information.");
push (@commands_subs, sub { 
    ACT("MESSAGE",$target,"$receiver: $version"); 
});
