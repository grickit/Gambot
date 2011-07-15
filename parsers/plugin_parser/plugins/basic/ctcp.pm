if ($message =~ /^$sl (VERSION|CLIENTINFO).*$/) {
  ACT('NOTICE',$sender,"$1 $version");
}

if ($message =~ /^$sl TIME.*$/) {
  require POSIX;
  my $timestamp = POSIX::strftime('%m-%d-%Y %H:%M:%S',localtime);
  ACT('NOTICE',$sender,"TIME $timestamp");
}

if ($message =~ /^$sl PING.*$/) {
  my $timestamp = time;
  ACT('NOTICE',$sender,"PING $timestamp");
}

if ($message =~ /^$sl FINGER.*$/) {
  ACT('NOTICE',$sender,"FINGER Take your fingers off me!");
}
