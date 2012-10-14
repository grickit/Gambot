if ($message =~ /^${sl}${cm}op $validChannel $validNick$/) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"op $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}op(?:me)?$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"op $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}op $validNick$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"op $target $1") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}deop $validChannel $validNick$/) {
  authCheck($1,$hostname) ? actOut('MESSAGE','chanserv',"deop $1 $2") : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}deop(?:me)?$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"deop $target $sender") : authError($sender,$target,$target);
}

if ($message =~ /^${sl}${cm}deop $validNick$/) {
  authCheck($target,$hostname) ? actOut('MESSAGE','chanserv',"deop $target $1") : authError($sender,$target,$target);
}
