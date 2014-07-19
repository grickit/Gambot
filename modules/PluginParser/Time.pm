package PluginParser::Time;
use strict;
use warnings;
use POSIX;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;

  if(!$core->{'pinged'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }

  if($core->{'message'} =~ /^time$/) {
    return time_offset($core,'+0',$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^time utc$/) {
    return time_offset($core,'+0',$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^time ([+-][0-9]+)$/) {
    return time_offset($core,$1,$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^time unix$/) {
    return time_unix($core,$core->{'chan'},$core->{'target'});
  }

  elsif($core->{'message'} =~ /^timestamp$/) {
    return time_unix($core,$core->{'chan'},$core->{'target'});
  }

  return '';
}

sub time_offset {
  my ($core,$offset,$chan,$target) = @_;
  my $time = POSIX::strftime('%H:%M:%S',(gmtime(time+$offset*3600)));

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${time} (UTC${offset})");
}

sub time_unix {
  my ($core,$chan,$target) = @_;
  my $time = time;

  $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${time}");
}