if ($message =~ /^${sl}${cm}time-local$/) {
  require POSIX;
  my $timestamp = POSIX::strftime('%H:%M:%S',localtime);
  actOut('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^${sl}${cm}time(-utc)?$/) {
  require POSIX;
  my $timestamp = POSIX::strftime('%H:%M:%S',gmtime(time));
  actOut('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^${sl}${cm}time-unix$/) {
  require POSIX;
  my $timestamp = time;
  actOut('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^${sl}${cm}time ([+-][0-9]+)$/) {
  require POSIX;
  my $offset = $1;
  my $hours = POSIX::strftime('%H',gmtime(time));
  my $minsec = POSIX::strftime('%M:%S',gmtime(time));
  $hours += $offset;
  if($hours > 23 || $hours < 0) { $hours = ($hours % 24); }
  my $timestamp = $hours.':'.$minsec;
  actOut('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^${sl}${cm}time-internet$/) {
  require POSIX;
  my @time_struct = gmtime(time);
  my $seconds_into_day = ($time_struct[2] * 3600 + $time_struct[1] * 60 + $time_struct[0] + 3600) % 86400; # + 3600 because 'BMT' = UTC+1
  $seconds_into_day = POSIX::floor($seconds_into_day); # Because printf rounds, badly
  my $timestamp = sprintf("@%03i",$seconds_into_day * 1000 / 86400);
  actOut('MESSAGE',$target,"$receiver: $timestamp");
}