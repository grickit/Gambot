use strict;
use warnings;
use URI::Escape;
use FindBin;
use lib "$FindBin::Bin/../../modules/";
use Gambot::GAPIL::CommandChild;
use IRC::Freenode::Specifications;
use IRC::Freenode::Parser;
use IRC::Freenode::Output;

$| = 1;

my $core = new Gambot::GAPIL::CommandChild;
$core->{'parser'} = new IRC::Freenode::Parser($core);
$core->{'output'} = new IRC::Freenode::Output($core);

$core->{'childid'} = stdin_read();
$core->{'botname'} = stdin_read();
$core->{'incoming_message'} = stdin_read();
$core->{'triggers'} = ();

(
  $core->{'nick'},
  $core->{'user'},
  $core->{'host'},
  $core->{'chan'},
  $core->{'command'},
  $core->{'message'},
  $core->{'event'}
) = $core->{'parser'}->parse($core->{'botname'},$core->{'incoming_message'});

$core->{'pinged'} = '';
$core->{'target'} = $core->{'nick'};

if($core->{'event'} eq 'on_private_message') {
  $core->{'pinged'} = 1;
}

if($core->{'event'} eq 'on_public_message') {
  my $botname = $core->{'botname'};

  if($core->{'message'} =~ /@([, $charactersNick]+)$/) {
    $core->{'target'} = $1;
    $core->{'message'} =~ s/ ?@$1$//;
  }

  if($core->{'message'} =~ /^(${botname}[:,] )/ or $core->{'message'} =~ /^(&)/) {
    $core->{'pinged'} = 1;
    $core->{'message'} =~ s/^$1//;
  }
}

sub module_load {
  my ($module) = @_;
  (my $file = $module) =~ s|::|/|g;
  require $file.'.pm';
  $module->match($core);
}

module_load('PluginParser::Maintenance::NickBump');
module_load('PluginParser::Maintenance::Autojoin');
module_load('PluginParser::Maintenance::ServerPing');
module_load('PluginParser::Hug');
module_load('PluginParser::Time');
module_load('PluginParser::Subreddit');