if (($event eq 'public_message') && ($message =~ /^$sl (.+)$/) && !(&have_output())) {
  require LWP::UserAgent;
  if (($hostname !~ /\/bot\//i) && ($sender !~ /bot$/i)) {
    my $answer = $message;
    $answer =~ s/$sl\s+//;
    $answer = uri_escape($answer);
    my $url = "http://aesoft.org/qmark/qmai.php?q=$answer";
    $url =~ s/%0D/ /;
    $url =~ s/%20$//;

    my $request = LWP::UserAgent->new;
    $request->timeout(60);
    $request->env_proxy;
    $request->agent('gambot');
    my $response = $request->get($url);
    $answer = $response->decoded_content;

    $answer =~ s/[\r\n]+/ /g;
    ($answer) ? ACT('MESSAGE',$target,"$receiver: $answer") : ACT('LITERAL',undef,"error>QMarkAPI failed to load $url");
  }
}
