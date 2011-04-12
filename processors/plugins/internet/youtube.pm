push (@commands_regexes, "$sl !youtube ([a-zA-Z0-9]+)");
push (@commands_subs, sub {
  my $vid = $1;
  my $url = "http://gdata.youtube.com/feeds/api/videos/$vid?v=2";
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  my $response = $request->get("$url");
  my $content = $response->decoded_content;

  if ($content =~ /<error><domain>GData<\/domain><code>InvalidRequestUriException<\/code><internalReason>Invalid id<\/internalReason><\/error>/) {
    ACT("MESSAGE",$target,"$receiver: That video does not exist.");
  }

  elsif ($content =~ /<title>(.+)<\/title>/) {
    my $title = $1;
    $content =~ /<name>(.+)<\/name>/;
    ACT("MESSAGE",$target,"$receiver: The title is \"$title\". It was uploaded by \"$1\".");

    $content =~ /<yt:statistics favoriteCount='([0-9]+)' viewCount='([0-9]+)'\/>/;
    my ($favorites, $views) = ($1, $2);
    $content =~ /<yt:rating numDislikes='([0-9]+)' numLikes='([0-9]+)'\/>/;
    my ($dislikes, $likes) = ($1, $2);
    ACT("MESSAGE",$target,"$receiver: It has $views views, $likes likes, and $dislikes dislikes.");

    $content =~ /<yt:duration seconds='([0-9]+)'\/>/;
    my $length = $1;
    my $length_m = int($length / 60);
    my $length_s = $length % 60;

    ACT("MESSAGE",$target,"$receiver: It is $length_m minutes and $length_s seconds long.");
  }

  if ($content =~ /<media:restriction type='country'/) {
    ACT("MESSAGE",$target,"$receiver: This video is unavailable in some regions.");
  }
  else {
    ACT("MESSAGE",$target,"$receiver: This video has no region restrictions.");
  }

  ACT("MESSAGE",$target,"$receiver: http://www.youtube.com/watch?v=$vid");
});