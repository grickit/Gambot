if (($event =~ /message/) && ($message =~ /^$sl !quote? ?([0-9]+)? ?(.+)$/)) {
  my ($choice, $person, $quotes, $temp_person, $i);
  $choice = $1;
  $person = $2;

  open (QUOTESR, "$home_folder/plugins/conversation/quotes.txt");
  my @lines = <QUOTESR>;

  foreach my $current_line (@lines) {
    if($current_line =~ /^\*(.+)/) {
      $temp_person = $1;
      $i = 1;
    }

    elsif ($current_line =~ /^-(.+)/) {
      $main::quotes{$temp_person}{$i} = $1;
      $i++;
    }

    elsif ($current_line =~ /^#(.+)/) {
      $main::quotes{$temp_person}{'size'} = $1;
    }

    elsif ($current_line =~ /^>(.+)/) {
      $main::quotes{$temp_person} = $main::quotes{$1};
    }
  }

  $choice = int(rand($main::quotes{$person}{'size'})) + 1 if !($choice);

  ACT('MESSAGE',$target,"$receiver: \"$main::quotes{$person}{$choice}\" - $person $choice") if ($main::quotes{$person}{$choice});
  ACT('MESSAGE',$target,"$sender: I couldn't find any quotes for that person.") if !($main::quotes{$person}{$choice});
}
