package PluginParser::Internet::QMarkAPI;
use strict;
use warnings;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(match);

sub match {
  my ($self,$core) = @_;
  if($core->{'receiver_nick'} ne $core->{'botname'}) { return ''; }
  if($core->{'event'} ne 'on_public_message' and $core->{'event'} ne 'on_private_message') { return ''; }


  if($core->{'output'}->{'lines_sent'} == 0) {
    return qmark($core,$core->{'receiver_chan'},$core->{'target'},$core->{'message'});
  }


  return '';
}

sub qmark {
  require LWP::Simple;
  require LWP::UserAgent;
  my ($core,$chan,$target,$message) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('perl Gambot');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $content = $request->post('http://qmarkai.com/qmai.php',{'q' => $message})->decoded_content;
  $content =~ s/[\r\n]+/ /g;

  if($content !~ /<html>/) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${content}");
  }
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: f**k I'm sooo confused %)");
    $core->log_error("Weird QMark output: ${content}");
  }
}
