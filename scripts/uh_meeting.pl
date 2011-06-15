use strict;
use warnings;

$| = 1;

while(defined sleep(1)) {
  my ($sec,$min,$hour,undef,undef,undef,$wday,undef,undef) = gmtime(time);
  $hour = sprintf ("%02d", $hour);
  $min = sprintf ("%02d", $min);
  $sec = sprintf ("%02d", $sec);
  my @days = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

  if (($wday < 6) && ($wday > 0) && ($hour == 17) && ($min == 0)) {
    print "send>PRIVMSG #unknown-horizons :Don't forget about the meeting \x02Sunday\x02 at \x0217:00 UTC\x02! It is currently $hour:$min UTC on $days[$wday].\n";
  }

  elsif (($wday == 6) && (($hour == 12) || ($hour == 14) || ($hour == 16) || ($hour == 18) || ($hour == 20) || ($hour == 22)) && ($min == 0)) {
    print "send>PRIVMSG #unknown-horizons :Don't forget about the meeting \x02tomorrrow\x02 at \x0217:00 UTC\x02! It is currently $hour:$min UTC.\n";
  }

  elsif (($wday == 0) && ($hour < 16) && ($min == 0)) {
    my $time_left = 17 - $hour;
    print "send>PRIVMSG #unknown-horizons :Don't forget about the meeting \x02today\x02 in \x02$time_left hours\x02!\n";
  }

  elsif (($wday == 0) && (($min == 30) || ($min == 50))) {
    my $time_left = 60 - $min;
    print "send>PRIVMSG #unknown-horizons :Don't forget about the meeting \x02today\x02 in \x02$time_left minutes\x02!\n";
  }
}
