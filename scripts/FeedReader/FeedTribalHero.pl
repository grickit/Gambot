#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use FeedReader;

my $link_regex = qr!\n<id>(.+)</id>\n!;
my $item_id_regex = qr!\n<id>http://forums.tribalhero.com/viewtopic.php\?t=[0-9]+&amp;p=([0-9]+)#p[0-9]+</id>\n!;
my $author_regex = qr!^<author><name><\!\[CDATA\[(.+)]]></name></author>\n!;
my $title_regex = qr!\n<title type="html"><\!\[CDATA\[(.+)]]></title>\n!;
my $date_regex = qr!\n<updated>(.+)</updated>\n!;
my $data_site = 'Tribalhero';

my @feed_array;
push(@feed_array, '5'); #Announcements
push(@feed_array, '1'); #General Discussion
push(@feed_array, '6'); #Tribe Recruiting and Discussion
push(@feed_array, '3'); #Suggestions
push(@feed_array, '7'); #Theorycrafting
push(@feed_array, '4'); #Problems and Bugs

foreach my $current_feed (@feed_array) {
  my @subscribers_array = get_subscribers($data_site,$current_feed);
  my $current_feed_url = "http://forums.tribalhero.com/feed.php?f=$current_feed";
  my @entries_array = url_to_entries($current_feed_url,'<entry>','</entry>');

  foreach my $i (1..scalar(@entries_array)) {
    my $current_entry = $entries_array[-$i];

    my ($data_link,$item_id,$data_author,$data_title,$data_date_full) = entry_to_data($current_entry,$link_regex,$item_id_regex,$author_regex,$title_regex,$date_regex);
    #2011-06-04T14:23:22-05:00
    $data_date_full =~ m/^([0-9]+-[0-9]+-[0-9]+)T([0-9]+:[0-9]+):[0-9]+([+-][0-9]+:[0-9]+)$/i;
    my $data_time = "$1 $2 $3";

    if(check_new($data_site,$current_feed,$item_id)) {
      commit_entry($data_site,$current_feed,$item_id);
      foreach my $current_subscriber (@subscribers_array) {
        #http://forums.tribalhero.com/viewtopic.php?t=35139&p=508432#p508432
        $FeedReader::core->server_send("PRIVMSG $current_subscriber :\x02Tribalhero Forums\x02 | \x02$data_title\x02 by \x0303$data_author\x0F [ \x0314$data_time\x0F ] [ $data_link ]");
      }
    }
  }
}
