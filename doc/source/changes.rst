.. _changes:

Changes between versions
========================

This document lists functionality differences between each major version of Modules. The goal of each following section is to reference the features of previous major version that are missing or behave differently on the next major version and the features that can only be found on this newer version. For instance the `Modules 4`_ section lists the changes compared to Modules 3.2.

Regarding deprecated or newly introduced features, this document only lists their name or the command line argument related to them. Please refer to the :ref:`module(1)` and the :ref:`modulefile(5)` man pages of the previous or newer Modules version to learn the details about these removed or added features.


.. _Modules 4 changes:

Modules 4
---------

This section provides the list of differences with Modules version 3.2. This version of Modules is also referred in this document as *compatibility version*. Modules 4 is based on what was previously called Modules-Tcl. Comparison takes as a basis version ``3.2.10`` of compatibility version against Modules version ``4.0``. Any change made past these versions will explicitly mention the release number starting from the difference appears or disappears.

.. note:: The numerous bugs or limitations spotted on Modules ``3.2`` across the years have been fixed in Modules ``4.0``. The list of reported issues that have been solved are available on `the project code forge <https://github.com/envmodules/modules/milestone/1?closed=1>`_.

Removed or changed features
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes the features of the compatibility version that are not supported or that behave differently on Modules 4.


Package Initialization
""""""""""""""""""""""

:envvar:`MODULESBEGINENV` environment snapshot functionality is not supported on version 4. Modules collection mechanism should be preferred to save and restore sets of enabled modulepaths and loaded modulefiles. Modules 4 also introduces a system configuration file *init/modulerc*, located in Modules installation directory. Starting version ``4.3``, this file could also be *etc/initrc*. This *modulerc*/*initrc* file is sourced by Modules shell initialization scripts and helps to setup the initial environment right after initializing the :command:`module` command.


Command line switches
"""""""""""""""""""""

**--human**

**--create**, **-c**

**--userlvl** lvl, **-u** lvl

 These command line switches are not supported on Modules 4. When these options are passed on the command-line, it produces an *Unsupported option* warning and command is ran with the unsupported switches ignored.

**--ter**

**--lon**

**--sil**

**--verb**

 These intermediate-form command line switches are not supported on Modules 4. Short or long switch name should be used instead.

:option:`-h`

 This command line switch is short version of :option:`--help` switch on Modules 4 whereas it is short version of **--human** switch on compatibility version.

:option:`--force`, :option:`-f`

 This command line switch was not supported starting Modules version ``4.0`` but reintroduced starting version ``4.2`` with a different meaning: instead of enabling an active dependency resolution mechanism ``--force`` command line switch now enables to by-pass dependency consistency when loading or unloading a *modulefile*.

:option:`--verbose`, :option:`-v`

:option:`--silent`, :option:`-s`

 These command line switches were not supported starting Modules version ``4.0`` but reintroduced starting version ``4.3``. However, reintroduced :option:`--silent` switch does not redirect stderr channel to ``/dev/null`` if stderr is found not to be a tty.

:option:`--icase`, :option:`-i`

 This command line switch was not supported starting Modules version ``4.0`` but reintroduced starting version ``4.4``. When :option:`--icase` switch is now set it applies to search query string and module specification on all sub-commands and modulefile Tcl commands.


Module Sub-Commands
"""""""""""""""""""
On compatibility version, paths composing the :envvar:`MODULEPATH` environment variable may contain reference to environment variable. These variable references are resolved dynamically when :envvar:`MODULEPATH` is looked at during module sub-command action like :subcmd:`avail`. This feature was missing on Modules ``4.0`` but it has been re-introduced on Modules ``4.1``.

:subcmd:`update`

 This module sub-commands is not supported on Modules 4.

:subcmd:`clear`

 This command line switch was not supported starting Modules version ``4.0`` but reintroduced starting version ``4.3``. It now takes into account the :option:`--force` command-line switch to skip confirmation dialog.

:subcmd:`refresh`

 On compatibility version, only the shell aliases defined by the currently loaded modulefiles are set again on a :subcmd:`refresh` command. Whereas on Modules 4 this command is an alias on the :subcmd:`reload` command that :subcmd:`unload` then :subcmd:`load` all the currently loaded modulefiles.

:subcmd:`help`

 Compatibility version redirects output made on stdout in ``ModulesHelp`` Tcl procedure to stderr.

 During an :subcmd:`help` sub-command, only the ``ModulesHelp`` Tcl procedure of a modulefile is interpreted on compatibility version. Version 4 interprets all the content of the modulefile, then call the ``ModulesHelp`` procedure if it exists.

 On version 4, ``ModulesHelp`` subroutine is not ran if an error occurred during the interpretation of the *modulefile* main body.

:subcmd:`display`

 On version 4, ``ModulesDisplay`` subroutine is not ran if an error occurred during the interpretation of the *modulefile* main body.

:subcmd:`avail`

 On compatibility version, the same Tcl interpreter is used for the interpretation of all *.modulerc* or *.version* files during an :subcmd:`avail` command but the state of this interpreter is not reset between each interpretation. So some variable and procedure definitions may spread from one interpretation to another on this compatibility version. Modules 4 reuses the same interpreter for all *.modulerc* or *.version* interpretation but it is cleaned between each interpretation to protect from definition spread.

 In case of :option:`--terse` or :option:`--long` mode, all enabled modulepaths will be displayed whether they hold result to display or not. Modules 4 outputs only the modulepaths where matching results are found. Modulepaths with no result to report are discarded from output.

:subcmd:`apropos`

 On Modules 4, *string* passed as argument is always searched in a case insensitive manner.

:subcmd:`load`

 On Modules 4, the value of an environment variable is set even if the new value is the same as the current value of this variable in environment.

 When an already loaded *modulefiles* is asked for load again, compatibility version will refresh the shell alias definition this modulefile hold if any, whereas Modules 4 will ignore the new load order.

 In case of *modulefile* loading another modulefile, if sub-modulefile load fails calling modulefile will still be loaded on compatibility version whereas Modules 4 will also abort calling modulefile load. Compatibility version behavior could be restored by enclosing ``module load`` command and arguments within ``catch`` Tcl command.

 Starting with version ``4.1``, content sent to the ``stdout`` channel during a *modulefile* interpretation is spooled to effectively transmit this content to stdout after rendering the environment changes made by this modulefile.

:subcmd:`unload`

 On Modules 4, the value of an environment variable is set even if the new value is the same as the current value of this variable in environment.

 Compatibility version enables to load a *modulefile* by passing on the command-line the name of a module alias or symbolic version pointing to this modulefile. However this module alias or symbolic version name cannot be used to unload the modulefile once loaded. Modules 4 enables to pass a module alias or symbolic version name to unload a loaded modulefile referred by this name.

 On versions ``4.0`` and ``4.1``, unloading an nonexistent modulefile generates an *Unable to locate modulefile* error. Starting with version ``4.2``, unloading a module only looks at loaded module list and does not trigger a modulefile search. So starting version ``4.2`` the same behavior than Modules compatibility version is obtained.

 Starting with version ``4.1``, content sent to the ``stdout`` channel during a *modulefile* interpretation is spooled to effectively transmit this content to stdout after rendering the environment changes made by this modulefile.

 When the specified module to unload matches multiple loaded modules, Modules 4 unloads lastly loaded module whereas compatibility version unloads firstly loaded module. A configuration option ``unload_match_order`` has been introduced in version ``4.3`` and it enables to restore the behavior of compatibility version when it is set to ``returnfirst``.

:subcmd:`switch`

 When switching on version 4 an *old* modulefile by a *new* one, no error is raised if *old* modulefile is not currently loaded. In this situation compatibility version throws an error and abort switch action.

 When switching on Modules 4 an *old* modulefile by a *new* one, this *new* modulefile does not keep the position that the *old* modulefile had in the :envvar:`LOADEDMODULES` list as done on compatibility version but it is appended to the end of the list. Same goes for PATH-like environment variables: replaced PATH component is appended to the end or prepended to the beginning of the relative PATH-like variable, not appended or prepended relatively to the position hold by the swapped PATH component.

 When a modulefile loads another modulefile with a *module load* order, this sub-module is not unloaded when the top modulefile is swapped-out during a :subcmd:`switch` command on compatibility version. Version 4 interprets the swapped-out modulefile in unload mode, so the *module load* order is interpreted as *module unload* order and sub-module is unloaded.

:subcmd:`use`

 When the modulepath to enable is passed as a relative path, compatibility version will set it using passed relative name whereas Modules 4 will determine the corresponding absolute path and will register it rather passed relative name.

:subcmd:`unuse`

 Modules 4 provides path element counting feature which increases a reference counter each time a given path entry is added to a given environment variable. This feature also applies to the :envvar:`MODULEPATH` environment variable. As consequence a modulepath entry element is removed from the modulepath enabled list only if the related element counter is equal to 1. When unusing a modulepath if its reference counter is greater than 1, modulepath is kept enabled and reference counter is decreased by 1.

:subcmd:`whatis`

 On Modules 4, environment variable edition commands (*setenv*, *unsetenv*, *append-path*, *prepend-path* and *remove-path*) do no set variable to the defined value on the modulefile evaluation context during a :subcmd:`whatis` evaluation. Instead environment variables are initialized with an empty value if undefined, to avoid raising error when attempting access to an undefined element during the modulefile evaluation.

:subcmd:`initadd`

:subcmd:`initprepend`

:subcmd:`initswitch`

 On version 4 no message is displayed to give details on how list of modulefiles to load has been altered in initialization file.

:subcmd:`initrm`

 No message is displayed on Modules 4 to inform of the modulefiles that have been removed from the loading list in initialization file.

 Empty ``module load`` line is left on version 4 when last modulefile from a line is asked to be removed. On compatibility version ``module load null`` line is set in this case.

:subcmd:`initclear`

 Empty ``module load`` lines are left on version 4 whereas ``module load null`` lines are set on compatibility version.


Modules Specific Tcl Commands
"""""""""""""""""""""""""""""

On version 4 the characters that have a special meaning when rendered in shells are escaped when used in value to set environment variables, shell alias or shell functions. Thus it is possible to set environment elements with value containing these special characters (like backticks). On version 3 these special characters were evaluated by shell when recording the environment changes implied by modulefile evaluation.

:mfcmd:`append-path`

:mfcmd:`prepend-path`

 Modules 4 produces an error when adding a bare colon character *:* as a path element to a path-like variable, as this colon cannot be distinguished from the colon used for path separator.

 Modules 4 supports adding or removing empty path element to a path-like variable, whereas compatibility version looses track of this path element when the path-like variable is modified afterward. Empty path element enables to set a leading colon character *:*, which has a specific meaning on some regular environment variable like :envvar:`MANPATH` or :envvar:`LD_LIBRARY_PATH`.

 When adding a path element to the :envvar:`MANPATH` environment variable, Modules 4 is treating this variable like any other whereas a special treatment was applied on compatibility version: a default MANPATH value, set at configure time, was appended in case :envvar:`MANPATH` variable was unset.

:mfcmd:`remove-path`

 Modules 4 provides path element counting feature which increases a reference counter each time a given path entry is added to a given environment variable. As consequence a path entry element is removed from a path-like variable only if the related element counter is equal to 1. If this counter is greater than 1, path element is kept in variable and reference counter is decreased by 1.

 When unloading a modulefile, :mfcmd:`remove-path` command is not applied to environment variable on Modules 4, whereas on compatibility version it is processed the exact same way than when loading modulefile.

:mfcmd:`exit`

 On Modules 4 code passed to the :mfcmd:`exit` Modules specific Tcl command will not be thrown to be the :command:`module` return value.

:mfcmd:`module-alias`

:mfcmd:`module-version`

 In case the specified aliased module or the symbolic version introduces a resolution loop with already defined aliases or symbolic versions, this new alias or symbolic version is not registered and an error message is raised. On compatibility version, alias or symbolic version introducing loop are registered as the modulefile resolution is not computed at registration time.

:mfcmd:`module-info`

 **module-info flags**

 **module-info trace**

 **module-info tracepat**

 **module-info user**

  These :mfcmd:`module-info` options are related to compatibility version-specific features so they are available on Modules 4 but with a dummy implementation that always returns false or an empty value.

 **module-info mode**

  During an :subcmd:`unload` sub-command, ``unload`` is returned instead of ``remove``. However if *mode* is tested against ``remove`` value, true will be returned.

  During a :subcmd:`switch` sub-command, ``unload`` then ``load`` is returned instead of ``switch1`` then ``switch2`` then ``switch3``. However if *mode* is tested against ``switch`` value, true will be returned.

 **module-info name**

  If the module name passed to the command-line has been specified as a full path name, the **module-info name** used in modulefile returns this file base name on compatibility version whereas it returns on Modules 4+ the full path name as it is identified by this name once loaded.

 **module-info version**

  Declared aliases or symbolic versions are not registered anymore if they introduce a resolution loop. As a result **module-info version** does not return an ``*undef*`` string value as it does not face resolution loop situation anymore.

 **module-info symbols**

  Declared aliases or symbolic versions are not registered anymore if they introduce a resolution loop. As a consequence symbolic versions introducing loop situation are not part anymore of the **module-info symbols** returned result as they are not registered.

  A symbolic version sets on a module alias will be propagated toward the resolution path to also apply to the relative *modulefile* if it still correspond to the same module name.

:mfcmd:`module-log`

:mfcmd:`module-trace`

:mfcmd:`module-user`

:mfcmd:`module-verbosity`

 These Modules specific Tcl commands are related to compatibility version-specific features so they are available on Modules 4 but with a dummy implementation that always displays a warning message saying the command is not implemented.

:mfcmd:`module-whatis`

 When multiple words are passed as argument to :mfcmd:`module-whatis` but they are not enclosed in double-quotes or curly braces they will be displayed as a single line on Modules 4 whereas compatibility version displays them as one line per word.

:mfcmd:`set-alias`

 Whereas compatibility version sets a shell function when variables are in use in alias value on Bourne shell derivatives, Modules 4 always defines a shell alias never a shell function.

:mfcmd:`setenv`

 On compatibility version the :mfcmd:`setenv` modulefile command accepts any number of argument, but ignores all arguments after the first two. An error is raised on Modules 4 when more than two arguments are passed to the :mfcmd:`setenv` modulefile command.

Locating Modulefiles
""""""""""""""""""""

On version 4, when a module alias is set and overrides name of an existing directory, this alias is taken into account to locate the default version of this module name and the *modulefiles* locating in the directory are ignored.

When looking for an implicit default in a *modulefile* directory, aliases are taken into account in addition to *modulefiles* and directories to determine the highest numerically sorted element.

Modules 4 will resolve module alias or symbolic version passed to :subcmd:`unload` command to then remove the loaded modulefile pointed by the mentioned alias or symbolic version.

Modules 4 resolves module alias or symbolic version pointing to a *modulefile* located in another modulepath.

When locating *modulefiles* on Modules 4, if a *.modulerc*, a *.version*, a directory or a *modulefile* cannot be read during the search it is simply ignored with no error message produced. Visibility of *modulefiles* can thus be adapted to the rights the user has been granted. Exception is made when trying to directly access a directory or a *modulefile*. In this case, the access issue is returned as an error message. Access issue is also returned when a direct access is made to a module alias or a symbolic version targeting an unreadable *modulefile*.


New features
^^^^^^^^^^^^

This section describes the features of Modules version 4 that are not supported on the compatibility version. Please refer to the above section for features supported by both versions but behaving differently.


Package Initialization
""""""""""""""""""""""

Support for *fish*, *lisp*, *tcl* and *R* code output has been introduced on Modules ``4.0``.

On version 4 and for *sh*, *bash*, *ksh*, *zsh* and *fish* shells, text output, like listing from the :subcmd:`avail` command, is redirected from *stderr* to *stdout* after shell command evaluation if shell is in interactive mode. Starting version ``4.1``, this content redirection occurs if shell session is attached to a terminal.

Starting version ``4.5``, a new alias or function called :command:`ml` may be defined at initialization time, to provide a handy frontend to the :command:`module` command.

Starting version ``4.5``, support for Windows *cmd* shell is introduced.

Modulecmd startup
"""""""""""""""""

Starting with version ``4.1``, :file:`modulecmd.tcl` sources upon invocation a site-specific configuration script named :file:`siteconfig.tcl`. This Tcl script enables to supersede any global variable or procedure definition of modulecmd.tcl.


Command line switches
"""""""""""""""""""""

The following command line switches appeared on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New command line switches                                       |
| in version |                                                                 |
+============+=================================================================+
| 4.0        | :option:`--debug`, :option:`-D`, :option:`--default`,           |
|            | :option:`-d`, :option:`--latest`, :option:`-L`                  |
+------------+-----------------------------------------------------------------+
| 4.1        | :option:`--paginate`, :option:`--no-pager`                      |
+------------+-----------------------------------------------------------------+
| 4.2        | :option:`--auto`, :option:`--no-auto`                           |
+------------+-----------------------------------------------------------------+
| 4.3        | :option:`--indepth`, :option:`--no-indepth`, :option:`--color`, |
|            | :option:`--starts-with`, :option:`-S`, :option:`--contains`,    |
|            | :option:`-C`                                                    |
+------------+-----------------------------------------------------------------+
| 4.5        | :option:`--json`, :option:`-j`                                  |
+------------+-----------------------------------------------------------------+
| 4.6        | :option:`--trace`, :option:`-T`, :option:`--all`, :option:`-a`, |
|            | :option:`-DD`                                                   |
+------------+-----------------------------------------------------------------+
| 4.7        | :option:`-vv`, :option:`--output`, :option:`-o`,                |
|            | :option:`--width`, :option:`-w`                                 |
+------------+-----------------------------------------------------------------+

:option:`--long`, :option:`--terse`

 Starting Modules 4.0, :subcmd:`savelist` sub-command is supported.

:option:`--all`

 Starting Modules 4.7, :subcmd:`list` sub-command is supported.


Module Sub-Commands
"""""""""""""""""""

The following module sub-commands appeared on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New module sub-commands                                         |
| in version |                                                                 |
+============+=================================================================+
| 4.0        | :subcmd:`reload`, :subcmd:`source`, :subcmd:`search`,           |
|            | :subcmd:`save`, :subcmd:`restore`, :subcmd:`saverm`,            |
|            | :subcmd:`saveshow`, :subcmd:`savelist`, :subcmd:`path`,         |
|            | :subcmd:`paths`, :subcmd:`autoinit`, :subcmd:`aliases`,         |
|            | :subcmd:`test`                                                  |
+------------+-----------------------------------------------------------------+
| 4.1        | :subcmd:`append-path`, :subcmd:`prepend-path`,                  |
|            | :subcmd:`remove-path`, :subcmd:`is-loaded`, :subcmd:`is-saved`  |
|            | :subcmd:`is-used`, :subcmd:`is-avail`, :subcmd:`info-loaded`    |
+------------+-----------------------------------------------------------------+
| 4.3        | :subcmd:`config`                                                |
+------------+-----------------------------------------------------------------+
| 4.6        | :subcmd:`sh-to-mod`                                             |
+------------+-----------------------------------------------------------------+
| 4.8        | :subcmd:`edit`, :subcmd:`try-load`                              |
+------------+-----------------------------------------------------------------+

All module sub-commands will return a non-zero exit code in case of error whereas on compatibility version issues that occurred do not lead to an exit of the :command:`module` command with a non-zero code.

Starting with version ``4.1``, :command:`module` function for all scripting languages, like Perl or Python, always returns a value. In case of error, a *false* boolean value is returned instead of raising a fatal exception. For module sub-commands returning a text value, the module function will actually return this value. In all other cases a *true* boolean value is returned.

:subcmd:`avail`, :subcmd:`whatis` and :subcmd:`apropos`

 Non-critical errors are not displayed on :subcmd:`avail`, :subcmd:`whatis` and :subcmd:`apropos` sub-commands. Only valid results are returned.

 Module aliases are included in the result of these sub-commands. They are displayed in the module path section where they are defined or in a *global/user modulerc* section for aliases set in user's or global modulerc file. A ``@`` symbol is added in parenthesis next to their name to distinguish them from *modulefiles*.

 Search may be performed with an alias or a symbolic version-name passed as argument.

 Arguments to these :subcmd:`avail`, :subcmd:`whatis` and :subcmd:`apropos` commands may use wildcard characters to express glob patterns.


Collections
"""""""""""

Modules :ref:`collections` have been introduced on Modules ``4.0``.


Environment
"""""""""""

The following environment variables appeared on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New environment variables                                       |
| in version |                                                                 |
+============+=================================================================+
| 4.0        | :envvar:`MODULECONTACT`, :envvar:`MODULES_COLLECTION_TARGET`,   |
|            | :envvar:`MODULES_USE_COMPAT_VERSION`,                           |
|            | :envvar:`<VAR>_modshare<__MODULES_SHARE_\<VAR\>>`               |
+------------+-----------------------------------------------------------------+
| 4.1        | :envvar:`MODULES_CMD`, :envvar:`MODULES_COLLECTION_PIN_VERSION`,|
|            | :envvar:`MODULES_PAGER`, :envvar:`MODULES_RUNENV_\<VAR\>`,      |
|            | :envvar:`MODULES_RUN_QUARANTINE`,                               |
|            | :envvar:`MODULES_SILENT_SHELL_DEBUG`,                           |
|            | :envvar:`<VAR>_modquar<__MODULES_QUAR_<VAR>>`                   |
+------------+-----------------------------------------------------------------+
| 4.2        | :envvar:`MODULES_AUTO_HANDLING`,                                |
|            | :envvar:`MODULES_LMALTNAME<__MODULES_LMALTNAME>`,               |
|            | :envvar:`MODULES_LMCONFLICT<__MODULES_LMCONFLICT>`,             |
|            | ``MODULES_LMNOTUASKED``,                                        |
|            | :envvar:`MODULES_LMPREREQ<__MODULES_LMPREREQ>`                  |
+------------+-----------------------------------------------------------------+
| 4.3        | :envvar:`MODULES_AVAIL_INDEPTH`, :envvar:`MODULES_COLOR`,       |
|            | :envvar:`MODULES_COLORS`, :envvar:`MODULES_IMPLICIT_DEFAULT`,   |
|            | :envvar:`MODULES_SEARCH_MATCH`,                                 |
|            | :envvar:`MODULES_SET_SHELL_STARTUP`,                            |
|            | :envvar:`MODULES_SITECONFIG`, :envvar:`MODULES_TERM_BACKGROUND`,|
|            | :envvar:`MODULES_UNLOAD_MATCH_ORDER`,                           |
|            | :envvar:`MODULES_VERBOSITY`, :envvar:`MODULES_WA_277`           |
+------------+-----------------------------------------------------------------+
| 4.4        | :envvar:`MODULES_ADVANCED_VERSION_SPEC`,                        |
|            | :envvar:`MODULES_EXTENDED_DEFAULT`, :envvar:`MODULES_ICASE`     |
+------------+-----------------------------------------------------------------+
| 4.5        | :envvar:`MODULES_ML`                                            |
+------------+-----------------------------------------------------------------+
| 4.6        | :envvar:`MODULES_LMSOURCESH<__MODULES_LMSOURCESH>`,             |
|            | :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS`                         |
+------------+-----------------------------------------------------------------+
| 4.7        | :envvar:`MODULES_SHELLS_WITH_KSH_FPATH`,                        |
|            | :envvar:`MODULES_IMPLICIT_REQUIREMENT`,                         |
|            | :envvar:`MODULES_LMTAG<__MODULES_LMTAG>`,                       |
|            | :envvar:`MODULES_TAG_ABBREV`, :envvar:`MODULES_TAG_COLOR_NAME`, |
|            | :envvar:`MODULES_MCOOKIE_VERSION_CHECK`                         |
|            | :envvar:`MODULES_AVAIL_OUTPUT`,                                 |
|            | :envvar:`MODULES_AVAIL_TERSE_OUTPUT`,                           |
|            | :envvar:`MODULES_LIST_OUTPUT`,                                  |
|            | :envvar:`MODULES_LIST_TERSE_OUTPUT`,                            |
|            | :envvar:`MODULES_TERM_WIDTH`                                    |
+------------+-----------------------------------------------------------------+
| 4.8        | :envvar:`MODULES_EDITOR`, :envvar:`MODULES_VARIANT_SHORTCUT`,   |
|            | :envvar:`MODULES_LMVARIANT<__MODULES_LMVARIANT>`                |
+------------+-----------------------------------------------------------------+


Modules Specific Tcl Commands
"""""""""""""""""""""""""""""

The following modulefile Tcl commands appeared on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New modulefile Tcl commands                                     |
| in version |                                                                 |
+============+=================================================================+
| 4.0        | :mfcmd:`module-info command<module-info>`, :mfcmd:`getenv`,     |
|            | :mfcmd:`report`, :mfcmd:`reportError`, :mfcmd:`reportWarning`   |
+------------+-----------------------------------------------------------------+
| 4.1        | :mfcmd:`module-info loaded<module-info>`, :mfcmd:`is-saved`,    |
|            | :mfcmd:`is-used`, :mfcmd:`is-avail`, :mfcmd:`module-virtual`    |
+------------+-----------------------------------------------------------------+
| 4.2        | :mfcmd:`set-function`, :mfcmd:`unset-function`                  |
+------------+-----------------------------------------------------------------+
| 4.6        | :mfcmd:`source-sh`, :mfcmd:`module-hide`,                       |
|            | :mfcmd:`module-forbid`,                                         |
|            | :mfcmd:`module-info usergroups<module-info>`,                   |
|            | :mfcmd:`module-info username<module-info>`                      |
+------------+-----------------------------------------------------------------+
| 4.7        | :mfcmd:`versioncmp`, :mfcmd:`module-tag`,                       |
|            | :mfcmd:`module-info tags<module-info>`                          |
+------------+-----------------------------------------------------------------+
| 4.8        | :mfcmd:`variant`, :mfcmd:`getvariant`                           |
+------------+-----------------------------------------------------------------+

:mfcmd:`conflict` and :mfcmd:`prereq`

 Starting with version ``4.2``, these Modules-specific Tcl commands support being called with a symbolic modulefile or a modulefile alias passed as argument.

:mfcmd:`getenv`

 Starting with version ``4.2``, an optional *value* argument is added on :mfcmd:`getenv` to define the value to return in case environment variable is not set.

:mfcmd:`module`

 In case of ``module load`` command specifying multiple *modulefiles*, when mode is set to ``unload`` these *modulefiles* will be unloaded in the reverse order to ensure correct handling of prerequisites.

 Starting with version ``4.7``, the ``load``, ``unload`` and ``switch`` sub-commands support the ``--not-req`` option to avoid recording a prereq or a conflict requirement toward specified modules.

:mfcmd:`append-path` and :mfcmd:`prepend-path`

 Starting with version ``4.1``, both commands handle being called with multiple *value* arguments and option ``--duplicates`` is added.

:mfcmd:`remove-path`

 Starting with version ``4.1``, :mfcmd:`remove-path` handles being called with multiple *value* arguments and option ``--index`` is added.

:mfcmd:`is-loaded`

 Starting with version ``4.1``, :mfcmd:`is-loaded` supports being called with no argument passed. In this case, it returns *true* if any modulefile is currently loaded, *false* otherwise.

 Starting with version ``4.2``, :mfcmd:`is-loaded` supports being called with a symbolic modulefile or a modulefile alias passed as argument.

 This Modules-specific Tcl command was not enabled for *modulerc* evaluation starting Modules version ``4.0`` but it has been reintroduced starting version ``4.2.1``.


Modules Variables
"""""""""""""""""

The following Modules-specific Tcl variables appeared on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New Modules-specific Tcl variables                              |
| in version |                                                                 |
+============+=================================================================+
| 4.7        | :mfvar:`ModuleTool`, :mfvar:`ModuleToolVersion`                 |
+------------+-----------------------------------------------------------------+
| 4.8        | :mfvar:`ModuleVariant`                                          |
+------------+-----------------------------------------------------------------+


Modules configuration options
"""""""""""""""""""""""""""""

The concept of configuration option has been introduced on Modules ``4.3``. The
following Modules configuration option has been introduced on Modules 4.

+------------+-----------------------------------------------------------------+
| Introduced | New Modules configuration options                               |
| in version |                                                                 |
+============+=================================================================+
| 4.3        | :mconfig:`auto_handling`, :mconfig:`avail_indepth`,             |
|            | :mconfig:`collection_pin_version`, :mconfig:`collection_target`,|
|            | :mconfig:`color`, :mconfig:`colors`, :mconfig:`contact`,        |
|            | :mconfig:`extra_siteconfig`, :mconfig:`implicit_default`,       |
|            | :mconfig:`locked_configs`, :mconfig:`pager`, :mconfig:`rcfile`, |
|            | :mconfig:`run_quarantine`, :mconfig:`silent_shell_debug`,       |
|            | :mconfig:`search_match`, :mconfig:`set_shell_startup`,          |
|            | :mconfig:`term_background`, :mconfig:`unload_match_order`,      |
|            | :mconfig:`verbosity`, :mconfig:`wa_277`                         |
+------------+-----------------------------------------------------------------+
| 4.4        | :mconfig:`advanced_version_spec`, :mconfig:`extended_default`,  |
|            | :mconfig:`home`, :mconfig:`icase`                               |
+------------+-----------------------------------------------------------------+
| 4.5        | :mconfig:`ml`                                                   |
+------------+-----------------------------------------------------------------+
| 4.6        | :mconfig:`nearly_forbidden_days`                                |
+------------+-----------------------------------------------------------------+
| 4.7        | :mconfig:`avail_output`, :mconfig:`avail_terse_output`,         |
|            | :mconfig:`implicit_requirement`, :mconfig:`list_output`,        |
|            | :mconfig:`list_terse_output`, :mconfig:`mcookie_version_check`, |
|            | :mconfig:`shells_with_ksh_fpath`, :mconfig:`tag_abbrev`,        |
|            | :mconfig:`tag_color_name`, :mconfig:`term_width`                |
+------------+-----------------------------------------------------------------+
| 4.8        | :mconfig:`editor`, :mconfig:`variant_shortcut`                  |
+------------+-----------------------------------------------------------------+

:mconfig:`list_output`, :mconfig:`list_terse_output`

 Starting version 4.8, element ``variant`` is added to the list of accepted
 values. It is added to the default value list of :mconfig:`list_output`.


.. _Modules 5 changes:

Modules 5
---------

This section provides the list of differences with Modules version 4.
Comparison takes as a basis version ``4.8`` against Modules version ``5.0``.
Any change made past these versions will explicitly mention the release number
starting from the difference appears or disappears.

Removed or changed features
^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes the features of Modules 4 that are not supported or
that behave differently on Modules 5.

Package Initialization
""""""""""""""""""""""

The initialization configuration file :file:`initrc` and the
modulepath-specific configuration file :file:`modulespath` are now searched by
default in the ``etcdir`` instead of in the ``initdir``. Moreover these
configuration files are only searched in one location. Previously they were
searched in both ``etcdir`` and ``initdir`` locations by Modules
initialization process.

When initializing Modules, the :file:`initrc` configuration file is evaluated
in addition to the the :file:`modulespath` configuration file and not instead
of this file. :file:`initrc` is evaluated after :file:`modulespath` file.

Report the modules loading and unloading during the evaluation of the
:file:`initrc` configuration file. These report messages are disabled when the
:mconfig:`verbosity` configuration option is set to ``concise`` or ``silent``.

Enforce use of the Modules magic cookie (i.e., ``#%Module`` file signature) at
the start of :file:`initrc` configuration file. No evaluation occurs and an
error is produced if the magic cookie is missing or if the optional version
number placed after the cookie string is higher than the version of the
:file:`modulecmd.tcl` script in use.

Quarantine mechanism code in the Modules shell initialization scripts is now
always defined and mechanism always applies if some environment variables are
defined in :envvar:`MODULES_RUN_QUARANTINE`. Code in the :file:`modulecmd.tcl`
script to restore environment variables put in quarantine is now always
generated and applies if the :envvar:`__MODULES_QUARANTINE_SET` environment
variable is set to ``1``. By default on Modules 5 the :command:`module` shell
function definition is generated without quarantine support but it could be
enabled by setting :mconfig:`quarantine_support` to ``1`` in :file:`initrc`.

Code to silence shell debug properties in the Modules shell initialization
scripts is now always defined and mechanism applies if
:envvar:`MODULES_SILENT_SHELL_DEBUG` is set to ``1``. Code to silence shell
debug properties in the :command:`module` shell function could now be enabled
if :envvar:`MODULES_SILENT_SHELL_DEBUG` is set to ``1`` prior Modules
initialization or if the :mconfig:`silent_shell_debug` configuration option is
set to ``1`` in the :file:`initrc` configuration file. Option is set off by
default on Modules 5.

During the :subcmd:`autoinit` process, the environment variable
:envvar:`__MODULES_AUTOINIT_INPROGRESS` is checked and if it is found set to
``1``, the initialization process immediately ends. If not, this environment
variable is set to ``1`` which ensures no initialization loop could occur,
especially when the :mconfig:`set_shell_startup` configuration option is set.

Modulecmd startup
"""""""""""""""""

Enforce use of the Modules magic cookie (i.e., ``#%Module`` file signature) at
the start of global or user rc files. These files are not evaluated and an
error is produced if the magic cookie is missing or if the optional version
number placed after the cookie string is higher than the version of the
:file:`modulecmd.tcl` script in use.

Module Sub-Commands
"""""""""""""""""""

:subcmd:`append-path`, :subcmd:`prepend-path`, :subcmd:`remove-path`

 When sub-command is not called during a modulefile evaluation, the reference
 counter associated with each entry in targeted environment variable is
 ignored. In such context, a
 :subcmd:`module append-path/prepend-path<prepend-path>` will not increase the
 reference counter of a path entry already defined and a
 :subcmd:`module remove-path<remove-path>` will remove specified path
 whatever its reference counter value.

:subcmd:`display`

 No error is raised when evaluating a modulefile without a value specified for
 the :mfcmd:`variant` it defines. As a result, the unspecified variant is not
 instantiated in the :mfvar:`ModuleVariant` array variable.

:subcmd:`load`

 Reference counting mechanism is not anymore applied to the Modules-specific
 path variables (like :envvar:`LOADEDMODULES`). As a result no
 :envvar:`__MODULES_SHARE_\<VAR\>` variable is set in user environment for
 these variables. Exception is made for :envvar:`MODULEPATH` environment
 variable where the mechanism still applies.

:subcmd:`refresh`

 Sub-command evaluates all loaded modulefiles and re-apply the non-persistent
 environment changes they define (i.e., shell aliases, shell functions and
 command put on stdout channel). With this change the :subcmd:`refresh`
 sub-command is restored to the behavior it had on Modules version 3.2.

:subcmd:`restore`, :subcmd:`source`

 Only report the module load and unload directly triggered by these
 sub-commands. Load and unload triggered by other modules are reported through
 the automated module handling messages of the main modules.

:subcmd:`restore`

 Starting Modules 5.2:

 * if no argument is provided and if default collection does not exist,
   initial environment is restored.
 * *sticky* modules are unloaded when restoring a collection.

:subcmd:`source`

 Enforce use of the Modules magic cookie (i.e., ``#%Module`` file signature) at
 the start of any scriptfile passed for evaluation to the :subcmd:`source`
 sub-command. These files are not evaluated and an error is produced if the
 magic cookie is missing or if the optional version number placed after the
 cookie string is higher than the version of the :file:`modulecmd.tcl` script
 in use.

:subcmd:`saveshow`

 Starting Modules 5.2, if no argument is provided and if default collection
 does not exist, initial environment is displayed.

:subcmd:`use`

 Non-existent modulepath is now accepted as argument.

 Reference counting mechanism is ignored when sub-command is not called during
 a modulefile evaluation. In such context, a :subcmd:`module use<use>` will
 not increase the reference counter of a path entry already defined.

:subcmd:`unuse`

 Reference counting mechanism is ignored when sub-command is not called during
 a modulefile evaluation. In such context, a :subcmd:`module unuse<unuse>`
 will remove specified path whatever its reference counter value.

 Correctly handle several modulepaths specified as a single argument (i.e.,
 ``/path/to/dir1:/path/to/dir2``).

Modules Specific Tcl Commands
"""""""""""""""""""""""""""""

:mfcmd:`append-path`, :mfcmd:`prepend-path`

 When an element is added to a path-like variable, add this element to the
 associated reference counter variable (named
 :envvar:`__MODULES_SHARE_\<VAR\>`) only when this element is added multiple
 times to the path-like variable. When an element is removed from a path-like
 variable, this element is removed from the reference counter variable when
 its counter is equal to 1.

:mfcmd:`chdir`, :mfcmd:`module`, ``module-trace``, ``module-verbosity``,
``module-user``, ``module-log``

 These modulefile commands have been undeclared from the modulerc Tcl
 interpreter on Modules 5. An error message is obtained if still used instead
 of silently ignoring it.

:mfcmd:`getenv`

 When passed environment variable is not defined, an empty string is returned
 by default rather ``_UNDEFINED_``.

:mfcmd:`module`

 Forbid use of :subcmd:`module source<source>` command in modulefile or in an
 initialization rc file, the ``source`` Tcl command should be used instead.

 Starting version ``5.1`` an error is raised when an unused option is set on
 ``module use`` or ``module unuse`` commands.

:mfcmd:`unsetenv`

 When running on an unload evaluation, do not unset designated environment
 variable if no value to restore is provided.

 Distinguish between being called on a unload evaluation without a value to
 restore or with an empty string value to restore.

:mfcmd:`variant`

 Starting version 5.1, :mfcmd:`variant` command accepts being called without a
 list of accepted value defined. In this case, any value specified is
 accepted.

 Starting version 5.5, a valid variant name is only composed of the
 ``[A-Za-z0-9_-]``  characters. It cannot start with ``-`` character and the
 name as a whole cannot correspond to a number.

Locating Modulefiles
""""""""""""""""""""

As the :ref:`Advanced module version specifiers` mechanism is enabled by
default on Modules 5.0, several characters are made special and cannot be used
anymore in module name or version. These characters are ``@``, ``=``, ``~``,
``+`` and ``,``. Also a module name cannot start with ``-`` character. Module
name is allowed to finish by one or more ``+`` character but ``+`` cannot be
used at the start or inside a module name.

Starting version 5.5, characters ``+`` and ``~`` may be part of module name or
version as long as the string part next to these character is not a valid
variant name.

Environment
"""""""""""

The following Modules environment variables have been changed on Modules 5.

+--------------------------------------+---------------------------------------------+
| Environment variable                 | Change                                      |
+======================================+=============================================+
| :envvar:`MODULES_LMALTNAME`          | Renamed to :envvar:`__MODULES_LMALTNAME`    |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMCONFLICT`         | Renamed to :envvar:`__MODULES_LMCONFLICT`   |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMNOTUASKED`        | Removed                                     |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMPREREQ`           | Renamed to :envvar:`__MODULES_LMPREREQ`     |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMSOURCESH`         | Renamed to :envvar:`__MODULES_LMSOURCESH`   |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMTAG`              | Renamed to :envvar:`__MODULES_LMTAG`        |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_LMVARIANT`          | Renamed to :envvar:`__MODULES_LMVARIANT`    |
+--------------------------------------+---------------------------------------------+
| :envvar:`MODULES_USE_COMPAT_VERSION` | Removed                                     |
+--------------------------------------+---------------------------------------------+
| :envvar:`<VAR>_modquar`              | Renamed to :envvar:`__MODULES_QUAR_\<VAR\>` |
+--------------------------------------+---------------------------------------------+
| :envvar:`<VAR>_modshare`             | Renamed to :envvar:`__MODULES_SHARE_\<VAR\>`|
+--------------------------------------+---------------------------------------------+

Modules configuration options
"""""""""""""""""""""""""""""

The default value of the following Modules configuration option has been
changed on Modules 5.

+---------------------------------+------------------------+-------------------+
| Configuration option            | Previous default value | New default value |
+=================================+========================+===================+
| :mconfig:`auto_handling`        | ``0``                  | ``1``             |
+---------------------------------+------------------------+-------------------+
| :mconfig:`extended_default`     | ``0``                  | ``1``             |
+---------------------------------+------------------------+-------------------+
| :mconfig:`advanced_version_spec`| ``0``                  | ``1``             |
+---------------------------------+------------------------+-------------------+
| :mconfig:`color`                | ``never``              | ``auto``          |
+---------------------------------+------------------------+-------------------+
| :mconfig:`icase`                | ``never``              | ``search``        |
+---------------------------------+------------------------+-------------------+
| :mconfig:`set_shell_startup`    | ``1``                  | ``0``             |
+---------------------------------+------------------------+-------------------+
| :mconfig:`silent_shell_debug`   | *undefined*            | ``0``             |
+---------------------------------+------------------------+-------------------+

New features
^^^^^^^^^^^^

Package Initialization
""""""""""""""""""""""

When initializing Modules, :subcmd:`refresh` the loaded modules in case some
user environment is already configured.

Starting version ``5.5``, support for Windows *pwsh* shell is introduced.

Command line switches
"""""""""""""""""""""

The following command line switches appeared on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New command line switches                                       |
| in version |                                                                 |
+============+=================================================================+
| 5.1        | :option:`--redirect`, :option:`--no-redirect`, :option:`--tag`  |
+------------+-----------------------------------------------------------------+
| 5.2        | :option:`--timer`                                               |
+------------+-----------------------------------------------------------------+
| 5.3        | :option:`--ignore-cache`, :option:`--ignore-user-rc`            |
+------------+-----------------------------------------------------------------+
| 5.6        | :option:`--dumpname`                                            |
+------------+-----------------------------------------------------------------+

:option:`--output`

 Starting Modules 5.3, this command line switch accepts value prefixed by
 ``+`` or ``-`` which means value should respectively be appended to or
 subtracted from current configuration option value.

 Starting Modules 5.6, :subcmd:`spider` sub-command is supported.

:option:`--force`

 Starting Modules 5.4, this command line switch by-passes *abort on error*
 behavior. Modulefile is unloaded anyway when an evaluation error occurs if
 :option:`--force` option is used.

:option:`--all`

 Starting Modules 5.2, :subcmd:`lint` and :subcmd:`savelist` sub-commands are
 supported.

 Starting Modules 5.6, :subcmd:`spider` sub-command is supported.

:option:`--contains`, :option:`--starts-with`

 Starting Modules 5.1, :subcmd:`list` sub-command is supported.

 Starting Modules 5.2, :subcmd:`savelist` sub-command is supported.

 Starting Modules 5.6, :subcmd:`spider` sub-command is supported.

:option:`--json`, :option:`--long`, :option:`--terse`

 Starting Modules 5.2, :subcmd:`stashlist` sub-command is supported.

 Starting Modules 5.6, :subcmd:`spider` sub-command is supported.

:option:`--default`, :option:`--latest`, :option:`--indepth`,
:option:`--no-indepth`

 Starting Modules 5.6, :subcmd:`spider` sub-command is supported.

Module Sub-Commands
"""""""""""""""""""

The following module sub-commands appeared on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New module sub-commands                                         |
| in version |                                                                 |
+============+=================================================================+
| 5.1        | :subcmd:`state`, :subcmd:`load-any`                             |
+------------+-----------------------------------------------------------------+
| 5.2        | :subcmd:`lint`, :subcmd:`mod-to-sh`, :subcmd:`reset`,           |
|            | :subcmd:`stash`, :subcmd:`stashpop`, :subcmd:`stashrm`,         |
|            | :subcmd:`stashshow`, :subcmd:`stashclear`, :subcmd:`stashlist`  |
+------------+-----------------------------------------------------------------+
| 5.3        | :subcmd:`cachebuild`, :subcmd:`cacheclear`                      |
+------------+-----------------------------------------------------------------+
| 5.6        | :subcmd:`spider`, :subcmd:`update`, :subcmd:`disable`,          |
|            | :subcmd:`describe`                                              |
+------------+-----------------------------------------------------------------+

:subcmd:`list`

 Starting Modules 5.1:

 * this sub-command accepts patterns to filter the loaded modules to list.
 * the :option:`--starts-with` and :option:`--contains` options are supported
   on this sub-command to provide the regular search match capabilities.

 Starting Modules 5.3:

 * Search query with just a variant set (no module name and version) is
   accepted.

:subcmd:`refresh`

 Starting Modules 5.2, only the loaded modules listed in the
 :envvar:`__MODULES_LMREFRESH` environment variables are refreshed.

:subcmd:`restore`

 Starting Modules 5.2, initial environment is restored when specified
 collection name is ``__init__``.

:subcmd:`savelist`

 Starting Modules 5.2:

 * this sub-command accepts patterns to filter the named collections to list.
 * the :option:`--starts-with` and :option:`--contains` options are supported
   on this sub-command to provide the regular search match capabilities.
 * the :option:`--all` option is supported on this sub-command not to limit to
   the collection matching currently set collection target.

:subcmd:`saveshow`

 Starting Modules 5.2, initial environment is displayed when specified
 collection name is ``__init__``.

:subcmd:`sh-to-mod`

 Starting Modules ``5.1``, this sub-command also tracks shell completion
 changes for bash, tcsh and fish shells.

 Shell mode ``bash-eval`` is introduced on Modules version ``5.4``.

:subcmd:`source`

 Starting Modules 5.2, this sub-command accepts modulefile specification as
 argument in addition to file path.

:subcmd:`avail`, :subcmd:`paths`, :subcmd:`whatis`

 Starting Modules 5.3:

 * variant specified in search query is taken into account to return available
   modules matching the variant specification.
 * when one variant is specified multiple times in search query, returned
   modules are those providing all the specified variant values.
 * Search query with just a variant set (no module name and version) is
   accepted.
 * :ref:`Extra specifier` is accepted in search query to query content of
   modulefiles.

 Starting Modules 5.4:

 * ``tag`` :ref:`extra specifier` is introduced.
 * set multiple values on extra specifier, each of them separated by comma
   character, to get modules matching any of these values (*OR* operator).
 * set multiple values on variant specification, each of them separated by
   comma character, to get modules providing any of these variant values (*OR*
   operator).

 Starting Modules 5.5:

 * ``not:`` prefix may be added to extra specifier criterion to select modules
   not matching specified values.
 * ``not:`` prefix may be added to variant specification to get modules not
   providing variant or not matching specified variant values.

 Starting Modules 5.6:

 * ``use`` :ref:`extra specifier` is introduced.
 * setting :envvar:`MODULEPATH` environment variable with :mfcmd:`append-path`
   or :mfcmd:`prepend-path` may also be queried with ``use`` extra specifier.
 * ``depends-on-any`` :ref:`extra specifier` is introduced.
 * result of a multi pattern search is consolidated under a single output
 * ``provide`` and ``provided-alias`` :ref:`extra specifier` are introduced.

:subcmd:`reload`

 Starting Modules 5.4, support for :option:`--force` option is added on this
 sub-command.

:subcmd:`autoinit`

 Starting Modules 5.5, definition of :command:`mogui` shell alias or function
 is added on this sub-command.

:subcmd:`lint`

 Starting Modules 5.6, readable modulecache files are also linted when no
 module specification is provided as argument or if :file:`.modulecache` file
 is specifically linted.

:subcmd:`cachebuild`

 Starting Modules 5.6, the minimal Modules version specified in the cache file
 header indicates the oldest Modules version compatible with this cache file
 (5.3), rather than the version that generated the cache file.

:subcmd:`update`

 This sub-command is reintroduced (was part of Modules v3) as a simple alias
 of :subcmd:`reload` sub-command. No more support from ``MODULESBEGINENV``,
 initial environment handling now covers this use case.

Environment
"""""""""""

The following environment variables appeared on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New environment variables                                       |
| in version |                                                                 |
+============+=================================================================+
| 5.0        | :envvar:`MODULES_QUARANTINE_SUPPORT`,                           |
|            | :envvar:`__MODULES_QUARANTINE_SET`,                             |
|            | :envvar:`__MODULES_AUTOINIT_INPROGRESS`                         |
+------------+-----------------------------------------------------------------+
| 5.1        | :envvar:`MODULES_REDIRECT_OUTPUT`,                              |
|            | :envvar:`MODULES_MCOOKIE_CHECK`,                                |
|            | :envvar:`MODULES_FAMILY_\<NAME\>`,                              |
|            | :envvar:`__MODULES_PUSHENV_\<VAR\>`,                            |
|            | :envvar:`__MODULES_LMEXTRATAG`,                                 |
|            | :envvar:`MODULES_COLLECTION_PIN_TAG`                            |
+------------+-----------------------------------------------------------------+
| 5.2        | :envvar:`MODULES_PROTECTED_ENVVARS`,                            |
|            | :envvar:`MODULES_TCL_LINTER`,                                   |
|            | :envvar:`__MODULES_LMINIT`,                                     |
|            | :envvar:`MODULES_RESET_TARGET_STATE`,                           |
|            | :envvar:`__MODULES_LMREFRESH`                                   |
+------------+-----------------------------------------------------------------+
| 5.3        | :envvar:`MODULES_IGNORE_CACHE`,                                 |
|            | :envvar:`MODULES_CACHE_BUFFER_BYTES`,                           |
|            | :envvar:`MODULES_CACHE_EXPIRY_SECS`                             |
|            | :envvar:`MODULES_IGNORE_USER_RC`                                |
+------------+-----------------------------------------------------------------+
| 5.4        | :envvar:`MODULES_STICKY_PURGE`,                                 |
|            | :envvar:`MODULES_UNIQUE_NAME_LOADED`,                           |
|            | :envvar:`MODULES_ABORT_ON_ERROR`,                               |
|            | :envvar:`__MODULES_LMSTICKYRULE`,                               |
|            | :envvar:`MODULES_SOURCE_CACHE`                                  |
+------------+-----------------------------------------------------------------+
| 5.5        | :envvar:`MODULES_HIDE_AUTO_LOADED`, :envvar:`MODULES_LOGGER`,   |
|            | :envvar:`MODULES_LOGGED_EVENTS`,                                |
|            | :envvar:`MODULES_CONFLICT_UNLOAD`,                              |
|            | :envvar:`__MODULES_LMPREREQPATH`                                |
+------------+-----------------------------------------------------------------+
| 5.6        | :envvar:`MODULES_SPIDER_OUTPUT`,                                |
|            | :envvar:`MODULES_SPIDER_TERSE_OUTPUT`,                          |
|            | :envvar:`MODULES_SPIDER_INDEPTH`,                               |
|            | :envvar:`__MODULES_LMUSE`,                                      |
|            | :envvar:`MODULES_REQUIRE_VIA`                                   |
+------------+-----------------------------------------------------------------+

Modules Specific Tcl Commands
"""""""""""""""""""""""""""""

The following modulefile Tcl commands appeared on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New modulefile Tcl commands                                     |
| in version |                                                                 |
+============+=================================================================+
| 5.1        | :mfcmd:`add-property`, :mfcmd:`remove-property`,                |
|            | :mfcmd:`extensions`, :mfcmd:`prereq-any`,                       |
|            | :mfcmd:`require-fullname`, :mfcmd:`depends-on`,                 |
|            | :mfcmd:`prereq-all`, :mfcmd:`always-load`,                      |
|            | :mfcmd:`module load-any<module>`, :mfcmd:`family`,              |
|            | :mfcmd:`complete`, :mfcmd:`uncomplete`, :mfcmd:`pushenv`        |
+------------+-----------------------------------------------------------------+
| 5.4        | :mfcmd:`modulepath-label`                                       |
+------------+-----------------------------------------------------------------+
| 5.5        | :mfcmd:`hide-modulefile`, :mfcmd:`hide-version`,                |
|            | :mfcmd:`lsb-release`                                            |
+------------+-----------------------------------------------------------------+
| 5.6        | :mfcmd:`depends-on-any`, :mfcmd:`module-help`,                  |
|            | :mfcmd:`module-warn`, :mfcmd:`haveDynamicMPATH`,                |
|            | :mfcmd:`provide`                                                |
+------------+-----------------------------------------------------------------+

:mfcmd:`system`, :mfcmd:`is-used`

 Starting Modules 5.0, these modulefile commands are available from a modulerc
 evaluation context.

:mfcmd:`getenv`

 Starting version 5.1, the ``--return-value`` option is added to return
 environment variable value or its fallback when modulefile is evaluated in
 *display* mode.

:mfcmd:`prereq`, :mfcmd:`module load/try-load/load-any/switch<module>`

 Starting Modules 5.1, these modulefile commands accept the :option:`--tag`
 option.

:mfcmd:`prereq`, :mfcmd:`prereq-all`, :mfcmd:`always-load`,
:mfcmd:`depends-on`

 Starting Modules 5.2, these modulefile commands accept the ``--optional``
 option.

 Starting Modules 5.5, these modulefile commands accept the ``--modulepath``
 option.

:mfcmd:`module try-load/load-any<module>`

 Starting Modules 5.1, these modulefile commands accept the ``--not-req``
 option.

:mfcmd:`module unload<module>`

 Starting version ``5.5`` all matching modules loaded and their dependent are
 unloaded if both :mconfig:`auto_handling` and :mconfig:`conflict_unload`
 configuration options are enabled.

 Starting version ``5.6`` unloading a module that enables a modulepath unloads
 all loaded modules stored in this modulepath if :mconfig:`require_via`
 configuration option is enabled.

:mfcmd:`module unuse<module>`

 Starting version ``5.1`` options ``--*-on-unload`` added to the
 :mfcmd:`remove-path` command are also added to the ``module unuse`` command.

:mfcmd:`puts`

 Starting Modules 5.1, if content is sent to the ``prestdout`` channel, it is
 rendered as command to evaluate in current shell session and prior any other
 environment changes.

 Starting Modules 5.5, if content is sent to the ``log`` channel, it is sent
 to the defined :mconfig:`logger` command.

:mfcmd:`remove-path`

 Starting with version ``5.1``:

 * the ``--remove-on-unload`` option is added to also remove value when
   modulefile is unloaded.
 * the ``--append-on-unload`` and ``--prepend-on-unload`` options are added to
   restore when modulefile is unloaded the value list unset at load time.
 * the ``--noop-on-unload`` option is added to perform no operation when
   modulefile is unloaded.

 Starting with version ``5.4``, the ``--glob`` option is added to remove value
 matching a glob-style pattern.

:mfcmd:`setenv`

 Starting with version ``5.1``, the ``--set-if-undef`` option is added to set
 environment variable when modulefile is loaded only if not yet defined.

 Starting with version ``5.6``, value set can contain newline character.
 Exception for csh shell family where such character is chopped from value.

:mfcmd:`source-sh`

 Starting Modules ``5.1``, this modulefile command also tracks shell
 completion changes for bash, tcsh and fish shells.

 Shell mode ``bash-eval`` is introduced on Modules version ``5.4``.

 ``--ignore`` option is introduced on Modules version ``5.4``.

:mfcmd:`unsetenv`

 Starting with version ``5.1``:

 * the ``--noop-on-unload`` option is added to perform no operation when
   modulefile is unloaded.
 * the ``--unset-on-unload`` option is added to also unset variable when
   modulefile is unloaded.

:mfcmd:`getvariant`

 Starting version 5.1, the ``--return-value`` option is added to return
 variant value or its fallback when modulefile is evaluated in *display* mode.

:mfcmd:`module-tag`, :mfcmd:`module-hide`, :mfcmd:`module-forbid`

 Starting with version 5.4:

 * module can be specified with its full path file name to precisely target
   one modulefile.
 * module specification on which stickiness applies is recorded in loaded
   environment to determine if it is still satisfied when updating
   environment.
 * options ``--user`` and ``--group`` are added.

:mfcmd:`break`

 Starting with version 5.4, a modulefile using :mfcmd:`break` may be unloaded
 anyway if forced. To forbid unload of a modulefile, it is now advised to tag
 it ``super-sticky`` with :mfcmd:`module-tag` command.

:mfcmd:`conflict`, :mfcmd:`family`

 Starting with version ``5.5``, if :mconfig:`conflict_unload` and
 :mconfig:`auto_handling` configuration options are enabled, all matching
 loaded modules are unloaded.

:mfcmd:`modulepath-label`

 Starting version 5.6, label is also used on :subcmd:`whatis` and
 :subcmd:`search` sub-command output.

:mfcmd:`module use<module>`, :mfcmd:`append-path MODULEPATH<append-path>`,
:mfcmd:`prepend-path MODULEPATH<prepend-path>`

 Starting with version 5.6, if :mconfig:`require_via` configuration option is
 enabled, modulefile enabling a modulepath is considered a requirement of the
 loaded modules stored in this path.

:mfcmd:`extensions`

 Starting with version 5.6, :mfcmd:`extensions` becomes an alias of
 :mfcmd:`provide` modulefile command.

Modules Variables
"""""""""""""""""

The following Modules-specific Tcl variables appeared on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New Modules-specific Tcl variables                              |
| in version |                                                                 |
+============+=================================================================+
| 5.1        | :mfvar:`ModuleVersion`                                          |
+------------+-----------------------------------------------------------------+


Modules configuration options
"""""""""""""""""""""""""""""

The following Modules configuration option has been introduced on Modules 5.

+------------+-----------------------------------------------------------------+
| Introduced | New Modules configuration options                               |
| in version |                                                                 |
+============+=================================================================+
| 5.0        | :mconfig:`quarantine_support`                                   |
+------------+-----------------------------------------------------------------+
| 5.1        | :mconfig:`redirect_output`, :mconfig:`mcookie_check`,           |
|            | :mconfig:`collection_pin_tag`                                   |
+------------+-----------------------------------------------------------------+
| 5.2        | :mconfig:`tcl_linter`, :mconfig:`protected_envvars`,            |
|            | :mconfig:`reset_target_state`                                   |
+------------+-----------------------------------------------------------------+
| 5.3        | :mconfig:`ignore_cache`, :mconfig:`cache_buffer_bytes`,         |
|            | :mconfig:`cache_expiry_secs`, :mconfig:`ignore_user_rc`         |
+------------+-----------------------------------------------------------------+
| 5.4        | :mconfig:`sticky_purge`, :mconfig:`unique_name_loaded`,         |
|            | :mconfig:`abort_on_error`, :mconfig:`source_cache`              |
+------------+-----------------------------------------------------------------+
| 5.5        | :mconfig:`hide_auto_loaded`, :mconfig:`logger`,                 |
|            | :mconfig:`logged_events`, :mconfig:`conflict_unload`            |
+------------+-----------------------------------------------------------------+
| 5.6        | :mconfig:`spider_output`, :mconfig:`spider_terse_output`,       |
|            | :mconfig:`spider_indepth`, :mconfig:`require_via`               |
+------------+-----------------------------------------------------------------+
| 5.7        | :mconfig:`path_entry_reorder`                                   |
+------------+-----------------------------------------------------------------+

:mconfig:`auto_handling`

 Starting version 5.1, modules tagged ``keep-loaded`` are excluded from
 Useless Requirement Unload mechanism.

 Starting version 5.5:

 * Modules tagged ``sticky`` or ``super-sticky`` are excluded from Useless
   Requirement Unload mechanism.
 * No attempt to reload a Dependent Reload module is made if this module is
   not loadable (requirement not loaded or conflict found with loaded
   environment), even if force mode is enabled. Reload is attempted when
   module is not loadable if it is sticky (tagged super-sticky or sticky and
   force mode not enabled).
 * All reload of Dependent Reload modules are now performed on the top load,
   unload or switch evaluation rather right after the load, unload or switch
   that triggered the unload phase of the Dependent Reload mechanism.
 * Dependent Unload modules of Conflict Unload modules are merged into the
   Dependent Reload module list.

 Starting version 5.6:

 * No attempt to reload a Dependent Reload module is made if the modulepath
   where this module is stored is not enabled anymore and module cannot be
   found in other enabled modulepaths. Even if force mode is enabled. Reload
   is attempted when module is not loadable if it is sticky (tagged
   super-sticky or sticky and force mode not enabled).

:mconfig:`avail_output`, :mconfig:`avail_terse_output`

 Starting version 5.3, element ``variant`` is added to the list of accepted
 values.

 Starting version 5.3, element ``variantifspec`` is added to the list of
 accepted values. It is added to the default value list of both configuration
 options.

 Starting Modules 5.3, these configuration options accept value prefixed by
 ``+`` or ``-`` which means value should respectively be appended to or
 subtracted from current configuration option value.

 Starting version 5.3.1, element ``indesym`` is added to the list of accepted
 values.

 Starting version 5.6, elements ``hidden``, ``provided-alias`` and ``via`` are
 added to the list of accepted values. ``via`` is only supported on
 :mconfig:`avail_output`.

:mconfig:`list_output`, :mconfig:`list_terse_output`

 Starting Modules 5.3, these configuration options accept value prefixed by
 ``+`` or ``-`` which means value should respectively be appended to or
 subtracted from current configuration option value.

 Starting version 5.4, elements ``alias`` and ``indesym`` are added to the
 list of accepted values.

 Starting version 5.6, element ``hidden`` is added to the list of accepted
 values.

:mconfig:`colors`, :mconfig:`protected_envvars`,
:mconfig:`shells_with_ksh_fpath`, :mconfig:`tag_abbrev`,
:mconfig:`tag_color_name`, :mconfig:`variant_shortcut`

 Starting Modules 5.3, these configuration options accept value prefixed by
 ``+`` or ``-`` which means value should respectively be appended to or
 subtracted from current configuration option value.

:mconfig:`rcfile`

 Starting Modules 5.4, this configuration option accepts more than one global
 rc file location. A colon character separates each of these locations.

:mconfig:`pager`

 Starting Modules 5.5, pager is not launched if :file:`modulecmd.tcl` program
 is run for scripting language.
