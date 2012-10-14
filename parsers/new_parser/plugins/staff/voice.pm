if ($message =~ /^${sl}${cm}voice $validChannel $validNick$/) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"voice $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}voice(?:me)?$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"voice $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}devoice $validChannel $validNick$/) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"devoice $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}devoice(?:me)?$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"devoice $target $sender") : authError($sender,$target,$target);
}

