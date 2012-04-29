The Gambot API Language is just a series of commands that message parsers and scripts/commands can output to manipulate the bot.
They are as follows.

## Sending Messages ##
  #### end_server_message>[message] ####
    * Makes the bot send [message] to the IRC server. Should be valid raw IRC.

  * __send_pipe_message>[pipe id]>[message]__
    * Sends [message] to the pipe named [pipe id].
    * Use the id "*main*" to send messages to STDOUT.


## Variable storage ##
  * __dict_exists>[dict]__
    * If $dicts{[dict]} exists, the calling script will receive a "*1*" in STDIN.
    * Otherwise it will receive a *blank line*.

  * __dict_save>[dict]__
    * $dicts{[dict]} will be dumped into a file named [dict].

  * __dict_load>[dict]__
    * A file named [dict] will be read into $dicts{[dict]}.

  * __dict_save_all>__
    * All $dicts{} that were explicitly loaded or saved with "*dict_save>*" or "*dict_load>*" will be dumped to files.

  * __dict_delete>[dict]__
    * Deletes $dicts{[dict]}.

  * __value_get>[dict]>[key]__
    * $dicts{[dict]}{[key]} will be be printed to STDIN of the calling script.
    * Prints a blank line if the key does not exist.

  * __(return) value_add>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be set to [value] __only if it does not already exist__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_replace>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be set to [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_set>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be set to [value].
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_append>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be appended [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_prepend>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be prepended [value] __only if it already exists__.
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_increment>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be increased by [value] amount __only if it already exists and is an integer__.
    * If $dicts{[dict]}{[key]} exists, but is not an integer, it will be set to "*0*".
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_decrement>[dict]>[key]>[value]__
    * $dicts{[dict]}{[key]} will be decreased by [value] amount __only if it already exists and is an integer__.
    * If $dicts{[dict]}{[key]} exists, but is not an integer, it will be set to "*0*".
    * If "*return*" is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a "*blank line*" indicating failure.

  * __(return) value_delete>[dict]>[key]__
    * $dicts{[dict]}{[key]} will be deleted __only if it already exists__.
    * If "*return*" is present, the calling script will receive the value of $dicts{[dict]}{[key]} before it was deleted or a "*blank line*" indicating it did not exist.


## Pipe Management ##
  * __check_pipe_exists>[pipe id]__
    * If the pipe named [pipe id] exists, the calling script will receive a "*1*" in STDIN.
    * Otherwise it will receive a *blank line*

  * __kill_pipe>[pipe id]__
    * Abruptly kills and cleans up variables related to the pipe named [pipe id].
    * Obviously, prematurely killing pipes can lead to data loss.
    * Never use on "*main*" or you will corrupt the bot.

  * __run_command>[pipe id]>[command]__
    * Start a new child pipe named [pipe id].
    * It will __run the system command__: [command]
    * __Be careful about combining this with user input.__
    * It is __strongly recommended__ to only use "*run_command>*" on hardcoded [command] values and then pass user input with "*send_pipe_message>*".
    * Just in case it wasn't clear, __"*run_command>*" IS VERY DANGEROUS!__


## Bot Management ##
  * __sleep>[number]__
    * Causes the bot to sleep for [number] seconds.
    * Can be a float because it is directly mapped to the four argument version of select().
    * Because this locks up the entire bot, it should be used sparingly.
    * It is not necessary to use "*sleep>*" to throttle messages sent to the IRC server to avoid flood kicks. This is handled automatically.

  * __shutdown>__
    * Shuts the bot down.

  * __reconnect>__
    * The bot will disconnect from IRC and then reconnect.

  * __reload_config>__
    * The bot will reread its configuration file and reset values in $dicts{'config'}.
    * You could combine this with "*value_set>core>configuration_file>whatever.txt*" to switch configuration files without restarting (though you would also need to "*reconnect>*" if changing servers).

  * __log>[prefix]>[message]__
    * Uses the normal_output() function to log in the form: [prefix] timestamp [message]
    * normal_output() is always logged to files (unless using --unlogged mode), but is only output to the terminal in --verbose mode.
    * Sample: *BOTEVENT 11:00:00 I am attempting to connect.*

## Events ##
  * __event_schedule>[name]>[GAPIL]__
    * Schedules [GAPIL] to be parsed as a Gambot API call when event [name] is fired.

  * __event_fire>[name]__
    * This fires event [name]

  * __event_exists>[name]__
    * If event [name] exists, you will receive [name] in STDIN, otherwise you receive a blank line.

  * __delay_schedule>[name]>[seconds]>[GAPIL]__
    * Schedules [GAPIL] to be parsed as a Gambot API call at least [seconds] seconds in the future.
    * It may not be exactly on time if the bot is congested, but it usually will be.
    * Reuse "*delay_schedule*" on the same [name] value to change [seconds] or [GAPIL]

  * __delay_fire>[name]__
    * Fires a delay early.


## Notes ##
  All pipe ids and variable names must match: __([a-zA-Z0-9_-]+)__

  * $dicts{'core'} contains information that the bot requires to run.
  * $dicts{'config'} contains any values set in the configuration file.
  * Modifying or deleting any values in them could corrupt the bot. It won't necessarily. Just be careful.
