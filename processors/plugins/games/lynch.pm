if (($event =~ /message/) && ($message =~ /^.lynch ([$valid_nick_characters]+)$/)) {
      ACT('MESSAGE',$target,"The villagers, after much debate, finally decide on lynching \x02$1\x02, who turned out to be... a \x02wolf\x02.");
}