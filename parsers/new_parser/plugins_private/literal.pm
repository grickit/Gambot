if ($message =~ /^${sl}${cm}literal (.+)$/i) {
  my $command = $1;
  if($message =~ /run_command>/) {
    actOut('MESSAGE',$target,"$sender: Sorry. Not even administrators may use the run_command API call. It's just too dangerous.");
  }
  else {
    if ($hostname =~ /^wesnoth\/developer\/grickit$/) {
      actOut('LITERAL',undef,$command);
    }
    else {
      actOut('MESSAGE',$target,"$sender: Who the hell do you think you are?");
    }
  }
}
