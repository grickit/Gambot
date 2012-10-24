if ($message =~ /^${sl}${cm}kick $validNick ?(.+)?$/i) {
  my $kickmessage = "[requested by $sender]";
  $kickmessage .= ": $2" if $2;
  if(authCheck($target,$hostname)) {
    actOut('MESSAGE','chanserv',"op $target $botName");
    actOut('LITERAL',undef,"event_schedule>op$target>send_server_message>KICK $target $1 :$kickmessage");
    actOut('LITERAL',undef,"event_schedule>op$target>send_server_message>PRIVMSG chanserv :deop $target $botName");
  }
  else { authError($sender,$target,$1); }
}