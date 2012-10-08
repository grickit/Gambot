package IRCParser;

use strict;
use warnings;
use Exporter;
use base 'Exporter';

our @EXPORT = qw(
  beginParsing
  stripNewlines
  readInput
  actOut
  authCheck
  authError
  parseMessage
  runPlugin
);

our @EXPORT_OK = qw(
  $nickCharacters
  $serverCharacters
  $channelCharacters
  $hostmaskCharacters
  $validNick
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
);

our $nickCharacters = 'A-Za-z0-9[\]\\`_^{}|-';
our $serverCharacters = 'a-zA-Z0-9\.';
our $channelCharacters = '#A-Za-z0-9[\]\\`_^{}|-';
our $hostmaskCharacters = './A-Za-z0-9[\]\\`_^{}|-';
our $validNick = '(['.$nickCharacters.']+)';
our $validChannel = '(['.$channelCharacters.']+)';
our $validHostmask = '(['.$hostmaskCharacters.']+)';
our $validHumanSender = $validNick.'!~?'.$validNick.'@'.$validHostmask;
our $validServerSender = '(['.$serverCharacters.']+)';

our($pipeID,$botName,$incomingMessage) = ('','','');
our($sender,$account,$hostname,$command,$target,$message,$event,$receiver) = ('','','','','','','','');

our $sl = $botName.'[;,]';
our $cm = '!';
our $version = 'Gambot Core MK III | Plugin Parser 6 ';
our $about = 'I am a basic Gambot. http://grickit.github.com/ irc://chat.freenode.net/%23%23Gambot';

our %permissions;

sub beginParsing {
  $pipeID = readInput();
  $botName = readInput();
  $incomingMessage = readInput();
  ($sender,$account,$hostname,$command,$target,$message,$event,$receiver) = parseMessage($incomingMessage);
}

sub stripNewlines { #string
  my $string = shift;
  if($string) {
    $string =~ s/[\r\n\s\t]+$//;
    return $string;
  }
  return '';
}

sub readInput { #NONE
  my $message = <STDIN>;
  return stripNewlines($message);
}

sub actOut { #action,target,message
  my @args = @_;
  foreach my $i (0..$#args) { $args[$i] = stripNewlines($args[$i]); }

  if($_[0] eq 'MESSAGE')    { print "send_server_message>PRIVMSG $args[1] :$args[2]\n"; }
  elsif($_[0] eq 'ACTION')  { print "send_server_message>PRIVMSG $args[1] :ACTION $args[2]\n"; }
  elsif($_[0] eq 'NOTICE')  { print "send_server_message>NOTICE $args[1] :$args[2]\n"; }
  elsif($_[0] eq 'JOIN')    { print "send_server_message>JOIN $args[1]\n"; }
  elsif($_[0] eq 'PART')    { print "send_server_message>PART $args[1] :$args[2]\n"; }
  elsif($_[0] eq 'KICK')    { print "send_server_message>KICK $args[1] :$args[2]\n"; }
  elsif($_[0] eq 'INVITE')  { print "send_server_message>INVITE $args[1] :$args[2]\n"; }
  elsif($_[0] eq 'MODE')    { print "send_server_message>MODE $args[1] $args[2]\n"; }
  elsif($_[0] eq 'LITERAL') { print "$args[2]\n"; }
  else { print "log>ACTERROR>Unrecognized action: $args[1]"; return ''; }
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
    actOut('LITERAL',undef,"send_server_message>PONG$1");
    ($sender,$account,$hostname,$command,$target,$message,$receiver) = ('','','','','','','');
    $event = 'on_server_ping';
  }

  elsif ($string =~ /^:$validHumanSender (PRIVMSG) $validChannel :(.+)$/) {
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

  elsif ($string =~ /^:$validServerSender ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ($1,'','',$2,$3,$4);
    $event = 'on_server_message';
  }

  elsif ($string =~ /^ERROR :(.+)$/) {
    ($sender,$account,$hostname,$command,$target,$message) = ('','','','','',$1);
    $event = 'on_server_error';
  }

  else {
    actOut('LITERAL',undef,'error>Message did not match preparser.');
    actOut('LITERAL',undef,"error>$string");
    return '';
  }

  return ($sender,$account,$hostname,$command,$target,$message,$event,$receiver);
}

1;