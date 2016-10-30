package PluginParser::Conversation::Quotes;
use strict;
use warnings;
use IRC::Freenode::Specifications;
use PluginParser::Maintenance::Memory;
use Time::Piece;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^quote (\d+) $validNick$/) {
    return recall_quote($core, $core->{'receiver_chan'}, $core->{'target'}, (author => $2, id => int($1)));
  }

  if($core->{'message'} =~ /^quote $validNick$/) {
    return recall_quote($core, $core->{'receiver_chan'}, $core->{'target'}, (author => $1));
  }

  if($core->{'message'} =~ /^quote$/) {
    return recall_quote($core, $core->{'receiver_chan'}, $core->{'target'}, ());
  }

  if($core->{'message'} =~ /^quote \* (.+)$/) {
    return recall_quote($core, $core->{'receiver_chan'}, $core->{'target'}, (topic => $1));
  }

  if($core->{'message'} =~ /^quote $validNick (.+)$/) {
    return recall_quote($core, $core->{'receiver_chan'}, $core->{'target'}, (author => $1, topic => $2));
  }

  if($core->{'message'} =~ /^remember $validNick (.+)$/) {
    return remember_quote($core,$core->{'receiver_chan'},$core->{'target'},$1,$2);
  }


  return '';
}

sub format_quote {
  my ($core, %quote) = @_;

  if (!exists($quote{'key'})) {
    if (exists($quote{'author'})) {
      if (exists($quote{'id'})) {
        $quote{'key'} = lc($quote{'author'}).'#'.$quote{'id'};
      } else {
        my %quotes = $core->value_dump('quote:messages', '^'.lc($quote{'author'}).'#');
        return "I don't remember anything from $quote{'author'}." unless %quotes;
        if (exists($quote{'topic'})) {
          my @candidates = grep { $quotes{$_} =~ /\Q$quote{'topic'}/i } keys %quotes;
          return "I don't remember what $quote{'author'} said about $quote{'topic'}." unless @candidates;
          $quote{'key'} = @candidates[rand @candidates];
        } else {
          $quote{'key'} = (keys %quotes)[rand keys %quotes];
        }
        $quote{'message'} = $quotes{$quote{'key'}};
      }
    } else {
      my %quotes = $core->value_dump('quote:messages', '^');
      return "I don't remember anything." unless %quotes;
      if (exists($quote{'topic'})) {
        my @candidates = grep { $quotes{$_} =~ /\Q$quote{'topic'}/i } keys %quotes;
        return "I don't remember anything about $quote{'topic'}." unless @candidates;
        $quote{'key'} = @candidates[rand @candidates];
      } else {
        $quote{'key'} = (keys %quotes)[rand keys %quotes];
      }
      $quote{'message'} = $quotes{$quote{'key'}};
    }
  }

  ($quote{'author'}, $quote{'id'}) = $quote{'key'} =~ /^(.+)#(\d+)$/;

  if (!exists($quote{'message'})) {
    $quote{'message'} = $core->value_get('quote:messages', $quote{'key'});
  }

  if (!exists($quote{'date'})) {
    $quote{'date'} = $core->value_get('quote:dates', $quote{'key'});
  }

  if ($quote{'author'} && $quote{'id'} && $quote{'message'}) {
    my $result = "\"$quote{'message'}\" - $quote{'author'} $quote{'id'}";
    if ($quote{'date'}) {
      $result .= " ($quote{'date'})";
    }
    return $result;
  } else {
    return "I don't remember that quote.";
  }
}

sub recall_quote {
  my ($core,$chan,$target,%quote) = @_;
  $core->{'output'}->parse("MESSAGE>${chan}>${target}: " . format_quote($core, %quote));
}

sub add_quote {
  my ($core,$author,$message) = @_;
  my $id = $core->value_increment('quote:counts',lc($author),1);

  $core->value_set('quote:messages',lc($author).'#'.$id,$message);
  $core->value_set('quote:dates',lc($author).'#'.$id,localtime->ymd);

  return $id;
}

sub remember_quote {
  my ($core,$chan,$target,$author,$message) = @_;

  if ($author eq $target) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: You're not that memorable to me.");
    return '';
  }

  my @messages = retrieve_messages($core,$chan);
  my $match;

  for my $log (reverse(@messages)) {
    next unless $log->{'author'} eq $author;
    next unless $log->{'message'} =~ /\b\Q$message\E\b/i;
    $match = $log;
    last;
  }

  if ($match) {
    my $id = add_quote($core,$match->{'author'},$match->{'message'});
    my $quote = format_quote($core,(author => $match->{'author'}, id => $id));
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: Remembered ${quote}");
  } else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember what ${author} said about ${message}");
  }
}
