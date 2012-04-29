This README was last updated April 29 2012

## About Gambot ##
  Gambot is an IRC bot framework. It is written in perl.

## Major features ##

### Speed ###
  * The core is very lean and very fast.
  * Low memory usage.
  * The main loop's rate limit is adjustable. Give your Gambot as much or as little of your CPU time as you want.

### Full Asynchronism ###
  * Messages don't get parsed in order.
  * If you have certain commands that take longer (maybe they require network resources) they won't slow down the entire bot.
  * The core script acts as a server, with many clients connecting to it; again these are all handled asynchronously.

### On the fly updates ###
  * The only time you have to reconnect or restart is when updating the core.
  * Changes to message parsers are instantly live on the bot.
  * Changes to child scripts simply require issuing a command to reload those.
  * Changes to configuration files can likewise be reloaded with commands.

### Code in any language ###
  * The core is written in perl, but you can extend it in any programming language you want.
  * As long as it can read STDIN and print to STDOUT, it will work.

## Setting up ##
  * Just run "*gambot.pl*", edit "*configurations/config.txt*", and type "*reload_config>*" into the terminal.
  * From there you'll have to follow the setup instructions of whatever add-ons, message parsers, and extensions you're using.

## Coding for Gambot ##
  * There are files in the documentation folder about all the different aspects of programming for Gambot.
  * The code is also well commented, and several example extensions and parsers are included.

## Contact ##
  Contact me at: <thegrickit@gmail.com>
  Include "Gambot" in the subject line.

  Bug reports at: <https://github.com/grickit/Gambot/issues>
