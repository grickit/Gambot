The Gambot API Language is just a series of commands that message parsers and scripts/commands can output to manipulate the bot.
They are as follows.

## Sending Messages ##
  * ### send_server_message>[message] ###
    * Makes the bot send [message] to the IRC server. Should be valid raw IRC.



## Variable storage ##
  * ### dict_exists>[dict] ###
    * If $dicts{[dict]} exists, the calling script will receive a "*1*" in STDIN.
    * Otherwise it will receive a *blank line*.


  * ### dict_save>[dict] ###
    * $dicts{[dict]} will be dumped into a file named [dict].


  * ### dict_load>[dict] ###
    * A file named [dict] will be read into $dicts{[dict]}.


  * ### dict_save_all> ###
    * All $dicts{} that were explicitly loaded or saved with "*dict_save>*" or "*dict_load>*" will be dumped to files.


  * ### dict_delete>[dict] ###
    * Deletes $dicts{[dict]}.


  * ### value_get>[dict]>[key] ###
    * $dicts{[dict]}{[key]} will be be printed to STDIN of the calling script.
    * Prints a blank line if the key does not exist.


  * ### (return) value_add>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be set to [value] __only if it does not already exist__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_replace>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be set to [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_set>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be set to [value].
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.
    * __Be careful about modifying the "*config*" and "*core*" dicts.__


  * ### (return) value_append>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be appended [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_prepend>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be prepended [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_increment>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be increased by [value] amount __only if it already exists and is an integer__.
    * If $dicts{[dict]}{[key]} exists, but is not an integer, it will be set to "*0*".
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_decrement>[dict]>[key]>[value] ###
    * $dicts{[dict]}{[key]} will be decreased by [value] amount __only if it already exists and is an integer__.
    * If $dicts{[dict]}{[key]} exists, but is not an integer, it will be set to "*0*".
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.


  * ### (return) value_delete>[dict]>[key] ###
    * $dicts{[dict]}{[key]} will be deleted __only if it already exists__.
    * If "*return*" is present, the calling script will receive the value of $dicts{[dict]}{[key]} before it was deleted or a "*blank line*" indicating it did not exist.



## Child Process Management ##
  * ### child_exists>[child id] ###
    * If the child named [child id] exists, the calling script will receive a "*1*" in STDIN.
    * Otherwise it will receive a *blank line*


  * ### child_send>[child id]>[message] ###
    * Sends [message] to the child named [child id].
    * Use the id "*terminal*" to send messages to STDOUT.


  * ### child_delete>[child id] ###
    * Abruptly kills and cleans up variables related to the child named [child id].
    * Obviously, prematurely killing pipes can lead to data loss.
    * Never use on "*main*" or you will corrupt the bot.


  * ### child_add>[child id]>[command] ###
    * Start a new child child named [child id].
    * It will __run the system command__: [command]
    * __Be careful about combining this with user input.__
    * It is __strongly recommended__ to only use "*child_add>*" on hardcoded [command] values and then pass user input with "*child_send>*".
    * Just in case it wasn't clear, __"*child_add>*" IS VERY DANGEROUS!__



## Bot Management ##
  * ### sleep>[number] ###
    * Causes the bot to sleep for [number] seconds.
    * Can be a float because it is directly mapped to the four argument version of select().
    * Because this locks up the entire bot, it should be used sparingly.
    * It is not necessary to use "*sleep>*" to throttle messages sent to the IRC server to avoid flood kicks. This is handled automatically.


  * ### shutdown> ###
    * Shuts the bot down.


  * ### reconnect> ###
    * The bot will disconnect from IRC and then reconnect.


  * ### reload_config> ###
    * The bot will reread its configuration file and reset values in $dicts{'config'}.
    * You could combine this with "*value_set>core>configuration_file>whatever.txt*" to switch configuration files without restarting (though you would also need to "*reconnect>*" if changing servers).


  * ### log>[prefix]>[message] ###
    * Uses the normal_output() function to log in the form: [prefix] timestamp [message]
    * normal_output() is always logged to files (unless using --unlogged mode), but is only output to the terminal in --verbose mode.
    * Sample: *BOTEVENT 11:00:00 I am attempting to connect.*


## Events ##
  * ### event_schedule>[name]>[GAPIL] ###
    * Schedules [GAPIL] to be parsed as a Gambot API call when event [name] is fired.


  * ### event_fire>[name] ###
    * This fires event [name]


  * ### event_exists>[name] ###
    * If event [name] exists, you will receive [name] in STDIN, otherwise you receive a blank line.


  * ### delay_schedule>[name]>[seconds]>[GAPIL] ###
    * Schedules [GAPIL] to be parsed as a Gambot API call at least [seconds] seconds in the future.
    * It may not be exactly on time if the bot is congested, but it usually will be.
    * Reuse "*delay_schedule*" on the same [name] value to change [seconds] or [GAPIL]


  * ### delay_fire>[name] ###
    * Fires a delay early.



## Notes ##
  All child ids and variable names must match: __([a-zA-Z0-9_-]+)__

  * $dicts{'core'} contains information that the bot requires to run.
  * $dicts{'config'} contains any values set in the configuration file.
  * Modifying or deleting any values in them could corrupt the bot. It won't necessarily. Just be careful.
