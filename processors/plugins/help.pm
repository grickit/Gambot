push (@commands_regexes, "$sl !?help");
push (@commands_subs, sub { 
    if ($command ne 'PRIVMSG') {
      ACT("MESSAGE",$target,"$receiver: Can you ask me again in private? The help is rather long and spams the channel."); 
    }
    else {
      foreach my $current_help (@commands_helps) {
	ACT("NOTICE",$target,"$current_help\n"); 
      }
    }
});
