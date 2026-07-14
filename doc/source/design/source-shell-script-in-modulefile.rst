.. _source-shell-script-in-modulefile:

Source shell script in modulefile
=================================

Configuration
-------------

- No specific configuration


Specification
-------------

- Execute a shell script and include the environment changes it performs in modulefile

  - Environment changes done by shell script are gathered and evaluated in modulefile context through corresponding modulefile commands
  - Goal is to get the same environment after loading a modulefile using a :mfcmd:`source-sh` than if shell script targeted by the ``source-sh`` where directly sourced in shell session

- Environment changes tracked are (all environment elements ``module`` can handle):

  - Value set to variable: transformed into ``setenv`` modulefile command
  - Variable unset: transformed into ``unsetenv`` modulefile command
  - Path element added to variable: transformed into ``append-path`` or ``prepend-path`` modulefile command
  - Path element removed from variable: transformed into ``remove-path`` modulefile command
  - Current working directory change: transformed into ``cd`` modulefile command
  - Shell alias definition: transformed into ``set-alias``
  - Shell alias unset: transformed into ``unset-alias``
  - Shell function definition: transformed into ``set-function``
  - Shell function unset: transformed into ``unset-function``
  - Shell completion definition: transformed into ``complete``
  - Shell completion unset: transformed into ``uncomplete``

- Depending on modulefile evaluation mode, ``source-sh`` has different behaviors:

  - ``load``, ``refresh`` and ``scan``: execute script to gather its environment changes, transform them in modulefile commands and evaluate them
  - ``unload``: undo environment changes made on load mode
  - ``display``: execute script to gather its environment changes and report resulting command name and arguments for display
  - ``help``, ``test`` and ``whatis``: no operation

- **Limitation**: code in modulefile cannot rely on the environment changes done in script targeted by a ``source-sh`` command

  - For instance an environment variable set in shell script cannot be used to define another variable later in modulefile
  - This will work on ``load``, ``unload`` and ``display`` modes, as script is run and/or analyzed and corresponding modulefile commands are evaluated in modulefile context
  - But it will not work on the other modes, as script is not run and analyzed there

    - To simplify processing as script need to be run and analyzed if not yet loaded, but if already loaded changes recorded in environment for tracking should be used instead
    - To avoid a negative impact on performances on the ``whatis`` global evaluation

- Result of ``source-sh`` command evaluation is stored into the environment when modulefile is loaded

  - To keep track of environment changes made by ``source-sh`` script evaluation
  - In order to undo these changes when unloading modulefile and report corresponding modulefile commands when displaying modulefile
  - Environment variable :envvar:`__MODULES_LMSOURCESH` is used for this need

    - Using following syntax: ``mod&shell script arg|cmd|cmd|...&shell script|cmd:mod&shell script arg|cmd``
    - Example value: ``foo/1&sh /tmp/source.sh|append-path PATH /tmp|cd /tmp``
    - Characters used to structure information in ``__MODULES_LMSOURCESH`` (``:``, ``&`` and ``|``) are escaped

      - Respectively to ``<EnvModEscPS>``, ``<EnvModEscS1>`` and ``<EnvModEscS2>``
      - If found in environment changes to record

    - Actual bodies of shell alias, shell functions and shell completions are not recorded in ``__MODULES_LMSOURCESH``, an empty body is recorded instead

      - Example value: ``foo/1&sh /tmp/source.sh|set-alias alfoo {}|set-function funcfoo {}|complete bash foocmd {}``

  - When unloading modulefile, content found for this modulefile in ``__MODULES_LMSOURCESH`` variable is evaluated to reverse environment changes

    - When reaching a ``source-sh`` modulefile command, recorded content is evaluated through a modulefile Tcl interpreter in unload mode, to get the reversed effect

  - When displaying modulefile

    - If it is loaded

      - the content found for this modulefile in ``__MODULES_LMSOURCESH`` variable is evaluated in display mode to report each resulting modulefile command
      - script is evaluated to fetch shell alias, function and completion definitions which are not recorded in ``__MODULES_LMSOURCESH``

    - If not loaded, script is evaluated to gather environment changes and report each resulting modulefile command

- Script targeted by a ``source-sh`` command has to be run and environment prior this run and after this run have to be compared to determine the environment changes the script performs

  - The shell to use to run script has to be specified to ``source-sh``
  - This shell will be run to execute the following sequence:

    1. output current environment state
    2. source the script with its args
    3. output environment state after script source

  - Script output is kept to return it in an error message in case its execution fails
  - This comparison determines the environment changes performed by script which are then translated into corresponding modulefile commands
  - Shell is run in a mode where neither its user nor its system-wide configuration is evaluated to avoid side effect
  - Shell needs current environment to correctly evaluate script

    - it seems desirable to run shell in an empty environment to get the full list of changes it does over the environment
    - but the script may need the environment to be defined to correctly operate

      - for instance it needs the ``PATH`` to be set to execute external commands

    - so shell run inherits current environment to ensure script will be properly evaluated
    - but as a consequence if an environment change performed by script is already done prior script run, this environment change will not be *seen*

- **Limitation**: a variable already set by another module will not be seen set sourced script

  - if this module is unloaded and if it does not trigger the unload of the modulefile using ``source-sh``, variable will be unset as source-sh script has not increased variable reference counter

- **Limitation**: Script will not get access to shell aliases, functions or completions defined in interactive mode or shell profile configurations

- **Note**: environment change done through ``source-sh`` will not preserve change order occurring in sourced script, as all changes are analyzed after sourcing script

- Most shell will not get the full environment content when spawned as a sub-process

  - For instance shell aliases are not transmitted into sub-shells
  - As a result the environment prior script source will most of the time have no shell alias defined

- **Note**: shells may have specific behaviors

  - ``dash`` cannot pass arguments to the sourced script
  - ``ksh93`` reads the full script prior sourcing it which may cause issue if a shell alias is defined in script then used in script

- **Limitation**: implementation does not currently support:

  - the ``zsh`` shell when used as ``sh`` or as ``ksh``
  - the ``mksh`` shell
  - the BSD variant of the ``sh`` shell
  - the Windows ``cmd`` shell

- **Note**: if sourced script produces shell alias or function, these alias or function may not be compatible with the current shell of the user

- Shell completion is defined for the shell used to evaluate script

  - :mfcmd:`complete` commands are generated even if current user shell is not the same as the shell used to evaluate script
  - but the completion definition will produce a no-operation on current user shell when :mfcmd:`complete` command is evaluated

- **Note**: the mechanism described here only applies for shell script as to understand the impact the script execution over the user environment, this environment need to be compared prior and after execution

- ``source-sh`` modulefile command relies of the ``sh-to-mod`` procedure of ``modulecmd.tcl``

  - ``sh-to-mod`` procedure handles the evaluation of the targeted script and comparison of the environment prior and after this comparison
  - ``sh-to-mod`` returns as a result the list of modulefile commands describing the environment changes made by the analyzed script

- :subcmd:`sh-to-mod` is a module sub-command, calling the ``sh-to-mod`` procedure and outputting resulting modulefile commands

  - with a ``#%Module`` header
  - to enable users to convert the environment changes made by script in modulefiles

- There is no need to also make ``sh-to-mod`` a modulefile command and ``source-sh`` a module sub-command

- Shell to use to source targeted script may be specified as a command name or as a path name

  - When specified as a command name (e.g., ``bash``), command location will be determined based on currently set ``PATH``
  - When specified as a path name (e.g., ``/bin/bash``), this path name determines command location

- Prior executing shell and making it sourcing script:

  - Shell is checked to ensure an executable command matches it
  - Script is checked to ensure it exists
  - Those tests are done prior executing to avoid it if one check fails and provide a consistent error message whatever the shell used

- Environment changes to output as result should be enclosed and escaped

  - Enclosed if they contains space character (like white-space, tab and newline characters)
  - Escaped if they contains curly braces, as output is formatted as Tcl code, to avoid parsing issue

- If an error occurs during targeted script evaluation

  - Error is thrown which leads to either a modulefile evaluation error or a module sub-command error
  - Error and output messages reported by evaluated script will be reported along error by modulefile command or module sub-command

- To get prior and resulting environment state

  - ``env`` command is not used to gather environment state through exec source execution

    - it would simplify environment state parsing, as same command would be used for every shell
    - but it is an external command, so requires extra processing and an additional requirement
    - moreover it does not return shell functions in general, only exported Bash functions

  - Shell builtin commands are used to query existing environment variables, aliases, functions, completions and current working directory

    - which provides best processing efficiency
    - but leads to specific output parsing for each shell

  - A separator string ``%ModulesShToMod%`` is printed between each kind of environment item (variable, alias, etc) and also prior and after script evaluation

    - to separate each output kind and then be able to split them for separate analysis

- De-duplication of path entries is applied for changes on path-like environment variables

  - If the same path entry appears several times in the newly prepended entries for a variable, the first occurrence of this entry is kept others are dropped
  - If the same path entry appears several times in the newly appended entries for a variable, the first occurrence of this entry is kept others are dropped
  - De-duplication is not applied for path entries:

    - appearing in both the new prepended entries and newly appended entries
    - appearing in newly prepended entries or newly appended entries and in entries defined prior script evaluation

- An environment variable equaling to the path separator character (``:``) prior script evaluation is considered as undefined prior script evaluation to avoid misleading analysis

- Environment variables made for Modules private use are filtered-out from the environment changes produced

  - ``LOADEDMODULES``, ``_LMFILES_`` and any variable prefixed by ``__MODULES_`` are concerned
  - Changes relative to Modules state are ignored this way
  - If script loads in turn a modulefile, environment changes reported will not report the loaded module but only the environment changes it does
  - Modules configuration variable (prefixed by ``MODULES_``) are still taken into account

- There may be several shell completion changes found for the same command on particular shell like fish

  - It produces multiple ``complete`` modulefile commands
  - But in ``__MODULES_LMSOURCESH`` variable, a single entry is recorded as a single ``uncomplete`` command should be generated when unloading modulefile
  - If completion definition is partial for a command when loading modulefile, on fish shell previous completion definition is cleared right before setting those defined in modulefile
  - When a completion definition difference is spotted after script evaluation, new completion definition is set which means previous definition is cleared (either intrinsically by shell or for fish due to the definition clear specifically added)

- Fish shell allows nested definition of shell functions

  - A separator string ``%ModulesSubShToMod%`` is printed between each function definition not to get main and nested functions mixed up
  - Such sub-separator is only applied on fish shell

- ``bash-eval`` shell is added in version 5.4

  - Instead of sourcing a bash shell script, execution output of this script is evaluated

- ``--ignore`` option is added in version 5.4

  - This option accepts a list of shell element separated by ``:`` character among:

    - ``envvar``
    - ``alias``
    - ``function``
    - ``chdir``
    - ``complete``

  - Shell elements changed by sourced script and listed on ``--ignore`` option are ignored (no modulefile command relative to these changes are produced)

- **FUTURE**: this feature may be extended to translate environment changes made by tools like Spack, Lmod or pkg-config. It may provide this way bridges between different realms.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
