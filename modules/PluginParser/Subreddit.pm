package PluginParser::Subreddit;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^subreddit list$/) {
    return subreddit_list($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^subreddit add ([A-Za-z0-9][A-Za-z0-9_]{2,20})$/) {
    return subreddit_add($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^subreddit remove ([A-Za-z0-9][A-Za-z0-9_]{2,20})$/) {
    return subreddit_remove($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }


  return '';
}

sub subreddit_list {
  my ($core,$chan,$target) = @_;
  my $subreddits = $core->value_get('feed_channels:reddit',lc($chan));
  $subreddits =~ s/,?autosave,?//;
  $subreddits =~ s/,/+/g;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: https://www.reddit.com/r/${subreddits}/new");
}

sub subreddit_add {
  my ($core,$chan,$target,$subreddit) = @_;
  if(!$core->{'auth'}->test_sender($core,$chan)) { $core->{'auth'}->error($core,$core->{'sender_nick'},$core->{'receiver_chan'}); return ''; }

  $core->value_push('feed_subscriptions:reddit',lc($subreddit),lc($chan),1);
  $core->value_push('feed_channels:reddit',lc($chan),lc($subreddit),1);

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will now announce new posts from /r/${subreddit} in ${chan}.");
}

sub subreddit_remove {
  my ($core,$chan,$target,$subreddit) = @_;
  if(!$core->{'auth'}->test_sender($core,$chan)) { $core->{'auth'}->error($core,$core->{'sender_nick'},$core->{'receiver_chan'}); return ''; }

  $core->value_pull('feed_subscriptions:reddit',lc($subreddit),lc($chan),1);
  $core->value_pull('feed_channels:reddit',lc($chan),lc($subreddit),1);

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will not announce new posts from /r/${subreddit} in ${chan}.");
}
