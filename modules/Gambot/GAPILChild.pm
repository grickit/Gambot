package Gambot::GAPILChild;

use strict;
use warnings;

our $VERSION = 1.0;
our @ISA = qw(Exporter);
our @EXPORT = qw(
  strip_newlines
  stdin_read
  gapil_call
);
our @EXPORT_OK = qw();

sub strip_newlines {
  my $string = shift;

  if($string) {
    $string =~ s/[\r\n\s\t]+$//;
    return $string;
  }
  return '';
}

sub stdin_read { #none
  my $message = <STDIN>;
  return strip_newlines($message);
}

sub gapil_call {
  my ($call,$returns) = @_;

  print "$call\n";
  if($returns) { return stdin_read(); }
  return 1;
}

1;