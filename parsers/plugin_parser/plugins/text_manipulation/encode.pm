if ($message =~ /^$sl !encode (.*)$/) {
  my $string = uri_escape_utf8($1,"A-Za-z0-9\0-\377") if $1;
  ACT('MESSAGE',$target,"$receiver: $string");
}

if ($message =~ /^$sl !decode (.*)$/) {
  my $string = uri_unescape($1,"A-Za-z0-9\0-\377") if $1;
  ACT('MESSAGE',$target,"$receiver: $string");
}