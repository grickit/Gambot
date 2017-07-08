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
    return tweet($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  return '';
}

sub tweet {
  require IPC::Open2;
  require HTML::Entities;
  require JSON::JSON;
  # TODO: proper package instead of needing to clone this shit
  require StreamReader;
  my ($core, $chan, $target, $tweet_id) = @_;

  my %twitter_credentials = $core->value_dump('twitter_credentials', '^');

  $StreamReader::oauthConsumerKey = $twitter_credentials{'consumer_key'};
  $StreamReader::oauthAccessKey = $twitter_credentials{'access_key'};
  $StreamReader::oauthConsumerSecret = $twitter_credentials{'consumer_secret'};
  $StreamReader::oauthAccessSecret = $twitter_credentials{'access_secret'};

  my $url = "https://api.twitter.com/1.1/statuses/show/${tweet_id}.json";
  my $base_string = StreamReader::oauthGenerateBaseString({});
  my $signature_base_string = StreamReader::oauthGenerateSignatureBaseString('GET',$url,$base_string);
  my $signing_key = StreamReader::oauthGenerateSigningKey();
  my $signature = StreamReader::oauthGenerateSignature($signature_base_string,$signing_key);
  my $curl_command = StreamReader::oauthGenerateCurlCommand('GET',$url,$signature,{});

  my $request = IPC::Open2::open2(my $read_pipe,my $write_pipe,$curl_command);

  while (my $line = <$read_pipe>) {
    if($line =~ /^\s$/) { next; } # Throw out blank lines
    my $tweet = JSON::decode_json($line);

    if(!$tweet->{'text'}) { next; } # Throw out deletions, favorites, and so on

    
    if($tweet->{'text'} && $tweet->{'user'}->{'screen_name'}) {
      my $author = $tweet->{'user'}->{'screen_name'}; # Get the author
      my $text = HTML::Entities::decode_entities($tweet->{'text'}); # Get the message
      my $id = $tweet->{'id'}; # Get the ID

      if($tweet->{'entities'}->{'urls'}) { # Expand short urls

        foreach my $url (@{$tweet->{'entities'}->{'urls'}}) {
          my $old_url = decode_entities($tweet->{'entities'}->{'urls'}[$url]->{'url'});
          my $new_url = decode_entities($tweet->{'entities'}->{'urls'}[$url]->{'expanded_url'});
          $text =~ s/$old_url/$new_url/;
        }
      }

      $text =~ s/(#[a-z][a-z0-9_]*)/\x0312$1\x0F/ig; # Color hashtags
      $text =~ s/^RT (@\w{1,15}): /(\x0314RT $1\x0F) /; # Color retweets
      $text =~ s/[\r\n]+/ /ig; # Remove newlines

      $core->{'output'}->parse("MESSAGE>${chan}>${target}: \x02Tweet\x02 (by \x0303\@${author}\x0F) ${text} [ https://twitter.com/${author}/status/${id} ]");
    }
  }
}
