if ($message =~ /^${sl}${cm}gitpull$/i) {
  if ($hostname =~ /^wesnoth\/developer\/grickit$/) {
    actOut('LITERAL',undef,"run_command>gitpull>sh $FindBin::Bin/plugins_private/gitpull.sh");
  }
  else {
    actOut('MESSAGE',$target,"$sender: Who the hell do you think you are?");
  }
}
