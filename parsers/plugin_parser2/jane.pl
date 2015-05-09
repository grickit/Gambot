use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../modules/";
use PluginParser::Parser;

if($core->{'childid'} eq 'fork10' && $core->{'botname'} =~ /^janebot_*$/) {
  if(!$core->child_exists('streamtwitter')) {
    $core->child_add('streamtwitter',"perl $FindBin::Bin/../../scripts/StreamReader/StreamTwitter.pl");
  }
}

module_load('PluginParser::Maintenance::Autojoin');
module_load('PluginParser::Maintenance::NickBump');
module_load('PluginParser::Maintenance::ServerPing');
#module_load('PluginParser::Maintenance::StateManagement');
module_load('PluginParser::Basic::About');
module_load('PluginParser::Basic::CTCP');
module_load('PluginParser::Basic::Hug');
module_load('PluginParser::Staff::JoinPart');
module_load('PluginParser::Temperature');
module_load('PluginParser::Time');
module_load('PluginParser::Conversation::EDBlock');
module_load('PluginParser::Internet::FetchTitle');
module_load('PluginParser::Internet::Youtube');
module_load('PluginParser::Internet::Steam');
module_load('PluginParser::Games::Actions');
module_load('PluginParser::Games::Buttcoins');
module_load('PluginParser::Games::Dice');
module_load('PluginParser::Games::Eightball');
module_load('PluginParser::Subreddit');
#module_load('PluginParser::Internet::QMarkAPI');
