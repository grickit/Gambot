if ($message =~ /^${sl}${cm}quote? ?([0-9]+)? ?(.+)$/i) {
  my ($choice, $person, %quotes, $temp_person, $i) = ('','',(),'',0);
  $choice = $1;
  $person = $2;

  open (QUOTESR,"$FindBin::Bin/plugins/conversation/quotes.txt");
  my @lines = <QUOTESR>;
  close(QUOTESR);

  foreach my $current_line (@lines) {
    if($current_line =~ /^\*(.+)/) {
      $temp_person = $1;
      $i = 1;
    }

    elsif ($current_line =~ /^-(.+)/) {
      $quotes{$temp_person}{$i} = $1;
      $i++;
    }

    elsif ($current_line =~ /^#(.+)/) {
      $quotes{$temp_person}{'size'} = $1;
    }

    elsif ($current_line =~ /^>(.+)/) {
      $quotes{$temp_person} = $quotes{$1};
    }
  }

  $choice = int(rand($quotes{$person}{'size'})) + 1 if !($choice);

  if(!keys %{$quotes{$person}}) { actOut('MESSAGE',$target,"$sender: I couldn't find that person."); }
  elsif(!$quotes{$person}{$choice}) { actOut('MESSAGE',$target,"$sender: I couldn't find that quote."); }
  else { actOut('MESSAGE',$target,"$receiver: \"$quotes{$person}{$choice}\" - $person $choice"); }
}
