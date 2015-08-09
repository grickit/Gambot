use strict;
use warnings;

use LWP::UserAgent;
use HTML::Entities;
use FindBin;
use lib "$FindBin::Bin/../modules/";
use lib "$FindBin::Bin";

use JSON::JSON;
use Gambot::GAPIL::CommandChild;

$| = 1;

my $childName = stdin_read();
my $core = new Gambot::GAPIL::CommandChild;

sub fetch_json {
  my ($url) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Gambot Reddit Feed Reader 0.0.1 by /u/Grickit');
  my $response = $request->get($url);

  return $response->decoded_content;
}

my $last_reported = $core->value_get('feed_metadata:reddit','last_reported');

my $subreddits = $core->value_list('feed_subscriptions:reddit');
$subreddits =~ s/,?autosave,?//;
$subreddits =~ s/,/+/g;

my $string = fetch_json("http://www.reddit.com/r/${subreddits}/new.json?sort=new");
my $json = eval { JSON::decode_json($string) };

if($@) {
  $json = 0;
  $core->log_error($@);
}

if($json && scalar($json->{'data'}->{'children'}[0])) {
  my $actually_reported = 0;
  my %subscribers;

  foreach my $i (1..scalar(@{$json->{'data'}->{'children'}})) {
    my $post = $json->{'data'}->{'children'}[-$i]->{'data'};
    if($post->{'created_utc'} <= $last_reported) { next; }
    $actually_reported = 1;

    my $subreddit = $post->{'subreddit'};
    my $title = decode_entities($post->{'title'});
    my $author = '/u/'.$post->{'author'};
    (my $name = $post->{'name'}) =~ s|^t3_||;
    my $short_url = "https://reddit.com/r/${subreddit}/${name}";
    my $lcsubreddit = lc($subreddit);

    if(!$subscribers{$lcsubreddit}) { $subscribers{$lcsubreddit} = $core->value_get('feed_subscriptions:reddit',$lcsubreddit); }
    foreach my $channel (split(',',$subscribers{$lcsubreddit})) {
      $core->server_send("PRIVMSG ${channel} :\x02${subreddit}:\x02 ${title} (by \x0303${author}\x0F) ${short_url}",1);
    }
  }

  if($actually_reported) { $core->value_set('feed_metadata:reddit','last_reported',$json->{'data'}->{'children'}[0]->{'data'}->{'created_utc'},1); }
}

#value_delete>feed_metadata_reddit>last_reported
$core->delay_subscribe(60,"child_add>feed_reddit>perl $FindBin::RealBin/FeedReddit.pl",1);