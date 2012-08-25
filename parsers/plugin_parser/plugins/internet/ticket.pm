if ($message =~ /^$sl !ticket ([0-9]+)$/) {
  require LWP::Simple;
  require LWP::UserAgent;
  my ($ticket,$url) = ($1,0)
  #$answer = "http://trac.unknown-horizons.org/t/ticket/$answer" if ($target =~ /#unknown-horizons/);
  $url = "https://github.com/unknown-horizons/unknown-horizons/issues/$ticket" if ($target =~ /#unknown-horizons/);
  $url = "https://github.com/grickit/Gambot/issues#issue/$ticket" if ($target =~ /##Gambot/);
  $url = "https://gna.org/bugs/index.php?$ticket" if ($target =~ /#wesnoth/);

  my $request = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0});;
  $request->timeout(120);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->parse_head(0);
  my $response = $request->get($url);
  my $content = $response->decoded_content;
  if ($content =~ /<title>((\n|\s|\r|\t|.)+)<\/title>/) {
    $answer = $1;
    $answer=~s/(\n|\s|\r|\t)+/ /g;
    ACT('MESSAGE',$target,"$receiver: $answer [ $url ]");
  }
  else { ACT('MESSAGE',$target,"$sender: There was a problem getting that ticket."); }

}
