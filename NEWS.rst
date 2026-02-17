.. _NEWS:

Release notes
=============

This file describes changes in recent versions of Modules. It primarily
documents those changes that are of interest to users and admins.

.. _5.7 release notes:

Modules 5.7.0 (not yet released)
--------------------------------

* Script: improve :command:`mrel` to always ask a Fedora Kerberos ticket.
* Use CMake ``EVAL CODE`` to forward arguments passed to ``module`` CMake
  function. (fix issue #419 with contribution from Benoit Dumas)
* Doc: update email address in `Code of conduct`_ to report bad behavior to
  maintainers.
* Move *modules-interest* mailing-list to HPSF.
* Script: add tests on :command:`mb` utility to track performance of load,
  list and purge sub-commands with large number (>100) of modules.
* Script: fix procedure call timing of Tcllib profiler module within
  :command:`mlprof` to avoid mixing timers from calls made at different
  interpretation level.
* Parse loaded environment in early execution stage and always fail if an
  inconsistency is detected.
* Improve performances of loaded module comparison used when checking
  conflict and requirement dependencies. (fix issue #603)
* Fix environment variable synchronization issue between modulefile evaluation
  interpreters: supersede the ``append`` Tcl command rather sync interpreters
  for each environment variable change. A substantial performance improvement
  is observed when loading or unloading many modulefiles. (fix issue #603)
* Script: add ``--with-lmod`` option to :command:`mb` command to compare
  current Modules version against an installed version of Lmod.
* Update the :subcmd:`sh-to-mod` mechanism to correctly parse shell alias on
  Dash shell version 0.5.13.
* Update the :subcmd:`sh-to-mod` mechanism to correctly parse path-like
  environment variable on Fish shell version 4.3.
* When fetching user's groups, in case a group name cannot be resolved use
  this group gid number as name instead of raising an error. (fix issue #604)
* Introduce :mconfig:`path_entry_reorder` configuration option that change
  order of entry in a path-like environment variable when it is added again.
  This new configuration option is disabled by default. This option can be
  changed at installation time with :instopt:`--enable-path-entry-reorder`.
  When :mconfig:`path_entry_reorder` is changed with :subcmd:`config`
  sub-command, it sets the :envvar:`MODULES_PATH_ENTRY_REORDER` environment
  variable. (fix issue #595 with contribution from Achim Gsell)
* Install: reorder the options in the :file:`configure` script help message
  alphabetically.
* Doc: add manual page for :ref:`modulecmd(1)` command.
* Make :mfcmd:`getenv` modulefile command available from module rc file
  evaluation context. (fix issue #588)
* Install: add installation option
  :instopt:`--disable-compressed-changelog<--enable-compressed-changelog>` to
  cope with packaging process handling documentation file compression at their
  level. (fix issue #592)
* Add :option:`-p` option as an abbreviated form for :option:`--paginate`.
  (fix issue #593)
* Add :option:`-P` option as an abbreviated form for :option:`--no-pager`.
  (fix issue #606)
* Doc: add :ref:`organize-tsc-meeting` guide.
* Add the :mconfig:`paginate` configuration option to control whether or not
  output message should be piped into defined pager by default. This option
  can be changed at installation time with :instopt:`--enable-paginate`. When
  :mconfig:`paginate` is changed with :subcmd:`config` sub-command, it sets
  the :envvar:`MODULES_PAGINATE` environment variable. (fix issue #594)
* Doc: add :ref:`plan-next-release-content` guide
* Introduce the :mconfig:`non_exportable_tags` configuration option that lists
  tags that should not be exported to modules once loaded. When
  :mconfig:`non_exportable_tags` is changed with :subcmd:`config` sub-command,
  it sets the :envvar:`MODULES_NON_EXPORTABLE_TAGS` environment variable. (fix
  issue #608)


.. _5.6 release notes:

Modules 5.6.1 (2025-11-25)
--------------------------

* Script: improve :command:`mrel` to better support Koji states and not rely
  on sudo privileges to test a new release.
* Script: adapt utilities to only use :command:`curl` rather also requiring
  :command:`wget`.
* Doc: :ref:`CHARTER` has been approved on September 4, 2025.
* Doc: add :ref:`EESSI` design notes.
* Doc: update :ref:`modulefile(5)` man page to describe the :mfcmd:`report`
  modulefile command, which is supported since version 4.0. 
* Doc: use `Furo`_ Sphinx theme for the documentation published on Read The
  Docs.
* Doc: describe how to call modulefile command from a hook procedure in
  :ref:`module(1)` man page. (fix issue #590)
* Doc: add warning in :ref:`INSTALL-win` to mention :command:`ml` command name
  conflict with *MSVC x86 toolchain* ``ml.exe``. (fix issue #589)
* Doc: add :ref:`maintainer-guide`.
* Doc: website is now located at https://envmodules.io.
* Doc: precise that no automatic path resolution is performed on
  :mfcmd:`prepend-path`, :mfcmd:`append-path` or :mfcmd:`remove-path`
  modulefile commands. (fix issue #597)
* Doc: add way to build latexpdf documentation.
* Ensure that a module having the same name than a loaded module from
  another modulepath does not inherit its tags. (fix issue #599)
* Drop tags stored in memory that applies to a module when unloading it. It
  ensures that tags applied to the module when reloaded from a different
  modulepath are not inherited.
* Always apply *abort on error* behavior in case a Dependent Reload sticky
  (and :option:`--force` is not set) or super-sticky module fails to reload.
  (fix issue #601)
* When loading a module, check already loaded modules and their aliases
  exactly matching specification before looking at available modules and their
  aliases. (fix issue #602)

.. _Furo: https://github.com/pradyunsg/furo


Modules 5.6.0 (2025-07-31)
--------------------------

* Rename :file:`contrib` directory as :file:`share` in sources to use clearer
  name for architecture and configuration independent files.
* Set a `Security policy`_ for the project.
* Add red, white and black SVG logo files of Modules project.
* Doc: improve Links, Community sections in documentation index and README
* Doc: improve Authors and Acknowledgments sections in README
* Doc: add :ref:`create-new-release` guide
* Update repository URL to https://github.com/envmodules/modules.
* Install: update :file:`configure` script to allow running it from a current
  working directory different than where this file is stored. (fix issue #558)
* Doc: create *Developer HowTos* section on documentation website to group
  development how-to guides.
* Doc: add :ref:`acknowledgments` page in the documentation.
* Doc: describe :ref:`GOVERNANCE`.
* Doc: add :ref:`CHARTER`.
* Escape square brackets (``[]``) used in values within produced shell code as
  these characters may have special meaning on some shells (like *csh*). (fix
  issue #565)
* Doc: advertise the `Modules chat room`_ (``#modules:matrix.org``) to discuss
  with the community.
* Doc: describe the :ref:`developer-certificate-of-origin` process now applied
  on contributions.
* Doc: add :ref:`add-new-maintainer` guide
* Fix interpreter variable reset between multiple modulefile or modulerc
  evaluations when variable initial value is an invalid list. (fix issue #570)
* Fix :mfcmd:`source-sh` and :subcmd:`sh-to-mod` shell translation when used
  with new *fish* shell version (4.0).
* Doc: add :ref:`mode-select` design notes.
* Introduce ``use`` extra specifier to search for :envvar:`MODULEPATH` changes
  performed with :mfcmd:`module use<module>`, :mfcmd:`append-path` or
  :mfcmd:`prepend-path` modulefile commands on :subcmd:`avail`,
  :subcmd:`whatis` and :subcmd:`paths` sub-commands.
* Add :option:`--dumpname` option to report name of current Environment
  Modules implementation. Here it returns ``Modules``. This option is also
  available on Lmod starting version 8.7.50.
* Add the :mfcmd:`depends-on-any` modulefile command, alias over the
  :mfcmd:`prereq` command for compatibility with Lmod Tcl modulefiles.
* Add ``depends-on-any`` extra specifier to query modulefile requirement
  definitions. The extra specifier aliases ``prereq``, ``prereq-any`` or
  ``require`` may also be used to query this modulefile command.
* Introduce the :subcmd:`spider` sub-command that lists available modules
  found in enabled modulepaths and recursively found in modulepaths enabled by
  available modules. After a first step aimed at collecting all modulepaths,
  :subcmd:`spider` proceeds and reports like :subcmd:`avail` sub-command. The
  same set of options are supported.
* Introduce the :mconfig:`spider_output` and :mconfig:`spider_terse_output`
  configuration options to define the content to report in addition to the
  available module names respectively for :subcmd:`spider` sub-command regular
  and terse output modes. Excepted value for these configuration options is a
  colon separated list of elements to report. Default value is
  ``modulepath:alias:dirwsym:sym:tag:variantifspec:key`` for
  :mconfig:`spider_output` and
  ``modulepath:alias:dirwsym:sym:tag:variantifspec`` for
  :mconfig:`spider_terse_output`. These values can be changed at installation
  time respectively with the :instopt:`--with-spider-output` and
  :instopt:`--with-spider-terse-output` options. These values can then be
  superseded by using the :subcmd:`config` sub-command which sets the
  :envvar:`MODULES_SPIDER_OUTPUT` and :envvar:`MODULES_SPIDER_TERSE_OUTPUT`
  environment variables.
* Introduce the ability to control whether :subcmd:`spider` command search
  results should recursively include or not modulefiles from directories
  matching search query by use of the :option:`--indepth` and
  :option:`--no-indepth` command-line switches or :mconfig:`spider_indepth`
  configuration option (that sets :envvar:`MODULES_SPIDER_INDEPTH` environment
  variable through :subcmd:`config` command). Default value (enabled) may also
  be changed at installation time with
  :instopt:`--disable-spider-indepth<--enable-spider-indepth>` option.
* Doc: add :ref:`spider-sub-command` design notes.
* The :subcmd:`lint` sub-command now also lint any readable modulecache files
  when no modulefile specification is passed as argument or if
  :file:`.modulecache` file location is specifically passed as argument.
* Add the ``hidden`` element in the allowed value list of the
  :mconfig:`avail_output`, :mconfig:`avail_terse_output`,
  :mconfig:`list_output`, :mconfig:`list_terse_output`,
  :mconfig:`spider_output` and :mconfig:`spider_terse_output` configuration
  options. When set, it is equivalent to use :option:`--all` option: hidden
  modules are shown.
* Produce a single output for multi pattern :subcmd:`avail` search rather than
  a separate output for each submitted pattern.
* Produce a single output for multi pattern :subcmd:`whatis` search rather
  than a separate output for each submitted pattern.
* Doc: clarify that character used in version specification like *,* and *:*
  cannot be used as variant shortcut.
* Introduce :envvar:`__MODULES_LMUSE` environment variable to keep track of
  the loaded modules that enable modulepaths.
* Apply modulepath label defined with :mfcmd:`modulepath-label` also on output
  of :subcmd:`whatis` and :subcmd:`search` sub-commands.
* Report *via* information for each module entry on JSON output of
  :subcmd:`avail` and :subcmd:`spider` sub-commands. *Via* information is the
  name of the loaded or interpreted module that enables the modulepath in
  which reported modules are stored.
* Add the ``via`` element in the allowed value list of the
  :mconfig:`avail_output` and :mconfig:`spider_output` configuration options.
  When set, if a modulepath is enabled by a module, this module name is
  reported next to the modulepath name. ``via`` element is not available for
  terse output mode. ``via`` is set by default in :mconfig:`spider_output`
  configuration option.
* Add ``modules_release`` internal state. It will help to know the current
  version of Modules within :file:`siteconfig.tcl` script.
* Introduce :mfcmd:`module-help` modulefile command which defines help text to
  print when modulefile is evaluated in ``help`` mode.
* Update :mfcmd:`add-property` modulefile command to use its *value* argument
  to define tag on currently loading module.
* Doc: add :ref:`module-warn` design notes.
* Add :mfcmd:`module-warn` modulerc and modulefile command which prints a
  warning message when designated modulefile is evaluated. This command
  accepts options to emit the warning only for specific users, groups or
  times.
* Introduce the ``warning`` informational :ref:`module tag<Module tags>` on
  modulefiles targeted by :mfcmd:`module-warn` command. Update default
  :mconfig:`tag_abbrev` configuration option to add an abbreviation for the
  new tag (``W``) and default light and dark color palettes.
* Change light and dark color palettes for ``nearly-forbidden`` tag (red text
  with yellow background), to make it look closer to ``forbidden`` tag (red
  background) and distinguish it from new ``warning`` tag (black text and
  yellow background).
* No raise of *nearly-forbidden* warning when affected modulefile is evaluated
  in ``refresh`` mode.
* Issue the *nearly-forbidden* warning at the end of the affected modulefile
  evaluation, ensuring it is always reported at the same stage regardless of
  where it is defined.
* Change underlying shell code to set environment variable on *sh*, *bash*,
  *ksh*, *zsh* and *fish* shells: enclose value within single quotes rather
  escaping each special characters.
* :mfcmd:`setenv` modulefile command now supports environment variable value
  containing newline character. Exception is made for *csh* and *tcsh* shells
  where newline characters are chopped from value. (fix issue #557)
* Sort modules in JSON output as done on regular output.
* :subcmd:`cachebuild` command now sets the minimal Modules version specified
  in the cache file magic cookie header to the oldest Modules version
  compatible with this cache file, rather than the version that generated the
  cache file. Freshly generated cache files are compatible with Modules 5.3
  and above.
* Doc: improve :ref:`enable-modules-in-shells` guidelines.
* Doc: add :ref:`man-path` cookbook recipe.
* Doc: add :ref:`other-implementations` document.
* Add :subcmd:`update` sub-command, an alias of :subcmd:`reload`
* Add :subcmd:`disable` sub-command, an alias of :subcmd:`saverm`
* Add :subcmd:`describe` sub-command, an alias of :subcmd:`saveshow`
* Add ``--show_hidden`` option, an alias of :option:`--all`
* Add :mfcmd:`haveDynamicMPATH` modulefile command
* Fix ``use.own`` example modulefile to report when creating local modulefiles
  directory. (fix issue #576)
* Doc: add manual page for :ref:`envml(1)` command. (fix issue #190)
* Introduce Emacs addon files to highlight the modulefile syntax. Installation
  of these files, which is enabled by default, is controlled by the
  :instopt:`--enable-emacs-addons` and :instopt:`--emacsdatadir` configure
  options. (contribution from Laurent Besson)
* Add :mconfig:`require_via` configuration option that controls whether or not
  a requirement is considered between a module stored in a modulepath and the
  loaded module that enables this modulepath. With :ref:`Automated module
  handling mechanisms<MODULES_AUTO_HANDLING>` enabled, modules stored in a
  modulepath are unloaded or reloaded when the module enabling this modulepath
  is changed. :mconfig:`require_via` is disabled by default but everyone
  willing to hierarchically organize their modulefiles is encouraged to enable
  this new option. This option can be changed at installation time with
  :instopt:`--enable-require-via`. When :mconfig:`require_via` is changed with
  :subcmd:`config` sub-command, it sets the :envvar:`MODULES_REQUIRE_VIA`
  environment variable.
* Install: installation option :instopt:`--enable-new-features` is updated to
  include :instopt:`--enable-require-via`.
* Doc: add :ref:`require-via` design notes.
* Skip reload of a *Dependent Reload* module if it is not found after a change
  in enabled modulepaths. Reload of a not found module is attempted only if it
  is tagged *super-sticky* or *sticky* and force mode is disabled. Skipped
  module is considered *Dependent Unload* module.
* Script: update :command:`mb` tool to skip test for Modules version below 5.5
  if Tcl 9 is selected.
* Introduce the :mfcmd:`provide` modulefile command that defines module alias
  over currently evaluating module. This helps convey that the module offers
  additional functionality or components. (fix issue #539)
* Change :mfcmd:`extensions` modulefile command to be an alias over the
  :mfcmd:`provide` command.
* Add the ``provided-alias`` element in the allowed value list of the
  :mconfig:`avail_output`, :mconfig:`avail_terse_output`,
  :mconfig:`spider_output` and :mconfig:`spider_terse_output` configuration
  options. When set, module aliases are included into the output and the
  *extra match search* mechanism is activated to scan modulefiles to get the
  module aliases they define.
* Doc: add :ref:`provide` design notes.
* Introduce ``provide`` and ``provided-alias`` extra specifiers to search
  modules on :subcmd:`avail`, :subcmd:`spider`, :subcmd:`whatis` and
  :subcmd:`paths` sub-commands. ``provided-alias`` extra specifier is an alias
  onto ``provide`` and ``family`` extra specifiers.

.. _Security policy: https://github.com/envmodules/modules/blob/main/SECURITY.md
.. _Modules chat room: https://matrix.to/#/#modules:matrix.org


.. _5.5 release notes:

Modules 5.5.0 (2024-11-11)
--------------------------

* Init: update ``cmd`` shell initialization script to correctly define
  :envvar:`MODULESHOME` when installation pathname contains dot character.
  (fix issue #525 with contribution from V-clone)
* Init: add completion for :command:`ml` command on Tcsh shell. (fix issue
  #416 with contribution from Laurent Besson)
* Init: fix completion of :subcmd:`mod-to-sh`'s options on Bash and Tcsh
  shells.
* Fix modulepath file search when libtclenvmodules is disabled and modulepath
  contains glob characters.
* Lib: correct libtclenvmodules to retrieve all user groups on Darwin systems
  when user is member of more than 16 groups.
* Script: output testsuite run progress on :command:`mt` development utility.
* Resolve switched-on module prior testing stickiness preservation.
* Contrib: fix versions modulefiles generated when
  :instopt:`--enable-versioning` installation option is set. Use ``--not-req``
  option on :mfcmd:`module unload<module>` commands to avoid declaring a
  conflict toward these modules to unload. (fix issue #531)
* Add :mfcmd:`hide-modulefile` and :mfcmd:`hide-version` modulerc commands to
  support modulerc files written for Lmod.
* Update :subcmd:`autoinit` sub-command to define :command:`mogui` shell
  function or alias if `mogui-cmd` command is found in :envvar:`PATH`.
* Add the :mconfig:`hide_auto_loaded` configuration option to tag
  automatically loaded modules ``hidden-loaded``. These modules will not
  appear on :subcmd:`list` sub-command output unless :option:`--all` option is
  set. Option is disabled by default and when set, it defines the
  :envvar:`MODULES_HIDE_AUTO_LOADED` environment variable.
* Introduce the ``--modulepath`` option to the :mfcmd:`always-load`,
  :mfcmd:`depends-on`, :mfcmd:`prereq`, :mfcmd:`prereq-all` and
  :mfcmd:`prereq-any` modulefile commands. When this option is set, required
  module should be located in a path listed in the specified list or in an
  enabled modulepath matching one path of the list. This information is
  recorded in loaded environment in :envvar:`__MODULES_LMPREREQPATH` variable.
* Add :mfcmd:`lsb-release` modulefile command to get certain Linux Standard
  Base (LSB) information. It accepts to following sub-commands: ``id``,
  ``codename`` and ``release``.
* Add information logging capabilities controlled by two new configuration
  options: :mconfig:`logger` which defines the command to use to sent
  information to the log system and :mconfig:`logged_events` which controls
  the information sent to logs.
* :mconfig:`logger` configuration option relies on the :command:`logger`
  command by default. It can be changed at installation time with
  :instopt:`--with-logger` and :instopt:`--with-logger-opts` options. When
  :mconfig:`logger` is changed with :subcmd:`config` sub-command, it sets the
  :envvar:`MODULES_LOGGER` environment variable. :mconfig:`logger` can be
  declared as a locked configuration option in :mconfig:`locked_configs`.
* :mconfig:`logged_events` configuration option is a list of event names
  separated by colon character. It is empty by default, thus nothing is logged
  by default. Allowed event names are ``requested_cmd`` (log module commands
  directly executed by users), ``requested_eval`` (modulefile evaluations
  directly asked by users) and ``auto_eval`` (modulefile evaluations
  automatically triggered). Option value can be changed at installation time
  with :instopt:`--with-logged-events` option. When :mconfig:`logged_events`
  is changed with :subcmd:`config` sub-command, it sets the
  :envvar:`MODULES_LOGGED_EVENTS` environment variable.
  :mconfig:`logged_events` can be declared as a locked configuration option in
  :mconfig:`locked_configs`.
* Add ``log`` channel to the :mfcmd:`puts` modulefile command. String message
  passed to :mfcmd:`puts log<puts>` is sent to the :mconfig:`logger` command.
* Doc: update :ref:`log-module-command` cookbook recipe with integrated
  logging feature.
* Install: update :file:`configure` script to ignore all ``--with-*`` options
  if no value is associated to them.
* Install: update :file:`configure` script to set option to an empty string if
  specified with ``--without-*`` argument. Exception is made for
  :instopt:`--without-icase<--with-icase>` which sets option to the ``never``
  value.
* Introduce ``not:`` prefix for extra specifier and variant criteria on module
  search context. This prefix allows to negate search criteria on :ref:`Extra
  match search` mechanism.
* Adopt stricter naming rule for variant names. Only characters within the
  ``A-Za-z0-9_-`` range are allowed. Also, a variant name cannot start with
  ``-`` (minus) character and the overall name cannot just be a number.
* Allow ``+`` and ``~`` characters to be part of module name or version
  specification as long as the string following them is not a valid variant
  name (e.g., ``foo/1.2+8``). (fix issue #527)
* In case of an issue external to Modules, do not mention at the end of the
  error stack trace the web link to report this issue. (fix issue #546)
* When a modulefile performs a :mfcmd:`module unload<module>` command that
  fails due to dependent modules loaded, stop unload evaluation right after
  this failed command unless :option:`--force` option is used.
* Exclude sticky modules from the useless requirement unload mechanism as they
  cannot be unloaded.
* Tag automatically loaded module ``auto-loaded`` prior evaluation to be able
  to query this state during modulefile evaluation with :mfcmd:`module-info
  tags<module-info>`.
* Doc: describe in :ref:`module(1)` man page how to initialize Modules in a
  Ruby script. (fix issue #535)
* Add PowerShell Core (``pwsh``) shell support. (fix issue #326 with
  contribution from Simon Lukas Märtens)
* Lib: adapt Modules Tcl extension library to properly load on Tcl 9.
* Doc: describe how to upgrade Modules in :ref:`INSTALL`. (fix issue #544)
* Set exit code returned by :file:`modulecmd.tcl` script to ``1`` when a
  modulefile evaluation fails (modulefile does not exist, is buggy, etc).
  (fix issue #540)
* Disable pager when running :file:`modulecmd.tcl` script for script language
  (*python*, *perl*, *ruby*, *tcl*, *cmake*, *r* and *lisp*). (fix issue #542)
* Update error and warning messages when attempting to unload a module
  required by another. Distinguish if this module is a requirement of an
  already loaded or a currently loading module.
* Introduce :mconfig:`conflict_unload` configuration option that controls
  whether or not conflicting modules and their dependent should be unloaded
  when loading a module. All kind of conflicts are supported: conflicts
  defined by already loaded modules, conflict declared by loading module
  through :mfcmd:`conflict`, :mfcmd:`family` or :mfcmd:`module unload<module>`
  commands. :mconfig:`conflict_unload` also handles the unload of a module
  that is loaded again but with different variant values or from a different
  modulepath. :mconfig:`conflict_unload` is disabled by default as it changes
  behaviors of the :envvar:`automated module handling
  mode<MODULES_AUTO_HANDLING>`. But everyone is encouraged to enable this new
  option to benefit from an highly automated experience. This option can be
  changed at installation time with :instopt:`--enable-conflict-unload`. When
  :mconfig:`conflict_unload` is changed with :subcmd:`config` sub-command, it
  sets the :envvar:`MODULES_CONFLICT_UNLOAD` environment variable. Both
  :mconfig:`auto_handling` and :mconfig:`conflict_unload` options should be
  enabled to activate *Conflict Unload* automated behavior. (fix issue #242)
* When both :mconfig:`auto_handling` and :mconfig:`conflict_unload` options
  are enabled, all loaded modules matching module specifications set on
  :mfcmd:`conflict` or :mfcmd:`module unload<module>` commands are unloaded.
  If both options are not enabled, only one matching loaded module per
  specification argument of :mfcmd:`module unload<module>` is unloaded. (fix
  issue #215)
* When both :mconfig:`auto_handling` and :mconfig:`conflict_unload` options
  are enabled, :option:`--force` option set on :subcmd:`load` sub-command is
  taken into account during the *Conflict Unload* mechanism. For instance, it
  continues this unload process even if one module unload fails.
* Install: installation option :instopt:`--enable-new-features` is updated to
  include :instopt:`--enable-conflict-unload`.
* Fix detection of already loaded module with variant set. If trying to load
  same module with compatible variant set, a *module is already loaded*
  message is now returned instead of *another variant is loaded*.
* Correctly report module evaluation error in case during the same execution
  this module was already evaluated and failed silently during a *Requirement
  Load* mechanism.
* Split processing of *Dependent Reload* (DepRe) modules to treat the *DepRe*
  modules consequence of *Useless Requirement Unload* (UReqUn) modules
  separately, right before unloading the *UReqUn* modules. As a result,
  modules in conflict with *UReqUn* modules are unloaded right before *UReqUn*
  process and reloaded with the other *DepRe* modules.
* Handle *UReqUn* process in case of :subcmd:`switch` sub-command after the
  switch load phase. Unload of these modules were previously occurring at the
  end of the switch unload phase. Unload of *DepRe* modules consequence of
  *UReqUn* modules is also moved after switch load phase.
* Introduce the *Useless Requirement Unload* (UReqUn) process on
  :subcmd:`load` sub-command. It eliminates auto loaded modules that were
  requirements of *Conflict Unload* modules. In case of :subcmd:`switch`
  sub-command, *UReqUn* modules coming from the switch load phase are handled
  with *UReqUn* modules coming from switch unload phase.
* Rework handling of *DepRe* modules that also are *UReqUn* modules to unload
  them during the *DepRe* unload phase instead of during *UReqUn* process. As
  a consequence these modules part of both *DepRe* and *UReqUn* lists are
  unloaded prior main module action and prior unload of the other *UReqUn*
  modules. The *DepRe* modules may be also qualified *UReqUn* even if they are
  not a dependency of a module unloaded in the current processing.
* Mix unload of *Dependent Unload* and *Dependent Reload* modules to ensure
  they are processed in their reverse loading order. As a result, if a module
  is part of *DepUn* process and some of its requirements are part of *DepRe*
  process, requirements are unloaded after their dependent modules.
* Skip reload of a *Dependent Reload* module if found not loadable (either its
  requirements are not loaded or a conflict is spotted with loaded
  environment). Reload is attempted only if module is tagged *super-sticky* or
  *sticky* and force mode is disabled. Skipped module is considered *Dependent
  Unload* module.
* Reload all Dependent Reload modules after the main load, unload or switch
  module evaluation rather after the sub module evaluation that triggered the
  Dependent Reload unload phase.
* Dependent Unload modules of Conflict Unload modules are merged into the
  Dependent Reload module list. An attempt to reload these dependent modules
  is tried only if their requirements are satisfied by loaded environment.
* When a loading module requires a Dependent Unload module, the unload of this
  module was forced when it was triggered by a Conflict Unload or a
  switched-off module. The unload of such Dependent Unload module is not
  forced anymore by default and an error is raised if a loading module
  requiring the Dependent Unload module is detected.
* When unloading Dependent Reload modules, do not force by default this unload
  unless asked with :option:`--force` option. As a result an error is obtained
  when trying to reload Dependent Reload modules that conflict with other
  loaded modules. This error may be by-passed with :option:`--force`
  command-line option.
* Move stickiness check when unloading a module prior processing any automated
  module handling mechanism. (fix issue #536)

.. warning:: Variant names are now fully checked instead of just verifying
   their first character. Only characters within the ``A-Za-z0-9_-`` range are
   allowed. Variant name cannot start with ``-`` character and the overall
   name cannot just be a number.

.. warning:: Existing *versions* modulefiles generated by
   :instopt:`--enable-versioning` installation option and installed for
   Modules 4.7 and upward should be manually fixed by adding the ``--not-req``
   option to the :mfcmd:`module unload<module>` commands present in these
   modulefiles. Following command should fix these files: ``sed -i "s|module
   unload|module unload --not-req|" <version_modulefile>``.


.. _5.4 release notes:

Modules 5.4.0 (2024-02-20)
--------------------------

* Allow to designate module by its full path file name on :mfcmd:`module-tag`,
  :mfcmd:`module-hide` and :mfcmd:`module-forbid`. (fix issue #485)
* Introduce ``tag`` extra specifier to search modules on :subcmd:`avail`,
  :subcmd:`whatis` and :subcmd:`paths` sub-commands based on tags applied.
  Tag abbreviation may also be used as extra specifier name.
* Add ability to specify multiple names on one extra specifier criterion to
  select modules matching any of these names (e.g.,
  ``env:PATH,LD_LIBRARY_PATH``)
* Add ability to specify multiple values on one variant criterion to select
  modules providing any of these variant values (e.g., ``foo=val1,val2``)
* Add the ``indesym`` element in the allowed value list of the
  :mconfig:`list_output` and :mconfig:`list_terse_output` configuration
  options. When set, symbolic versions are reported as independent elements
  rather along the loaded module they are attached to.
* Add the ``alias`` element in the allowed value list of the
  :mconfig:`list_output` and :mconfig:`list_terse_output` configuration
  options. When set, module aliases targeting loaded modules are reported.
* Introduce :mconfig:`sticky_purge` configuration option to define behavior
  when unloading sticky or super-sticky module during a :subcmd:`purge`
  command. Raise an ``error`` (default) or emit a ``warning`` or be
  ``silent``. When set, it defines the :envvar:`MODULES_STICKY_PURGE`
  environment variable. Default value can be changed with
  :instopt:`--with-sticky-purge` installation option. (fix issue #502)
* Introduce :mfcmd:`modulepath-label` modulerc command, which defines label
  used instead of modulepath directory path in :subcmd:`avail` output.
* More than one global rc file can now be specified in :envvar:`MODULERCFILE`
  or via :mconfig:`rcfile` configuration option.
* Add the :mconfig:`unique_name_loaded` configuration option to allow, when
  enabled, only one module loaded per module name. When set, it defines the
  :envvar:`MODULES_UNIQUE_NAME_LOADED` environment variable. Default value
  (disabled) can be changed with :instopt:`--enable-unique-name-loaded`
  installation option.
* Add :ref:`evaluation-errors` design notes.
* Add :mconfig:`abort_on_error` configuration option to define module
  sub-commands that should abort when a module evaluation fails instead of
  continuing their evaluation sequence. When configuration option is set, it
  defines the :envvar:`MODULES_ABORT_ON_ERROR` environment variable. Default
  value can be changed with :instopt:`--with-abort-on-error` installation
  option.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :subcmd:`load`, :subcmd:`mod-to-sh` and :subcmd:`try-load` sub-commands.
* Report issue on modulefile when it fails to load an erroneous requirement
  through :mfcmd:`module try-load<module>` modulefile command.
* Doc/Install: modernize modulefile code example in documentation and
  installed example modulefiles.
* Vim: correctly highlight modulefile commands containing a dash character.
* Update requirement load error report to place it only under the message
  block of the module requiring this load. This change helps to better
  understand the chronology of actions and from where an error occurs.
* Do not report requirement load error when an alternative requirement module
  is found and loaded afterward. (fix issue #509)
* Do not render an error exit code on multi-module option requirement when
  one module option fails to load but another does. (fix issue #510)
* Do not report *module not found* error when loading a requirement if an
  alternative requirement module is found and loaded afterward. (fix issue
  #511)
* Add ``--glob`` option to :mfcmd:`remove-path` modulefile command in order to
  remove any values in variable matching a glob-style pattern.
* Record module specification on which loaded module stickiness applies in
  :envvar:`__MODULES_LMSTICKYRULE` environment variable. It helps to determine
  if stickiness is satisfied when changing loaded modules. Which was not
  working correctly for virtual modules. (fix issue #506)
* Silently ignore cache file when it requires a greater Modules version. (fix
  issue #515)
* Doc: move :ref:`modulefile(5)` man page in section 5. (fix issue #518 with
  contribution from Laurent Chardon)
* Add :mconfig:`source_cache` configuration option to cache files evaluated in
  modulefiles with ``source`` Tcl command. Files sourced multiple times are
  only read once when option is enabled. :mconfig:`source_cache` is disabled
  by default. When set, it defines the :envvar:`MODULES_SOURCE_CACHE`
  environment variable. Default value can be changed with
  :instopt:`--enable-source-cache` installation option.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :subcmd:`unload` sub-command.
* A modulefile is unloaded anyway even if an evaluation error occurs when
  :option:`--force` option is used on :command:`ml`, :subcmd:`purge`,
  :subcmd:`reload`, :subcmd:`reset`, :subcmd:`restore`, :subcmd:`stash`,
  :subcmd:`stashpop`, :subcmd:`switch` and :subcmd:`unload` sub-commands. To
  forbid the unload of a modulefile it is recommended to tag it
  ``super-sticky`` with :mfcmd:`module-tag` command.
* Disable :mconfig:`abort_on_error` when :option:`--force` option is used. In
  this case, behavior is to continue when an error occurs.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :command:`ml` command. *Abort on error* behavior is on by default with
  :command:`ml`. Removing it from :mconfig:`abort_on_error`'s value enables
  the *continue on error* behavior.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :subcmd:`reload` command. *Abort on error* behavior is on by default with
  :subcmd:`reload`. Removing it from :mconfig:`abort_on_error`'s value enables
  the *continue on error* behavior.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :subcmd:`purge` sub-command.
* Add support for :mconfig:`abort_on_error` evaluation behavior on unload
  phase of :subcmd:`switch` command. *Abort on error* behavior is on by
  default there. Removing ``switch_unload`` from :mconfig:`abort_on_error`'s
  value enables the *continue on error* behavior.
* Add support for :mconfig:`abort_on_error` evaluation behavior on
  :subcmd:`switch` command. *Abort on error* behavior is applied if ``switch``
  value is set in :mconfig:`abort_on_error` and either switch unload or switch
  load phase fails.
* Install: installation option :instopt:`--enable-new-features` is updated to
  enable *abort on error* behavior on :subcmd:`load` and :subcmd:`switch`
  sub-commands.
* Lib: slightly adapt code of Modules Tcl extension library to properly build
  against Tcl 9.0.
* Adapt alias unset shell code for *sh*-kind shells to avoid errors when alias
  to unset is not defined.
* Adapt function unset shell code for *sh*-kind shells to avoid errors when
  function to unset is not defined.
* No output of *unload of switched-off failed* and *load of switched-on
  failed* error messages when :mfcmd:`module switch<module>` command is run
  from a modulefile.
* No *Switching* block message report when :mfcmd:`module switch<module>`
  command is run from a modulefile.
* Report all error and warning messages locally under *Loading* or *Unloading*
  block message rather reporting some of them under the block message of the
  main action. These errors and warnings are thus reported where they occur.
* Report switched-on load failure as error rather warning.
* Report switched-on module locating or access issues only once.
* Report conflict error message when it occurs rather than after modulefile
  evaluation.
* Update conflict error message to report all conflicting modules name and
  version rather conflict module specification.
* Fix conflict error check to avoid reporting both *unloading conflict failed*
  and *conflict is loading* messages.
* Raise an error and stop modulefile evaluation when :mfcmd:`module
  switch<module>` command fails unless if :option:`--force` option is set.
* When a *useless requirement unload* fails, do not increase error count as
  this failure is reported as a warning and main unload process is not
  affected.
* Path element equals to delimiter character is allowed on
  :mfcmd:`append-path` and :mfcmd:`prepend-path` modulefile commands. (fix
  issue #522)
* Add ``bash-eval`` shell mode to :mfcmd:`source-sh` modulefile command and
  :subcmd:`sh-to-mod` sub-command. With this mode, the generated output of the
  bash shell script is evaluated to get the environment changes instead of
  sourcing this script. (fix issue #519)
* Add ``--ignore`` option to :mfcmd:`source-sh` modulefile command to define
  shell elements changed by shell script that should be ignored. (fix issue
  #503)
* Init: Improve Tcsh shell completion script to complete against existing
  files when pattern starts with ``/``, ``.`` or ``~/``. (fix issue #523)
* Add ``--user`` option to :mfcmd:`module-forbid`, :mfcmd:`module-hide` and
  :mfcmd:`module-tag` modulefile commands to forbid, hide or tag only if user
  is listed in the value of this new option. (fix issue #520 with contribution
  from Jérémy Déchard)
* Add ``--group`` option to :mfcmd:`module-forbid`, :mfcmd:`module-hide` and
  :mfcmd:`module-tag` modulefile commands to forbid, hide or tag only if one
  user's group is listed in the value of this new option. (fix issue #520 with
  contribution from Jérémy Déchard)


.. _5.3 release notes:

Modules 5.3.1 (2023-06-27)
--------------------------

* Fix additional `ShellCheck`_ warning reports over sh and bash shell scripts.
* Install: distribute ``ChangeLog`` as a zipped file to reduce installation
  size. As a consequence, :command:`gzip` becomes a requirement when building
  Modules from git repository.
* Install: adapt RPM spec file to install module initialization script for
  fish as configuration snippet for this shell.
* Fix extra specifier search to evaluate module matching requirement query.
  (fix issue #494)
* Fix extra specifier requirement search when module searched is also defining
  a requirement and is the sole module to define it. (fix issue #495)
* Script: update :command:`pre-commit` and :command:`commit-msg` git hook
  scripts to use `Hunspell`_ as spell checker instead of Aspell.
* Fix unaligned :subcmd:`list` output when 100 or more modules are loaded.
  (fix issue #496)
* Fix extra specifier search when an identical module name and version is
  available in several modulepaths. (fix issue #497)
* Do not match module commands with :mfcmd:`--not-req<module>` option set on
  ``require`` or ``incompat`` extra specifier queries. (fix issue #498)
* When one variant is specified multiple times on search context
  (:subcmd:`avail`, :subcmd:`paths` or :subcmd:`whatis` sub-commands),
  available modules returned are those providing all variant values set. (fix
  issue #499)
* Add the ``indesym`` element in the allowed value list of the
  :mconfig:`avail_output` and :mconfig:`avail_terse_output` configuration
  options. When set, symbolic versions are reported as independent elements
  rather along the module or directory they are attached to.
* Init: fix completion scripts to report module symbolic versions and aliases
  among available modules. (fix issue #500)

.. _Hunspell: https://hunspell.github.io/


Modules 5.3.0 (2023-05-14)
--------------------------

* Add :ref:`module-cache` design notes.
* Add :subcmd:`cachebuild` sub-command to create cache for modulepaths
  enabled or specified on the command line. Cache files are named
  ``.modulecache`` and stored at the root of modulepath directories.
* Add :subcmd:`cacheclear` sub-command to delete cache file in all enabled
  modulepaths.
* Use cache file if available rather search the content of modulepath
  directories when searching for modules (e.g., during :subcmd:`avail`,
  :subcmd:`load`, :subcmd:`display`, etc).
* Script: add cache-enabled version of *avail*, *whatis* and *load* tests on
  :command:`mb` benchmark utility.
* Add the :mconfig:`ignore_cache` configuration option to ignore module cache
  file. Option is disabled by default and when set, it defines
  :envvar:`MODULES_IGNORE_CACHE` environment variable.
* Add :option:`--ignore-cache` command-line switch to enable
  :mconfig:`ignore_cache` configuration option and ignore module cache file
  for current execution.
* Add :mconfig:`cache_buffer_bytes` configuration option to define buffer size
  when reading or writing cache files. Option is set to ``32768`` by default.
  When set it defines :envvar:`MODULES_CACHE_BUFFER_BYTES` environment
  variable.
* Add :mconfig:`cache_expiry_secs` configuration option that defines the
  number of seconds a cache file is considered valid after being generated.
  Option is set to ``0`` by default which means cache files never expire. When
  option is set it defines :envvar:`MODULES_CACHE_EXPIRY_SECS` environment
  variable.
* Modulefiles and directories that are not accessible by everyone are not
  recorded in cache file. A *limited access* directive is recorded instead to
  indicate these modulefiles have to be tested and directories have to be
  walked down to determine what the running user can access.
* Doc: update :ref:`reduce-io-load` cookbook recipe with module cache
  description.
* Correctly apply extra tag set when loading a module whose variant has value
  automatically set. (fix issue #484)
* Catch collection directory creation error and report appropriate message.
  (fix issue #482)
* Fix :mfcmd:`source-sh` and :subcmd:`sh-to-mod` shell alias translation when
  used with new *fish* shell version (3.6).
* Install: allow to build Modules from a short-depth git repository. (fix
  issue #486)
* Install: ensure git log format is not influenced by user's configuration in
  :command:`gitlog2changelog.py`. (fix issue #487)
* Init: fix bash shell completion script to be able to complete full name of
  available modules. (fix issue #490)
* Install: move license name to SPDX format in RPM spec file.
* Doc: add :ref:`extra-match-search` design notes.
* Introduce *extra match search* mechanism that evaluates available
  modulefiles during a module search to find those matching an extra query
  on a variant value, a dependency or an environment variable definition.
  During this specific evaluation, modulefiles are interpreted in *scan*
  mode.
* ``scan`` string is returned by :mfcmd:`module-info mode<module-info>` when
  queried during a *scan* modulefile evaluation.
* Add the ``variant`` element in the allowed value list of the
  :mconfig:`avail_output` and :mconfig:`avail_terse_output` configuration
  options. When set, variants and their possible values are reported along the
  module they are associated to on :subcmd:`avail` command output. Adding
  variant information to this output activates the *extra match search*
  mechanism that scan modulefiles to find variants they define. (fix issue
  #407)
* Apply graphic rendition of default version (``de`` SGR key) to default
  variant value on either :subcmd:`list` and :subcmd:`avail` command output.
* Apply either loaded or auto-loaded graphic rendition to the loaded variant
  value on :subcmd:`avail` command output.
* Update :subcmd:`avail`, :subcmd:`paths` and :subcmd:`whatis` sub-commands to
  take into account variant set in module specification. Available modules are
  filtered with *extra match search* mechanism to only return those matching
  the variant specification.
* Update :subcmd:`avail`, :subcmd:`paths` and :subcmd:`whatis` sub-commands to
  accept module specification with just a variant set (no module name and
  version). Available modules are filtered with *extra match search* mechanism
  to only return those matching the variant specification.
* Update :subcmd:`list` sub-command to accept module specification with just a
  variant set (no module name and version). Loaded modules are filtered to
  only return those matching the variant specification.
* Highlight searched variant name and value (``hi`` SGR key) on either
  :subcmd:`list` and :subcmd:`avail` command output.
* Doc: add :ref:`Extra match search` description in :ref:`module(1)` man page.
* Introduce *extra specifiers* to query content of modulefiles. *Extra
  specifiers* can be specified with *element:name* syntax as part of module
  specification on module search commands (:subcmd:`avail`, :subcmd:`paths`
  and :subcmd:`whatis`). For instance with the ``module avail
  append-path:PATH`` command, all modulefiles defining the ``append-path``
  command on ``PATH`` environment variable are returned.
* Add ``variant`` extra specifier to query modulefile variant definitions.
  (fix issue #408)
* Add ``setenv``, ``unsetenv``, ``append-path``, ``prepend-path``,
  ``remove-path`` and ``pushenv`` extra specifiers to query modulefile
  environment variable definitions. The extra specifier alias ``envvar`` may
  also be used to query any of these modulefile commands.
* Add ``complete`` and ``uncomplete`` extra specifiers to query modulefile
  shell completion definitions.
* Add ``set-alias`` and ``unset-alias`` extra specifiers to query modulefile
  shell alias definitions.
* Add ``set-function`` and ``unset-function`` extra specifiers to query
  modulefile shell function definitions.
* Add ``chdir`` extra specifier to query modulefile current working directory
  change definitions.
* Add ``family`` extra specifier to query modulefile family definitions.
* Add ``prereq``, ``prereq-any``, ``prereq-all``, ``depends-on``,
  ``always-load``, ``load``, ``load-any``, ``try-load``, ``switch`` and
  ``switch-on`` extra specifiers to query modulefile requirement definitions.
  The extra specifier alias ``require`` may also be used to query any of these
  modulefile commands.
* Add ``conflict``, ``unload``, ``switch`` and ``switch-off`` extra specifiers
  to query modulefile incompatibility definitions. The extra specifier alias
  ``incompat`` may also be used to query any of these modulefile commands.
* Requirement and incompatibility extra specifiers accept module specification
  as value.
* Doc: add :ref:`Extra specifier` description in :ref:`module(1)` man page.
* Mark loaded modules as qualified for refresh evaluation when they send
  content to ``stdout`` or ``prestdout`` channels with :mfcmd:`puts`
  modulefile command. (fix issue #488)
* Add the :mconfig:`ignore_user_rc` configuration option to skip evaluation of
  user-specific module rc file. Option is disabled by default and when set, it
  defines :envvar:`MODULES_IGNORE_USER_RC` environment variable.
* Add :option:`--ignore-user-rc` command-line switch to enable
  :mconfig:`ignore_user_rc` configuration option and ignore user-specific
  module rc file for current execution.
* Add the ``variantifspec`` element in the allowed value list of the
  :mconfig:`avail_output` and :mconfig:`avail_terse_output` configuration
  options. Set this new element in the default value list of both options.
  When set and if a variant is specified in search query, variants and their
  possible values are reported along the module they are associated to on
  :subcmd:`avail` command output.
* Accept value starting with ``+`` or ``-`` characters on
  :option:`--output`/:option:`-o` command-line switches to indicate value
  should respectively be appended to or subtracted from current configuration
  option value.
* Accept value starting with ``+`` or ``-`` characters on
  :mconfig:`avail_output`, :mconfig:`avail_terse_output`,
  :mconfig:`list_output`, :mconfig:`list_terse_output`, :mconfig:`colors`,
  :mconfig:`protected_envvars`, :mconfig:`shells_with_ksh_fpath`,
  :mconfig:`tag_abbrev`, :mconfig:`tag_color_name`,
  :mconfig:`variant_shortcut` configuration options to indicate value
  should respectively be appended to or subtracted from current configuration
  option value.
* Fix :subcmd:`switch` sub-command not to unload *sticky* module when
  switched-on module does not exist. (fix issue #492)


.. _5.2 release notes:

Modules 5.2.0 (2022-11-08)
--------------------------

* Introduce the ``--optional`` option on :mfcmd:`prereq`, :mfcmd:`prereq-all`,
  :mfcmd:`depends-on` and :mfcmd:`always-load` modulefile commands. Expressed
  optional dependency is considered satisfied even if modulefile is not
  loaded. If optional requirement is loaded afterward, dependent module is
  automatically reloaded, unless if the :mconfig:`auto_handling` configuration
  option is disabled.
* A dependency expressed in modulefile with :mfcmd:`module try-load<module>`
  command is considered optional. Dependent module is automatically reloaded
  if the optional requirement is loaded afterward, unless if the
  :mconfig:`auto_handling` configuration option is disabled.
* Raise error in case of unknown or misplaced option set on :mfcmd:`prereq`,
  :mfcmd:`prereq-all`, :mfcmd:`depends-on` or :mfcmd:`always-load` modulefile
  commands.
* Add the :option:`--timer` command-line switch to report the total execution
  time of the :command:`module` command. Also report the execution time of
  every internal procedure calls when mixed with :option:`--debug` option.
* Init: move :envvar:`PATH` setup (to locate Modules' binaries location) from
  shell initialization scripts to the :subcmd:`autoinit` sub-command. (fix
  issue #462)
* Init: move :envvar:`MANPATH` setup (to locate Modules' man-pages) from
  shell initialization scripts to the :subcmd:`autoinit` sub-command. (fix
  issue #462)
* Init: move shell completion setup from shell initialization scripts to the
  :subcmd:`autoinit` sub-command. (fix issue #462)
* Enclose installation path references in shell code produced by
  :subcmd:`autoinit`, in initialization scripts and Makefiles to guaranty
  correct evaluation in case these paths contain a space character. Note that
  the quarantine mechanism is not compatible with such installation paths.
* Fix :mfcmd:`source-sh` and :subcmd:`sh-to-mod` when used with *fish* shell
  script if ``regex-easyesc`` fish option is enabled. (fix issue #463)
* Add the :mconfig:`protected_envvars` configuration option to define a list
  of environment variables that cannot be modified by modulefile commands.
  When set, :mconfig:`protected_envvars` defines
  :envvar:`MODULES_PROTECTED_ENVVARS` environment variable. (fix issue #429
  with contribution from Adrien Cotte)
* Introduce the :subcmd:`lint` sub-command to statically analyze syntax of
  modulefiles, modulerc and global/user rc. (fix issue #451)
* Add the :mconfig:`tcl_linter` configuration option to define the program
  used to analyze files with :subcmd:`lint` sub-command. This option is set to
  ``nagelfar.tcl`` by default. When changed from default value, the
  :envvar:`MODULES_TCL_LINTER` environment variable is defined. Default value
  can be changed with :instopt:`--with-tcl-linter` and
  :instopt:`--with-tcl-linter-opts` installation options.
* Add the :instopt:`--enable-nagelfar-addons` installation option (enabled by
  default) to install specific syntax databases and plugins to lint
  modulefiles, modulerc and global/user rc with `Nagelfar`_. These files are
  installed in the directory designated by the :instopt:`--nagelfardatadir`
  (``DATAROOTDIR/nagelfar`` by default).
* Doc: add :ref:`lint-sub-command` design notes.
* Install: use :command:`install` command rather :command:`cp` or
  :command:`mkdir` to install Modules and guaranty consistent permission modes
  on deployed files.
* Also unset :mfcmd:`pushenv` value stacks on :subcmd:`clear` sub-command.
* Doc: add :ref:`mod-to-sh-sub-command` design notes.
* Introduce the :subcmd:`mod-to-sh` sub-command to translate designated
  modulefile(s) into code for specified shell. (fix issue #447)
* Make :subcmd:`source` sub-command accepts modulefile specification as
  argument. If argument does not correspond to a file path, search it among
  available modulefiles. (fix issue #424)
* Doc: clarify :mfcmd:`set-alias` only define shell alias and not shell
  function.
* Add the ability to filter the list of collections returned by
  :subcmd:`savelist` sub-command. Filtering pattern is matched in a case
  insensitive manner by default.
* Add support for :option:`--starts-with` and :option:`--contains` options on
  :subcmd:`savelist` sub-command.
* Highlight all search patterns on :subcmd:`list` sub-command output instead
  of only the first one..
* Highlight all search patterns on :subcmd:`savelist` sub-command output.
* Add support for :option:`--all` option on :subcmd:`savelist` sub-command not
  to limit result to the collection matching currently defined
  :mconfig:`collection_target`.
* Doc: add :ref:`Shell support` section in :ref:`modulefile(5)` man page to
  describe how shells support the different kind of environment changes that
  can be defined in modulefiles.
* Record during :subcmd:`autoinit` sub-command the initial environment state
  in :envvar:`__MODULES_LMINIT`. Enabled modulepaths and loaded modulefiles
  through :file:`modulespath` and :file:`initrc` initialization configuration
  files are recorded in this new environment variable.
* Add :subcmd:`reset` sub-command to restore initial environment. It takes
  recorded environment in :envvar:`__MODULES_LMINIT` and restores it.
* Initial environment is restored when collection name specified on
  :subcmd:`restore` sub-command equals ``__init__``.
* When no argument is provided to :subcmd:`restore` sub-command and if
  *default* collection does not exist, initial environment is restored.
* Initial environment content is displayed when collection name specified on
  :subcmd:`saveshow` sub-command equals ``__init__``.
* When no argument is provided to :subcmd:`saveshow` sub-command and if
  *default* collection does not exist, initial environment content is
  displayed.
* Add :mconfig:`reset_target_state` configuration option to determine behavior
  of :subcmd:`reset` sub-command. When set to ``__init__`` (default value)
  initial environment is restored. When set to ``__purge__``, a
  :subcmd:`purge` sub-command is performed. Any other value, corresponds to
  the name of a collection to :subcmd:`restore`. When set,
  :mconfig:`reset_target_state` defines :envvar:`MODULES_RESET_TARGET_STATE`
  environment variable.
* Doc: add :ref:`initial-environment` design notes.
* Unload *sticky* modules on :subcmd:`restore` and :subcmd:`reset`
  sub-commands to fully set environment in collection or initial state.
* Testsuite: add *lint* testsuite to validate syntax of shell and Tcl scripts
  of this project. This testsuite can be invoked with ``make testlint`` or
  ``script/mt lint``. sh, bash and ksh scripts are checked with `ShellCheck`_
  tool and tcl scripts are checked with `Nagelfar`_.
* Update :file:`modulecmd.tcl` code and add Nagelfar inline comments to fix
  linter reports.
* Script: add usage message and support for ``-h``/``--help`` option on
  :command:`mrel`, :command:`mpub`, :command:`mt`, :command:`mtreview`,
  :command:`nglfar2ccov`, :command:`mb` and :command:`mlprof` development
  utilities.
* Doc: describe :command:`script/mt` and :command:`script/mb` utilities in
  :ref:`CONTRIBUTING` guide.
* Fix `ShellCheck`_ error, warning and info reports over all sh, bash and ksh
  shell scripts. (fix issue #470 with contribution from Lukáš Zaoral)
* Init: update profile script for sh-like shells to only source sh or bash
  initialization script when BASH environment variable is found set. (fix
  issue #473)
* Add :subcmd:`stash` sub-command to save current environment and restore
  initial one.
* Add :subcmd:`stashpop` sub-command to restore stash collection then delete
  this collection file.
* Add :subcmd:`stashrm` sub-command to delete stash collection file.
* Add :subcmd:`stashshow` sub-command to display stash collection file.
* Add :subcmd:`stashclear` sub-command to delete all stash collection files.
* Add :subcmd:`stashlist` sub-command to list all stash collection files.
* Update :subcmd:`savelist` sub-command to filter out stash collections unless
  if :option:`--all` option is set.
* Doc: ensure current user environment does not break logging system in
  :ref:`log-module-command` recipe. (fix issue #475)
* Rename the default git branch from *master* to *main* to use inclusive
  terminology.
* Mark loaded modules that could benefit from a refresh evaluation in the
  :envvar:`__MODULES_LMREFRESH` environment variable.
* Optimize :subcmd:`refresh` sub-command to only evaluate loaded modules that
  defines volatile environment changes (shell completion, alias or function).
  (fix issue #477)
* Add :sitevar:`modulefile_extra_cmds` hook variable that could be defined in
  :file:`siteconfig.tcl` file to define specific commands in modulefile
  interpreter context. :sitevar:`modulefile_extra_cmds` is a list of command
  name and relative procedure pairs. (fix issue #286)
* Add :sitevar:`modulefile_extra_vars` hook variable that could be defined in
  :file:`siteconfig.tcl` file to define specific variables in modulefile
  interpreter context. :sitevar:`modulefile_extra_vars` is a list of variable
  name and value pairs. (fix issue #286)
* Add :sitevar:`modulerc_extra_cmds` hook variable that could be defined in
  :file:`siteconfig.tcl` file to define specific commands in modulerc
  interpreter context. :sitevar:`modulerc_extra_cmds` is a list of command
  name and relative procedure pairs. (fix issue #286)
* Add :sitevar:`modulerc_extra_vars` hook variable that could be defined in
  :file:`siteconfig.tcl` file to define specific variables in modulerc
  interpreter context. :sitevar:`modulerc_extra_vars` is a list of variable
  name and value pairs. (fix issue #286)
* Doc: Add :ref:`Site-specific configuration` section in :ref:`module(1)` man
  page.
* Doc: extend :ref:`Collections` section with examples in :ref:`module(1)` man
  page.

.. _Nagelfar: http://nagelfar.sourceforge.net/
.. _ShellCheck: https://www.shellcheck.net/


.. _5.1 release notes:

Modules 5.1.1 (2022-05-31)
--------------------------

* Install: add :command:`rpmlint` rc configuration file to filter false
  positive warning messages.
* Install: better guess ``libdir64`` and ``libdir32`` directory locations
  when ``libdir`` does not end with *64* but contains *64*.
* Install: update RPM spec file to move libtclenvmodules in an
  environment-modules directory under ``libdir``.
* Fix rendering of loading or unloading module designation when configured
  color palette does not set the ``hi`` color key. (fix issue #455)
* Remove the *already loaded* message displayed when verbosity level is higher
  or equal to ``verbose2`` if new tags are applied to the loaded module. (fix
  issue #456)
* Report a global known error when current working directory cannot be
  retrieved due to the removal of this directory. (fix issue #457)
* Update tags set through :mfcmd:`prereq` command on all already loaded
  requirements. (fix issue #459)
* Update module designation with the tags set by reloading dependent module.
  (fix issue #460)
* Install: include the ``lib/config.guess`` and ``lib/config.sub`` scripts in
  distribution tarball if generated by :command:`autoreconf`.
* Install: call ``git`` command in ``Makefile`` only if the definitions of
  ``version.inc`` need to get built or refreshed.


Modules 5.1.0 (2022-04-30)
--------------------------

* Allow to declare :mfcmd:`variant` with no list of accepted value. Such
  variant accepts any value specified. (fix issue #405)
* Add the :mconfig:`redirect_output` configuration option to control on *sh*,
  *bash*, *ksh*, *zsh* and *fish* shells whether or not the output of the
  :command:`module` function should be redirected from stderr to stdout. When
  set, :mconfig:`redirect_output` defines :envvar:`MODULES_REDIRECT_OUTPUT`
  environment variable.
* Introduce the :option:`--redirect`/:option:`--no-redirect` command-line
  switches to supersede the value of the :mconfig:`redirect_output`
  configuration option on *sh*, *bash*, *ksh*, *zsh* and *fish* shells. (fix
  issue #410)
* Add the ``--return-value`` option to the :mfcmd:`getenv` and
  :mfcmd:`getvariant` modulefile commands to force to return the value of
  respectively designated environment variable or variant when modulefile is
  evaluated in *display* mode. (fix issue #422)
* Introduce the :subcmd:`state` sub-command to display Modules states.
* Add the ``supported_shells`` state to get the list of the shells that are
  supported by :file:`modulecmd.tcl` through the :subcmd:`state` sub-command .
  (fix issue #426)
* Filter out the variables intended for Modules private usage when processing
  the environment changes made by a script evaluated by :subcmd:`sh-to-mod`
  sub-command or :mfcmd:`source-sh` modulefile command. (fix issue #427)
* Doc: add :ref:`control-mode-behaviors` design notes.
* Doc: add :ref:`add-new-config-option` design notes.
* Set a `Code of conduct`_ for the project and its community based on the
  widely adopted Contributor Covenant.
* Doc: add :ref:`add-new-sub-command` design notes.
* Add the ``--remove-on-unload`` option to the :mfcmd:`remove-path` to also
  remove value when modulefile is unloaded.
* Raise error when an unknown option is set on :mfcmd:`module use<module>` or
  :mfcmd:`module unuse<module>` modulefile command.
* Rework emitted debug messages to remove obvious ones and systematically
  report each modulefile command processed with their arguments.
* Add the ``--append-on-unload`` option to the :mfcmd:`remove-path` and
  :mfcmd:`module unuse<module>` modulefile commands to append back when
  modulefile is unloaded the value removed at load time or a specific value
  set after this option.
* Add the ``--prepend-on-unload`` option to the :mfcmd:`remove-path` and
  :mfcmd:`module unuse<module>` modulefile commands to prepend back when
  modulefile is unloaded the value removed at load time or a specific value
  set after this option.
* Add the ``--noop-on-unload`` option to the :mfcmd:`unsetenv`,
  :mfcmd:`remove-path` and :mfcmd:`module unuse<module>` modulefile commands
  to perform no operation when modulefile is unloaded.
* Add the ``--unset-on-unload`` option to the :mfcmd:`unsetenv` modulefile
  command to also unset environment variable when modulefile is unloaded.
* Add the ``--set-if-undef`` option to the :mfcmd:`setenv` modulefile command
  to set environment variable when modulefile is loaded only this variable is
  not yet defined.
* Install: add the :instopt:`--with-bashcompletiondir`,
  :instopt:`--with-fishcompletiondir` and :instopt:`--with-zshcompletiondir`
  installation options to install shell completion scripts in their
  system-wide location. (fix issue #428)
* Doc: add :ref:`lmod-tcl-modulefile-compat` design notes.
* Introduce the ``add-property``, ``remove-property`` and ``extensions``
  modulefile commands for compatibility with Lmod Tcl modulefiles. These
  commands are evaluated as a *no-operation* command.
* Introduce the :mfcmd:`prereq-any` modulefile command for compatibility with
  Lmod Tcl modulefiles. :mfcmd:`prereq-any` is an alias of :mfcmd:`prereq`
  command.
* Produce a clear error message when wrong number of argument is received by
  :mfcmd:`prereq` command.
* Doc: describe :mfvar:`ModulesVersion` in *Modules Variables* section in
  :ref:`modulefile(5)` man page.
* Set ``ModuleVersion`` as an alias over :mfvar:`ModulesVersion` modulefile
  variable for compatibility with Lmod Tcl modulefiles.
* Doc: describe :mfcmd:`reportError` and :mfcmd:`reportWarning` modulefile
  commands.
* Add the :mfcmd:`require-fullname` modulefile command for compatibility with
  Lmod Tcl modulefiles. This command aborts modulefile *load* evaluation if
  modulefile's name is not fully specified.
* Add the :mfcmd:`prereq-all` modulefile command, alias over the
  :mfcmd:`prereq` command which acts as an *AND* operation when multiple
  modulefiles are specified.
* Add the :mfcmd:`depends-on` modulefile command, alias over the
  :mfcmd:`prereq-all` command for compatibility with Lmod Tcl modulefiles.
* Introduce the ``keep-loaded`` :ref:`module tag<Module tags>` that avoids an
  auto-loaded module to get automatically unloaded when its dependent modules
  are getting unloaded. Update default :mconfig:`tag_abbrev` configuration
  option to add an abbreviation for the new tag (``kL``) and default light and
  dark color palettes.
* Add the :mfcmd:`always-load` modulefile command for compatibility with Lmod
  Tcl modulefiles. This command loads designated modulefile and applies the
  ``keep-loaded`` tag to it.
* Add the :subcmd:`load-any` sub-command and :mfcmd:`module load-any<module>`
  modulefile command for compatibility with Lmod Tcl modulefiles. This command
  loads one modulefile from specified list.
* Add support for ``--not-req`` option on :mfcmd:`module try-load<module>` and
  :mfcmd:`module load-any<module>` modulefile commands.
* Doc: add :ref:`magic-cookie-check` design notes.
* Add the :mconfig:`mcookie_check` configuration option that control whether
  the magic cookie at the start of modulefile (i.e., ``#%Module`` file
  signature) need to get checked or not. When set to ``eval`` the number of
  file checks is significantly reduced when walking through modulepaths to
  search for modulefiles. Default value for this option is overridden by the
  :envvar:`MODULES_MCOOKIE_CHECK` environment variable.
* Doc: describe :mfcmd:`puts` Tcl command and its specific feature when used
  in modulefile.
* Create the ``prestdout`` channel for :mfcmd:`puts` modulefile command to be
  able to send content that will be evaluated in current shell session prior
  any other content. (fix issue #432)
* Add the :mfcmd:`family` modulefile command for compatibility with Lmod Tcl
  modulefiles. This command defines family name as a module alias over
  currently loading module and express a conflict over this name to ensure
  only one member of a family can be loaded in user environment.
  :mfcmd:`family` also defines the :envvar:`MODULES_FAMILY_\<NAME\>` and
  :envvar:`LMOD_FAMILY_\<NAME\>` environment variables.
* Doc: add :ref:`reduce-io-load` cookbook recipe.
* Add the ability to filter the list of loaded modules returned by
  :subcmd:`list` sub-command. Filtering pattern could be part of module name,
  symbolic version or alias and is matched in a case insensitive manner by
  default. It could also leverage the :ref:`Advanced module version
  specifiers` syntax.
* Add support for :option:`--starts-with` and :option:`--contains` options on
  :subcmd:`list` sub-command.
* Doc: add :ref:`shell-completion` design notes.
* Introduce :mfcmd:`complete` and :mfcmd:`uncomplete` modulefile commands to
  respectively enable and disable shell completion for a given command name.
  *bash*, *tcsh* and *fish* shells are supported.
* Track shell completion changes of *bash*, *tcsh* and *fish* shell scripts on
  :subcmd:`sh-to-mod` sub-command and :mfcmd:`source-sh` modulefile command.
* Fix typos found in code, tests and documentation. (contribution from Dimitri
  Papadopoulos Orfanos)
* Update the :subcmd:`sh-to-mod` and :mfcmd:`source-sh` mechanisms to support
  nested function definition on fish shell.
* Fix the :subcmd:`sh-to-mod` and :mfcmd:`source-sh` mechanisms to correctly
  detect functions with a ``_`` character in their name on fish shell.
* Update the :command:`module` shell function definition for sh-kind shell to
  enclose the output generated by :file:`modulecmd.tcl` in quotes in order to
  pass it to the eval command. This change fixes definition of shell function,
  especially when coming from shell script evaluation over the
  :subcmd:`sh-to-mod` and :mfcmd:`source-sh` mechanisms. (fix issue #434)
* Fix csh shell alias detection on :subcmd:`sh-to-mod` and :mfcmd:`source-sh`
  mechanisms when enclosed in parenthesis. (fix issue #434)
* Include for fish shell environment analysis on :subcmd:`sh-to-mod` and
  :mfcmd:`source-sh` mechanisms the private functions defined by evaluated
  script, in order to catch all definitions that may be useful for shell
  completion.
* Fix the :subcmd:`sh-to-mod` and :mfcmd:`source-sh` mechanisms to correctly
  detect empty function on fish shell.
* Script: add :command:`pre-commit` git hook script to help verify if commits
  are free of misspellings (with `codespell`_ tool) and trailing spaces.
* Doc: fix typos found in documentation with Aspell utility.
* Doc: describe :ref:`Dependencies between modulefiles` in
  :ref:`modulefile(5)` man page. (fix issues #431 and #433)
* Script: update :command:`pre-commit` git hook script to spell check
  documentation files with `Aspell`_ tool.
* Script: add :command:`commit-msg` git hook script to spell check commit
  message with `Aspell`_ tool.
* Doc: clarify that ``#%Module`` is a file signature also called Modules magic
  cookie.
* Doc: update the :ref:`module ENVIRONMENT` section in :ref:`module(1)` man
  page to provide for each Modules environment variable the name of the
  configuration option that could be used to set the variable with the
  :subcmd:`config` sub-command.
* Doc: clarify in :ref:`module(1)` man page that
  :envvar:`MODULES_SET_SHELL_STARTUP`, :envvar:`MODULES_SHELLS_WITH_KSH_FPATH`
  and :envvar:`MODULES_WA_277` should be set prior Modules initialization to
  get taken into account.
* Doc: update :ref:`INSTALL` document to provide the name of the configuration
  option linked the installation options.
* Doc: describe in :ref:`module(1)` man page the default value of each
  configuration option and linked installation option and command-line
  switches.
* Doc: add *Configuration options* section in :ref:`INSTALL` document with a
  table summarizing all configuration options and their relative installation
  options and environment variables.
* Add the :mfcmd:`pushenv` modulefile command for compatibility with Lmod Tcl
  modulefiles. This command sets designated environment variable with
  specified value and save the previous value set to restore it when the
  modulefile is unloaded. Previous values are saved in a
  :envvar:`__MODULES_PUSHENV_\<VAR\>` environment variable.
* Doc: add :ref:`Compatibility with Lmod Tcl modulefile` section in
  :ref:`modulefile(5)` man page.
* Update definition of the ``module()`` python function and python
  initialization script to explicitly send output to ``sys.stderr`` to get the
  ability to catch this content.
* Lib: handle ``sysconf`` error in function implementing the
  ``initStateUsergroups`` procedure. (contribution from Lukáš Zaoral)
* Introduce the :option:`--tag` option for the :subcmd:`load`,
  :subcmd:`try-load`, :subcmd:`load-any`, :subcmd:`switch` sub-commands and
  associated :mfcmd:`module` modulefile commands and :mfcmd:`prereq`,
  :mfcmd:`prereq-all`, :mfcmd:`depends-on` and :mfcmd:`always-load` modulefile
  commands. This new option applies specified tags to the module to load.
* Record tags set to loaded modules with the :option:`--tag` option in the
  :envvar:`__MODULES_LMEXTRATAG` environment variable to make this information
  persists after module being loaded.
* When saving a collection, record loaded module tags set with the
  :option:`--tag` option and those resulting from module load states (like
  ``auto-loaded`` and ``keep-loaded``). The ``--notuasked`` string previously
  used to designate auto-loaded modules in collection is changed into the
  ``--tag=auto-loaded`` option.
* Introduce the :mconfig:`collection_pin_tag` configuration option, that
  records in collection all tags set on loaded modules when enabled. Option is
  disabled by default and when set it defines the :envvar:`MODULES_COLLECTION\
  _PIN_TAG` environment variable.
* When a collection is saved, its content starts with a ``#%Module5.1`` file
  signature if :option:`--tag` option is recorded in it.
* Update the :subcmd:`restore`, :subcmd:`savelist`, :subcmd:`saveshow` and
  :subcmd:`is-saved` sub-commands to exclude from result or return an error
  when checking a collection expressing a higher Modules version requirement
  in its header signature than the one currently in use.
* Doc: describe :ref:`differences between run-command file and modulefile
  interpretation<Modulefile and run-command interp diff>` in
  :ref:`modulefile(5)` man page.
* Doc: describe :mfcmd:`module` sub-commands available as modulefile Tcl
  command for each interpretation context in :ref:`modulefile(5)` man page.
* When loading a module with some extra tags defined through the
  :option:`--tag` option, if this module is already loaded the new tags are
  added to those already set.
* When reporting result of :subcmd:`avail` or :subcmd:`list` sub-commands,
  enclose module names in single quotes if they contain a space character.
* When mentioning the loading, unloading or refreshing evaluation of a module,
  report the tags associated to this module as done when printing results of
  :subcmd:`list` sub-command.
* Fix :ref:`log-module-command` cookbook recipe not to break Modules
  initialization when using provided :file:`siteconfig.tcl` file. (fix issue
  #453 with contribution from Eric Burgueño)
* Mention tagging evaluation of a module, when tag list of an already loaded
  module is updated.

.. _Code of conduct: https://github.com/envmodules/modules/blob/main/CODE_OF_CONDUCT.md
.. _codespell: https://github.com/codespell-project/codespell
.. _Aspell: http://aspell.net/


.. _5.0 release notes:

Modules 5.0.1 (2021-10-16)
--------------------------

* Doc: add *How to preserve my loaded environment when running screen* entry
  in :ref:`FAQ`.
* Fix the advanced version specifier resolution when the
  :mconfig:`extended_default` option is off and :mconfig:`icase` option is on
  when resolving version list specification. (fix issue #411)
* Doc: improve the :ref:`log-module-command` cookbook to rely on the ``trace``
  Tcl command to track every modulefile evaluation and module/ml procedure
  calls. (fix issue #412)
* Doc: fix missing space between list entries in :ref:`variants` design doc.
  (fix issue #413)
* Correctly detect tags set on loaded modules when refreshing them.
* Set the :envvar:`__MODULES_AUTOINIT_INPROGRESS` environment variable when
  running the :subcmd:`autoinit` sub-command and quit autoinit process if this
  variable is found defined and equal to 1 when starting it. Ensure this way
  that an autoinit process will not be triggered indefinitely by itself when
  the :mconfig:`set_shell_startup` option is enabled and some module loaded at
  initialization time relies on the execution of a bash script. (fix issue
  #414)
* Remove warning message when unloading a :mfcmd:`prepend-path` or
  :mfcmd:`append-path` modulefile command with ``--duplicates`` option set.
  (fix issue #421)
* Clarify the module sub-commands that are allowed to be used within a
  modulefile. (fix issue #423)
* Install: set in the module magic cookie of the :file:`initrc` configuration
  file installed by default the version of Modules required to evaluate this
  file.
* Doc: fix documentation of :mfcmd:`getenv` modulefile command to describe
  that an empty string is now returned when designated environment variable is
  not defined and no default value to return is specified.


Modules 5.0.0 (2021-09-12)
--------------------------

* Remove deprecated :command:`createmodule.sh` and :command:`createmodule.py`
  tools as shell script to modulefile conversion is now achieved with the
  :subcmd:`sh-to-mod` sub-command.
* Remove mention of the :subcmd:`init*<initadd>` sub-commands in module usage
  message to put focus on the collection handling sub-commands.
* Do not declare anymore the ``chdir``, ``module``, ``module-trace``,
  ``module-verbosity``, ``module-user`` and ``module-log`` commands under the
  modulerc Tcl interpreter as no-op commands. A clear error message is
  obtained if these commands are still used in modulerc files instead of
  silently ignoring them.
* Return by default an empty string rather ``_UNDEFINED_`` on :mfcmd:`getenv`
  modulefile command if passed environment variable is not defined.
* Align empty directory name error message obtained on :subcmd:`use`
  sub-command with message obtained when module or collection name is empty.
* Accept non-existent modulepath on :subcmd:`use` sub-command.
* Install: installation option :instopt:`--enable-auto-handling` is set on by
  default which enables the automated module handling mode (see
  :envvar:`MODULES_AUTO_HANDLING`).
* Install: installation option :instopt:`--enable-extended-default` is set on
  by default which allows partial module version specification (see
  :envvar:`MODULES_EXTENDED_DEFAULT`).
* Install: installation option :instopt:`--enable-advanced-version-spec` is
  set on by default which activates the :ref:`Advanced module version
  specifiers`
* Install: installation option :instopt:`--enable-color` is set on by default
  which enables the ``auto`` output color mode (see :envvar:`MODULES_COLOR`).
* Install: installation option :instopt:`--with-icase` is set to ``search``
  by default to activate case insensitive match on search contexts (see
  :envvar:`MODULES_ICASE`).
* Install: installation option :instopt:`--enable-new-features` has been reset
  following major version change as all the options it implied are now enabled
  by default.
* Install: installation option :instopt:`--enable-set-shell-startup` is set
  off by default but could be enabled once installed through the
  :file:`initrc` configuration file.
* Install: installation option :instopt:`--with-initconf-in` is set to
  ``etcdir`` by default to locate configuration files in the directory
  designated by the :instopt:`--etcdir` option. Therefore the initialization
  configuration file is named :file:`initrc` in this directory, and the
  modulepath-specific configuration file is named :file:`modulespath`.
* Only look at configuration files found in the location designated by the
  :instopt:`--etcdir` or :instopt:`--initdir` option (depending on the value
  of :instopt:`--with-initconf-in` option). Configuration files were
  previously searched in both locations.
* Install: remove installation option ``--enable-compat-version``.
  Compatibility version co-installation is discontinued. :command:`switchml`
  shell function and :envvar:`MODULES_USE_COMPAT_VERSION` are thus removed as
  well.
* Testsuite: introduce the non-regression quick test mode. When the
  :envvar:`QUICKTEST` environment variable is set to ``1``, only the main
  tests from the non-regression testsuite are run. When first argument of the
  :command:`mt` script is ``quick``, tests are run in quick mode.
* Install: run non-regression testsuite in quick mode in RPM spec file.
* Rename the environment variables that are used by Modules to track loaded
  environment state (variables whose name starts with ``MODULES_LM``). A
  ``__`` prefix is added to the name of these variables to indicate that they
  are intended for internal use only.
* Rename the environment variables used to indirectly pass to
  :file:`modulecmd.tcl` the value of variables set in quarantine (variables
  whose name finishes with ``_modquar``). A
  :envvar:`__MODULES_QUAR_<__MODULES_QUAR_\<VAR\>>` prefix is applied to the
  name of these variables instead of the ``_modquar`` suffix to indicate they
  are intended for Modules internal use of only.
* Update Tcl requirement to version 8.5 as Tcl 8.4 is deprecated since a long
  time and this version is not available anymore on recent OS distributions.
  Update internal code of :file:`modulecmd.tcl` to take benefit from the
  features brought by Tcl 8.5.
* Split source code in several Tcl files hosted in ``tcl`` directory. When
  building Modules, the Tcl files are concatenated to make the
  :file:`modulecmd.tcl` script.
* Record ``auto-loaded`` tag of loaded modules in :envvar:`__MODULES_LMTAG`
  environment variable rather set a specific entry for module in the
  ``__MODULES_LMNOTUASKED`` environment variable.
* Rename the environment variables used by the reference counting mechanism
  of path-like environment variables. A
  :envvar:`__MODULES_SHARE_<__MODULES_SHARE_\<VAR\>>` prefix is applied to the
  name of these variables instead of the ``_modshare`` suffix to clearly
  indicate they are intended for Modules internal use of only.
* Reference counting mechanism is not anymore applied to the Modules-specific
  path variables (like :envvar:`LOADEDMODULES`). As a result no
  :envvar:`__MODULES_SHARE_\<VAR\>` variable is set in user environment for
  these variables. Exception is made for :envvar:`MODULEPATH` environment
  variable where the mechanism still applies.
* When an element is added to a path-like variable through the
  :mfcmd:`append-path` or :mfcmd:`prepend-path` modulefile commands, add this
  element to the associated reference counter variable (named
  :envvar:`__MODULES_SHARE_\<VAR\>`) only when this element is added multiple
  times to the path-like variable. When an element is removed from a path-like
  variable, this element is removed from the reference counter variable when
  its counter is equal to 1.
* When the :subcmd:`use` and :subcmd:`unuse` module sub-commands are not
  called during a modulefile evaluation, the reference counter associated with
  each entry in :envvar:`MODULEPATH` environment variable is ignored. In such
  context, a :subcmd:`module use<use>` will not increase the reference counter
  of a path entry already defined and a :subcmd:`module unuse<unuse>` will
  remove specified path whatever its reference counter value.
* When the :subcmd:`append-path`, :subcmd:`prepend-path` and
  :subcmd:`remove-path` module sub-commands are not called during a modulefile
  evaluation, the reference counter associated with each entry in targeted
  environment variable is ignored. In such context, a
  :subcmd:`module append-path/prepend-path<prepend-path>` will not increase
  the reference counter of a path entry already defined and a
  :subcmd:`module remove-path<remove-path>` will remove specified path
  whatever its reference counter value.
* Fix :subcmd:`unuse` sub-command when several modulepaths are specified as a
  single argument (i.e., ``/path/to/dir1:/path/to/dir2``). Enabled modulepaths
  were not correctly detected when specified this way.
* Doc: clarify that an already defined path is not added again or moved when
  passed to the :subcmd:`use` sub-command or the
  :mfcmd:`append-path/prepend-path<prepend-path>` modulefile commands. (fix
  issue #60)
* Change the :subcmd:`refresh` sub-command to evaluate all loaded modulefiles
  and re-apply the non-persistent environment changes they define (i.e., shell
  aliases and functions). With this change the :subcmd:`refresh` sub-command
  is restored to the behavior it had on Modules version 3.2.
* Evaluate the modulefile commands resulting from a :mfcmd:`source-sh` command
  through the current modulefile Tcl interpreter in order to evaluate them
  according to the current modulefile evaluation mode.
* When initializing Modules, refresh the loaded modules in case some user
  environment is already configured. This is especially useful when starting a
  sub-shell session as it ensures that the loaded environment in parent shell
  is correctly inherited, as the :subcmd:`refresh` sub-command re-applies the
  non-persistent environment configuration (i.e., shell alias and function
  that are not exported to the sub-shell). (fix issue #86)
* Init: add example code in default :file:`initrc`, the initialization script
  of Modules, to either restore user's default collection if it exists or load
  a predefined module list at the end of the initialization process.
* When initializing Modules, evaluate the :file:`initrc` configuration file in
  addition to the the :file:`modulespath` configuration file and not instead
  of this file. :file:`initrc` is evaluated after :file:`modulespath` file.
* When the installation option :instopt:`--enable-modulespath` is set, the
  list of modulepath to enable by default is now only defined in the
  :file:`modulespath` configuration file and not anymore in the :file:`initrc`
  configuration file.
* No error is raised when evaluating in ``display`` mode a modulefile without
  a value specified for the :mfcmd:`variant` it defines. This change helps to
  learn all the variant a modulefile defines. As a result, the unspecified
  variant is not instantiated in the :mfvar:`ModuleVariant` array variable.
  (fix issue #406)
* When running the :mfcmd:`unsetenv` modulefile command on an unload
  evaluation, do not unset designated environment variable if no value to
  restore is provided.
* Fix :mfcmd:`unsetenv` to distinguish between being called on a unload
  evaluation without a value to restore or with an empty string value to
  restore.
* Make :mfcmd:`system` modulefile command available from a modulerc evaluation
  context whatever the underlying module evaluation mode.
* Make :mfcmd:`is-used` modulefile command available from a modulerc
  evaluation context.
* Remove internal state ``tcl_version_lt85`` as Tcl 8.5+ is now a requirement.
* Forbid use of :subcmd:`module source<source>` command in modulefile or in an
  initialization rc file, the ``source`` Tcl command should be used instead.
  :subcmd:`source` sub-command should only be called from the command-line.
* Report the modules loading and unloading during the :command:`module`
  command initialization (i.e., during the evaluation of the :file:`initrc`
  configuration file). These report messages are disabled when the
  :mconfig:`verbosity` configuration option is set to ``concise`` or
  ``silent``.
* During a module :subcmd:`restore` or :subcmd:`source`, only report the
  module load and unload directly triggered by these sub-commands. Load and
  unload triggered by other modules are reported through the automated module
  handling messages of the main modules.
* Enforce use of the module magic cookie (i.e., ``#%Module``) at the start of
  global or user rc files, :file:`initrc` configuration file or any scriptfile
  passed for evaluation to the :subcmd:`source` sub-command. These files are
  not evaluated and an error is produced if the magic cookie is missing or if
  the optional version number placed after the cookie string is higher than
  the version of the :file:`modulecmd.tcl` script in use.
* Doc: alphabetically sort installation option in :ref:`INSTALL` document.
* Update the :instopt:`--enable-quarantine-support` installation option to
  control a :mconfig:`quarantine_support` configuration option. When this
  option is enabled, the :subcmd:`autoinit` sub-command produces the shell
  code for the :command:`module` shell function definition with quarantine
  mechanism support. When disabled, code is generated without quarantine
  support.
* Install: installation option :instopt:`--enable-quarantine-support` is set
  off by default.
* Introduce the :envvar:`MODULES_QUARANTINE_SUPPORT` environment variable to
  control the :mconfig:`quarantine_support` configuration option once Modules
  is installed. To enable the quarantine mechanism,
  :envvar:`MODULES_QUARANTINE_SUPPORT` should be set to ``1`` prior Modules
  initialization or :mconfig:`quarantine_support` configuration option should
  be set to ``1`` in the :file:`initrc` configuration file.
* Quarantine mechanism code in the Modules shell initialization scripts is now
  always defined and mechanism always applies if some environment variables
  are defined in :envvar:`MODULES_RUN_QUARANTINE`.
* Code in the :file:`modulecmd.tcl` script to restore environment variables
  put in quarantine is now always generated and applies if the
  :envvar:`__MODULES_QUARANTINE_SET` environment variable is set to ``1``.
  This variable is set by the Modules initialization script prior calling the
  :subcmd:`autoinit` sub-command or by the :command:`module` shell function if
  it has been generated with quarantine support enabled.
* Install: installation option :instopt:`--enable-silent-shell-debug-support`
  is set off by default.
* Code to silence shell debug properties in the Modules shell initialization
  scripts is now always defined and mechanism applies if
  :envvar:`MODULES_SILENT_SHELL_DEBUG` environment variable is set to ``1``.
* Code to silence shell debug properties in the :command:`module` shell
  function could now be enabled if :envvar:`MODULES_SILENT_SHELL_DEBUG` is set
  to ``1`` prior Modules initialization or if the
  :mconfig:`silent_shell_debug` configuration option is set to ``1`` in the
  :file:`initrc` configuration file.
* Doc: clarify TOC and title of :ref:`MIGRATING<MIGRATING>` document.
* Doc: extend description of Modules configuration steps of in :ref:`INSTALL`
  document.
* Doc: document :file:`initrc` and :file:`modulespath` configuration files in
  :ref:`module(1)` man page.
* Install: replace :file:`example.txt` by :file:`INSTALL.txt` guide in RPM.
* Doc/Install: rename ``diff_v3_v4`` document into :ref:`changes<changes>`.
* Doc: reorganize :ref:`changes` document to let room to describe Modules 5
  changes.


.. _4.8 release notes:

Modules 4.8.0 (2021-07-14)
--------------------------

* Introduce the :subcmd:`edit` sub-command that opens modulefile passed as
  argument in a text editor. Modulefile can be specified like with any other
  sub-command, leveraging defined symbolic versions, aliases or using advanced
  version specifiers.
* Add the :mconfig:`editor` configuration option to select the text editor to
  use with :subcmd:`edit` sub-command. When this option is set through the
  :subcmd:`config` sub-command, the :envvar:`MODULES_EDITOR` environment
  variable is set. The :instopt:`--with-editor` installation option controls
  the default value of :mconfig:`editor` configuration option. If not set at
  installation time, ``vi`` is set as default editor.
* Default value of :mconfig:`editor` configuration option is overridden by the
  :envvar:`VISUAL` or the :envvar:`EDITOR` environment variables, which are
  both in turn overridden by the :envvar:`MODULES_EDITOR` environment
  variable.
* Doc: fix :file:`modulecmd.tcl` internal state check in recipes example
  codes. (fix issue #396)
* The :ref:`Advanced module version specifiers` mechanism now allows the use
  of version range in version list (for instance ``mod@:1.2,1.4:1.6,1.8:``).
  Such specification helps to exclude specific versions. (fix issue #397)
* Install: fix installation scripts to allow building Modules when its
  repository is set as a git submodule. (fix issue #398)
* Doc: demonstrate in the :ref:`source-script-in-modulefile` recipe how to use
  the :mfcmd:`source-sh` command when software provide a specific
  initialization script for each shell it supports. (fix issue #399)
* When defining a shell function with the :mfcmd:`set-function` modulefile
  command, only export this function when using the Bash shell (using the
  ``export -f`` shell command) to make it available in sub-shell contexts.
  Shell function export is not supported on other kind of sh shell (sh, ksh
  and zsh). (fix issue #401)
* Doc: add :ref:`variants` design notes.
* Add the :mfcmd:`variant` modulefile command that enables to pass down
  arguments, specified when designating the module to evaluate, within
  modulefile evaluation context. This command defines a variant name and a
  list of allowed values. When evaluated, :mfcmd:`variant` instantiates an
  element in the :mfvar:`ModuleVariant` array whose name equals variant name
  and value is set with value specified for variant when module is designated.
  If specified value does not correspond to an allowed value or if no value
  is specified for variant an error is raised.
* Enhance the :ref:`Advanced module version specifiers` to handle variant
  specification following `Spack`_'s syntax (e.g., *name=value*). When the
  :mconfig:`advanced_version_spec` configuration is enabled, variant could be
  specified anywhere a module can be specified.
* Add the ``--default`` option to the :mfcmd:`variant` modulefile command to
  indicate the default value of the variant to apply when the designation of
  the evaluating module does not mention this variant.
* Add the ``--boolean`` option to the :mfcmd:`variant` modulefile command to
  indicate that the variant defined is of the Boolean type, thus no list of
  accepted value is expected.
* Enhance the :ref:`Advanced module version specifiers` to handle Boolean
  variant specification following `Spack`_'s syntax (e.g., *+name*, *~name*
  and *-name*). The *-name* syntax is not supported on :ref:`ml(1)` command as
  the minus sign already means to unload designated module.
* Accept any minus argument (*-word*) set after the sub-command name when the
  :mconfig:`advanced_version_spec` configuration is enabled and if sub-command
  accepts :ref:`Advanced module version specifiers` (like :subcmd:`load` or
  :subcmd:`unload` sub-commands). A *false* value may be set to Boolean
  variant this way.
* Add the :mconfig:`variant_shortcut` configuration option to define shortcut
  characters that could be used to specify and report module variants. Default
  value for this option could be set at installation time with the
  :instopt:`--with-variant-shortcut` option. No variant shortcut is defined by
  default. This value could be superseded by setting up the
  :mconfig:`variant_shortcut` option with :subcmd:`config` sub-command. Which
  sets the :envvar:`MODULES_VARIANT_SHORTCUT` environment variable.
* Enhance the :ref:`Advanced module version specifiers` to handle variant
  shortcut specification (e.g., *<shortcut>value*).
* Record in user loaded environment, with
  :envvar:`MODULES_LMVARIANT<__MODULES_LMVARIANT>` environment variable, the
  value specified for the variants defined in the loaded modulefiles and their
  properties (if it is a Boolean variant and if the value set is the default
  one).
* Add the ``variant`` element in the allowed value list of the
  :mconfig:`list_output` and :mconfig:`list_terse_output` configuration
  options. Set this new element in the default value list of the
  :mconfig:`list_output` option. When set, the variant defined for loaded
  modules are reported on module :subcmd:`list` command output.
* Add the ``va`` color key in default light and dark color palettes to
  graphically enhance the report of variant value.
* Update the key section to explain on :subcmd:`list` sub-command output the
  reported variant elements (*name=value*, *+name*, *-name* or
  *<shortcut>value*)
* Record variant specification of loaded modules when saving collections and
  reload specified variants when restoring these collections.
* When :mconfig:`collection_pin_version` configuration is disabled, only
  record in collections the variants whose value is not the default one.
* Update module designation in error, warning or informational messages to
  report variant specification enclosed in curly braces (*{}*), enclose module
  name and version or variant specification in single quotes (*''*) if they
  contain a space character and highlight the module designation in report
  message if configured.
* Introduce the :mfcmd:`getvariant` modulefile command to query for currently
  evaluating module the value of a given variant name.
* When translating the ``@loaded`` version specifier also retrieve the variant
  specified for corresponding loaded module.
* Update hide, forbid and tag mechanisms to apply them only if they match
  selected module variant.
* Any variant defined in module specification passed as argument to search
  sub-commands (:subcmd:`avail`, :subcmd:`whatis`, :subcmd:`is-avail`,
  :subcmd:`path` and :subcmd:`paths`) is ignored.
* Raise an error if a variant named ``version`` is declared in a modulefile to
  let room for the future implementation of this specific variant.
* Doc: describe in the :ref:`changes` document argument handling change on
  :mfcmd:`setenv` since v3.2. (fix issue #402)
* Introduce the :subcmd:`try-load` sub-command which like :subcmd:`load`
  sub-command tries to load the modulefile passed as argument, but does not
  complain if this modulefile cannot be found. (fix issue #392)
* Init: fix stderr redirection in fish shell initialization script, now that
  use of the ``^`` character to redirect stderr is disabled by default (fish
  >=3.3).
* Protect quarantine mechanism code from ``rcexpandparam`` Zsh option when
  initializing the :command:`module` command on this shell. (fix issue #403)


.. _4.7 release notes:

Modules 4.7.1 (2021-04-06)
--------------------------

* Doc: clarify the license terms used by the project. (fix issue #389)
* Align all files from the Modules project under the GPLv2+ license. Scripts
  and libraries that were previously licensed with GPLv3+ have been moved to
  GPLv2+ with the consent of their respective copyright holders. (fix issue
  #389)
* Revert "Install: have :file:`configure` script assume the ``.`` dot
  directory when invoked without the prepended ``./``" as consent was not
  obtained from author to re-license the contribution to GPLv2+.
* Doc: fixes few typos in :ref:`module(1)` and :ref:`modulefile(5)`.
* Update the :subcmd:`sh-to-mod` mechanism to support version 3.2 of the fish
  shell. Fish 3.2 introduces the ``.`` builtin command that should be
  regexp-escaped when determining the shell functions or aliases defined by
  the script analyzed by :subcmd:`sh-to-mod`.
* Vim: update addon files to highlight modulefile variables
  :mfvar:`ModuleTool`, :mfvar:`ModuleToolVersion` and
  :mfvar:`ModulesCurrentModulefile`.
* Doc: update the description and default value of the
  :instopt:`--with-dark-background-colors` and
  :instopt:`--with-light-background-colors` installation options.
* Doc: add description of changes that occurred on versions 4.6 and 4.7 for
  the :instopt:`--with-dark-background-colors` and
  :instopt:`--with-light-background-colors` installation options and for the
  :envvar:`MODULES_COLORS` environment variable.
* Doc: correct the default value of the :instopt:`--with-tag-abbrev`
  installation option.
* Doc: add :ref:`sticky-modules-rcp` cookbook recipe.


Modules 4.7.0 (2021-02-19)
--------------------------

* Doc: simplify TOC of :ref:`MIGRATING` document
* Add the :mfvar:`ModuleTool` and :mfvar:`ModuleToolVersion` Modules
  variables to determine during modulefile or modulerc evaluation the name and
  version of the *module* implementation currently in use.
* Introduce the :mfcmd:`versioncmp` modulefile command to compare two version
  strings passed as argument.
* Enable the use of wildcard character to designate multiple directories at
  once in :file:`modulespath` configuration file. (fix issue #125)
* Distinguish aliases from symbolic versions in
  :envvar:`MODULES_LMALTNAME<__MODULES_LMALTNAME>` environment variable.
  Prefix these alias entries with the ``al|`` string.
* Fetch modulefile modification time only if required by :subcmd:`list`
  sub-command display format.
* Use symbolic versions recorded in environment, with
  :envvar:`MODULES_LMALTNAME<__MODULES_LMALTNAME>` variable, to report the
  symbols applying to loaded modules on :subcmd:`list` sub-command. Modulerc
  files are not evaluated anymore when performing a module list.
* Move the definition of the :envvar:`FPATH` environment variable for Modules
  initialization on ksh shell from the initialization script of this shell to
  the resulting output of the :subcmd:`autoinit` sub-command.
* Introduce the :mconfig:`shells_with_ksh_fpath` configuration option to
  define a list of shell where to ensure that any ksh sub-shell will get the
  module function defined by use of the :envvar:`FPATH` environment variable.
  When the :mconfig:`shells_with_ksh_fpath` option is set through the
  :subcmd:`config` sub-command, the :envvar:`MODULES_SHELLS_WITH_KSH_FPATH`
  environment variable is set. Accepted values are a list of shell among *sh*,
  *bash*, *csh*, *tcsh* and *fish* separated by colon character (``:``).
* Add the :mconfig:`implicit_requirement` configuration option to control
  whether a prereq or a conflict requirement should be implicitly set onto
  modules respectively specified on :mfcmd:`module load<module>` or
  :mfcmd:`module unload<module>` commands in modulefile. Default value for
  this option could be set at configure time with the
  :instopt:`--enable-implicit-requirement` option (enabled by default). This
  value could be superseded by setting up the :mconfig:`implicit_requirement`
  option with :subcmd:`config` sub-command. Which sets the
  :envvar:`MODULES_IMPLICIT_REQUIREMENT` environment variable. (fix issue
  #260)
* Add the ``--not-req`` option to the :mfcmd:`module` modulefile command to
  inhibit for its ``load`` and ``unload`` sub-commands the definition of a
  prereq or conflict requirement onto specified modules.
* Add the ``lpopState`` and ``currentState`` procedures to respectively remove
  or return the last entry from the list of values of a given state.
* Add the ``topState`` and ``depthState`` procedures to respectively return
  the first element from or the number of elements in the list of values of a
  given state.
* Remove the pre-definition of runtime states with no specific property. These
  basic states are defined on-the-fly which implied they are not reported on a
  :subcmd:`module config --dump-state<config>` command unless if instantiated.
* Introduce the ``loaded`` symbolic version among advanced version specifiers
  (e.g. ``foo@loaded``) to designate the currently loaded version of specified
  module. (fix issue #366)
* Doc: add *Module tags* design notes.
* Report tags applying to the modules returned by the :subcmd:`avail`
  sub-command. Adapt the regular, terse and JSON output styles to report these
  tags along the module they are attached to (enclosed in ``<>``). Reported
  tags currently are states that apply to modules: ``auto-loaded``,
  ``forbidden``, ``hidden``, ``loaded``, ``nearly-forbidden``, ``sticky`` and
  ``super-sticky``.
* Record tags applying to each loaded module in the
  :envvar:`MODULES_LMTAG<__MODULES_LMTAG>` environment variable to make this
  information persist after module being loaded.
* Report tags applying to the loaded modules returned by the :subcmd:`list`
  sub-command. Adapt the regular and JSON output styles to report these tags
  along the module they are attached to (enclosed in ``<>``). Reported tags
  currently are states applying to loaded modules: ``auto-loaded``,
  ``hidden-loaded``, ``nearly-forbidden``, ``sticky`` and ``super-sticky``.
* Introduce the :mfcmd:`module-info tags<module-info>` modulefile command to
  query the tags that apply to the currently evaluated modulefile.
* Add the :mfcmd:`module-tag` modulefile command to associate tag to
  designated modulefile. Those tags are reported on :subcmd:`avail` and
  :subcmd:`list` sub-commands along the module they are attached to.
  :mfcmd:`module-tag` supports the advanced module version specifier syntax.
* Add the :mconfig:`tag_abbrev` configuration option to define abbreviated
  strings for module tags and use these abbreviations instead of tag names
  when reporting tags on :subcmd:`avail` and :subcmd:`list` command results.
  Default value for this option could be set at configure time with the
  :instopt:`--with-tag-abbrev` option. By default the following abbreviations
  are set: ``aL`` for *auto-loaded*, ``F`` for *forbidden*, ``H`` for
  *hidden*, ``H`` for *hidden-loaded*, ``L`` for *loaded*, ``nF`` for
  *nearly-forbidden*, ``S`` for *sticky*, ``sS`` for *super-sticky*. This
  value could be superseded by setting up the :mconfig:`tag_abbrev` option
  with :subcmd:`config` sub-command. Which sets the
  :envvar:`MODULES_TAG_ABBREV` environment variable.
* A Select Graphic Rendition (SGR) code can be associated to module tag names
  or abbreviation strings in the color palette to graphically render these
  tags over the module name they are associated to. The default light and dark
  color palettes have been updated to set a color code for all basic module
  tags. When a color code is set for a tag, it is then graphically rendered
  over the module names and not reported along module name by its tag name or
  abbreviation. When multiple colored tags apply to a given module, each tag
  is graphically rendered over a sub-part of the module name.
* Add the :mconfig:`tag_color_name` configuration option to designate module
  tags whose graphical rendering should be applied to their own name or
  abbreviation rather than over the module name they are attached to.
  Default value for this option could be set at configure time with the
  :instopt:`--with-tag-color-name` option (empty by default). This value could
  be superseded by setting up the :mconfig:`tag_color_name` option with
  :subcmd:`config` sub-command. Which sets the
  :envvar:`MODULES_TAG_COLOR_NAME` environment variable.
* Add the ``--hidden-loaded`` option to the :mfcmd:`module-hide` modulefile
  command that indicates module should be hidden once loaded. When set, the
  ``hidden-loaded`` module tag applies to module specification set on
  :mfcmd:`module-hide` command.
* Do not report on :subcmd:`list` sub-command results the loaded modules
  associated with the ``hidden-loaded`` tag, unless if the :option:`--all`
  option is set.
* Doc: add an ``hidden-loaded`` example in the *Hide and forbid modules*
  cookbook recipe.
* Introduce the ``verbose2`` verbosity level between ``verbose`` and ``trace``
  levels. Verbose2 mode can be enabled by setting the :mconfig:`verbosity`
  config to the ``verbose2`` value or by using the :option:`-v` command-line
  switch twice.
* Do not report the load, unload or switch of modules set ``hidden-loaded`` if
  these modules have been loaded, unloaded or switched automatically. Unless
  the verbosity mode is set to ``verbose2`` or any higher level or if any
  specific messages have to be reported for these module evaluations.
* Report when trying to load a module which is already loaded or when trying
  to unload a module which is not loaded in case the verbosity mode is set to
  ``verbose2`` or any higher level. (fix issue #187)
* Doc: improve readability of version 4 improvements in :ref:`changes`
  document.
* Introduce stickiness: module tagged ``sticky`` with :mfcmd:`module-tag`
  command cannot be unloaded unless if the unload is forced or if the module
  is reloaded. (fix issue #269)
* Introduce super-stickiness: module tagged ``super-sticky`` with
  :mfcmd:`module-tag` command cannot be unloaded even if the unload is forced
  unless if the module is reloaded. (fix issue #269)
* Allow swap of sticky or super-sticky modules by another modulefile version
  if stickiness definition applies to module parent name. E.g., *foo/1.0* can
  be swapped by *foo/2.0* if sticky tag applies to *foo*.
* When forcing purge with a :subcmd:`purge --force<purge>` sub-command, also
  unload the modules that are depended by non-unloadable modules.
* Doc: improve readability of Modules installation configuration in
  :ref:`INSTALL` document and enable hypertext reference to these elements.
* Doc: improve readability of module command configuration option in
  :ref:`module(1)` document and enable hypertext reference to these elements.
* Doc: describe in HTML documentation when installation options, module
  command configuration options and options of modulefile command or module
  sub-command were introduced.
* Doc: update HTML documentation Table Of Content.
* Doc: improve markup of module sub-commands, modulefile commands,
  installation option, module configuration option across documentation.
* Doc: colorize terminal output examples in :ref:`MIGRATING` document.
* Abort modulefile read if first file content chunk does not start with the
  ``#%Module`` magic cookie. (fix issue #375)
* Install: add installation option :instopt:`--enable-new-features` that
  enables all at once the installation options that are disabled by default
  due to the substantial behavior changes they imply.
* Add a *Key* section at the end of :subcmd:`avail` and :subcmd:`list`
  sub-commands to explain the meaning of graphical renditions or of elements
  set in parentheses or chevrons along module name.
* Fix output of :subcmd:`avail` and :subcmd:`list` sub-commands on very small
  terminal width. (fix issue #378)
* Add :mconfig:`mcookie_version_check` configuration to define if version set
  in modulefile magic cookie should be checked against :command:`module`
  current version to determine if modulefile can be evaluated. The new
  configuration, which is enabled by default, can be set at installation time
  with configure option :instopt:`--enable-mcookie-version-check` or can be
  superseded later on with the :envvar:`MODULES_MCOOKIE_VERSION_CHECK`
  environment variable. (fix issue #377)
* Fix output of modulefile evaluation error stack trace on very small terminal
  width. (fix issues #379 and #381)
* Correct :subcmd:`config` sub-command to set :mconfig:`nearly_forbidden_days`
  configuration. (fix issue #380)
* Init: reduce usage of helper variables in :file:`bash_completion` and
  :file:`tcsh_completion` that are showing up in the output of the shell's
  ``set`` command. (fix issue #382 with contribution from Colin Marquardt)
* Consider modulepath starting with a reference to an environment variable as
  absolute. (fix issue #376)
* Consider the :subcmd:`module load<load>` performed in the user or the global
  RC file like load commands issued from initialization RC file. (fix issue
  #372)
* Install: have :file:`configure` script assume the ``.`` dot directory when
  invoked without the prepended ``./``. (contribution from R.K. Owen)
* Install: disable the Makefile rules to build the HTML documentation in case
  if the documentation is found pre-built in the dist archive.
* Install: do not flag documentation as pre-built if :file:`configure` script
  is ran another time after building docs.
* Restrict the value accepted by :mconfig:`nearly_forbidden_days`
  configuration and :instopt:`--with-nearly-forbidden-days` installation
  option to integers comprised between 0 and 365.
* Install: color *ERROR* and *WARNING* message headers produced by
  :file:`configure` script if output is sent to a terminal.
* Install: split error messages produced by :file:`configure` script over an
  additional line when too long.
* Doc: add *Output configuration* design notes.
* Introduce the :mconfig:`avail_output` and :mconfig:`avail_terse_output`
  configuration options to define the content to report in addition to the
  available module names respectively for :subcmd:`avail` sub-command regular
  and terse output modes. Excepted value for these configuration options is a
  colon separated list of elements to report. Default value is
  ``modulepath:alias:dirwsym:sym:tag:key`` for :mconfig:`avail_output` and
  ``modulepath:alias:dirwsym:sym:tag`` for :mconfig:`avail_terse_output`.
  These values can be changed at installation time respectively with the
  :instopt:`--with-avail-output` and :instopt:`--with-avail-terse-output`
  options. These values can then be superseded by using the :subcmd:`config`
  sub-command which sets the :envvar:`MODULES_AVAIL_OUTPUT` and
  :envvar:`MODULES_AVAIL_TERSE_OUTPUT` environment variables.
* Introduce the :mconfig:`list_output` and :mconfig:`list_terse_output`
  configuration options to define the content to report in addition to the
  available module names respectively for :subcmd:`list` sub-command regular
  and terse output modes. Excepted value for these configuration options is a
  colon separated list of elements to report. Default value is
  ``header:idx:sym:tag:key`` for :mconfig:`list_output` and ``header`` for
  :mconfig:`list_terse_output`. These values can be changed at installation
  time respectively with the :instopt:`--with-list-output` and
  :instopt:`--with-list-terse-output` options. These values can then be
  superseded by using the :subcmd:`config` sub-command which sets the
  :envvar:`MODULES_LIST_OUTPUT` and :envvar:`MODULES_LIST_TERSE_OUTPUT`
  environment variables.
* Add the :option:`--output`/:option:`-o` command-line switches to supersede
  the output configuration of :subcmd:`avail` or :subcmd:`list` sub-commands
  on their regular or terse output modes.
* Remove the ``avail_report_dir_sym`` and ``avail_report_mfile_sym`` locked
  configuration options whose behaviors can now be obtained by respectively
  adding the ``dirwsym`` and ``sym`` elements to the :mconfig:`avail_output`
  or :mconfig:`avail_terse_output` configuration options.
* When ``modulepath`` is omitted from the content to report on :subcmd:`avail`
  sub-command, available modules collected from global/user rc and enabled
  modulepaths are aggregated and reported all together.
* Install: print generated file names rather commands executed to generate
  these files on Makefile build targets. Output obtained when building Modules
  is this way simplified. When option ``V=1`` is passed to ``make``, the
  verbose mode is enabled and run commands are shown. The simplified ``make``
  output does not apply to the install, test and clean targets or any target
  similar to them.
* Install: fix configure and build files of Modules Tcl extension library to
  make them compatible with autoconf >=2.69.
* Script: correctly detect previous Modules version number released from a
  side git branch on :command:`mpub` command.
* Install: align RPM spec file syntax with spec file used on Fedora. Add
  missing build dependency on ``make`` package. Also remove obsolete ``Group``
  RPM tag.
* Add the :mconfig:`term_width` configuration option to set the width of the
  output. This configuration option is set to ``0`` by default, which means
  that the output width is the full terminal width. The
  :option:`--width`/:option:`-w` command line switches are added to supersede
  the value of the configuration option. (fix issue #359 with contribution
  from Anaïs Gaertner)
* Doc: add a *Get Modules* section in :ref:`INSTALL` document to provide
  download links for Modules' sources. (fix issue #387)


.. _4.6 release notes:

Modules 4.6.1 (2020-11-14)
--------------------------

* Lib: implement ``initStateClockSeconds`` as a Tcl command in
  libtclenvmodules to provide an optimized way to retrieve current Epoch time.
* Lib: implement ``parseDateTimeArg`` as a Tcl command in libtclenvmodules to
  provide an optimized way to convert a datetime string into an Epoch time.
* When full module specification is equal to ``@``, raise an error as no
  module name is provided. (fix issue #362)
* Optimize internal recording of hidden module and tag specification when
  parsing modulerc files in order to reduce the time taken to test if a given
  module is hidden or if a given tag applies to it.
* Script: add the ability to select the benchmark test to perform on
  :command:`mb` utility.
* Doc: add *Use new features without breaking old module command* cookbook
  recipe
* Doc: rework option description for :mfcmd:`module-hide` and
  :mfcmd:`module-forbid` commands in :ref:`modulefile(5)` document.
* Doc: describe in :ref:`changes` document that shell special characters like
  backticks are escaped when used in values starting Modules 4.0. (fix issue
  #365)
* Doc: make the ENVIRONMENT section from :ref:`modulefile(5)` man page point
  to the ENVIRONMENT section of :ref:`module(1)` man page.
* Fix :subcmd:`clear` sub-command to unset the
  :envvar:`MODULES_LMSOURCESH<__MODULES_LMSOURCESH>` environment variable.
  (fix issue #367)
* Correctly return on :subcmd:`avail` sub-command a symbolic version defined
  in a global RC file when specifically searched. (fix issue #368)
* Fix module hiding resolution for symbolic versions defined in a global RC
  file when :mfcmd:`module-hide` statements are set in the modulepath where
  the modulefiles targeted by these symbols are located. (fix issue #369)
* When a module fails to unload during a :subcmd:`purge` sub-command, preserve
  loaded the modules it requires to keep environment consistent. (fix issue
  #370)
* Doc: add *Hide and forbid modules* cookbook recipe.


Modules 4.6.0 (2020-09-16)
--------------------------

* Rework internal state handling to gather all state definitions in a global
  array and use the same initialization and retrieval procedure, named
  ``getState``, for all these states.
* Add the ``setState``, ``unsetState``, ``lappendState``, ``isStateDefined``
  and ``isStateEqual`` procedures to provide unified ways to set or check the
  value of state.
* Introduce the :subcmd:`sh-to-mod` sub-command, to evaluate shell script and
  determine the environment changes it does. Corresponding modulefile
  content is outputted as a result. Changes on environment variables, shell
  aliases, shell functions and current working directory are tracked. The
  following shells are supported: sh, dash, csh, tcsh, bash, ksh, ksh93, zsh
  and fish.
* Doc: add *Source shell script in modulefile* design notes.
* Introduce the :mfcmd:`source-sh` modulefile command, to evaluate shell
  script and apply resulting environment changes through modulefile commands.
  When a modulefile using :mfcmd:`source-sh` modulefile command is loaded, the
  modulefile commands resulting from shell script evaluation are recorded in
  the :envvar:`MODULES_LMSOURCESH<__MODULES_LMSOURCESH>` environment variable
  to be able to undo these environment changes when modulefile is unloaded and
  to report the modulefile commands used when modulefile is displayed. The
  same kind of environment changes than the :subcmd:`sh-to-mod` sub-command
  are tracked. The same list of shells than :subcmd:`sh-to-mod` sub-command
  are supported. (fix issue #346)
* Doc: add *Source shell script in modulefile* cookbook recipe.
* Doc: embed new Modules logo on website, online README and documentation
  portal.
* Install: disable by default the build of Modules compatibility version. From
  now on, option :instopt:`--enable-compat-version` has to be set to trigger
  this build.
* Introduce the ``username`` sub-command to the :mfcmd:`module-info`
  modulefile command to get the username of the user currently running
  :file:`modulecmd.tcl` or to test a string passed as argument corresponds to
  this username.
* Introduce the ``usergroups`` sub-command to the :mfcmd:`module-info`
  modulefile command to get all the groups of the user currently running
  :file:`modulecmd.tcl` or to test a string passed as argument corresponds to
  one of these groups.
* Doc: improve markup of :ref:`NEWS` and :ref:`MIGRATING` documents starting
  from this 4.6 version to enable references to module sub-commands, command
  line switches, environment variables and modulefile Tcl commands.
* Use inclusive terminology to eliminate *master* and *slave* terms as much as
  possible from code source and documentation.
* Doc: use a versioned magic cookie in examples that demonstrate new
  modulefile features. (fix issue #349)
* Introduce the :instopt:`--enable-multilib-support` configure option to add
  mechanism in :file:`modulecmd.tcl` to look at an alternative location to
  find the Modules Tcl extension library in case this library cannot be found
  at its main location.
* Lib: remove *fetch_hidden* argument from ``getFilesInDirectory`` procedure
  of Modules Tcl extension library.
* Doc: add *Hide or forbid modulefile* design notes.
* Add the :mfcmd:`module-hide` modulefile command, to dynamically hide
  modulefile, module alias or symbolic version matching passed specification.
  When hidden, a modulefile, an alias or a symbolic version is not reported
  nor selected unless referred by its exact name, like for module whose name
  or version starts with a dot character. :mfcmd:`module-hide` supports the
  advanced module version specifiers. (fix issue #202)
* Add option ``--soft`` to the :mfcmd:`module-hide` modulefile command to
  introduce a soften level of camouflage: modules targeted by such hide
  directive are made visible as soon as their root name is part of search
  query.
* Add option ``--hard`` to the :mfcmd:`module-hide` modulefile command to
  introduce a hardened level of camouflage: modules targeted by such hide
  directive keep being hidden even if they are fully matched by search query.
* Do not report among :subcmd:`whatis` search result the modulefiles with
  version name prefixed by a dot character and targeted by a symbolic version
  unless if they are precisely searched.
* When a loading module has hidden alternative names (hidden due to their
  name or version starting with a dot character or because they match a
  :mfcmd:`module-hide` statement), these alternative names are not recorded in
  environment unless if they are not hard-hidden and if they have been used in
  query to select loading module.
* On :subcmd:`avail` sub-command, remove hidden symbolic versions from the
  list to display along modulefile or directory they target, unless these
  symbols are not hard-hidden and are used in query to search modules.
* When the :option:`--default` filter of :subcmd:`avail` sub-command is set,
  unhide all the *default* symbolic versions or modules targeted by these
  symbols unless if they are hard-hidden.
* Define the *default* and *latest* automatic symbolic versions only if
  relative module name matches search query to ensure all elements for this
  module have been processed prior assigning the symbols.
* In case a symbolic version is transitively applied toward a modulefile, like
  for instance when this symbol is first set onto a directory, record the
  resolution of each transitively applied symbol. By doing so, a module
  :subcmd:`load` tentative using the transitively applied symbolic version
  will now correctly resolve to the modulefile targeted by symbol.
* Fix use of the advanced version specifiers in arguments to the
  :mfcmd:`is-avail` modulefile command.
* Introduce the :option:`--all`/:option:`-a` option for :subcmd:`avail`,
  :subcmd:`aliases`, :subcmd:`whatis` and :subcmd:`search` sub-commands, to
  include in the search process all hidden modulefiles, module aliases or
  symbolic versions. Hard-hidden modules stay hidden even if
  :option:`--all`/:option:`-a` option is used.
* Add the :mfcmd:`module-forbid` modulefile command, to dynamically forbid
  evaluation of modulefile matching passed specification. When forbidden, a
  module cannot be loaded and an access error is obtained when trying to
  evaluate them. :mfcmd:`module-forbid` supports the advanced module version
  specifiers.
* Add ``--not-user`` and ``--not-group`` options to :mfcmd:`module-hide` and
  :mfcmd:`module-forbid` modulefile commands to ignore hiding or forbidding
  definition if current user is respectively part of specified username list
  or member of one of specified group list.
* Add ``--before`` and ``--after`` options to :mfcmd:`module-hide` and
  :mfcmd:`module-forbid` modulefile commands to ignore hiding or forbidding
  definition respectively after and before a specified date time. Accepted
  date time format is ``YYYY-MM-DD[THH:MM]``.
* Add ``--message`` option to :mfcmd:`module-forbid` modulefile command to
  supplement the error message obtained when trying to evaluate a forbidden
  module.
* When a module that will soon be forbidden (as the date limit specified on
  the ``--after`` option of a matching :mfcmd:`module-forbid` command is near)
  is evaluated, warn user this module access will soon be denied.
* The range of time the above warning appears can be controlled with the
  :mconfig:`nearly_forbidden_days` configuration option, whose value equals to
  the number of days prior the module starts to be forbidden. This
  configuration is set to ``14`` (days) by default and this value can be
  controlled at :file:`configure` time with
  :instopt:`--with-nearly-forbidden-days` option. When the
  :mconfig:`nearly_forbidden_days` configuration is set through the
  :subcmd:`config` sub-command, the :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS`
  environment variable is set.
* Add ``--nearly-message`` option to :mfcmd:`module-forbid` modulefile command
  to supplement the warning message obtained when evaluating a nearly
  forbidden module.
* Add the ``debug2`` verbosity level, to report each call of
  :file:`modulecmd.tcl` internal procedures in addition to debug messages.
  Debug2 mode can be enabled by setting the :mconfig:`verbosity` config to the
  ``debug2`` value or by using the :option:`-D` command-line switch twice.
* Install: look for ``make`` rather ``gmake`` on MinGW and build library with
  a ``.dll`` extension on this platform.
* Add the ``trace`` verbosity level, to report details on module searches,
  resolutions, selections and evaluations. Trace mode can be enabled by
  setting the ``verbosity`` config to the ``trace`` value or by using the
  :option:`-T`/:option:`--trace` command-line switches.
* Introduce the ``tr`` key in the color palette to specifically render trace
  messages. Default value for ``tr`` key is ``2`` (decreased intensity).
* When trying to set an environment variable to an empty value on the Windows
  platform, unset this environment variable instead to cope with the
  underlying OS behavior.


.. _4.5 release notes:

Modules 4.5.3 (2020-08-31)
--------------------------

* Install: take into account the ``--build``, ``--host``, ``--target``,
  ``--enable-dependency-tracking`` and ``--disable-dependency-tracking``
  configure options to transmit them to the :file:`configure` scripts of
  Modules Tcl extension library and Modules compatibility version. (fix issue
  #354)
* Install: ignore some regular options of an Autoconf :file:`configure` script
  that are useless for this project but usually implied in build macros (like
  RPM ``%configure`` macro).
* Install: ignore unsupported ``--enable-*`` and ``--with-*`` options on
  :file:`configure` script rather raise an error and add support to define
  environment variable and build system type as :file:`configure` script
  arguments to comply with `GNU configuration recommendations`_.
* Install: fix :file:`modulecmd` pre-alternatives check in RPM spec file.
* Install: use ``%make_build`` and ``%make_install`` macros in RPM spec file.
* When :mfcmd:`module switch<module>` command is used in modulefile, do not
  state when processing it a conflict over switched-off module if its
  specification on the ``module switch`` command also matches switched-on
  module's specification. Allow this way the replacement of any loaded version
  of a module for a specific one required by currently loading module. (fix
  issue #355)
* Correctly report failed attempts to load module requirements expressed with
  advanced version specifiers. (fix issue #356)

.. _GNU configuration recommendations: https://www.gnu.org/prep/standards/html_node/Configuration.html


Modules 4.5.2 (2020-07-30)
--------------------------

* Init: :subcmd:`list` and :subcmd:`source` sub-commands do not take available
  modules as argument in fish completion script.
* Init: fix option list for :subcmd:`search` sub-command in bash completion
  script.
* Fix double error counter increase when modulefile evaluation breaks.
* Install: adapt :file:`configure` script to pass to the :file:`configure`
  script of Modules compatibility version only a subset of the options it
  supports (most commonly used options).
* Install: raise an error when an unknown option is passed to
  :file:`configure` script rather silently ignore it. (fix issue #348)
* Install: enable the definition of installation directory options of
  :file:`configure` script with the ``--option value`` syntax in addition to
  the ``--option=value`` syntax. (fix issue #348)
* Doc: alphabetically sort sub-commands of :mfcmd:`module-info` modulefile Tcl
  command in :ref:`modulefile(5)` document.
* Script: clean previously built environment-modules RPMs in :command:`mrel`.
* Clearly separate quarantine variable definition from tclsh binary on
  :file:`modulecmd.tcl` evaluated command call in ``_module_raw`` function for
  *sh*, *bash*, *ksh* and *zsh* shells. (fix issue #350)
* Doc: clarify in documentation index that Environment Modules should not be
  confused with language-specific modules. (contribution from Rob Hurt)
* Adapt conflict detection tests to ensure a module loaded by its full
  pathname will not detect itself as a conflict when declaring a reflexive
  conflict. (fix issue #352)
* Adapt the :command:`mrel` and :command:`mpub` commands to produce new
  Modules release from a *vZ.Y.x* git branch rather than from the repository
  main branch.


Modules 4.5.1 (2020-06-01)
--------------------------

* Install: consistently output Makefile warning messages on stderr.
* Script: add the ``mrel`` script, that automates build of the Modules release
  files and performs tests over these distribution files to guaranty their
  correctness.
* Script: add the ``mpub`` script, that automates Modules new release
  publishing over git repositories and websites.
* Install: remove project-specific tools from git repository export thus from
  release distribution files.
* Disable pager when ``clear`` sub-command is called from ``ml`` shortcut
  command. (fix issue #338)
* In case a modulefile evaluation fails, environment context prior this failed
  evaluation is restored. Fix environment variable restoration mechanism to
  keep the link that monitors and updates environment variable array ``env``
  in every Tcl sub-interpreters. (fix issue #340)
* Ensure environment variable change at the Tcl interpreter level is
  propagated to every sub-interpreters used to evaluate modulefiles or
  modulercs. (fix issue #342)
* Use absolute path to load Modules Tcl extension library. (fix issue #344
  with contribution from Roy Storey)
* Fix formatting of error stack trace not to look for internal commands to
  withdraw if start-up stack pattern cannot be matched.


Modules 4.5.0 (2020-04-07)
--------------------------

* Doc: fix typos and grammar mistakes on :ref:`module(1)`,
  :ref:`modulefile(5)` and :ref:`changes` documents. (contribution from Colin
  Marquardt)
* Doc: update cookbook recipes to highlight code of the Tcl scripts included.
  (contribution from Colin Marquardt)
* Doc: improve markup of :ref:`module(1)`, :ref:`modulefile(5)` and
  :ref:`changes` documents to enable references to module sub-commands,
  command line switches, environment variables and modulefile Tcl commands.
  (contribution from Colin Marquardt)
* Doc: alphabetically sort module sub-commands, command-line switches,
  environment variables and modulefile Tcl commands in :ref:`module(1)` and
  :ref:`modulefile(5)` documents.
* Introduce the ``ml`` command, a handy frontend to the ``module`` command.
  ``ml`` reduces the number of characters to type to trigger ``module``. With
  no argument ``ml`` is equivalent to ``module list``, ``ml mod`` corresponds
  to ``module load mod`` and ``ml -mod`` means ``module unload mod``. Multiple
  modules to either load or unload can be combined on a single command. ``ml``
  accepts all command-line switches and sub-commands accepted by ``module``
  command. ``ml`` command is defined by default. Its definition can be
  controlled at ``./configure`` time with :instopt:`--enable-ml` option or
  later on with :mconfig:`ml` configuration option (which defines
  ``MODULES_ML`` environment variable when set).
* Fix module sub-command abbreviation match to ensure passed abbreviated
  form fully match sub-command, not only its minimal abbreviated form. As an
  example, ``lod`` or ``loda`` do not match anymore the ``load``
  sub-command, ``lo`` or ``loa`` still do.
* Add the ``-j``/``--json`` command line switches to the ``avail``, ``list``,
  ``savelist``, ``whatis`` and ``search`` module sub-commands to render their
  output in `JSON`_ format. (fix issue #303)
* Script: remove need to build project management-specific tools
  (``mtreview``, ``mb``, ``mlprof`` and ``playdemo``) prior using them.
* Script: gather all distributed and maintained scripts in a ``script``
  directory at the root of the project repository tree.
* Install: provide Windows-specific batch files when ``./configure`` option
  :instopt:`--enable-windows-support` is set. module command wrapper
  ``module.cmd`` is installed in ``bindir`` and initialization script
  ``cmd.cmd`` in ``initdir``. Those batch files are relocatable and expect
  ``modulecmd.tcl`` in ``..\libexec`` directory. (fix issue #272 with
  contribution from Jacques Raphanel)
* Install: add ml command wrapper ``ml.cmd`` and install it in ``bindir`` when
  ``./configure`` option :instopt:`--enable-windows-support` is set.
* Install: introduce envml command wrapper ``envml.cmd`` for Windows ``cmd``
  shell and install it in ``bindir`` when ``./configure`` option
  :instopt:`--enable-windows-support` is set. (contribution from Jacques
  Raphanel)
* Doc: improve documentation portal index.
* Install: add ``dist-win`` target to Makefile in order to build a
  distribution zipball containing the required files to run Modules on a
  Windows platform. ``INSTALL.bat`` and ``UNINSTALL.bat`` Windows batch files
  are introduced and shipped in the zipball to automate installation and basic
  configuration of Modules on the Windows platform.
* Doc: update :ref:`INSTALL-win` document to describe how to install Modules
  with newly provided Windows-specific distribution zipball.
* Install: enable build of Modules from ``git archive`` tarball or zipball
  exports (like download source archives automatically provided on GitHub
  project)
* Install: ship reStructuredText and MarkDown source documents at the root of
  Modules distribution tarball rather their built txt counterpart.
* Script: fix ``createmodule.sh`` script to correctly analyses environment
  when shell functions are found defined in it.
* Script: inhibit output generated by scripts evaluated by ``createmodule.sh``
  and ``createmodule.py`` to ensure these outputs will not get in the way when
  analyzing the environment changes. (fix issue #309)
* Correctly handle symbolic version target including a whitespace in their
  name.
* Testsuite: output test error details whatever the testsuite run verbose
  mode.
* Install: adapt configure script and Makefile to detect ``python`` command
  location and set it as shebang for ``createmodule.py`` and
  ``gitlog2changelog.py``. If ``python`` command is not found, ``python3``
  then ``python2`` are searched.
* Install: enable to pass a specific Python interpreter command name or
  location at configure step with :instopt:`--with-python` option. Specified
  command name or location should be found on build system only if building
  from git repository.
* Install: build ``createmodule.py`` script and install it in ``bindir``.
* Install: update RPM spec file to explicitly define Python interpreter
  location.
* Script: fix ``createmodule.py`` script for Python3 (fix issue #315 with
  contribution from Armin Wehrfritz)
* Lift Perl variable strictness when defining ``_mlstatus`` variable in case
  ``modulecmd.tcl`` output is directly evaluated without use of the ``module``
  sub-routine in Perl script. (with contribution from Andrey Maslennikov)
* Script: fix path de-duplication in ``createmodule.sh``. (fix issue #316)
* Doc: add *Handling Compiler and other Package Dependencies* cookbook
  recipe, which discusses various strategies for creating modulefiles for
  packages with multiple builds depending on previously loaded compiler,
  MPI libraries, etc. (contribution from Tom Payerle)
* Init: test availability of ``compopt`` Bash builtin prior using it in
  Bash completion script to avoid error with versions of this shell older
  than 4.0. (fix issue #318)
* Install: adapt configure step to detect if ``sed`` option ``-E`` is
  supported and fallback to ``-r`` otherwise in shell completion scripts.
  (fix issue #317)
* Add support for the ``NO_COLOR`` environment variable
  (https://no-color.org/) which when set (regardless of its value) prevents
  the addition of ANSI color. When set, ``NO_COLOR`` prevails over
  ``CLICOLOR`` and ``CLICOLOR_FORCE`` environment variables. ``MODULES_COLOR``
  overrides these three variables. (fix issue #310)
* Script: when analyzing environment variable changes in ``createmodule.sh``
  applied by shell script passed as argument, produce a ``setenv`` modulefile
  statement for any variable found set prior script evaluation and for which
  value is completely changed after script evaluation. (fix issue #320)
* When an error message is composed of multiple lines, render it in the same
  way whether it is part of a block message or not: lines after the first one
  are prepended with a 2-space padding. As a result error messages appear
  clearly separated from each other.
* Append to the error message the error stack trace when a general unknown
  error occurs in ``modulecmd.tcl`` and provide a link to encourage users to
  report such error to the GitHub project.
* Add to the error message the error stack trace for errors occurring during
  site-specific configuration evaluation. Error stack is expunged from the
  ``modulecmd.tcl`` internals to only report information relevant to
  site-specific configuration file.
* When an error occurs during the evaluation of a modulefile or a modulerc,
  report associated error stack trace expunged from ``modulecmd.tcl`` internal
  references to only output useful information for users.
* GitHub: add issue templates to guide people submitting a bug report or a
  feature request.
* Doc: provide a link toward issues that have been fixed between versions 3.2
  and 4.0 in :ref:`changes` document.
* Script: introduce ``envml.cmd`` script for Windows platform providing
  similar behavior than ``envml`` Bash script. (contribution from Jacques
  Raphanel)
* Init: add Bash shell completion for the ``ml`` command. (contribution from
  Adrien Cotte)
* Fix Fish shell stderr redirection for newer Fish versions. (fix issue #325)
* Correctly handle modulefiles and modulepaths containing a space character in
  their name whether they are used from the command-line, in collections,
  within modulefiles or from loaded environment definitions.
* Doc: add *Default and latest version specifiers* design note.
* An ``avail`` search over a symbolic version targeting a directory now
  correctly returns the special modules (alias and virtual module) lying in
  this directory. (fix issue #327)
* ``whatis`` and ``paths`` searches only return special modules (symbolic
  version, alias and virtual modules) that fully match search query, not
  those that partially match it. (fix issue #328)
* alias and virtual module whose name mention a directory that does not
  exists are correctly handled. (fix issue #168)
* Hide special modules (aliases, symbolic versions and virtual modules)
  whose version name starts with a dot character (``.``) from ``avail``,
  ``whatis`` and ``paths`` searches if their query does not fully match
  special module name. (fix issue #329)
* Filter-out from the output of the ``aliases`` sub-command all hidden
  aliases, symbolic versions or hidden modules targeted by a non-hidden
  symbolic version. (fix issue #330)
* Enable resolution of default module in module sub-directory when this
  default symbol targets a hidden directory (whose name starts with a dot
  character). (fix issue #331)
* Doc: clarify hidden module location in :ref:`modulefile(5)` man page.
* Install: define ``LD_PRELOAD`` as quarantine var along with
  ``LD_LIBRARY_PATH`` in RPM specfile.
* When :mconfig:`implicit_default` and :mconfig:`advanced_version_spec`
  configuration are enabled, automatically define a ``default`` and ``latest``
  symbolic version for each module name (at each module depth for deep
  modules) if those version names does not already exist. (fix issue #210)
* Once a module is loaded, the automatically defined symbols associated to it
  are recorded in loaded environment in the ``MODULES_LMALTNAME`` environment
  variable. They are distinguished from the other alternative names applying
  to the module by a ``as|`` prefix, which qualifies their *auto symbol* type.
* When an advanced version specifier list contains symbolic version
  references, fix resolving to honor default version if part of the specified
  list. (fix issue #334)

.. _JSON: https://tools.ietf.org/html/rfc8259


.. _4.4 release notes:

Modules 4.4.1 (2020-01-03)
--------------------------

* Fix error and warning messages relative to dependency management to enclose
  dependency specification in single quotes to clearly distinguish
  specification from each other.
* Skip output of module loading message if module is already loaded.
* Doc: add demonstration material played at SC19 to promote the new features
  of Modules.
* Contrib: add ``playdemo`` script to play recorded demonstration cast.
* Doc: add a web anchor to each modulefile Tcl command, module sub-command
  and module environment variable documentation.
* Install: update RPM spec file to enable build on ``el8``.
* Doc: fix RST syntax for bullet lists in design docs. (fix issue #306)
* In case ``module avail`` query does not match a directory but only its
  contained elements (for instance ``module av mod/7`` matches ``mod/7.1`` and
  ``mod/7.2`` but not ``mod/``), fix query processing to correctly return
  latest or default element in case ``--latest`` or ``--default`` flags are
  set.
* In case a ``module avail`` query performed in a no-indepth mode with
  ``--latest`` or ``--default`` flags either enabled or disabled, fix query
  processing to return directory elements if they are part of result.
* When a ``module avail`` query performed in no-indepth mode targets a virtual
  module, fix result to filter-out the directory holding the virtual module
  from result.
* Fix ``module avail --default`` queries when modulefile default version does
  not match query: select latest version from modulefiles matching query
  unless ``implicit_default`` configuration is disabled in which case no
  default version is returned.
* Improve highlighting of module ``avail`` and ``whatis`` search result by
  coloring module names matching search query expressed with the advanced
  version specifiers. ``name@1,3`` or ``name@1:3`` queries now highlight
  ``name/1`` and ``name/3`` strings found in search result.
* Contrib: add the ``mlprof`` script which wraps ``modulecmd.tcl`` to collect
  profiling information on its execution.
* Contrib: adapt ``mb`` script to profile ``modulecmd.tcl`` run tests rather
  bench them when ``profile`` argument is passed to the script.
* Improve overall performances of module names and versions comparison by
  introducing optimized procedures and caching in memory module search
  results.


Modules 4.4.0 (2019-11-17)
--------------------------

* Doc: add *Return file basename on module-info name for full path modulefile*
  recipe to cookbook. (fix issue #297)
* Rework internal handling of configuration options to gather all option
  definitions in a global array and use the same initialization and retrieval
  procedure, named ``getConf``, for all these options.
* Add the ``setConf``, ``unsetConf`` and ``lappendConf`` procedures to provide
  unified ways to set the value of configuration option. These procedures
  should be used in site configuration files to override configuration option
  value instead of directly setting corresponding option variable as it was
  done in previous Modules releases.
* Add the ability to match module specification in a case insensitive manner.
  Default case sensitiveness behavior is set at ``./configure`` time with the
  ``--with-icase`` option. It could be superseded with the ``MODULES_ICASE``
  environment variable, that could be set with ``config`` module sub-command
  through the ``icase`` option. Command-line switch ``--icase`` (``-i``)
  enables to supersede defined case sensitiveness configuration. (fix issue
  #212 with contribution from Eric Deveaud)
* Introduce the extended default mechanism, to help selecting a module when
  only the first numbers in its version are specified. Starting portion of the
  version, part separated from the rest of the version string by a ``.``
  character, will get matched to the appropriate complete version name. In
  case multiple versions match partial version specified and only one module
  should be returned, default version (implicit or explicit) among matches is
  returned. In case ``implicit_default`` option is disabled and no explicit
  default is found among matches, an error is returned. This mechanism is
  enabled through a new configuration option named ``extended_default`` (which
  defines ``MODULES_EXTENDED_DEFAULT`` environment variable when set). It may
  be enabled by default in ``modulecmd.tcl`` script with option
  ``--enable-extended-default`` passed to the ``./configure`` script.
* Introduce the advanced module version specifiers mechanism to specify finer
  constraints on module version. This new feature enables to filter the module
  selection to a given version list or range by specifying after the module
  name a version constraint prefixed by the ``@`` character. It leverages the
  version specifier syntax of the `Spack`_ package manager. A single version
  can be specified with the ``@version`` syntax, a list of versions with
  ``@version1,version2,...``, a greater than or equal to range with
  ``@version1:`` syntax, a less than or equal to range with ``@:version2`` and
  an in between or equal to range with ``@version1:version2`` syntax. In case
  ``implicit_default`` option is disabled and no explicit default is found
  among version specifier matches, an error is returned. This mechanism is
  enabled through a new configuration option named ``advanced_version_spec``
  (which defines ``MODULES_ADVANCED_VERSION_SPEC`` environment variable when
  set). It may be enabled by default in ``modulecmd.tcl`` script with option
  ``--enable-advanced-version-spec`` passed to the ``./configure`` script.
* Conflict defined with a generic module name or an advanced version specifier
  may match multiple loaded modules (generally in case multiple loaded modules
  share same root name). Loaded environment analysis has been fixed to bind
  conflict to all loaded modules matching it. As a result the *Dependent
  Reload* mechanism is not triggered when one loaded module matching conflict
  is removed if another loaded module still match the conflict.
* Doc: add *Module selection contexts*, *Insensitive case*, *Extended default*
  and *Advanced module version specifiers* design notes.
* Make ``MODULESHOME`` environment variable controllable through the
  ``config`` sub-command with ``home`` configuration option. A
  ``--with-moduleshome`` argument is also added to the ./configure script to
  set specific default value for this option at installation time. (fix issue
  #292)

.. _Spack: https://github.com/spack/spack


.. _4.3 release notes:

Modules 4.3.1 (2019-09-21)
--------------------------

* Contrib: add ``mb`` script to bench Modules versions.
* Correct ``modulecmd.tcl`` script startup to correctly report error in case
  Tcl extension library fails to load. (fix issue #284)
* Install: fix typo on ``CFLAGS`` definition in ``lib/Makefile``. (fix issue
  #287 with contribution from Felix Neumärker)
* Remove useless code in Modules Tcl extension library
* Make URLs in README correctly rendered in HTML. (contribution from Per
  Persson)
* Doc: clarify modulefile evaluation modes in modulefile.4 man page. (fix
  issue #289)
* When looking at the closest match among loaded modules when switching module
  with just a single module argument specified, load the information on the
  currently set environment to get the alternative names of loaded modules
  prior to look at closest module match. (fix issue #290)
* Doc: describe the way to determine the site-specific configuration script
  location in cookbook recipes implying the installation of such a file. (fix
  issue #266)
* Doc: add *Log module command* recipe to cookbook. (fix issue #283)
* Doc: add *Expose procedures and variables to modulefiles* recipe to
  cookbook.
* Doc: add *Make defined modulepaths persist over sudo* recipe to cookbook.
* Doc: add *Ensure user fully qualify the modules they use* recipe to
  cookbook.
* Introduce the ``wa_277`` configuration option to workaround an issue with
  Tcsh history mechanism. Default ``module`` alias definition for Tcsh hits
  an issue with shell history mechanism: erroneous history entries are
  recorded each time the ``module`` command is called. When ``wa_277`` option
  is enabled (which sets the ``MODULES_WA_277`` environment variable to *1*),
  an alternative module alias is defined which fixes the history mechanism
  issue. However the alternative definition of the module alias weakens shell
  evaluation of the code produced by modulefiles. Characters with special
  meaning for Tcsh shell (like *{* and *}*) may not be used anymore in shell
  alias definition elsewhere the evaluation of the code produced by
  modulefiles will return a syntax error. (fix issue #277)
* Doc: add *Tips for Code Reuse in Modulefiles* recipe to cookbook.
  (contribution from Tom Payerle)
* Fix the ``whatis`` and ``paths`` sub-command results for module symbolic
  versions targeting a directory when ``implicit_default`` configuration
  option is disabled. No error is returned and same result is now obtained
  whether the symbolic name or its target is used as argument for those two
  sub-commands. (fix issue #294)
* Fix the ``whatis`` and ``paths`` sub-command results for module aliases
  targeting a directory when ``implicit_default`` configuration option is
  disabled. No error is returned and same result is now obtained whether the
  alias name or its target is used as argument for those two sub-commands.
  (fix issue #295)
* Rework all the ternary operator expressions in ``modulecmd.tcl`` that may
  result in a *nan* value (whatever the case used to write this string) as the
  ``expr`` Tcl command raises an error when it returns such a value, which
  breaks Modules as soon as a modulefile, an alias or a symbolic version is
  named *nan*. (fix issue #296)


Modules 4.3.0 (2019-07-26)
--------------------------

* Introduce Vim addon files to highlight the modulefile syntax. Installation
  of these files, which is enabled by default, is controlled by the
  ``--enable-vim-addons`` and ``--vimdatadir`` configure options.
  (contribution from Felix Neumärker)
* If modulefile is fully read, cache the content read and the file header
  computed to avoid another file read if the same modulefile need to be read
  multiple times.
* Except for path, paths, list, avail and aliases module commands always fully
  read a modulefile whether its full content is needed or just its header to
  verify its validity. Proceed this way to only read file once on commands
  that first just check modulefile validity then read again valid files to get
  their full content.
* Introduce Modules Tcl extension library (written in C) to extend Tcl
  language in order to provide more optimized I/O commands to read a file or a
  directory content than native Tcl commands do.
* Install: add ``--libdir``, ``--enable-libtclenvmodules``, ``--with-tcl`` and
  ``--with-tclinclude`` options to configure script to control
  libtclenvmodules build and installation.
* When an error is caught during modulecmd.tcl first initialization steps,
  ensure the error report facility is initialized to render error message.
* When looking for modulefiles in enabled modulepaths, take ``.modulerc`` file
  found at the root of a modulepath directory into account. Which means these
  rc files are now evaluated like global rc files and can be used to define
  module aliases targeting modulefiles stored in the underlying file tree.
* Correctly get available default (-d) and latest (-L) version whether search
  pattern is passed with an ending forward slash character or not or if it
  contains a ``*`` wildcard character.
* Append a forward slash character to any directory result of an avail command
  to better distinguish these directories from regular files.
* Introduce the ability to control whether ``avail`` command search results
  should recursively include or not modulefiles from directories matching
  search query by use of the ``--indepth`` and ``--no-indepth`` command-line
  switches or the environment variable ``MODULES_AVAIL_INDEPTH``. Default
  behavior is set at the ``./configure`` time with the
  ``--enable-avail-indepth`` and ``--disable-avail-indepth`` switches. (fix
  issue #150)
* Update ``bash``, ``fish`` and ``zsh`` completion scripts to propose
  available modulefiles in the no in depth mode.
* Add the ability to graphically enhance some part of the produced output to
  improve readability by the use of the ``--color`` command-line switch or the
  ``MODULES_COLOR`` environment variable. Both accept the following values:
  ``never``, ``auto`` and ``always``. When color mode is set to ``auto``,
  output is colored if stderr is attached to a terminal. Default color mode
  could be controlled at configure time with the ``--enable-color`` and the
  ``--disable-color`` option, which respectively correspond to the ``auto``
  and ``never`` color mode.
* Control the color to apply to each element with the ``MODULES_COLORS``
  environment variable or the ``--with-dark-background-colors`` and
  ``--with-light-background-colors`` configure options. These variable and
  options take as value a colon-separated list in the same fashion
  ``LS_COLORS`` does. In this list, each element that should be highlighted is
  associated to a Select Graphic Rendition (SGR) code.
* Inform Modules of the terminal background color with the
  ``MODULES_TERM_BACKGROUND`` environment variable or the
  ``--with-terminal-background`` configure option, which helps to determine if
  either the dark or light background colors should be used to color output in
  case no specific color set is defined with the ``MODULES_COLORS``.
* Color prefix tag of debug, error, warning, module error and info messages.
* Highlight the modulefile or collection name when reporting messages for a
  an action made over this modulefile or collection.
* Color the modulepaths reported on a ``use`` command.
* Highlight title of separator lines or column name of table header.
* Color modulepaths, directories, aliases and symbols reported by the
  ``avail``, ``aliases``, ``list``, ``whatis`` and ``search`` commands.
* When color mode is enabled and module aliases are colored, do not associate
  them a ``@`` tag as the color already distinguish them from regular
  modulefile.
* When color mode is enabled and a Select Graphic Rendition (SGR) code is set
  for the ``default`` modulefile symbol, apply this SGR code to the modulefile
  name instead of associating it the ``default`` symbol tag.
* Highlight matched module search query string among ``avail``, ``whatis`` and
  ``search`` command results.
* Highlight the modulefile and collection full path name on ``display``,
  ``help``, ``test`` and ``saveshow`` command reports.
* Color modulefile Tcl commands set in a modulefile on a ``display`` command
  report.
* Color module commands set in a collection on a ``saveshow`` command report.
* Re-introduce ``clear`` sub-command. (fix issue #203)
* Leverage ``--force`` command-line switch on ``clear`` sub-command to skip
  confirmation dialog. (fix issue #268)
* Init: improve readability of variable definition operations by writing one
  definition operation per line rather having multiple commands on a single
  line like ``VAR=val; export VAR``. (fix issue #225)
* Add the ability to define a site-specific configuration file with an
  environment variable: ``MODULES_SITECONFIG``. When set, the script file
  pointed by the variable is sourced (if readable) after the site-specific
  configuration file initially defined in ``modulecmd.tcl``. (contribution
  from Ben Bowers, fix issue #234)
* Doc: add description in the module.1 man page of ``MODULERCFILE`` in the
  environment section and ``siteconfig.tcl`` in the files section.
* Install: provide at installation time a bare site-specific configuration
  script in designated ``etcdir`` if no pre-existing ``siteconfig.tcl`` file
  is found at designated location.
* Introduce the ``config`` sub-command to get and set ``modulecmd.tcl``
  options and to report its current state.
* Contrib: update ``createmodule.py`` script to support execution from the
  *cmd* shell. (contribution from Jacques Raphanel, fix issue #270)
* Add the ability to configure when unloading a module and multiple loaded
  modules match request if firstly loaded module should be chosen or lastly
  loaded module. Configure option ``--with-unload-match-order`` defines this
  setting which can be superseded with the ``MODULES_UNLOAD_MATCH_ORDER``
  environment variable. This variable can be set with the option
  ``unload_match_order`` on the ``config`` sub-command. By default, lastly
  loaded module is selected. It is recommended to keep this behavior when the
  modulefiles used express dependencies between each other.
* Add the ability to configure whether an implicit default version should be
  defined for modules with no default version explicitly defined. When
  enabled, which stays the default behavior, a module version is automatically
  selected (latest one) when the generic name of the module is passed. When
  implicit default selection is disabled, the name of modules to evaluate
  should be fully qualified elsewhere an error is returned. This option is set
  at ``./configure`` time with the ``--enable-implicit-default`` and
  ``--disable-implicit-default`` options. It could be superseded with the
  ``MODULES_IMPLICIT_DEFAULT`` environment variable, that could be set with
  ``config`` module sub-command through the ``implicit_default`` option.
* Install: add to the configure script the ``--with-locked-configs`` option to
  ignore environment variable superseding of Modules configurations defined in
  ``modulecmd.tcl`` script. Lockable configuration option are
  ``extra_siteconfig`` and ``implicit_default``. Currently locked options are
  reported through the ``locked_configs`` option on the ``config``
  sub-command.
* Introduce the ability to control the module search match. Search query
  string should match module name start or any part of module fully qualified
  name. Default search match behavior is set at ``./configure`` time with the
  ``--with-search-match`` option. It could be superseded with the
  ``MODULES_SEARCH_MATCH`` environment variable, that could be set with
  ``config`` module sub-command through the ``search_match`` option.
  Command-line switches ``--starts-with`` (``-S``) and ``--contains`` (``-C``)
  for ``avail`` module sub-command enable to supersede defined search match
  configuration.
* Introduce the ability not to set the shell startup file that ensure
  ``module`` command is defined once shell has been initialized. Setting shell
  startup file currently means defining ``ENV`` and ``BASH_ENV`` environment
  variables to the Modules bourne shell initialization script. ``./configure``
  options ``--enable-set-shell-startup`` and ``--disable-set-shell-startup``
  define if shell startup should be set or not by default. It could be
  superseded with the ``MODULES_SET_SHELL_STARTUP`` environment variable, that
  could be set with ``config`` module sub-command through the
  ``set_shell_startup`` option.
* Cookbook: add the *test-modulefiles* recipe. (fix issue #182 with
  contribution from Colin Marquardt)
* Fix location of global RC file to ``@etcdir@/rc`` instead of
  ``@prefix@/etc/rc`` to cope with ``@etcdir@`` specific setup (``@etcdir@``
  defaults to ``@prefix@/etc``).
* Take into account Modules initialization configurations found in ``etc``
  directory if they exist rather in ``init`` directory. If ``initrc``
  configuration file is found in ``etcdir`` then it is preferred over
  ``modulerc`` file in ``initdir``. Following the same trend, ``modulespath``
  configuration file is found in ``etcdir`` then it is preferred over
  ``.modulespath`` file in ``initdir``.
* Introduce the ability to install the Modules initialization configuration
  files in the ``etcdir`` rather than in the ``initdir``. A new configure
  option is introduced for this task: ``--with-initconf-in``. Accepted values
  for this option are: ``etcdir`` or ``initdir`` (default).
* Add the ``--enable-modulespath`` configure option, which is an alias for the
  ``--enable-dotmodulespath`` option as ``.modulespath`` configuration file is
  named ``modulespath`` when installed in ``etcdic``.
* Install: update RPM spec file to disable ``set_shell_startup`` option by
  default, set ``/etc/environment-modules`` as configuration directory and
  store Modules initialization configuration files in it.
* Report an error when a module load or unload evaluation aborts due to the
  use of the ``break`` or ``exit`` modulefile commands. This error
  notification clarifies that module evaluation failed. (fix issue #267)
* Remove the message block display output for the ``reload``, ``purge`` and
  ``restore`` sub-commands to preserve this output style for modulefile
  evaluation modes (load, unload and switch) and thus clarify understanding.
* When unloading a module that contains a ``module load`` or ``module switch``
  modulefile command, inhibit the unload performed of the useless requirement
  when auto_handling mode is disabled if currently performing a ``purge``,
  ``reload`` or ``restore`` sub-command. As the unload sequence is determined
  and managed from these top commands.
* Add ability to control module command message verbosity with configuration
  option. Introduced verbosity levels from the least to the most verbose are
  ``silent``, ``concise``, ``normal``, ``verbose`` and ``debug``. This option
  could be set at ``./configure`` time with ``--with-verbosity`` option.
  It could be superseded with the ``MODULES_VERBOSITY`` environment variable,
  that could be set with ``config`` module sub-command through the
  ``verbosity`` option. Silent, verbose and debug verbosity modes can be set
  at the command-line level respectively with ``--silent``/``-s``,
  ``--verbose``/``-v`` and ``--debug``/``-D`` command-line switches. (fix
  issue #204)
* When verbosity level is ``normal`` or higher, reports every module loads or
  unloads performed to ``restore`` a collection or ``source`` a scriptfile,
  even if there is no specific message to output for these module evaluations.
  Clarifies what module evaluations have been triggered by these sub-commands.
* Also honor the ``CLICOLOR`` and ``CLICOLOR_FORCE`` environment variables to
  define color mode. (fix issue #279)


.. _4.2 release notes:

Modules 4.2.5 (2019-07-08)
--------------------------

* Correctly escape ``?`` character in shell alias. (fix issue #275)
* When resolving the enabled list of modulepaths, ensure resolved path
  entries are unique. (fix issue #274)
* Right trim '#' characters from the fetched modulefile magic cookie string
  to ensure a correct compatibility version comparison. Useful when modulefile
  first line is equal to ``#%Module4.2##############``.
* Fix argument parsing for the ``append-path``, ``prepend-path`` and
  ``remove-path`` modulefile commands to consider every arguments found after
  the variable name as variable values and not command option even if argument
  starts with ``-`` character. (fix issue #278)
* Fix automatic loading of modulefiles when multiple module names are set on a
  single ``module load`` modulefile command. When auto_handling mode was
  disabled, the load of not loaded modules was not achieved as soon as some
  modules on this list were already loaded. (fix issue #281)


Modules 4.2.4 (2019-04-26)
--------------------------

* Better track each module evaluation and the context associated to it in
  order to report a more accurate information on the additional modules
  loaded or unloaded when proceeding the main evaluation request. (fix issue
  #244, #245, #246, #247 and #248)
* Doc: preserve quotes and dashes when making HTML docs. (fix issue #250 with
  contribution from Riccardo Coccioli)
* Fix hanging ``list`` sub-command when terminal width is equal to the single
  column text width to be printed. (contribution from Jesper Dahlberg)
* During an additional evaluation triggered by an automated module handling
  mechanism, ensure warning and error messages are reported under the message
  block of the main evaluation. (fix issue #252)
* During the unload of a module when the automated module handling mode is
  disabled, report a warning message for each unload of a useless requirement
  that fails as done when the automated module handling mode is enabled. (fix
  issue #253)
* When multiple modules are listed on a ``prereq`` command, drop the output of
  those modules that fails to load (by the *Requirement Load* automated
  mechanism) to only keep the output of the module whose load succeed. (fix
  issue #254)
* Fix ``switch`` sub-command when the switched-off module cannot be unloaded
  when other loaded modules depend on it. Whole switch process is failed and
  no load of the switched-on module is attempted. (fix issue #251)
* When switching modules, report failure of switched-off module unload or
  switched-on module load under the message block of the switch action. A
  failed switched-off module unload is reported as an error, as it aborts the
  switch evaluation, whereas a failed switched-on module load is reported as a
  warning. (fix issue #255)
* When a module requirement is seen missing but the load of this module was
  attempted, report a more specific error or warning message to let user
  understand that the load of the requirement was attempted but failed. (fix
  issue #257)
* When loading a module, report any missing requirement on the message
  reporting block corresponding to this module load. This warning or error
  message comes in addition to the eventual *Requirement Load* message
  reported under the message block of the main evaluation. (fix issue #258)
* When unloading a module which has some dependent module still loaded,
  produce a more specific error or warning message if an evaluation of these
  dependent modules has been realized or if the unload of the required module
  is forced. (fix issue #259)
* When a conflicting module is seen loaded but the unload of this module was
  attempted, report a *Conflict Unload* error or warning message toward the
  main evaluation message block. (fix issue #261)
* When loading a module, report any loaded conflict on the message reporting
  block corresponding to this module load. This warning or error message comes
  in addition to the eventual *Conflict Unload* message reported under the
  message block of the main evaluation. (fix issue #261)
* Correctly report loading state of conflicting module. (fix issue #262)
* Adapt warning, error and info messages relative to the *Dependent Reload*
  mechanism to distinguish the unload phase from the load (reload) phase of
  this mechanism. In the automated module handling summary report, unloaded
  modules via this mechanism are reported in the *Unloading dependent* list
  and modules reloaded afterward are reported against the *Reloading
  dependent* list. (fix issue #263)
* When the automated module handling mode is disabled, do not attempt to load
  a requirement expressed in a modulefile with a ``module load`` command, if
  this requirement is already loaded or loading.
* Skip load or unload evaluation of a module whose respectively load or unload
  was already attempted but failed. If this second evaluation attempt occurs
  within the same main evaluation frame. (fix issue #264)
* When reloading modules through the *Dependent Reload* automated mechanism,
  prevent modules to automatically load of other modules with the ``module
  load`` modulefile command, as it is done for the ``prereq`` command. (fix
  issue #265)
* Raise an error when an invalid option is set on ``append-path``,
  ``prepend-path`` or ``remove-path`` modulefile command. (fix issue #249)
* Zsh initializes by default the ``MANPATH`` environment variable to an empty
  value when it starts. To preserve ``manpath`` system configuration even
  after addition to this variable by modulefiles, set ``MANPATH`` variable to
  ``:`` if found empty. (improve fix for issue #224)
* Doc: provide a short installation guideline in README file. (fix issue #230)


Modules 4.2.3 (2019-03-23)
--------------------------

* Add all the module dependency-related internal information to those saved
  prior a modulefile evaluation in order to correctly restore internal state
  in case modulefile evaluation fails.
* Init: in shell initialization scripts, initialize ``MANPATH`` if not set
  with a value that preserves ``manpath`` system configuration even after
  addition of paths to this variable by modulefiles. (fix issue#224)
* Enable to define an entire path entry to the ``MODULEPATH`` variable which
  corresponds to a variable reference only. (fix issue#223)
* Cookbook: add the *modulefiles-in-git* recipe. (contribution from Scott
  Johnson)
* When ``module switch`` commands are found in modulefiles, track switched-off
  modulefile as a conflict and switched-to modulefile as a requirement to
  apply same behaviors than for ``module load`` and ``module unload`` commands
  in modulefiles. If ``module switch`` has only one argument, do not define a
  conflict toward switched-off modulefile. *CAUTION: it is not recommended to
  use module switch command in modulefiles*. (fix issue#229)
* When unloading a module, revert ``module switch`` commands found in
  modulefile: switched-on module is converted to a ``module unload``, like for
  ``module load`` command. Nothing is done for switched-off module, like for
  ``module unload`` command. (fix issue#226)
* For default element in a modulefile directory which is a module alias that
  points to a modulefile, when this modulefile is loaded, it receives as
  alternative names the eventual module aliases set on the distant directory
  holding the alias pointing to it. (fix issue#231)
* When unloading a module that contains ``module load`` or ``module switch``
  commands in its modulefile, select for unload the automatically loaded
  requirement module which has been loaded prior its dependent. (fix
  issue#232)
* Doc: describe Emacs settings useful for adhering to coding conventions in
  CONTRIBUTING guide. (fix issue #233 with contribution from Ben Bowers)
* When looking for a loaded or loading dependency requirement, select among
  the eventual multiple candidates the closest match to the dependent module.
* During the unload of a module, if the unload of one of its dependent (by the
  *Dependent Unload* mechanism) fails, abort the whole unload process.
  Exception made if the force mode is enabled. In this case failing module
  stays loaded and the *Dependent Unload* mechanism continues with next module
  to unload.
* During the unload of a module, if the unload of one of its useless
  requirements (by the *Useless Requirement Unload* mechanism) fails, keep the
  requirements of this failing module loaded. Such error is reported as a
  warning and it does not stop the whole unload process. (fix issue#240)
* During the load or the unload of a module, if the unload of one of its
  dependent (by the *Dependent Reload* mechanism) fails, abort the whole
  unload or load process. Exception made if the force mode is enabled. In this
  case failing module stays loaded and *Dependent Reload* mechanism continues
  with next module to unload. This failing module is removed from the
  *Dependent Reload* list, so it will not take part of the load phrase of the
  mechanism. (fix issue#239)
* During the load or the unload of a module, if the load of one of its
  dependent (by the *Dependent Reload* mechanism) fails, abort the whole
  unload or load process. Exception made if the force mode is enabled. In this
  case failing module stays loaded and *Dependent Reload* mechanism continues
  with next module to load. When the mechanism is applied during a ``switch``
  command, force mode is enabled by default on the load phase. (fix issue#241)
* When reloading all loaded modules with the ``reload`` sub-command, if one
  reloading module fails to unload or load, abort the whole reload process to
  preserve environment sanity. (fix issue#237)
* During the unload of a module when the automated module handling mode is
  disabled and this module declares its requirements with the ``module load``
  modulefile command. If the unload of one of its useless requirements (by the
  *Useless Requirement Unload* mechanism) fails, whole unload process is not
  aborted and continue with next module to unload. (fix issue#238)
* Contrib: add ``mtreview`` utility script that analyzes test suite log file
  to compare actual and expected output of failed test. ``mt`` does not output
  the full test suite logs anymore but only the information produced by
  ``mtreview`` on failed tests.
* Install: exclude Continuous Integration configurations from dist tarballs.


Modules 4.2.2 (2019-02-17)
--------------------------

* Correct the *Dependent Unload* mechanism when it triggers the unload of 2
  modules making together a requirement from another module. This module is
  now also added to the dependent modules to unload.
* Doc: add a cookbook section in the documentation and port there the 3
  pre-existing recipes: *inhibit-report-info*, *top-priority-values* and
  *unload-firstly-loaded*.
* Doc: add a CONTRIBUTING guide.
* Doc: fix a typo on the Python initialization example in module man page.
* Doc: add a FAQ entry to describe the use of module from Makefile. (with
  contribution from Robert McLay)
* Trim any white-space, newline or ``;`` characters at the beginning or end of
  the function body passed to set-function modulefile command.
* Init: add recognition of the ``--auto``, ``--no-auto`` and ``--force``
  command-line switches in fish shell completion script.
* Init: add recognition of the ``--auto``, ``--no-auto``, ``--force``,
  ``--paginate`` and ``--no-pager`` command-line switches in zsh shell
  completion script.
* When the load of a modulefile is asked but a conflict is registered against
  this modulefile by an already loaded module, the load evaluation is now
  performed and the conflict is checked after this evaluation. If the conflict
  is still there, this evaluation (and the evaluation of its requirements) is
  rolled back. (fix issue#216)
* Init: fix ``_module_not_yet_loaded`` alias in tcsh completion script to
  handle situation when ``noclobber`` variable is set. Also ensure actual
  ``rm`` command is called and not an alias. (fix issue#219)
* Fix warning message when the load of a modulefile is forced over a reflexive
  conflict (message was reported twice).
* When looking at the dependency of a loaded module, only consider requirement
  loaded before dependent module (holding a prior position in the loaded
  module list) as valid. Those loaded after dependent module are considered as
  an unmet dependency thus they are not taking part in the *Dependent Unload*,
  the *Useless Requirement Unload* and the *Dependent Reload* mechanisms.


Modules 4.2.1 (2018-11-11)
--------------------------

* Cookbook: add the *inhibit-report-info* recipe.
* Cookbook: port *unload-firstly-loaded* and *top-priority-values* recipes to
  v4.2.
* Init: fix listing of loaded modules for *fish* and *tcsh* shell completions.
* Init: fix saved collection listing when no collection found for *bash*,
  *zsh*, *tcsh* and *fish* shell completions.
* Adapt ``system`` modulefile Tcl command to execute the command passed as
  argument through shell, like it is performed on compatibility version. (fix
  issue#205)
* Correctly filter modulefile search memory cache entries when using a full
  search result to search later on a specific modulefile.
* Prefix debug messages by information on the current modulefile or modulerc
  interpreter if any.
* Init: fix listing of loaded modules on unload and switch sub-commands for
  *bash* shell completion.
* Refrain ``module unload`` modulefile command from unloading a module
  required by another loading module.
* Enable ``is-loaded`` modulefile Tcl command in modulerc interpretation
  context, like done on compatibility version. (fix issue#207)
* Check a required module is not already loading before attempting to load it.
  Helps to handle cyclic dependencies.
* Compute loaded modules requirement dependency relations without cycle and
  consider the module closing the cycle in a constraint violation state to
  avoid reloading loops on the *Dependent Reload* mechanism.
* Safely unset dependency reference when computing dependency relations as
  some dependencies expressed may target same module.
* Ensure a loaded module matching multiple entries of a same *or* ``prereq``
  will just be considered as one module matching this requirement.
* Init: quote prompt in *csh* and *tcsh* script with ``:q`` rather double
  quotes to accommodate prompts with embedded newlines. (fix issue#209 with
  contribution from Satya Mishra)
* Init: skip shell environment alteration if ``autoinit`` command fails. (fix
  issue#208)
* Reword path-like variable element counter reference handling to simply
  ignore the counter values not coherent with the content of related
  path-like variable. (fix issue#206)


Modules 4.2.0 (2018-10-18)
--------------------------

* Add ``chdir`` and ``puts`` environment settings to the per-modulefile
  evaluation saved context. So previous values of these settings are restored
  in case of evaluation failure.
* Fix save and restore of ``x-resource`` environment settings on the
  per-modulefile evaluation context.
* Use the correct warning procedure to report the full reference counter
  inconsistency message (so this message is fully inhibited during global
  ``whatis`` evaluations).
* Make ``append-path``, ``prepend-path``, ``remove-path`` and ``unsetenv``
  commands alter ``env`` Tcl global array during ``display``, ``help``,
  ``test`` or ``whatis`` evaluation modes. Thus an invalid argument passed to
  these commands will now raise error on these modes. (see
  :ref:`v42-variable-change-through-modulefile-evaluation` section in
  MIGRATING document)
* On ``whatis`` mode, ``append-path``, ``prepend-path``, ``remove-path``,
  ``setenv`` and ``unsetenv`` commands initialize variables if undefined but
  do not set them to their accurate value for performance concern.
* Clear value instead of unsetting it during an unload mode evaluation of
  ``setenv`` or ``*-path`` commands to avoid breaking later reference to the
  variable in modulefile.
* Make ``getenv`` command returns value on ``help``, ``test`` or ``whatis``
  evaluation modes. (fix issue#188)
* Add an argument to the ``getenv`` command to return the value of this
  argument if the queried variable is undefined.
* Use a different modulefile interpreter for each evaluation mode.
* Adapt the procedure called for each modulefile command depending on the
  evaluation mode to adapt behavior of these commands to the module command
  currently running.
* Report calling name and arguments for modulefile commands on ``display``
  mode. For the commands evaluated during this mode, trigger this report at
  the end of the evaluation.
* Inhibit ``chdir``, ``conflict``, ``module``, ``module-log``,
  ``module-trace``, ``module-user``, ``module-verbosity``, ``prereq``,
  ``set-alias``, ``system``, ``unset-alias``, ``x-resource`` commands on
  ``help``, ``test`` and ``whatis`` evaluation modes.
* Ignore ``chdir``, ``module``, ``module-trace``, ``module-verbosity``,
  ``module-user`` and ``module-log`` commands found during modulerc
  evaluation.
* Correctly restore an empty string value on sub-interpreter global variables
  when sanitizing this interpreter between two modulefile/modulerc
  evaluations.
* Cache in memory results of a modulefile search to reuse it in case of rerun
  instead of re-walking the filesystem.
* Evaluate global rc files once module sub-command is known and registered,
  so it can be queried during their evaluation.
* Rename ``_moduleraw`` shell function in ``_module_raw`` to use a common
  ``_module_`` prefix for all module-related internal shell functions.
* Install: add ``--enable-append-binpath`` and ``--enable-append-manpath``
  configure options to append rather prepend the bin or man directory when
  adding them to the relative environment variable.
* Doc: clarify documentation for module usage on scripting language like Perl
  or Python to mention that arguments to the ``module`` function should be
  passed as list and not as a single string.
* When interpreting a ``setenv`` modulefile order during an unload evaluation,
  variable is still set to be unset in generated shell code but it is set to
  the value defined on the ``setenv`` order in the interpreter context instead
  of being cleared.
* Register the conflicts defined by loaded modules in the environment
  (variable ``MODULES_LMCONFLICT``) and ensure they keep satisfied. (see
  :ref:`v42-conflict-constraints-consistency` section in MIGRATING document)
* Register the prereqs defined by loaded modules in the environment (variable
  ``MODULES_LMPREREQ``) and ensure they keep satisfied. (see
  :ref:`v42-prereq-constraints-consistency` section in MIGRATING document)
* Introduce the automated module handling mode, which consists in additional
  actions triggered when loading or unloading a modulefile to satisfy the
  dependency constraints it declares. Those actions are when loading a
  modulefile: the *Requirement Load* and the *Dependent Reload*. When
  unloading a modulefile, *Dependent Unload*, *Useless Requirement Unload* and
  *Dependent Reload* actions are triggered. (see
  :ref:`v42-automated-module-handling-mode` section in MIGRATING document)
* Track the loaded modules that have been automatically loaded (with
  environment variable ``MODULES_LMNOTUASKED``) to distinguish them from
  modules that have been explicitly asked by user. This information helps to
  determine what module becomes a useless requirement once all its dependent
  modules are unloaded.
* Track in saved collections the loaded modules that have been automatically
  loaded by add of a ``--notuasked`` argument to ``module load`` collection
  lines. So this information is restored in loaded environment when collection
  is restored. This ``--notuasked`` argument is ignored outside of a
  collection restore context.
* Consider modules loaded from a ``module source`` file as explicitly asked by
  user.
* Install: add ``--enable-auto-handling`` configure option to enable or
  disable the automatic modulefile handling mechanism.
* Process list of loaded modules or modules to load one by one during the
  ``restore``, ``purge`` and ``reload`` sub-commands whatever the auto
  handling mode is.
* Add the ability to control whether the auto_handling mode should be enabled
  or disabled with an environment variable called ``MODULES_AUTO_HANDLING`` or
  from the command-line with ``--auto`` and ``--no-auto`` switches. These
  command-line switches are ignored when called from modulefile.
* Init: add pager-related command-line options in shell completion scripts.
* Doc: describe ``MODULES_LMCONFLICT``, ``MODULES_LMPREREQ`` and
  ``MODULES_LMNOTUASKED`` in module.1 man page.
* Add ``-f`` and ``--force`` command-line switches to by-pass dependency
  consistency during ``load``, ``unload`` or ``switch`` sub-commands. (see
  :ref:`v42-by-passing-module-constraints` section in MIGRATING document)
* Disallow collection ``save`` or loaded modules ``reload`` if some loaded
  modules have some of their dependency constraints unsatisfied.
* The *Dependent Reload* action of a ``load``, ``unload`` and ``switch``
  sub-commands excludes modules that have unsatisfied constraints and includes
  modules whose constraints are satisfied again (when sub-command process
  solves a conflict for instance).
* Doc: describe ``--force``, ``--auto`` and ``--no-auto`` command-line
  switches and ``MODULES_AUTO_HANDLING`` variable in module.1 man page.
* Ignore directories ``.SYNC`` (DesignSync) and ``.sos`` (SOS) when walking
  through modulepath directory content. (contribution from Colin Marquardt)
* Install: look for ``make`` rather ``gmake`` on MSYS2.
* Fix ``exec()`` usage in Python module function definition to retrieve the
  correct return status on Python3.
* Cookbook: add the *top-priority-values* and *unload-firstly-loaded* recipes.
* Install: add ``gcc`` to the build requirements in RPM specfile.
* Silent any prereq violation warning message when processing *Dependent
  Reload* mechanism or ``purge`` sub-command.
* Doc: mention ``createmodule.sh`` and ``createmodule.py`` scripts in FAQ.
  (fix issue#189)
* Register all alternative names of loaded modules in environment with
  ``MODULES_LMALTNAME`` variable. These names correspond to the symbolic
  versions and aliases resolving to the loaded modules. Helps to consistently
  solve ``conflict`` or ``prereq`` constraints set over these alternative
  names. (fix issue#143 / see
  :ref:`v42-consistency-module-load-unload-commands` section in MIGRATING
  document)
* Doc: describe ``MODULES_LMALTNAME`` in module.1 man page.
* Install: add ``--with-bin-search-path`` configure option to get in control
  of the path list used to search the tools required to build and configure
  Modules. (fix issue#164)
* Install: add ``--enable-silent-shell-debug-support`` configure option to add
  the ability to control whether or not code to support silent shell debug
  should be added to the module function and sh-kind initialization scripts.
  (fix issue#166)
* Install: add ``--enable-quarantine-support`` configure option to add the
  ability to control whether or not code to support quarantine mechanism
  should be added to the module function and initialization scripts.
  (fix issue#167)
* Check version set in modulefile magic cookie. If modulefile sets a version
  number greater than ``modulecmd.tcl`` script version, this modulefile is not
  evaluated like when no magic cookie is set at all. (fix issue#171 / see
  :ref:`v42-versioned-magic-cookie` section in MIGRATING document)
* Fix uninitialized variable in procedure producing list of element output.
  (fix issue#195)
* Ensure the consistency of ``module load`` modulefile command once the
  modulefile defining it has been loaded by assimilating this command to a
  ``prereq`` command. Thus the defined constraint is recorded in the
  ``MODULES_LMPREREQ`` environment variable. Same approach is used for
  ``module unload`` modulefile command which is assimilated to a ``conflict``
  command. Thus the defined constraint is recorded in the
  ``MODULES_LMCONFLICT`` environment variable. (see
  :ref:`v42-alias-symbolic-name-consistency` section in MIGRATING document)
* Only look at loaded modules when unloading so unloading an nonexistent
  modulefile does not produce an error anymore. (fix issue#199)
* Report error raised from modulefile evaluation as ``ERROR`` rather
  ``WARNING``, like when a conflict constraint is hit. Moreover this kind of
  evaluation error is now silenced on global evaluation like when processing
  ``avail`` or ``search`` sub-commands.
* Record messages to report them by block on when processing a ``load`` or an
  ``unload`` modulefile evaluation to improve readability on these evaluating
  modes that may cascade additional actions. (see
  :ref:`v42-module-message-report` section in MIGRATING document)
* Foreground ``load``, ``unload``, ``switch`` and ``restore`` actions (i.e.,
  asked on the command-line) now report a summary of the additional load and
  unload evaluations that were eventually triggered in the process.
* Support ``del`` and ``remove`` aliases for ``unload`` sub-command like on
  compatibility version. (fix issue#200 with contribution from Wenzler)
* Correctly transmit the arguments along with the command to execute on
  ``system`` modulefile command. (fix issue#201)
* Contrib: add ``mt`` utility script which helps to run just specific part of
  the test suite.
* Introduce ``set-function`` and ``unset-function`` modulefile commands to
  define shell function on sh-kind and fish shells. (fix issue#193 with
  contribution from Ben Bowers)


.. _4.1 release notes:

Modules 4.1.4 (2018-08-20)
--------------------------

* Doc: fix typo on ``getenv`` command description in modulefile(5) man page
  and clarify this command should be preferred over ``::env`` variable to
  query environment variable value in modulefile.
* Init: fix ``bash`` and ``zsh`` completion scripts to enable Extended Regular
  Expression (ERE) on ``sed`` command with ``-E`` argument (rather ``-r``) for
  compatibility with OS X's and BSDs' sed. (fix issue#178)
* Handle default version sets on an hidden modulefile (were not found
  previously). (fix issue#177)
* Init: fix ``ksh`` initialization script for ksh88 compatibility. (fix
  issue#159)
* Install: use ``sed`` command rather ``grep`` and ``cut`` in ``configure``
  and ``Makefile`` scripts. (fix issue#175 with contribution from Michael
  Sternberg)
* Fix typo, tab indentation and pipe opening mode on ``createmodule.py``
  utility script. (contribution from Jan Synacek)
* Check ``ModulesVersion`` value set from ``.version`` rc file to ensure this
  value refers to a version name in current directory. Report error if a
  nested value is detected and ignore this value. (fix issue#176)


Modules 4.1.3 (2018-06-18)
--------------------------

* Make ``setenv`` command alter ``env`` Tcl global array during ``help``,
  ``test`` or ``whatis`` evaluation modes. (fix issue#160)
* Doc: describe MANPATH variable special treatment on compatibility version
  in diff_v3_v4 document.
* Initialize and export _moduleraw SH shell function if ``stderr`` is attached
  to a terminal. Was previously checking ``stdout``. (fix issue#169)
* For ``csh`` shells, quote code generated by modulecmd.tcl to pass it to the
  ``eval`` shell command.
* Escape special characters when producing code to define shell aliases (fix
  issue#165)
* Correct modulefile lookup when a modulefile directory is overwritten by a
  module alias definition but it contains an empty sub-directory. (fix
  issue#170)
* Doc: describe ``getenv`` command in modulefile(5) man page.
* Improve SH shell detection in profile.sh initialization script to use shell
  variable on ``bash`` or ``zsh`` to determine current shell name. (fix
  issue#173)


Modules 4.1.2 (2018-03-31)
--------------------------

* Add an example global rc file in ``contrib/etc`` directory that ensures
  ``MODULEPATH`` is always defined.
* Check ``HOME`` environment variable is defined on ``savelist`` and
  ``is-saved`` commands or raise error if not.
* Fix saving of deep module default version in collection when version pinning
  is disabled: if ``foo/bar/version`` is default version for ``foo``,
  collection will retain just ``foo`` (was retaining ``foo/bar``).
* Enable to save and restore collections containing full path modulefiles
  eventually with no modulepath defined.
* Run ``puts`` command not related to ``stderr`` or ``stdout`` channels in
  calling modulefile context to correctly get access to the targeted file
  channel. (fix issue#157)
* Quote ``autoinit`` result for eval interpretation on SH-kind shells to avoid
  parameter expansion to randomly occur on generated code depending on file
  or directory names of current working directory. (fix RH bug#1549664)
* Ignore empty elements found in ``MODULEPATH``, ``LOADEDMODULES`` or
  ``_LMFILES_`` to ensure all elements in these variables are non-empty
  strings.
* Raise error if loaded environment is in an inconsistent state when calling
  commands requiring correlation of information from the ``LOADEDMODULES`` and
  the ``_LMFILES_`` environment variables. Error raised on ``load``,
  ``unload``, ``switch``, ``reload``, ``purge``, ``list``, ``save`` and
  ``restore`` commands. May affect ``info-loaded`` or ``is-loaded`` commands
  if module passed as argument to these command is specified as a full path
  modulefile.
* Fix ``list`` command to process loaded modules information before performing
  any content output.
* Install: adapt ``configure`` script and Makefiles to support installation on
  Cygwin system.
* Detect terminal width on Windows ``cmd`` terminal with ``mode`` command.
* Improve Windows ``cmd`` shell support: error code returned, echoing text,
  shell alias creation and removal, working directory change.
* Raise error when an empty module name is passed to module sub-commands like
  ``load``, ``display`` or ``unload``.
* Raise error when an empty collection name is passed to module sub-commands
  like ``save``, ``saveshow`` or ``restore``.
* Raise error when an empty path is passed to module ``unuse`` sub-command,
  like already done on ``use`` sub-command.
* Clear argument list if an empty module command name is passed.
* Fix ``module`` function definition for all shells in ``autoinit`` command to
  correctly handle empty-string parameters or parameters containing
  white-spaces, quotes, escape characters.
* Fix ``module`` function definition for Python to accept being called with no
  argument.
* Fix parameter expansion on ``module`` function for all SH-kind shells when
  quarantine mode is activated.
* Escape ``\`` character when producing R shell code.


Modules 4.1.1 (2018-02-17)
--------------------------

* Make separator lines, used on ``display`` command result for instance, fit
  small screen width.
* Install: give ability to build and install Modules from git repository
  without documentation if ``sphinx-build`` cannot be found.
* Install: adapt ``configure`` script and Makefiles to support installation on
  FreeBSD, Solaris and OS X systems. (fix issue#147)
* Rework code generated by ``autoinit`` for sh-kind shells to avoid use of
  local variables as those are defined differently through the sh variants.
  (also fix issue#147)
* Init: use a default value on undefined variables in sh-kind scripts to avoid
  unbound variables in bash ``-eu`` mode. (fix issue#151)
* Correctly detect terminal column number on Solaris.
* Init: fix csh init script to get compatibility with pure csh shell
* Sanitize content of ``MODULEPATH`` before using it at run-time, to make
  potential relative paths absolute, remove trailing slashes, etc. (fix
  issue#152)
* Check loaded modulefiles still exists before displaying statistics on them
  during a ``list`` action.
* Use a specific reference counter variable name (``MODULES_MODSHARE_<VAR>``
  instead of ``<VAR>_modshare``) for DYLD-specific variables. (fix issue#153)
* No error raise when updating a DYLD or LD path-like variable on OS X when
  System Integrity Protection (SIP) is enabled. In this situation, these
  variables are not exported in subshell context, so they appear undefined.
* Init: protect arguments passed to the ``_moduleraw`` sh function from
  interfering content of current working directory. (fix issue#154)
* Install: move ``hostname`` RPM requirement to the compat sub-package.
* Start pager process only if some text has to be printed. (partially fix
  issue#146)
* Ignore ``PAGER`` environment variable to configure Modules pager to avoid
  side effects coming from a general pager configuration not compatible with
  Modules pager handling. (fix issue#146)
* Do not blank anymore default Modules pager options if default pager is
  ``less`` when the ``LESS`` environment variable is defined. (fix issue#146)

.. warning:: With this bugfix release, changes have been made on the pager
   setup to avoid side effects coming from the system general pager
   configuration. As a result ``PAGER`` environment variable is now ignored
   and ``MODULES_PAGER`` should be used instead to adapt Modules pager
   configuration at run-time.


Modules 4.1.0 (2018-01-15)
--------------------------

* Extend stderr output redirection on sh-kind shells to all terminal-attached
  shell session, not only interactive shell session.
* Extend shell code produced by the ``autoinit`` command to perform the same
  environment initialization as done in ``init`` shell scripts (default value
  set for module-specific environment variables, parse or source of
  configuration files).
* Make init shell scripts rely on ``autoinit`` command to define the
  ``module`` command and setup its default environment.
* Fix error rendering code for Tcl shell by producing a call to the ``error``
  procedure.
* Introduce pager support to handle informational messages, using ``less``
  command with ``-eFKRX`` options by default. Environment variable
  ``MODULES_PAGER`` or ``PAGER`` may be used to supersede default pager
  command and options. ``--paginate`` and ``--no-pager`` switches enable or
  disable pager from the command line.
* Install: add ``--with-pager`` and ``--with-pager-opts`` configure options to
  define default pager command and its relative command-line options.
* Introduce quarantine mechanism to protect module execution against side
  effect coming from the current environment definition. Variables whose name
  has been put in ``MODULES_RUN_QUARANTINE`` will be emptied or set to the
  value hold by ``MODULES_RUNENV_<VAR>`` in the modulecmd.tcl run-time
  environment. Quarantine variable original value is then restored within
  modulecmd.tcl execution context once it has started.
* Install: add ``--with-quarantine-vars`` configure option to define at build
  time the ``MODULES_RUN_QUARANTINE`` and ``MODULES_RUNENV_<VAR>`` environment
  variables set in initialization scripts.
* Add ``MODULES_SILENT_SHELL_DEBUG`` environment variable to disable on sh
  shell and derivatives any ``xtrace`` or ``verbose`` debugging property for
  the duration of either the module command or the module shell initialization
  script. (fix issue#121)
* Change error code produced by modulecmd.tcl for the Tcl, Perl, Python, Ruby,
  CMake and R scripting languages to return a 'false' boolean value in case of
  error rather raising a fatal exception.
* Adapt module function definition for Tcl, Perl, Python, Ruby, CMake and R
  scripting languages to always return a value, result of the modulecmd.tcl
  run. When modulecmd.tcl run does not produce a specific status, a 'true'
  boolean value is returned. On CMake, resulting value is returned though a
  ``module_result`` global variable.
* Spool content sent to the stdout channel with ``puts`` command during a
  modulefile interpretation, to effectively transmit this content to stdout
  after rendering the environment changes made by this modulefile. (fix
  issue#113)
* Introduce ``append-path``, ``prepend-path``, ``remove-path`` and
  ``is-loaded`` module sub-commands, based on existing modulefile-specific
  Tcl commands. (fix issue#116)
* Introduce ``is-saved``, ``is-used`` and ``is-avail`` modulefile Tcl commands
  and module sub-commands to test availability of collection, modulepath or
  modulefile.
* Raise error when a call to ``path`` or ``paths`` module sub-commands is
  attempted during a modulefile interpretation. Both commands now return text
  rather print text on scripting languages. An empty string is returned in
  no match case instead of a false boolean value.
* Introduce ``module-info loaded`` modulefile command and its module
  sub-command counterpart ``info-loaded``. This new command returns name of
  the modules currently loaded corresponding to the name passed as argument.
  (fix issue#3)
* Fix ``is-loaded`` command to correctly handle multiple module names passed
  as argument (fix issue#138)
* Support no argument on ``is-loaded``, ``is-saved`` and ``is-used`` commands
  to return if anything is respectively loaded, saved or used.
* Interpret ``module source`` command set in modulefile in ``unload`` mode
  when the modulefile itself is interpreted in this mode.
* Consider a modulefile passed with name starting by ``./`` or ``../`` a full
  path name modulefile, like those starting by ``/``. These kind of names are
  converted to absolute path names, for instance to register them in loaded
  modulefile list during a ``load`` command.
* Correlate modulefile passed as full path name (starting by either ``./``,
  ``../`` or ``/``) to already loaded modulefile registered with regular
  module name (file name without its modulepath prefix) to prevent for
  instance from loading twice same modulefile. Correlate in the same way
  regular module name to already loaded full path name modulefile.
* Introduce ``MODULES_COLLECTION_PIN_VERSION`` environment variable to record
  modulefile version number when saving collections even if version
  corresponds to the default one. (fix issue#89)
* Fix location of ``etc/rc`` global RC file to ``@prefix@/etc/rc`` instead of
  ``$MODULESHOME/etc/rc`` not to depend on ``MODULESHOME`` environment
  variable value.
* Strengthen argument check for ``append-path``, ``prepend-path`` and
  ``remove-path`` modulefile Tcl commands and module sub-commands. Raise error
  if argument list is not correct.
* Fix support for the ``--delim=C`` argument form on ``append-path``,
  ``prepend-path`` and ``remove-path`` commands.
* Fix path reference counter handling in case path element is an empty string.
  Distinguish an empty path element from a variable set empty to clear it.
* Pass multiple path elements separated by delimiter character as one string
  on ``append-path``, ``prepend-path`` and ``remove-path`` commands.
* Accept multiple path element arguments on ``append-path``, ``prepend-path``
  and ``remove-path`` commands.
* Introduce the ``--duplicates`` argument option to ``append-path`` and
  ``prepend-path`` commands to add a path element already registered in
  variable.
* Introduce the ``--index`` argument option to ``remove-path`` command to
  delete a path entry by passing its position index in variable.
* Provide the ability to setup a site-specific configuration sourced at the
  start of ``modulecmd.tcl`` main procedure. This configuration is a Tcl
  script named ``siteconfig.tcl`` which enables to supersede any Tcl
  definition made in ``modulecmd.tcl``. Location of this file is controlled
  at configure time with the ``--etcdir`` option.
* Add the ability to handle paths containing reference to environment variable
  in ``MODULEPATH``. When these kind of paths are used by ``module`` command,
  the variable references are converted to their corresponding value or to an
  empty string if they are not defined.
* Enclose value set to environment variable on Tcl within curly braces rather
  double quotes to protect special characters in it from interpretation.
* Correctly parse ``.modulespath`` initialization file to handle lines without
  any ``#`` character or to handle files with no content to extract.
* Re-introduce the ``--enable-versioning`` configure option, which appends
  Modules version to installation prefix and deploy a ``versions`` modulepath
  shared between all versioning enabled Modules installation. A modulefile
  corresponding to Modules version is added to the shared modulepath and
  enables to switch from one Modules version to another.
* Fix removal of CMake generated temporary script file by stripping newline
  character from script file name.
* Add ``MODULES_CMD`` environment variable to expose path to the currently
  active module command script. This variable is set at initialization time.
* Introduce ``modulecmd`` wrapper script, installed in binary directory, which
  executes the active module command.
* Fix modulefile Tcl interpreter reset when handling list variables. (fix
  issue#145)
* Introduce 'module-virtual' modulefile Tcl command to associate a virtual
  module name to a modulefile. This module can be located with its virtual
  name and the associated modulefile is the script interpreted when loading,
  unloading, etc.
* Resolution of relative paths occurring during a modulefile interpretation to
  target a modulefile or a modulepath now takes the directory of the currently
  interpreted modulefile as the current working directory to solve the
  relative paths.


.. _4.0 release notes:

Modules 4.0.0 (2017-10-16)
--------------------------

Starting with this release, modules-tcl has become Modules. The following
changes describe the differences with last modules-tcl release (1.923). To
learn about the changes between this release and last Modules 3.2 release,
please see the :ref:`MIGRATING` document.

* Relax constraint on command-line argument position so options and
  switches can be passed either before or after command name.
* Report ``unsupported option`` warning rather stop on error when
  compatibility-version specific command-line switches are passed (
  ``--force``, ``--human``, ``--verbose``, ``--silent``, ``--create``,
  ``--icase``, ``--userlvl``).
* Keep empty ``module load`` line in shell configuration files after running
  the ``initrm`` or ``initclear`` commands.
* Always return the value of ``tcl_platform(osVersion)`` for ``uname release``
* Optimize code output, for Perl to only return ``1;`` once for a no-operation
  situation and for Python to not ``import os`` when there is only an error
  to render.
* Use value of system command ``uname -n`` for ``uname nodename``.
* Add support for CMake *shell*
* Ignore ``/`` character used as suffix in modulefile name passed on command
  line.
* Rename Perl initialization script in ``perl.pm`` and Python in
  ``python.py``.
* Add support for Ruby *shell* (with contribution from Tammo Tjarks)
* Add support for R *shell* (with contribution from Roy Storey)
* When a *default* is set for a given module name, target modulefile can
  be referred on as *modulename/default* in addition to just *modulename*.
* Locate symbolic versions on ``avail`` command even these symbols are set
  over a module alias or another symbolic version. In this situation the
  symbol spread along the resolution path until reaching a modulefile.
* Define a more standard shebang on modulecmd.tcl script.
* Determine modulefile corresponding to given module name using the loaded
  context only on ``unload`` situation.
* Enable to unload *mod/dir/subdir/vers* when unload of *mod* or *mod/dir*
  asked. Was previously working only if deep module to unload was also the
  default version for these root names.
* Make -l/-t switches mutually exclusive. Last switch mentioned on the
  command-line is honored.
* Output parsable modulepath header when -l/-t switches are enabled.
* When searching for a module in a given modulepath directory, if a module
  alias or a symbolic version matches searched module but the target of
  this alias or symbol is not found in current modulepath directory,
  search for this target restarting search from the first modulepath in
  list to ensure modulepath priority.
* Solve aliases or symbolic versions looking for all modulepaths on ``search``
  and ``paths`` commands. Was previously solved if their target was found in
  same modulepath directory.
* Add support for hidden *dot* modulefiles. A hidden modulefile does not
  appear in case of wild search, it is only returned when search is about
  its exact name.
* No table header print in --long mode on an ``avail`` command if no result
  are returned.
* Add blank line between displayed list of elements, for instance between
  modulepath content on ``avail`` command.
* Improve readability of error messages encountered during modulefile
  execution by putting Tcl error message first after the ``Module ERROR``
  prefix.
* Do not exit immediately when an internal error occurs in currently
  interpreted modulefile. Consider this interpretation as failed and
  continue to proceed the other modulefile arguments.
* When multiple modulefiles are passed on ``display``, ``help`` and ``test``
  commands only output one separator line between 2 interpreted modulefiles.
* Fix environment settings stack handling issue when restoring stack after
  a failed attempt to load a modulefile in a modulefile.
* Failed attempt to load or unload a modulefile within a modulefile now
  leads to this upper modulefile load or unload failure. Previously upper
  modulefile were loaded respectively unloaded even if its dependent
  sub-modulefile failed to load or unload.
* During a ``switch`` command, if the unloading part fails the loading part
  will not be tried. Unloading part fails if module to unload does not
  exist or its unload interpretation raise error.
* Init: use ``module source`` rather shell command ``source`` to load modulerc
  system configuration in sh-kind, csh-kind and fish shell init scripts.
* Install: transform configuration options to bind to an existing
  compatibility Modules version into option (--enable-compat-version) to
  build and install this compatibility version along with main version.
* Init: adapt initialization scripts to handle both main and compatibility
  version. By default a shell script enables main version and if the
  environment variable MODULES_USE_COMPAT_VERSION is set to 1, the
  compatibility version is enabled instead of main version.
* Install: import from compatibility version and install ``add.modules``
  and ``mkroot`` utility scripts (scripts developed by R.K. Owen).
* Install: update RPM spec file to handle compatibility version as a
  ``compat`` sub-package.
* Add completion script for Fish shell (contribution from BEFH).
* Doc: extend content of diff_v3_v4 to details all noticeable changes
  between v3.2 and v4.0.
* Doc: introduce MIGRATING guide to learn the major changes when moving
  from v3.2 to v4.0.
* Fix ``list`` command when full pathname modulefile is loaded (fix bug#132)
* Install: handle version number though git tags in scripts, documentation
  and RPM spec file.
* Doc: migrate documents from POD format to reStructuredText to benefit from
  Sphinx documentation framework and Read The Docs publishing capabilities.

Above changes describe the differences with modules-tcl release 1.923. To
learn about the changes between Modules 4.0 and last Modules 3.2 release,
please see the :ref:`MIGRATING` document.


modules-tcl-1.923 (2017-07-20)
------------------------------

* Fix ``aliases`` command when a global or user RC file is set.
* Find and solve global or user RC aliases and symbolic versions on
  ``search``, ``whatis`` and ``paths`` commands.
* Do not look at currently loaded modules to resolve the target of a module
  alias.
* Rework default and latest versions search on ``avail`` command. Correct
  display when at a given level a sub-directory element is last element in
  directory among modulefiles. Previously sub-directory was printed but
  last file among modulefiles was also printed (2 latest versions at the
  same level). A directory tagged "default" does not appear anymore in
  default listing result as its content (the default version found in that
  directory) will be displayed.
* When an alias is set and overrides name of an existing directory, take
  this alias into account for default and latest choice and ignore
  directory content.
* Bad default set will lead to no result displayed for the corresponding
  module in case of default ``avail`` display.
* Correct inclusion of aliases in output result when these aliases are not
  part of the exact same module path than module path of the search.
* Rewrite existing shell initialization file with initadd, initprepend,
  initswitch, initrm and initclear commands rather than writing a new
  file then copying this new file to replace the existing initialization
  file. In addition only re-writes shell initialization file if its content
  need to be altered.
* Raise an error on initadd, initprepend, initswitch, initrm and initclear
  commands when no ``module load`` line are found in shell initialization
  file.
* Normalize error messages for the various collection-related commands
  when collection cannot be accessed.
* Cleanup existing reference counters of a path list variable when this
  variable is altered by a ``setenv`` or an ``unsetenv`` command.
* Init: do not pollute tab-completion with moduleraw command. (Bert Wesarg)
* Make use of the same Tcl interp for each modulefile interpretation and
  use another one for each modulerc (but the same for each modulerc). By
  doing so we proceed like on C-version where same interpreter is used
  across modulefile or modulerc interpretation. Huge performance
  improvement is achieved with this change on commands making intensive
  use of interp like ``avail``. Interpreter state is reset from one
  interpretation to another: the initial variable and procedure state is
  restored before each new interpretation to avoid spread of definitions
  from one interpretation to another. Also in case of nested interpretation
  each interpretation level has its own interpreter so a module loaded by
  another does not influence the interpretation of the module loading it.
* Improve performance of aliases and symbolic versions resolution by
  computing these resolution at definition time. As a consequence
  resolution loop are not registered anymore and produce an error message
  when spotted not at display time.
* Reduce number of ``access`` system call by trying access to modulefile
  when reading the content of a modulefile directory rather testing access
  before trying it.
* No error raise on empty argument list for load. To cope with initadd
  behavior that requires at least an empty ``module load`` line in startup
  files. (fix SF bug#88)
* Fix initadd to handle load line without trailing space. Was previously
  expecting load directive to be written "module load " to get a match. With
  fix, ``module load`` line will also be matched.
* Like C-version catch raised error when break or continue are called from
  outside of a loop to handle them as when they are called from modulefile
  main body. (fix SF bug#87)
* Return error on ``module use`` command when an empty path string is
  provided rather ignoring it.
* Workaround ``min`` and ``max`` functions and ``lreverse`` procedure for
  correct operations under Tcl version 8.4.
* Install: add --with-tclsh configure option to give the ability to choose
  the Tcl interpreter shell to setup in initialization scripts.
* Handle error raised from the ModulesDisplay, ModulesHelp and ModulesTest
  procedures in the same way than for the evaluation of the modulefile
  content. An error occurring during the evaluation of the modulefile
  content will lead to no evaluation of the ``display``, ``help`` and
  ``test`` command specific functions.
* Remove ``debug`` module command
* Doc: describe ``path``, ``paths`` and ``autoinit`` module command.
* Correct use of xrdb tool when not installed in default path.
* Fix ``init*`` module commands to behave more like C-version and document
  remaining differences in diff_with_c-version.
* Init: make ``sh`` init script closer to POSIX specification to support sh
  flavors different than Bash or Zsh like Dash.
* Fix column-mode display for very short width terminal.
* Install: introduce an ``install`` non-regression testsuite which is
  triggered by the ``make testinstall`` command and checks modules-tcl
  installation is operational.
* Init: fix modulerc load test on ``fish`` init script.
* Init: fix interactive shell test on ``sh`` init script.
* Install: add --enable-example-modulefiles configure option that install
  by default some modulefiles provided as example in the system modulefiles
  directory.
* Install: when uninstalling, do not remove modulefiles directory if it is
  not empty.
* Add completion script for Zsh shell.
* Add ``module test`` command to trigger when called execution of a
  ModulesTest procedure in target modulefile following same kind of
  mechanism than ``module help``.


modules-tcl-1.832 (2017-04-29)
------------------------------

* Fix ``getenv`` sub-command to correctly return environment variable value.
* Clarify in man-pages display of module alias and symbolic version-name on
  ``avail`` command and management of file access issue when locating
  modulefiles.
* Distinguish access issue (permission denied) from find issue (cannot
  locate) when trying to access directly a directory or a modulefile as
  done on ``load``, ``display`` or ``whatis`` commands. In addition on this
  kind of access, not readable .modulerc files are ignored rather producing a
  missing magic cookie error.
* When mode is set to unload, ``module load`` commands in modulefile are
  interpreted as ``module unload`` commands. To guaranty correct behavior
  regarding requirements, the module list passed to the load command is
  reversed to unload the modulefiles in the reverse order than they have
  been loaded.
* Correct ``display`` command to only report module commands set in
  modulefile and not those set in the various .modulerc on the path toward
  this modulefile.
* Fix bash and tcsh completion scripts to eliminate symbolic version names
  from ``avail`` command result.
* Improve ``avail`` command when a symbolic version-name is passed as
  argument to return the modulefile target of this symbolic version-name.
* When looking for an implicit default in a directory, now a module alias is
  taken into account so it can be returned as the last element in it
  (highest numerically sorted version).
* Fix ``list`` command to correctly display the ``default`` tag along loaded
  modules when set via a .version file.
* Fix long output of ``list`` command to display the symbolic version-names
  associated to each loaded module if any.
* Improve ``avail`` command to return alias module when an alias name is
  passed as argument.
* On a ``--default`` listing, a modulefile does not appear anymore if a
  directory is set default at the same level. On a ``--latest`` listing, a
  directory does not appear anymore if set default but not the latest.
* Read modulerc and validate its header in a single open/read/close sequence
  instead of two in order to reduce to number of IO operations during an
  ``avail`` command.
* Drastically reduce grid size computation time which removes overhead when
  displaying module avail results in column-mode.
* Translate module name to currently interpreted module name when name
  correspond to the last part this interpreted module only in case of
  symbolic version-name or alias resolution.
* Avoid resetting regular path (/usr/bin) or manpath (/usr/share/man) when
  switching from Tcl to C version in switchml utility.
* Raise error on x-resource if DISPLAY environment variable is not set.
* Fix lisp init script which was broken for environment change actions.


modules-tcl-1.775 (2017-03-07)
------------------------------

* Improve README with examples, requirements, links, etc. Also update
  INSTALL documentation with details on the new configure/make/make install
  process.
* Add display of a release date next to the version number when calling for
  ``--help`` or ``--version``.
* Update diff_with_c-version document to describe the features of the
  Tcl-version that are not supported on the C-version. Also state that the
  diff takes C version 3.2.10 against Tcl version 1.729 as a basis.
* Introduce ``switchml`` tool, a shell function (or alias for csh or tcsh
  shells) that swap currently enabled Modules version (C or Tcl) by the
  other version (C or Tcl). Configure option ``--with-cver-initdir`` must be
  defined to enable ``switchml`` in initialization script.
* Define a PATH and MANPATH in shell initialization scripts that point to
  the defined modules-tcl installation directories.
* Give ability to generate distribution tarball from the git repository with
  Makefile ``dist`` target.
* Introduce an installation process for this software following the
  configure/make/make install fashion. Configure step enables to choose
  installation paths and init scripts features to activate. Make step mainly
  translates init scripts with the configuration set. Make install creates
  target directories and copy files into them.
* Fix MODULESHOME setup in autoinit command to define it as an absolute path
  and set it to the upper directory when modulecmd.tcl is located in a ``bin``
  or a ``libexec`` directory.
* Correct alias and version resolution on avail command which was erroneous
  in case of a modulefile holding symbols (like ``default``) and targeted by
  aliases. Avail output was showing the aliases holding the symbols instead
  of the modulefile.


modules-tcl-1.729 (2017-02-01)
------------------------------

* Add documentation in module(1) man page on the modulefile collection
  concept and the relative ``save``, ``restore``, ``saverm``, ``saveshow``
  and ``savelist`` commands.
* Add document to list the differences of the functionalities that can be
  found on the C-version of the Modules package compared to the
  Tcl-version.
* Improve modulecmd.tcl shebang to only search ``tclsh`` once if found in
  PATH.
* Add ``module-info mode`` check against ``remove`` and ``switch`` values.
* Introduce ``module-info command`` Modules-specific Tcl command to
  distinguish complex ``load`` or ``unload`` commands that cannot be
  determined with ``module-info mode`` alone. For instance a modulefile can
  now be aware that a ``switch``, a ``restore`` or a ``purge`` command is
  currently being run.
* Enable usage of ``module-info`` Modules-specific Tcl command from a
  modulerc file.
* Fix ``module-info specified`` Modules-specific Tcl command.
* No exit raise on modulefile or modulerc error during ``avail``, ``aliases``,
  ``whatis`` and ``search`` commands to avoid harming results from these
  global commands if error exists in a few modulefiles.
* Exit with error code when a critical error is encountered when
  interpreting a modulefile or a modulerc.
* Inhibit non-critical error report raised from modulefiles during ``avail``,
  ``aliases``, ``whatis`` and ``search`` commands to avoid error flood when
  parsing all modulefiles or modulercs.
* Handle multiple lines of ``module-whatis`` Modules-specific Tcl commands
  defined for the same modulefile.
* Handle multiple arguments passed to the ``module-whatis`` Modules-specific
  Tcl commands. They are joined to get a single line of text.
* Return error on ``whatis`` command if searched modulefile is not found.


modules-tcl-1.704 (2017-01-20)
------------------------------

* Set path variable counter to 1 for paths without a known reference count
  (was previously set to 999999999).
* Introduce ``envml`` utility which acts as an application launcher where
  module commands are instantiated to setup environment before launching
  the given application.
* Always register paths provided to be part of MODULEPATH environment
  variable as absolute paths to get independent from the current working
  directory.
* Inhibit next modulefiles interpretation with ``exit`` Modules-specific Tcl
  command only if current mode is ``load``.
* Add argument to ``module-info shell`` and ``module-info shelltype`` to test
  current shell or shelltype value.
* Fix use of ``default`` version-name to not consider it as a module symbol
  if a modulefile is named ``default``.
* Fix path variable counters when ``:`` character is used in elements of a
  path-like variable.
* Update module(1) and modulefile(5) man pages to clear content specific to
  the C version of Modules and add content specific to or adapt content that
  behave differently on this Tcl version.
* Fix TCLSH variable issue in Python init script.


modules-tcl-1.677 (2017-01-04)
------------------------------

* Make ``switch`` command handle a single argument. The modulefile to switch
  to is the one passed on the command-line and the modulefile to unload is
  assumed to be the currently loaded module with the same root name as
  this modulefile specified on the command-line.
* Make ``switch`` command idempotent by always ending up with ``old`` unloaded
  and ``new`` loaded, whatever the starting situation is.
* Fix ``exit`` Modules-specific Tcl command.
* Add ``refresh`` command as alias on ``reload`` command.
* Add dummy ``module-log``, ``module-trace``, ``module-user`` and
  ``module-verbosity`` Modules-specific Tcl commands to enable support for
  modulefiles using them.
* Fix ``system`` Modules-specific Tcl command to behave like described on the
  man page.
* Fix ``module list`` when module loaded with full path
* Disable ``g_force`` property by default to avoid loading a modulefile
  already loaded. It also avoids path element reference counting to get
  increased when the same module is asked twice for load.
* Clarify module-info ``mode`` option and set ``help`` mode on ``module help``
  command.
* Clarify module-info ``flags`` and ``user`` options.
* Handle empty or separator path on ``add-path`` ad ``unload-path`` commands.
* Delete environment variable targeted by an ``unsetenv`` command on
  ``unload`` mode if no value has been provided along. On display mode, print
  environment variable value if any has been passed to ``unsetenv`` command.
* When setting Tcl variable, enclose value within double quotes.
* Fix perl quoting style for variable set, escape single quotes rather
  double quotes.
* Call ``unuse`` command instead of ``use`` command on a ``module unload``.
* Fix ``continue`` Modules-specific Tcl command.
* Add ``chdir`` Modules-specific Tcl command.
* Fix ``break`` Modules-specific Tcl command.


modules-tcl-1.655 (2016-11-23)
------------------------------

* No display of modulepath header if no module found in it.
* Remove call to ``module aliases`` on ``module avail`` command, as aliases
  are now directly included in the ``avail`` results.
* Include module aliases in the displayed result of an ``avail`` command.
  Also display aliases defined in a global or user modulerc file.
* Exit with error code if error occurred on display or help commands.
* Fix module-info symbols resolution.
* Better handling of .modulerc and .version files when searching for a
  modulefile.
* Fix module-info version resolution.
* Fix module-info alias resolution.
* Register alias and version by the short module name and improve their
  resolution to avoid loop.
* Source $MODULERCFILE/modulerc when $MODULERCFILE is dir.
* Make it so you can do ``module avail un``, wildcard ``*`` character
  implied.


modules-tcl-1.632 (2016-09-06)
------------------------------

* Raise error if command does not receive the excepted number of arguments.
* Improve column-mode display to get a denser output on ``avail`` command.
* Standardize the output of Warning, Error, InternalBug and ErrorAndExit
  messages.
* Add short option -d for --delim on prepend-path.
* Introduce collection target concept to distinguish between machines,
  environments or domains that are incompatible with each other.
* Introduce ``saveshow`` command, to display content of saved collections.
* Improve ``save`` and ``restore`` commands to handle collection specified as
  absolute or relative file path.
* Introduce ``saverm`` command, to delete saved collections.
* Enable to ``restore`` collection with multiple modulefiles specified on the
  same line.
* Fix ``restore`` command when there is no module to load in collection.
* Fix ``restore`` command when collection fully rewind module paths.
* Fix ``restore`` command to preserve module path order set in collection.
* Raise error if try to save an empty environment in a collection.


modules-tcl-1.602 (2016-08-13)
------------------------------

* Add support for Fish shell.
* Import recent tests added to C-version on 10-use and 50-cmds testsuites.
* Add short option -d for --delim on append-path and remove-path.
* Fix load and implement unload x-resource.
* Fix Python code that was broken or not Python3-compliant. Fixed code is
  used to define the module command, to render error and to process
  x-resource.
* Always dictionary-sort (also called numerical-sort) list of modulefiles
  or list of collections.
* Fix bash completion script to be compliant with bash posix mode.


modules-tcl-1.578 (2014-12-24)
------------------------------

* First release to be described in this NEWS file but it does not mean this
  is the first version of modules-tcl as this Modules flavor is born in
  2002.
* At this stage, modules-tcl handles a majority of the module commands and
  modulefile Tcl commands available on C version.
