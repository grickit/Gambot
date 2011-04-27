if (($event eq 'private_message') && ($message =~ /^$sl (VERSION|CLIENTINFO).*$/)) {
  ACT('NOTICE',$sender,"$1 $version"); 
}

if (($event eq 'private_message') && ($message =~ /^$sl TIME.*$/)) {
  require POSIX;
  my $timestamp = POSIX::strftime('%m-%d-%Y %H:%M:%S',localtime); 
  ACT('NOTICE',$sender,"TIME $timestamp");
}

if (($event eq 'private_message') && ($message =~ /^$sl PING.*$/)) {
  my $timestamp = time; 
  ACT('NOTICE',$sender,"PING $timestamp"); 
}

if (($event eq 'private_message') && ($message =~ /^$sl FINGER.*$/)) {
  ACT('NOTICE',$sender,"FINGER Take your fingers off me!"); 
}
