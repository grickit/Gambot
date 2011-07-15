require POSIX;

if ($message =~ /^$sl !time-local$/) {
    my $timestamp = POSIX::strftime('%H:%M:%S',localtime);
    ACT('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^$sl !time-utc$/) {
  my $timestamp = POSIX::strftime('%H:%M:%S',gmtime(time));
  ACT('MESSAGE',$target,"$receiver: $timestamp");
}

if ($message =~ /^$sl !time-internet$/) {
  my @time_struct = gmtime(time);
  my $seconds_into_day = ($time_struct[2] * 3600 + $time_struct[1] * 60 + $time_struct[0] + 3600) % 86400; # + 3600 because 'BMT' = UTC+1
  $seconds_into_day = POSIX::floor($seconds_into_day); # Because printf rounds, badly
  my $timestamp = sprintf("@%03i",$seconds_into_day * 1000 / 86400);
  ACT('MESSAGE',$target,"$receiver: $timestamp");
}
