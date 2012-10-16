if ($message =~ /^(VERSION|CLIENTINFO).*$/i) {
  actOut('NOTICE',$sender,"$1 $version");
}

if ($message =~ /^TIME.*$/i) {
  require POSIX;
  actOut('NOTICE',$sender,'TIME '.POSIX::strftime('%Y-%m-%d %H:%M:%S',localtime).'');
}

if ($message =~ /^PING.*$/i) {
  actOut('NOTICE',$sender,'PING '.time.'');
}

if ($message =~ /^FINGER.*$/i) {
  actOut('NOTICE',$sender,"FINGER Take your fingers off me!");
}
