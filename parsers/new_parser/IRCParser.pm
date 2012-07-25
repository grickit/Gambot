package IRCParser;

use strict;
use warnings;
use Exporter;
use base 'Exporter';

our @EXPORT = qw(
  stripNewlines
  readInput
  actOut
  authCheck
  authError
  $nickCharacters
  $channelCharacters
  $hostmaskCharacters
  $validNick
  $validChannel
  $validHostmask
  $validHumanSender
  $pipeID
  $botName
  $incomingMessage
  %permissions
);

our $nickCharacters = 'A-Za-z0-9[\]\\`_^{}|-';
our $channelCharacters = '#A-Za-z0-9[\]\\`_^{}|-';
our $hostmaskCharacters = './A-Za-z0-9[\]\\`_^{}|-';
our $validNick = '(['.$nickCharacters.']+)';
our $validChannel = '(['.$channelCharacters.']+)';
our $validHostmask = '(['.$hostmaskCharacters.']+)';
our $validHumanSender = $validNick.'!~?'.$validNick.'@'.$validHostmask;

our $pipeID = readInput();
our $botName = readInput();
our $incomingMessage = readInput();

our %permissions;

sub stripNewlines { #string
  my $string = shift;
  $string =~ s/[\r\n\s\t]+$//;
  return $string;
}

sub readInput { #NONE
  my $message = <STDIN>;
  return stripNewlines($message);
}

sub actOut { #action,target,message
  my @args = @_;
  foreach my $i (0..$#args) { $args[$i] =~ s/[\r\n]+/ /g; }

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
  return 0;
}

sub authError { #sender,target,location
  actOut('MESSAGE',$_[1],"$_[0]: Sorry. You don't have permission to do that in $_[2].");
}

sub parseMessage { #string
  my $string = shift;
  my ($sender,$account,$hostname,$command,$target,$message,$event,$receiver);

  if ($string =~ /^PING(.*)$/i) {
    ACT('LITERAL',undef,"send_server_message>PONG$1");
    ($sender, $account, $hostname, $command, $target, $message) = ('','','','','','');
    $event = 'server_ping';
  }
}

1;