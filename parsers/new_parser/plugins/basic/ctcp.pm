if ($message =~ /^(VERSION|CLIENTINFO).*$/) {
  actOut('NOTICE',$sender,"$1 $version");
}

if ($message =~ /^TIME.*$/) {
  require POSIX;
  actOut('NOTICE',$sender,'TIME '.POSIX::strftime('%Y-%m-%d %H:%M:%S',localtime).'');
}

if ($message =~ /^PING.*$/) {
  actOut('NOTICE',$sender,'PING '.time.'');
}

if ($message =~ /^FINGER.*$/) {
  actOut('NOTICE',$sender,"FINGER Take your fingers off me!");
}
