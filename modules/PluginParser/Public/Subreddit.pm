package PluginParser::Public::Subreddit;
use strict;
use warnings;
use POSIX;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if(!$core->{'pinged'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^subreddit list$/) {
    return subreddit_list($core,$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^subreddit add ([A-Za-z0-9][A-Za-z0-9_]{2,20})$/) {
    return subreddit_add($core,$1,$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^subreddit remove ([A-Za-z0-9][A-Za-z0-9_]{2,20})$/) {
    return subreddit_remove($core,$1,$core->{'chan'},$core->{'target'});
  }

  return '';
}

sub load_dict_feed_reddit {
  my ($core) = @_;
  if(!$core->dictionary_exists('feed_metadata:reddit')) { $core->dictionary_load('feed_metadata:reddit'); }
  if(!$core->dictionary_exists('feed_subscriptions:reddit')) { $core->dictionary_load('feed_subscriptions:reddit'); }
  if(!$core->dictionary_exists('feed_channels:reddit')) { $core->dictionary_load('feed_channels:reddit'); }
}

sub subreddit_list {
  my ($core,$chan,$target) = @_;
  load_dict_feed_reddit($core);
  my $channels = $core->value_get('feed_channels:reddit',lc($chan));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${channels}");
}

sub subreddit_add {
  my ($core,$subreddit,$chan,$target) = @_;
  load_dict_feed_reddit($core);
  $core->value_push('feed_subscriptions:reddit',lc($subreddit),lc($chan));
  $core->value_push('feed_channels:reddit',lc($chan),lc($subreddit));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will now announce new posts from ${subreddit} in ${chan}.");
}

sub subreddit_remove {
  my ($core,$subreddit,$chan,$target) = @_;
  load_dict_feed_reddit($core);
  $core->value_pull('feed_subscriptions:reddit',lc($subreddit),lc($chan));
  $core->value_pull('feed_channels:reddit',lc($chan),lc($subreddit));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will not announce new posts from ${subreddit} in ${chan}.");
}