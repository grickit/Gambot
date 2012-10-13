use strict;
use warnings;
use URI::Escape;
use FindBin;
use lib $FindBin::Bin;
use IRCParser;

$IRCParser::permissions{'wesnoth/developer/*'}               = '#wesnoth*';
$IRCParser::permissions{'wesnoth/artist/*'}                  = '#wesnoth*';
$IRCParser::permissions{'wesnoth/forumsith/*'}               = '#wesnoth*';

$IRCParser::permissions{'wesnoth/developer/dave'}            = '#frogatto*';
$IRCParser::permissions{'wesnoth/developer/crimson_penguin'} = '#frogatto*';
$IRCParser::permissions{'wesnoth/artist/jetrel'}             = '#frogatto*';
$IRCParser::permissions{'unaffiliated/marcavis*'}            = '#frogatto*';

$IRCParser::permissions{'unaffiliated/dreadknight'}          = '#AncientBeast';

$IRCParser::permissions{'unaffiliated/aperson'}              = '#minecraft';
$IRCParser::permissions{'reddit/operator/bep'}               = '#minecraft';
$IRCParser::permissions{'unaffiliated/dagmar'}               = '#minecraft';
$IRCParser::permissions{'unaffiliated/helzibah'}             = '#minecraft';
$IRCParser::permissions{'reddit/operator/kylexy'}            = '#minecraft';
$IRCParser::permissions{'pdpc/supporter/student/phonicuk'}   = '#minecraft';
$IRCParser::permissions{'unaffiliated/skuld'}                = '#minecraft';
$IRCParser::permissions{'unaffiliated/streather'}            = '#minecraft';
$IRCParser::permissions{'i.could.have.had.any.host.but.i.decided.on.dinnerbone.com'} = '#minecraft';

$IRCParser::permissions{'unaffiliated/sircmpwn'}             = '#mcgaming';

$IRCParser::permissions{'unaffiliated/gambit/bot/*'}         = '##Gambot*';
$IRCParser::permissions{'unaffiliated/gambit/bot/*'}         = '#wesnoth-offtopic';
$IRCParser::permissions{'wesnoth/developer/grickit'}         = '*';
$IRCParser::permissions{'wesnoth/developer/shadowmaster*'}   = '*';

$IRCParser::sl = '';
$IRCParser::cm = '.';

# Autojoin list
if($IRCParser::pipeID eq 'fork10') {
  actOut('JOIN','##Gambot',undef);
}

sub on_server_ping {}
sub on_private_message {}
sub on_public_message {

  runPlugin("$FindBin::Bin/plugins/hug.pm");

}
sub on_private_notice {}
sub on_public_notice {}
sub on_join {}
sub on_part {}
sub on_quit {}
sub on_mode {}
sub on_nick {}
sub on_kick {}
sub on_server_message {

  runPlugin("$FindBin::Bin/plugins/basic/nick_bump.pm");

}
sub on_server_error {}

# Fire the subroutine that is named in $event
&{\&{$IRCParser::event}}();