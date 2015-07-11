package PluginParser::Conversation::Quotes;
use strict;
use warnings;
use IRC::Freenode::Specifications;
use PluginParser::Maintenance::Memory;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^quote (\d+) $validNick$/) {
    return recall_quote($core,$core->{'receiver_chan'},$core->{'sender_nick'},$2,int($1));
  }

  if($core->{'message'} =~ /^quote $validNick$/) {
    return recall_quote($core,$core->{'receiver_chan'},$core->{'sender_nick'},$1);
  }

  if($core->{'message'} =~ /^quote $validNick (.+)$/) {
    return recall_topical_quote($core,$core->{'receiver_chan'},$core->{'sender_nick'},$1,$2);
  }

  if($core->{'message'} =~ /^remember $validNick (.+)$/) {
    return remember_quote($core,$core->{'receiver_chan'},$core->{'sender_nick'},$1,$2);
  }


  return '';
}

sub get_quote_count {
  my ($core,$author) = @_;

  return $core->value_get('quote:counts',lc($author)) || 0;
}

sub add_quote {
  my ($core,$author,$message) = @_;
  my $id = $core->value_increment('quote:counts',lc($author),1);

  $core->value_set('quote:messages',lc($author).'#'.$id,$message);

  return $id;
}

sub get_quote {
  my ($core,$author,$id) = @_;

  if(!defined($id)) {
    $id = int(rand(get_quote_count($core,$author))) + 1;
  }

  my $message = $core->value_get('quote:messages',lc($author).'#'.$id);

  if ($message) {
    return "\"${message}\" - ${author} ${id}";
  }

  return '';
}

sub recall_quote {
  my ($core,$chan,$target,$author,$id) = @_;

  if (!get_quote_count($core,$author)) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember anything from $author.");
    return '';
  }

  my $message = get_quote($core,$author,$id);

  if (!$message) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember that quote.");
    return '';
  }

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${message}");
}

sub recall_topical_quote {
  my ($core,$chan,$target,$author,$topic) = @_;

  if (!get_quote_count($core,$author)) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember anything from $author.");
    return '';
  }

  my $message;
  for my $id (1..get_quote_count($core,$author)) {
    next unless $core->value_get('quote:messages',lc($author).'#'.$id) =~ /\Q$topic/i;
    $message = get_quote($core,$author, $id);
    last;
  }

  if (!$message) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember that quote.");
    return '';
  }

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${message}");
}


sub remember_quote {
  my ($core,$chan,$target,$author,$message) = @_;

  if ($author eq $target) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: You're not that memorable to me.");
    return '';
  }

  my @messages = retrieve_messages($core,$chan);
  my $match;

  for my $log (@messages) {
    next unless $log->{'author'} eq $author;
    next unless $log->{'message'} =~ /\Q$message/i;
    $match = $log;
    last;
  }

  if ($match) {
    my $id = add_quote($core,$match->{'author'},$match->{'message'});
    my $quote = get_quote($core,$match->{'author'},$id);
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: Remembered ${quote}");
  } else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: I don't remember what ${author} said about ${message}");
  }
}
