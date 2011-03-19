push (@commands_regexes, "(VERSION|CLIENTINFO) ?");
push (@commands_subs, sub {
  ACT("NOTICE",$sender,"$1 $version"); 
});

push (@commands_regexes, "TIME ?");
push (@commands_subs, sub {
  my $timestamp = strftime('%m-%d-%Y %H:%M:%S',localtime); 
  ACT("NOTICE",$sender,"TIME $timestamp");
});

push (@commands_regexes, "PING [0-9]+");
push (@commands_subs, sub {
  my $timestamp = time; 
  ACT("NOTICE",$sender,"PING $timestamp"); 
});

push (@commands_regexes, "FINGER ?");
push (@commands_subs, sub {
  ACT("NOTICE",$sender,"FINGER Take your fingers off me!"); 
});