.. _NEWS:

Release notes
=============

This file describes changes in recent versions of Modules. It primarily
documents those changes that are of interest to users and admins.

Modules 4.5.4 (2026-09-07)
--------------------------

* Init: fix command injection in Bash completion when module names contain
  shell meta-characters. Completion candidates were passed to ``compgen -W``
  which evaluates command substitution syntax. (fix `CVE-2026-85013`_ found
  by AISLE in partnership with Red Hat)

.. _CVE-2026-85013: https://github.com/envmodules/modules/security/advisories/GHSA-8hrw-p88g-qhmg


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
  command in :ref:`modulefile(4)` document.
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
  :ref:`modulefile(4)` and :ref:`diff_v3_v4` documents. (contribution from
  Colin Marquardt)
* Doc: update cookbook recipes to highlight code of the Tcl scripts included.
  (contribution from Colin Marquardt)
* Doc: improve markup of :ref:`module(1)`, :ref:`modulefile(4)` and
  :ref:`diff_v3_v4` documents to enable references to module sub-commands,
  command line switches, environment variables and modulefile Tcl commands.
  (contribution from Colin Marquardt)
* Doc: alphabetically sort module sub-commands, command-line switches,
  environment variables and modulefile Tcl commands in :ref:`module(1)` and
  :ref:`modulefile(4)` documents.
* Introduce the ``ml`` command, a handy frontend to the ``module`` command.
  ``ml`` reduces the number of characters to type to trigger ``module``. With
  no argument ``ml`` is equivalent to ``module list``, ``ml mod`` corresponds
  to ``module load mod`` and ``ml -mod`` means ``module unload mod``. Multiple
  modules to either load or unload can be combined on a single command. ``ml``
  accepts all command-line switches and sub-commands accepted by ``module``
  command. ``ml`` command is defined by default. Its definition can be
  controlled at ``./configure`` time with ``--enable-ml`` option or later on
  with ``ml`` configuration option (which defines ``MODULES_ML`` environment
  variable when set).
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
  ``--enable-windows-support`` is set. module command wrapper ``module.cmd``
  is installed in ``bindir`` and initialization script ``cmd.cmd`` in
  ``initdir``. Those batch files are relocatable and expect ``modulecmd.tcl``
  in ``..\libexec`` directory. (fix issue #272 with contribution from Jacques
  Raphanel)
* Install: add ml command wrapper ``ml.cmd`` and install it in ``bindir`` when
  ``./configure`` option ``--enable-windows-support`` is set.
* Install: introduce envml command wrapper ``envml.cmd`` for Windows ``cmd``
  shell and install it in ``bindir`` when ``./configure`` option
  ``--enable-windows-support`` is set. (contribution from Jacques Raphanel)
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
  location at configure step with ``--with-python`` option. Specified command
  name or location should be found on build system only if building from git
  repository.
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
  and 4.0 in :ref:`diff_v3_v4` document.
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
* Doc: clarify hidden module location in :ref:`modulefile(4)` man page.
* Install: define ``LD_PRELOAD`` as quarantine var along with
  ``LD_LIBRARY_PATH`` in RPM specfile.
* When ``implicit_default`` and ``advanced_version_spec`` configuration are
  enabled, automatically define a ``default`` and ``latest`` symbolic version
  for each module name (at each module depth for deep modules) if those
  version names does not already exist. (fix issue #210)
* Once a module is loaded, the automatically defined symbols associated to it
  are recorded in loaded environment in the ``MODULES_LMALTNAME`` environment
  variable. They are distinguished from the other alternative names applying
  to the module by a ``as|`` prefix, which qualifies their *auto symbol* type.
* When an advanced version specifier list contains symbolic version
  references, fix resolving to honor default version if part of the specified
  list. (fix issue #334)

.. _JSON: https://tools.ietf.org/html/rfc8259


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
  (which  defines ``MODULES_ADVANCED_VERSION_SPEC`` environment variable when
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
  use `module switch` command in modulefiles*. (fix issue#229)
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
* Install: add ``--enable-append-binpath`` and ``--enable-append-binpath``
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
  versions and aliases resolving to the loaded modules. Helps to consistenly
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
  evaluation error is now silenced on global evaluation like when proceding
  ``avail`` or ``search`` sub-commands.
* Record messages to report them by block on when processing a ``load`` or an
  ``unload`` modulefile evaluation to improve readability on these evaluating
  modes that may cascade additional actions. (see
  :ref:`v42-module-message-report` section in MIGRATING document)
* Foreground ``load``, ``unload``, ``switch`` and ``restore`` actions (ie.
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


Modules 4.1.4 (2018-08-20)
--------------------------

* Doc: fix typo on ``getenv`` command description in modulefile(4) man page
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
* Doc: describe ``getenv`` command in modulefile(4) man page.
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
  ``restore`` commands.  May affect ``info-loaded`` or ``is-loaded`` commands
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
  expecting load directive to be written "module load "  to get a match.
  With fix, ``module load`` line will also be matched.
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
* Update module(1) and modulefile(4) man pages to clear content specific to
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
* Fix ``system`` Modules-specific Tcl command  to behave like described on
  the man page.
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
