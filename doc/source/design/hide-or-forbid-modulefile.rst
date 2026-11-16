.. _hide-or-forbid-modulefile:

Hide or forbid modulefile
=========================

Configuration
-------------

- No specific configuration


Use cases
---------

- Restrict usage of particular software to a limited set of user (RestrictUsage)

  - Included in module specification result for a not granted user: no
  - Visible for a not granted user on a full ``avail`` or ``spider``: no
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: no
  - Visible for a not granted user once loaded on a ``list``: yes
  - Load tentative for a not granted user: error

- Allow usage of particular software once clearance has been obtained (AllowOnceCleared)

  - Included in module specification result for a not granted user: yes
  - Visible for a not granted user on a full ``avail`` or ``spider``: yes
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: yes
  - Visible for a not granted user once loaded on a ``list``: yes
  - Load tentative for a not granted user: error

- Expire a software after a given date (Expire)

  - Included in module specification result for a not granted user: no after expiration date
  - Visible for a not granted user on a full ``avail`` or ``spider``: no after expiration date
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: no after expiration date
  - Visible for a not granted user once loaded on a ``list``: yes, even after expiration date
  - Load tentative for a not granted user: error after expiration date

- Disclose a software after a given date (Disclose)

  - Included in module specification result for a not granted user: no prior disclosure date
  - Visible for a not granted user on a full ``avail`` or ``spider``: no prior disclosure date
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: no prior disclosure date
  - Visible for a not granted user once loaded on a ``list``: yes, even prior disclosure date
  - Load tentative for a not granted user: error prior disclosure date

- Hide software not of interest for current user (HideNotOfInt)

  - Included in module specification result for a not granted user: yes
  - Visible for a not granted user on a full ``avail`` or ``spider``: no, unless specific option set
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: yes
  - Visible for a not granted user once loaded on a ``list``: yes
  - Load tentative for a not granted user: success

- Hide software only useful for other software as dependency (HideDep)

  - Included in module specification result for a not granted user: yes
  - Visible for a not granted user on a full ``avail`` or ``spider``: no, unless specific option set
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: yes
  - Visible for a not granted user once loaded on a ``list``: yes
  - Load tentative for a not granted user: success

- Hide dependency software once loaded (HideDepOnceLoaded)

  - Included in module specification result for a not granted user: see HideDep
  - Visible for a not granted user on a full ``avail`` or ``spider``: see HideDep
  - Visible for a not granted user on a targeted ``avail`` or ``spider``: see HideDep
  - Visible for a not granted user once loaded on a ``list``: no, unless specific option set
  - Load tentative for a not granted user: see HideDep


Specification
-------------

- 2 new modulefile commands are introduced for the needs described above: :mfcmd:`module-hide` and :mfcmd:`module-forbid`

- ``module-hide`` removes visibility of specified modules

  - ``module-hide`` acts when modules are searched (``avail``, ``spider``, ``whatis`` and ``search`` sub-commands) or selected (``load``, ``unload``, ``display``, etc sub-commands)

  - Visibility is however enabled if hidden module is specifically searched

    - On all context hidden module *mod/1.0* is included in result for instance if *mod/1.0* or *mod@1.0,2.0* are specified
    - But hidden module *mod/1.0* is excluded from result if *mod@:2.0* or *mod@1:* are specified
    - And is also excluded from result if *mod* or *mod/** are specified when *mod/1.0* is set default
    - Unless if search is made to select one module since in this context a *mod* search query is equivalent to *mod/default*
    - Hard-hidden modules are not disclosed even if specifically searched

  - Excluded from module resolution result

    - Unless precisely specified on the following selection contexts:

      - :ref:`module_version_specification_to_select_one_module`
      - :ref:`module_version_specification_to_check_compatibility`
      - :ref:`module_version_specification_to_return_all_matching_modules`

    - For example, the hidden module *mod/1.0*

      - is included in ``module load mod/1.0`` result
      - is excluded from ``module load mod/1`` result, even if default symbol targets it
      - is excluded from ``module load mod`` result, unless if default symbol targets it (as query is equivalent to *mod/default*)
      - is excluded from ``module load mod@:2`` result, even if default symbol targets it
      - is included in ``module load mod@1.0,2.0`` result
      - is included/excluded the same way for ``prereq`` and ``conflict`` sub-commands than ``load`` sub-command
      - is matched by ``is-loaded`` and ``info-loaded`` sub-commands querying it once loaded
      - is excluded from ``module whatis`` result
      - is included/excluded the same way for ``whatis``, ``spider`` sub-commands than ``avail`` sub-command
      - is excluded from ``module avail`` result
      - is excluded from ``module avail m*`` result
      - is included in ``module avail mod/1.0`` result
      - is excluded from ``module avail mod/1`` result, even if default symbol targets it
      - is excluded from ``module avail mod`` result, even if default symbol targets it (as query is NOT equivalent to *mod/default* in this context)
      - is excluded from ``module avail mod@:2`` result, even if default symbol targets it
      - is included in ``module avail mod@1.0,2.0`` result

  - Included in module resolution result if :option:`--all` option of ``avail``, ``whatis``, ``search``, ``aliases`` and ``spider`` sub-commands is set

    - ``--all`` option does not apply to ``is-avail`` sub-command to make it coherent with ``load`` sub-command (e.g., a ``is-avail mod`` returning true implies ``load mod`` effectively loading a module)

  - Visibility of a module targeted by a ``module-hide`` command, with regular hiding level defined, acts similarly than for a file whose name is prefixed by a dot character on Unix platform

  - If ``--soft`` option is set on ``module-hide`` command, module hiding is weakened

    - Module is always included in resolution result for the following contexts

      - :ref:`module_version_specification_to_select_one_module`
      - :ref:`module_version_specification_to_check_compatibility`

    - For example, the hidden module *mod/1.0*

      - is included in ``module load mod/1.0`` result
      - is included in ``module load mod/1`` result
      - is included in ``module load mod`` result
      - is included in ``module load mod@:2`` result
      - is included in ``module load mod@1.0,2.0`` result
      - is included/excluded the same way for ``prereq`` and ``conflict`` sub-commands than ``load`` sub-command
      - is matched by ``is-loaded`` and ``info-loaded`` sub-commands querying it once loaded
      - is excluded from ``module whatis`` result
      - is included/excluded the same way for ``whatis``, ``spider`` sub-commands than ``avail`` sub-command
      - is excluded from ``module avail`` result
      - is excluded from ``module avail m*`` result
      - is included in ``module avail mod/1.0`` result
      - is included in ``module avail mod/1`` result
      - is included in ``module avail mod`` result
      - is included in ``module avail mod@:2`` result
      - is included in ``module avail mod@1.0,2.0`` result

  - If ``--hard`` option is set on ``module-hide`` command, hiding is hardened and designated modules are never unveiled

    - Designated modules are strictly hidden, also referred as *hard-hidden*

      - ``--all`` option of ``avail`` and ``spider`` sub-commands cannot unveil them

    - Excluded from module resolution result, which means it is always excluded from resolution on following context:

      - :ref:`module_version_specification_to_select_one_module`
      - :ref:`module_version_specification_to_check_compatibility`
      - :ref:`module_version_specification_to_return_all_matching_modules`

    - For example, the hard-hidden module *mod/1.0*

      - is excluded from ``module load mod/1.0`` result
      - is excluded from ``module load mod`` result, even if default symbol targets it
      - is excluded from ``module load mod/1`` result, even if default symbol targets it
      - is excluded from ``module load mod@:2`` result, even if default symbol targets it
      - is excluded from ``module load mod@1.0,2.0`` result
      - is included/excluded the same way for ``prereq`` and ``conflict`` sub-commands than ``load`` sub-command
      - is matched by ``is-loaded`` and ``info-loaded`` sub-commands querying it once loaded
      - is excluded from any ``avail`` query result
      - is included/excluded the same way for ``whatis``, ``spider`` sub-commands than ``avail`` sub-command

    - Visibility of a module targeted by a ``module-hide --hard`` command acts like if no modulefile exists on filesystem

  - If ``--hidden-loaded`` option is set on ``module-hide``, hiding also applies to specified modules once they are loaded

    - Hidden once loaded modules do not appear on ``module list``

      - Unless ``--all`` option is set on ``list`` sub-command

    - Hidden once loaded modules load, unload or tag is not reported

      - If this evaluation has been triggered automatically

        - By an *automated module handling mechanism* for instance
        - Which means user has not explicitly asked the module load or unload

      - And was automatically loaded, in case of an automatic unload

        - Which means the automatic unload of an hidden loaded module will be reported if it was manually loaded

      - And if ``verbosity`` level is lower than ``verbose2`` level
      - And if no issue occurs during hidden module evaluation
      - Switch of hidden modules is not reported

        - If both switched-off and switched-on modules are set hidden
        - If switched-off module were automatically loaded
        - And if the switch evaluation has been automatically triggered

    - When those modules are loaded, a ``hidden-loaded`` tag is applied to them and recorded in :envvar:`__MODULES_LMTAG` environment variable to keep track of their hidden status
    - Hidden once loaded status does not affect ``is-loaded``: these modules will always be reported if they match ``is-loaded`` queries

- ``module-forbid`` disallow evaluation of specified modules

  - It does not imply hiding, but can be of course coupled with ``module-hide`` calls
  - Evaluation of targeted modules is forbidden

    - Error is rendered prior evaluation when trying to *load*, *display*, *help*, *test*, *path*, *whatis* them
    - Note that for *whatis* evaluation mode, an error is reported only if a module is referred by its exact name which is not the case on ``search`` sub-command as no module is specified, just a keyword to search
    - No error occurs when unloading a module that were set forbidden after it was loaded by user

  - As it impacts module evaluation, ``module-forbid`` is only effective when it targets modulefiles or virtual modules

    - Module alias or symbolic version are not impacted by ``module-forbid`` directives
    - Even if they match some ``module-forbid`` statements, they are still resolved to their target and these targets do not inherit the *forbidden* tag set on their alias, symbol.
    - When a ``module-forbid`` command targets a directory, this directory is still resolved to its target, but the target inherits the *forbidden* tag as it matches the name specified on ``module-forbid`` command

  - When combined with a ``module-hide --hard`` command, designated modules is unveiled if referred by its exact name and set in error

    - Thus an error is obtained when trying to reach module instead of not finding it (which is the regular behavior for hard-hidden modules)

- ``module-hide`` accepts options that change its behavior:

  - ``--hidden-loaded``: hides module from loaded module list
  - ``--soft``: lightweight module hide
  - ``--hard``: highest hiding level
  - ``--not-user``: specify a list of users unaffected by hide mechanism
  - ``--not-group``: specify a list of groups whose member are unaffected by hide mechanism
  - ``--user``: specify a list of users specifically affected by hide mechanism
  - ``--group``: specify a list of groups whose member are specifically affected by hide mechanism
  - ``--before``: enables hide mechanism until a given date
  - ``--after``: enables hide mechanism after a given date
  - ``--regexp``: module arguments are regular expressions designating the modules to hide

- ``module-forbid`` accepts options that change its behavior:

  - ``--not-user``: specify a list of users unaffected by forbid mechanism
  - ``--not-group``: specify a list of groups whose member are unaffected by forbid mechanism
  - ``--user``: specify a list of users specifically affected by forbid mechanism
  - ``--group``: specify a list of groups whose member are specifically affected by forbid mechanism
  - ``--before``: enables forbid mechanism until a given date
  - ``--after``: enables forbid mechanism after a given date
  - ``--message``: supplements error message obtained when trying to evaluate a forbidden module with given text message
  - ``--nearly-message``: supplements warning message obtained when evaluating a nearly forbidden module with given text message
  - ``--regexp``: module arguments are regular expressions designating the modules to forbid

- ``--regexp`` option selects modules with regular expressions rather than module specifications

  - See :ref:`module-tags` design notes for the description of this option, as it is shared by ``module-hide``, ``module-forbid``, ``module-tag`` and ``module-warn``
  - Hiding level set through regular expressions is compared to the levels set on module specifications and on full path designation: the strongest matching level is retained

- Each use case expressed above are covered by following command:

  - RestrictUsage: ``module-hide --hard``
  - AllowOnceCleared: ``module-forbid``
  - Expire: ``module-forbid --after`` + ``module-hide --hard --after``
  - Disclose: ``module-hide --hard --before``
  - HideNotOfInt: ``module-hide --soft``
  - HideDep: ``module-hide --soft``
  - HideDepOnceLoaded: ``module-hide --soft --hidden-loaded``

- ``module-hide`` and ``module-forbid`` accept the specification of several modules

  - For instance ``module-hide mod1 mod2...``
  - :ref:`advanced-module-version-specifiers` are supported if relative module option is enabled
  - Full path specification are not supported, as modulerc are not evaluated when reaching a modulefile specified as full path

    - For instance, ``/path/to/modulefiles/.modulerc`` is not evaluated when loading ``/path/to/modulefiles/mod/1.0``
    - Thus ``module-hide`` and ``module-forbid`` commands set in this modulerc files are not evaluated
    - If module is specified as full path, no error is returned, but it will have no effect as demonstrated above

      - Unless on very specific cases, where a global rc file defines these hidden/forbidden commands for the full path modules

- ``--user``, ``--group``, ``--not-user`` and ``--not-group`` specification is only supported on Unix platform

  - These options raise an error when used on Windows platform
  - In which case relative ``module-hide`` or ``module-forbid`` command is made ineffective as well as remaining content of the modulerc script hosting them
  - Error message is clearly seen when trying to load related modules and indicate where to find the erroneous command

- ``--user`` and ``--group`` options prevail over ``--not-user`` and ``--not-group`` options

  - When ``--user`` or ``--group`` is set, exclusion list from ``--not-user`` and ``--not-group`` are ignored

- ``--before`` and ``--after`` are also supported by ``module-hide`` to phase-out modules prior to forbid their evaluation

- ``--before`` and ``--after`` accept a date time as value

  - Accepted date time format is ``YYYY-MM-DD[THH:MM]``
  - If no time value is specified (just a date like ``2020-08-01``), *00:00* is assumed

    - So ``2020-08-01`` is translated into ``2020-08-01T00:00``

  - An error is raised if submitted date time value does not match accepted date time format

  - if both ``--before`` and ``--after`` options are set and *before* date is greater than *after* date

    - targeted module is always hidden/forbidden
    - no error is returned

- ``--before`` and ``--after`` options are not supported on Tcl version below 8.5

  - Prior 8.5, ``clock scan`` command does not have a ``-format`` option
  - This option is required to support defined date time format
  - An error is raised when ``--before`` or ``--after`` options are used over a Tcl version below 8.5

- ``--message`` option adds additional text to the *access denied* error message

  - Newline set in text message are preserved, which could help to control text output format
  - Message content is set along forbidden module specification

    - Message recorded for matching module specification will be printed
    - Message recorded on other matching specification will be ignored, only message from retained matching specification is printed
    - Firstly evaluated ``module-forbid`` command that matches module specification is retained with its message property

- a module matching a ``module-forbid`` statement whose ``--after`` limit is close is considered *nearly forbidden*

  - ``nearly-forbidden`` tag applies to such module
  - matched ``module-forbid`` statement should of course not be disabled for current user or group due to ``--not-user`` or ``--not-group`` option values
  - the *near* range is defined by the :mconfig:`nearly_forbidden_days` configuration, which equals to ``14`` (14 days) by default
  - this configuration accepts an integer value which represents a number of days prior forbidding starts to be effective for module
  - ``nearly_forbidden_days`` configuration can be set at configure time with :instopt:`--with-nearly-forbidden-days` option or afterward with the ``config`` sub-command (which sets the :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS` environment variable)
  - when evaluating a *nearly-forbidden* module, a warning message is reported to indicate that module access will soon be denied

- ``--nearly-message`` option adds additional text to the *access will be denied* warning message

  - Newline set in text message are preserved, which could help to control text output format
  - Message content is set along nearly-forbidden module specification

    - Message recorded for matching module specification will be printed
    - Message recorded on other matching specification will be ignored, only message from retained matching specification is printed
    - Firstly evaluated ``module-forbid`` command that matches module specification is retained with its message property

- ``module-hide`` and ``module-forbid`` are intended to be used in modulerc files

  - as they impact modulefile resolution
  - they also need to be enabled in modulefile context as global/user rc files are evaluated as modulefile, not modulerc

- several ``module-hide`` calls for the same module will supersede each other

  - definition with the highest hiding level wins
  - which means the most restrictive call wins
  - a ``--hidden-loaded`` status set is kept even if corresponding ``module-hide`` call is not the highest one
  - the multiple definitions can come across different modulerc files (global, modulepath or modulefile rc levels)

- Module specification passed as argument to ``module-hide`` and ``module-forbid`` are matched exactly against available modules

  - Exception made when *extended_default* or *icase* mechanisms are enabled
  - Which means wildcard characters like *\** or *?* are treated literally

- Auto symbols (*@default* and *@latest*) are adapted when a *latest* version is hidden

  - Auto symbols are applied to this version if it is selected specifically (for instance loaded by its full name)
  - Auto symbols are applied to another version when hidden latest is not selected specifically, even if specified with *@latest* auto symbol

- Auto-symbols cannot be set hidden

  - When a defined ``default`` or ``latest`` symbol is set hidden, it is replaced by a ``default`` or ``latest`` auto-symbol targeting highest available module version
  - Targeting an auto-symbol with a ``module-hide`` command, will have no effect

- When module specification of ``module-hide`` targets:

  - A symbolic version

    - This symbol only is hidden
    - Modulefile targeted by hidden symbolic version stays visible

  - An alias

    - This alias only is hidden
    - Modulefile targeted by hidden alias stays visible

  - A modulefile targeted by either symbolic version or alias

    - This modulefile is hidden and all symbolic versions targeting it
    - Aliases targeting modulefile stays visible (thus resolving alias in *load* or *whatis* contexts make hidden modulefile target visible unless if set hard-hidden)

- Hidden alias or symbolic version should not appear in the list of alternative names of loaded modules

  - Unless this alias or symbolic version is not hard-hidden and is used to designate the module to load
  - When ``default`` symbolic version is set hidden

    - also remove parent module name from the list of alternative names
    - if resolution query corresponds to parent module name, unhide ``default`` symbol unless if hard-hidden

- On ``avail``/``spider`` sub-commands

  - Hidden symbolic versions are not reported along module they target

    - Unless for non-hard-hidden symbols specifically designated in search query

  - A :option:`--default` filtered search considers search query matches ``default`` symbol

    - So ``default`` symbolic version will appear in result unless if hard-hidden

- Different hiding level are considered

  - *-1*: module is not hidden
  - *0*: soft hiding (applied with ``module-hide --soft``)
  - *1*: regular hiding (applied with dot name module or default ``module-hide`` command)
  - *2*: hard hiding (applied with ``module-hide --hard``)

- Hiding threshold

  - is *0* by default, which means module is considered hidden if its hiding level is greater or equal to *0*
  - is raised to *2* when ``--all`` option is applied, which means module is considered hidden if its hiding level is greater or equal to *2*

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
