if ($message =~ /^$sl !kick ([$valid_nick_characters]+)$/) {
  if(CheckAuth($1,$hostname)) {
    ACT('MESSAGE','chanserv',"op $target $self");
    ACT('LITERAL',undef,"schedule_event>op$target>send_server_message>KICK $target :$1");
    ACT('LITERAL',undef,"schedule_event>op$target>send_server_message>PRIVMSG chanserv :deop $target $self");
  }
  else {
    AuthError($sender,$target,$1);
  }
}