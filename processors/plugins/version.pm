if (($event =~ /message/) && ($message =~ /^$sl !?version$/)) {
    ACT('MESSAGE',$target,"$receiver: $version"); 
}
