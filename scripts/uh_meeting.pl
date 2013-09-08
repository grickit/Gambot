use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../modules/";
use Gambot::GAPIL::CommandChild;

$| = 1;

our $childName = stdin_read();
my $core = new Gambot::GAPIL::CommandChild();

my @days = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
my ($sec,$min,$hour,undef,undef,undef,$wday,undef,undef) = gmtime(time);
$hour = sprintf ("%02d", $hour);
$min = sprintf ("%02d", $min);
my $mins_off = 60 - $min;
my $next_run = 1;

if($wday == 0) { ## Sunday
  if($hour == 16) { ## Less than 1 hour remaining
    if($min == 0) {
      $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02today\x02 in \x02$mins_off minutes\x02! [ http://git.io/9vk4bg ]");
      $next_run = 1800; ## Fire again in 30 minutes to hit Sunday at 16:30
    }

    elsif($min == 30) {
      $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02today\x02 in \x02$mins_off minutes\x02! [ http://git.io/9vk4bg ]");
      $next_run = 1200; ## Fire again in 20 minutes to hit Sunday at 16:50
    }

    elsif($min == 50) {
      $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02today\x02 in \x02$mins_off minutes\x02! [ http://git.io/9vk4bg ]");
      $next_run = 87000; ## Fire again in 24 hours 10 minutes to hit Monday at 17:00
    }

    else {
      $core->log_debug('uh_meeting.pl out of sync(1). Resyncing the minutes.');
      $next_run = 60; ## Resync the minutes
    }
  }

  elsif($hour == 0 || $hour == 3 || $hour == 6 || $hour == 9 || $hour == 12 || $hour == 15) { ## 1-2 hours remaining
    my $time_left = 17 - $hour;
    $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02today\x02 in \x02$time_left hours\x02! [ http://git.io/9vk4bg ]");
    if($hour == 15) { $next_run = 60*$mins_off; } ## Fire again in a few minutes to hit Sunday at 16:00
    else { $next_run = 10800; } ## Fire again in 3 hours to hit Sunday at 3:00, 6:00, 9:00, 12:00, or 15:00
  }

  else {
    $core->log_debug('uh_meeting.pl out of sync(2). Resyncing the hours.');
    $next_run = 60*$mins_off; ## Resync the hours
  }
}

elsif($wday == 6) { ## Saturday

  if($hour == 12 || $hour == 16 || $hour == 20) {
    $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02tomorrrow\x02 at \x0217:00 UTC\x02! For reference, it is currently $hour:$min UTC. [ http://git.io/9vk4bg ]");
    $next_run = 14400; ## Fire again in 4 hours to hit Satuday at 16:00, 20:00, or Sunday at 0:00
  }

  else {
    $core->log_debug('uh_meeting.pl out of sync(3). Resyncing the hours.');
    $next_run = 60*$mins_off; ## Resync the hours
  }
}

else { ## Weekdays
  if($hour == 17) {
    $core->server_send("PRIVMSG ##Gambot :Don't forget about the meeting \x02Sunday\x02 at \x0217:00 UTC\x02! For reference, it is currently $hour:$min UTC on $days[$wday]. [ http://git.io/9vk4bg ]");
    if($wday == 5) { $next_run = 68400; } ## Fire again in 19 hours to hit Saturday at 12:00
    else { $next_run = 86400; } ## Fire again in 24 hours to hit tomorrow at 17:00
  }

  else {
    $core->log_debug('uh_meeting.pl out of sync(4). Resyncing the hours.');
    $next_run = 60*$mins_off; ## Resync the hours
  }
}

$core->delay_subscribe($next_run,"child_add>uhmeeting>perl $FindBin::RealBin/uh_meeting.pl");