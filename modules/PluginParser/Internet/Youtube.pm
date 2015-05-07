package PluginParser::Internet::Youtube;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^youtube ([a-zA-Z0-9-_]+)$/) {
    return youtube($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^youtube .*youtube\.com.+v=([a-zA-Z0-9-_]+).*$/) {
    return youtube($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^youtube .*youtu\.be\/([a-zA-Z0-9-_]+).*$/) {
    return youtube($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }


  return '';
}

sub youtube {
  use FindBin;
  use lib "$FindBin::Bin/../../modules/";
  require POSIX;
  require LWP::Simple;
  require LWP::UserAgent;
  require JSON::JSON;
  my ($core,$chan,$target,$video) = @_;

  my $url = "https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails,statistics&id=${video}&key=AIzaSyA7oMrml5891LSmnZY0scg7gKLRnvb54Pc";
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $json = JSON::decode_json($request->get($url)->decoded_content);

  if(!$json->{'error'} && $json->{'items'}->[0]) {
    $json = $json->{'items'}->[0];

    my $title = $json->{'snippet'}->{'title'};
    my $duration = $json->{'contentDetails'}->{'duration'};
    $duration =~ s/^PT//;
    my $author = $json->{'snippet'}->{'channelTitle'};
    my $views = $json->{'statistics'}->{'viewCount'};
    my $likes = $json->{'statistics'}->{'likeCount'};
    my $dislikes = $json->{'statistics'}->{'dislikeCount'};

    my $restrictions = "(\x0314no region restrictions\x0F)";
    if($json->{'contentDetails'}->{'regionRestriction'}) { $restrictions = "(\x0307unavailable in some regions\x0F)"; }

    $core->{'output'}->parse("MESSAGE>${chan}>${target}: \x02\"${title}\"\x02 \x0306${duration}\x0F (by \x0303${author}\x0F) \x0314${views}\x0F views, \x0303${likes}\x0F likes, \x0304${dislikes}\x0F dislikes http://youtu.be/${video} ${restrictions}");
  }
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: That video does not exist.");
  }
}
