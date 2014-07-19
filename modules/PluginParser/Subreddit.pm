package PluginParser::Subreddit;
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

sub subreddit_list {
  my ($core,$chan,$target) = @_;
  my $subreddits = $core->value_get('feed_channels:reddit',lc($chan));
  $subreddits =~ s/,?autosave,?//;
  $subreddits =~ s/,/+/g;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: http://www.reddit.com/r/${subreddits}/new");
}

sub subreddit_add {
  my ($core,$subreddit,$chan,$target) = @_;
  $core->value_push('feed_subscriptions:reddit',lc($subreddit),lc($chan));
  $core->value_push('feed_channels:reddit',lc($chan),lc($subreddit));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will now announce new posts from http://reddit.com/r/${subreddit} in ${chan}.");
}

sub subreddit_remove {
  my ($core,$subreddit,$chan,$target) = @_;
  $core->value_pull('feed_subscriptions:reddit',lc($subreddit),lc($chan));
  $core->value_pull('feed_channels:reddit',lc($chan),lc($subreddit));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: I will not announce new posts from http://reddit.com/r/${subreddit} in ${chan}.");
}