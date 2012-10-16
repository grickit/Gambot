if ($message =~ /^${sl}${cm}op $validChannel $validNick$/i) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"op $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}op(?:me)?$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"op $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}op $validNick$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"op $target $1") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}deop $validChannel $validNick$/i) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"deop $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}deop(?:me)?$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"deop $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}deop $validNick$/i) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"deop $target $1") : authError($sender,$target,$target);
}
