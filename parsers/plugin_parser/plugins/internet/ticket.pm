if ($message =~ /^${sl}${cm}ticket #?([0-9]+)$/i) {
  require LWP::Simple;
  require LWP::UserAgent;
  my $ticket = $1;
  my $url = '';
  #$answer = "http://trac.unknown-horizons.org/t/ticket/$answer" if ($target =~ /#unknown-horizons/);
  $url = "https://github.com/unknown-horizons/unknown-horizons/issues/$ticket" if ($target =~ /#unknown-horizons/);
  $url = "https://github.com/grickit/Gambot/issues/$ticket" if ($target =~ /##Gambot/);
  $url = "https://gna.org/bugs/index.php?$ticket" if ($target =~ /#wesnoth/);
  $url = "https://mojang.atlassian.net/browse/MC-$ticket" if ($target =~ /#minecraft/);
  $url = "https://github.com/frogatto/frogatto/issues/$ticket" if ($target =~ /#frogatto/);
  $url = "https://github.com/FreezingMoon/AncientBeast/issues/$ticket" if ($target =~ /#AncientBeast/);

  my $request = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0});
  $request->timeout(120);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->parse_head(0);
  my $response = $request->get($url);
  my $content = $response->decoded_content;
  if ($content =~ /<title>((\n|\s|\r|\t|.)+)<\/title>/) {
    my $answer = $1;
    $answer =~ s/(\n|\s|\r|\t)+/ /g;
    actOut('MESSAGE',$target,"$receiver: $answer [ $url ]");
  }
  else { actOut('MESSAGE',$target,"$sender: There was a problem getting that ticket."); }

}
