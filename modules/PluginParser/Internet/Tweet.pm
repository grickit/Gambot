package PluginParser::Internet::Tweet;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  # Match full twitter urls
  if($core->{'message'} =~ /^tweet .*twitter\.com\/[a-zA-Z0-9-_]+\/status\/([0-9]+).*$/) {
    return tweet($core,$core->{'receiver_chan'},$core->{'target'},$1,0);
  }

  return '';
}

# Twitter requires that you authenticate using your bearer credentials (from app page), to get a access token
# which you then have to send with each request
# We save this token till we need to get a new one again
sub get_access_token {
  require LWP::Simple;
  require LWP::UserAgent;
  require JSON;
  my ($core,$chan,$target) = @_;

  my $bearer_token = $core->value_get('twitter', 'bearer_token');

  if ($bearer_token eq '') {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: My owner hasn't added twitter api details so I can't fetch that tweet! Sorry :(");
    return '';
  }

  my $url = "https://api.twitter.com/oauth2/token";
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->default_header('Authorization' => "Basic ${bearer_token}"); # Required header
  $request->default_header('Content-Type' => "application/x-www-form-urlencoded;charset=UTF-8"); # Required header
  $request->max_size('1024000');
  $request->parse_head(0);
  my $resp = $request->post($url, Content => 'grant_type=client_credentials')->decoded_content; # Required body content
  my $json = JSON::decode_json($resp);

  if(!$json->{'errors'} && $json->{'access_token'} && $json->{'token_type'} eq 'bearer') {
    my $token = $json->{'access_token'};
    $core->value_set('twitter', 'access_token', $token);

    return $token;
  }
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: Error authenticating with the Twitter API.");
  }
}

sub format_tweet {
  my($json) = @_;
  my %colours = (
    "bold" => "\x02",
    "italics" => "\x1D",
    "underline" => "\x1F",
    "reset" => "\x0F",
    "white" => "\x0300",
    "black" => "\x0301",
    "blue" => "\x0302",
    "green" => "\x0303",
    "red" => "\x0304",
    "brown" => "\x0305",
    "magenta" => "\x0306",
    "orange" => "\x0307",
    "yellow" => "\x0308",
    "lgreen" =>"\x0309",
    "cyan" => "\x0310",
    "lcyan" => "\x0311",
    "lblue" => "\x0312",
    "pink" => "\x0313",
    "grey" => "\x0314",
    "lgrey" => "\x0315"
  );

  # Ideal format:  Tweet (by @Grickit) (RT @flyosity) C'mon dude, really? https://t.co/SqZZ43exxl [ https://twitter.com/Grickit/status/883308925235408896 ]
  my $author = "@".$json->{'user'}->{'screen_name'};
  my $tweet_id = $json->{'id_str'};
  my $text = $json->{'text'};
  my $url = "https://twitter.com/${author}/status/${tweet_id}";

  # No need to check for if it is a reply - twitter adds the @mentions in the text anyway
  # my $is_reply = $json->{'in_reply_to_status_id_str'} ne "";
  # Twitter just returns the retweeted tweet now (diffrent from their docs), so this will always be false
  # my $is_retweet = $json->{'retweeted'};

  my $tweet = "$colours{'bold'}Tweet $colours{'reset'}(by $colours{green}${author}$colours{reset}) ${text} [${url}]";
  $tweet =~ s/[\r\n]/ /g; # Remove \r and \n characters, which are sometimes in tweets
  return $tweet;
}

sub tweet {
  require LWP::Simple;
  require LWP::UserAgent;
  require JSON;
  my ($core, $chan, $target, $tweet_id, $alreadyTried) = @_;

  my $access_token = $core->value_get('twitter', 'access_token');

  # First time running, probably
  if ($access_token eq '') {
    $access_token = get_access_token($core, $chan, $target);

    # Still no access token? api error -> Don't continue
    if ($access_token eq '') {
      return '';
    }
  }

  my $url = "https://api.twitter.com/1.1/statuses/show/${tweet_id}.json";
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->default_header('Authorization' => "Bearer ${access_token}"); # Required header
  $request->max_size('1024000');
  $request->parse_head(0);
  my $json = JSON::decode_json($request->get($url)->decoded_content);

  if ($json->{'errors'}) {
    # Errored a second time -> Fail
    if ($alreadyTried) {
      return $core->{'output'}->parse("MESSAGE>${chan}>${target}: Failed to fetch that tweet.");
    }
    # Errored first time -> Try again if we need a new access token
    elsif ($json->{'errors'}->{'code'} eq 89) {
      my $new_token = get_access_token($core, $chan, $target);

      # Failed to get a new token, and already sent a message to the channel - do nothing more
      if ($new_token eq '') {
        return '';
      }

      return get_tweet($core, $chan, $target, $tweet_id, 1);
    }
  }
  # No errors -> format the tweet and send it off
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: ".format_tweet($json));
  }
}
