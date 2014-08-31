package PluginParser::Internet::FetchTitle;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^(http:\/\/.+)$/) {
    return title($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }


  return '';
}

sub title {
  require LWP::Simple;
  require LWP::UserAgent;
  my ($core,$chan,$target,$url) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $content = $request->get($url)->decoded_content;

  if($content =~ /<title>((\n|\s|\r|\t|.)+)<\/title>/) { $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${1}"); }
  elsif(defined $content) { $core->{'output'}->parse("MESSAGE>${chan}>${target}: Doesn't look like that page has a title."); }
  else { $core->{'output'}->parse("MESSAGE>${chan}>${target}: Failed to load that page."); }
}
