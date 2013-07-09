#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/

package StreamReader;
use strict;
use warnings;
use URI::Escape;
use Digest::SHA qw(hmac_sha1_base64);
use Exporter;
use base 'Exporter';

use lib "$FindBin::Bin/../../modules/";
use JSON::JSON;

$| = 1;
binmode STDOUT, ":utf8";

our @EXPORT = qw(
  oauthGenerateTimestamp
  oauthGenerateNonce
  oauthGenerateBaseString
  oauthGenerateSignatureBaseString
  oauthGenerateSigningKey
  oauthGenerateSignature
);

our @EXPORT_OK = qw(
  $oauthConsumerKey
  $oauthAccessKey
  $oauthConsumerSecret
  $oauthAccessSecret
  $oauthSignatureMethod;
  $oauthVersion
  $oauthNonce
);

# TODO: PRIVATE!
our $oauthConsumerKey = '';
our $oauthAccessKey = '';
our $oauthConsumerSecret = '';
our $oauthAccessSecret = '';

our $oauthSignatureMethod = 'HMAC-SHA1';
our $oauthVersion = '1.0';
our $oauthTimestamp = oauthGenerateTimestamp();
our $oauthNonce = oauthGenerateNonce();

sub oauthGenerateTimestamp {
  my $timestamp = time;
  #print 'Timestamp:'."\n".$timestamp."\n\n";
  return $timestamp;
}

sub oauthGenerateNonce {
  my $nonce = hmac_sha1_base64(time,rand(9999999999));
  $nonce =~ s/[^\w]//ig;
  #print 'Nonce:'."\n".$nonce."\n\n";
  return $nonce;
}

sub oauthGenerateBaseString {
  my $arguments = $_[0];
  my @base_string_tokens;

  $arguments->{'oauth_consumer_key'} = $oauthConsumerKey;
  $arguments->{'oauth_nonce'} = $oauthNonce;
  $arguments->{'oauth_signature_method'} = $oauthSignatureMethod;
  $arguments->{'oauth_timestamp'} = $oauthTimestamp;
  $arguments->{'oauth_token'} = $oauthAccessKey;
  $arguments->{'oauth_version'} = $oauthVersion;

  foreach my $key (sort keys %$arguments) {
    push(@base_string_tokens,$key.'='.$arguments->{$key});
  }

  my $base_string = join('&',@base_string_tokens);
  #print 'Base string:'."\n".$base_string."\n\n";
  return $base_string;
}

sub oauthGenerateSignatureBaseString {
  my $method = $_[0];
  my $url = $_[1];
  my $base_string = $_[2];

  my $signature_base_string = $method.'&'.uri_escape($url).'&'.uri_escape($base_string);
  #print 'Signature base string:'."\n".$signature_base_string."\n\n";
  return $signature_base_string;  
}

sub oauthGenerateSigningKey {
  my $signing_key = uri_escape($oauthConsumerSecret).'&'.uri_escape($oauthAccessSecret);
  #print 'Signing key:'."\n".$signing_key."\n\n";
  return $signing_key;
}

sub oauthGenerateSignature {
  my $signature_base_string = $_[0];
  my $signing_key = $_[1];

  my $signature = hmac_sha1_base64($signature_base_string,$signing_key).'=';
  $signature =~ s/[\r\n\s]+$//;
  #print 'Signature:'."\n".$signature."\n\n";
  return $signature;
}

sub oauthGenerateCurlCommand {
  my $method = $_[0];
  my $url = $_[1];
  my $signature = $_[2];
  my $arguments = $_[3];

  my $curl_command = 'curl --request \''.$method.'\' \''.$url.'\'';
  foreach my $key (sort keys %$arguments) {
    $curl_command .= ' --data \''.$key.'='.$arguments->{$key}.'\'';
  }
  $curl_command .= ' --header \'Authorization: OAuth';
  $curl_command .= ' oauth_consumer_key="'.uri_escape($oauthConsumerKey).'",';
  $curl_command .= ' oauth_nonce="'.uri_escape($oauthNonce).'",';
  $curl_command .= ' oauth_signature="'.uri_escape($signature).'",';
  $curl_command .= ' oauth_signature_method="'.uri_escape($oauthSignatureMethod).'",';
  $curl_command .= ' oauth_timestamp="'.uri_escape($oauthTimestamp).'",';
  $curl_command .= ' oauth_token="'.uri_escape($oauthAccessKey).'",';
  $curl_command .= ' oauth_version="'.uri_escape($oauthVersion).'"\'';
  $curl_command .= ' -Ns';
  #print 'Curl command:'."\n".$curl_command."\n\n";
  return $curl_command;
}

1;