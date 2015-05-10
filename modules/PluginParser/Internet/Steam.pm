package PluginParser::Internet::Steam;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^steam ([0-9-_]+)$/) {
    return steam($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^steam .*store.steampowered.com\/app\/([0-9-_]+).*$/) {
    return steam($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  return '';
}

sub steam {
  use FindBin;
  use lib "$FindBin::Bin/../../modules/";
  require POSIX;
  require LWP::Simple;
  require LWP::UserAgent;
  require JSON::JSON;
  my ($core,$chan,$target,$app) = @_;

  my $url = "http://store.steampowered.com/api/appdetails/?appids=${app}";
  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $json = JSON::decode_json($request->get($url)->decoded_content);

  if($json->{$app}->{'success'}) {
    $json = $json->{$app}->{'data'};

    my $title = $json->{'name'};

    my $price = '0.00';
    if($json->{'price_overview'}->{'final'}) { $price = sprintf("%.2f",$json->{'price_overview'}->{'final'}/100); }

    my $platforms = 'platforms unknown';
    if($json->{'platforms'}->{'windows'} && $json->{'platforms'}->{'mac'} && $json->{'platforms'}->{'linux'}) { $platforms = 'all platforms!'; }
    elsif($json->{'platforms'}->{'windows'} && !$json->{'platforms'}->{'mac'} && !$json->{'platforms'}->{'linux'}) { $platforms = 'Windows only :('; }
    elsif($json->{'platforms'}->{'windows'} && $json->{'platforms'}->{'mac'} && !$json->{'platforms'}->{'linux'}) { $platforms = 'Windows and Mac'; }
    elsif($json->{'platforms'}->{'windows'} && !$json->{'platforms'}->{'mac'} && $json->{'platforms'}->{'linux'}) { $platforms = 'Windows and Linux'; }
    elsif(!$json->{'platforms'}->{'windows'} && $json->{'platforms'}->{'mac'} && $json->{'platforms'}->{'linux'}) { $platforms = 'Mac and Linux'; }

    $core->{'output'}->parse("MESSAGE>${chan}>${target}: \x02\"${title}\"\x02 \x0303\$${price}\x0F, available for ${platforms} http://store.steampowered.com/app/${app}");
  }
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: That app does not exist.");
  }
}
