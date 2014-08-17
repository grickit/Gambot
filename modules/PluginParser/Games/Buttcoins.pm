package PluginParser::Games::Buttcoins;
use strict;
use warnings;
use IRC::Freenode::Specifications;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if($core->{'event'} eq 'on_public_message') {
    my $word_chosen = buttcoin_get_stat_word_chosen($core);
    if($core->{'message'} =~ /\b$word_chosen\b/i) {
      if($core->{'message'} =~ /\bthe\b/i and $core->{'message'} =~ /\bthat\b/i and $core->{'message'} =~ /\ba\b/i and $core->{'message'} =~ /\band\b/i and $core->{'message'} =~ /\bfor\b/i) {
        buttcoin_track_stat_abuse($core,$core->{'sender_nick'});
      }
      return buttcoin_mine($core,$core->{'sender_nick'},$word_chosen);
    }
  }

  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^buttcoin balance$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_balance($core,$core->{'sender_nick'},$core->{'sender_nick'});
  }

  elsif($core->{'message'} =~ /^buttcoin balance $validNick$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_balance($core,$core->{'sender_nick'},$1);
  }

  elsif($core->{'message'} =~ /^buttcoin stats$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_stats($core,$core->{'sender_nick'},$core->{'sender_nick'});
  }

  elsif($core->{'message'} =~ /^buttcoin stats $validNick$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_stats($core,$core->{'sender_nick'},$1);
  }

  elsif($core->{'message'} =~ /^buttcoin transfer ([0-9]+) $validNick$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_transfer($core,$core->{'sender_nick'},$2,$1,'No reason given.');
  }

  elsif($core->{'message'} =~ /^buttcoin transfer ([0-9]+) $validNick (.+)$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_transfer($core,$core->{'sender_nick'},$2,$1,$3);
  }

  elsif($core->{'message'} =~ /^buttcoin tip $validNick$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_transfer($core,$core->{'sender_nick'},$1,10,'No reason given.');
  }

  elsif($core->{'message'} =~ /^buttcoin tip $validNick (.+)$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_transfer($core,$core->{'sender_nick'},$1,10,$2);
  }

  elsif($core->{'message'} =~ /^$validNick\+\+$/) {
    buttcoin_set_stat_active($core,$core->{'sender_nick'});
    return buttcoin_transfer($core,$core->{'sender_nick'},$1,1,'Plus plus.');
  }

  return '';
}

sub buttcoin_balance {
  my ($core,$target,$nick) = @_;

  my $balance = buttcoin_get_balance($core,$nick);
  my $active = (buttcoin_get_stat_active($core,$nick) ? 'active' : 'inactive');

  $core->{'output'}->parse("NOTICE>${target}>[BALANCE] ${nick} has ${balance} buttcoins (account ${active}).");
}

sub buttcoin_stats {
  my ($core,$target,$nick) = @_;

  my $balance = buttcoin_get_balance($core,$nick);
  my $active = (buttcoin_get_stat_active($core,$nick) ? 'active' : 'inactive');
  my $mined = buttcoin_get_stat_mined($core,$nick);
  my $abuse = buttcoin_get_stat_abuse($core,$nick);
  my $given = buttcoin_get_stat_given($core,$nick);
  my $received = buttcoin_get_stat_received($core,$nick);
  my $unknown = $balance - $mined + $given - $received;

  $core->{'output'}->parse("NOTICE>${target}>[STATS] ${nick} has ${balance} buttcoins (${unknown} unaccounted for) and an ${active} account. They've mined ${mined} buttcoins (${abuse} abusively), given away ${given} buttcoins, and received ${received} as gifts.");
}

sub buttcoin_mine {
  my ($core,$nick,$word) = @_;
  buttcoin_add_balance($core,$nick,1);
  buttcoin_track_stat_mined($core,$nick);
  buttcoin_track_stat_word_average($core,$word);
  buttcoin_track_stat_word_chosen($core);

  my $average = buttcoin_get_stat_word_average($core,$word);

  $core->{'output'}->parse("MESSAGE>##Gambutt>[DEBUG] Buttcoin mined from \"${word}\" (${average} seconds average).");
}

sub buttcoin_transfer {
  my ($core,$sender,$receiver,$value,$message) = @_;
  my $sender_balance = buttcoin_get_balance($core,$sender);
  my $receiver_balance = buttcoin_get_balance($core,$receiver);

  if(lc($sender) eq lc($receiver)) { $core->{'output'}->parse("NOTICE>${sender}>[ERROR] You are ${receiver}."); return ''; }
  if($value <= 0) { $core->{'output'}->parse("NOTICE>${sender}>[ERROR] You must send at least 1 buttcoin."); return ''; }
  if($value > $sender_balance) { $core->{'output'}->parse("NOTICE>${sender}>[ERROR] You only have ${sender_balance} buttcoins."); return ''; }
  if(!buttcoin_get_stat_active($core,$receiver)) { $core->{'output'}->parse("NOTICE>${sender}>[ERROR] You can only send buttcoins to those with active buttcoin accounts. Users can active their buttcoin account by using any buttcoin related command."); return ''; }

  buttcoin_sub_balance($core,$sender,$value);
  buttcoin_add_balance($core,$receiver,$value);
  $sender_balance -= $value;
  $receiver_balance += $value;
  buttcoin_track_stat_given($core,$sender,$value);
  buttcoin_track_stat_received($core,$receiver,$value);

  $core->{'output'}->parse("NOTICE>$sender>[TRANSFER] You (${sender_balance}) have sent $value buttcoins to $receiver (${receiver_balance}).");
  $core->{'output'}->parse("NOTICE>$receiver>[TRANSFER] You (${receiver_balance}) have received $value buttcoins from $sender (${sender_balance}). [${message}]");
}

#===== GETTERS =====#
sub buttcoin_get_stat_active {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:stats:active',lc($nick)) || 0;
}

sub buttcoin_get_balance {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:balance',lc($nick)) || 0;
}

sub buttcoin_get_stat_mined {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:stats:mined',lc($nick)) || 0;
}

sub buttcoin_get_stat_abuse {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:stats:abuse',lc($nick)) || 0;
}

sub buttcoin_get_stat_given {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:stats:gifted',lc($nick)) || 0;
}

sub buttcoin_get_stat_received {
  my ($core,$nick) = @_;
  return $core->value_get('buttcoin:stats:received',lc($nick)) || 0;
}

sub buttcoin_get_stat_word_chosen {
  my ($core) = @_;
  return $core->value_get('buttcoin:metadata','word_chosen') || 'the';
}

sub buttcoin_get_stat_word_average {
  my ($core,$word) = @_;
  my $count = $core->value_get('buttcoin:metadata','word_count:'.$word);
  my $time = $core->value_get('buttcoin:metadata','word_time:'.$word);
  return ($time/$count);
}



#===== SETTERS =====#
sub buttcoin_set_stat_active {
  my ($core,$nick) = @_;
  return $core->value_set('buttcoin:stats:active',lc($nick),1);
}

sub buttcoin_add_balance {
  my ($core,$nick,$value) = @_;
  return $core->value_increment('buttcoin:balance',lc($nick),$value);
}

sub buttcoin_sub_balance {
  my ($core,$nick,$value) = @_;
  return $core->value_decrement('buttcoin:balance',lc($nick),$value);
}

sub buttcoin_track_stat_word_chosen {
  my ($core) = @_;
  my @word_list = ('the','that','a','and','for');
  return $core->value_set('buttcoin:metadata','word_chosen',$word_list[int(rand(5))]);
}

sub buttcoin_track_stat_mined {
  my ($core,$nick) = @_;
  return $core->value_increment('buttcoin:stats:mined',lc($nick),1);
}

sub buttcoin_track_stat_given {
  my ($core,$nick,$value) = @_;
  return $core->value_increment('buttcoin:stats:gifted',lc($nick),$value);
}

sub buttcoin_track_stat_received {
  my ($core,$nick,$value) = @_;
  return $core->value_increment('buttcoin:stats:received',lc($nick),$value);
}

sub buttcoin_track_stat_abuse {
  my ($core,$nick) = @_;
  return $core->value_increment('buttcoin:stats:abuse',lc($nick),1);
}

sub buttcoin_track_stat_word_average {
  my ($core,$word) = @_;

  my $timestamp = $core->value_get('buttcoin:metadata','timestamp') || time;
  $core->value_set('buttcoin:metadata','timestamp',time);
  $core->value_increment('buttcoin:metadata','word_count:'.$word,1);
  $core->value_increment('buttcoin:metadata','word_time:'.$word,(time-$timestamp));
  return 1;
}
