if ($message =~ /^${sl}${cm}voice $validChannel $validNick$/i) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"voice $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}voice(?:me)?$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"voice $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}devoice $validChannel $validNick$/i) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"devoice $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}devoice(?:me)?$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"devoice $target $sender") : authError($sender,$target,$target);
}

