use strict;
use warnings;
use FindBin;

$| = 1;
my $interval = 5;
die "60 not divisible by timer interval" if (60 % $interval);

my ($seconds,$minutes,undef,undef,undef,undef,undef,undef,undef) = localtime(time);
my $ten;
if ($minutes < 5) {
  $ten = 0;
}
else {
  $ten = 1;
}

while(defined sleep(1)) {
  ($seconds,$minutes,undef,undef,undef,undef,undef,undef,undef) = localtime(time);
  if((($minutes % $interval) == 0) && ($seconds == 0)) {
    print "run_command>feed_twitter>perl $FindBin::RealBin/feed_reader/feed_twitter.pl\n";
    #print "Twitter\n";
    if($ten == 1) {
      #print "Others\n";
      print "run_command>feed_frogatto>perl $FindBin::RealBin/feed_reader/feed_frogatto.pl\n";
      print "run_command>feed_unknownhorizons>perl $FindBin::RealBin/feed_reader/feed_unknownhorizons.pl\n";
      print "run_command>feed_wesnoth>perl $FindBin::RealBin/feed_reader/feed_wesnoth.pl\n";
      print "run_command>feed_tribalhero>perl $FindBin::RealBin/feed_reader/feed_tribalhero.pl\n";
    }
    $ten = !$ten;
  }
}
