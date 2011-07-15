#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
# Copyright (C) 2010-2011 by Derek Hoagland <grickit@gmail.com>
# This file is part of Gambot.
#
# Gambot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Gambot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Gambot.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

####-----#----- Setup -----#-----####
$| = 1;
my %banlist;
my $channel = '##Gambot';
my $self = 'kairibot';
my $valid_nick_characters = 'A-Za-z0-9[\]\\`_^{}|-';

my %players;
my $time = 'setup';
my $minplayers = 4;

my $timer = 0;
my $numwaits = 0;

my ($maxwolves, $maxseers, $maxharlots, $maxgunners) = (0,0,0,0);

my $wolfvotesneeded = 0;
my $seer = '';
my $seersaw = '';
my $harlot = '';
my $harlotvisited = '';
my $deadman = '';

my $lynchvotesneeded = 0;

my $nightstart = 999999999999;

####-----#----- IRC Management -----#-----####
sub ACT {
  if ($_[0] eq 'MESSAGE') { print "send_server_message>PRIVMSG $_[1] :$_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'ACTION') { print "send_server_message>PRIVMSG $_[1] :ACTION $_[2]\nsleep>0.25\n"; }
  elsif (($_[0] eq 'NOTICE') || ($_[0] eq 'PART') || ($_[0] eq 'KICK') || ($_[0] eq 'INVITE')) { print "send_server_message>$_[0] $_[1] :$_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'JOIN') { print "send_server_message>JOIN $_[1]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'MODE') { print "send_server_message>MODE $_[1] $_[2]\nsleep>0.25\n"; }
  elsif ($_[0] eq 'LITERAL') { print "$_[2]\n"; }
}


####-----#----- Data Management -----#-----####
sub numplayers {
  return scalar(keys %players);
}

sub playerexists {
  return defined($players{$_[0]});
}

sub playerbanned {
  return defined($banlist{$_[0]});
}

sub playersarray {
  my @playersarray;
  while (my ($person, $value) = each %players ) {
    push(@playersarray,$person);
  }
  return @playersarray;
}

sub randomplayer {
  my @playersarray = playersarray();
  my $person = $playersarray[int(rand(scalar(@playersarray)))];
  return $person;
}

sub removeplayer {
  my $person = shift;
  delete $players{$person};
  ACT('MODE',$channel,"-v $person");
  checkplayers();
}


####-----#----- Gameplay Management -----#-----####
sub checkplayers {
  my $flags = '';
  my $people = '';
  my $message = '';
  my $good = 0;
  my $evil = 0;
  my $result = '';
  while (my ($person, $value) = each %players ) {
    $flags .= '-v';
    $people .= " $person";
    if ($players{$person}{'role'} eq 'wolf') {
      $message .= " $person was a $players{$person}{'role'}.";
      $evil++;
    }
    elsif ($players{$person}{'role'} eq 'seer' || $players{$person}{'role'} eq 'harlot' || $players{$person}{'role'} eq 'gunner') {
      $message .= " $person was a $players{$person}{'role'}.";
      $good++;
    }
    else { $good++; }
  }
  $message =~ s/^\s+//;
  if ($evil == 0) { $result = 'The villagers won.'; endgame("$flags$people",$result,$message); }
  elsif ($evil >= $good) { $result = 'The wolves won.'; endgame("$flags$people",$result,$message); }
}

sub endgame {
  my ($flags, $result, $roles) = @_;
  ACT('MODE',$channel,"-m");
  ACT('MODE',$channel,"$flags");
  ACT('MESSAGE',$channel,"In the end: $result");
  ACT('MESSAGE',$channel,"$roles");
  exit();
}

sub assignroles {
  if (numplayers() >= 4) {
    $maxseers = 1;
  }
  if (numplayers() >= 6) {
    $maxharlots = 1;
  }
  if (numplayers() >= 12) {
    $maxgunners = 1;
  }

  if (numplayers() == 3) {
    $maxwolves = 1;
  }
  else {
    $maxwolves = int(numplayers() / 4);
  }

  ACT('MESSAGE',$channel,"There will be $maxwolves wolves, $maxseers seers, $maxharlots harlots, and $maxgunners gunners. Assigning those roles now.");

  for (my $i = 0; $i < $maxwolves; 1) {
    my $person = randomplayer();
    unless (defined $players{$person}{'role'}) {
      $players{$person}{'role'} = 'wolf';
      $i++;
    }
  }

  for (my $i = 0; $i < $maxseers; 1) {
    my $person = randomplayer();
    unless (defined $players{$person}{'role'}) {
      $players{$person}{'role'} = 'seer';
      $i++;
    }
  }

  for (my $i = 0; $i < $maxharlots; 1) {
    my $person = randomplayer();
    unless (defined $players{$person}{'role'}) {
      $players{$person}{'role'} = 'harlot';
      $i++;
    }
  }

  for (my $i = 0; $i < $maxgunners; 1) {
    my $person = randomplayer();
    unless (defined $players{$person}{'role'}) {
      $players{$person}{'role'} = 'gunner';
      $i++;
    }
  }

  while (my ($person, $value) = each %players) {
    unless (defined $players{$person}{'role'}) {
      $players{$person}{'role'} = 'villager';
    }
  }

  nightly_messages();
}

sub nightly_messages {
  if (playerexists($deadman)) {
    ACT('MESSAGE',$channel,"Because they were suspected of being a wolf, $deadman was drug out to the big oak tree and hung. Turns out they were a $players{$deadman}{'role'}");
    removeplayer($deadman);
  }
  $seer = '';
  $seersaw = '';
  $harlot = '';
  $harlotvisited = '';
  $deadman = '';
  my $numwolves = 0;
  while (my ($person, $value) = each %players) {
    $players{$person}{'used'} = 0;
    $players{$person}{'wolfvotes'} = 0;
    $players{$person}{'wolfvoted'} = '';

    if ($players{$person}{'role'} eq 'wolf') {
      ACT('NOTICE',$person,"You are a wolf. You can vote on who the wolf team should eat. \"/msg kairibot eat [playername]\"");
      $numwolves++;
    }

    if ($players{$person}{'role'} eq 'seer') {
      $seer = $person;
      ACT('NOTICE',$person,"You are a seer. You can see one other player's role. \"/msg kairibot see [playername]\"");
    }

    if ($players{$person}{'role'} eq 'harlot') {
      $harlot = $person;
      ACT('NOTICE',$person,"You are a harlot (like your mother). You can visit another player. \"/msg kairibot visit [playername]\"");
    }
  }
  $wolfvotesneeded = int(($numwolves / 2) + 1);
  ACT('MESSAGE',$channel,"It is now night time. I just queried everyone with instructions. If you didn't get a message, it's because God hate you. So sit down and shut up until morning.");
  ACT('MESSAGE',$channel,"$wolfvotesneeded votes are needed to eat someone.");
  $time = 'night';
  $nightstart = time();
}

sub daily_messages {
  if (playerexists($deadman)) {
    if (($players{$deadman}{'role'} eq 'harlot') && ($players{$deadman}{'used'} == 1)) {
      ACT('MESSAGE',$channel,"The wolves attempted to eat the harlot last night. But she was out.");
    }
    else {
      ACT('MESSAGE',$channel,"The half-eaten corpse of $deadman - a $players{$deadman}{'role'} - was found in the morning.");
    }
  }
  else {
    ACT('MESSAGE',$channel,"Several dead sheep were found in the morning.");
  }
  if (playerexists($harlotvisited)) {
    if ($players{$harlotvisited}{'role'} eq 'wolf') {
      ACT('MESSAGE',$channel,"Unfortunately, $harlot" . "'s half eaten corpse was found in streets this morning. Looks like they visited a wolf last night.");
      if (playerexists($harlot)) { removeplayer($harlot); }
    }
    elsif($harlotvisited eq $deadman) {
      ACT('MESSAGE',$channel,"$harlot" . "'s half eaten corpse was also found in $deadman" . "'s house.");
      if (playerexists($harlot)) { removeplayer($harlot); }
      if (playerexists($deadman)) { removeplayer($deadman); }
    }
  }
  if (playerexists($deadman)) { removeplayer($deadman); }

  while (my ($person, $value) = each %players) {
    $players{$person}{'used'} = 0;
    $players{$person}{'lynchvotes'} = 0;
    $players{$person}{'lynchvoted'} = '';
    if ($players{$person}{'role'} eq 'gunner') {
      ACT('NOTICE',$person,"You are a gunner. You can shoot someone. If they're a wolf they will definitely die. If they're aren't, then they will only probably die. \".shoot [playername]\"");
    }
  }
  $lynchvotesneeded = int((numplayers() / 2) + 1);
  ACT('MESSAGE',$channel,"It is now day time. The villagers get to vote on who they think the wolf is. \".lynch [playername]\"");
  ACT('MESSAGE',$channel,"$lynchvotesneeded votes are needed to lynch someone.");
  $time = 'day';
}

sub checkmovetoday {
  if (playerexists($deadman) && (playerexists($harlotvisited) || !playerexists($harlot)) && (playerexists($seersaw) || !playerexists($seer))) {
    daily_messages();
  }
}

sub checkwolfvotes {
  while (my ($person, $value) = each %players) {
    if ($players{$person}{'wolfvotes'} >= $wolfvotesneeded) {
      $deadman = $person;
    }
    checkmovetoday();
  }
}

sub checklynchvotes {
  while (my ($person, $value) = each %players) {
    if ($players{$person}{'lynchvotes'} >= $lynchvotesneeded) {
      $deadman = $person;
    }
  }
  if (playerexists($deadman)) {
    nightly_messages();
  }
}

sub checktime {
  if ($time eq 'night') {
    if ((time() - $nightstart) >= 180) {
      ACT('MESSAGE',$channel,"It has been over 3 minutes. Night is over.");
      daily_messages();
    }
  }
}

####-----#----- Request Management -----#-----####
sub join_request {
  my $person = shift;
  if($time eq 'setup') {
    if(playerbanned($person)) { ACT('NOTICE',$person,"Sorry. You're banned."); }
    elsif (playerexists($person)) { ACT('NOTICE',$person,"You're already in the game."); }
    else {
      ACT('MESSAGE',$channel,"$person has joined the game.");
      $players{$person} = {};
      ACT('MODE',$channel,"+v $person");
    }
  }
}

sub leave_request {
  my $person = shift;
  if (playerexists($person)) {
    if ($time eq 'setup') {
      delete $players{$person};
      ACT('MODE',$channel,"-v $person");
      ACT('MESSAGE',$channel,"$person has left the game.");
    }
    else {
      ACT('MESSAGE',$channel,"$person was struck by lightning. They were a $players{$person}{'role'}.");
      removeplayer($person);
    }
    if ($time eq 'setup' && numplayers() == 0) {
      ACT('MESSAGE',$channel,"No players left. Closing this game attempt.");
      exit();
    }
  }
}

sub start_request {
  if ($time eq 'setup') {
    my $timediff = time() - $timer;
    if ($timediff >= 30) {
      if(numplayers() >= $minplayers) {
	ACT('MESSAGE',$channel,"Starting the game.");
	ACT('MODE',$channel,'+m');
	assignroles();
      }
      else {
	ACT('MESSAGE',$channel,"Sorry. You have " . numplayers() . " players, but you need at least $minplayers to play.");
      }
    }
    else {
      my $timeleft = 30 - $timediff;
      ACT('MESSAGE',$channel,"Sorry. Please wait another $timeleft seconds before starting.");
    }
  }
}

sub wait_request {
  if ($time eq 'setup') {
    if ($numwaits <= 2) {
      ACT('MESSAGE',$channel,"Stalling for 30 seconds.");
      $timer = time();
      $numwaits++;
    }
    else {
      ACT('MESSAGE',$channel,"Sorry. Already waited $numwaits times.");
    }
  }
}

sub see_request {
  my ($person, $target) = @_;
  if ($time ne 'night') { ACT('NOTICE',$person,"It's not time to use that."); }
  else {
    if ($person eq $target) { ACT('NOTICE',$person,"You can't see yourself."); }
    else {
      if ($players{$person}{'role'} ne 'seer') { ACT('NOTICE',$person,"You're not a seer."); }
      else {
	if ($players{$person}{'used'}) { ACT('NOTICE',$person,"You've already used your power tonight."); }
	else {
	  if (!(playerexists($target))) { ACT('NOTICE',$person,"$target isn't playing."); }
	  else {
	    ACT('NOTICE',$person,"$target is a $players{$target}{'role'}.");
	    $seersaw = $target;
	    $players{$person}{'used'} = 1;
	    checkmovetoday();
	  }
	}
      }
    }
  }
}

sub visit_request {
  my ($person, $target) = @_;
  if ($time != 'night') { ACT('NOTICE',$person,"It's not time to use that."); }
  else {
    if ($person eq $target) { ACT('NOTICE',$person,"You can't visit yourself."); }
    else {
      if ($players{$person}{'role'} ne 'harlot') { ACT('NOTICE',$person,"You're not a harlot."); }
      else {
	if ($players{$person}{'used'}) { ACT('NOTICE',$person,"You've already used your power tonight."); }
	else {
	  if (!(playerexists($target))) { ACT('NOTICE',$person,"$target isn't playing."); }
	  else {
	    ACT('NOTICE',$person,"Okay. Visiting $target.");
	    ACT('NOTICE',$target,"A harlot is visiting you tonight. Enjoy.");
	    $players{$person}{'used'} = 1;
	    $harlotvisited = $target;
	    checkmovetoday();
	  }
	}
      }
    }
  }
}

sub eat_request {
  my ($person, $target) = @_;
  if ($time ne 'night') { ACT('NOTICE',$person,"It's not time to use that."); }
  else {
    if ($person eq $target) { ACT('NOTICE',$person,"You can't eat yourself."); }
    else {
      if ($players{$person}{'role'} ne 'wolf') { ACT('NOTICE',$person,"You're not a wolf."); }
      else {
	if (!(playerexists($target))) { ACT('NOTICE',$person,"$target isn't playing."); }
	else {
	  if ($players{$target}{'role'} eq 'wolf') { ACT('NOTICE',$person,"You can't eat another wolf."); }
	  else {
	    if (playerexists($players{$person}{'wolfvoted'})) {
	      ACT('NOTICE',$person,"Okay. Switching vote from $players{$person}{'wolfvoted'} to $target.");
	      $players{$players{$person}{'wolfvoted'}}{'wolfvotes'}--;
	      $players{$target}{'wolfvotes'}++;
	      $players{$person}{'wolfvoted'} = $target;
	      checkwolfvotes();
	    }
	    else {
	      ACT('NOTICE',$person,"Okay. Voted for $target.");
	      $players{$target}{'wolfvotes'}++;
	      $players{$person}{'wolfvoted'} = $target;
	      checkwolfvotes();
	    }
	  }
	}
      }
    }
  }
}

sub lynch_request {
  my ($person, $target) = @_;
  if ($time ne 'day') { ACT('NOTICE',$person,"It's not time to use that."); }
  else {
    if (!(playerexists($target))) { ACT('NOTICE',$person,"$target isn't playing."); }
    else {
      if (playerexists($players{$person}{'lynchvoted'})) {
	ACT('MESSAGE',$channel,"$person switched their vote from $players{$person}{'lynchvoted'} to $target.");
	$players{$players{$person}{'lynchvoted'}}{'lynchvotes'}--;
	$players{$target}{'lynchvotes'}++;
	$players{$person}{'lynchvoted'} = $target;
	checklynchvotes();
      }
      else {
	ACT('MESSAGE',$channel,"$person voted for $target.");
	$players{$target}{'lynchvotes'}++;
	$players{$person}{'lynchvoted'} = $target;
	checklynchvotes();
      }
    }
  }
}

sub retract_request {
  my $person = shift;
  if ($time ne 'day') { ACT('NOTICE',$person,"It's not time to use that."); }
  else {
      ACT('MESSAGE',$channel,"$person retracted their vote.");
      $players{$players{$person}{'lynchvoted'}}{'lynchvotes'}--;
      $players{$person}{'lynchvoted'} = '';
  }
}


####-----#----- Main loop -----#-----####
while (my $request = <STDIN>) {
  $request =~ s/[\r\n\t\s]+$//;
  if ($request =~ /^join>([$valid_nick_characters]+)$/) { join_request($1); }
  elsif ($request =~ /^leave>([$valid_nick_characters]+)$/) { leave_request($1); }
  elsif ($request =~ /^start>$/) { start_request(); }
  elsif ($request =~ /^wait>$/) { wait_request(); }

  elsif ($request =~ /^check_time>$/) { checktime(); }

  elsif ($request =~ /^eat>([$valid_nick_characters]+)>([$valid_nick_characters]+)$/) { eat_request($1,$2); }
  elsif ($request =~ /^see>([$valid_nick_characters]+)>([$valid_nick_characters]+)$/) { see_request($1,$2); }
  elsif ($request =~ /^visit>([$valid_nick_characters]+)>([$valid_nick_characters]+)$/) { visit_request($1,$2); }
  elsif ($request =~ /^shoot>([$valid_nick_characters]+)>([$valid_nick_characters]+)$/) { shoot_request($1,$2); }

  elsif ($request =~ /^lynch>([$valid_nick_characters]+)>([$valid_nick_characters]+)$/) { lynch_request($1,$2); }
  elsif ($request =~ /^retract>([$valid_nick_characters]+)$/) { retract_request($1); }

  select(undef,undef,undef,0.1);
}
