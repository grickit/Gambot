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

my ($sender,$account,$hostname,$command,$target,$message,$event,$receiver) = parseMessage($IRCParser::incomingMessage);


if($event eq 'public_message' && authCheck($target,$hostname)) { actOut('MESSAGE',$target,"$receiver: hi"); }
elsif($event eq 'public_message') { authError($sender,$target,$target); }