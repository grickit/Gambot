package IRCParser;

use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use lib "$FindBin::Bin/../../modules/";
use Gambot::GAPIL::CommandChild;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  beginParsing
  actOut
  authCheck
  authError
  parseMessage
  runPlugin
  $core
);
our @EXPORT_OK = qw(
  $nickCharacters
  $userCharacters
  $serverCharacters
  $channelCharacters
  $hostmaskCharacters
  $validNick
  $validUser
  $validChannel
  $validHostmask
  $validHumanSender
  $validServerSender
  $pipeID
  $botName
  $incomingMessage
  $sender
  $account
  $hostname
  $command
  $target
  $message
  $event
  $receiver
  $sl
  $cm
  $version
  $about
  %permissions
  $sentOutput
);

our $core = new Gambot::GAPIL::CommandChild();
our $nickCharacters = 'A-Za-z0-9[\]\\`_^{}|-';
our $userCharacters = 'A-Za-z0-9[\]\\`_^{}|.-';
our $serverCharacters = 'a-zA-Z0-9\.';
our $channelCharacters = '#A-Za-z0-9[\]\\`_^{}|-';
our $hostmaskCharacters = ':./A-Za-z0-9[\]\\`_^{}|-';
our $validNick = '(['.$nickCharacters.']+)';
our $validUser = '(['.$userCharacters.']+)';
our $validChannel = '(['.$channelCharacters.']+)';
our $validHostmask = '(['.$hostmaskCharacters.']+)';
our $validHumanSender = $validNick.'!~?'.$validUser.'@'.$validHostmask;
our $validServerSender = '(['.$serverCharacters.']+)';

our $pipeID = stdin_read();
our $botName = stdin_read();
our $incomingMessage = stdin_read();

our($sender,$account,$hostname,$command,$target,$message,$event,$receiver) = parseMessage($incomingMessage);

our $sl = $botName.'[;,]';
our $cm = '!';
our $version = 'Gambot Core MK IV | Plugin Parser 7 | <http://grickit.github.com/>';
our $about = 'I am a basic Gambot. <http://grickit.github.com/> <irc://chat.freenode.net/%23%23Gambot>';
our $sentOutput = 0;

our %permissions;

sub actOut { #action,target,message
  my @args = @_;
  foreach my $i (0..$#args) { $args[$i] = strip_newlines($args[$i]); }

  if($_[0] eq 'MESSAGE') {
    $core->server_send("PRIVMSG $args[1] :$args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'ACTION') {
    $core->server_send("PRIVMSG $args[1] :ACTION $args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'NOTICE') {
    $core->server_send("NOTICE $args[1] :$args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'JOIN') {
    $core->server_send("JOIN $args[1]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'PART') {
    $core->server_send("PART $args[1] :$args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'KICK') {
    $core->server_send("KICK $args[1] :$args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'INVITE') {
    $core->server_send("INVITE $args[1] :$args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'MODE') {
    $core->server_send("MODE $args[1] $args[2]");
    $sentOutput = 1;
  }
  elsif($_[0] eq 'DEBUG') {
    $core->server_send("PRIVMSG $args[1] :$args[2]");
  }
  elsif($_[0] eq 'LITERAL') {
    print "$args[2]\n";
  }
  else {
    $core->log_normal('ACTERROR',"Unrecognized action: $args[1] $args[2] $args[3]");
    return '';
  }
  return 1;
}

sub authCheck { #chanmask,hostmask
  my ($chanmask,$hostmask) = @_;
  while (my ($hostreg, $chanreg) = each %permissions) {
    $hostreg =~ s/\*/.*/;
    $chanreg =~ s/\*/.*/;
    $hostreg = qr/$hostreg/;
    $chanreg = qr/$chanreg/;
    if (($hostmask =~ /^$hostreg$/) && ($chanmask =~ /^$chanreg$/)) { return 1; }
  }
  return '';
}

sub authError { #sender,target,location
  actOut('MESSAGE',$_[1],"$_[0]: Sorry. You don't have permission to do that in $_[2].");
}

sub runPlugin { #filepath
  my $plugin = '';
  open(PLUGIN_FILE, $_[0]) or actOut('LITERAL',undef,"error>Could not load plugin file: $_[0]");
  while(my $line = <PLUGIN_FILE>) { $plugin .= $line; }
  close(PLUGIN_FILE);
  eval($plugin);
  if($@) { print "$@\r\n"; }
}

sub parseMessage { #string
  my $string = shift;
  my ($sender,$account,$hostname,$command,$target,$message,$event,$receiver);

  if ($string =~ /^PING(.*)$/i) {
    actOut('LITERAL',undef,"server_send>PONG$1");
    ($sender,$account,$hostname,$command,$target,$message,$receiver) = ('','','','','','','');
    $event = 'on_server_ping';
  }

  elsif ($string =~ /^:$validHumanSender (PRIVMSG) $validChannel :(.*)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    if($target eq $botName) { $event = 'on_private_message'; $target = $sender; }
    else { $event = 'on_public_message'; }
    $receiver = $sender;
    if ($message =~ /@ ?([, $nickCharacters]+)$/) {
      $receiver = $1;
      $message =~ s/ ?@ ?$receiver$//;
    }
  }

  elsif ($string =~ /^:$validHumanSender (NOTICE) $validChannel :(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    if ($target eq $botName) { $event = 'on_private_notice'; $target = $sender; }
    else { $event = 'on_public_notice'; }
  }

  elsif ($string =~ /^:$validHumanSender (JOIN) :?$validChannel$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,'');
    $event = 'on_join';
  }

  elsif ($string =~ /^:$validHumanSender (PART) $validChannel ?:?(.+)?$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    $message = '' unless $message;
    $event = 'on_part';
  }

  elsif ($string =~ /^:$validHumanSender (QUIT) :(.+)?$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,'',$5);
    $event = 'on_quit';
  }

  elsif ($string =~ /^:$validHumanSender (MODE) $validChannel (.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    $event = 'on_mode';
  }

  elsif ($string =~ /^:$validHumanSender (NICK) :?$validNick$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,'',$5);
    $event = 'on_nick';
  }

  elsif ($string =~ /^:$validHumanSender (KICK) $validChannel ?:?(.+)?$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    $message = '' unless $message;
    $event = 'on_kick';
  }

  elsif ($string =~ /^:$validHumanSender (TOPIC) $validChannel ?:?(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$2,$3,$4,$5,$6);
    $event = 'on_topic';
  }

  elsif ($string =~ /^:$validServerSender ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,'','',$2,$3,$4);
    $event = 'on_server_message';
  }

  elsif ($string =~ /^:$validServerSender (332) $validNick $validChannel ?:?(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,$3,'',$2,$4,$5);
    $event = 'on_topic';
  }

  elsif ($string =~ /^ERROR :(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ('','','','','',$1);
    $event = 'on_server_error';
  }

  else {
    actOut('LITERAL',undef,'log_error>Message did not match preparser.');
    actOut('LITERAL',undef,"log_error>$string");
    return '';
  }

  return ($sender,$account,$hostname,$command,$target,$message,$event,$receiver);
}

1;