if ($message =~ /^${sl}${cm}about$/) {
  actOut('MESSAGE',$target,"$receiver: $about");
}

if ($message =~ /^${sl}${cm}version$/) {
  actOut('MESSAGE',$target,"$receiver: $version");
}
