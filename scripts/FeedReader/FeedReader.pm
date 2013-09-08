#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/

package FeedReader;
use strict;
use warnings;
use LWP::UserAgent;
use HTML::Entities;
use lib "$FindBin::Bin/../../modules/";
use Gambot::GAPIL::CommandChild;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  url_to_entries
  shorten_url
  entry_to_data
  check_new
  commit_entry
  get_subscribers
);
our @EXPORT_OK = qw(
  $core
  $childName
);

$| = 1;
binmode STDOUT, ":utf8";

our $childName = stdin_read();
our $core = new Gambot::GAPIL::CommandChild();
my %last_reported;

if(!$core->dictionary_exists('feed_reader:subscribers')) { $core->dictionary_load('feed_reader:subscribers'); }
if(!$core->dictionary_exists('feed_reader:last_reported')) { $core->dictionary_load('feed_reader:last_reported'); }
$core->log_normal('FEEDREAD',"$childName beginning.");
$core->event_subscribe("child_deleted:$childName","log_normal>FEEDREAD>$childName ended.");

sub url_to_entries {
  my ($url, $container_start, $container_end) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('franbot/3.0 (Ubuntu 11.04; Perl 5.10)');
  my $response = $request->get($url);
  my $content = $response->decoded_content;

  #Mark the space between tags.
  $content =~ s/>[\s\t\r\n]+</::tagbarrierhere::/g;
  #Clear newlines in the data.
  $content =~ s/[\r\n]+/ /g;
  #Put back the tag barriers
  $content =~ s/::tagbarrierhere::/>\n</g;

  my @lines = split(/\n/,$content);
  my $entry_open = 0;
  my $entry_lines = '';
  my @entries;
  foreach my $line (@lines) {
    $line =~ s/^[\s\t]*//;
    if(!($entry_open) && ($line =~ /^[\s\t]*$container_start[\s\t]*$/)) {
      $entry_open =1;
    }

    elsif(($entry_open) && ($line =~ /^[\s\t]*$container_end[\s\t]*$/)) {
      $entry_open = 0;
      push(@entries, $entry_lines);
      $entry_lines = '';
    }

    elsif(($entry_open)) {
      $entry_lines .= "$line\n";
    }
  }
  return @entries;
}

sub shorten_url {
  my $original_url = shift;
  my $url = "http://tinyurl.com/api-create.php?url=$original_url";

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('franbot/3.0 (Ubuntu 11.04; Perl 5.10)');
  my $response = $request->get($url);
  my $content = $response->decoded_content;
  $content =~ s/[\r\n]*//;

  if($content =~ /^http/) { return $content; }

  return $original_url;
}

sub entry_to_data {
  my ($entry_text,$link_regex,$item_id_regex,$author_regex,$title_regex,$date_regex) = @_;
  my ($link,$item_id,$author,$title,$date);

  if($entry_text =~ m/$link_regex/) {
    $link = $1;
    $link = decode_entities($link);
  }

  if($entry_text =~ m/$item_id_regex/) {
    $item_id = $1;
  }

  if($entry_text =~ m/$author_regex/) {
    $author = $1;
    $author = decode_entities($author);
  }

  if($entry_text =~ m/$title_regex/) {
    $title = $1;
    $title = decode_entities($title);
  }

  if($entry_text =~ m/$date_regex/) {
    $date = $1;
  }

  return ($link,$item_id,$author,$title,$date);
}

sub check_new {
  my ($site_name,$feed_id,$item_id) = @_;
  my $subscription_name = $site_name.$feed_id;

  if(!$last_reported{$subscription_name}) { $last_reported{$subscription_name} = $core->value_get('feed_reader:last_reported',$subscription_name); }
  if(!$last_reported{$subscription_name} || $item_id > $last_reported{$subscription_name}) { return 1; }

  return '';
}

sub commit_entry {
  my ($site_name,$feed_id,$item_id) = @_;
  my $subscription_name = $site_name.$feed_id;

  $core->value_set('feed_reader:last_reported',$subscription_name,$item_id);
  $last_reported{$subscription_name} = $item_id;
}

sub get_subscribers {
  my ($site_name,$feed_id) = @_;
  my $subscription_name = $site_name.$feed_id;

  my $subscriber_list = $core->value_get('feed_reader:subscribers',$subscription_name);
  return split(',',$subscriber_list);
}

1;
