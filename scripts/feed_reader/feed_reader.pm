#!/usr/bin/perl -I/usr/share/perl5/ -I/usr/lib/perl5/
use strict;
use warnings;
use LWP::UserAgent;
use HTML::Entities;
use DBI;

sub connect_to_database {
  my $db_user = "foo";
  my $db_pass = "bar";
  my $db_connection = DBI->connect('dbi:mysql:Gambot',$db_user,$db_pass) or die "Database connection error: $DBI::errstr\n";
  return $db_connection;
}

sub url_to_entries {
  my ($url, $container_start, $container_end) = @_;

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('franbot/3.0 (Ubuntu 11.04; Perl 5.10)');
  my $response = $request->get($url);
  my $content = $response->decoded_content;

  #Mark the space between tags.
  $content =~ s/>[\s\t\r\n]+</::tagbarrierhere::/g;
  #Clear newlines in the data.
  $content =~ s/[\r\n]+/ /g;
  #Put back the tag barriers
  $content =~ s/::tagbarrierhere::/>\n</g;

  my @lines = split(/\n/,$content);
  my $entry_open = 0;
  my $entry_lines = '';
  my @entries;
  foreach my $line (@lines) {
    $line =~ s/^[\s\t]*//;
    if(!($entry_open) && ($line =~ /^[\s\t]*$container_start[\s\t]*$/)) {
      $entry_open =1;
    }

    elsif(($entry_open) && ($line =~ /^[\s\t]*$container_end[\s\t]*$/)) {
      $entry_open = 0;
      push(@entries, $entry_lines);
      $entry_lines = '';
    }

    elsif(($entry_open)) {
      $entry_lines .= "$line\n";
    }
  }
  return @entries;
}

sub shorten_url {
  my $original_url = shift;
  my $url = "http://tinyurl.com/api-create.php?url=$original_url";

  my $request = LWP::UserAgent->new;
  $request->timeout(60);
  $request->env_proxy;
  $request->agent('franbot/3.0 (Ubuntu 11.04; Perl 5.10)');
  my $response = $request->get($url);
  my $content = $response->decoded_content;
  $content =~ s/[\r\n]*//;

  if ($content =~ /^http/) {
    return $content;
  }
  else {
    print "$content\n";
    return $original_url;
  }
}

sub entry_to_data {
  my ($entry_text, $link_regex, $author_regex, $title_regex, $date_regex) = @_;
  my ($link, $author, $title, $date);

  if($entry_text =~ m/$link_regex/) {
    $link = $1;
    $link = decode_entities($link);
  }

  if($entry_text =~ m/$author_regex/) {
    $author = $1;
    $author = decode_entities($author);
  }

  if($entry_text =~ m/$title_regex/) {
    $title = $1;
    $title = decode_entities($title);
  }

  if($entry_text =~ m/$date_regex/) {
    $date = $1;
  }

  return ($link, $author, $title, $date);
}

sub check_existence {
  my ($db_connection, $feed_id, $link) = @_;
  my $id;
  my $query_string = "SELECT id FROM feed_items WHERE feed_id = ? AND link = ?";
  my $query = $db_connection->prepare($query_string) or die "SQL preparation error: $DBI::errstr\n";
  $query->execute($feed_id, $link) or die "SQL query error: $DBI::errstr\n";
  $query->bind_columns(\$id);
  my $results = $query->rows();
  $query->finish();

  if($results) { return 1; }
  else { return 0; }
}

sub commit_entry {
  my ($db_connection, $site_name, $feed_id, $link, $title, $author, $date, $time) = @_;
  my $query_string = "INSERT INTO feed_items (site_name, feed_id, link, title, author, date, time) VALUES (?, ?, ?, ?, ?, ?, ?)";
  my $query = $db_connection->prepare($query_string) or die "SQL preparation error: $DBI::errstr\n";
  $query->execute($site_name, $feed_id, $link, $title, $author, $date, $time) or die "SQL query error: $DBI::errstr\n";
}

sub get_subscribers {
  my ($db_connection, $source,$feed_id) = @_;
  my @subscribers = ();
  my $subscriber_name;
  my $subscription_name = $source . $feed_id;

  my $query_string = "SELECT name FROM feed_subscriptions WHERE feed_id = ?";
  my $query = $db_connection->prepare($query_string) or die "SQL preparation error: $DBI::errstr\n";
  $query->execute($subscription_name) or die "SQL query error: $DBI::errstr\n";
  $query->bind_columns(\$subscriber_name);

  while($query->fetch()) {
    push(@subscribers,$subscriber_name);
  }

  return @subscribers;
}
1;