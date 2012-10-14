if ($message =~ /^${sl}${cm}join $validChannel$/) {
  authCheck($1,$hostname) ? actOut('JOIN',$1) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}part $validChannel ?(.+)?$/) {
  my $partmessage = "[requested by $sender]";
  $partmessage .= ": $2" if $2;
  authCheck($1,$hostname) ? actOut('PART',$1,$partmessage) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}part$/) {
  my $partmessage = "[requested by $sender]";
  authCheck($target,$hostname) ? actOut('PART',$target,$partmessage) : authError($sender,$target,$target);
}