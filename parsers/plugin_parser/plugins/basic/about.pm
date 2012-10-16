if ($message =~ /^${sl}${cm}about$/i) {
  actOut('MESSAGE',$target,"$receiver: $about");
}

if ($message =~ /^${sl}${cm}version$/i) {
  actOut('MESSAGE',$target,"$receiver: $version");
}
