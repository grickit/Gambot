package IRCParser;

use strict;
use warnings;
use Exporter;
use base 'Exporter';

our @EXPORT = qw(
  stripNewlines
  readInput
  actOut
  $nickCharacters
  $channelCharacters
  $hostmaskCharacters
  $validNick $valid_channel
  $validHostmask
  $validHumanSender
  $pipeID
  $botName
  $incomingMessage
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