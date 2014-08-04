package PluginParser::Maintenance::StateManagement;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'childid'} eq 'fork1') {
    $core->dictionary_delete('state:channel_users',1);
    $core->dictionary_delete('state:user_channels',1);
    $core->value_set('state:channel_users','NOSAVE',1,1);
    $core->value_set('state:user_channels','NOSAVE',1,1);
  }

  if($core->{'event'} eq 'on_join') {
    return user_add($core,$core->{'chan'},$core->{'nick'});
  }

  if($core->{'event'} eq 'on_quit') {
    return user_remove_all($core,$core->{'nick'});
  }

  if($core->{'event'} eq 'on_kick') {
    $core->{'output'}->parse("MESSAGE>##Gambot>STATE: ".$core->{'nick'}." kicked from ".$core->{'chan'}.".");
  }

  if($core->{'event'} eq 'on_part' and $core->{'nick'} eq $core->{'botname'}) {
    return channel_remove_all($core,$core->{'chan'});
  }

  if($core->{'event'} eq 'on_part') {
    return user_remove($core,$core->{'chan'},$core->{'nick'});
  }

  if($core->{'event'} eq 'on_server_message' and $core->{'command'} eq '353') {
    my @nicks = split(' ',$core->{'message'});
    foreach my $current_nick (@nicks) {
      if($current_nick =~ /$validNick$/) {
        user_add($core,$core->{'chan'},$1);
      }
    }
  }

  return '';
}

sub user_add {
  my ($core,$chan,$nick) = @_;
  $chan = lc($chan);
  $nick = lc($nick);

  $core->value_push('state:channel_users',$chan,$nick,1);
  $core->value_push('state:user_channels',$nick,$chan,1);
  $core->{'output'}->parse("MESSAGE>##Gambutt>STATE: ${nick} added to ${chan}.");

}

sub user_remove {
  my ($core,$chan,$nick) = @_;
  $chan = lc($chan);
  $nick = lc($nick);

  $core->value_pull('state:channel_users',$chan,$nick,1);
  $core->value_pull('state:user_channels',$nick,$chan,1);
  $core->{'output'}->parse("MESSAGE>##Gambutt>STATE: ${nick} removed from ${chan}.");
}

sub user_remove_all {
  my ($core,$nick) = @_;
  $nick = lc($nick);

  my @channels = split(',',$core->value_delete('state:user_channels',$nick));
  foreach my $current_channel (@channels) {
    user_remove($core,$current_channel,$nick);
  }
}

sub channel_remove_all {
  my ($core,$chan) = @_;
  $chan = lc($chan);

  my @nicks = split(',',$core->value_delete('state:channel_users',$chan));
  foreach my $current_nick (@nicks) {
    user_remove($core,$chan,$current_nick);
  }
}