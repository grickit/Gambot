use strict;
use warnings;

my $have_output = 0;

my %permissions;
$permissions{'wesnoth/developer/*'} 			= '#wesnoth*';
$permissions{'wesnoth/artist/*'} 			= '#wesnoth*';
$permissions{'wesnoth/forumsith/*'} 			= '#wesnoth*';

$permissions{'wesnoth/developer/dave'} 			= '#frogatto*';
$permissions{'wesnoth/developer/crimson_penguin'} 	= '#frogatto*';
$permissions{'wesnoth/artist/jetrel'}		 	= '#frogatto*';
$permissions{'unaffiliated/marcavis*'}	 		= '#frogatto*';

$permissions{'unaffiliated/dreadknight'} 		= '#AncientBeast';

$permissions{'unaffiliated/gambit/bot/*'} 		= '##Gambot*';
$permissions{'wesnoth/developer/grickit'}	 	= '*';
$permissions{'wesnoth/developer/shadowmaster*'} 	= '*';

my $events = {
  'server_ping' => \&on_ping,
  'private_message' => \&on_private_message,
  'public_message' => \&on_public_message,
  'private_notice' => \&on_private_notice,
  'public_notice' => \&on_public_notice,
  'join' => \&on_join,
  'part' => \&on_part,
  'quit' => \&on_quit,
  'mode' => \&on_mode,
  'nick' => \&on_nick,
  'kick' => \&on_kick,
  'server_message' => \&on_server_message,
  'error' => \&on_error
};

sub startup_variables {
  my $pipe_id = <STDIN>;
  my $bot_name = <STDIN>;
  my $incoming_message = <STDIN>;
  $pipe_id =~ s/[\r\n\s\t]+$//;
  $bot_name =~ s/[\r\n\s\t]+$//;
  $incoming_message =~ s/[\r\n\s\t]+$//;
  return ($pipe_id, $bot_name, $incoming_message);
}

sub CheckAuth {
  my $chanmask = $_[0];
  my $hostmask = $_[1];
  while (my ($hostreg, $chanreg) = each %permissions) {
    $hostreg =~ s/\*/.*/;
    $chanreg =~ s/\*/.*/;
    $hostreg = qr/$hostreg/;
    $chanreg = qr/$chanreg/;
    if (($hostmask =~ /^$hostreg$/) && ($chanmask =~ /^$chanreg$/)) { return 1; }
  }
  return 0;
}

sub AuthError {
  my ($sender, $target, $location) = @_;
  ACT('MESSAGE',$target,"$sender: Sorry. You don't have permission to do that in $location.");
}

sub have_output {
  return $have_output;
}

sub ACT {
  if ($_[0] eq 'MESSAGE') { print "send_server_message>PRIVMSG $_[1] :$_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'ACTION') { print "send_server_message>PRIVMSG $_[1] :ACTION $_[2]\nsleep>0.25\n"; }
  elsif (($_[0] eq 'NOTICE') || ($_[0] eq 'PART') || ($_[0] eq 'KICK') || ($_[0] eq 'INVITE')) { print "send_server_message>$_[0] $_[1] :$_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'JOIN') { print "send_server_message>JOIN $_[1]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'MODE') { print "send_server_message>MODE $_[1] $_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'LITERAL') { print "$_[2]\n"; }
  $have_output = 1;
}

sub fire_event {
  my $event = shift;
  $events->{$event}->();
}

sub parse_message {
  my ($self, $incoming_message) = @_;

  my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-';
  my $valid_chan_characters = "#$valid_nick_characters";
  my $valid_human_sender_regex = "([.$valid_nick_characters]+)!~?([.$valid_nick_characters]+)@(.+?)";

  my ($sender, $account, $hostname, $command, $target, $message);
  my $event;
  my $receiver;

  if ($incoming_message =~ /^PING(.*)$/i) {
    ACT("LITERAL",undef,"send_server_message>PONG$1");
    ($sender, $account, $hostname, $command, $target, $message) = ('', '', '', '', '', '');
    $event = 'server_ping';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (PRIVMSG) ([$valid_chan_characters]+) :(.+)$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    if ($target eq $self) { $event = 'private_message'; $target = $sender; }
    else { $event = 'public_message'; }
    $receiver = $sender;
    if ($message =~ /@ ?([, $valid_nick_characters]+)$/) {
      $receiver = $1;
      $message =~ s/ ?@ ?([, $valid_nick_characters]+)$//;
    }
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (NOTICE) ([$valid_chan_characters]+) :(.+)$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    if ($target eq $self) { $event = 'private_notice'; $target = $sender; }
    else { $event = 'public_notice'; }
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (JOIN) :([$valid_chan_characters]+)$/) {
    ($sender, $account, $hostname, $command, $target) = ($1, $2, $3, $4, $5);
    $message = '';
    $event = 'join';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (PART) ([$valid_chan_characters]+) ?:?(.+)?$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $message = '' unless $message;
    $event = 'part';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (QUIT) :(.+)?$/) {
    ($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
    $target = '';
    $event = 'quit';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (MODE) ([$valid_chan_characters]+) (.+)$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $event = 'mode';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (NICK) :(.+)$/) {
    ($sender, $account, $hostname, $command, $message) = ($1, $2, $3, $4, $5);
    $target = '';
    $event = 'nick';
  }

  elsif ($incoming_message =~ /^:$valid_human_sender_regex (KICK) ([$valid_chan_characters]+) ?:?(.+)?$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $2, $3, $4, $5, $6);
    $message = '' unless $message;
    $event = 'kick';
  }

  elsif ($incoming_message =~ /^:(.+?) ([a-zA-Z0-9]+) (.+?) :?(.+)$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ($1, $1, $1, $2, $3, $4);
    $event = 'server_message';
  }

  elsif ($incoming_message =~ /^ERROR :(.+)$/) {
    ($sender, $account, $hostname, $command, $target, $message) = ('','','','','',$1);
    $event = 'error';
  }

  else {
    ACT('LITERAL',undef,"log>APIERROR>Message did not match preparser.");
    ACT('LITERAL',undef,"log>APIERROR>$incoming_message");
    exit();
  }

  return ($event, $sender, $account, $hostname, $command, $target, $message, $receiver);
}