#This plugin must be the last one loaded if used.
push (@commands_regexes, "$sl (.+)\$");
push (@commands_subs, sub {
  require LWP::Simple;
  if (($hostname !~ /\/bot\//i) && ($sender !~ /bot$/i) && !($output)) {
    $answer = "$message";
    $answer =~ s/$sl( +)//;
    $answer = uri_escape($answer);
    my $url = "http://aesoft.org/qmark/qmai.php?q=$answer";
    $url =~ s/%0D/ /;
    $url =~ s/%20$//;
    $answer = get $url;
    $answer =~ s/\n/ /;
    ($answer) ? ACT("MESSAGE",$target,"$receiver: $answer") : ACT("MESSAGE",$target,"Gambit: Couldn't get the page ^^^");
  }
});