if ($message =~ /^${sl}${cm}join $validChannel$/i) {
  authCheck($1,$hostname) ? actOut('JOIN',$1) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}part $validChannel ?(.+)?$/i) {
  my $partmessage = "[requested by $sender]";
  $partmessage .= ": $2" if $2;
  authCheck($1,$hostname) ? actOut('PART',$1,$partmessage) : authError($sender,$target,$1);
}

if ($message =~ /^${sl}${cm}part$/i) {
  my $partmessage = "[requested by $sender]";
  authCheck($target,$hostname) ? actOut('PART',$target,$partmessage) : authError($sender,$target,$target);
}