use strict;
use warnings;
use URI::Escape;
use FindBin;
use lib "$FindBin::Bin/../../modules/";
use Gambot::GAPIL::CommandChild;
use IRC::Freenode::Specifications;
use IRC::Freenode::Parser;
use IRC::Freenode::Output;
use IRC::Freenode::AuthBasic;

$| = 1;

my $core = new Gambot::GAPIL::CommandChild;
$core->{'parser'} = new IRC::Freenode::Parser($core);
$core->{'output'} = new IRC::Freenode::Output($core);
$core->{'auth'} = new IRC::Freenode::AuthBasic($core);

$core->{'childid'} = stdin_read();
$core->{'botname'} = stdin_read();
$core->{'incoming_message'} = stdin_read();

(
  $core->{'sender_nick'},
  $core->{'sender_user'},
  $core->{'sender_host'},
  $core->{'receiver_nick'},
  $core->{'receiver_chan'},
  $core->{'command'},
  $core->{'message'},
  $core->{'event'},
) = $core->{'parser'}->parse($core->{'botname'},$core->{'incoming_message'});

$core->{'version'} = 'Gambot Core MK V | Module Parser 1.0 | <http://grickit.github.com/>';
$core->{'about'} = 'I am a basic Gambot that is also tasked with reporting on the twitter, reddit, and forum feeds of various projects around freenode. <http://grickit.github.com/> <irc://chat.freenode.net/%23%23Gambot>';

$core->{'target'} = $core->{'sender_nick'};

if($core->{'event'} eq 'on_public_message') {
  my $botname = $core->{'botname'};

  if($core->{'message'} =~ /@([, $charactersNick]+)$/) {
    $core->{'target'} = $1;
    $core->{'message'} =~ s/ ?\@$1$//;
  }

  if($core->{'message'} =~ /^(${botname}[:,] )/ or $core->{'message'} =~ /^(&)/) {
    $core->{'receiver_nick'} = $botname;
    $core->{'message'} =~ s/^$1//;
  }
}

sub module_load {
  my ($module) = @_;
  (my $file = $module) =~ s|::|/|g;
  require $file.'.pm';
  $module->match($core);
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
module_load('PluginParser::Games::Actions');
module_load('PluginParser::Games::Buttcoins');
module_load('PluginParser::Games::Dice');
module_load('PluginParser::Games::Eightball');
module_load('PluginParser::Subreddit');

module_load('PluginParser::Internet::QMarkAPI');
