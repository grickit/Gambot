use strict;
use warnings;

use IPC::Open2;
use URI::Escape;
use HTML::Entities;
use FindBin;
use lib "$FindBin::Bin/../../modules/";
use lib "$FindBin::Bin";

use JSON::JSON;
use Gambot::GAPIL::CommandChild;
use StreamReader;

my $childName = stdin_read();
my $core = new Gambot::GAPIL::CommandChild();

if(!$core->dictionary_exists('feed_reader:subscribers')) { $core->dictionary_load('feed_reader:subscribers'); }
if(!$core->dictionary_exists('twitter_credentials')) { $core->dictionary_load('twitter_credentials'); }
$core->log_normal('FEEDREAD',"$childName beginning.");
$core->event_subscribe("child_deleted:$childName","log_normal>FEEDREAD>$childName ended.");
## Make this script undead
$core->event_subscribe("child_deleted:$childName","child_add>$childName>perl $FindBin::Bin/StreamTwitter.pl");

$StreamReader::oauthConsumerKey = $core->value_get('twitter_credentials','consumer_key');
$StreamReader::oauthAccessKey = $core->value_get('twitter_credentials','access_key');
$StreamReader::oauthConsumerSecret = $core->value_get('twitter_credentials','consumer_secret');
$StreamReader::oauthAccessSecret = $core->value_get('twitter_credentials','access_secret');

my %feeds;
$feeds{'Grickit'} =             165895839;
$feeds{'uhorizons'} =           116289965;
$feeds{'uhorizonstech'} =       269224038;
$feeds{'Wesnoth'} =             292527834;
$feeds{'jeb_'} =                24166202;
$feeds{'Dinnerbone'} =          83820762;
$feeds{'SeargeDP'} =            381007605;
$feeds{'MinecraftAPIBot'} =     718090032;
$feeds{'shikadilord'} =         165991694;
$feeds{'StatusMinecraft'} =     901296078;
$feeds{'kairibot'} =            369296792;
$feeds{'_grum'} =               432311300;
$feeds{'frogatto'} =            162971133;

my %mojangles;
$mojangles{'716689700'} = 'PoiPoiChen';
$mojangles{'479041531'} = 'MansOlson';
$mojangles{'437016484'} = 'KarinSeverinson';
$mojangles{'381096157'} = 'Linnsebumsan';
$mojangles{'373453224'} = 'MissMarzenia';
$mojangles{'325583724'} = 'carnalizer';
$mojangles{'282348945'} = 'MojangTeam';
$mojangles{'251785109'} = 'Bomuboi';
$mojangles{'245282361'} = 'jbernhardsson';
$mojangles{'211105430'} = 'JahKob';
$mojangles{'210944652'} = 'jnkboy';
$mojangles{'193055570'} = 'eldrone';
$mojangles{'180670967'} = 'Marc_IRL';
$mojangles{'177564924'} = 'Kappische';
$mojangles{'144584760'} = 'mamirm';
$mojangles{'112344837'} = 'LydiaWinters';
$mojangles{'109344609'} = 'KrisJelbring';
$mojangles{'83820762'} = 'Dinnerbone';
$mojangles{'76831143'} = 'EvilSeph';
$mojangles{'63485337'} = 'notch';
$mojangles{'41179149'} = '91maan90';
$mojangles{'24166202'} = 'jeb_';
$mojangles{'20586677'} = 'danfrisk';
$mojangles{'18731347'} = 'carlmanneh';
$mojangles{'17989826'} = 'bopogamel';
$mojangles{'16952295'} = 'jonkagstrom';
$mojangles{'14796299'} = 'xlson';
$mojangles{'8032822'} = 'mollstam';
$mojangles{'381007605'} = 'SeargeDP';
$mojangles{'2150950224'} = 'themogminer';

my $url = 'https://stream.twitter.com/1.1/statuses/filter.json';
my $follow = uri_escape(join(',',values(%feeds)));
my $base_string = StreamReader::oauthGenerateBaseString({'follow' => $follow});
my $signature_base_string = StreamReader::oauthGenerateSignatureBaseString('POST',$url,$base_string);
my $signing_key = StreamReader::oauthGenerateSigningKey();
my $signature = StreamReader::oauthGenerateSignature($signature_base_string,$signing_key);
my $curl_command = StreamReader::oauthGenerateCurlCommand('POST',$url,$signature,{'follow' => $follow});

my $request = open2(my $read_pipe,my $write_pipe,$curl_command);

while (my $line = <$read_pipe>) {
  #print $line;
  if($line =~ /^\s$/) { next; } # Throw out blank lines
  my $tweet = JSON::decode_json($line);

  if(!$tweet->{'text'}) { next; } # Throw out deletions, favorites, and so on
  if(!$feeds{$tweet->{'user'}->{'screen_name'}}) { next; } # Throw out replies
  
  if($tweet->{'text'} && $tweet->{'user'}->{'screen_name'}) {
    my $author = $tweet->{'user'}->{'screen_name'}; # Get the author
    my $text = decode_entities($tweet->{'text'}); # Get the message
    my $id = $tweet->{'id'}; # Get the ID

    if($tweet->{'entities'}->{'urls'}) { # Expand short urls
      foreach my $url (keys $tweet->{'entities'}->{'urls'}) {
        my $old_url = decode_entities($tweet->{'entities'}->{'urls'}[$url]->{'url'});
        my $new_url = decode_entities($tweet->{'entities'}->{'urls'}[$url]->{'expanded_url'});
        $text =~ s/$old_url/$new_url/;
      }
    }

    $text =~ s/(#[a-z0-9]+)/\x0312$1\x0F/ig; # Color hashtags
    $text =~ s/^RT (@\w{1,15}): /(\x0314RT $1\x0F) /; # Color retweets
    $text =~ s/[\r\n]+/ /ig; # Remove newlines

    my $subscribers = $core->value_get('feed_reader:subscribers',"Twitter$author");
    foreach my $channel (split(',',$subscribers)) {
      if($channel ne '#minecraft' || !$tweet->{'in_reply_to_user_id'} || $mojangles{$tweet->{'in_reply_to_user_id'}}) {
        $core->server_send("PRIVMSG $channel :\x02Tweet\x02 (by \x0303\@$author\x0F) $text [ https://twitter.com/$author/status/$id ]");
      }
    }
  }
}
