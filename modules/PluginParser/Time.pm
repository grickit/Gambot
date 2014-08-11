package PluginParser::Time;
use strict;
use warnings;
use POSIX;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'message'} =~ /^time$/) {
    return time_offset($core,$core->{'receiver_chan'},$core->{'target'},'+0');
  }

  elsif($core->{'message'} =~ /^time utc$/) {
    return time_offset($core,$core->{'receiver_chan'},$core->{'target'},'+0');
  }

  elsif($core->{'message'} =~ /^time ([+-][0-9]+)$/) {
    return time_offset($core,$core->{'receiver_chan'},$core->{'target'},$1);
  }

  elsif($core->{'message'} =~ /^time unix$/) {
    return time_unix($core,$core->{'receiver_chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^timestamp$/) {
    return time_unix($core,$core->{'receiver_chan'},$core->{'target'});
  }


  return '';
}

sub time_offset {
  my ($core,$chan,$target,$offset) = @_;
  my $time = POSIX::strftime('%H:%M:%S',(gmtime(time+$offset*3600)));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${time} (UTC${offset})");
}

sub time_unix {
  my ($core,$chan,$target) = @_;
  my $time = time;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${time}");
}
