push (@commands_regexes, "encyclopediadramatica\.com");
push (@commands_subs, sub {
  ACT("MESSAGE","$target","\"NOBODY TOUCH THAT LINK\" - shadowmaster"); 
});