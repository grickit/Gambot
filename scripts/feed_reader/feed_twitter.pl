#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
use strict;
use warnings;
use Benchmark;
use FindBin;
use lib $FindBin::Bin;
use HTML::Entities;

use feed_reader;

my $time_start = Benchmark->new();
$| = 1;
binmode STDOUT, ":utf8";

my $db_connection = &connect_to_database();

my $link_regex = qr/\n<link>(.+)<\/link>\n/;
my $author_regex = qr/\n<link>http:\/\/twitter.com\/(.+)\/statuses\/[0-9]+<\/link>\n/;
my $title_regex = qr/^<title>(.+)<\/title>\n/;
my $date_regex = qr/\n<pubDate>(.+)<\/pubDate>\n/;
my $data_site = 'Twitter';

my @feed_array;
push(@feed_array, 'Grickit');
push(@feed_array, 'AncientBeast');
push(@feed_array, 'TheFreezingMoon');
push(@feed_array, 'uhorizons');
push(@feed_array, 'uhorizonstech')
push(@feed_array, 'Wesnoth');
push(@feed_array, 'Notch');
push(@feed_array, 'jeb_');
push(@feed_array, 'Dinnerbone');

print "log>FEEDREAD>$data_site feeds beginning\n";

foreach my $current_feed (@feed_array) {
  my @subscribers_array = get_subscribers($db_connection, $data_site,$current_feed);
  my $current_feed_url = "http://twitter.com/statuses/user_timeline/$current_feed.rss";
  my @entries_array = &url_to_entries($current_feed_url,'<item>','</item>');

  foreach my $i (1..scalar(@entries_array)) {
    my $current_entry = $entries_array[-$i];

    my ($data_link, $data_author, $data_title, $data_date_full) = entry_to_data($current_entry,$link_regex,$author_regex,$title_regex,$date_regex);
    #Sun, 05 Jun 2011 03:25:38 +0000
    $data_date_full =~ m/^[a-z]+, ([0-9]+) ([a-z]+) ([0-9]+) ([0-9]+):([0-9]+):[0-9]+ \+[0-9]+$/i;
    my $data_date = "$2-$1-$3";
    my $data_time = "$4:$5";
    $data_title =~ s/^$data_author: //;
    $data_title = decode_entities($data_title);

    unless(&check_existence($db_connection, $current_feed, $data_link)) {
      &commit_entry($db_connection, $data_site, $current_feed, $data_link, $data_title, $data_author, $data_date, $data_time);
      my $shortened_link = &shorten_url($data_link);
      #print "send_server_message>PRIVMSG ##Gambot-forum :\x02Twitter\x02: \x0303$data_author\x0F: $data_title [ \x0314$data_date $data_time\x0F ] [ $shortened_link ]\n";
      #print "sleep>0.5\n";
      foreach my $current_subscriber (@subscribers_array) {
	if($current_subscriber eq '#minecraft') {
	  if($data_title =~ /^(RT )?\@[a-zA-Z0-9_-]+/ && $data_title !~ /^(RT )?\@(Marc_IRL|KrisJelbring|LydiaWinters|xlson|carnalizer|BomuBoi|danfrisk|Kappische|JahKob|jeb_|notch|jnkboy|carlmanneh|mollstam|Dinnerbone|CraftBukkit)/) {
	    next;
	  }
	  else {
	    print "send_server_message>PRIVMSG $current_subscriber :\x0303\@$data_author\x0F: $data_title [ $shortened_link ]\n";
	    print "sleep>0.5\n";
	  }
	}
	else {
	  print "send_server_message>PRIVMSG $current_subscriber :\x02Twitter\x02: \x0303\@$data_author\x0F: $data_title [ \x0314$data_date $data_time\x0F ] [ $shortened_link ]\n";
	  print "sleep>0.5\n";
	}
      }
    }
  }
}

$db_connection->disconnect();
my $time_end = Benchmark->new();
my $time_difference = timestr(timediff($time_end,$time_start));
print "log>FEEDREAD>$data_site finished. $time_difference\n";