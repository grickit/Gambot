#http://encyclopediadramatica.ch/Accidentally
if ($message =~ /encyclopediadramatica(\.[a-z]{2,3})+/i) {
  actOut('MESSAGE',$target,"NOBODY TOUCH THAT LINK");
}