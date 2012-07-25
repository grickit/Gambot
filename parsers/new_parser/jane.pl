use strict;
use warnings;
use URI::Escape;
use FindBin;
use lib $FindBin::Bin;
use IRCParser;

$permissions{'wesnoth/developer/*'}               = '#wesnoth*';
$permissions{'wesnoth/artist/*'}                  = '#wesnoth*';
$permissions{'wesnoth/forumsith/*'}               = '#wesnoth*';

$permissions{'wesnoth/developer/dave'}            = '#frogatto*';
$permissions{'wesnoth/developer/crimson_penguin'} = '#frogatto*';
$permissions{'wesnoth/artist/jetrel'}             = '#frogatto*';
$permissions{'unaffiliated/marcavis*'}            = '#frogatto*';

$permissions{'unaffiliated/dreadknight'}          = '#AncientBeast';

$permissions{'unaffiliated/aperson'}              = '#minecraft';
$permissions{'reddit/operator/bep'}               = '#minecraft';
$permissions{'unaffiliated/dagmar'}               = '#minecraft';
$permissions{'unaffiliated/helzibah'}             = '#minecraft';
$permissions{'reddit/operator/kylexy'}            = '#minecraft';
$permissions{'pdpc/supporter/student/phonicuk'}   = '#minecraft';
$permissions{'unaffiliated/skuld'}                = '#minecraft';
$permissions{'unaffiliated/sircmpwn'}             = '#minecraft';
$permissions{'unaffiliated/streather'}            = '#minecraft';
$permissions{'i.could.have.had.any.host.but.i.decided.on.dinnerbone.com'} = '#minecraft';

$permissions{'unaffiliated/sircmpwn'}             = '#mcgaming';

$permissions{'unaffiliated/gambit/bot/*'}         = '##Gambot*';
$permissions{'unaffiliated/gambit/bot/*'}         = '#wesnoth-offtopic';
$permissions{'wesnoth/developer/grickit'}         = '*';
$permissions{'wesnoth/developer/shadowmaster*'}   = '*';

if(authCheck('#minecraft','wesnoth/artist/shadowmaster')) { actOut('MESSAGE',$botName,'Hi'); }
else { authError($botName,'#minecraft','#minecraft'); }