if (($event eq 'server_message') && ($command eq '433')) {
    ACT('LITERAL',undef,'send>NICK ' . $self . '_'); 
}
