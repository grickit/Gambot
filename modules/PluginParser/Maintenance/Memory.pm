package PluginParser::Maintenance::Memory;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT = qw(retrieve_messages);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'event'} ne 'on_public_message') { return ''; }

  return record_line($core,$core->{'receiver_chan'},$core->{'sender_nick'},$core->{'message'});
}

sub retrieve_messages {
  my ($core,$channel) = @_;
  my %keys = $core->value_dump('memory:messages', '^'.$channel.':');

  my $pointer = $keys{$channel.':pointer'} || 0;
  my $count = $keys{$channel.':count'} || 0;
  my @result;

  for my $index (($pointer..$count-1),(0..$pointer-1)) {
    my $author = $keys{$channel.':'.$index.':author'};
    my $message = $keys{$channel.':'.$index.':message'};
    push(@result,{'author'=>$author,'message'=>$message});
  }

  return @result;
}

sub record_line {
  my ($core,$channel,$nick,$message) = @_;

  my $maxCount = 100;
  my $count = $core->value_get('memory:messages',$channel.':count') || 0;
  my $pointer = $core->value_get('memory:messages',$channel.':pointer') || 0;
  $core->value_set('memory:messages',$channel.':'.$pointer.':author',$nick);
  $core->value_set('memory:messages',$channel.':'.$pointer.':message',$message);
  $core->value_set('memory:messages',$channel.':pointer',($pointer + 1) % $maxCount);
  if ($count < $maxCount) {
    $core->value_set('memory:messages',$channel.':count', $count + 1);
  }
}
