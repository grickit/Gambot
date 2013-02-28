if ($message =~ /^${sl}${cm}(.+)$/ && $sentOutput == 0) {
  require LWP::Simple;
  require LWP::UserAgent;
  if (($hostname !~ /\/bot\//i) && ($sender !~ /bot$/i)) {
    my $answer = $message;
    $answer =~ s/^${sl}${cm}\s*//;

    my $request = LWP::UserAgent->new;
    $request->timeout(60);
    $request->env_proxy;
    $request->agent('franbot/3.0 (Linux Mint 14; Perl 5.10)');
    my $response = $request->post('http://qmark.tk/qmai.php',{'q' => $answer});
    $answer = $response->content();

    $answer =~ s/[\r\n]+/ /g;
    if($answer) { actOut('MESSAGE',$target,"$receiver: $answer"); }
  }
}