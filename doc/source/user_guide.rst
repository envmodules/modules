.. _user_guide:

Lesser know features
====================

Environment Modules provides many capabilities beyond the commonly used
:command:`module` :subcmd:`load` command. Some features are lesser known, despite being very
useful for users, modulefile developers, and site administrators.

This document gathers and explains a selection of these features through
practical examples and common use cases.

It originates from the presentation *Beyond `module load`: Exploring the
Capabilities of Environment Modules* presented at `HPSFCon 2026
<https://hpsf.io/event/hpsf-conference-2026/>`_. Original slides and video
demonstrations can be found on the `event session page
<https://hpsf2026.sched.com/event/2ESia/beyond-module-load-exploring-the-capabilities-of-environment-modules-part-1-adrien-cotte-as+>`_.

Short command names
-------------------

Most Modules sub-commands can be abbreviated. The :command:`ml` command also
provides a shorter alternative interface for common operations.

.. list-table::
   :header-rows: 1
   :widths: 50 50

   * - Standard command
     - Short form

   * - ``module <cmd>``
     - ``ml <cmd>``

   * - ``module avail``
     - ``module av``

   * - ``module purge``
     - ``module pu``

   * - ``module list``
     - ``ml``

   * - ``module load <module>``
     - ``ml <module>``

   * - ``module unload <module>``
     - ``ml -<module>``

Display/Parsing
---------------

--output=LIST
^^^^^^^^^^^^^

The :option:`--output`, or :option:`-o`, option customizes the information
displayed by Modules commands.

It is supported by :command:`module` :subcmd:`avail`, :subcmd:`list`, and
:subcmd:`spider` sub-commands.

By default, these commands display additional formatting elements such as
modulepaths, tags, default markers, or variant information. With
:option:`--output`, it is possible to restrict the displayed information to
only the needed fields.

This option is especially useful when parsing command output in shell scripts,
Python programs, or monitoring tools.

.. code-block:: console

   $ module avail -o ''

Only module names are displayed.

The output format is defined as a colon-separated list of elements. Supported
elements are documented in the corresponding sub-command manual pages.

This feature helps avoid fragile text parsing pipelines.

Instead of parsing formatted output:

.. code-block:: bash

   modules_list=$(module avail | grep -v '^---' \
      | sed 's/(default)//g' | head -n -2 | xargs)

A simpler and more robust approach is:

.. code-block:: bash

   modules_list=$(module avail -o '')

spider
^^^^^^

The :command:`module` :subcmd:`spider` sub-command lists all available
modulefiles found in enabled modulepaths, including modulepaths recursively
added by modulefiles.

Unlike :subcmd:`avail`, :subcmd:`spider` explores the full dependency tree
created by :mfcmd:`module use`, :mfcmd:`append-path`, or
:mfcmd:`prepend-path` instructions.

This command is especially useful with hierarchical module layouts, where some
modulefiles only become visible after loading compiler or MPI dependencies.

The :subcmd:`spider` sub-command accepts the same display and formatting
options as :subcmd:`avail`, including :option:`--output`,
:option:`--latest`, :option:`--default`, :option:`--json`,
:option:`--indepth`, and :option:`--no-indepth`.

For example, in a hierarchical environment:

.. code-block:: console

   $ module avail
   ------------------- /usr/share/modulefiles/common ------------------
   gcc/14.0  intel/25.0

Only compiler modules are initially visible.

The :subcmd:`spider` sub-command reveals additional modules together with
their dependency path:

.. code-block:: console

   $ module spider
   ------------------- /usr/share/modulefiles/common ------------------
   gcc/14.0  intel/25.0


   ---------- /usr/share//modulefiles/intel (via intel/25.0) ----------
   intelmpi/25.0

   ------------ /usr/share//modulefiles/gcc (via gcc/14.0) ------------
   openmpi/5.0.8


This output indicates which modules must be loaded before these MPI stacks
become available.

Modules caches are automatically used by :subcmd:`spider` when configured,
which significantly improves search performance on large installations.

--latest and --default
^^^^^^^^^^^^^^^^^^^^^^

The :option:`--latest`, or :option:`-L`, and :option:`--default`, or
:option:`-d`, options restrict the output of the :command:`module`
:subcmd:`avail` and :subcmd:`spider` sub-commands.

The :option:`--latest` option displays only the highest numerically sorted
version of each module name.

.. code-block:: console

   $ module avail --latest

The :option:`--default` option displays only the default version of each
module name.

.. code-block:: console

   $ module avail --default

These options may also be combined with other display options such as
:option:`--output` or :option:`--json`.

--indepth and --no-indepth
^^^^^^^^^^^^^^^^^^^^^^^^^^

The :option:`--indepth` and :option:`--no-indepth` options control how the
:command:`module` :subcmd:`avail` and :subcmd:`spider` sub-commands search
for matching modulefiles.

By default, Modules searches recursively and returns all matching
modulefiles. This behavior is equivalent to :option:`--indepth` and
could be configured with :command:`module` :subcmd:`config` :mconfig:`avail_indepth`
and :mconfig:`spider_indepth`.

.. code-block:: console

   $ module avail
   ------------------- /usr/share/modulefiles ------------------

   intel/24.0 intel/25.0 gcc/8.3 gcc/11.1 gcc/14.0

The :option:`--no-indepth` option limits results to the depth level
expressed by the search query. Modulefiles contained in matching directories
are not displayed.

.. code-block:: console

   $ module avail --no-indepth
   ------------------- /usr/share/modulefiles ------------------

   intel/ gcc/

--json
^^^^^^

The :option:`--json`, or :option:`-j`, option displays command results in
JSON format.

It is supported by the :command:`module` :subcmd:`avail`, :subcmd:`list`,
:subcmd:`savelist`, :subcmd:`search`, :subcmd:`spider`,
:subcmd:`stashlist`, and :subcmd:`whatis` sub-commands.

JSON output is intended for machine consumption and can be processed directly
by tools such as Python or `jq`.

.. code-block:: console

    $ module avail -j | jq .
    {
      "/usr/share/modulefiles": {
        "gcc/14.0": {
          "name": "gcc/14.0",
          "type": "modulefile",
          "symbols": [],
          "tags": [],
          "pathname": "/usr/share/modulefiles/gcc/14.0",
          "via": ""
        },
        ...
    }

The JSON format is also useful for monitoring, reporting, and integration
with external tools.

Manipulating environment for users
----------------------------------

Collections
^^^^^^^^^^^

Collections save and restore sets of loaded modules.

They provide a convenient way to switch between software environments without
having to manually load and unload each module.

Collections are managed through several :command:`module` sub-commands:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Sub-command
     - Description

   * - :subcmd:`save` [collection]
     - Save the current module environment to a collection.

   * - :subcmd:`restore` [collection]
     - Restore a collection or collection file.

   * - :subcmd:`savelist`
     - List saved collections.

   * - :subcmd:`saverm` [collection]
     - Remove a saved collection.

   * - :subcmd:`saveshow` [collection]
     - Display information about a collection.

   * - :subcmd:`is-saved` [collection]
     - Test whether one or more collections exist.

Collections are stored under the user collection directory, usually
:file:`$HOME/.module`.

The :envvar:`MODULES_COLLECTION_TARGET` environment variable may be defined
to append a suffix to collection names. This feature is particularly useful
on systems sharing a common home directory across multiple clusters.

.. code-block:: console

   $ module save
   $ module purge
   $ module restore

mogui
^^^^^

``mogui`` provides a graphical interface to browse available modules and
manage collections.

It offers an alternative to the command line and can be useful for new users
discovering a software stack or for users who prefer an interactive
interface.

Any environment change made from the GUI, such as loading modules or
restoring collections, is applied back to the shell session that launched
the application.

The project is available on GitHub:
`cea-hpc/mogui <https://github.com/cea-hpc/mogui>`_. It can be installed
from PyPI with :command:`pip` or from Spack.

.. code-block:: console

   $ pip install modules-gui

or:

.. code-block:: console

   $ spack install py_modules_gui

Then start the graphical interface:

.. code-block:: console

   $ mogui

.. image:: https://raw.githubusercontent.com/cea-hpc/mogui/main/doc/sneak_peek.gif
   :alt: mogui graphical interface
   :align: center

stash commands
^^^^^^^^^^^^^^

Stash collections temporarily save the current module environment and make it
easy to switch to another environment.

This feature is similar to the :command:`git stash` workflow: save the current
state, perform other work, then restore the original environment later.

Stash collections are managed through several :command:`module`
sub-commands:

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Sub-command
     - Description

   * - :subcmd:`stash`
     - Save the current environment and reset it.

   * - :subcmd:`stashpop`
     - Restore and remove a stash collection.

   * - :subcmd:`stashrm`
     - Remove a stash collection.

   * - :subcmd:`stashshow`
     - Display information about a stash collection.

   * - :subcmd:`stashclear`
     - Remove all stash collections.

   * - :subcmd:`stashlist`
     - List stash collections.

Save the current environment:

.. code-block:: console

   $ module stash

Load a different software stack:

.. code-block:: console

   $ module purge
   $ module load ...

Restore the original environment:

.. code-block:: console

   $ module stashpop

Unlike regular collections, stash collections are intended to be short-lived
and are automatically removed when restored with
:subcmd:`stashpop`.

Envml
^^^^^

The :ref:`envml(1)` command executes a command in a specific module
environment.

It applies the requested module actions, executes the command, then restores
the original environment. As a result, the current shell session remains
unchanged.

This feature is particularly useful in scripts, tests, and automation
workflows where commands must be executed in a controlled software
environment.

Supported module actions include:

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Action
     - Description

   * - ``purge``
     - Purge all loaded modules.

   * - ``restore=<collection>``
     - Restore a saved collection.

   * - ``unload=<module>``
     - Unload one or more modules.

   * - ``switch=<module1>&<module2>``
     - Switch from one module to another.

   * - ``load=<module>``
     - Load one or more modules.

   * - ``<module>``
     - Shorthand form of ``load=<module>``.

Multiple actions may be chained with the ``:`` separator. When specifying
multiple modules for a single action, use the ``&`` separator. In some
shells, such as Bash, the ``&`` character must be escaped or quoted.

For example, execute a command in a clean environment:

.. code-block:: console

   $ envml purge -- gcc hello.c

The :ref:`envml(1)` command can simplify scripts by replacing sequences of
module operations with a single command.

Instead of:

.. code-block:: bash

   #!/bin/bash
   module purge
   module load gcc
   gcc hello.c

One can write:

.. code-block:: bash

   #!/bin/bash
   envml purge:gcc -- gcc hello.c

Protected environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :mconfig:`protected_envvars` configuration option prevents Modules from
modifying selected environment variables. Multiple variables may be specified using the ``:`` separator.

This feature is useful to protect critical environment settings from
unintended changes.

When a modulefile attempts to modify a protected variable, Modules ignores
the modification and emits a warning.

.. code-block:: console

   $ module config protected_envvars LD_PRELOAD
   $ module load intel
   Loading intel/25.0
     WARNING: Modification of protected environment variable LD_PRELOAD ignored

Developing and configuring module files
---------------------------------------

module edit
^^^^^^^^^^^

The :command:`module` :subcmd:`edit` sub-command opens a modulefile in the
configured text editor (cf. :subcmd:`config` :mconfig:`editor`).

Instead of manually locating a modulefile:

.. code-block:: console

   $ vi $(module path appA)

One can directly edit it with:

.. code-block:: console

   $ module edit appA

module lint
^^^^^^^^^^^

The :command:`module` :subcmd:`lint` sub-command analyzes modulefiles and
reports potential issues.

It relies on the Nagelfar Tcl syntax checker to detect syntax errors and
common mistakes.

Analyze a specific modulefile:

.. code-block:: console

   $ module lint appA

Reported issues may include:

* Unknown variables
* Unknown commands
* Invalid command arguments
* Tcl syntax errors

source-sh
^^^^^^^^^

The :mfcmd:`source-sh` modulefile command evaluates a shell script and tracks
the environment changes it performs.

The detected changes are translated into modulefile actions, making it
possible to load and unload shell-based environments through Modules.

It is particularly useful to integrate software distributions that provide
environment setup scripts such as ``setup-env.sh``, ``mpivars.sh``, or
similar rc-provided files.

For example:

.. code-block:: tcl

   #%Module

   source-sh bash /opt/spack/share/spack/setup-env.sh

sh-to-mod
^^^^^^^^^

The :command:`module` :subcmd:`sh-to-mod` sub-command evaluates a shell script
and reports the resulting environment changes as modulefile commands.

It can be used to convert existing shell initialization scripts into
modulefiles.

For example:

.. code-block:: console

   $ module sh-to-mod bash setup-env.sh > setup-env.mod

.. tip::

   Use :subcmd:`sh-to-mod` when you want to generate and maintain a regular
   modulefile from an existing shell script.

mod-to-sh
^^^^^^^^^

The :command:`module` :subcmd:`mod-to-sh` sub-command evaluates one or more
modulefiles and reports the resulting environment changes as shell code.

For example:

.. code-block:: console

   $ module mod-to-sh bash appA > setup-env.sh

.. tip::

   The :subcmd:`mod-to-sh` sub-command can be seen as the reverse operation of
   :subcmd:`sh-to-mod`.

prereq
^^^^^^

The :mfcmd:`prereq` modulefile command declares one or more modules that must
already be loaded before the current modulefile can be loaded.

Instead of explicitly loading dependencies:

.. code-block:: tcl

   if { ! [ is-loaded appA ] } {
      module load appA
   }

Declare them with:

.. code-block:: tcl

   prereq appA

When the prerequisite is not satisfied, Modules reports an error and refuses
to load the modulefile.

Multiple module names passed to a single :mfcmd:`prereq` command act as a
logical OR. Multiple :mfcmd:`prereq` commands act as a logical AND.

conflict
^^^^^^^^

The :mfcmd:`conflict` modulefile command declares one or more modules that
cannot be loaded together with the current modulefile.

Instead of manually checking for incompatible modules:

.. code-block:: tcl

   if { [ is-loaded appB ] } {
      puts stderr "ERROR: appB conflicts with appA!"
      exit 1
   }

Declare the conflict with:

.. code-block:: tcl

   conflict appB

When a conflicting module is loaded, Modules reports an error and refuses to
load the modulefile.

The conflict check may be bypassed with the :option:`--force` option:

.. code-block:: console

   $ module load --force appA

.. tip::

   To ensure that only one version of a module can be loaded at a time,
   consider enabling the :mconfig:`unique_name_loaded` configuration option
   instead of declaring self-conflicts in every modulefile.

variant
^^^^^^^

The :mfcmd:`variant` modulefile command declares variants and their accepted
values.

This command is only available inside modulefiles.

Variants allow users to customize the behavior of a modulefile at load time.
They follow the same syntax as Spack variants.

Boolean variants are enabled with ``+`` and disabled with ``~``:

.. code-block:: tcl

   #%Module
   variant --boolean cuda

.. code-block:: console

   $ module load openmpi +cuda

Variants with multiple values are declared by listing the accepted values:

.. code-block:: tcl

   #%Module
   variant compiler gcc intel

And selected with the ``=`` syntax:

.. code-block:: console

   $ module load openmpi compiler=intel

The :mfcmd:`getvariant` modulefile command retrieves the value of a declared
variant, allowing the modulefile to adapt its behavior.

For example:

.. code-block:: tcl

   switch -- [getvariant compiler] {
      gcc {
         prereq gcc
      }
      intel {
         prereq intel
      }
   }

Configuration option :mconfig:`variant_shortcut` defines shortcut characters
for variants.

For example:

.. code-block:: console

   $ module config variant_shortcut compiler=%

Allows users to write:

.. code-block:: console

   $ module load openmpi %gcc

Advanced manipulations
----------------------

Advanced specifications specifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:ref:`advanced_module_version_specifiers` provide a concise way to select modulefiles based on
their version or declared variants. They can be used with several
:command:`module` sub-commands, including :subcmd:`avail`,
:subcmd:`spider`, :subcmd:`load`, and :subcmd:`switch`.

Version specifications use the ``@`` character:

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Specification
     - Description

   * - ``module avail cuda@default``
     - Select the default version.

   * - ``module avail cuda@latest``
     - Select the latest version.

   * - ``module avail cuda@12:``
     - Select versions greater than or equal to ``12``.

   * - ``module avail cuda@:12``
     - Select versions lower than or equal to ``12``.

   * - ``module avail cuda@12:13``
     - Select versions between ``12`` and ``13``.

Variant specifications may also be used:

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Specification
     - Description

   * - ``module avail +mpi``
     - Select modules declaring the ``mpi`` variant.

   * - ``module avail cuda=12``
     - Select modules where the ``cuda`` variant is set to ``12``.

   * - ``module avail +mpi +cuda``
     - Select modules matching both variant requirements.

--timer and --debug
^^^^^^^^^^^^^^^^^^^

The :option:`--timer` and :option:`--debug`, or :option:`-D`, options help
analyze and troubleshoot Modules commands.

They are supported by most :command:`module` sub-commands.

The :option:`--timer` option reports the total execution time of a command.

For example:

.. code-block:: console

   $ module avail --timer

The :option:`--debug`, or :option:`-D`, option displays debugging messages
describing the internal execution of the command.

For example:

.. code-block:: console

   $ module avail -D

The :option:`--timer` and :option:`--debug` options may be combined. In this
case, regular debug messages are replaced by execution time reports for each
internal procedure call.

.. code-block:: console

   $ module avail --timer -D

For even more detailed debugging information, use :option:`-DD`.

.modulerc files
^^^^^^^^^^^^^^^

A :file:`.modulerc` file contains Tcl code automatically evaluated by
Modules when encountered during a command execution.

Rc files are used to define module aliases, virtual
modules, tags, hidden modules, forbidden modules, ...

Several :file:`.modulerc` files may be evaluated during a single
:command:`module` command.

Depending on the executed sub-command, Modules may evaluate
:file:`.modulerc` files found in different locations, including:

* :envvar:`MODULERCFILE`
* :file:`$HOME/.modulerc`
* Modulepath and modules directories

For example, the following directory hierarchy contains several
:file:`.modulerc` files:

.. code-block:: text

   /home/user/.modulerc
   modulefiles/
   ├── .modulerc
   ├── app/
   │   ├── .modulerc
   │   └── 1.0
   └── mpi/
       ├── .modulerc
       └── openmpi/5.0

Depending on the requested operation, one or more of these files are
evaluated automatically.

See :ref:`Modulecmd startup` for details on the startup sequence,
:mconfig:`rcfile` and :mconfig:`ignore_user_rc` to configure the evaluation
of user rc files, and :sitevar:`modulerc_extra_vars` and
:sitevar:`modulerc_extra_cmds` to extend :file:`.modulerc` files.

module-tag
^^^^^^^^^^

The :mfcmd:`module-tag` modulerc command associates one or more tags with
modulefiles.

This command is only available inside :file:`.modulerc` files.

Tags may be used to provide additional information about modulefiles or to
modify their behavior.

For example:

.. code-block:: tcl

   module-tag experimental app/2.0

Several predefined tags affect the behavior of Modules:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Tag
     - Description

   * - ``keep-loaded``
     - Prevent automatic unloading when unloading dependent modules.

   * - ``sticky``
     - Prevent unloading unless :option:`--force` is specified.

   * - ``super-sticky``
     - Prevent unloading under any circumstances.

For example:

.. code-block:: tcl

   module-tag sticky core

Sticky modules can help ensure that essential software stacks remain loaded.
The behavior of :subcmd:`purge` with sticky modules can be configured through
:mconfig:`sticky_purge`.

module-hide
^^^^^^^^^^^

The :mfcmd:`module-hide` modulerc command hides modulefiles from module
searches and selection.

This command is only available inside :file:`.modulerc` files.

A hidden module is excluded from regular searches but may still be selected
when explicitly referred to by its exact name.

For example:

.. code-block:: tcl

   module-hide app/1.0

Visibility may also be restricted to specific users or groups with options.

Time-based restrictions can be defined with ``--after`` and ``--before``.

For example:

.. code-block:: tcl

   module-hide --after 2027-01-01 app/1.0

See :mfcmd:`module-hide` for additional visibility options, including **soft**
and **hard** hiding, as well as **users** and **groups** restrictions.

module-forbid
^^^^^^^^^^^^^

The :mfcmd:`module-forbid` modulerc command prevents designated modulefiles
from being loaded.

This command is only available inside :file:`.modulerc` files.

Unlike a hidden module, a forbidden module remains visible in module searches
but cannot be loaded.

For example:

.. code-block:: tcl

   module-forbid app/1.0

A custom message may be displayed when a user attempts to load a forbidden
module with ``--message`` option.

For example:

.. code-block:: tcl

   module-forbid --message {Please use app/2.0 instead} app/1.0

See :mfcmd:`module-forbid` for additional restriction options, including
custom messages, as well as **after**/**before**, **users** and **groups** restrictions.

module-virtual
^^^^^^^^^^^^^^

The :mfcmd:`module-virtual` modulerc command associates a virtual module name
with an existing modulefile.

This command is only available inside :file:`.modulerc` files.

Several virtual modules may refer to the same modulefile, reducing the number
of files required to define similar modules.

For example:

.. code-block:: text

   modulefiles/app/
   ├── .common
   └── .modulerc

The :file:`.modulerc` file may define several virtual versions:

.. code-block:: tcl

   #%Module
   module-virtual 1.0 .common
   module-virtual 1.2 .common
   module-virtual 1.5 .common
   module-virtual 2.0 .common

.. code-block:: console

   $ module avail
   ------------------- /usr/share/modulefiles ------------------
   app/1.0  app/1.2 app/1.5 app/2.0

All these virtual modules are evaluated using the same :file:`.common`
modulefile.
Its behavior can be adapted according to the virtual module
name being evaluated.

.. code-block:: tcl

   #%Module

   set version [lindex [split [module-info name] /] end]

   setenv APP_VERSION $version

Module logger
^^^^^^^^^^^^^

Modules can log module activity through the :mconfig:`logger` and
:mconfig:`logged_events` configuration options.

The :mconfig:`logger` option defines the command used to record log messages.

For example:

.. code-block:: console

   $ module config logger "/usr/bin/logger -t modules"

The :mconfig:`logged_events` option defines which module events are recorded.

.. list-table::
   :header-rows: 1
   :widths: 30 70

   * - Event
     - Description

   * - ``requested_cmd``
     - Record module commands requested by users.

   * - ``requested_eval``
     - Record modulefile evaluations requested by users.

   * - ``auto_eval``
     - Record modulefile evaluations automatically triggered by Modules.

Multiple events may be specified using the ``:`` separator.

For example:

.. code-block:: console

   $ module config logged_events requested_cmd:requested_eval

By default, no events are logged.

The logger command can be customized to integrate Modules activity with an
existing logging or monitoring infrastructure.
