package PluginParser::Internet::QMarkAPI;
use strict;
use warnings;
use LWP::Simple;
use LWP::UserAgent;
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
  my ($core,$chan,$target,$message) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)');
  $request->max_size('1024000');
  $request->parse_head(0);
  my $content = $request->post('http://qmark.tk/qmai.php',{'q' => $message})->decoded_content;
  $content =~ s/[\r\n]+/ /g;

  if($content !~ /<html>/) {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: ${content}");
  }
  else {
    $core->{'output'}->parse("MESSAGE>${chan}>${target}: f**k I'm sooo confused %)");
    $core->log_error("Weird QMark output: ${content}");
  }
}
