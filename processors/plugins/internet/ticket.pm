push (@commands_regexes, "$sl !ticket ([0-9]+)");
push (@commands_helps, "!ticket - Links to project's support tickets.");
push (@commands_subs, sub {
  $answer = $1; 
  ACT("MESSAGE",$target,"http://trac.unknown-horizons.org/t/ticket/$answer") if ($target =~ /#unknown-horizons/); 
  ACT("MESSAGE",$target,"https://github.com/grickit/Gambot/issues#issue/$answer") if ($target =~ /##Gambot/);
  ACT("MESSAGE",$target,"https://gna.org/bugs/index.php?$answer") if ($target =~ /#wesnoth/);
});