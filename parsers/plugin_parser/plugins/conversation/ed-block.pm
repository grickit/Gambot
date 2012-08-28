##########http://encyclopediadramatica.ch/Accidentally
if ($message =~ /encyclopediadramatica(\.[a-z]{2,3})+/) {
  ACT('MESSAGE',$target,"NOBODY TOUCH THAT LINK");
}