package PluginParser::Parser;
use strict;
use warnings;
use Gambot::GAPIL::CommandChild;
use IRC::Freenode::Specifications;
use IRC::Freenode::Parser;
use IRC::Freenode::Output;
use IRC::Freenode::AuthBasic;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw($core module_load);
our @EXPORT_OK = qw();

$| = 1;

our $core = new Gambot::GAPIL::CommandChild;
$core->{'parser'} = new IRC::Freenode::Parser($core);
$core->{'output'} = new IRC::Freenode::Output($core);
$core->{'auth'} = new IRC::Freenode::AuthBasic($core);

$core->{'childid'} = stdin_read();
$core->{'botname'} = stdin_read();
$core->{'incoming_message'} = stdin_read();

if (my ($forkid) = $core->{'childid'} =~ /^fork(\d+)$/) {
  $core->{'forkid'} = $forkid;
} else {
  $core->{'forkid'} = 0;
}

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
$core->{'about'} = 'I am a basic Gambot. <http://grickit.github.com/> <irc://chat.freenode.net/%23%23Gambot>';

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

1;