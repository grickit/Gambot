if ($message =~ /^${sl}${cm}kick $validNick ?(.+)?$/i) {
  my $kickmessage = "[requested by $sender]";
  $kickmessage .= ": $2" if $2;
  if(authCheck($target,$hostname)) {
    actOut('MESSAGE','chanserv',"op $target $botName");
    actOut('LITERAL',undef,"event_subscribe>op:$target>server_send>KICK $target $1 :$kickmessage");
    actOut('LITERAL',undef,"event_subscribe>op:$target>server_send>PRIVMSG chanserv :deop $target $botName");
  }
  else { authError($sender,$target,$1); }
}