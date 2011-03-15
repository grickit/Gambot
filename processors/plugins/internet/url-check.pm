push (@commands_regexes, "$sl (http:\/\/(.+))\$");
push (@commands_subs, sub {
  my $url = $1;
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  my $response = $request->get("$url");
  my $content = $response->decoded_content;
  if ($content =~ /<title>((\n|\s|\r|\t|.)+)<\/title>/) { $answer="$1"; $answer=~s/(\n|\s|\r|\t)+/ /g; ACT("MESSAGE","$target","$receiver: title: $answer"); }
  elsif (defined $content) { ACT("MESSAGE","$target","$receiver: It doesn't look like that page has a title."); }
  else { ACT("MESSAGE",$target,"$receiver: I can't get that page for some reason."); }
});