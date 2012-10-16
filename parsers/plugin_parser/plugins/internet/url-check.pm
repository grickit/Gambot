if ($message =~ /^${sl}${cm}(http:\/\/(.+))$/i) {
  require LWP::Simple;
  require LWP::UserAgent;
  my $url = $1;
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $response = $request->get("$url");
  my $content = $response->decoded_content;
  if ($content =~ /<title>((\n|\s|\r|\t|.)+)<\/title>/) { my $answer="$1"; $answer=~s/(\n|\s|\r|\t)+/ /g; actOut('MESSAGE',"$target","$receiver: title: $answer"); }
  elsif (defined $content) { actOut('MESSAGE',"$target","$receiver: It doesn't look like that page has a title."); }
  else { actOut('MESSAGE',$target,"$receiver: I can't get that page for some reason."); }
}
