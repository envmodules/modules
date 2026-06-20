.. _modulefile(5):

modulefile
==========


DESCRIPTION
-----------

*modulefiles* are written in the Tool Command Language, :manpage:`Tcl(n)` and
are interpreted by the :file:`modulecmd.tcl` program via the :ref:`module(1)`
user interface. *modulefiles* can be loaded, unloaded, or switched on-the-fly
while the user is working; and can be used to implement site policies
regarding the access and use of applications.

A *modulefile* begins with the ``#%Module`` file signature, also called the
Modules magic cookie. A version number may be placed after this string. The
version number is useful as the *modulefile* format may change thus it
reflects the minimum version of :file:`modulecmd.tcl` required to interpret
the modulefile. If a version number doesn't exist, then :file:`modulecmd.tcl`
will assume the *modulefile* is compatible. Files without the magic cookie or
with a version number greater than the current version of
:file:`modulecmd.tcl` will not be interpreted. If the
:mconfig:`mcookie_version_check` configuration is disabled the version number
set is not checked.

Each *modulefile* contains the changes to a user's environment needed to
access an application. Tcl is a simple programming language which permits
*modulefiles* to be arbitrarily complex, depending upon the application's
and the *modulefile* writer's needs. If support for extended tcl (tclX)
has been configured for your installation of the Modules package, you may
use all the extended commands provided by tclX, too.

A typical *modulefile* is a simple bit of code that set or add entries
to the :envvar:`PATH`, :envvar:`MANPATH`, or other environment variables. A
Modulefile is evaluated against current :file:`modulecmd.tcl`'s mode which
leads to specific evaluation results. For instance if the *modulefile* sets a
value to an environment variable, this variable is set when modulefile is
loaded and unset when modulefile is unloaded.

Tcl has conditional statements that are evaluated when the *modulefile* is
interpreted. This is very effective for managing path or environment changes
due to different OS releases or architectures. The user environment
information is encapsulated into a single *modulefile* kept in a central
location. The same *modulefile* is used by every user on any machine. So,
from the user's perspective, starting an application is exactly the same
irrespective of the machine or platform they are on.

*modulefiles* also hide the notion of different types of shells. From the
user's perspective, changing the environment for one shell looks exactly
the same as changing the environment for another shell. This is useful
for new or novice users and eliminates the need for statements such as "if
you're using the C Shell do this ..., otherwise if you're using the Bourne
shell do this ...". Announcing and accessing new software is uniform and
independent of the user's shell. From the *modulefile* writer's perspective,
this means one set of information will take care of every type of shell.

.. _Modules specific Tcl commands:

Modules Specific Tcl Commands
-----------------------------

The Modules Package uses commands which are extensions to the "standard"
Tool Command Language :manpage:`Tcl(n)` package. Unless otherwise specified,
the Module commands return the empty string. Some commands behave differently
when a *modulefile* is loaded or unloaded. The command descriptions assume
the *modulefile* is being loaded.

.. mfcmd:: add-property name value

 Associate module tag *value* to currently loading *modulefile*. Argument
 *name* is ignored. See :mfcmd:`module-tag` command for more information on
 tags.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: always-load [options] modulefile...

 Load *modulefile* and apply the ``keep-loaded`` tag to it in order to avoid
 the automatic unload of this *modulefile* when modules dependent of it are
 unloaded.

 :mfcmd:`always-load` command accepts the following options:

 * ``--modulepath modulepathlist``
 * ``--optional``
 * ``--tag taglist``

 *modulefile* is declared as a requirement of currently loading module. This
 command acts as an alias of :mfcmd:`module load<module>` command. If more
 than one *modulefile* are specified, then this list acts as a Boolean AND
 operation, which means all specified *modulefiles* are required.

 When the ``--optional`` option is set, each specified *modulefile* is
 declared as an optional requirement. A *modulefile* that cannot be loaded,
 will not stop the evaluation.

 The ``--tag`` option accepts a list of module tags to apply to *modulefile*
 once loaded in addition to the ``keep-loaded`` tag. *taglist* corresponds to
 the concatenation of multiple tags separated by colon character. *taglist*
 should not contain tags inherited from *modulefile* state or from other
 modulefile commands. If module is already loaded, tags from *taglist* are
 added to the list of tags already applied to this module.

 The ``--modulepath`` option accepts a list of modulepath. *modulepathlist*
 corresponds to the concatenation of multiple modulepaths separated by colon
 character. When this option is set, required *modulefile* should be located
 within one of the listed modulepaths. A path in this list may correspond to
 the first path elements of an actual modulepath (e.g., ``/path/to`` will
 match modulefiles located into the ``/path/to/modulefiles`` modulepath
 directory).

 If an attempt to load *modulefile* is performed and ``--modulepath`` option
 is set, *modulefile* will be searched in the enabled modulepaths whose start
 match one of the specified paths and in the specified paths not matching any
 enabled modulepaths. For instance if this option is set to
 ``/path/to:/another/path`` and ``/path/to/modulefiles`` is currently the sole
 enabled modulepath, *modulefile* will be searched into
 ``/path/to/modulefiles`` and ``/another/path`` directories.

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.2
       Option ``--optional`` added

    .. versionchanged:: 5.5
       Option ``--modulepath`` added

.. mfcmd:: append-path [-d C|--delim C|--delim=C] [--duplicates] variable value...

 See :mfcmd:`prepend-path`.

.. mfcmd:: break

 This is not a Modules-specific command, it's actually part of Tcl, which
 has been overloaded similar to the :mfcmd:`continue` and :mfcmd:`exit`
 commands to have the effect of causing the module not to be listed as loaded
 and not affect other modules being loaded concurrently. All non-environment
 commands within the module will be performed up to this point. Processing
 will continue on to the next module on the command line unless if
 :mconfig:`abort_on_error` configuration option is enabled for running module
 sub-command. The :mfcmd:`break` command will only have this effect if not
 used within a Tcl loop though.

 An example: Suppose that a full selection of *modulefiles* are needed for
 various different architectures, but some of the *modulefiles* are not
 needed and the user should be alerted. Having the unnecessary *modulefile*
 be a link to the following ``notavail`` *modulefile* will perform the task
 as required.

 .. code-block:: tcl

      #%Module

      module-help {This module does nothing but alert the user}
      module-help "that the [module-info name] module is not available"

      module-whatis {Notifies user that module is not available.}

      set curMod [module-info name]
      if {[module-info mode load]} {
          puts stderr "Note: '$curMod' is not available for [uname sysname]."
      }
      break

 Modulefile using :mfcmd:`break` command when unloading may be unloaded anyway
 if :option:`--force` option is set. To forbid the unload of a modulefile, it
 is recommended to tag it ``super-sticky`` with :mfcmd:`module-tag` command.

 .. only:: html or latex

    .. versionchanged:: 5.4
       Breaking modulefile is unloaded anyway when :option:`--force` option is
       set

.. mfcmd:: chdir directory

 Set the current working directory to *directory*.

.. mfcmd:: complete shell name body

 Define shell completion for command *name* with specified *body* if *shell*
 is the current shell under which :file:`modulecmd.tcl` was invoked. *Body*
 corresponds to argument options accepted by the shell command which
 defines completion. When a *modulefile* is unloaded, :mfcmd:`complete`
 becomes :mfcmd:`uncomplete`.

 The following *shells* are supported: bash, tcsh, bash and fish. Please refer
 to the documentation of these shells to learn how to define completion. The
 command is ignored if an unsupported shell is specified.

 .. only:: html or latex

    .. versionadded:: 5.1

.. mfcmd:: conflict modulefile...

 :mfcmd:`conflict` controls whether or not the *modulefile* will be loaded.
 The :mfcmd:`conflict` command lists *modulefiles* which conflict with the
 current *modulefile*. If a list contains more than one *modulefile*, then
 each member of the list acts as a Boolean OR operation. Multiple
 :mfcmd:`conflict` commands may be used to create a Boolean AND operation. If
 one of the requirements have not been satisfied, an error is reported and the
 current *modulefile* makes no changes to the user's environment.

 If an argument for :mfcmd:`conflict` is a directory and any other
 *modulefile* from that directory has been loaded, then a conflict will occur.
 For example, specifying X11 as a :mfcmd:`conflict` will stop X11/R4 and
 X11/R5 from being loaded at the same time.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If the :mconfig:`conflict_unload` and :mconfig:`auto_handling` configuration
 options are enabled, :mfcmd:`conflict` will attempt to unload all loaded
 modules that match specification. (see :ref:`Automated module handling
 mechanisms<MODULES_AUTO_HANDLING>` in :ref:`module(1)`).

 .. only:: html or latex

    .. versionchanged:: 5.5
       An attempt to unload module is made if :mconfig:`conflict_unload` and
       :mconfig:`auto_handling` configuration options are enabled

.. mfcmd:: continue

 This is not a modules specific command but another overloaded Tcl command
 and is similar to the :mfcmd:`break` or :mfcmd:`exit` commands except the
 module will be listed as loaded as well as performing any environment or Tcl
 commands up to this point and then continuing on to the next module on
 the command line. The :mfcmd:`continue` command will only have this effect if
 not used within a Tcl loop though.

.. mfcmd:: depends-on [options] modulefile...

 Alias of :mfcmd:`prereq-all` command.

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.2
       Option ``--optional`` added

    .. versionchanged:: 5.5
       Option ``--modulepath`` added

.. mfcmd:: depends-on-any [options] modulefile...

 Alias of :mfcmd:`prereq` command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: exit [N]

 This is not a modules specific command but another overloaded Tcl command
 and is similar to the :mfcmd:`break` or :mfcmd:`continue` commands. However,
 this command will cause the immediate cessation of this module. Any
 additional modules on the command line will not be evaluated even if the
 :mconfig:`abort_on_error` configuration option is disabled for running
 module sub-command. This module and the subsequent modules will not be listed
 as loaded. No environment commands will be performed in the current module.

.. mfcmd:: extensions modulefile...

 Alias of :mfcmd:`provide` command.

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.6
       Changed from *no-operation* command to alias of :mfcmd:`provide`

.. mfcmd:: family name

 Defines loading modulefile as a member of family *name*. Only one member of a
 family could be loaded. Error is raised when attempting to load another
 member of the same family *name*.

 :mfcmd:`family` corresponds to the definition of a :mfcmd:`conflict` on
 *name* and the definition of a :mfcmd:`module-alias` *name* targeting
 currently loading module.

 In addition, the :envvar:`MODULES_FAMILY_\<NAME\>` environment variable is
 defined and set to the currently loading module name minus version. This
 variable helps to know what module provides for the family *name* in the
 currently loaded environment. For instance if loading modulefile ``foo/1.0``
 defines being member of the ``bar`` family, the
 :envvar:`MODULES_FAMILY_BAR<MODULES_FAMILY_\<NAME\>>` will be set to the
 ``foo`` value. For compatibility, the :envvar:`LMOD_FAMILY_\<NAME\>`
 environment variable is also defined and set to the same value than
 :envvar:`MODULES_FAMILY_\<NAME\>`.

 *name* should be a non-empty string only containing characters that could be
 part of an environment variable name (i.e., *[a-zA-Z0-9_]*).

 If the :mconfig:`conflict_unload` and :mconfig:`auto_handling` configuration
 options are enabled, an attempt to unload loaded module that defines the same
 family is made. (see :ref:`Automated module handling
 mechanisms<MODULES_AUTO_HANDLING>` in :ref:`module(1)`).

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.5
       An attempt to unload module defining same family is made if
       :mconfig:`conflict_unload` and :mconfig:`auto_handling` configuration
       options are enabled

.. mfcmd:: getenv [--return-value] variable [value]

 Returns value of environment *variable*. If *variable* is not defined,
 *value* is returned if set, an empty string is returned otherwise. The
 :mfcmd:`getenv` command should be preferred over the Tcl global variable
 ``env`` to query environment variables.

 When modulefile is evaluated in *display* mode, :mfcmd:`getenv` returns
 *variable* name prefixed with dollar sign (e.g., ``$variable``) unless if the
 ``--return-value`` option is set. When this option is set the value of
 environment *variable* or defined fallback value is returned in *display*
 mode.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 4.2
       Optional argument *value* added

    .. versionchanged:: 5.0
       An empty string is returned instead of ``_UNDEFINED_`` when *variable*
       is not defined and no *value* is set

    .. versionchanged:: 5.1
       Option ``--return-value`` added

    .. versionchanged:: 5.7
       Command available from module rc file context

.. mfcmd:: getvariant [--return-value] variant [value]

 Returns value of designated *variant*. If *variant* is not defined, *value*
 is returned if set, an empty string is returned otherwise. The
 :mfcmd:`getvariant` command should be preferred over the
 :mfvar:`ModuleVariant` Tcl array to query a variant value.

 When modulefile is evaluated in *display* mode, :mfcmd:`getvariant` returns
 *variant* name enclosed in curly braces (e.g., ``{variant}``) unless if the
 ``--return-value`` option is set. When this option is set the value of
 *variant* or defined fallback value is returned in *display* mode.

 .. only:: html or latex

    .. versionadded:: 4.8

    .. versionchanged:: 5.1
       Option ``--return-value`` added.


.. mfcmd:: haveDynamicMPATH

 :mfcmd:`haveDynamicMPATH` command signals that a modulefile modifies the
 :envvar:`MODULEPATH` environment variable. It is useful when the modulefile
 conditionally updates :envvar:`MODULEPATH` and is processed by Lmod tool.

 Here in the Modules tool, this command is implemented as a *no-operation*,
 since the :subcmd:`spider` sub-command evaluates the modulefile in the
 context of the current user to determine whether :envvar:`MODULEPATH` is
 updated.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: hide-modulefile modulefile

 Alias of :mfcmd:`module-hide` command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. mfcmd:: hide-version modulefile

 Alias of :mfcmd:`module-hide` command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. mfcmd:: is-avail modulefile...

 The :mfcmd:`is-avail` command returns a true value if any of the listed
 *modulefiles* exists in enabled :envvar:`MODULEPATH`. If a list contains more
 than one *modulefile*, then each member acts as a boolean OR operation. If an
 argument for :mfcmd:`is-avail` is a directory and a *modulefile* exists in
 the directory :mfcmd:`is-avail` would return a true value.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 .. only:: html or latex

    .. versionadded:: 4.1

.. mfcmd:: is-loaded [modulefile...]

 The :mfcmd:`is-loaded` command returns a true value if any of the listed
 *modulefiles* has been loaded or if any *modulefile* is loaded in case no
 argument is provided. If a list contains more than one *modulefile*, then
 each member acts as a boolean OR operation. If an argument for
 :mfcmd:`is-loaded` is a directory and any *modulefile* from the directory has
 been loaded :mfcmd:`is-loaded` would return a true value.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

.. mfcmd:: is-saved [collection...]

 The :mfcmd:`is-saved` command returns a true value if any of the listed
 *collections* exists or if any *collection* exists in case no argument is
 provided. If a list contains more than one *collection*, then each member
 acts as a boolean OR operation.

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable is appended to the passed *collection* name. In case
 no *collection* argument is provided, a true value will only be returned if
 a collection matching currently set target exists.

 .. only:: html or latex

    .. versionadded:: 4.1

.. mfcmd:: is-used [directory...]

 The :mfcmd:`is-used` command returns a true value if any of the listed
 *directories* has been enabled in :envvar:`MODULEPATH` or if any *directory*
 is enabled in case no argument is provided. If a list contains more than one
 *directory*, then each member acts as a boolean OR operation.

 .. only:: html or latex

    .. versionadded:: 4.1

.. mfcmd:: lsb-release field

 Provide certain Linux Standard Base (LSB) information. :mfcmd:`lsb-release`
 will invoke the :manpage:`lsb_release(1)` command to get each *field*
 information.

 *field* values are:

 * ``id``: string id of distributor
 * ``release``: release number of distribution
 * ``codename``: codename according to distribution release

 .. only:: html or latex

    .. versionadded:: 5.5

.. mfcmd:: module [sub-command] [sub-command-options] [sub-command-args]

 This command permits a *modulefile* to :subcmd:`load` or :subcmd:`unload`
 other *modulefiles* or to :subcmd:`use` or :subcmd:`unuse` *modulepaths*. No
 checks are made to ensure that the *modulefile* does not try to load itself.
 Often it is useful to have a single *modulefile* that performs a number of
 ``module load`` commands. For example, if every user on the system requires a
 basic set of applications loaded, then a core *modulefile* would contain the
 necessary ``module load`` commands.

 The ``--not-req`` option may be set for the ``load``, ``try-load``,
 ``load-any``, ``unload`` and ``switch`` sub-commands to inhibit the
 definition of an implicit prereq or conflict requirement onto specified
 modules.

 On ``try-load`` sub-command, *modulefiles* are considered optional prereq
 requirement. However an error is raised if they cannot be loaded unless if
 they are not found or forbidden.

 The ``load-any`` sub-command loads one *modulefile* from the specified list.
 An error is obtained if no *modulefile* from the list can be loaded. No
 operation is performed if a *modulefile* from the list is found already
 loaded.

 The ``unload`` sub-command unloads one matching *modulefile* for each module
 specification provided as argument if :mconfig:`auto_handling` or
 :mconfig:`conflict_unload` configuration options are disabled. When both
 options are enabled, ``unload`` removes all loaded modules matching each
 module specification. When both options are enabled, modules dependent of the
 unloaded modules are also unloaded. Otherwise an error is raised if module to
 unload has a dependent module loaded.

 If the :mconfig:`require_via` configuration option is enabled, the ``use``
 sub-command defines a requirement of modulefiles stored in the added
 modulepath onto current *modulefile*.

 The ``unuse`` sub-command accepts the ``--remove-on-unload``,
 ``--noop-on-unload``, ``--append-on-unload`` and ``--prepend-on-unload``
 options to control the behavior to apply when *modulefile* is unloaded. See
 :mfcmd:`remove-path` for further explanation.

 The ``load``, ``try-load``, ``load-any`` and ``switch`` sub-commands accept
 the ``--tag`` option to apply specified tags to *modulefile* once loaded.
 Option accepts a concatenation of multiple module tags separated by colon
 character. *taglist* should not contain tags inherited from *modulefile*
 state or from other modulefile commands. If module is already loaded, tags
 from *taglist* are added to the list of tags already applied to this module.

 Command line switches :option:`--auto`, :option:`--no-auto` and
 :option:`--force` are ignored when passed to a :mfcmd:`module` command set in
 a *modulefile*.

 Not all the *sub-commands* described in the :ref:`Module Sub-Commands`
 section of the :ref:`module(1)` man page are available when :mfcmd:`module`
 is used as a Modules specific Tcl command. The following table summarizes the
 different sub-commands available for each interpretation context.

 +--------------------------------+---------------------+---------------------+
 | Sub-commands available from    | Sub-commands avail\ | Sub-commands avail\ |
 | modulefile interpretation      | able from :file:`i\ | able from run-comm\ |
 |                                | nitrc` configuration| and (rc) file       |
 |                                | file and sourced    | interpretation      |
 |                                | script file         |                     |
 +================================+=====================+=====================+
 | :subcmd:`load`,                | Same sub-commands   | *None*              |
 | :subcmd:`load-any`,            | available than for  |                     |
 | :subcmd:`switch`,              | modulefile and      |                     |
 | :subcmd:`try-load`,            | :subcmd:`config`    |                     |
 | :subcmd:`unload`,              | sub-command.        |                     |
 | :subcmd:`unuse`, :subcmd:`use`.|                     |                     |
 | Also available but not recomm\ |                     |                     |
 | ended for use from regular     |                     |                     |
 | modulefile: :subcmd:`aliases`, |                     |                     |
 | :subcmd:`avail`,               |                     |                     |
 | :subcmd:`display`,             |                     |                     |
 | :subcmd:`initadd`,             |                     |                     |
 | :subcmd:`initclear`,           |                     |                     |
 | :subcmd:`initlist`,            |                     |                     |
 | :subcmd:`initprepend`,         |                     |                     |
 | :subcmd:`initrm`,              |                     |                     |
 | :subcmd:`initswitch`,          |                     |                     |
 | :subcmd:`list`,                |                     |                     |
 | :subcmd:`purge`,               |                     |                     |
 | :subcmd:`reload`,              |                     |                     |
 | :subcmd:`restore`,             |                     |                     |
 | :subcmd:`save`,                |                     |                     |
 | :subcmd:`savelist`,            |                     |                     |
 | :subcmd:`saverm`,              |                     |                     |
 | :subcmd:`saveshow`,            |                     |                     |
 | :subcmd:`search`,              |                     |                     |
 | :subcmd:`test`,                |                     |                     |
 | :subcmd:`whatis`               |                     |                     |
 +--------------------------------+---------------------+---------------------+

 .. only:: html or latex

    .. versionchanged:: 4.7
       Option ``--not-req`` added for ``load``, ``unload`` and ``switch``
       sub-commands

    .. versionchanged:: 5.0
       :subcmd:`source` sub-command is not allowed anymore and ``source`` Tcl
       command should be used instead

    .. versionchanged:: 5.1
       Options ``--remove-on-unload``, ``--noop-on-unload``,
       ``--append-on-unload`` and ``--prepend-on-unload`` added for ``unuse``
       sub-command

    .. versionchanged:: 5.1
       Option ``--tag`` added for ``load``, ``try-load``, ``load-any`` and
       ``switch`` sub-commands

    .. versionchanged:: 5.1
       Option ``--not-req`` added for ``try-load`` and ``load-any``
       sub-commands

    .. versionchanged:: 5.5
       When :mconfig:`auto_handling` and :mconfig:`conflict_unload`
       configuration options are enabled, ``unload`` sub-command removes all
       matching modules loaded and modules that depend on them

    .. versionchanged:: 5.6
       When :mconfig:`require_via` configuration option is enabled, a
       modulefile using new modulepath is considered a requirement of
       modulefiles stored in this modulepath.

.. mfcmd:: module-alias name modulefile

 Assigns the *modulefile* to the alias *name*. This command should be
 placed in one of the :file:`modulecmd.tcl` rc files in order to provide
 shorthand invocations of frequently used *modulefile* names.

 The parameter *modulefile* may be either

 * a fully qualified *modulefile* with name and version

 * a symbolic *modulefile* name

 * another *modulefile* alias

.. mfcmd:: module-forbid [options] modulefile...

 Forbid use of *modulefile*. An error is obtained when trying to evaluate a
 forbidden module. This command should be placed in one of the
 :file:`modulecmd.tcl` rc files.

 :mfcmd:`module-forbid` command accepts the following options:

 * ``--after datetime``
 * ``--before datetime``
 * ``--not-user {user...}``
 * ``--not-group {group...}``
 * ``--user {user...}``
 * ``--group {group...}``
 * ``--message {text message}``
 * ``--nearly-message {text message}``

 If ``--after`` option is set, forbidding is only effective after specified
 date time. Following the same principle, if ``--before`` option is set,
 forbidding is only effective before specified date time. Accepted date time
 format is ``YYYY-MM-DD[THH:MM]``. If no time (``HH:MM``) is specified,
 ``00:00`` is assumed. ``--after`` and ``--before`` options are not supported
 on Tcl versions prior to 8.5.

 If ``--not-user`` option is set, forbidding is not applied if the username of
 the user currently running :file:`modulecmd.tcl` is part of the list of
 username specified. Following the same approach, if ``--not-group`` option is
 set, forbidding is not applied if current user is member of one of the groups
 specified. When both options are set, forbidding is not applied if a match is
 found for ``--not-user`` or ``--not-group``.

 If ``--user`` option is set, forbidding is applied only if the username of
 the user currently running :file:`modulecmd.tcl` is part of the list of
 username specified. Following the same approach, if ``--group`` option is
 set, forbidding is applied only if current user is member of one of the
 groups specified. When both options are set, forbidding is applied if a match
 is found for ``--user`` or ``--group``. If the same user name is set on both
 ``--user`` and ``--not-user`` options, ``--user`` prevails over
 ``--not-user``. If the same group name is set on both ``--group`` and
 ``--not-group``, ``--group`` prevails over ``--not-group``.

 Error message returned when trying to evaluate a forbidden module can be
 supplemented with the *text message* set through ``--message`` option.

 If ``--after`` option is set, modules are considered *nearly forbidden*
 during a number of days defined by the :mconfig:`nearly_forbidden_days`
 :file:`modulecmd.tcl` configuration option
 (see :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS`), prior reaching the expiry
 date fixed by ``--after`` option. When a *nearly forbidden* module is
 evaluated a warning message is issued to inform module will soon be
 forbidden. This warning message can be supplemented with the *text message*
 set through ``--nearly-message`` option.

 If a :mfcmd:`module-forbid` command applies to a *modulefile* also targeted
 by a :mfcmd:`module-hide --hard<module-hide>` command, this module is
 unveiled when precisely named to return an access error.

 Forbidden modules included in the result of :subcmd:`avail` or
 :subcmd:`spider` sub-commands are reported with a ``forbidden`` tag applied
 to them. Nearly forbidden modules included in the result of :subcmd:`avail`,
 :subcmd:`list` or :subcmd:`spider` sub-commands are reported with a
 ``nearly-forbidden`` tag applied to them. See :ref:`Module tags` section in
 :ref:`module(1)`.

 The parameter *modulefile* may leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below). It
 may also be a full path file name to precisely designate one module in a
 specific modulepath.

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 5.4
       Full path file name may be used to designate *modulefile*

    .. versionchanged:: 5.4
       Options ``--user`` and ``--group`` added

.. mfcmd:: module-help string

 Defines a string which is displayed in case of the invocation of the
 :subcmd:`module help<help>` command. This command takes no action on non-help
 *modulefile* evaluation.

 Multi-word *string* should be enclosed in curly-braces or double-quotes.
 There may be more than one :mfcmd:`module-help` command call in a
 *modulefile*. In which case each command call is reported as a separate line.

 If a *modulefile* also defines a ``ModulesHelp`` procedure, the text defined
 with :mfcmd:`module-help` is printed before running this procedure on
 ``help`` evaluation mode.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: module-hide [options] modulefile...

 Hide *modulefile* to exclude it from available module search or module
 selection unless query refers to *modulefile* by its exact name. This command
 should be placed in one of the :file:`modulecmd.tcl` rc files.

 :mfcmd:`module-hide` command accepts the following options:

 * ``--soft|--hard``
 * ``--hidden-loaded``
 * ``--after datetime``
 * ``--before datetime``
 * ``--not-user {user...}``
 * ``--not-group {group...}``
 * ``--user {user...}``
 * ``--group {group...}``

 When ``--soft`` option is set, *modulefile* is also set hidden, but hiding is
 disabled when search or selection query's root name matches module's root
 name. This soft hiding mode enables to hide modulefiles from bare module
 availability listing yet keeping the ability to select such module for load
 with the regular resolution mechanism (i.e., no need to use module exact name
 to select it)

 When ``--hard`` option is set, *modulefile* is also set hidden and stays
 hidden even if search or selection query refers to *modulefile* by its exact
 name.

 When ``--hidden-loaded`` option is set, hidden state also applies to the
 *modulefile* when it is loaded. Hidden loaded modules do not appear on
 :subcmd:`list` sub-command output, unless :option:`--all` option is set.
 Their loading or unloading informational messages are not reported unless the
 :envvar:`verbosity of Modules<MODULES_VERBOSITY>` is set to a level higher
 than ``verbose``. Hidden loaded modules are detected in any cases by state
 query commands like :mfcmd:`is-loaded`.

 If ``--after`` option is set, hiding is only effective after specified date
 time. Following the same principle, if ``--before`` option is set, hiding is
 only effective before specified date time. Accepted date time format is
 ``YYYY-MM-DD[THH:MM]``. If no time (``HH:MM``) is specified, ``00:00`` is
 assumed. ``--after`` and ``--before`` options are not supported on Tcl
 versions prior to 8.5.

 If ``--not-user`` option is set, hiding is not applied if the username of the
 user currently running :file:`modulecmd.tcl` is part of the list of username
 specified. Following the same approach, if ``--not-group`` option is set,
 hiding is not applied if current user is member of one of the groups
 specified. When both options are set, hiding is not applied if a match is
 found for ``--not-user`` or ``--not-group``.

 If ``--user`` option is set, hiding is applied only if the username of the
 user currently running :file:`modulecmd.tcl` is part of the list of username
 specified. Following the same approach, if ``--group`` option is set, hiding
 is applied only if current user is member of one of the groups specified.
 When both options are set, hiding is applied if a match is found for
 ``--user`` or ``--group``. If the same user name is set on both ``--user``
 and ``--not-user`` options, ``--user`` prevails over ``--not-user``. If the
 same group name is set on both ``--group`` and ``--not-group``, ``--group``
 prevails over ``--not-group``.

 If the :option:`--all` option is set on :subcmd:`avail`, :subcmd:`aliases`,
 :subcmd:`whatis`, :subcmd:`search` or :subcmd:`spider` sub-commands, hiding
 is disabled thus hidden modulefiles are included in module search.
 Hard-hidden modules (i.e., declared hidden with ``--hard`` option) are not
 affected by :option:`--all` and stay hidden even if option is set.
 :option:`--all` option does not apply to *module selection* sub-commands like
 :subcmd:`load`. Thus in such context a hidden module should always be
 referred by its exact full name (e.g., ``foo/1.2.3`` not ``foo``) unless if
 it has been hidden in ``--soft`` mode. A hard-hidden module cannot be
 unveiled or selected in any case.

 If several :mfcmd:`module-hide` commands target the same *modulefile*, the
 strongest hiding level is retained which means if both a regular, a
 ``--soft`` hiding command match a given module, regular hiding mode is
 considered. If both a regular and a ``--hard`` hiding command match a given
 module, hard hiding mode is retained. A set ``--hidden-loaded`` option is
 retained even if the :mfcmd:`module-hide` statement on which it is declared
 is superseded by a stronger :mfcmd:`module-hide` statement with no
 ``--hidden-loaded`` option set.

 Hidden modules included in the result of :subcmd:`avail` or :subcmd:`spider`
 sub-commands are reported with a ``hidden`` tag applied to them. Hidden
 loaded modules included in the result of :subcmd:`list` sub-command are
 reported with a ``hidden-loaded`` tag applied to them. This tag is not
 reported on :subcmd:`avail` or :subcmd:`spider` sub-commands context. See
 :ref:`Module tags` section in :ref:`module(1)`.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).
 Moreover it may also be a full path file name to precisely designate one
 module in a specific modulepath.

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 4.7
       Option ``--hidden-loaded`` added.

    .. versionchanged:: 5.4
       Full path file name may be used to designate *modulefile*

    .. versionchanged:: 5.4
       Options ``--user`` and ``--group`` added

.. mfcmd:: module-info option [info-args]

 Provide information about the :file:`modulecmd.tcl` program's state. Some of
 the information is specific to the internals of :file:`modulecmd.tcl`.
 *option* is the type of information to be provided, and *info-args* are any
 arguments needed.

 **module-info alias** name

  Returns the full *modulefile* name to which the *modulefile* alias *name*
  is assigned

 **module-info command** [commandname]

  Returns the currently running :file:`modulecmd.tcl`'s command as a string
  if no *commandname* is given.

  Returns ``1`` if :file:`modulecmd.tcl`'s command is *commandname*.
  *commandname* can be: ``load``, ``unload``, ``refresh``, ``reload``,
  ``source``, ``switch``, ``display``, ``avail``, ``aliases``, ``list``,
  ``whatis``, ``search``, ``purge``, ``restore``, ``help``, ``test``,
  ``try-load``, ``load-any``, ``mod-to-sh``, ``reset``, ``stash``,
  ``stashpop`` or ``spider``.

  .. only:: html or latex

     .. versionadded:: 4.0

 **module-info loaded** modulefile

  Returns the names of currently loaded modules matching passed *modulefile*.
  The parameter *modulefile* might either be a fully qualified *modulefile*
  with name and version or just a directory which in case all loaded
  *modulefiles* from the directory will be returned. The parameter
  *modulefile* may also be a symbolic modulefile name or a modulefile alias.

  This command only returns the name and version of designated loaded module.
  The defined variants of the loaded module are not included in the returned
  string.

  .. only:: html or latex

     .. versionadded:: 4.1

 **module-info mode** [modetype]

  Returns the current :file:`modulecmd.tcl`'s mode as a string if no
  *modetype* is given.

  Returns ``1`` if :file:`modulecmd.tcl`'s mode is *modetype*. *modetype* can
  be: ``load``, ``unload``, ``remove`` (alias of ``unload``), ``switch``,
  ``refresh``, ``nonpersist`` (alias of ``refresh``), ``display``, ``help``,
  ``test``, ``whatis`` or ``scan``.

 **module-info name**

  Return the name of the *modulefile*. This is not the full pathname for
  *modulefile*. See the `Modules Variables`_ section for information on the
  full pathname.

  This command only returns the name and version of currently evaluating
  *modulefile*. The defined variants are not included in the returned string.
  See :mfcmd:`getvariant` command or :mfvar:`ModuleVariant` array variable to
  get defined variant values for currently evaluating *modulefile*.

 **module-info shell** [shellname]

  Return the current shell under which :file:`modulecmd.tcl` was invoked if
  no *shellname* is given. The current shell is the first parameter of
  :file:`modulecmd.tcl`, which is normally hidden by the :command:`module`
  alias.

  If a *shellname* is given, returns ``1`` if :file:`modulecmd.tcl`'s current
  shell is *shellname*, returns ``0`` otherwise. *shellname* can be: ``sh``,
  ``bash``, ``ksh``, ``zsh``, ``csh``, ``tcsh``, ``fish``, ``cmd``, ``pwsh``,
  ``tcl``, ``perl``, ``python``, ``ruby``, ``lisp``, ``cmake``, ``r``.

 **module-info shelltype** [shelltypename]

  Return the family of the shell under which *modulefile* was invoked if no
  *shelltypename* is given. As of :mfcmd:`module-info shell<module-info>` this
  depends on the first parameter of :file:`modulecmd.tcl`. The output reflects
  a shell type determining the shell syntax of the commands produced by
  :file:`modulecmd.tcl`.

  If a *shelltypename* is given, returns ``1`` if :file:`modulecmd.tcl`'s
  current shell type is *shelltypename*, returns ``0`` otherwise.
  *shelltypename* can be: ``sh``, ``csh``, ``fish``, ``cmd``, ``pwsh``,
  ``tcl``, ``perl``, ``python``, ``ruby``, ``lisp``, ``cmake``, ``r``.

 **module-info specified**

  Return the module designation (name, version and variants) specified that
  led to current *modulefile* evaluation.

 **module-info symbols** modulefile

  Returns a list of all symbolic versions assigned to the passed
  *modulefile*. The parameter *modulefile* might either be a full qualified
  *modulefile* with name and version, another symbolic *modulefile* name
  or a *modulefile* alias.

 **module-info tags** [tag]

  Returns all tags assigned to currently evaluated *modulefile* as a list of
  strings if no *tag* name is given (see :ref:`Module tags` section in
  :ref:`module(1)`)

  When tags are assigned to specific module variants, they are returned only
  if this variant is the one currently evaluated.

  Returns ``1`` if one of the tags applying to currently evaluated
  *modulefile* is *tag*. Returns ``0`` otherwise.

  .. only:: html or latex

     .. versionadded:: 4.7

 **module-info type**

  Returns either ``C`` or ``Tcl`` to indicate which :command:`module` command
  is being executed, either the C version or the Tcl-only version, to allow
  the *modulefile* writer to handle any differences between the two.

 **module-info usergroups** [name]

  Returns all the groups the user currently running :file:`modulecmd.tcl` is
  member of as a list of strings if no *name* is given.

  Returns ``1`` if one of the group current user running :file:`modulecmd.tcl`
  is member of is *name*. Returns ``0`` otherwise.

  If the Modules Tcl extension library is disabled, the :manpage:`id(1)`
  command is invoked to fetch groups of current user.

  .. only:: html or latex

     .. versionadded:: 4.6

 **module-info username** [name]

  Returns the username of the user currently running :file:`modulecmd.tcl` as
  a string if no *name* is given.

  Returns ``1`` if username of current user running :file:`modulecmd.tcl` is
  *name*. Returns ``0`` otherwise.

  If the Modules Tcl extension library is disabled, the :manpage:`id(1)`
  command is invoked to fetch username of current user.

  .. only:: html or latex

     .. versionadded:: 4.6

 **module-info version** modulefile

  Returns the physical module name and version of the passed symbolic
  version *modulefile*. The parameter *modulefile* might either be a full
  qualified *modulefile* with name and version, another symbolic *modulefile*
  name or a *modulefile* alias.

.. mfcmd:: module-tag [options] tag modulefile...

 Associate *tag* to designated *modulefile*. This tag information will be
 reported along *modulefile* on :subcmd:`avail`, :subcmd:`list` and
 :subcmd:`spider` sub-commands (see :ref:`Module tags` section in
 :ref:`module(1)`). Tag information can be queried during *modulefile*
 evaluation with the :mfcmd:`module-info tags<module-info>` modulefile
 command. :mfcmd:`module-tag` commands should be placed in one of the
 :file:`modulecmd.tcl` rc files.

 :mfcmd:`module-tag` command accepts the following options:

 * ``--not-user {user...}``
 * ``--not-group {group...}``
 * ``--user {user...}``
 * ``--group {group...}``

 If ``--not-user`` option is set, the tag is not applied if the username of
 the user currently running :file:`modulecmd.tcl` is part of the list of
 username specified. Following the same approach, if ``--not-group`` option is
 set, the tag is not applied if current user is member of one of the groups
 specified. When both options are set, the tag is not applied if a match is
 found for ``--not-user`` or ``--not-group``.

 If ``--user`` option is set, the tag is applied only if the username of the
 user currently running :file:`modulecmd.tcl` is part of the list of username
 specified. Following the same approach, if ``--group`` option is set, the tag
 is applied only if current user is member of one of the groups specified.
 When both options are set, the tag is applied if a match is found for
 ``--user`` or ``--group``. If the same user name is set on both ``--user``
 and ``--not-user`` options, ``--user`` prevails over ``--not-user``. If the
 same group name is set on both ``--group`` and ``--not-group``, ``--group``
 prevails over ``--not-group``.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).
 Moreover it may also be a full path file name to precisely designate one
 module in a specific modulepath.

 Tags inherited from other modulefile commands or module states cannot be set
 with :mfcmd:`module-tag`. Otherwise an error is returned. Those special tags
 are: ``auto-loaded``, ``forbidden``, ``hidden``, ``hidden-loaded``,
 ``loaded``, ``nearly-forbidden`` and ``warning``.

 When *tag* equals ``sticky`` or ``super-sticky``, designated *modulefile* is
 defined :ref:`Sticky modules`.

 When *tag* equals ``keep-loaded``, designated *modulefile* is not
 automatically unloaded when it has been auto-loaded and its dependent modules
 are getting unloaded.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.1
       Tag ``keep-loaded`` added

    .. versionchanged:: 5.4
       Full path file name may be used to designate *modulefile*

    .. versionchanged:: 5.4
       Options ``--user`` and ``--group`` added

.. mfcmd:: module-version modulefile version-name...

 Assigns the symbolic *version-name* to the *modulefile*. This command
 should be placed in one of the :file:`modulecmd.tcl` rc files in order to
 provide shorthand invocations of frequently used *modulefile* names.

 The special *version-name* default specifies the default version to be
 used for module commands, if no specific version is given. This replaces
 the definitions made in the :file:`.version` file in former
 :file:`modulecmd.tcl` releases.

 The parameter *modulefile* may be either

 * a fully or partially qualified *modulefile* with name / version. If
   name is ``.`` (dot) then the current directory name is assumed to be the
   module name. (Use this for deep *modulefile* directories.)

 * a symbolic *modulefile* name

 * another *modulefile* alias

.. mfcmd:: module-virtual name modulefile

 Assigns the *modulefile* to the virtual module *name*. This command should be
 placed in rc files in order to define virtual modules.

 A virtual module stands for a module *name* associated to a *modulefile*. The
 modulefile is the script interpreted when loading or unloading the virtual
 module which appears or can be found with its virtual name.

 The parameter *modulefile* corresponds to the relative or absolute file
 location of a *modulefile*.

 .. only:: html or latex

    .. versionadded:: 4.1

.. mfcmd:: module-warn [options] --message {text message} modulefile...

 Print warning message when evaluating *modulefile*. This command could be
 placed in one of the :file:`modulecmd.tcl` rc files or within *modulefiles*.
 Warning is emitted when *modulefile* is evaluated in ``load``, ``display``,
 ``test``, ``help``.

 :mfcmd:`module-warn` command accepts the following options:

 * ``--after datetime``
 * ``--before datetime``
 * ``--not-user {user...}``
 * ``--not-group {group...}``
 * ``--user {user...}``
 * ``--group {group...}``

 If ``--after`` option is set, warning is only effective after specified date
 time. Following the same principle, if ``--before`` option is set, warning is
 only effective before specified date time. Accepted date time format is
 ``YYYY-MM-DD[THH:MM]``. If no time (``HH:MM``) is specified, ``00:00`` is
 assumed. ``--after`` and ``--before`` options are not supported on Tcl
 versions prior to 8.5.

 If ``--not-user`` option is set, warning is not applied if the username of
 the user currently running :file:`modulecmd.tcl` is part of the list of
 username specified. Following the same approach, if ``--not-group`` option is
 set, warning is not applied if current user is member of one of the groups
 specified. When both options are set, warning is not applied if a match is
 found for ``--not-user`` or ``--not-group``.

 If ``--user`` option is set, warning is applied only if the username of the
 user currently running :file:`modulecmd.tcl` is part of the list of username
 specified. Following the same approach, if ``--group`` option is set, warning
 is applied only if current user is member of one of the groups specified.
 When both options are set, warning is applied if a match is found for
 ``--user`` or ``--group``. If the same user name is set on both ``--user``
 and ``--not-user`` options, ``--user`` prevails over ``--not-user``. If the
 same group name is set on both ``--group`` and ``--not-group``, ``--group``
 prevails over ``--not-group``.

 Modules in warning included in the result of :subcmd:`avail`, :subcmd:`list`
 or :subcmd:`spider` sub-commands are reported with a ``warning`` tag applied
 to them. See :ref:`Module tags` section in :ref:`module(1)`.

 The parameter *modulefile* may leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below). It
 may also be a full path file name to precisely designate one module in a
 specific modulepath.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: module-whatis string

 Defines a string which is displayed in case of the invocation of the
 :subcmd:`module whatis<whatis>` command. There may be more than one
 :mfcmd:`module-whatis` line in a *modulefile*. This command takes no actions
 in case of :subcmd:`load`, :subcmd:`display`, etc. invocations of
 :file:`modulecmd.tcl`.

 The *string* parameter has to be enclosed in double-quotes if there's more
 than one word specified. Words are defined to be separated by whitespace
 characters (space, tab, cr).

.. mfcmd:: modulepath-label directory label

 Assigns *label* string to modulepath *directory*. This *label* is used on
 :subcmd:`avail`, :subcmd:`whatis`, :subcmd:`search` and :subcmd:`spider`
 output to refer to the modulepath.

 The parameter *directory* corresponds to a fully or partially qualified
 modulepath. If *directory* is ``.`` (dot) then the current directory of the
 modulerc file defining this command is assumed.

 .. only:: html or latex

    .. versionadded:: 5.4

    .. versionchanged:: 5.6
       Label also applied on :subcmd:`whatis` and :subcmd:`search` output

.. mfcmd:: prepend-path [-d C|--delim C|--delim=C] [--duplicates] variable value...

 Append or prepend *value* to environment *variable*. The
 *variable* is a colon, or *delimiter*, separated list such as
 ``PATH=directory:directory:directory``. The default delimiter is a colon
 ``:``, but an arbitrary one can be given by the ``--delim`` option. For
 example a space can be used instead (which will need to be handled in
 the Tcl specially by enclosing it in ``" "`` or ``{ }``). A space, however,
 can not be specified by the ``--delim=C`` form.

 A reference counter environment variable is also set to know the number of
 times *value* has been added to environment *variable* when it is added more
 than one time. This reference counter environment variable is named by
 prefixing *variable* by :envvar:`__MODULES_SHARE_<__MODULES_SHARE_\<VAR\>>`.

 When *value* is already defined in environment *variable*, it is not added
 again or moved at the end or at the beginning of *variable*. Exception is
 made when the ``--duplicates`` option is set in which case *value* is added
 again to *variable*.

 If the *variable* is not set, it is created. When a *modulefile* is
 unloaded, :mfcmd:`append-path` and :mfcmd:`prepend-path` become
 :mfcmd:`remove-path`.

 If *value* corresponds to the concatenation of multiple elements separated by
 colon, or *delimiter*, character, each element is treated separately.

 The provided *value* is used as-is. If any path resolution is required, it
 must be performed within the *modulefile* itself. Use caution when including
 characters with special meanings in the shell context (such as ``~``), as the
 shell may expand these paths automatically. This can prevent the
 corresponding entries from being properly removed when the *modulefile* is
 unloaded.

 If the *variable* is :envvar:`MODULEPATH` and :mconfig:`require_via`
 configuration option is activated, the *modulefile* is considered a
 dependency by the loaded modulefiles stored in the added modulepaths.

 If a link is defined for *variable* through the :mconfig:`linked_envvars`
 configuration option, the same :mfcmd:`prepend-path` command is applied to
 all associated environment variables.

 If an initial value is defined for the *variable* through the
 :mconfig:`init_envvars` configuration option, that value is assigned before
 the modification is applied when the *variable* is not already set.

 .. only:: html or latex

    .. versionchanged:: 4.1
       Option ``--duplicates`` added

    .. versionchanged:: 5.4
       *value* equal to *delimiter* character allowed

    .. versionchanged:: 5.6
       When :mconfig:`require_via` configuration option is enabled, a
       modulefile adding path to :envvar:`MODULEPATH` environment variable is
       considered a requirement of modulefiles stored in this path.

.. mfcmd:: prereq [options] modulefile...

 :mfcmd:`prereq` controls whether or not the *modulefile* will be loaded. The
 :mfcmd:`prereq` command lists *modulefiles* which must have been previously
 loaded before the current *modulefile* will be loaded. If a list contains
 more than one *modulefile*, then each member of the list acts as a Boolean OR
 operation. Multiple :mfcmd:`prereq` commands may be used to create a Boolean
 AND operation. If one of the requirements have not been satisfied, an error
 is reported and the current *modulefile* makes no changes to the user's
 environment.

 If an argument for :mfcmd:`prereq` is a directory and any *modulefile* from
 the directory has been loaded, then the prerequisite is met. For example,
 specifying X11 as a :mfcmd:`prereq` means that any version of X11, X11/R4 or
 X11/R5, must be loaded before proceeding.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 :mfcmd:`prereq` command accepts the following options:

 * ``--modulepath modulepathlist``
 * ``--optional``
 * ``--tag taglist``

 When the ``--optional`` option is set, the whole list of specified
 *modulefiles* is declared as an optional requirement list. Evaluation is not
 stopped if no *modulefile* from the list is loaded.

 If the :mconfig:`auto_handling` configuration option is enabled
 :mfcmd:`prereq` will attempt to load specified modulefile if not found loaded
 yet (see :ref:`Automated module handling mechanisms<MODULES_AUTO_HANDLING>`
 in :ref:`module(1)`).

 The ``--tag`` option accepts a list of module tags to apply to *modulefile*
 once loaded. *taglist* corresponds to the concatenation of multiple tags
 separated by colon character. *taglist* should not contain tags inherited
 from *modulefile* state or from other modulefile commands. If module is
 already loaded, tags from *taglist* are added to the list of tags already
 applied to this module.

 The ``--modulepath`` option accepts a list of modulepath. *modulepathlist*
 corresponds to the concatenation of multiple modulepaths separated by colon
 character. When this option is set, required *modulefile* should be located
 within one of the listed modulepaths. A path in this list may correspond to
 the first path elements of an actual modulepath (e.g., ``/path/to`` will
 match modulefiles located into the ``/path/to/modulefiles`` modulepath
 directory).

 If an attempt to load *modulefile* is performed and ``--modulepath`` option
 is set, *modulefile* will be searched in the enabled modulepaths whose start
 match one of the specified paths and in the specified paths not matching any
 enabled modulepaths. For instance if this option is set to
 ``/path/to:/another/path`` and ``/path/to/modulefiles`` is currently the sole
 enabled modulepath, *modulefile* will be searched into
 ``/path/to/modulefiles`` and ``/another/path`` directories.

 .. only:: html or latex

    .. versionchanged:: 4.2
       An attempt to load modulefile is made if :mconfig:`auto_handling`
       configuration option is enabled

    .. versionchanged:: 5.1
       Option ``--tag`` added

    .. versionchanged:: 5.2
       Option ``--optional`` added

    .. versionchanged:: 5.5
       Option ``--modulepath`` added

.. mfcmd:: prereq-all [options] modulefile...

 Declare *modulefile* as a requirement of currently loading module. This
 command acts as an alias of :mfcmd:`prereq` command. If more than one
 *modulefile* are specified, then this list acts as a Boolean AND operation,
 which means all specified *modulefiles* are required.

 :mfcmd:`prereq-all` command accepts the following options:

 * ``--modulepath modulepathlist``
 * ``--optional``
 * ``--tag taglist``

 When the ``--optional`` option is set, each specified *modulefile* is
 declared as an optional requirement. A *modulefile* that cannot be loaded,
 will not stop the evaluation.

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.2
       Option ``--optional`` added

    .. versionchanged:: 5.5
       Option ``--modulepath`` added

.. mfcmd:: prereq-any [options] modulefile...

 Alias of :mfcmd:`prereq` command.

 .. only:: html or latex

    .. versionadded:: 5.1

    .. versionchanged:: 5.2
       Option ``--optional`` added

    .. versionchanged:: 5.5
       Option ``--modulepath`` added

.. mfcmd:: provide modulefile...

 Define each specified *modulefile* as a module alias of currently evaluating
 module. :mfcmd:`provide` command helps to declare the additional elements
 included in a modulefile.

 The :mfcmd:`provide` command should be paired with a :mfcmd:`conflict`
 command if the specified alias should be uniquely provided in the currently
 loaded environment.

 Note: A module alias defined using :mfcmd:`provide` command will not be
 recognized during module resolution. It is recommended to use the
 :mfcmd:`module-alias` command to define an alias that points to the default
 resolution target.

 .. only:: html or latex

    .. versionadded:: 5.6

.. mfcmd:: pushenv variable value

 Set environment *variable* to *value* and save previous value of *variable*
 to restore it when *modulefile* is unloaded. Like for :mfcmd:`setenv`
 modulefile command, changes made to *variable* with :mfcmd:`pushenv` are
 applied to *variable* in Tcl's ``env`` array to update environment *variable*
 value in current evaluation context.

 When *modulefile* is unloaded, the *value* saved from the :mfcmd:`pushenv`
 command of this modulefile is removed from saved value stack list. *variable*
 is then set to the remaining *value* on top of the stack or it is unset if
 stack becomes empty.

 Saved value stack list for *variable* is stored in an environment variable
 which is named by prefixing *variable* by :envvar:`__MODULES_PUSHENV_\
 <__MODULES_PUSHENV_\<VAR\>>`.

 If a link is defined for *variable* through the :mconfig:`linked_envvars`
 configuration option, the same :mfcmd:`pushenv` command is applied to all
 associated environment variables.

 .. only:: html or latex

    .. versionadded:: 5.1

.. mfcmd:: puts [-nonewline] [channelId] string

 Writes the characters given by *string* to the channel given by *channelId*.
 This command is part of the regular set of Tcl commands but it is enhanced
 with specific features in the modulefile evaluation context. See the
 :manpage:`puts(n)` Tcl man page for the basic description of this command.
 Specific features for modulefile evaluation context are described in the
 remainder of this section.

 Content written to the ``stderr`` channel is rendered as output message
 produced by modulefile. Content written to the ``stdout`` channel is rendered
 as shell command evaluated in the user current shell environment. Content
 sent to ``stdout`` is spooled to be rendered after the environment changes
 made by modulefile.

 When *channelId* equals ``prestdout``, content is rendered as shell command
 evaluated in current shell environment. This content is spooled and rendered
 prior any other environment changes.

 When *channelId* equals ``log``, content is sent to the log system through
 the defined :mconfig:`logger` command.

 .. only:: html or latex

    .. versionchanged:: 4.1
       Content sent to ``stdout`` is spooled to apply it after the rendering
       of the environment changes made by modulefile

    .. versionchanged:: 5.1
       Channel ``prestdout`` added to render content prior any other
       environment changes

    .. versionchanged:: 5.5
       Channel ``log`` added to send information to log system

.. mfcmd:: remove-path [options] variable value... [--append-on-unload|--prepend-on-unload value...]

 Remove *value* from the colon, or *delimiter*, separated list in
 *variable*.

 :mfcmd:`remove-path` command accepts the following options:

 * ``-d C|--delim C|--delim=C``
 * ``--index``
 * ``--glob``
 * ``--remove-on-unload|--noop-on-unload|--append-on-unload|--prepend-on-unload``

 See :mfcmd:`prepend-path` or :mfcmd:`append-path` for further
 explanation of using an arbitrary delimiter. Every string between colons, or
 delimiters, in *variable* is compared to *value*. If the two match, *value*
 is removed from *variable* if its reference counter is equal to 1 or unknown.

 When ``--index`` option is set, *value* refers to an index in *variable*
 list. The string element pointed by this index is set for removal.

 When ``--glob`` option is set, *value* refers to a glob-style pattern which
 is matched against values in *variable* to find those to remove. ``*``
 character in *value* matches any sequence of characters, including a null
 string. ``?`` character in *value* matches any single character. See
 :manpage:`string(n)` Tcl command for the full list of special characters.

 When *modulefile* is unloaded, no operation is performed by default or if the
 ``--noop-on-unload`` option is set. If the ``--remove-on-unload`` option is
 set, *value* is removed. If the ``--append-on-unload`` option is set, append
 back *value* removed at load time or specific *value* if any set. If the
 ``--prepend-on-unload`` option is set, prepend back *value* removed at load
 time or specific *value* if any set. These options cannot be set if
 ``--index`` option is also set. The ``--append-on-unload`` and
 ``--prepend-on-unload`` options cannot be set if ``--glob`` option is also
 set.

 Reference counter of *value* in *variable* denotes the number of times
 *value* has been added to *variable*. This information is stored in
 environment :envvar:`__MODULES_SHARE_variable<__MODULES_SHARE_\<VAR\>>`. When
 attempting to remove *value* from *variable*, relative reference counter is
 checked and *value* is removed only if counter is equal to 1 or not defined.
 Otherwise *value* is kept in *variable* and reference counter is decreased by
 1. If counter equals 1 after being decreased, *value* and its counter are
 removed from reference counter variable.

 If *value* corresponds to the concatenation of multiple elements separated by
 colon, or *delimiter*, character, each element is treated separately.

 An error is raised if *value* equals *delimiter* character.

 If a link is defined for *variable* through the :mconfig:`linked_envvars`
 configuration option, the same :mfcmd:`remove-path` command is applied to
 all associated environment variables.

 If an initial value is defined for *variable* through the
 :mconfig:`init_envvars` configuration option, variable is unset when, after
 the modification, its value matches the configured initial value and no
 explicit reference counter is defined.

 .. only:: html or latex

    .. versionchanged:: 4.1
       Option ``--index`` added

    .. versionchanged:: 5.1
       Options ``--remove-on-unload``, ``--noop-on-unload``,
       ``--append-on-unload`` and ``--prepend-on-unload`` added

    .. versionchanged:: 5.4
       Option ``--glob`` added

.. mfcmd:: report string

 Output *string* as a message during *modulefile* evaluation.

 .. only:: html or latex

    .. versionadded:: 4.0

.. mfcmd:: reportError string

 Output *string* as an error message during *modulefile* evaluation and raise
 error count. :mfcmd:`reportError` does not abort modulefile evaluation. Use
 the :manpage:`error(n)` Tcl command to abort evaluation in addition to emit
 an error message.

 .. only:: html or latex

    .. versionadded:: 4.0

.. mfcmd:: reportWarning string

 Output *string* as a warning message during *modulefile* evaluation.

 .. only:: html or latex

    .. versionadded:: 4.0

.. mfcmd:: require-fullname

 Abort *load* evaluation of *modulefile* if name specified to designate it is
 not the fully qualified one. Module alias or a symbolic version names are
 considered fully qualified names, exception made for the *default* symbol.

 .. only:: html or latex

    .. versionadded:: 5.1

.. mfcmd:: set-alias alias-name alias-string

 Sets an alias with the name *alias-name* in the user's environment to the
 string *alias-string*. For some shells, aliases are not possible and the
 command has no effect (see `Shell support`_ section). When a *modulefile* is
 unloaded, :mfcmd:`set-alias` becomes :mfcmd:`unset-alias`.

.. mfcmd:: set-function function-name function-string

 Creates a function with the name *function-name* in the user's environment
 with the function body *function-string*. For some shells, functions are not
 possible and the command has no effect (see `Shell support`_ section). When a
 *modulefile* is unloaded, :mfcmd:`set-function` becomes
 :mfcmd:`unset-function`.

 .. only:: html or latex

    .. versionadded:: 4.2

.. mfcmd:: setenv [--set-if-undef] variable value

 Set environment *variable* to *value*. The :mfcmd:`setenv` command will also
 change the process' environment. A reference using Tcl's env associative
 array will reference changes made with the :mfcmd:`setenv` command. Changes
 made using Tcl's ``env`` associative array will **NOT** change the user's
 environment *variable* like the :mfcmd:`setenv` command. An environment
 change made this way will only affect the module parsing process. The
 :mfcmd:`setenv` command is also useful for changing the environment prior to
 the ``exec`` or :mfcmd:`system` command. When a *modulefile* is unloaded,
 :mfcmd:`setenv` becomes :mfcmd:`unsetenv`. If the environment *variable* had
 been defined it will be overwritten while loading the *modulefile*. A
 subsequent :subcmd:`unload` will unset the environment *variable* - the
 previous value cannot be restored! (Unless you handle it explicitly or if you
 use the :mfcmd:`pushenv` modulefile command instead of :mfcmd:`setenv`)

 When the ``--set-if-undef`` option is set, environment variable is defined
 when *modulefile* is loaded only if not yet defined.

 Any newline character in *value* is chopped if using *csh* or *tcsh* shells.

 If a link is defined for *variable* through the :mconfig:`linked_envvars`
 configuration option, the same :mfcmd:`setenv` command is applied to all
 associated environment variables.

 .. only:: html or latex

    .. versionchanged:: 5.1
       Option ``--set-if-undef`` added

    .. versionchanged:: 5.6
       Newline character in value supported except for *csh* and *tcsh* shells

.. mfcmd:: source-sh [--ignore eltlist] shell script [arg...]

 Evaluate with *shell* the designated *script* with defined *arguments* to
 find out the environment changes it does. Those changes obtained by comparing
 environment prior and after *script* evaluation are then translated into
 corresponding *modulefile* commands, which are then applied during modulefile
 evaluation as if they were directly written in it.

 When modulefile is unloaded, environment changes done are reserved by
 evaluating in the ``unload`` context the resulting modulefile commands, which
 were recorded in the :envvar:`__MODULES_LMSOURCESH` environment variable at
 ``load`` time.

 Changes on environment variables, shell aliases, shell functions, shell
 completions and current working directory are tracked.

 Changes made on environment variable intended for Modules private use (e.g.,
 :envvar:`LOADEDMODULES`, :envvar:`_LMFILES_`, ``__MODULES_*``) are ignored.

 *Shell* could be specified as a command name or a fully qualified pathname.
 The following shells are supported: sh, dash, csh, tcsh, bash, ksh, ksh93,
 zsh and fish.

 *Shell* could also be set to ``bash-eval``. In this mode, bash shell *script*
 is not sourced but the output resulting from its execution is evaluated to
 determine the environment changes it does.

 The ``--ignore`` option accepts a list of shell elements whose changes made
 by *script* should be ignored. *eltlist* corresponds to the concatenation of
 multiple shell element separated by colon character. Accepted shell elements
 are: ``envvar``, ``alias``, ``function``, ``chdir`` and ``complete``.

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 5.1
       Changes on Modules private environment variable are ignored

    .. versionchanged:: 5.1
       Support for tracking shell completion changes on bash, tcsh and fish
       shells added

    .. versionchanged:: 5.4
       Support for ``bash-eval`` shell mode added

    .. versionchanged:: 5.4
       Option ``--ignore`` added

.. mfcmd:: system string

 Run *string* command through shell. On Unix, command is passed to the
 ``/bin/sh`` shell whereas on Windows it is passed to ``cmd.exe``.
 :file:`modulecmd.tcl` redirects stdout to stderr since stdout would be parsed
 by the evaluating shell. The exit status of the executed command is returned.

.. mfcmd:: uname field

 Provide lookup of system information. Most *field* information are retrieved
 from the ``tcl_platform`` array (see the :manpage:`tclvars(n)` man page).
 Uname will return the string ``unknown`` if information is unavailable for
 the *field*.

 :mfcmd:`uname` will invoke the :manpage:`uname(1)` command in order to get
 the operating system version and :manpage:`domainname(1)` to figure out the
 name of the domain.

 *field* values are:

 * ``sysname``: the operating system name

 * ``nodename``: the hostname

 * ``domain``: the name of the domain

 * ``release``: the operating system release

 * ``version``: the operating system version

 * ``machine``: a standard name that identifies the system's hardware

.. mfcmd:: uncomplete name

 Unsets completion for command *name* in the user's environment. When a
 *modulefile* is unloaded, no operation is performed.

 The following shells are supported: bash, tcsh and fish.

 .. only:: html or latex

    .. versionadded:: 5.1

.. mfcmd:: unset-alias alias-name

 Unsets an alias with the name *alias-name* in the user's environment.

.. mfcmd:: unset-function function-name

 Removes a function with the name *function-name* from the user's environment.

 .. only:: html or latex

    .. versionadded:: 4.2

.. mfcmd:: unsetenv [options] variable [value]

 Unsets environment *variable*. When a *modulefile* is unloaded, no operation
 is performed unless if an optional *value* is defined, in which case
 *variable* is set to *value*. The :mfcmd:`unsetenv` command changes the
 process' environment like :mfcmd:`setenv`.

 If the ``--noop-on-unload`` option is set, no operation is performed when
 *modulefile* is unloaded. If the ``--unset-on-unload`` option is set,
 environment *variable* is also unset when *modulefile* is unloaded. These
 behaviors are applied even if an optional *value* is defined.

 If a link is defined for *variable* through the :mconfig:`linked_envvars`
 configuration option, the same :mfcmd:`unsetenv` command is applied to all
 associated environment variables.

 .. only:: html or latex

    .. versionchanged:: 5.0
       *variable* is not unset when unloading *modulefile* and no optional
       value is provided

    .. versionchanged:: 5.1
       Options ``--noop-on-unload`` and ``--unset-on-unload`` added

.. mfcmd:: variant [--boolean] [--default value] name [value...]

 Declare :ref:`module variant<Module variants>` *name* with list of accepted
 *value* and instantiate it in the :mfvar:`ModuleVariant` array variable.

 Variant's value is selected through the module designation that leads to the
 modulefile evaluation. See `Advanced module version specifiers`_ section to
 learn how variants could be specified.

 Selected variant value is transmitted to the evaluating modulefile. A value
 must be specified for variant *name* and it must corresponds to a value in
 the accepted value list if such list is defined. Otherwise an error is
 raised. An exception is made if modulefile is evaluated in ``display`` mode:
 no error is raised if no value is specified for a given variant and variant
 is not instantiated in the :mfvar:`ModuleVariant` array variable. When no
 list of accepted value is defined, variant could be set to any value.

 When the ``--default`` option is set, variant *name* is set to the *value*
 associated with this option in case no value is specified for variant in
 module designation.

 If the ``--boolean`` option is set, variant *name* is defined as a Boolean
 variant. No list of accepted value should be defined in this case. All values
 recognized as Boolean value in Tcl are accepted (i.e., ``1``, ``true``,
 ``t``, ``yes``, ``y``, ``on``, ``0``, ``false``, ``f``, ``no``, ``n`` or
 ``off``). Boolean variants are instantiated in :mfvar:`ModuleVariant` using
 Tcl canonical form of Boolean value (i.e., ``0`` or ``1``).

 A variant which is not defined as a Boolean variant cannot define Boolean
 values in its accepted value list, exception made for the ``0`` and ``1``
 integers. An error is raised otherwise.

 Variant *name* should only be composed of characters part of the
 ``A-Za-z0-9_-`` range. Also, a variant name cannot start with ``-`` (minus)
 character and the overall name cannot just be a number. An error is raised
 if specified *name* does not match these rules.

 A variant cannot be named ``version``. An error is raised otherwise.

 .. only:: html or latex

    .. versionadded:: 4.8

    .. versionchanged:: 5.0
       No error raised if a defined variant is not specified when modulefile
       is evaluated in ``display`` mode

    .. versionchanged:: 5.1
       Accepted value list is made optional

    .. versionchanged:: 5.5
       Stricter variant name naming rule adopted

.. mfcmd:: versioncmp version1 version2

 Compare version string *version1* against version string *version2*. Returns
 ``-1``, ``0`` or ``1`` respectively if *version1* is less than, equal to or
 greater than *version2*.

 .. only:: html or latex

    .. versionadded:: 4.7

.. mfcmd:: x-resource [resource-string|filename]

 Merge resources into the X11 resource database. The resources are used to
 control look and behavior of X11 applications. The command will attempt
 to read resources from *filename*. If the argument isn't a valid file
 name, then string will be interpreted as a resource. Either *filename*
 or *resource-string* is then passed down to be :manpage:`xrdb(1)` command.

 *modulefiles* that use this command, should in most cases contain one or
 more :mfcmd:`x-resource` lines, each defining one X11 resource. The
 :envvar:`DISPLAY` environment variable should be properly set and the X11
 server should be accessible. If :mfcmd:`x-resource` can't manipulate the X11
 resource database, the *modulefile* will exit with an error message.

 Examples:

 ``x-resource /u2/staff/leif/.xres/Ileaf``

  The content of the *Ileaf* file is merged into the X11 resource database.

 ``x-resource [glob ~/.xres/ileaf]``

  The Tcl glob function is used to have the *modulefile* read different
  resource files for different users.

 ``x-resource {Ileaf.popup.saveUnder: True}``

  Merge the Ileaf resource into the X11 resource database.

.. _Modulefile and run-command interp diff:

Modulefiles and run-command (rc) files are differently interpreted. A limited
number of the Modules specific Tcl commands are available for rc files
interpretation since such files are intended to set parameters for modulefiles
(like defining alias, hiding, tagging, etc) and not to change user
environment. The following table summarizes the different commands available
for each interpretation context.

+---------------------------+-----------------------------------------------------+
| Commands available from   | Commands available from run-command (rc) file       |
| modulefile interpretation | interpretation                                      |
+===========================+=====================================================+
| All the Modules specific  | :mfcmd:`getenv`, :mfcmd:`hide-modulefile`,          |
| and standard Tcl commands | :mfcmd:`hide-version`, :mfcmd:`is-loaded`,          |
|                           | :mfcmd:`is-used`, :mfcmd:`lsb-release`,             |
|                           | :mfcmd:`module-alias`, :mfcmd:`module-forbid`,      |
|                           | :mfcmd:`module-hide`, :mfcmd:`module-info`,         |
|                           | :mfcmd:`module-tag`, :mfcmd:`module-version`,       |
|                           | :mfcmd:`module-virtual`, :mfcmd:`module-warn`,      |
|                           | :mfcmd:`modulepath-label`, :mfcmd:`system`,         |
|                           | :mfcmd:`uname`, :mfcmd:`versioncmp` and standard    |
|                           | Tcl commands                                        |
+---------------------------+-----------------------------------------------------+

.. note:: Global and user run-command files are interpreted like modulefiles
   and benefit from all Modules specific Tcl commands. However it not advised
   to perform environment changes from such files.


Modules Variables
-----------------

.. mfvar:: ModulesCurrentModulefile

 The :mfvar:`ModulesCurrentModulefile` variable contains the full pathname of
 the *modulefile* being interpreted.

.. mfvar:: ModulesVersion

 The :mfvar:`ModulesVersion` variable can be set in :file:`.version` file to
 designate the name of the *modulefile* version which should be considered
 as default in current directory (see `Locating Modulefiles`_ section below).

.. mfvar:: ModuleTool

 The :mfvar:`ModuleTool` variable contains the name of the *module*
 implementation currently in use. The value of this variable is set to
 ``Modules`` for this implementation.

 .. only:: html or latex

    .. versionadded:: 4.7

.. mfvar:: ModuleToolVersion

 The :mfvar:`ModuleToolVersion` variable contains the version of the *module*
 implementation currently in use. The value of this variable is set to
 |code version| for this version of Modules.

 .. only:: html or latex

    .. versionadded:: 4.7

.. mfvar:: ModuleVariant

 The :mfvar:`ModuleVariant` array variable contains an element entry for each
 defined variant associated to the value of this variant (e.g., the
 ``$ModuleVariant(foo)`` syntax corresponds to the value of variant ``foo`` if
 defined). A Tcl evaluation error is obtained when accessing an undefined
 variant in :mfvar:`ModuleVariant` array. Use preferably the
 :mfcmd:`getvariant` command to retrieve a variant value when this variant
 state is not known.

 The list of the currently defined variants can be retrieved with
 ``[array names ModuleVariant]`` Tcl code.

 .. only:: html or latex

    .. versionadded:: 4.8

.. _Locating Modulefiles:

Locating Modulefiles
--------------------

Every directory in :envvar:`MODULEPATH` is searched to find the
*modulefile*. A directory in :envvar:`MODULEPATH` can have an arbitrary number
of sub-directories. If the user names a *modulefile* to be loaded which
is actually a directory, the directory is opened and a search begins for
an actual *modulefile*. First, :file:`modulecmd.tcl` looks for a file with
the name :file:`.modulerc` in the directory. If this file exists, its contents
will be evaluated as if it was a *modulefile* to be loaded. You may place
:mfcmd:`module-version`, :mfcmd:`module-alias` and :mfcmd:`module-virtual`
commands inside this file.

Additionally, before seeking for :file:`.modulerc` files in the module
directory, the global modulerc file and the :file:`.modulerc` file found at
the root of the modulepath directory are sourced, too. If a named version
default now exists for the *modulefile* to be loaded, the assigned
*modulefile* now will be sourced. Otherwise the file :file:`.version` is
looked up in the module directory.

If the :file:`.version` file exists, it is opened and interpreted as Tcl code
and takes precedence over a :file:`.modulerc` file in the same directory. If
the Tcl variable :mfvar:`ModulesVersion` is set by the :file:`.version` file,
:file:`modulecmd.tcl` will use the name as if it specifies a *modulefile* in
this directory. This will become the default *modulefile* in this case.
:mfvar:`ModulesVersion` cannot refer to a *modulefile* located in a different
directory.

If :mfvar:`ModulesVersion` is a directory, the search begins anew down that
directory. If the name does not match any files located in the current
directory, the search continues through the remaining directories in
:envvar:`MODULEPATH`.

Every :file:`.version` and :file:`.modulerc` file found is interpreted as Tcl
code. The difference is that :file:`.version` only applies to the current
directory, and the :file:`.modulerc` applies to the current directory and all
subdirectories. Changes made in these files will affect the subsequently
interpreted *modulefile*.

If a :file:`.modulecache` file is found at the root of a modulepath directory,
this file is interpreted as Tcl code to learn all :file:`.modulerc`,
:file:`.version` and modulefiles available. Modulepath content is read from
:ref:`module cache<Module cache>` file. Modulepath directory is only walked
through to check if limited access modulefiles or directories are available to
current user.

If no default version may be figured out, an implicit default is selected when
this behavior is enabled (see :envvar:`MODULES_IMPLICIT_DEFAULT` in
:ref:`module(1)`). If disabled, module names should be fully qualified when no
explicit default is defined for them, otherwise no default version is found
and an error is returned. If enabled, then the highest numerically sorted
*modulefile*, virtual module or module alias under the directory will be used.
The dictionary comparison method of the :manpage:`lsort(n)` Tcl command is
used to achieve this sort. If highest numerically sorted element is an alias,
search continues on its *modulefile* target.

For example, it is possible for a user to have a directory named X11 which
simply contains a :file:`.version` file specifying which version of X11 is to
be loaded. Such a file would look like:

.. code-block:: tcl

     #%Module
     set ModulesVersion R4

The equivalent :file:`.modulerc` would look like:

.. code-block:: tcl

     #%Module
     module-version ./R4 default

If the extended default mechanism is enabled (see
:envvar:`MODULES_EXTENDED_DEFAULT` in :ref:`module(1)`) the module version
specified is matched against starting portion of existing module versions,
where portion is a substring separated from the rest of version string by a
``.`` character.

When the implicit default mechanism and the `Advanced module version
specifiers`_ are both enabled, a ``default`` and ``latest`` symbolic versions
are automatically defined for each module name (also at each directory level
in case of deep *modulefile*). Unless a symbolic version, alias, or regular
module version already exists for these version names.

Every file in searched directories is checked to see if it begins with the
Modules magic cookie (i.e., ``#%Module`` file signature) to determine if it is
a *modulefile* (see `DESCRIPTION`_ section). When the :mconfig:`mcookie_check`
configuration is set to ``eval``, this check is skipped and all files in
search directories are considered *modulefiles*.

If user names a *modulefile* that cannot be found in the first *modulepath*
directory, *modulefile* will be searched in next *modulepath* directory
and so on until a matching *modulefile* is found. If search goes through
a module alias or a symbolic version, this alias or symbol is resolved by
first looking at the *modulefiles* in the *modulepath* where this alias or
symbol is defined. If not found, resolution looks at the other *modulepaths*
in their definition order.

When locating *modulefiles*, if a :file:`.modulerc`, a :file:`.version`, a
directory or a *modulefile* cannot be read during the search it is simply
ignored with no error message produced. Visibility of *modulefiles* can thus
be adapted to the rights the user has been granted. Exception is made when
trying to directly access a directory or a *modulefile*. In this case,
the access issue is returned as an error message.

Depending on their name, their file permissions or the use of specific
modulefile commands, *modulefile*, virtual module, module alias or symbolic
version may be set hidden which impacts available modules search or module
selection processes (see `Hiding modulefiles`_ section below).

.. _Hiding modulefiles:

Hiding modulefiles
------------------

A *modulefile*, virtual module, module alias or symbolic version whose name or
element in their name starts with a dot character (``.``) or who are targeted
by a :mfcmd:`module-hide` command are considered hidden. Hidden modules are
not displayed or taken into account except if they are explicitly named (e.g.,
``foo/1.2.3`` or ``foo/.2.0`` not ``foo``). If module has been hidden with the
``--soft`` option of the :mfcmd:`module-hide` command set, it is not
considered hidden if the root name of the query to search it matches module
root name (e.g., searching ``foo`` will return a ``foo/1.2.3`` modulefile
targeted by a ``module-hide --soft`` command). If module has been hidden with
the ``--hard`` option of the :mfcmd:`module-hide` command set, it is always
considered hidden thus it is never displayed nor taken into account even if
it is explicitly named.

A *modulefile*, virtual module, module alias or symbolic version who are
targeted by a :mfcmd:`module-hide --hard<module-hide>` command and a
:mfcmd:`module-forbid` command or whose file access permissions are restricted
are considered hard-hidden and forbidden. Such modules are not displayed or
taken into account. When explicitly named for evaluation selection, such
modules are unveiled to return an access error.

.. note:: When the :mconfig:`mcookie_check` configuration is set to ``eval``,
   file access permissions are not checked thus files with restricted
   permissions are included in search results but still lead to error if
   evaluated.

A symbolic version-name assigned to a hidden module is displayed or taken into
account only if explicitly named and if module is not hard-hidden. Non-hidden
module alias targeting a hidden *modulefile* appears like any other non-hidden
module alias. Finally, a hidden symbolic version targeting a non-hidden module
is displayed or taken into account only if not hard-hidden and explicitly
named to refer to its non-hidden target.

The automatic version symbols (e.g., ``default`` and ``latest``) are
unaffected by hiding. Moreover when a regular ``default`` or ``latest``
version is set hidden, the corresponding automatic version symbol takes the
left spot. For instance, if ``foo/default`` which targets ``foo/1.2.3`` is set
hard-hidden, the ``default`` automatic version symbol will be set onto
``foo/2.1.3``, the highest available version of ``foo``.

When loading a *modulefile* or a virtual module targeted by a
:mfcmd:`module-hide --hidden-loaded<module-hide>` command, this module
inherits the ``hidden-loaded`` tag. Hidden loaded modules are not reported
among :subcmd:`list` sub-command results.

If the :option:`--all` option is set on :subcmd:`avail`, :subcmd:`aliases`,
:subcmd:`whatis`, :subcmd:`search` or :subcmd:`spider` sub-commands, hidden
modules are taken into account in search. Hard-hidden modules are unaffected
by this option.

If the :option:`--all` option is set on :subcmd:`list` sub-command, hidden
loaded modules are included in result output.

A behavior equivalent to the use of the :option:`--all` option is obtained on
:subcmd:`avail`, :subcmd:`list` and :subcmd:`spider` sub-commands by adding
the ``hidden`` element to the output configuration option controlling regular
or terse reporting of these sub-commands: :mconfig:`avail_output`,
:mconfig:`avail_terse_output`, :mconfig:`list_output`,
:mconfig:`list_terse_output`, :mconfig:`spider_output`,
:mconfig:`spider_terse_output`.

Advanced module version specifiers
----------------------------------

When the advanced module version specifiers mechanism is enabled (see
:envvar:`MODULES_ADVANCED_VERSION_SPEC` in :ref:`module(1)`), the
specification of modulefile passed on Modules specific Tcl commands changes.
After the module name a version constraint and variants may be added.

Version specifiers
^^^^^^^^^^^^^^^^^^

After the module name a version constraint prefixed by the ``@`` character may
be added. It could be directly appended to the module name or separated from
it with a space character.

Constraints can be expressed to refine the selection of module version to:

* a single version with the ``@version`` syntax, for instance ``foo@1.2.3``
  syntax will select module ``foo/1.2.3``
* a list of versions with the ``@version1,version2,...`` syntax, for instance
  ``foo@1.2.3,1.10`` will match modules ``foo/1.2.3`` and ``foo/1.10``
* a range of versions with the ``@version1:``, ``@:version2`` and
  ``@version1:version2`` syntaxes, for instance ``foo@1.2:`` will select all
  versions of module ``foo`` greater than or equal to ``1.2``, ``foo@:1.3``
  will select all versions less than or equal to ``1.3`` and ``foo@1.2:1.3``
  matches all versions between ``1.2`` and ``1.3`` including ``1.2`` and
  ``1.3`` versions

Advanced specification of single version or list of versions may benefit from
the activation of the extended default mechanism (see
:envvar:`MODULES_EXTENDED_DEFAULT` in :ref:`module(1)`) to use an abbreviated
notation like ``@1`` to refer to more precise version numbers like ``1.2.3``.
Range of versions on its side natively handles abbreviated versions.

In order to be specified in a range of versions or compared to a range of
versions, the version major element should corresponds to a number. For
instance ``10a``, ``1.2.3``, ``1.foo`` are versions valid for range
comparison whereas ``default`` or ``foo.2`` versions are invalid for range
comparison.

Range of versions can be specified in version list, for instance
``foo@:1.2,1.4:1.6,1.8:``. Such specification helps to exclude specific
versions, like versions ``1.3`` and ``1.7`` in previous example.

If the implicit default mechanism is also enabled (see
:envvar:`MODULES_IMPLICIT_DEFAULT` in :ref:`module(1)`), a ``default`` and
``latest`` symbolic versions are automatically defined for each module name
(also at each directory level for deep *modulefiles*). These automatic version
symbols are defined unless a symbolic version, alias, or regular module
version already exists for these ``default`` or ``latest`` version names.
Using the ``mod@latest`` (or ``mod/latest``) syntax ensures highest available
version will be selected.

.. only:: html or latex

   .. versionadded:: 4.4

   .. versionchanged:: 4.8
      Use of version range is allowed in version list

Variants
^^^^^^^^

After the module name, variants can be specified. :ref:`Module variants` are
alternative evaluation of the same *modulefile*. A variant is specified by
associating a value to its name. This specification is then transmitted to the
evaluating *modulefile* which instantiates the variant in the
:mfvar:`ModuleVariant` array variable when reaching the :mfcmd:`variant`
modulefile command declaring this variant.

Variant can be specified with the ``name=value`` syntax where *name* is the
declared variant name and *value*, the value this variant is set to when
evaluating the *modulefile*.

Boolean variants can be specified with the ``+name`` syntax to set this
variant on and with the ``-name`` or ``~name`` syntaxes to set this variant
off. The ``-name`` syntax is not supported on :ref:`ml(1)` command as the
minus sign already means to unload designated module. The ``~name`` and
``+name`` syntaxes could also be defined appended to another specification
word (e.g., the module name, version or another variant specification),
whereas ``-name`` syntax must be the start of a new specification word.

Boolean variants may also be specified with the ``name=value`` syntax. *value*
should be set to ``1``, ``true``, ``t``, ``yes``, ``y`` or ``on`` to enable
the variant or it should be set to ``0``, ``false``, ``f``, ``no``, ``n`` or
``off`` to disable the variant.

Shortcuts may be used to abbreviate variant specification. The
:mconfig:`variant_shortcut` configuration option associates shortcut character
to variant name. With a shortcut defined, variant could be specified with the
``<shortcut>value`` syntax. For instance if character ``%`` is set as a
shortcut for variant ``foo``, the ``%value`` syntax is equivalent to the
``foo=value`` syntax.

Variant *name* should only be composed of characters part of the
``A-Za-z0-9_-`` range. Also, a variant name cannot start with ``-`` (minus)
character and the overall name cannot just be a number.

Specific characters used in variant specification syntax cannot be used as
part of the name or version of a module. These specific characters are ``+``,
``~``, ``=`` and all characters set as variant shortcut. Exception is made for
``+`` and ``~`` characters if string that follows after does not correspond to
a valid variant name (e.g., *name+*, *name++*, *name/version+1*).

.. only:: html or latex

   .. versionadded:: 4.8

   .. versionchanged:: 5.5
      Stricter variant name naming rule adopted

   .. versionchanged:: 5.5
      ``+`` and ``~`` characters are allowed in module name or version if not
      followed by a valid variant name

.. _Dependencies between modulefiles:

Dependencies between modulefiles
--------------------------------

A modulefile may express dependencies on other modulefiles. Two kind of
dependency exist: pre-requirement and conflict. The former means specified
modulefiles should be loaded prior the modulefile that express the
requirement. The latter means specified modulefiles should not be loaded for
the modulefile that express the conflict to be loaded too.

Pre-requirement could be expressed with :mfcmd:`prereq`, :mfcmd:`prereq-any`,
:mfcmd:`prereq-all`, :mfcmd:`depends-on`, :mfcmd:`depends-on-any`,
:mfcmd:`always-load`, :mfcmd:`module load<module>`,
:mfcmd:`module switch<module>`, :mfcmd:`module try-load<module>` or
:mfcmd:`module load-any<module>` modulefile commands. When the
:mconfig:`auto_handling` configuration option is disabled, required modulefile
should be manually loaded prior their dependent modulefile when expressed with
the :mfcmd:`prereq`, :mfcmd:`prereq-any`, :mfcmd:`prereq-all`,
:mfcmd:`depends-on` or :mfcmd:`depends-on-any` modulefile commands. For other
commands or when :mconfig:`auto_handling` is enabled, pre-required modulefiles
are automatically loaded.

Another form of pre-requirement is expressed through the use of the modulefile
commands :mfcmd:`module use<module>`, :mfcmd:`append-path
MODULEPATH<append-path>`, or :mfcmd:`prepend-path MODULEPATH<prepend-path>`,
when the :mconfig:`require_via` configuration option is enabled. In this
context, a modulefile that adds a modulepath is treated as a requirement for
the modulefiles loaded from that path. This pre-requirement is considered when
such modules are already loaded, helping to maintain consistency when
attempting to unload a modulefile that enables a modulepath.

Conflict is expressed with :mfcmd:`conflict`, :mfcmd:`family` or
:mfcmd:`module unload<module>` modulefile commands. When the
:mconfig:`auto_handling` or :mconfig:`conflict_unload` configuration options
are disabled, a conflicting loaded modulefile should be manually unloaded
prior loading the modulefile that express such conflict when defined with
:mfcmd:`conflict` or :mfcmd:`family`. It is automatically unloaded when
expressed with :mfcmd:`module unload<module>` (unless dependent modulefiles
are loaded) or if :mconfig:`auto_handling` and :mconfig:`conflict_unload`
options are enabled. An error is raised when trying to load a module that is
already loaded but with a different variant set or coming from a different
modulepath. If both options are enabled the loaded module is automatically
unloaded to satisfy the new set of variant or modulepath asked.

It is strongly advised to define dependencies prior environment changes in a
modulefile. Dependency resolution should be done before any environment change
to ensure the environment is getting set in the same order whether
pre-requirements are already loaded, or if they are automatically loaded when
loading the modulefile which depends on them, or if all loaded modules are
reloaded or refreshed. This is especially important when the modulefile
updates an environment variable also altered by other modulefiles like
:envvar:`PATH`. As the order of the path elements in such variable defines
priority, it is important that this order does not change depending on the way
the modulefiles are loaded.

:command:`module` keeps environment consistent which means a modulefile cannot
be loaded if its requirements are not loaded or if a conflicting module is
loaded. In addition a loaded module cannot be unloaded if other loaded modules
depends on it. The :ref:`automated module handling
mechanisms<MODULES_AUTO_HANDLING>` attempt to solve the dependencies expressed
by loading or unloading additional modulefiles. When the :option:`--no-auto`
option is set on :command:`module` command when loading or unload modulefile,
automated module handling mechanisms are disabled and dependencies have to be
solved manually. When dependencies are not satisfied, modulefile fails to load
or unload.

Adding the ``--not-req`` option when expressing dependencies in modulefile
with the :mfcmd:`module` command will attempt to load or unload the designated
modulefile but it will not mark them as pre-requirement or conflict.

Adding the ``--optional`` option on :mfcmd:`prereq`, :mfcmd:`prereq-any`,
:mfcmd:`prereq-all`, :mfcmd:`depends-on`, :mfcmd:`depends-on-any` or
:mfcmd:`always-load` modulefile commands declares the pre-requirement as
optional. If an optional pre-requirement is not found loaded or cannot be
automatically loaded, the dependency expressed is yet considered satisfied.
When an optional requirement is loaded afterward, the dependent module will
get automatically reloaded if the :mconfig:`auto_handling` configuration
option is enabled.

By adding the :option:`--force` option to the :command:`module` command when
loading or unloading modulefile, the consistency checks are by-passed. This
option cannot be used when expressing dependencies in modulefiles. If a module
has been force loaded whereas its requirements are not loaded or whereas a
conflicting module is also loaded, the user environment is said inconsistent.

Note that a pre-requirement should be found in the loaded module list prior
its dependent module. User environment is considered inconsistent if
pre-requirement module is found loaded after dependent module, as the
environment changes may have been done in the wrong priority order.

When user environment is considered inconsistent global operations achieved by
:subcmd:`refresh`, :subcmd:`reload` and :subcmd:`save` sub-commands cannot
perform. This mechanism is there to avoid the situation to worsen by
re-evaluating all loaded modules or recording this environment.

When the :mconfig:`auto_handling` configuration option is enabled, if missing
pre-requirement modulefile gets loaded or conflicting modulefile gets unloaded
the inconsistent loaded module will be automatically reloaded to make user
environment consistent again.

.. only:: html or latex

   .. versionchanged:: 4.2
      Options :option:`--force`, :option:`--auto` and :option:`--no-auto`
      added

   .. versionchanged:: 4.2
      :ref:`Automated module handling mechanisms<MODULES_AUTO_HANDLING>` added

   .. versionchanged:: 4.7
      Option ``--not-req`` added

   .. versionchanged:: 5.6
      A modulefile enabling a modulepath is considered a requirement of
      modulefiles stored in this path if :mconfig:`require_via` configuration
      option is enabled

Modulefile Specific Help
------------------------

Users can request help about a specific *modulefile* through the
:ref:`module(1)` command. The *modulefile* can print helpful information or
start help oriented programs by defining a ``ModulesHelp`` subroutine. The
subroutine will be called when the :subcmd:`module help modulefile<help>`
command is used.

Help text may also be defined within *modulefile* with :mfcmd:`module-help`
command. Text defined such way is printed before evaluation of ``ModulesHelp``
subroutine if any.


Modulefile Specific Test
------------------------

Users can request test of a specific *modulefile* through the :ref:`module(1)`
command. The *modulefile* can perform some sanity checks on its
definition or on its underlying programs by defining a ``ModulesTest``
subroutine. The subroutine will be called when the
:subcmd:`module test modulefile<test>` command is used. The subroutine should
return 1 in case of success. If no or any other value is returned, test is
considered failed.


Modulefile Display
------------------

The :subcmd:`module display modulefile<display>` command will detail all
changes that will be made to the environment. After displaying all of the
environment changes :file:`modulecmd.tcl` will call the ``ModulesDisplay``
subroutine. The ``ModulesDisplay`` subroutine is a good place to put
additional descriptive information about the *modulefile*.


.. _Compatibility with Lmod Tcl modulefile:

Compatibility with Lmod Tcl modulefile
--------------------------------------

The :file:`modulecmd.tcl` program supports Tcl modulefile or modulerc written
for Lmod, the alternative :command:`module` implementation developed in Lua.
Except for the specific cases listed below, such modulefiles can be evaluated
by Modules without producing errors. Key differences between the two
implementations are outlined below.

The ``remove-property`` modulefile command is evaluated as a *no-operation*
command. No error is obtained if this command is used in modulefiles but no
change occurs.

The :mfcmd:`haveDynamicMPATH` is evaluated as a *no-operation* modulefile
command. If modulefile conditionally updates :envvar:`MODULEPATH` environment
variable, this command is needed to help Lmod know that modulefile changes
:envvar:`MODULEPATH`. :subcmd:`spider` sub-command on Modules does not need
this information as modulefile is evaluated in the context of the current
user to determine whether :envvar:`MODULEPATH` is updated.

The :mfcmd:`break` command does not accept any argument. A ``msg`` argument
can be set on Lmod to provide a customized break error message.

The :mfcmd:`setenv`, :mfcmd:`unsetenv`, :mfcmd:`prepend-path`,
:mfcmd:`append-path`, :mfcmd:`remove-path`, :mfcmd:`pushenv` and ``module``
:mfcmd:`load<module>`, :mfcmd:`load-any<module>`, :mfcmd:`try-load<module>`
and :mfcmd:`unload<module>` modulefile commands do not support the ``--mode``
option. An error is raised if this option is used.

The :mfcmd:`setenv` and :mfcmd:`unsetenv` modulefile commands do not support
the ``--respect`` option. An error is raised if this option is used.

Use of :mfcmd:`reportError` command aborts modulefile evaluation on Lmod. This
command only reports an error message on Modules.

The :mfcmd:`require-fullname` command only aborts *load* modulefile evaluation
whereas the Lmod implementation also aborts *unload* and *display*
evaluations.

When processing a :mfcmd:`family` command, the :envvar:`LMOD_FAMILY_\<NAME\>`
environment variable is also defined to be compatible with modulefiles or
scripts relying on such variable.

When unloading a modulefile, the :mfcmd:`pushenv` command does not update the
value of the environment variable if this modulefile was not defining the
value currently in use.

The third optional argument of :mfcmd:`append-path` and :mfcmd:`prepend-path`
commands corresponds to a priority specification on Lmod whereas these two
commands accept multiple path element arguments on Modules.

The :mfcmd:`prereq` command is equivalent to the :mfcmd:`prereq-any` command
on Modules whereas on Lmod it is equivalent to the :mfcmd:`prereq-all`
command.

If the :mconfig:`auto_handling` configuration option is disabled, the
requirements defined with the :mfcmd:`depends-on` or :mfcmd:`depends-on-any`
commands are not automatically loaded and an error is raised if none of these
requirements are found loaded.

If the :mconfig:`auto_handling` or :mconfig:`conflict_unload` configuration
options are disabled, the conflicts defined with the :mfcmd:`family` command
are not automatically unloaded and an error is raised when trying to load a
module defining a family already defined by a loaded module.

On :subcmd:`module load-any<load-any>` sub-command and modulefile command, a
modulefile evaluation error is not reported and :subcmd:`module
load-any<load-any>` continues to the next modulefile instead of aborting the
whole process. No attempt to load listed modulefiles is made if one of these
modulefiles is found already loaded.

On :mfcmd:`module try-load<module>` modulefile command, each modulefile
specified is considered an optional pre-requirement. If it is loaded
afterward and if the :mconfig:`auto_handling` configuration option is enabled,
the dependent module will get automatically reloaded.

.. only:: html or latex

   .. versionadded:: 5.1

   .. versionchanged:: 5.5
      Modulefile commands :mfcmd:`hide-modulefile` and :mfcmd:`hide-version`
      implemented

   .. versionchanged:: 5.6
      Modulefile commands :mfcmd:`add-property`, :mfcmd:`depends-on-any` and
      :mfcmd:`haveDynamicMPATH` implemented

.. _Shell support:

Shell support
-------------

The :file:`modulecmd.tcl` program that evaluates *modulefiles* supports a
variety of shells or languages: *sh* family shells (*sh*, *bash*, *ksh* and
*zsh*), *csh* family shells (*csh* and *tcsh*), *fish*, *cmd*, *pwsh*,
*python*, *perl*, *ruby*, *tcl*, *cmake*, *r*, and *lisp*.

Modulefiles produce environment changes when evaluated, like defining an
environment variable. The :file:`modulecmd.tcl` program outputs the
corresponding code for the selected "shell". Thereafter this code is evaluated
by the :command:`module` alias or function to update the current environment.

Depending on the "shell" kind, not all the environment changes that can be
defined in modulefiles are supported. The following table summarizes the
changes that are supported by the shells supported by :file:`modulecmd.tcl`.

+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
|        | Environment variables | Shell alias          | Shell functions         | Command completion  | :mfcmd:`chdir` | :mfcmd:`x-resource` |
|        | (:mfcmd:`setenv`,     | (:mfcmd:`set-alias`, | (:mfcmd:`set-function`, | (:mfcmd:`complete`, |                |                     |
|        | :mfcmd:`unsetenv`,    | :mfcmd:`unset-alias`)| :mfcmd:`unset-function`)| :mfcmd:`uncomplete`)|                |                     |
|        | :mfcmd:`pushenv`,     |                      |                         |                     |                |                     |
|        | :mfcmd:`append-path`, |                      |                         |                     |                |                     |
|        | :mfcmd:`prepend-path`,|                      |                         |                     |                |                     |
|        | :mfcmd:`remove-path`) |                      |                         |                     |                |                     |
+========+=======================+======================+=========================+=====================+================+=====================+
| sh     | x                     | x                    | x                       |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| bash   | x                     | x                    | x                       | x                   | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| ksh    | x                     | x                    | x                       |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| zsh    | x                     | x                    | x                       |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| csh    | x                     | x                    |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| tcsh   | x                     | x                    |                         | x                   | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| fish   | x                     | x                    | x                       | x                   | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| cmd    | x                     | x                    |                         |                     | x              |                     |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| pwsh   | x                     | x                    | x                       | x                   | x              |                     |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| python | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| perl   | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| ruby   | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| tcl    | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| cmake  | x                     |                      |                         |                     |                | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| r      | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+
| lisp   | x                     |                      |                         |                     | x              | x                   |
+--------+-----------------------+----------------------+-------------------------+---------------------+----------------+---------------------+

The :mfcmd:`source-sh` command evaluates a shell script and produces the
modulefile commands corresponding to the environment changes made by this
script. :mfcmd:`source-sh` is able to evaluate *sh*, *bash*, *ksh*, *zsh*,
*csh*, *tcsh* and *fish* shell scripts. :mfcmd:`source-sh` produces
environment changes corresponding to the kinds listed in the above table.
Based on the evaluated script, refer to the above table to know the
environment changes that will be rendered for the shell specified to
:file:`modulecmd.tcl` program.


ENVIRONMENT
-----------

See the :ref:`ENVIRONMENT<module ENVIRONMENT>` section in the
:ref:`module(1)` man page.

SEE ALSO
--------

:ref:`envml(1)`, :ref:`ml(1)`, :ref:`module(1)`, ref:`modulecmd(1)`,
:manpage:`Tcl(n)`, :manpage:`TclX(n)`, :manpage:`id(1)`, :manpage:`xrdb(1)`,
:manpage:`exec(n)`, :manpage:`uname(1)`, :manpage:`domainname(1)`,
:manpage:`tclvars(n)`, :manpage:`lsort(n)`, :manpage:`string(n)`


NOTES
-----

Tcl was developed by John Ousterhout at the University of California
at Berkeley.

TclX was developed by Karl Lehenbauer and Mark Diekhans.
