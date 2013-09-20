#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use FeedReader;

my $link_regex = qr!\n<id>(.+)</id>\n!;
my $item_id_regex = qr!\n<id>http://forums.wesnoth.org/viewtopic.php\?t=[0-9]+&amp;p=([0-9]+)#p[0-9]+</id>\n!;
my $author_regex = qr!^<author><name><\!\[CDATA\[(.+)]]></name></author>\n!;
my $title_regex = qr!\n<title type="html"><\!\[CDATA\[(.+)]]></title>\n!;
my $date_regex = qr!\n<updated>(.+)</updated>\n!;
my $data_site = 'Wesnoth';

my @feed_array;
push(@feed_array, '6'); #Users Forum
push(@feed_array, '5'); #Release Announcements
push(@feed_array, '4'); #Technical Support
push(@feed_array, '3'); #Strategies & Tips
push(@feed_array, '17'); #Website

push(@feed_array, '22'); #Mainline Feedback
  push(@feed_array, '39'); #HttT
  push(@feed_array, '40'); #AToTB
  push(@feed_array, '41'); #AOI
  push(@feed_array, '42'); #TSG
  push(@feed_array, '43'); #Liberty
  push(@feed_array, '51'); #LowSP
  push(@feed_array, '56'); #LowMP
  push(@feed_array, '49'); #EI
  push(@feed_array, '55'); #HoT
  push(@feed_array, '54'); #DiD
  push(@feed_array, '52'); #DM
  push(@feed_array, '45'); #DW
  push(@feed_array, '48'); #SoF
  push(@feed_array, '53'); #SotBE
  push(@feed_array, '44'); #RoW
  push(@feed_array, '47'); #NR
  push(@feed_array, '50'); #UtBS
  push(@feed_array, '46'); #Tutorial
push(@feed_array, '31'); #Add-on Feedback

push(@feed_array, '9'); #Art Contributions
push(@feed_array, '23'); #Art Workshop
push(@feed_array, '14'); #Music and Sound Development
push(@feed_array, '32'); #Writers Forum
push(@feed_array, '21'); #WML Workshop
push(@feed_array, '19'); #Faction and Era
push(@feed_array, '15'); #Multiplayer Development
push(@feed_array, '8'); #Scenario and Campaign Development
push(@feed_array, '58'); #Lua Labs
push(@feed_array, '10'); #Coders Corner
push(@feed_array, '12'); #Ideas
push(@feed_array, '7'); #Translations

push(@feed_array, '2'); #Developer Discussion
push(@feed_array, '18'); #Art Development

push(@feed_array, '36'); #Experimental Corner

push(@feed_array, '13'); #Game Development
push(@feed_array, '11'); #Off-Topic

foreach my $current_feed (@feed_array) {
  my @subscribers_array = get_subscribers($data_site,$current_feed);
  my $current_feed_url = "http://forums.wesnoth.org/feed.php?f=$current_feed";
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
        #http://forums.wesnoth.org/viewtopic.php?t=35139&p=508432#p508432
        if ($data_link =~ /^http:\/\/forums\.wesnoth\.org\/viewtopic\.php\?t=[0-9]+&p=([0-9]+)#p[0-9]+$/) {
          $data_link = "http://r.wesnoth.org/p$1";
        }
        $FeedReader::core->server_send("PRIVMSG $current_subscriber :\x02Wesnoth Forums\x02 | \x02$data_title\x02 by \x0303$data_author\x0F [ \x0314$data_time\x0F ] [ $data_link ]");
      }
    }
  }
}
