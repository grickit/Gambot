if ($message =~ /^$sl !?version$/) {
    ACT('MESSAGE',$target,"$receiver: $version");
}
