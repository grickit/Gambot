use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../modules/";
use Gambot::GAPIL::CommandChild;

$| = 1;

our $childName = stdin_read();
my $core = new Gambot::GAPIL::CommandChild();

## Close any lagging or stuck scripts
if($core->child_exists('feed_frogatto')) { $core->child_delete('feed_frogatto'); }
if($core->child_exists('feed_unknown-horizons')) { $core->child_delete('feed_unkownhorizons'); }
if($core->child_exists('feed_wesnoth')) { $core->child_delete('feed_wesnoth'); }
if($core->child_exists('feed_tribalhero')) { $core->child_delete('feed_tribalhero'); }

$core->child_add('feed_frogatto',"perl $FindBin::RealBin/FeedReader/FeedFrogato.pl");
$core->child_add('feed_unknownhorizons',"perl $FindBin::RealBin/FeedReader/FeedFrogatto.pl");
$core->child_add('feed_wesnoth',"perl $FindBin::RealBin/FeedReader/FeedWesnoth.pl");
$core->child_add('feed_tribalhero',"perl $FindBin::RealBin/FeedReader/FeedWesnoth.pl");

## Start this script again in 10 minutes
$core->delay_subscribe('600',"perl $FindBin::RealBin/feed_timer.pl");
