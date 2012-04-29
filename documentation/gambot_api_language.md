The Gambot API Language is just a series of commands that message parsers and scripts/commands can output to manipulate the bot.
They are as follows.

### Sending Messages ###
  * __send_server_message>[message]__
    Makes the bot send [message] to the IRC server. Should be valid IRC as per RFC 1459.

  * __send_pipe_message>[pipe id]>[message]__
    Sends [message] to the pipe named [pipe id].
    Use the id "main" to send messages to STDOUT.


--- Variable storage ---
  dict_exists>[dict]
    If $dicts{[dict]} exists, the calling script will receive a "1" in its STDIN.
    Otherwise it will receive a blank line.

  dict_save>[dict]
    $dicts{[dict]} will be dumped into a file named [dict]

  dict_load>[dict]
    A file named [dict] will be read into $dicts{[dict]}

  dict_save_all>
    All $dicts that were explicitly loaded or saved with dict_save or dict_load will be dumped to files.

  dict_delete>[dict]
    Deletes $dicts{$dict}

  value_get>[dict]>[key]
    $dicts{[dict]}{[key]} will be be printed to STDIN of the calling script.
    Prints a blank line if the key does not exist.

  (return) value_add>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} does not already exist, it will be set to [value].
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

  (return) value_replace>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} already exists, it will be set to [value].
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

  (return) value_set>[dict]>[key]>[value]
    $dicts{[dict]}{[key]} will be set to [value]
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

 (return) value_append>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} already exists, [value] will be appended to it.
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

 (return) value_prepend>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} already exists, [value] will be prepended to it.
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

 (return) value_increment>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} already exists and is an integer, [value] will be added to it.
    If $dicts{[dict]}{[key]} existed, but was not an integer, it will be set to 0.
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

 (return) value_decrement>[dict]>[key]>[value]
    If $dicts{[dict]}{[key]} already exists and is an integer, [value] will be subtracted from it.
    If $dicts{[dict]}{[key]} existed, but was not an integer, it will be set to 0.
    If (return) is present, the calling script will receive the new value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.

 (return) value_delete>[dict]>[key]
    If $dicts{[dict]}{[key]} exists, it will be deleted
    If (return) is present, the calling script will receive the old value of $dicts{[dict]}{[key]} or a blank line indicating failure in STDIN.


--- Pipe Management ---
  check_pipe_exists>[pipe id]
    If the pipe named [pipe id] exists, the calling script will receive a "1" in its STDIN.
    Otherwise it will receive a "0"

  kill_pipe>[pipe id]
    This abruptly kills and cleans up variables related to the pipe named [pipe id].
    This can lead to data loss if that pipe isn't already finished running.
    Never use on "main" or you will corrupt the running bot.

  run_command>[pipe id]>[command]
    This will start a new child pipe named [pipe id].
    It will run the system command: [command]
    Be careful about combining this with user input.
    We recommend only running commands that you have explicitly typed out, and passing user input to them with send_pipe_message>


--- Bot Management ---
  sleep>[number]
    This will cause the bot to sleep for [number] seconds.
    Can be a float because we actually use the four argument version of select() for this.

  shutdown>
    Shuts the bot down.

  reconnect>
    The bot will disconnect from IRC and then reconnect.

  reload_config>
    The bot will reread its configuration file and re-set %config values.

  log>[prefix]>[message]
    This will use the normal_output() function to log in the form: [prefix] timestamp [message]
    It looks like: BOTEVENT 11:00:00 I am attempting to connect.

--- Events ---
  event_schedule>[name]>[GAPIL]
    This schedules [GAPIL] to be parsed as a Gambot API call when event [name] is fired.

  event_fire>[name]
    This fires event [name]

  event_exists>[name]
    If event [name] exists, you will receive [name] in STDIN, otherwise you receive a blank line.

  delay_schedule>[name]>[seconds]>[GAPIL]
    Schedules [GAPIL] to be run at least [seconds] seconds in the future.
    It may not be exactly on time if the core is congested, but it usually will be.
    [name] can be used for editing delays

  delay_fire>[name]
    Fires a delay early.


--- Notes ---
  All pipe ids and variable names must match: ([a-zA-Z0-9_-]+)

  %core contains information that the bot requires to run.
  %config contains any values set in the configuration file.
  %variable contains nothing by default. Message parsers and commands are able to store data here.
