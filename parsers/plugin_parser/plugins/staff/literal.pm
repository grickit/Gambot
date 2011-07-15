if ($message =~ /^$sl !literal (.+)$/) {
  my $command = $1;
  if($message =~ /run_command>/) {
    ACT('MESSAGE',$target,"$sender: Sorry. Not even administrators may use the run_command API call. It's just too dangerous.");
  }
  else {
    if ($hostname =~ /^wesnoth\/developer\/grickit$/) {
      ACT('LITERAL',undef,$command);
    }
    else {
      ACT('MESSAGE',$target,"$sender: Who the hell do you think you are?");
    }
  }
}
