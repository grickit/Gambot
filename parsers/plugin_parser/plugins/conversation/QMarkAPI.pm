if (($event eq 'public_message') && ($message =~ /^$sl (.+)$/) && !(&have_output())) {
  require LWP::Simple;
  if (($hostname !~ /\/bot\//i) && ($sender !~ /bot$/i)) {
    my $answer = $message;
    $answer =~ s/$sl( +)//;
    $answer = uri_escape($answer);
    my $url = "http://aesoft.org/qmark/qmai.php?q=$answer";
    $url =~ s/%0D/ /;
    $url =~ s/%20$//;
    $answer = LWP::Simple::get $url;
    $answer =~ s/\n/ /;
    ($answer) ? ACT('MESSAGE',$target,"$receiver: $answer") : ACT('LITERAL',undef,'error>QMarkAPI failed to load $url');
  }
}
