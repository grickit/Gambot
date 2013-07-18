if ($message =~ /^${sl}${cm}ban $validNick ?([0-9]+)?([hmsdw])? ?(.+)?$/i) {
  my $kickmessage = "[requested by $sender]";
  $kickmessage .= ": $4" if $4;
  if(authCheck($target,$hostname)) {
    actOut('LITERAL',undef,"value_get>hostnames>$1");
    my $banmask = readInput();

    if($banmask ne '') {
      my $bantime = 0;
      $bantime = 3600 if ($3 eq 'h');
      $bantime = 60 if ($3 eq 'm');
      $bantime = 1 if ($3 eq 's');
      $bantime = 86400 if ($3 eq 'd');
      $bantime = 604800 if ($3 eq 'w');
      $bantime *= $2 if $2;
      $bantime = 15552000 if ($bantime > 15552000);
      $bantime = 2592000 if ($bantime == 0);
      actOut('MESSAGE',$target,"Banning $1 ($banmask) for $bantime seconds.");
      actOut('MESSAGE','chanserv',"op $target $botName"); # op the bot

      actOut('LITERAL',undef,"event_schedule>op:$target>delay_schedule>$bantime>server_send>chanserv :op $target $botName");
      actOut('LITERAL',undef,"event_schedule>op:$target>delay_schedule>$bantime>event_schedule>op:$target>server_send>PRIVMSG $target :Unbanning $1 ($banmask) after $bantime seconds.");
      actOut('LITERAL',undef,"event_schedule>op:$target>delay_schedule>$bantime>event_schedule>op:$target>server_send>MODE $target -b *!*\@$banmask");
      actOut('LITERAL',undef,"event_schedule>op:$target>delay_schedule>$bantime>event_schedule>op:$target>server_send>PRIVMSG chanserv :deop $target $botName");

      actOut('LITERAL',undef,"event_schedule>op:$target>server_send>MODE $target +b *!*\@$banmask");
      actOut('LITERAL',undef,"event_schedule>op:$target>server_send>KICK $target $1 :$kickmessage");
      actOut('LITERAL',undef,"event_schedule>op:$target>server_send>PRIVMSG chanserv :deop $target $botName");
    }
    else {
      actOut('MESSAGE',$target,"$sender: Sorry. I don't have a record of that user and I can't look them up.");
    }
  }
  else { authError($sender,$target,$1); }
}