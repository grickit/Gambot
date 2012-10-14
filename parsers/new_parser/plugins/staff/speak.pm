if ($message =~ /^${sl}${cm}tell $validChannel (.+)$/) {
  authCheck($1,$hostname) ? actOut('MESSAGE',$1,$2) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}do $validChannel (.+)$/) {
  authCheck($1,$hostname) ? actOut('ACTION',$1,$2) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}notify $validChannel (.+)$/) {
  authCheck($1,$hostname) ? actOut('NOTICE',$1,$2) : authError($sender,$target,$1);
}