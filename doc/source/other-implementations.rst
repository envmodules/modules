.. _other-implementations:

Other ``module`` implementations
================================

Since the inception of the Environment Modules project in 1991, the ``module``
command has become a de facto standard interface for dynamically modifying a
user's environment via modulefiles. Over time, several alternative
implementations of the ``module`` command have been developed.

This document provides an overview of known ``module`` command
implementations, with a particular focus on Lmod, the most widely adopted
alternative. The goal is to inform users and developers of the current
landscape of ``module`` system tools.

Lmod
----

`Lmod`_ is an implementation of Environment Modules written in Lua. Its
development started in 2008 and along a years Lmod has introduced many new
features into the ``module`` world: software hierarchy, cache mechanism, Lua
modulefile support, ``ml`` command, etc.

Lmod gained popularity in the mid-2010s, during a period when the Modules
project was largely inactive. It is now widely adopted, particularly in the
HPC community.

.. _Lmod: https://github.com/TACC/Lmod/

Today, Lmod and Modules offer broadly similar feature sets. The following
table highlights features that are unique to each implementation.

.. list-table::
   :header-rows: 1

   * - |lmod_version|
     - |modules_version|
   * - * Integration with *nushell* and *rc* shells and *json* structured
         output
       * `Lua modulefile support`_
       * `Inactive modules`_
       * Save configuration under :envvar:`XDG_CONFIG_HOME`
       * `i18n`_
       * `Find best module`_
       * `Path entry priorities`_
       * ``--regexp`` search option
       * `settarg`_
       * `Hook functions`_
       * |LMOD_FILE_IGNORE_PATTERNS|_ environment variable
     - * Integration with *cmd* and *pwsh* shells and *Tcl* language
       * :ref:`Automated module handling<MODULES_AUTO_HANDLING>`
       * :ref:`Advanced module version specifiers`
       * :ref:`Module variants`
       * :ref:`Virtual modules`
       * :ref:`Sourcing modulefiles`
       * Handle modulefile outside modulepath
       * :ref:`Quarantine mechanism`
       * :ref:`Case insensitive module load<Insensitive case>`
       * Automatic ``latest`` and ``loaded`` symbols
       * ``alias``, ``command``, ``loaded``, ``tags``, ``usergroups`` and
         ``username`` sub-commands of :mfcmd:`module-info`
       * :ref:`Super-sticky modules<Sticky modules>`
       * :ref:`Fine-tuned output configuration<--output>`
       * :ref:`Editing modulefiles`
       * :ref:`Tag when loading module<More tagging capabilities>`
       * :ref:`Stashing environment`
       * :ref:`Extra specifier`
       * Configurable :ref:`Abort on error` behavior
       * Integration with *bash-eval* and *fish* shells in :mfcmd:`source-sh`
       * :ref:`Specific modulepath for requirements`
       * :ref:`Logging activity`
       * :command:`envml` launcher

.. _Lua modulefile support: https://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html
.. _Inactive modules: https://lmod.readthedocs.io/en/latest/010_user.html#module-hierarchy
.. _Find best module: https://lmod.readthedocs.io/en/latest/060_locating.html
.. _i18n: https://lmod.readthedocs.io/en/latest/185_localization.html
.. _Path entry priorities: https://lmod.readthedocs.io/en/latest/077_ref_counting.html#specifying-priorities-for-path-entries
.. _Update path entry order: https://lmod.readthedocs.io/en/latest/077_ref_counting.html
.. _settarg: https://lmod.readthedocs.io/en/latest/310_settarg.html
.. _Hook functions: https://lmod.readthedocs.io/en/latest/170_hooks.html#hook-functions
.. |LMOD_FILE_IGNORE_PATTERNS| replace:: ``LMOD_FILE_IGNORE_PATTERNS``
.. _LMOD_FILE_IGNORE_PATTERNS: https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html#setting-environment-variables-or-cosmic-assign-at-startup

The following table highlights ``module`` sub-commands that are exclusive to
either Lmod or Modules. In some cases, similar functionality exists under
different sub-command names or mechanisms. A correspondence table is provided
at the end of this section to map these equivalents.

.. list-table::
   :header-rows: 1

   * - |lmod_version|
     - |modules_version|
   * - ``category``, ``overview``, ``tablelist``
     - :subcmd:`aliases`, :subcmd:`append-path`, :subcmd:`cachebuild`,
       :subcmd:`cacheclear`, :subcmd:`clear`, :subcmd:`config`,
       :subcmd:`edit`, :subcmd:`info-loaded`, :subcmd:`initadd`,
       :subcmd:`initclear`, :subcmd:`initlist`, :subcmd:`initprepend`,
       :subcmd:`initrm`, :subcmd:`initswitch`, :subcmd:`is-saved`,
       :subcmd:`is-used`, :subcmd:`lint`, :subcmd:`mod-to-sh`, :subcmd:`path`,
       :subcmd:`paths`, :subcmd:`prepend-path`, :subcmd:`remove-path`,
       :subcmd:`saverm`, :subcmd:`saveshow`, :subcmd:`sh-to-mod`,
       :subcmd:`source`, :subcmd:`stash`, :subcmd:`stashclear`,
       :subcmd:`stashlist`, :subcmd:`stashpop`, :subcmd:`stashrm`,
       :subcmd:`stashshow`, :subcmd:`state`, :subcmd:`test`


The following table highlights Tcl modulefile commands that are exclusive to
either Lmod or Modules. In some cases, similar functionality exists under
different command names or mechanisms. A correspondence table is provided at
the end of this section to map these equivalents.

.. list-table::
   :header-rows: 1

   * - |lmod_version|
     - |modules_version|
   * - ``remove-property``
     - :mfcmd:`getvariant`, :mfcmd:`is-saved`, :mfcmd:`is-used`,
       :mfcmd:`lsb-release`, :mfcmd:`module-tag`, :mfcmd:`module-virtual`,
       :mfcmd:`module-warn`, :mfcmd:`modulepath-label`,
       :mfcmd:`modulepath-label`, :mfcmd:`provide`, :mfcmd:`reportWarning`,
       :mfcmd:`uncomplete`, :mfcmd:`variant`, :mfcmd:`x-resource`

See the :ref:`Compatibility with Lmod Tcl modulefile` section for details on
how the implementation of the Tcl modulefile commands differ between Lmod and
Modules.

The following table provides a correspondence between features in Lmod and
Modules that offer similar functionality, even if they differ in name or
implementation.

.. list-table::
   :header-rows: 1

   * - |lmod_version|
     - |modules_version|
   * - `Module properties`_
     - :ref:`Module tags` 
   * - `One name rule`_
     - :mconfig:`unique_name_loaded` configuration option
   * - `Custom labels for avail`_
     - :mfcmd:`modulepath-label` modulefile command
   * - `Extensions`_
     - :mfcmd:`provide` modulefile command
   * - `Irreversible module actions`_
     - :ref:`Change modulefile command behavior`
   * - `NAG file`_
     - :mfcmd:`module-forbid`, :mfcmd:`module-warn` modulefile commands
   * - Lmod + `XALT`_
     - :ref:`Logging activity`
   * - `Hook functions`_
     - :ref:`Override any internal procedures or set trace hook<Site-specific
       configuration>`
   * - `Module hierarchy`_
     - :ref:`Requiring via module`
   * - `Autoswap`_
     - :ref:`Conflict unload MIGRATING`
   * - `Update path entry order`_
     - :mconfig:`path_entry_reorder` configuration option
   * - |LMOD_DOWNSTREAM_CONFLICTS|_ environment variable
     - :ref:`Dependencies between modulefiles`
   * - |LMOD_QUARANTINE_VARS|_ environment variable
     - :mconfig:`protected_envvars` configuration option
   * - |clearLmod|_ shell function
     - ``module`` :subcmd:`clear`
   * - |update_lmod_system_cache_files|_ script
     - ``module`` :subcmd:`cachebuild`
   * - |sh_to_modulefile|_ script
     - ``module`` :subcmd:`sh-to-mod`
   * - |check_module_tree_syntax|_ script
     - ``module`` :subcmd:`lint`
   * - ``module --checkSyntax load``
     - ``module`` :subcmd:`lint`
   * - ``module --config``
     - ``module`` :subcmd:`config`
   * - ``$LMOD_CMD bash load``
     - ``module`` :subcmd:`mod-to-sh` ``bash``
   * - ``module --raw show`` 
     - ``EDITOR=cat module`` :subcmd:`edit`
   * - ``module --location show``
     - ``module`` :subcmd:`path`
   * - ``module --mt``
     - ``module`` :subcmd:`state`
   * - ``module overview``
     - ``module avail`` :option:`--no-indepth`
   * - ``module --regexp avail``
     - ``module avail`` :option:`--contains`
   * - ``module --style=<style_name> avail``
     - ``module avail`` :option:`--output` ``<element_list>``
   * - ``module --no_extensions avail``
     - ``module avail`` :option:`--output` ``-provided-alias``
   * - ``module --terse_show_extensions avail``
     - ``module avail --terse`` :option:`--output` ``+provided-alias``
   * - ``module category``
     - ``module`` :subcmd:`search`
   * - ``module --brief list``
     - ``module config`` :mconfig:`hide_auto_loaded` ``1``
   * - ``module tablelist``
     - ``module list`` :option:`--json`
   * - ``module --pin_versions restore``
     - ``module config`` :mconfig:`collection_pin_version` ``1`` +
       ``module save`` + ``module restore``
   * - ``module --initial_load restore``
     - ``module restore`` during :ref:`Modules initialization<Initial
       environment>`
   * - ``atleast("foo","5.0")``
     - |foo@5.0:|_
   * - ``atmost("foo","5.0")``
     - |foo@:5.0|_
   * - ``between("foo","5.0","7.0")``
     - |foo@5.0:7.0|_
   * - ``latest("foo")``
     - |foo@latest|_

.. _Irreversible module actions: https://lmod.readthedocs.io/en/latest/370_irreversible.html
.. _NAG file: https://lmod.readthedocs.io/en/latest/140_deprecating_modules.html
.. _Custom labels for avail: https://lmod.readthedocs.io/en/latest/200_avail_custom.html
.. _Extensions: https://lmod.readthedocs.io/en/latest/330_extensions.html
.. _Module properties: https://lmod.readthedocs.io/en/latest/145_properties.html
.. _One name rule: https://lmod.readthedocs.io/en/latest/010_user.html#users-can-only-have-one-version-active-the-one-name-rule
.. _XALT: https://github.com/xalt/xalt
.. _Module hierarchy: https://lmod.readthedocs.io/en/latest/080_hierarchy.html
.. _Autoswap: https://lmod.readthedocs.io/en/latest/060_locating.html#autoswapping-rules
.. |LMOD_DOWNSTREAM_CONFLICTS| replace:: ``LMOD_DOWNSTREAM_CONFLICTS``
.. _LMOD_DOWNSTREAM_CONFLICTS: https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html#configuration-or-cosmic-assign-at-startup
.. |LMOD_QUARANTINE_VARS| replace:: ``LMOD_QUARANTINE_VARS``
.. _LMOD_QUARANTINE_VARS: https://lmod.readthedocs.io/en/latest/090_configuring_lmod.html#environment-variables-only
.. |clearLmod| replace:: ``clearLmod``
.. _clearLmod: https://lmod.readthedocs.io/en/latest/010_user.html#clearlmod-complete-remove-lmod-setup
.. |check_module_tree_syntax| replace:: ``check_module_tree_syntax``
.. _check_module_tree_syntax: https://lmod.readthedocs.io/en/latest/360_check_syntax.html
.. |update_lmod_system_cache_files| replace:: ``update_lmod_system_cache_files``
.. _update_lmod_system_cache_files: https://lmod.readthedocs.io/en/latest/130_spider_cache.html
.. |sh_to_modulefile| replace:: ``sh_to_modulefile``
.. _sh_to_modulefile: https://lmod.readthedocs.io/en/latest/260_sh_to_modulefile.html#converting-shell-scripts-to-modulefiles
.. |foo@5.0:| replace:: ``foo@5.0:``
.. _foo@5.0\:: module.html#version-specifiers
.. |foo@:5.0| replace:: ``foo@:5.0``
.. _foo@\:5.0: module.html#version-specifiers
.. |foo@5.0:7.0| replace:: ``foo@5.0:7.0``
.. _foo@5.0\:7.0: module.html#version-specifiers
.. |foo@latest| replace:: ``foo@latest``
.. _foo@latest: module.html#version-specifiers

Other alternatives
------------------

This section intends to reference all other existing alternative ``module``
implementations.

* `Modulecmd.py`_: Environment Modules implementation in Python
* `Pmodules`_: Environment Modules implementation in Bash
* `RSModules`_: Environment Modules implementation in Rust

.. _Modulecmd.py: https://github.com/tjfulle/Modulecmd.py
.. _Pmodules: https://github.com/Pmodules/Pmodules
.. _RSModules: https://github.com/fretn/rsmodules

If you know of a ``module`` implementation project that's not listed here,
please :ref:`let us know<Community>` so we can include it.

Related projects
----------------

Beyond alternative implementations of the ``module`` command, several projects
have been developed along the years to extend its functionality or provide
additional tools that enhance how modulefiles are handled.

* `Devel::IPerl::Plugin::EnvironmentModules`_: interact with Environment
  Modules in a Jupyter IPerl kernel
* `Env::Modulecmd`_: interface to ``modulecmd`` from Perl
* `environmentmodules`_: Python interface for Environment Modules
* `flavours`_: extension built on top of Modules v3 to provide module auto
  handling mechanisms
* `Mii`_: a smart search engine for module environments
* `RenvModule`_: interface to Environment Modules within the R environment

.. _Devel\:\:IPerl\:\:Plugin\:\:EnvironmentModules: https://github.com/kiwiroy/Devel-IPerl-Plugin-EnvironmentModules
.. _Env\:\:Modulecmd: https://metacpan.org/pod/Env::Modulecmd
.. _environmentmodules: https://github.com/ben-albrecht/environmentmodules
.. _flavours: https://sourceforge.net/projects/flavours/
.. _Mii: https://github.com/codeandkey/mii
.. _RenvModule: https://cran.r-project.org/web/packages/RenvModule/index.html

If you're aware of a ``module``-related project missing from this list, feel
free to :ref:`contact us<Community>` so we can add it.

.. |modules_version| replace:: Modules 5.7.0 (not yet released)
.. |lmod_version| replace:: Lmod 9.0.5
