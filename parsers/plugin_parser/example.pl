use strict;
use warnings;
use URI::Escape;
use FindBin;
use lib $FindBin::Bin;
use IRCParser;

$| = 1;

$IRCParser::permissions{'wesnoth/developer/grickit'}         = '*';
$IRCParser::permissions{'wesnoth/developer/shadowmaster*'}   = '*';

$IRCParser::sl = '';
$IRCParser::cm = '(?:&|(?:'.$IRCParser::botName.'[:,] ))';

# Autojoin list
if($IRCParser::pipeID eq 'fork10') {
  actOut('JOIN','##Gambot',undef);
}


sub on_server_ping {}
sub on_private_message {
  runPlugin("$FindBin::Bin/plugins/basic/ctcp.pm");
  on_public_message();
}
sub on_public_message {
  runPlugin("$FindBin::Bin/plugins/basic/about.pm");
  runPlugin("$FindBin::Bin/plugins/hug.pm");
  runPlugin("$FindBin::Bin/plugins/actions.pm");
  runPlugin("$FindBin::Bin/plugins/temperature.pm");
  runPlugin("$FindBin::Bin/plugins/time.pm");

  runPlugin("$FindBin::Bin/plugins/conversation/ed-block.pm");
  runPlugin("$FindBin::Bin/plugins/conversation/memes.pm");
  runPlugin("$FindBin::Bin/plugins/conversation/quote.pm");

  runPlugin("$FindBin::Bin/plugins/games/roulette.pm");
  runPlugin("$FindBin::Bin/plugins/games/dice.pm");
  runPlugin("$FindBin::Bin/plugins/games/eightball.pm");

  runPlugin("$FindBin::Bin/plugins/internet/url-check.pm");
  runPlugin("$FindBin::Bin/plugins/internet/youtube.pm");
}
sub on_private_notice {}
sub on_public_notice {}
sub on_join {}
sub on_part {}
sub on_quit {}
sub on_mode {}
sub on_nick {}
sub on_kick {}
sub on_topic {}
sub on_server_message {
  runPlugin("$FindBin::Bin/plugins/basic/nick_bump.pm");
}
sub on_server_error {}

# Fire the subroutine that is named in $event
&{\&{$IRCParser::event}}() if $IRCParser::event;
