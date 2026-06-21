.. _MIGRATING:

New features
============

This document describes the major changes occurring between versions of
Modules. It provides an overview of the new features and changed behaviors
that will be encountered when upgrading.


v5.7 (not yet released)
-----------------------

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.7 release notes<5.7 release notes>` for a complete
list of the changes between Modules v5.6 and v5.7.

Improving evaluation performances
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We observed that Modules could feel slow when evaluating more than one hundred
modulefiles within a single command. To address this, several improvements
have been implemented:

* In-memory caching of expensive operations: the results of costly operations,
  such as module specification comparisons, are now cached in memory.

* Reworked environment synchronization between Tcl interpreters: environment
  synchronization during Tcl modulefile evaluation has been redesigned to rely
  on Tcl’s internal mechanisms rather than a custom reimplementation. As part
  of this change, calls to the Tcl ``append`` command have been replaced with
  ``set``, which reliably triggers synchronization when environment variables
  are modified.

* More efficient dependency checks: when verifying dependencies against loaded
  modules, comparisons are now limited to the subset of loaded modules that
  match the module root name specification, instead of comparing against all
  loaded modules.

For this work, the :command:`mb` utility was extended with new benchmark tests
that loads 137 modulefiles, lists the loaded modules, and then purges them.
Running this benchmark highlights the performance improvements, as shown in
the table below:

+---------+-------------+--------------------+
|         |      v5.6.1 |             v5.7.0 |
+=========+=============+====================+
|    load |     1038 ms |      384 ms (-63%) |
+---------+-------------+--------------------+
|    list |      222 ms |       29 ms (-87%) |
+---------+-------------+--------------------+
|   purge |      568 ms |      303 ms (-46%) |
+---------+-------------+--------------------+

These measurements were obtained on a system where all modulefiles are stored
on local flash storage. If your modulefiles reside on a shared network
filesystem, using a `Module cache`_ is strongly recommended.

Reorder existing entries in path-like variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new :mconfig:`path_entry_reorder` configuration option is introduced to
control how path-like environment variables are modified when
:mfcmd:`prepend-path`, :mfcmd:`append-path` or :subcmd:`use` target a path
entry that is already defined in the environment variable.

By default, this configuration option is set to ``0``, meaning that when a
path entry already exists, the environment variable is left unchanged. When
set to ``1``, an existing entry is reordered to the beginning or the end of
the variable, depending on the command used, unless duplicates are explicitly
allowed.

.. parsed-literal::

    :ps:`$` module append-path PATHVAR /foo
    :ps:`$` module append-path PATHVAR /bar
    :ps:`$` module append-path PATHVAR /foo
    :ps:`$` echo $PATHVAR
    /foo:/bar
    :ps:`$` module config path_entry_reorder 1
    :ps:`$` module append-path PATHVAR /foo
    :ps:`$` echo $PATHVAR
    /bar:/foo
    :ps:`$` module append-path --duplicates PATHVAR /bar
    :ps:`$` echo $PATHVAR
    /bar:/foo:/bar

The default value of :mconfig:`path_entry_reorder` can be defined at
installation time with the :instopt:`--enable-path-entry-reorder` option. When
the configuration option is changed from its default value using the
:subcmd:`config` sub-command, the :envvar:`MODULES_PATH_ENTRY_REORDER`
environment variable is defined accordingly. See
:envvar:`MODULES_PATH_ENTRY_REORDER` for details.

.. _Linked environment variables:

Linked environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new configuration option, :mconfig:`linked_envvars`, can be used to
automatically mirror environment variable changes onto other environment
variables.

When a modulefile modifies an environment variable using commands such as
:mfcmd:`setenv`, :mfcmd:`unsetenv`, :mfcmd:`prepend-path`,
:mfcmd:`append-path`, :mfcmd:`remove-path` or :mfcmd:`pushenv`, the same
operation is also applied to all variables linked through the
:mconfig:`linked_envvars` configuration option.

For example, with the following configuration:

.. parsed-literal::

    :ps:`$` module config linked_envvars "CPATH&INCLUDE_PATH"

loading a module that prepends a directory to ``CPATH``:

.. parsed-literal::

    :sgrcm:`prepend-path` CPATH /opt/pkg/include

will also prepend the same directory to ``INCLUDE_PATH``.

Links are directional. In the previous example, changes made to ``CPATH`` are
also applied to ``INCLUDE_PATH``, but changes made directly to
``INCLUDE_PATH`` are not applied back to ``CPATH`` unless an explicit reverse
link is configured.

When enabling this feature, note that existing values are not synchronized
when the link is established. Only subsequent modifications performed through
modulefile environment variable commands are propagated to linked variables.

The output of ``module display`` also includes the environment variable
changes applied to linked environment variables, making these propagated
updates visible before a module is loaded.

.. _Init environment variables:

Initialize environment variables on first modification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new configuration option, :mconfig:`init_envvars`, has been added to define
initial values for environment variables that are modified through path-like
modulefile commands.

This feature is particularly useful for variables such as ``MANPATH``, which
require a leading or trailing colon character to preserve access to the system
default search paths. Previously, modifying an undefined ``MANPATH`` could
prevent system manual pages from being found. See the :ref:`man-path` cookbook
for details.

The :mconfig:`init_envvars` option defines a colon-separated list of
``VARIABLE_NAME=initial_value`` entries. When a path-like operation is applied
to an environment variable that is not currently set, the configured initial
value is assigned before the modification is performed.

For example, with the following configuration:

.. parsed-literal::

    :ps:`$` module config init_envvars MANPATH=

loading a module that prepends a directory to ``MANPATH``:

.. parsed-literal::

    :sgrcm:`prepend-path` MANPATH /opt/pkg/man

will keep a colon character at the end of ``MANPATH``

.. parsed-literal::

    :ps:`$` echo $MANPATH
    /opt/pkg/man:

This mechanism applies to all path-like environment variable management
commands, including :mfcmd:`append-path`, :mfcmd:`prepend-path` and
:mfcmd:`remove-path`.

When values are later removed from an environment variable, it is
automatically unset if its resulting value matches the configured initial
value and no explicit reference counter is associated with it.


v5.6
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.6 release notes<5.6 release notes>` for a complete
list of the changes between Modules v5.5 and v5.6.

spider sub-command
^^^^^^^^^^^^^^^^^^

Support has been added for the :subcmd:`spider` sub-command introduced by the
`Lmod`_ project. This sub-command lists available modules found in enabled
modulepaths and recursively found in modulepaths enabled by available modules.

.. parsed-literal::

    :ps:`$` module avail
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    foo/1  foo/2
    :ps:`$` module show foo/1
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1`:

    :sgrcm:`conflict`        foo
    :sgrcm:`module`          use /path/to/modulefiles.2
    -------------------------------------------------------------------
    :ps:`$` module show foo/2
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/2`:

    :sgrcm:`conflict`        foo
    :sgrcm:`append-path`     MODULEPATH /path/to/modulefiles.3
    -------------------------------------------------------------------
    :ps:`$` module spider
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    foo/1  foo/2

    -------------- :sgrdi:`/path/to/modulefiles.2` (via foo/1) --------------
    bar/1  bar/2  bar/3

    -------------- :sgrdi:`/path/to/modulefiles.3` (via foo/2) --------------
    bar/3  bar/4

    -------------- :sgrdi:`/path/to/modulefiles.3` (via bar/1) --------------
    qux/1  qux/2

The :subcmd:`spider` sub-command relies on the :ref:`Extra match search`
mechanism to scan modulefiles and identify the modulepaths they enable. Since
all modulefiles are evaluated during this scan, it is recommended to build
and use a :ref:`Module cache` to improve search performance.

The output of :subcmd:`spider` is similar to that of the :subcmd:`avail`
sub-command and supports the same set of options and queries.

.. parsed-literal::

    :ps:`$` module spider -t bar@2:
    :sgrdi:`/path/to/modulefiles.2`:
    :sgrhi:`bar/2`
    bar/3

    :sgrdi:`/path/to/modulefiles.3`:
    bar/3
    bar/4

The :subcmd:`spider` sub-command has its own configuration options to control
the content of its output: :mconfig:`spider_indepth`,
:mconfig:`spider_output`, and :mconfig:`spider_terse_output`.

These settings make it possible to define output for :subcmd:`spider` that
differs from the :subcmd:`avail` sub-command.

.. parsed-literal::

    :ps:`$` module config spider_output -modulepath
    :ps:`$` module config spider_indepth 0
    :ps:`$` module spider
    :sgrdi:`bar`/  :sgrdi:`foo`/  :sgrdi:`qux`/

When a modulepath is enabled by a specific module, that modulepath is
considered available *via* that module. When the module is loaded, this *via*
information is stored in the :envvar:`__MODULES_LMUSE` environment variable to
track which modules enable which modulepaths.

By default, the *via* information is included in the standard output of the
:subcmd:`spider` sub-command. Additionally, the JSON output for both the
:subcmd:`avail` and :subcmd:`spider` sub-commands has been updated to include
*via* details for each modulefile.

.. parsed-literal::

    :ps:`$` module spider -j bar@2:
    {"/path/to/modulefiles.2": {
    "bar/2": { "name": "bar/2", "type": "modulefile", "symbols": [], "tags": [], "pathname": "/path/to/modulefiles.2/bar/2", "via": "foo/1"}
    "bar/2": { "name": "bar/3", "type": "modulefile", "symbols": [], "tags": [], "pathname": "/path/to/modulefiles.2/bar/3", "via": "foo/1"}
    },
    "/path/to/modulefiles.3": {
    "bar/3": { "name": "bar/3", "type": "modulefile", "symbols": [], "tags": [], "pathname": "/path/to/modulefiles.3/bar/3", "via": "foo/2"},
    "bar/4": { "name": "bar/4", "type": "modulefile", "symbols": [], "tags": [], "pathname": "/path/to/modulefiles.3/bar/4", "via": "foo/2"}
    }}

.. _Requiring via module:

Requiring *via* module
^^^^^^^^^^^^^^^^^^^^^^

A loaded module that enables a modulepath is considered the *via* module of
other loaded modules whose modulefiles are stored in this modulepath. The
:mconfig:`require_via` configuration option is introduced to consider a *via*
module a requirement for the loaded module stored in the modulepath it
enables.

A *module hierarchy* mechanism, as introduced by the Lmod_ project, is now
supported with this feature. It allows organizing modulefiles through a
primary modulepath, where loading certain modules enables additional
modulepaths. :mconfig:`require_via` maintains a link between modulefiles in
these additional paths and the *via* module that activated them.

The :mconfig:`require_via` setting is disabled by default to maintain
compatibility with previous Modules 5 releases. However, users are encouraged
to enable this feature if they want to use the *module hierarchy* mechanism.

.. parsed-literal::

    :ps:`$` module config require_via 1

When unloading a *via* module, all the modules stored in its enabled
modulepath are automatically unloaded thanks to the *Dependent Unload*
mechanism of the :ref:`Automated module handling mode<MODULES_AUTO_HANDLING>`.

.. parsed-literal::

    :ps:`$` module load foo/1 bar/2
    :ps:`$` module avail
    -------------- :sgrdi:`/path/to/modulefiles.2` (via foo/1) --------------
    bar/1  :sgrl:`bar/2`  bar/3

    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    :sgrl:`foo/1`  foo/2

    Key:
    :sgrl:`loaded`  :sgrdi:`modulepath`
    :ps:`$` module unload foo
    Unloading :sgrhi:`foo/1`
      :sgrin:`Unloading dependent`: bar/2

When a *via* module is replaced by another, any modulepaths it enabled are
updated accordingly. If the newly enabled modulepath provides alternatives to
modules previously loaded from the original path, those modules are reloaded
from the new location. If no alternatives are found, the dependent modules are
unloaded.

.. parsed-literal::

    :ps:`$` module config conflict_unload 1
    :ps:`$` module load foo/1 bar/3
    :ps:`$` module load foo/2
    Loading :sgrhi:`foo/2`
      :sgrin:`Unloading dependent`: bar/3
      :sgrin:`Unloading conflict`: foo/1
      :sgrin:`Reloading dependent`: bar/3
    :ps:`$` module avail
    -------------- :sgrdi:`/path/to/modulefiles.3` (via foo/2) --------------
    :sgrl:`bar/3`  bar/4

    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    foo/1  :sgrl:`foo/2`

    Key:
    :sgrl:`loaded`  :sgrdi:`modulepath`

Always see hidden modules
^^^^^^^^^^^^^^^^^^^^^^^^^

The ``hidden`` element is a new allowed value for the :mconfig:`avail_output`,
:mconfig:`avail_terse_output`, :mconfig:`list_output`,
:mconfig:`list_terse_output`, :mconfig:`spider_output` and
:mconfig:`spider_terse_output` configuration options. When set into the value
list of these options hidden modules are shown on the output of corresponding
commands (:subcmd:`avail`, :subcmd:`list` and :subcmd:`spider`).

.. parsed-literal::

    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0
    :ps:`$` module config avail_output +hidden
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0  foo/1.0 <H>

When set, this is equivalent to always adding the :option:`--all` command-line
option.

Issue warning upon module evaluation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The mfcmd:`module-warn` modulefile Tcl command is introduced to define warning
message to print when loading specified modulefiles.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.0
    #%Module
    module-warn --message {Please consider using "bar" module instead} foo
    :ps:`$` module load foo
    Loading :sgrhi:`foo/1.0`
      :sgrwa:`WARNING`: Please consider using "bar" module instead

The warning message is printed when targeted modulefile is evaluated in
*load*, *display*, *help* or *test* mode.

:mfcmd:`module-warn` supports the same kind of options than
:mfcmd:`module-tag` or :mfcmd:`module-hide`: it is possible to specify a list
of affected or unaffected users or groups. Warning may also be only effective
before or after a particular date.

The ``warning`` tag is set on modules targeted by a mfcmd:`module-warn`
command.

Simplified way to define module help message
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Until now module help message was defined through a specific Tcl procedure
that outputs text to *stderr* channel:

.. code-block:: tcl

   #%Module
   proc ModulesHelp {} {
       puts stderr {Module Name: foo, Version: 1.0}
       puts stderr {This modulefile does this and that}
   }

A new modulefile Tcl command is introduced, :mfcmd:`module-help`, to simplify
a bit the definition of help message:

.. code-block:: tcl

   #%Module
   module-help {Module Name: foo, Version: 1.0}
   module-help {This modulefile does this and that}

With this modulefile command there is no need to define the ``ModulesHelp``
procedure anymore. As :mfcmd:`module-help` is reported on module *display*
evaluation, help message will also be visible there.

Support for newline character in environment variable value
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

It is now possible on *sh*, *bash*, *ksh*, *zsh* and *fish* shells to set
value for environment variable that contains newline character:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/1.0
    #%Module
    setenv BAR "multi\nline\nvalue"
    :ps:`$` module load bar
    :ps:`$` echo "$BAR"
    multi
    line
    value

Generated shell code on these shells has been changed to enclose value within
single quotes rather escaping each special characters:

.. parsed-literal::

    :ps:`$` module mod-to-sh bash bar/1.0
    BAR='multi
    line
    value'; export BAR;

Declare additional elements provided by a module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

New :mfcmd:`provide` modulefile command is added to declare additional
elements included in a modulefile. When the modulefile is loaded, each
argument specified in the :mfcmd:`provide` command is registered as an alias
for the module.


.. parsed-literal::

    :ps:`$` module show foo
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1`:

    :sgrcm:`provide`         liba/1.2 libb/2.1
    :sgrcm:`conflict`        foo
    :sgrcm:`conflict`        liba libb
    -------------------------------------------------------------------
    :ps:`$` module load foo

It is advised to define :mfcmd:`conflict` over the name of these additional
elements to ensure only one provider is found loaded in user environment.

.. parsed-literal::

    :ps:`$` module show bar/1
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/1`:

    :sgrcm:`provide`         liba/1.2 libb/2.1
    :sgrcm:`conflict`        bar
    :sgrcm:`conflict`        liba libb
    -------------------------------------------------------------------
    :ps:`$` module load bar
    Loading :sgrhi:`bar/1`
      :sgrer:`ERROR`: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload foo/1" first.

Once a module with a provided alias is loaded, it fulfills any requirements
declared by other modules for that name and version, just like any other type
of module alias.

.. parsed-literal::

    :ps:`$` module show qux
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/qux/1`:

    :sgrcm:`prereq`          liba/1.2
    -------------------------------------------------------------------
    :ps:`$` module load qux
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1   2) qux/1

Module aliases defined via the :mfcmd:`provide` command are not available
during module resolution, as modulefiles are not evaluated in that context.
Therefore, it is recommended to define a global module alias in a ``modulerc``
file using the :mfcmd:`module-alias` command to specify a default target for
the alias.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/.modulerc
    #%Module
    module-alias liba/1.2 bar/1
    :ps:`$` module purge
    :ps:`$` module load qux
    Loading :sgrhi:`qux/1`
      :sgrin:`Loading requirement`: bar/1

The :mfcmd:`provide` modulefile command also serves as an alias for the
:mfcmd:`extensions` command, ensuring compatibility with modulefiles written
for `Lmod`_.

By default an :subcmd:`avail` command includes module aliases defined in
``modulerc`` files. To also get aliases defined within modulefiles with
:mfcmd:`provide` or :mfcmd:`family`, output element ``provided-alias`` has to
be included. It is supported on :mconfig:`avail_output`,
:mconfig:`avail_terse_output`, :mconfig:`spider_output` and
:mconfig:`spider_terse_output` configuration options.

Having ``provided-alias`` included in output triggers :ref:`Extra match
search` mechanism that scans all modulefiles to find these aliases. It is thus
advised to have :ref:`Module cache` built and used to improve search speed.

.. parsed-literal::

    :ps:`$` module avail
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1  foo/1  :sgrali:`liba/1.2`  qux/1

    Key:
    :sgrdi:`modulepath`  :sgrali:`module-alias`
    :ps:`$`  module avail -o +provided-alias
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1  foo/1  :sgrali:`liba/1.2`  :sgrali:`libb/2.1`  qux/1

    Key:
    :sgrdi:`modulepath`  :sgrali:`module-alias`

The ``provided-alias`` :ref:`Extra specifier` is also introduced to find
modules that define such alias with :mfcmd:`provide` or :mfcmd:`family`
modulefile commands.

.. parsed-literal::

    :ps:`$` module avail provided-alias:liba/1.2
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1  foo/1

    Key:
    :sgrdi:`modulepath`


v5.5
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.5 release notes<5.5 release notes>` for a complete
list of the changes between Modules v5.4 and v5.5.

.. _Logging activity:

Logging activity
^^^^^^^^^^^^^^^^

The ability to log module command activity is now available out of the box. It
could be enabled on previous versions by using a specific
:file:`siteconfig.tcl` configuration script as described in the
:ref:`log-module-command` cookbook recipe.

Integrated logging feature relies on two configuration options:

* :mconfig:`logger`, the command run to transmit messages to the log system
* :mconfig:`logged_events`, list of module event to log

:mconfig:`logger` option relies on the :command:`logger` command by default,
which is usually available and already installed on most systems.

The :mconfig:`logged_events` option is empty by default, so no content is sent
to logs by default. It recognizes the following events:

* ``requested_cmd``: record module commands typed by users
* ``requested_eval``: record modulefile evaluations requested by users
* ``auto_eval``: record modulefile evaluations automatically triggered

.. parsed-literal::

    :ps:`$` module config logged_events +requested_cmd:requested_eval
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0  foo/1.0  qux/1.0
    :ps:`$` module load bar
    Loading :sgrhi:`bar/1.0`
      :sgrin:`Loading requirement`: qux/1.0
    :ps:`$` module purge

In the above example the module command and modulefile evaluations directly
requested by users are sent to the system log:

.. parsed-literal::

    :ps:`$` journalctl -q -t modules
    Apr 29 07:47:42 hostname modules[3777797]: user="username" command="avail" arguments=""
    Apr 29 07:48:10 hostname modules[3777876]: user="username" command="load" arguments="bar"
    Apr 29 07:48:10 hostname modules[3777876]: user="username" mode="load" module="bar/1.0" specified="bar" modulefile="/path/to/modulefiles/bar/1.0" requested="1"
    Apr 29 07:48:17 hostname modules[3777914]: user="username" command="purge" arguments=""
    Apr 29 07:48:17 hostname modules[3777914]: user="username" mode="unload" module="bar/1.0" specified="bar/1.0" modulefile="/path/to/modulefiles/bar/1.0" requested="1"

Some messages can also be sent during modulefile evaluation by using the
``log`` channel of the :mfcmd:`puts` command:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.0
    #%Module
    puts log {some message sent to log}
    :ps:`$` ml foo/1.0
    :ps:`$` journalctl -q -t modules
    Apr 29 07:47:51 hostname modules[3777835]: user="username" command="ml" arguments="foo/1.0"
    Apr 29 07:47:51 hostname modules[3777835]: some message sent to log
    Apr 29 07:47:51 hostname modules[3777835]: user="username" mode="load" module="foo/1.0" specified="foo/1.0" modulefile="/path/to/modulefiles/foo/1.0" requested="1"

Negating extra match search criteria
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``not:`` prefix string is introduced for extra specifier and variant
criteria. When this prefix is used, the search criteria where it is applied is
negated.

.. parsed-literal::

    :ps:`$` module config avail_output +variant
    :ps:`$` module config variant_shortcut toolchain=%
    :ps:`$` module avail
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0{:sgrva:`%x86_64`}        foo/2.0{:sgrva:`%x86_64`,\ :sgrva:`arm64`}
    bar/2.0{:sgrva:`%x86_64`,\ :sgrva:`arm64`}  qux/1.0{:sgrva:`%x86_64`}
    foo/1.0{:sgrva:`%x86_64`}        qux/2.0{:sgrva:`%x86_64`,\ :sgrva:`arm64`}
    :ps:`$` module avail not:envvar:FOO,BAR
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    qux/1.0{:sgrva:`%x86_64`}  qux/2.0{:sgrva:`%x86_64`,\ :sgrva:`arm64`}

The above search query returns all modules not defining ``FOO`` and ``BAR``
environment variables.

.. parsed-literal::

    :ps:`$` module avail not:envvar:BAR not:%arm64
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    foo/1.0{:sgrva:`%x86_64`}  qux/1.0{:sgrva:`%x86_64`}

The above example returns all modules not defining ``BAR`` environment
variable and not defining ``toolchain`` variant or defining this variant
without ``arm64`` among the possible values.

This prefix is recognized on module search context (i.e., :subcmd:`avail`,
:subcmd:`whatis` and :subcmd:`paths` sub-commands).

PowerShell support
^^^^^^^^^^^^^^^^^^

Support for PowerShell (``pwsh``) is added. This shell may be used with
Modules on either Unix or Windows platforms. All main :ref:`kind of
environment changes are supported<Shell support>`.

A ``envmodule`` shell function is configured on PowerShell, as ``module`` is a
reserved keyword on this shell.

The Windows-specific distribution zipball of Modules has been updated to also
contain the required files to setup PowerShell support.

.. _Conflict unload MIGRATING:

Conflict unload
^^^^^^^^^^^^^^^

Automated module handling is enhanced with the addition of a new mechanism:
*Conflict Unload*. When loading a module, this new mechanism automatically
unloads conflicting modules and their dependent.

.. parsed-literal::

    :ps:`$` module load foo/1
    Loading :sgrhi:`foo/1`:sgrse:`{`:sgrvahi:`-debug`:sgrse:`}`
      :sgrin:`Loading requirement`: qux/1 bar/1
    :ps:`$` module load foo/2
    Loading :sgrhi:`foo/2`
      :sgrer:`ERROR`: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload foo/1" first.
    :ps:`$` module config conflict_unload 1
    :ps:`$` module load foo/2
    Loading :sgrhi:`foo/2`:sgrse:`{`:sgrvahi:`-debug`:sgrse:`}`
      :sgrin:`Unloading conflict`: foo/1\ :sgrse:`{`:sgrva:`-debug`:sgrse:`}`

As seen in the above example, *Conflict Unload* is controlled by the
:mconfig:`conflict_unload` configuration option. It is disabled by default
as it changes behaviors of the :envvar:`automated module handling
mode<MODULES_AUTO_HANDLING>`. But everyone is encouraged to enable this new
option to benefit from an highly automated experience. This option can be
changed at installation time with :instopt:`--enable-conflict-unload`
configure script option.

*Conflict Unload* handles all kind of conflicts: conflicts defined by already
loaded modules, conflict declared by loading module through :mfcmd:`conflict`,
:mfcmd:`family` or :mfcmd:`module unload<module>` commands. It also supports
the unload of a module that is loaded again but with different variant values.

.. parsed-literal::

    :ps:`$` module load foo/2 +debug
    Loading :sgrhi:`foo/2`:sgrse:`{`:sgrvahi:`+debug`:sgrse:`}`
      :sgrin:`Unloading conflict`: foo/2\ :sgrse:`{`:sgrva:`-debug`:sgrse:`}`

Along with *Conflict Unload*, the *Useless Requirement Unload* mechanism is
added to load evaluation. With it, auto loaded requirements of modules
unloaded by *Conflict Unload* mechanism are automatically unloaded.

.. parsed-literal::

    :ps:`$` module load foo/3
    Loading :sgrhi:`foo/3`:sgrse:`{`:sgrvahi:`-debug`:sgrse:`}`
      :sgrin:`Unloading conflict`: foo/2\ :sgrse:`{`:sgrva:`+debug`:sgrse:`}` bar/1
      :sgrin:`Loading requirement`: bar/2
      :sgrin:`Unloading useless requirement`: qux/1

Dependent modules of *Conflict Unload* modules are considered *Dependent
Reload* modules. They are unloaded prior unloading the *Conflict Unload*
module that depend on them. Reload occurs after loading main module and only
if the loaded environment satisfies the dependencies of the module to reload.

.. parsed-literal::

    :ps:`$` module load bar/3
    Loading :sgrhi:`bar/3`
      :sgrin:`Loading requirement`: qux/2
    :ps:`$` module load qux/1
    Loading :sgrhi:`qux/1`
      :sgrin:`Unloading dependent`: bar/3
      :sgrin:`Unloading conflict`: qux/2
      :sgrin:`Reloading dependent`: bar/3

Improved automated module handling mechanisms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Along with the introduction of *Conflict Unload* mechanism, some of the
existing automated module handling mechanisms have been adapted and enhanced.

*Useless Requirement Unload* (UReqUn) mechanism is moved during a
:subcmd:`switch` sub-command from the end of the unload phase to the end of
the load phase. Both *UReqUn* modules coming from unload and load phases are
this way treated jointly. If *UReqUn* modules resulting from the switch unload
phase are detected as conflict to the switched-on module, it is advised to
enable the :mconfig:`conflict_unload` mechanism to automatically handle them.

.. parsed-literal::

    :ps:`$` module switch foo/3 foo/4
    Loading :sgrhi:`foo/4`
      :sgrer:`ERROR`: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload bar/2" first.

    Switching from :sgrhi:`foo/3`:sgrse:`{`:sgrvahi:`-debug`:sgrse:`}` to :sgrhi:`foo/4`
      :sgrer:`ERROR`: Load of switched-on foo/4 failed
    :ps:`$` module config conflict_unload 1
    :ps:`$` module switch foo/3 foo/4
    Switching from :sgrhi:`foo/3`:sgrse:`{`:sgrvahi:`-debug`:sgrse:`}` to :sgrhi:`foo/4`
      :sgrin:`Unloading conflict`: bar/2

*Dependent Reload* (DepRe) modules that also are *UReqUn* modules are now
unloaded during the *DepRe* unload phase instead of during the *UReqUn*
process. As a consequence these modules are now unloaded prior main module
action, as they are a dependent of this main module. This kind of *UReqUn*
modules may not be a dependency of a module unloaded in the current
processing.

Modules from *Dependent Unload* (DepUn) and *Dependent Reload* (DepRe)
mechanisms are now mixed together to proceed to their unload. They are this
way unloaded in their reverse loading order. So if a module is part of the
*DepUn* process and one of its requirement is part of the *DepRe* process, the
requirement is now unloaded after its dependent.

Reload of *Dependent Reload* (DepRe) module is now skipped if this module is
not found loadable in environment. Either because its requirements are not
loaded or a conflict is spotted. Such module is considered *Dependent Unload*
rather *Dependent Reload*. If *DepRe* module is sticky, reload is attempted
anyway.

Reload of all *Dependent Reload* (DepRe) modules now occurs after main module
evaluation rather after each sub module evaluation that triggered the
*Dependent Reload* unload phase.

When a loading module requires a *Dependent Unload* (DepUn) module, the unload
of this module was forced when it was triggered by a Conflict Unload or a
switched-off module. The unload of such *DepUn* module is not forced anymore
by default and an error is raised if a loading module requiring the *DepUn*
module is detected.

When unloading *Dependent Reload* modules, do not force by default this unload
unless asked with :option:`--force` option. As a result an error is obtained
when trying to reload Dependent Reload modules that conflict with other loaded
modules. This error may be by-passed with :option:`--force` command-line
option.

.. _Specific modulepath for requirements:

Specific modulepath for requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A ``--modulepath`` option is introduced on the :mfcmd:`always-load`,
:mfcmd:`depends-on`, :mfcmd:`prereq`, :mfcmd:`prereq-all` and
:mfcmd:`prereq-any` modulefile commands. This option indicates that
requirement should be specifically searched in the provided list of
modulepaths. Such mechanism helps to ensure loaded requirements are those
expected and they are not coming from an unexpected module tree.

In the following example, ``foo`` module requires ``bar``. It expects the
``bar`` module from the same modulepath than ``foo``. User's environment has
enabled another modulepath that also provides a ``bar`` module. Use of
``--modulepath`` option guides the requirement load mechanism to the expected
module.

.. parsed-literal::

    :ps:`$` module avail
    --------------------- :sgrdi:`/path/to/othermfiles` ---------------------
    bar/1

    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1  foo/1  foo/2
    :ps:`$` module show foo/1
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1`:

    :sgrcm:`prereq`          --modulepath .. bar/1
    -------------------------------------------------------------------
    :ps:`$` module load foo/1
    Loading :sgrhi:`foo/1`
      :sgrin:`Loading requirement`: bar/1
    :ps:`$` echo $_LMFILES_
    /path/to/modulefiles/bar/1:/path/to/modulefiles/foo/1

Specific modulepath set may guide to a directory not necessarily enabled
(i.e., not defined in :envvar:`MODULEPATH` environment variable):

.. parsed-literal::

    :ps:`$` module show foo/2
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/2`:

    :sgrcm:`prereq`          --modulepath /path/to/alternatefiles bar/2
    -------------------------------------------------------------------
    :ps:`$` module load foo/2
    Loading :sgrhi:`foo/2`
      :sgrin:`Loading requirement`: bar/2
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) bar/2   2) foo/2
    :ps:`$` echo $_LMFILES_
    /path/to/alternatefiles/bar/2:/path/to/modulefiles/foo/2

If a required module is already loaded from a modulepath that does not
correspond to the requirement definition, an error is obtained. However if
the *Conflict Unload* mechanism described above is enabled, the conflicting
module will automatically be unloaded.

.. parsed-literal::

    :ps:`$` module purge
    :ps:`$` module load bar/1
    :ps:`$` echo $_LMFILES_
    /path/to/othermfiles/bar/1
    :ps:`$` module load foo/1
    Loading :sgrhi:`bar/1`
      :sgrer:`ERROR`: Module already loaded from a different modulepath

    Loading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Load of requirement bar/1 (specific path) failed
    :ps:`$` module config conflict_unload 1
    :ps:`$` module load foo/1
    Loading :sgrhi:`foo/1`
      :sgrin:`Unloading conflict`: bar/1
      :sgrin:`Loading requirement`: bar/1
    :ps:`$` echo $_LMFILES_
    /path/to/modulefiles/bar/1:/path/to/modulefiles/foo/1


v5.4
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.4 release notes<5.4 release notes>` for a complete
list of the changes between Modules v5.3 and v5.4.

Enhancing extra specifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^

Extra specifier ``tag`` is introduced to search modules based on tags applied.
It applies to :subcmd:`avail`, :subcmd:`whatis` and :subcmd:`paths`
sub-commands. Tag abbreviation may also be used as extra specifier name.

.. parsed-literal::

    :ps:`$` module avail tag:sticky
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    :sgrs:`bar/1`

Multiple names can now be specified on one extra specifier criterion to select
modules matching any of these names.

.. parsed-literal::

    :ps:`$` module avail tag:S,F
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    :sgrs:`bar/1`  :sgrf:`qux/1`

Multiple values can now be specified on one variant criterion to select
modules providing any of these variant values.

.. parsed-literal::

    :ps:`$` module config variant_shortcut toolchain=%
    :ps:`$` module avail %a,c
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    baz/1{:sgrvahi:`%c`}  foo/1{:sgrvahi:`%a`,\ :sgrva:`b`,\ :sgrvahi:`c`}
    :ps:`$` module avail %a,c %b
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    foo/1{:sgrvahi:`%a`,\ :sgrvahi:`b`,\ :sgrvahi:`c`}

Purging sticky modules
^^^^^^^^^^^^^^^^^^^^^^

The :mconfig:`sticky_purge` configuration option is added to define the
behavior of :subcmd:`purge` sub-command when unloading a sticky or
super-sticky module.

By default an ``error`` is raised. :mconfig:`sticky_purge` can be changed to
emit a ``warning`` message instead or to be ``silent``.

.. parsed-literal::

    :ps:`$` module purge
    Unloading :sgrshi:`foo/1.0`
      :sgrer:`ERROR`: Unload of sticky module skipped
    :ps:`$` module config sticky_purge warning
    :ps:`$` module purge
    Unloading :sgrshi:`foo/1.0`
      :sgrwa:`WARNING`: Unload of sticky module skipped
    :ps:`$` module config sticky_purge silent
    :ps:`$` module purge
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrs:`foo/1.0`

    Key:
    :sgrs:`sticky`


Specific modulepath labels
^^^^^^^^^^^^^^^^^^^^^^^^^^

:mfcmd:`modulepath-label` command is introduced to define a label to use to
designate modulepath in module :subcmd:`avail` output. This new command should
be used in global or modulepath-specific rc files.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/.modulerc
    #%Module
    modulepath-label . Tools
    :ps:`$` module avail foo
    ---------------------- :sgrdi:`Tools` ----------------------
    foo/1.0  foo/2.0

Unique module name loaded
^^^^^^^^^^^^^^^^^^^^^^^^^

The configuration option :mconfig:`unique_name_loaded` is introduced to allow
only one module loaded per module name. It is similar to the *One name rule*
feature introduced by the `Lmod`_ project.

When enabled, :mconfig:`unique_name_loaded` produces a conflict definition
at the start of modulefile evaluation for each actual and alternative module
root name. For instance when loading a module named ``foo/sub/1.0`` with a
``qux/1.0`` alias, it produces a conflict against ``foo`` and ``qux``.

When loading a module that shares a name with an already loaded module, an
error is raised due to the conflict definition. This error aborts the module
load evaluation.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/1.0
    #%Module
    :ps:`$` cat /path/to/modulefiles/bar/2.0
    #%Module
    :ps:`$` module config unique_name_loaded 1
    :ps:`$` module load bar/1.0
    :ps:`$` module load bar/2.0
    Loading :sgrhi:`bar/2.0`
      :sgrer:`ERROR`: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload bar" first.

:mconfig:`unique_name_loaded` is disabled by default. It can be changed with
module :subcmd:`config` sub-command or at installation time with
:instopt:`--enable-unique-name-loaded` configure script option.

Cache sourced files
^^^^^^^^^^^^^^^^^^^

You may have gathered common Tcl code files used by all your modulefiles in
Tcl files that are sourced with :manpage:`source(n)` Tcl command. When loading
multiple modulefiles at once, these sourced files may be read for every loaded
modules, which may induce some I/O load.

The configuration option :mconfig:`source_cache` is introduced to cache files
evaluated through ``source`` Tcl command in order to only read them once
during a :file:`modulecmd.tcl` execution. When this option is enabled, sourced
file read also benefits from optimized I/O calls of Modules Tcl extension
library.

In the following example, 20 modules are loaded, each of them sources the same
Tcl file:

  .. parsed-literal::

    :ps:`$` syscall_list=close,fcntl,ioctl,newfstatat,openat,read,readlink
    :ps:`$` strace -f -e $syscall_list -c $MODULES_CMD bash load foo/20
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     31.48    0.000781           1       466           read
     28.58    0.000709           5       131        16 openat
     14.19    0.000352           2       142         3 newfstatat
      9.71    0.000241           1       124           close
      8.02    0.000199           0       212       211 readlink
      4.55    0.000113           1        67        47 ioctl
      3.47    0.000086           1        60           fcntl
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.002481           2      1202       277 total

When sourced file is cached, it is only read once which saves a substantial
amount of I/O operations:

  .. parsed-literal::

    :ps:`$` module config source_cache 1
    :ps:`$` strace -f -e $syscall_list -c $MODULES_CMD bash load foo/20
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     34.41    0.000523           4       112        16 openat
     27.37    0.000416           0       428           read
     11.84    0.000180           1       122         3 newfstatat
     11.51    0.000175           1       105           close
      7.11    0.000108           2        47        27 ioctl
      5.99    0.000091           0        92        91 readlink
      1.78    0.000027           0        40           fcntl
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.001520           1       946       137 total

.. _Abort on error:

Abort on error
^^^^^^^^^^^^^^

When an error occurs during the evaluation of a modulefile, several module
sub-commands, like :subcmd:`load` or :subcmd:`unload`, continue their
processing. It means these sub-commands do not stop if they have multiple
modulefiles to evaluate. This is named the *continue on error* behavior.

The :mconfig:`abort_on_error` configuration option is introduced to abort, for
the sub-commands listed in its value, the evaluation of multiple modulefiles
if one fails to evaluate.

The *abort on error* behavior is applied by default on :command:`ml` command,
:subcmd:`reload` sub-command and the unload phase of :subcmd:`switch`
sub-command. This behavior may also be turned on for :subcmd:`load`,
:subcmd:`mod-to-sh`, :subcmd:`purge`, :subcmd:`switch`, :subcmd:`try-load` and
:subcmd:`unload` sub-commands. If a command is removed from
:mconfig:`abort_on_error`'s value, it applies the *continue on error*
behavior.

In the following example, *abort on error* behavior is applied to
:subcmd:`load` sub-command to stop evaluation instead of loading the remaining
modulefile in the sequence if first modulefile fails to evaluate.

  .. parsed-literal::

    :ps:`$` module load foo bar
    Loading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Module evaluation aborted
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) bar/1
    :ps:`$` module purge
    :ps:`$` module config abort_on_error +load
    :ps:`$` module load foo bar
    Loading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Module evaluation aborted
    :ps:`$` module list
    No Modulefiles Currently Loaded.

When enabled for :subcmd:`switch` sub-command, whole action aborts if
switched-on modulefile fails to load. By default, :subcmd:`switch` only aborts
if switched-off modulefile fails to unload.

  .. parsed-literal::

    :ps:`$` module load bar
    :ps:`$` module switch bar foo
    Loading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Module evaluation aborted

    Switching from :sgrhi:`bar/1` to :sgrhi:`foo/1`
      :sgrwa:`WARNING`: Load of switched-on foo/1 failed
    :ps:`$` module list
    No Modulefiles Currently Loaded.
    :ps:`$` module load bar
    :ps:`$` module config abort_on_error +switch
    :ps:`$` module switch bar foo
    Loading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Module evaluation aborted

    Switching from :sgrhi:`bar/1` to :sgrhi:`foo/1`
      :sgrwa:`WARNING`: Load of switched-on foo/1 failed
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) bar/1

:mconfig:`abort_on_error` configure option has no impact on :mfcmd:`module`
commands defined in modulefiles. When :option:`--force` option is set,
sub-commands apply the *continue on error* behavior.

When :instopt:`--enable-new-features` installation option is set, the
*abort on error* behavior is also enabled on :subcmd:`load` and
:subcmd:`switch` sub-commands.

Improve error reporting
^^^^^^^^^^^^^^^^^^^^^^^

Module evaluation error reports have been tweaked to appear where these errors
occur rather reporting them on the message block of the main action. Such
change helps to better understand the module evaluation flow.

  .. parsed-literal::

    :ps:`$` module load baz
    Loading :sgrhi:`baz/1`
      :sgrin:`Loading requirement`: foo/1
    :ps:`$` module switch foo bar
    Unloading :sgrhi:`baz/1`
      :sgrme:`Module ERROR`: invalid command name "bad_command"
            while executing
        "bad_command"
            (file "/path/to/modulefiles/baz/1" line 4)
        Please contact <root@localhost>

    Unloading :sgrhi:`foo/1`
      :sgrer:`ERROR`: Unload of dependent baz/1 failed

    Switching from :sgrhi:`foo/1` to :sgrhi:`bar`
      :sgrer:`ERROR`: Unload of switched-off foo/1 failed

:subcmd:`switch` sub-command specific error messages are not reported when
:mfcmd:`module switch<module>` command is run from a modulefile (like *unload
of switched-off module failed*, *load of switched-on module failed* messages
or *Switching* block message). On :subcmd:`switch` sub-command, load failure
of switched-on module is now reported as an error.

  .. parsed-literal::

    :ps:`$` module load foo
    :ps:`$` module switch foo qux
    Loading :sgrhi:`qux/1`
      :sgrme:`Module ERROR`: invalid command name "bad_command"
            while executing
        "bad_command"
            (file "/path/to/modulefiles/qux/1" line 2)
        Please contact <root@localhost>

    Switching from :sgrhi:`foo/1` to :sgrhi:`qux/1`
      :sgrer:`ERROR`: Load of switched-on qux/1 failed

Conflict error messages now describe the loaded module name and version that
conflicts rather the generic conflict module specification.

  .. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/1
    #%Module
    conflict foo
    :ps:`$` module load foo
    :ps:`$` module load bar
    Loading :sgrhi:`bar/1`
      :sgrer:`ERROR`: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload foo/1" first.

New options for source-sh modulefile command
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Support for new *shell* mode named ``bash-eval`` is added to
:mfcmd:`source-sh` modulefile command. With this new mode, the generated
output of the bash shell script is evaluated to get the environment changes
instead of sourcing this script.

  .. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/foo-output.sh
    #!/bin/bash
    cat <<EOF
    export FOO=value;
    alias foo_alias='echo foo_alias;'
    foo_function() {
        echo foo_function;
    }
    EOF
    :ps:`$` cat /path/to/modulefiles/foo/1
    #%Module
    set foo_script [file dirname $ModulesCurrentModulefile]/foo-output.sh
    :sgrhi:`source-sh bash-eval` $foo_script

    :ps:`$` module show foo/1
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1`:

    :sgrcm:`set-alias`       foo_alias {echo foo_alias;}
    :sgrcm:`set-function`    foo_function {
        echo foo_function}
    :sgrcm:`setenv`          FOO value
    -------------------------------------------------------------------
    :ps:`$` module load foo/1
    :ps:`$` foo_alias
    foo_alias

``bash-eval`` *shell* support is also available on :subcmd:`sh-to-mod`
sub-command.

A new option is added to :mfcmd:`source-sh` modulefile command: ``--ignore``.
It filters shell elements changed by script, not to get these changes applied
when loading modulefile. This option accepts a list, separated by colon
character, of shell elements: ``envvar``, ``alias``, ``function``,
``complete`` or ``chdir``.

  .. parsed-literal::

    :ps:`$` module purge
    :ps:`$` cat /path/to/modulefiles/foo/2
    #%Module
    set foo_script [file dirname $ModulesCurrentModulefile]/foo-output.sh
    :sgrhi:`source-sh --ignore alias:function bash-eval` $foo_script

    :ps:`$` module show foo/2
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/2`:

    :sgrcm:`setenv`          FOO value
    -------------------------------------------------------------------
    :ps:`$` module load foo/2
    :ps:`$` foo_alias
    bash: foo_alias: command not found

This ``--ignore`` option can be used with any *shell* supported by
:mfcmd:`source-sh`.


v5.3
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.3 release notes<5.3 release notes>` for a complete
list of the changes between Modules v5.2 and v5.3.

Module cache
^^^^^^^^^^^^

A module cache file can be created under each modulepath directory with new
:subcmd:`cachebuild` sub-command. Cache file is named :file:`.modulecache` and
contains in one file all modulefiles and modulercs found in modulepath
directory.

When cache file is available, module search mechanism uses this file rather
walking through the content of modulepath directory. I/O operations are saved
this way which reduces search processing time.

When searching for available modules without cache, each file contained
in enabled modulepaths is opened to check if it is a modulefile or not. Such
checks lead to a large number of I/O operations on large module setup like in
the below example where a total of 1051 modulefiles are available:

  .. parsed-literal::

    :ps:`$` module -o "" avail -t | wc -l
    1051
    :ps:`$` syscall_list=access,close,getdents64,newfstatat,openat,read
    :ps:`$` strace -f -e $syscall_list -c $MODULES_CMD bash avail
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     31.09    0.003776           2      1424         9 openat
     28.56    0.003469           2      1649         3 newfstatat
     14.08    0.001710           1      1421           close
     11.85    0.001439           3       460           getdents64
     10.88    0.001321           0      1505           read
      3.54    0.000430           4       107         5 access
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.012145           1      6566        17 total

After building cache file for every enabled modulepaths in this example setup,
a lot of I/O operations are saved when searching for available modules:

  .. parsed-literal::

    :ps:`$` module cachebuild
    Creating :sgrhi:`/path/to/modulefiles/.modulecache`
    Creating :sgrhi:`/path/to/modulefiles.2/.modulecache`
    Creating :sgrhi:`/path/to/modulefiles.3/.modulecache`
    :ps:`$` module config cache_buffer_bytes 1000000
    :ps:`$` strace -f -e $syscall_list -c $MODULES_CMD bash avail
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     70.19    0.000544           2       255           read
     13.16    0.000102           2        38         9 openat
      8.90    0.000069           1        35           close
      6.06    0.000047           1        31         2 newfstatat
      1.68    0.000013           1        11         2 access
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.000775           2       370        13 total

A significant execution time drop may be noticed, especially if modulepath
directories are stored on heavily loaded network filesystem.

To further optimize I/O operation count, the :mconfig:`cache_buffer_bytes`
configuration option can be set like in the above example to use fewer number
of ``read`` operation to load cache file content.

To build cache file, user should be granted write access on modulepath
directory. Modulefiles or directories that are not accessible for everyone are
not recorded in cache. An indication is saved instead to test these limited
access elements when cache is loaded to determine if they are available to
currently running user.

Cache file can be ignored with :option:`--ignore-cache` command line switch or
more permanently with :mconfig:`ignore_cache` configuration option.

Cache file is valid indefinitely by default but :mconfig:`cache_expiry_secs`
configuration option can be used to define the number of seconds a cache file
is considered valid after being generated. Expired cache file is ignored.

Cache file of enabled modulepaths can be deleted all at once with
:subcmd:`cacheclear` sub-command.

Querying available module variants
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new mechanism named :ref:`Extra match search` is introduced to evaluate
modulefiles during a module search to find those matching an extra query on a
variant value, a dependency or an environment variable definition.

During this specific evaluation, modulefiles are interpreted in *scan* mode to
collect the different Tcl modulefile commands they use. Special care should be
given when writing modulefiles to ensure they cope with such evaluation mode.

:ref:`Extra match search` mechanism is available on :subcmd:`avail`,
:subcmd:`whatis` and :subcmd:`paths` sub-commands.

With this new mechanism, it is possible to list all available variant defined
in modulefiles with their associated values:

.. parsed-literal::

    :ps:`$` module config avail_output modulepath:alias:dirwsym:sym:tag:key:variant
    :ps:`$` module config variant_shortcut toolchain=%
    :ps:`$` module avail
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0{:sgrva:`%a`,\ :sgrva:`b`}  foo/1.0{:sgrvade:`%a`}      qux/1.0{:sgrva:`%a`,\ :sgrva:`b`}  
    bar/2.0{:sgrvade:`%b`}    foo/2.0{:sgrva:`%a`,\ :sgrva:`b`,\ :sgrva:`c`}  qux/2.0{:sgrva:`%b`,\ :sgrva:`c`}  

    Key:
    :sgrdi:`modulepath`       {:sgrva:`%value`}={:sgrva:`toolchain=value`}  
    :sgrde:`default-version`  {:sgrva:`variant=value`} 

You can also search for modules defining a specific variant value:

.. parsed-literal::

    :ps:`$` module avail %a
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0{:sgrvahi:`%a`,\ :sgrva:`b`}  foo/1.0{:sgrvadehi:`%a`}  foo/2.0{:sgrvahi:`%a`,\ :sgrva:`b`,\ :sgrva:`c`}  qux/1.0{:sgrvahi:`%a`,\ :sgrva:`b`}  

    Key:
    :sgrdi:`modulepath`       {:sgrva:`%value`}={:sgrva:`toolchain=value`}  
    :sgrde:`default-version`  {:sgrva:`variant=value`} 

.. note:: As extra match search implies additional modulefile evaluations, it
   is advised to build and use `Module cache`_ to improve search speed.

Two new elements, ``variant`` and ``variantifspec``, are added to the allowed
value list of :mconfig:`avail_output` and :mconfig:`avail_terse_output`
configuration options. The latter is set in the default value list of both
options. When ``variant`` is set, variants and their possible values are
reported along module they are associated to. When ``variantifspec`` is set,
available variants are reported only if a variant is specified in search
query.

.. parsed-literal::

    :ps:`$` module config --reset avail_output
    :ps:`$` module config avail_output
    Modules Release 5.3.0 (2023-05-14)

    - :sgrhi:`Config. name` ---------.- :sgrhi:`Value (set by if default overridden)` ---------------
    avail_output              modulepath:alias:dirwsym:sym:tag:variantifspec:key
    :ps:`$` module avail foo
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    :sgrhi:`foo`/1.0  :sgrhi:`foo`/2.0  

    Key:
    :sgrdi:`modulepath`  
    :ps:`$` module avail foo %a
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    :sgrhi:`foo`/1.0{:sgrvadehi:`%a`}  :sgrhi:`foo`/2.0{:sgrvahi:`%a`,\ :sgrva:`b`,\ :sgrva:`c`}  

    Key:
    :sgrdi:`modulepath`       {:sgrva:`%value`}={:sgrva:`toolchain=value`}  
    :sgrde:`default-version`  {:sgrva:`variant=value`} 

Extra specifiers
^^^^^^^^^^^^^^^^

Extra specifiers are introduced to query content of modulefiles. They can be
specified with *element:name* syntax as part of module specification on module
search commands (:subcmd:`avail`, :subcmd:`paths` and and :subcmd:`whatis`).

Extra specifiers trigger :ref:`Extra match search` mechanism when found in
module specification. Available modulefiles are evaluated in *scan* mode to
collect the different Tcl modulefile commands they use.

.. parsed-literal::

    :ps:`$` module avail variant:toolchain
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0  bar/2.0  foo/1.0  foo/2.0  qux/1.0  qux/2.0  

In the above example, all modulefiles defining a ``toolchain`` variant are
returned.

Most Tcl modulefile commands can be queried with extra specifiers:
``variant``, ``setenv``, ``unsetenv``, ``append-path``, ``prepend-path``,
``remove-path``, ``pushenv``, ``complete``, ``uncomplete``, ``set-alias``,
``unset-alias``, ``set-function``, ``unset-function``, ``chdir``, ``family``,
``prereq``, ``prereq-any``, ``prereq-all``, ``depends-on``, ``always-load``,
``load``, ``load-any``, ``try-load``, ``switch``, ``switch-on``,
``switch-off``, ``conflict`` and ``unload``. Commands that handle environment
variables may be aliased ``envvar``. Commands that define a module requirement
may be aliased ``require`` and those that define a module incompatibility may
be aliased ``incompat``.

When several extra specifiers are set in query, modules returned are those
matching both conditions. In the following example, all modulefiles
interacting with :envvar:`PATH` environment variable and requiring ``foo``
module are returned.

.. parsed-literal::

    :ps:`$` module avail envvar:PATH require:foo
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0  bar/2.0  

Extra specifiers related to module requirement or incompatibility may leverage
the :ref:`Advanced module version specifiers` syntax. On following example,
modulefiles returned are those defining a requirement on ``foo`` module with
version higher or equal to ``1.2`` and variant ``toolchain=a`` selected.

.. parsed-literal::

    :ps:`$` module avail "require:foo@1.2: toolchain=a"
    --------------------- :sgrdi:`/path/to/modulefiles` ---------------------
    bar/1.0  

.. note:: Module aliases or symbolic versions used either in modulefile
   definitions or as extra specifier values are not resolved.

Append or subtract elements to current option value
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For command-line switches and configuration options whose value is a
colon-separated list, it is now possible to append or subtract elements to the
current value. With a ``+`` prefix elements are appended and with a ``-``
prefix elements are subtracted.

This new feature applies to :option:`--output`/:option:`-o` command-line
switches and :mconfig:`avail_output`, :mconfig:`avail_terse_output`,
:mconfig:`list_output`, :mconfig:`list_terse_output`, :mconfig:`colors`,
:mconfig:`protected_envvars`, :mconfig:`shells_with_ksh_fpath`,
:mconfig:`tag_abbrev`, :mconfig:`tag_color_name`, :mconfig:`variant_shortcut`
configuration options.

For instance, to output available *foo* modules without modulepath and tag
information:

.. parsed-literal::

    :ps:`$` module -o -modulepath:tag avail foo
    :sgrhi:`foo`/1.0  :sgrhi:`foo`/2.0

On following example, terse output mode of *list* sub-command is permanently
updated to report variant information:

.. parsed-literal::

    :ps:`$` module config list_terse_output
    Modules Release 5.3.0 (2023-05-14)

    - :sgrhi:`Config. name` ---------.- :sgrhi:`Value (set by if default overridden)` ---------------
    list_terse_output         header
    :ps:`$` module config list_terse_output +variant
    :ps:`$` module config list_terse_output
    Modules Release 5.3.0 (2023-05-14)

    - :sgrhi:`Config. name` ---------.- :sgrhi:`Value (set by if default overridden)` ---------------
    list_terse_output         header:variant (env-var)


v5.2
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.2 release notes<5.2 release notes>` for a complete
list of the changes between Modules v5.1 and v5.2.

Optional requirements
^^^^^^^^^^^^^^^^^^^^^

The ``--optional`` option has been added to the :mfcmd:`prereq`,
:mfcmd:`prereq-all`, :mfcmd:`depends-on` and :mfcmd:`always-load` modulefile
commands to indicate that specified requirement is optional. An automatic
load attempt is also performed for optional requirements. If requirement is
not found or cannot be loaded, the dependency is yet considered satisfied as
it is optional.

.. parsed-literal::

    :ps:`$` module show foo
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo`:

    :sgrcm:`prereq`          --optional bar
    -------------------------------------------------------------------
    :ps:`$` module load foo
    Loading :sgrhi:`foo`
      :sgrin:`Loading requirement`: bar


If the optional requirement is unloaded or loaded afterward, the dependent
module is automatically reloaded thanks to the :mconfig:`auto_handling`
mechanism.

.. parsed-literal::

    :ps:`$` module unload bar
    Unloading :sgrhi:`bar`
      :sgrin:`Unloading dependent`: foo
      :sgrin:`Reloading dependent`: foo
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo
    :ps:`$` module load bar
    Loading :sgrhi:`bar`
      :sgrin:`Unloading dependent`: foo
      :sgrin:`Reloading dependent`: foo

Modules loaded by other modules with the :mfcmd:`module try-load<module>`
command are now considered optional requirements. Dependent module can be
loaded without the *try-load* modules, but now it gets automatically reloaded
if *try-load* module is loaded afterward, to take it into account.

Linting modulefiles
^^^^^^^^^^^^^^^^^^^

Static analysis of modulefile, modulerc and global/user rc is now possible
with :subcmd:`lint` sub-command. It relies on an external program defined with
:mconfig:`tcl_linter` configuration option. Modules or files specified on the
command-line are resolved then passed to the Tcl linter program.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.0
    #%Module
    if {"str" eq} {
     else {
    }
    :ps:`$` module lint foo/1.0
    Linting :sgrhi:`/path/to/modulefiles/foo/1.0`
      :sgrer:`ERROR   line 2`: Could not complete statement.
        One close brace would complete the first line
        One close brace would complete at end of line 4.
        One close brace would complete the script body at line 5.
        Assuming completeness for further processing.
      :sgrer:`ERROR   line 2`: Bad expression: missing operand at _@_
        in expression ""str" eq_@_"
      :sgrwa:`WARNING line 3`: Unknown command "else"
      :sgrin:`NOTICE  line 4`: Close brace not aligned with line 3 (1 0)

`Nagelfar`_ is the Tcl linter recommended for Modules and set by default. This
default can be changed at installation time with :instopt:`--with-tcl-linter`
and :instopt:`--with-tcl-linter-opts` options. It can also be configured later
on through :mconfig:`tcl_linter` config option.

Specific syntax databases and plugins for `Nagelfar`_ are added by Modules to
precisely lint modulefile commands syntax in addition to regular Tcl syntax.
The installation of these specific files is controlled with
:instopt:`--enable-nagelfar-addons` option (enabled by default). Their
location is controlled by the :instopt:`--nagelfardatadir` option.

.. parsed-literal::

    :ps:`$` module lint bar@:1 /path/to/modulefiles/.modulerc
    Linting :sgrhi:`/path/to/modulefiles/.modulerc`
      :sgrer:`ERROR   line 35`: Wrong number of arguments (3) to "module-alias"
      :sgrer:`ERROR   line 41`: Wrong number of arguments (3) to "module-virtual"

    Linting :sgrhi:`/path/to/modulefiles/bar/1.2`
      :sgrwa:`WARNING line 19`: Unknown command "unk"
    :ps:`$` module lint ~/.modulerc
    Linting :sgrhi:`/home/user/.modulerc`
      :sgrwa:`WARNING line 2`: Command "setenv" should not be be used in global rc file

:subcmd:`lint` sub-command outputs messages returned by the Tcl linter
program. Nagelfar produces NOTICE, WARNING and ERROR messages. If linter does
not report a thing, :subcmd:`lint` sub-command will be silent, unless if the
:option:`--verbose`/:option:`-v` is set.

.. parsed-literal::

    :ps:`$` module lint /path/to/modulefiles/bar/.version bar/1.4
    :ps:`$` module lint -v /path/to/modulefiles/bar/.version bar/1.4
    Linting :sgrhi:`/path/to/modulefiles/bar/.version`
    Linting :sgrhi:`/path/to/modulefiles/bar/1.4`

When no file is specified to :subcmd:`lint` sub-command, all the global/user
rc files and all the modulefiles and modulercs from enabled modulepaths are
analyzed. If the :option:`--all`/:option:`-a` option is set, all hidden
modulefiles are also linted.

.. parsed-literal::

    :ps:`$` module lint
    Linting :sgrhi:`/home/user/.modulerc`
      :sgrwa:`WARNING line 2`: Command "setenv" should not be be used in global rc file

    Linting :sgrhi:`/path/to/modulefiles/.modulerc`
      :sgrer:`ERROR   line 35`: Wrong number of arguments (3) to "module-alias"
      :sgrer:`ERROR   line 41`: Wrong number of arguments (3) to "module-virtual"

    Linting :sgrhi:`/path/to/modulefiles/bar/1.2`
      :sgrwa:`WARNING line 19`: Unknown command "unk"
    ...

To use `Nagelfar`_ as Tcl linter for Modules, this open source tool has to be
installed on your system. When installing from tarball distribution, make sure
:command:`nagelfar.tcl` command is found through a :envvar:`PATH` lookup or
that :mconfig:`tcl_linter` option is set to its full path location.
`Nagelfar`_ is also made available as a RPM package in `EPEL and Fedora
repositories`_.

.. _Nagelfar: http://nagelfar.sourceforge.net/
.. _EPEL and Fedora repositories: https://src.fedoraproject.org/rpms/nagelfar

mod-to-sh sub-command
^^^^^^^^^^^^^^^^^^^^^

New sub-command is added to translate modulefile into shell code:
:subcmd:`mod-to-sh`. It evaluates modulefiles passed as argument and produces
code for specified shell.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo
    #%Module
    setenv FOO value
    set-function foo {echo foo}
    :ps:`$` module mod-to-sh bash foo
    FOO=value; export FOO;
    foo () { echo foo; }; export -f foo;

Designated modulefiles are evaluated as if they were loading. But instead of
producing shell code that is evaluated in current shell session,
:command:`module` command outputs this shell code.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar
    #%Module
    setenv BAR othervalue
    set-alias bar {echo bar}
    :ps:`$` module mod-to-sh fish foo bar
    set -xg FOO value;
    set -xg BAR othervalue;
    alias bar echo\ bar;
    function foo; echo foo; end;
    :ps:`$` module list
    No Modulefiles Currently Loaded.

All shells supported by :file:`modulecmd.tcl` script are supported by
:subcmd:`mod-to-sh`.

.. parsed-literal::

    :ps:`$` module mod-to-sh python foo bar
    import os
    os.environ['FOO'] = 'value'
    os.environ['BAR'] = 'othervalue'

.. _Initial environment:

Initial environment
^^^^^^^^^^^^^^^^^^^

When Modules initializes, it evaluates the :file:`initrc` and
:file:`modulespath` configuration files to enable default modulepaths and load
default modules. Initial environment corresponds to the environment state
after this initialization.

Initial environment is now saved in an environment variable
(:envvar:`__MODULES_LMINIT`) in current shell session to remember what are the
initial modulepaths and initial modules with their tags and variants if any.

:subcmd:`reset` sub-command is introduced, in a similar fashion than on
`Lmod`_, to restore the initial environment. Here, :subcmd:`reset` relies on
the :ref:`collection<collections>` mechanism based and the content of
:envvar:`__MODULES_LMINIT`. Currently enabled modulepaths and loaded modules
are respectively unused and unloaded to use the modulepaths and load the
modules with tags and variants as described by initial environment.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.0   2) bar/1.0
    :ps:`$` module switch bar/1.0 qux/1.0
    :ps:`$` module reset
    Unloading :sgrhi:`qux/1.0`
    Loading :sgrhi:`bar/1.0`

:subcmd:`restore` sub-command has been adapted to reinitialize the environment
to its initial state when no collection name is provided and no *default*
collection exists or if ``__init__`` virtual collection name is provided.

It is possible to view the content of the initial environment with
:subcmd:`saveshow` sub-command. It is displayed when no argument is provided
and no collection exists or if ``__init__`` name is provided.

.. parsed-literal::

    :ps:`$` module saveshow __init__
    -------------------------------------------------------------------
    :sgrhi:`initial environment`:

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foo/1.0
    :sgrcm:`module` load bar/1.0

    -------------------------------------------------------------------

Users have the ability to define what is their initial environment state and
thus adapt the behavior of :subcmd:`reset` sub-command with
:mconfig:`reset_target_state` configuration option. Default value is
``__init__`` and it corresponds to the behavior described above. When set to
``__purge__``, a :subcmd:`purge` command is performed when resetting. Any
other value corresponds to the name of a collection to restore.

.. parsed-literal::

    :ps:`$` module config reset_target_state __purge__
    :ps:`$` module reset
    Unloading bar/1.0
    Unloading foo/1.0

.. _Stashing environment:

Stashing environment
^^^^^^^^^^^^^^^^^^^^

The ability to stash current environment is added with the introduction of the
:subcmd:`stash` sub-command. When called current environment is saved in a
*stash* collection then initial environment is restored.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) bar/2.0   2) foo/2.0
    :ps:`$` module stash
    Unloading :sgrhi:`foo/2.0`
    Unloading :sgrhi:`bar/2.0`
    :ps:`$` module list
    No Modulefiles Currently Loaded.

Sub-commands are added to specifically handle stash collections. Their names
are prefixed with *stash*, like :subcmd:`stashlist` to list existing stash
collections or :subcmd:`stashshow` to display their content.

.. parsed-literal::

    :ps:`$` module stashlist
    Stash collection list:
     0) stash-1665377597432   1) stash-1664946764252
    :ps:`$` module stashshow
    -------------------------------------------------------------------
    :sgrhi:`/home/user/.module/stash-1665377597432:`

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load bar
    :sgrcm:`module` load foo

    -------------------------------------------------------------------

Stash collections can be designated on sub-commands by their collection name
or stash index. Most recent stash collection has index ``0``, the one after is
designated with index ``1``, and so on. When no stash collection is specified,
most recent one is assumed.

.. parsed-literal::

    :ps:`$` module stashshow 1
    -------------------------------------------------------------------
    :sgrhi:`/home/user/.module/stash-1664946764252:`

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foobar

    -------------------------------------------------------------------

Stash collections are restored with the :subcmd:`stashpop` sub-command. It
changes the user environment to match the stash definition, then it deletes
the stash collection file.

.. parsed-literal::

    :ps:`$` module stashpop
    Loading :sgrhi:`bar/2.0`
    Loading :sgrhi:`foo/2.0`
    :ps:`$` module stashlist
    Stash collection list:
     0) stash-1664946764252

Stash collections can be deleted one by one with :subcmd:`stashrm` sub-command
or all together with :subcmd:`stashclear`.

.. parsed-literal::

    :ps:`$` module stashrm
    :ps:`$` module stashlist
    No stash collection.

Siteconfig hook variables
^^^^^^^^^^^^^^^^^^^^^^^^^

Several Tcl variables are introduced for :ref:`Site-specific configuration`
script to define specific commands and variables in the evaluation context of
modulefiles and modulercs. These commands and variables setup in
:file:`siteconfig.tcl` can be used in modulefile or modulerc. Sites can easily
extend modulefile and modulerc syntax with specific elements.

:sitevar:`modulefile_extra_cmds` variable defines a list of commands to expose
in the modulefile evaluation context and the associated procedure to run when
this command is called. This variable has to be defined in
:file:`siteconfig.tcl` located for instance at |file etcdir_siteconfig|.

In the following example :sitevar:`modulefile_extra_cmds` is used to define
the ``sys`` command and bound it to the ``sys`` procedure that is also defined
in :file:`siteconfig.tcl`.

.. code-block:: tcl

    proc sys {mode} {
       switch -- $mode {
          name    { return myhost-$::tcl_platform(machine) }
          default { error "Unknown mode '$mode'" }
       }
    }
    set modulefile_extra_cmds {sys sys}

Once :file:`siteconfig.tcl` is setup, the ``sys`` command can be called by
modulefiles. In the following example it is used to determine the application
path.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.2
    #%Module
    append-path PATH /path/to/apps/foo-1.2/[sys name]/bin

    :ps:`$` module show foo/1.2
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.2`:

    :sgrcm:`append-path`     PATH /path/to/apps/foo-1.2/myhost-x86_64/bin
    -------------------------------------------------------------------

:sitevar:`modulerc_extra_cmds` follows the same approach than
:sitevar:`modulefile_extra_cmds` and makes specific commands available during
modulerc evaluation.

:sitevar:`modulefile_extra_vars` variable defines a list of variables to
expose in the modulefile evaluation context and their associated value. This
variable has to be defined in :file:`siteconfig.tcl`.

In the following example :sitevar:`modulefile_extra_vars` is used to define
the ``APP_ROOT`` variable with ``/path/to/apps`` as value.

.. code-block:: tcl

    set modulefile_extra_vars {APP_ROOT /path/to/apps}

Once :file:`siteconfig.tcl` is setup, the ``APP_ROOT`` variable can be used in
modulefiles.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/2.1
    #%Module
    append-path PATH $APP_ROOT/bar-2.1/[sys name]/bin

    :ps:`$` module show bar/2.1
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/2.1`:

    :sgrcm:`append-path`     PATH /path/to/apps/bar-2.1/myhost-x86_64/bin
    -------------------------------------------------------------------

:sitevar:`modulerc_extra_vars` follows the same approach than
:sitevar:`modulefile_extra_vars` and makes specific variables available during
modulerc evaluation.


v5.1
----

This new version is backward-compatible with previous version 5 release. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`5.1 release notes<5.1 release notes>` for a complete
list of the changes between Modules v5.0 and v5.1.

Control output redirection
^^^^^^^^^^^^^^^^^^^^^^^^^^

Since version 4.0, the :command:`module` function is initialized differently
on *sh*, *bash*, *ksh*, *zsh* and *fish* shells when their session is found
interactive. In such situation :command:`module` redirects its output from
*stderr* to *stdout*. Once initialized the redirection behavior is inherited
in sub-sessions.

The :mconfig:`redirect_output` configuration option is introduced in version
5.1, to supersede the default behavior set at initialization time.

.. parsed-literal::

    :ps:`$` module load unknown >/dev/null
    :ps:`$` module config redirect_output 0
    :ps:`$` module load unknown >/dev/null
    :sgrer:`ERROR`: Unable to locate a modulefile for 'unknown'

The :option:`--redirect` and :option:`--no-redirect` command-line switches are
also added to change the output redirection behavior for a single command:

.. parsed-literal::

    :ps:`$` module load unknown --redirect >/dev/null
    :ps:`$` module load unknown --no-redirect >/dev/null
    :sgrer:`ERROR`: Unable to locate a modulefile for 'unknown'

.. _Change modulefile command behavior:

Change modulefile command behavior
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Depending on the evaluation mode of the modulefile (e.g. *load*, *unload*,
*display*, etc) commands have different behavior. Most common example is the
:mfcmd:`setenv` command that sets an environment variable when modulefile is
loaded and unsets it when it is unloaded. A different behavior may be wished
sometimes for commands. This is why options are introduced for some modulefile
commands to control what happens on particular evaluation mode.

The ``--return-value`` option is added to the :mfcmd:`getenv` and
:mfcmd:`getvariant` modulefile commands to ensure that the value of the
designated environment variable or variant is returned even if modulefile is
evaluated in *display* mode:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.0
    #%Module5.1
    if {[getenv --return-value VAR] eq {}} {
        setenv VAR value
    }
    :ps:`$` module display foo/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:

    :sgrcm:`setenv`          VAR value
    -------------------------------------------------------------------

``--remove-on-unload``, ``--append-on-unload``, ``--prepend-on-unload`` and
``--noop-on-unload`` options are added to the :mfcmd:`remove-path` and
:mfcmd:`module unuse<module>` modulefile commands to control the behavior
applied when modulefile is unloaded. With these options it is possible for
instance to restore the paths unset at load time or to set other paths:

.. parsed-literal::

    :ps:`$` module display bar/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/1.0`:

    :sgrcm:`module`          unuse --prepend-on-unload /path/to/dir1
    :sgrcm:`module`          use /path/to/dir2
    -------------------------------------------------------------------
    :ps:`$` module use
    Search path for module files (in search order):
      :sgrmp:`/path/to/dir1`
      :sgrmp:`/path/to/modulefiles`
    :ps:`$` module bar/1.0
    :ps:`$` module use
    Search path for module files (in search order):
      :sgrmp:`/path/to/dir2`
      :sgrmp:`/path/to/modulefiles`
    :ps:`$` module unload bar/1.0
    :ps:`$` module use
    Search path for module files (in search order):
      :sgrmp:`/path/to/dir1`
      :sgrmp:`/path/to/modulefiles`

Following the same trend, the ``--unset-on-unload`` and ``--noop-on-unload``
options are added to the :mfcmd:`unsetenv` modulefile command to be able to
choose between unsetting variable, setting a value or performing no operation
when modulefile is unloaded.

Reducing number of I/O operations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A new configuration option named :mconfig:`mcookie_check` is introduced to
control the verification made to files to determine if they are modulefiles.
By default this configuration option is set to ``always`` and when searching
for modulefiles within enabled modulepaths each file below these directories
is opened to check if it starts with the Modules magic cookie (i.e.,
``#%Module`` file signature).

These historical checks lead to a large number of I/O operations on large
module setup like in the below example where a total of 1098 modulefiles are
available:

  .. parsed-literal::

    :ps:`$` module -o "" avail -t | wc -l
    1098
    :ps:`$` module config mcookie_check always
    :ps:`$` strace -f -e open,openat,read,close -c $MODULES_CMD bash avail
    ...
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     44.29    0.044603          25      1734       166 open
     34.15    0.034389          16      2056           close
     11.87    0.011949          24       483         5 openat
      9.69    0.009761           4      2146           read
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.100702                  6419       171 total

For each file, 3 I/O operations (``open``, ``read`` and ``close``) are
achieved to determine if it is a modulefile and include it in search results.
When modulefiles are located in a shared filesystem concurrently accessed by
hundreds of users, a ``module avail`` command may take some time to finish.

When setting the :mconfig:`mcookie_check` configuration option to the ``eval``
value, files are not checked anymore when searching for modulefiles, only when
evaluating them. All files under modulepaths are considered modulefiles, so
the content of these directories must be carefully checked to use this
:mconfig:`mcookie_check` mode which lead to a significant reduction of I/O
operations:

  .. parsed-literal::

    :ps:`$` module config mcookie_check eval
    :ps:`$` strace -f -e open,openat,read,close -c $MODULES_CMD bash avail
    ...
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     30.56    0.013717          14       944           close
     28.76    0.012911          21       612       156 open
     26.41    0.011857          24       483         5 openat
     14.26    0.006403           6      1034           read
    ------ ----------- ----------- --------- --------- ----------------
    100.00    0.044888                  3073       161 total

A substantial reduction of execution time may be noticed depending on the
storage setup used to host the modulepath directories. A special care should
be given to the content of these directories to ensure they only contain
modulefiles (see :envvar:`MODULES_MCOOKIE_CHECK`).

See the :ref:`reduce-io-load` cookbook recipe to learn additional features of
Modules that could be leveraged to lower the number of I/O operations.

Shell command completion
^^^^^^^^^^^^^^^^^^^^^^^^

New modulefile commands :mfcmd:`complete` and :mfcmd:`uncomplete` are added to
get the ability to respectively define and unset command completion. *bash*,
*tcsh* and *fish* shells are supported.

.. parsed-literal::

    :ps:`>` module display foo
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:

    :sgrcm:`append-path`     PATH /path/to/foo-1.0/bin
    :sgrcm:`complete`        fish foo {-s V -l version --description 'Command version'}
    :sgrcm:`complete`        fish foo {-s h -l help --description 'Command help'}
    -------------------------------------------------------------------
    :ps:`>` module load foo
    :ps:`>` foo -<TAB>
    -h  --help  (Command help)  -V  --version  (Command version)

:subcmd:`sh-to-mod` sub-command and :mfcmd:`source-sh` modulefile command have
also been updated to track shell completion changes.

.. parsed-literal::

    :ps:`$` module sh-to-mod bash /path/to/foo-1.0/share/setup-env.sh
    #%Module
    :sgrcm:`complete`        bash foo {-o default -F _foo}
    :sgrcm:`append-path`     PATH /path/to/foo-1.0/bin
    :sgrcm:`set-function`    _foo {
        ...bash completion code...}

Lmod Tcl modulefile support
^^^^^^^^^^^^^^^^^^^^^^^^^^^

With this new version, Modules now supports Tcl modulefiles written for
`Lmod`_, the alternative :command:`module` implementation developed in Lua.
Such modulefiles can be safely evaluated by Modules without raising error.

Support has been added for the following modulefile commands introduced by
Lmod: :mfcmd:`depends-on`, :mfcmd:`prereq-any`, :mfcmd:`always-load`,
:mfcmd:`module load-any<module>`, :mfcmd:`pushenv`, :mfcmd:`require-fullname`
and :mfcmd:`family`.

The :ref:`Compatibility with Lmod Tcl modulefile` section in the
:ref:`modulefile(5)` man page describes the differences existing between the
two implementations.

Note that when processing a :mfcmd:`family` command, the
:envvar:`LMOD_FAMILY_\<NAME\>` environment variable is defined by Modules to
be compatible with existing modulefiles or scripts relying on such variable.

.. _More tagging capabilities:

More tagging capabilities
^^^^^^^^^^^^^^^^^^^^^^^^^

The new :option:`--tag` option helps to define extra tags onto a loading
module. These tags comes in addition to those inherited from the module state
or those associated with the :mfcmd:`module-tag` modulefile command.

The :option:`--tag` option is available on :subcmd:`load`, :subcmd:`load-any`,
:subcmd:`switch` and :subcmd:`try-load` sub-commands and on
:mfcmd:`always-load`, :mfcmd:`depends-on`, :mfcmd:`module`, :mfcmd:`prereq`,
:mfcmd:`prereq-all` and :mfcmd:`prereq-any` modulefile commands.

Informational messages of module evaluation have been updated to mention in
module denomination the tags applying to it, as it is done in :subcmd:`list`
sub-command output:

.. parsed-literal::

    :ps:`$` module load -v --tag=sticky:bar foo/1.0
    Loading :sgrshi:`foo/1.0` <bar>

In case the designated module is already loaded, the additional tags are added
to the list of tags already applied to this module.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.0
    :ps:`$` module load -v --tag=sticky:bar foo/1.0
    Tagging :sgrshi:`foo/1.0` <bar>

The ``keep-loaded`` tag is introduced in this version. It avoids an
auto-loaded module to get automatically unloaded when its dependent modules
are unloaded. This new tag can be set with the :mfcmd:`module-tag` modulefile
command or when module is loaded with the :mfcmd:`always-load` modulefile
command. Default :mconfig:`tag_abbrev` configuration option has been updated
to add the ``kL`` abbreviation for ``keep-loaded`` tag. Default dark and light
color palettes have been updated too.

.. parsed-literal::

    :ps:`$` module show bar/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/1.0`:

    :sgrcm:`always-load`     foo/1.0
    -------------------------------------------------------------------
    :ps:`$` module load bar/1.0
    Loading :sgrhi:`bar/1.0`
      :sgrin:`Loading requirement`: foo/1.0
    :ps:`$` module unload bar/1.0
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgral:`foo`:sgrkl:`/1.0`

    Key:
    :sgral:`auto-loaded`  :sgrkl:`keep-loaded`

When saving a collection, the tags defined with :option:`--tag` option are
recorded to set them again when collection is restored. Tags resulting from
module load state, like ``auto-loaded`` and ``keep-loaded``, are also
recorded.

.. parsed-literal::

    :ps:`$` module load --tag=sticky bar/1.0
    Loading :sgrshi:`bar/1.0`
      :sgrin:`Loading requirement`: foo/1.0
    :ps:`$` module save
    :ps:`$` module saveshow
    -------------------------------------------------------------------
    :sgrhi:`/home/user/.module/default`:

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load --tag=auto-loaded:keep-loaded foo
    :sgrcm:`module` load --tag=sticky bar

    -------------------------------------------------------------------

The :mconfig:`collection_pin_tag` configuration option is added to record in
collection all tags set on loaded modules. This configuration option is
disabled by default.

.. note:: Collection saved now starts with a ``#%Module5.1`` file signature if
   :option:`--tag` option is recorded in it. Such collection could only be
   handled by Modules version 5.1 and above.

v5.0
----

With this new major version the :command:`module` experience has been updated
to benefit by default from all the advanced behaviors and features developed
over the Modules 4 versions. Modules 5.0 also introduces some breaking
changes to improve the consistency of the whole solution. See the :ref:`5.0
release notes<5.0 release notes>` for a complete list of the changes between
Modules v4.8 and v5.0. The :ref:`changes<Modules 5 changes>` document gives an
in-depth view of the modified behaviors.

Upgraded default configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Release after release, new advanced features were added on Modules 4. They
were set off by default to avoid breaking change during the version 4 cycle.
With the move to a new major release, these features are set on to improve by
default usages for everybody. These features enabled by default are:

* :ref:`v42-automated-module-handling-mode` which provides the automatic
  dependency resolution when loading and unloading modules

  .. parsed-literal::

      :ps:`$` module load foo/1.0
      Loading :sgrhi:`foo/1.0`
        :sgrin:`Loading requirement`: bar/1.0

* `Extended default`_ that enables to select a module when the first number
  in its version is specified

  .. parsed-literal::

      :ps:`$` module load -v foo/1
      Loading :sgrhi:`foo/1.2.3`


* :ref:`Advanced module version specifiers`, an improved syntax to designate
  module version in range or list and module variant

  .. parsed-literal::

      :ps:`$` module load foo@:2.2 %gcc11
      Loading :sgrhi:`foo/2.1`:sgrse:`{`:sgrva:`%gcc11`:sgrse:`}`
        :sgrin:`Loading requirement`: bar/1.2\ :sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`%gcc11`:sgrse:`}`

* `Colored output`_ to graphically enhance parts of the produced output to
  improve readability

  .. parsed-literal::

      :ps:`$` ml av
      ------------------ :sgrdi:`/path/to/modulefiles` ------------------
      :sgrde:`bar/1.0`  bar/2.0  :sgrf:`foo/1.0`  :sgrs:`foo/2.0`  :sgrali:`foo/2.2`

      Key:
      :sgrdi:`modulepath`       :sgrali:`module-alias`  :sgrs:`sticky`
      :sgrde:`default-version`  :sgrf:`forbidden`

* :ref:`Insensitive case` search that matches modules using a different
  character case than the one expressed in search query

  .. parsed-literal::

      :ps:`$` ml av liba
      ------------------ :sgrdi:`/path/to/modulefiles` ------------------
      LibA/1.0  LibA/2.0

Some other features that were enabled by default during the Modules 4 cycle
have been turned off as they may not be useful for basic usages. Among other
things setting off the following features makes the definition of the
:command:`module` function simpler. Even if off by default, these features
can now be enabled once Modules is installed through the :file:`initrc`
configuration file.

* *Set shell startup* files to ensure the :command:`module` command is defined
  once shell has been initialized. See the :mconfig:`set_shell_startup`
  configuration option to activate.

* *Quarantine mechanism* that protects the :command:`module` command
  run-time environment from side effect coming from the current environment
  definition. See the :mconfig:`quarantine_support` configuration option to
  activate.

* *Silent shell debug* which disables the debugging property set on current
  shell session for the duration of the :command:`module` command. See the
  :mconfig:`silent_shell_debug` configuration option to activate.

Removing compatibility version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ability to co-install version 3.2 of Modules along newer version is
discontinued. The installation option ``--enable-compat-version``,
:command:`switchml` shell function and :envvar:`MODULES_USE_COMPAT_VERSION`
environment variables are thus removed.

The interesting features of Modules 3.2 that were missing in the
initial Modules 4 release in 2017 have been reintroduced progressively (like
:subcmd:`clear` sub-command or :option:`--icase` search). With Modules 5.0,
the :subcmd:`refresh` sub-command is even changed to the behavior it had on
Modules 3.2. So it is a good time for the big jump.

If you are still using Modules 3.2, please refer to the :ref:`changes`
document that describes the differences of this version compared to the newer
releases.

Improving Modules initialization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Modules initialization files are now installed by default in the *etc*
directory designated by the :instopt:`--etcdir` installation option. The
initialization configuration file is named :file:`initrc` in this directory,
and the modulepath-specific configuration file is named :file:`modulespath`.
When both files exist, now they are both evaluated instead of just the
:file:`modulespath` file.

Modules magic cookie (i.e., ``#%Module`` file signature) is now required at
the start of :file:`initrc`. An error is produced if the magic cookie is
missing or if the optional version number placed after the cookie string is
higher than the version of the :file:`modulecmd.tcl` script in use.

Note that :file:`initrc` configuration file can host more than
:subcmd:`module use<use>` and :subcmd:`module load<load>` commands.
:command:`module` configuration can also be achieved with this file through
the use of :subcmd:`module config<config>` commands.

Modules initialization has been enhanced for situations where a module
environment is found already defined. In this case the loaded modules are
automatically refreshed which is useful to re-apply the non-persistent
environment configuration (i.e., shell alias and function that are not
exported to the sub-shell). For instance when starting a sub-shell session it
ensures that the loaded environment is fully inherited from parent shell:

.. parsed-literal::

    :ps:`$` ml show foo/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:

    :sgrcm:`set-alias`       foo {echo foo}
    -------------------------------------------------------------------
    :ps:`$` ml foo/1.0
    :ps:`$` alias foo
    alias foo='echo foo'
    :ps:`$` bash
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) foo/1.0
    :ps:`$` alias foo
    alias foo='echo foo'

Simplifying path-like variable reference counting
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The reference counting mechanism used for path-like environment variable
enables to determine if a path entry has been added several times (by several
loaded modules for instance) to know whether or not this path entry should be
unset when unloading a module. Entry is not removed if multiple loaded modules
rely on it.

The mechanism is not applied anymore to the Modules-specific path variables
(like :envvar:`LOADEDMODULES`) as an element entry in these variables cannot
be added multiple times without duplication. For instance, a given module name
and version cannot be added twice in :envvar:`LOADEDMODULES` as this module is
only loaded once. With this change a thinner environment is produced by
:command:`module`. An exception is made for :envvar:`MODULEPATH` environment
variable where the mechanism still applies.

.. parsed-literal::

    :ps:`$` $MODULES_CMD bash load foo/2.0
    _LMFILES_=/path/to/modulefiles/foo/2.0; export _LMFILES_;
    LOADEDMODULES=foo/2.0; export LOADEDMODULES;
    __MODULES_LMTAG=foo/2.0\&mytag; export __MODULES_LMTAG;
    test 0;

Reference counting mechanism has also been simplified for entries in path-like
variable that are only referred once. For such entries no entry is set in the
reference counting variable (which are now called
:envvar:`__MODULES_SHARE_\<VAR\>`). A reference count entry is set only if the
entry in the path-like variable is referred more than one time.

.. parsed-literal::

    :ps:`$` ml foo/3.0
    :ps:`$` echo $PATHVAR
    /path/to/dir1
    :ps:`$` echo $__MODULES_SHARE_PATHVAR

    :ps:`$` ml bar/1.0
    :ps:`$` echo $PATHVAR
    /path/to/dir1
    :ps:`$` echo $__MODULES_SHARE_PATHVAR
    /path/to/dir1:2
    :ps:`$` ml -foo/3.0
    :ps:`$` echo $PATHVAR
    /path/to/dir1
    :ps:`$` echo $__MODULES_SHARE_PATHVAR

    :ps:`$`

When the :subcmd:`use` and :subcmd:`unuse` module sub-commands are not called
during a modulefile evaluation, the reference counter associated with each
entry in :envvar:`MODULEPATH` environment variable is ignored. In such
context, a :subcmd:`module use<use>` will not increase the reference counter
of a path entry already defined and a :subcmd:`module unuse<unuse>` will
remove specified path whatever its reference counter value. Same change applies
for :subcmd:`append-path`, :subcmd:`prepend-path` and :subcmd:`remove-path`
module sub-commands when called from the command-line.

.. parsed-literal::

    :ps:`$` echo $MODULEPATH
    /path/to/modulefiles
    :ps:`$` echo $__MODULES_SHARE_MODULEPATH
    /path/to/modulefiles:2
    :ps:`$` ml use /path/to/modulefiles
    :ps:`$` echo $__MODULES_SHARE_MODULEPATH
    /path/to/modulefiles:2
    :ps:`$` ml unuse /path/to/modulefiles
    :ps:`$` echo $MODULEPATH

    :ps:`$` echo $__MODULES_SHARE_MODULEPATH

    :ps:`$`


v4.8
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.8 release notes<4.8 release notes>` for a complete
list of the changes between Modules v4.7 and v4.8.

.. _Editing modulefiles:

Editing modulefiles
^^^^^^^^^^^^^^^^^^^

:subcmd:`edit` sub-command is introduced to give the ability to open
modulefiles in a text editor. Modulefiles can be specified like with any other
sub-command: using regular, symbolic or aliased names or using advanced
version specifiers.

.. parsed-literal::

    :ps:`$` ml edit foo

:subcmd:`edit` sub-command resolves the path toward the designated modulefile
then call configured text editor to open this modulefile with it. Below, the
modulefile is opened with the ``vi`` command:

.. parsed-literal::

    #%Module
    module-whatis [module-info name]
    setenv PATH /path/to/foo-1.0/bin
    ~                                                           
    ~                                                           
    ~                                                           
    "/path/to/modulefiles/foo/1.0" 3L, 42B 1,1           All

The :mconfig:`editor` configuration option controls the editor command to use.
This option can be configured at installation time with the
:instopt:`--with-editor` installation option. If not set, :mconfig:`editor`
configuration option is set by default to ``vi``.

:mconfig:`editor` configuration option can be changed with the
:subcmd:`config` sub-command. Which sets the :envvar:`MODULES_EDITOR`
environment variable.

The :envvar:`VISUAL` or the :envvar:`EDITOR` environment variables override
the default value of :mconfig:`editor` configuration option but are overridden
by the :envvar:`MODULES_EDITOR` environment variable.

Using version range in version list
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :ref:`Advanced module version specifiers` mechanism has been improved to
allow the use of version range (*@:version*, *@vers1:vers2* or *@version:*)
within version list (*@version1,version2,...*).

It is now possible to write for instance ``mod@:1.2,1.4:1.6,1.8:`` to
designate all versions of module *mod*, except versions *1.3* and *1.7*.

This improvement is available where the advanced version specifier syntax is
supported. Thus it can be either used from the command-line or when writing
modulefiles, for instance to hide or tag modules or to declare requirements.

Try module load with no complain if not found
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add the :subcmd:`try-load` sub-command that tries to load the modulefile
passed as argument, like the :subcmd:`load` sub-command, but does not raise an
error if this modulefile cannot be found.

.. parsed-literal::

    :ps:`$` module load unknown
    :sgrer:`ERROR`: Unable to locate a modulefile for 'unknown'
    :ps:`$` echo $?
    1
    :ps:`$` module try-load unknown
    :ps:`$` echo $?
    0
    :ps:`$` module list
    No Modulefiles Currently Loaded.

This sub-command first introduced by the `Lmod`_ project is added to Modules
to improve the compatibility between the two ``module`` implementations.

:subcmd:`try-load` is also available within modulefile context to continue the
evaluation of a modulefile in case no module is found in its attempt to load
another modulefile

.. parsed-literal::

    :ps:`$` module display foo/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:
    
    :sgrcm:`module`   try-load unknown/1.0
    -------------------------------------------------------------------
    :ps:`$` module load foo/1.0
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.0

Module variants
^^^^^^^^^^^^^^^

:ref:`Module variants` is a new mechanism that allows to pass arguments to
evaluated modulefiles in order to achieve different environment variable or
module requirement setup with a single modulefile.

Variant specification relies on the :ref:`Advanced module version specifiers`
mechanism, which leverages the `variant syntax`_ of the `Spack`_ package
manager:

.. _variant syntax: https://spack.readthedocs.io/en/latest/basic_usage.html#variants

.. parsed-literal::

    :ps:`$` module config advanced_version_spec 1
    :ps:`$` module load -v bar/1.2 toolchain=a -debug
    Loading :sgrhi:`bar/1.2`:sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`toolchain=a`:sgrse:`}`

Variants are defined in modulefile with the :mfcmd:`variant` command, which
defines the variant type and its accepted values:

.. code-block:: tcl

    #%Module4.8
    variant toolchain a b c
    variant --boolean --default off debug

    # select software build depending on variant values
    set suffix -[getvariant toolchain]
    if {$ModuleVariant(debug)} {
        append suffix -dbg
    }

    prepend-path PATH /path/to/bar-1.2$suffix/bin
    prepend-path LD_LIBRARY_PATH /path/to/bar-1.2$suffix/lib

The *bar/1.2* modulefile defines a ``toolchain`` variant, which accepts the
``a``, ``b`` and ``c`` values, and a ``debug`` Boolean variant, which is set
``off`` by default. Once these two variants are declared, their value
specified on module designation are instantiated in the :mfvar:`ModuleVariant`
array variable which could also be queried with the :mfcmd:`getvariant`
modulefile command. Selected variant values enable to define a specific
installation build path for the *bar/1.2* software.

If a variant is not specified when designating module and if this variant is
not declared with a default value, an error is obtained:

.. parsed-literal::

    :ps:`$` module purge
    :ps:`$` module load :noparse:`bar@1.2`
    Loading :sgrhi:`bar/1.2`
      :sgrer:`ERROR`: No value specified for variant 'toolchain'
        Allowed values are: a b c

Once module is loaded, selected variants are reported on the :subcmd:`list`
sub-command output:

.. parsed-literal::

    :ps:`$` module load :noparse:`bar@1.2` toolchain=b
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) bar/1.2\ :sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`toolchain=b`:sgrse:`}`  

    Key:
    :sgrse:`{`:sgrva:`-variant`:sgrse:`}`\=\ :sgrse:`{`:sgrva:`variant=off`:sgrse:`}`  :sgrse:`{`:sgrva:`variant=value`:sgrse:`}`

.. note:: The default value of the :instopt:`--with-list-output` installation
   option has been updated to include variant information.

Variant specification could be used where the :ref:`Advanced module version
specifiers` is supported. For instance a module may express a dependency over
a specific module variant:

.. parsed-literal::

    :ps:`$` module show foo/2.1 toolchain=c
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/2.1`:

    :sgrcm:`variant`         toolchain a b c
    :sgrcm:`prereq`          :noparse:`bar@1.2 toolchain=`:sgrva:`{toolchain}`
    :sgrcm:`prepend-path`    PATH /path/to/foo-2.1-:sgrva:`{toolchain}`/bin
    :sgrcm:`prepend-path`    LD_LIBRARY_PATH /path/to/foo-2.1-:sgrva:`{toolchain}`/lib
    -------------------------------------------------------------------

In this example, *foo/2.1* module depends on *bar/1.2* and the same toolchain
variant should be selected for both modules in order to load two software
builds that are compatible between each other.

.. parsed-literal::

    :ps:`$` module purge
    :ps:`$` module config auto_handling 1
    :ps:`$` module load foo/2.1 toolchain=a
    Loading :sgrhi:`foo/2.1`:sgrse:`{`:sgrva:`toolchain=a`:sgrse:`}`
      :sgrin:`Loading requirement`: bar/1.2\ :sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`toolchain=a`:sgrse:`}`

Variant shortcuts
^^^^^^^^^^^^^^^^^

The :mconfig:`variant_shortcut` configuration option is added to define
shortcut characters for easily specifying variants. Instead of writing the
variant name to specify it in module designation (e.g., *name=value*), the
shortcut associated to this variant could be used (i.e., *<shortcut>value*):

.. parsed-literal::

    :ps:`$` module purge
    :ps:`$` module config variant_shortcut toolchain=%
    :ps:`$` module load foo/2.1 %a
    Loading :sgrhi:`foo/2.1`:sgrse:`{`:sgrva:`%a`:sgrse:`}`
      :sgrin:`Loading requirement`: bar/1.2\ :sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`%a`:sgrse:`}`

Configured shortcuts are also used to report the loaded variant on
:subcmd:`list` sub-command output (shortcuts are explained in key section):

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgral:`bar/1.2`\ :sgrse:`{`:sgrva:`-debug`:sgrse:`:`:sgrva:`%a`:sgrse:`}`  2) foo/2.1\ :sgrse:`{`:sgrva:`%a`:sgrse:`}`  

    Key:
    :sgral:`auto-loaded`  :sgrse:`{`:sgrva:`-variant`:sgrse:`}`\=\ :sgrse:`{`:sgrva:`variant=off`:sgrse:`}`  :sgrse:`{`:sgrva:`%value`:sgrse:`}`\=\ :sgrse:`{`:sgrva:`toolchain=value`:sgrse:`}`  :sgrse:`{`:sgrva:`variant=value`:sgrse:`}`


v4.7
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.7 release notes<4.7 release notes>` for a complete
list of the changes between Modules v4.6 and v4.7.

Determining module implementation and version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

New Modules variables are introduced to determine during the evaluation of a
modulefile or a modulerc what *module* implementation is currently in use. The
:mfvar:`ModuleTool` variable corresponds to the name of the *module*
implementation and is set to ``Modules`` for this project. The
:mfvar:`ModuleToolVersion` variable corresponds to the version number of the
implementation (e.g. ``4.7.0``).

With these new variables it is possible to precisely know what *module*
command is in use then adapt modulefile code to handle a specific behavior or
leverage a new feature.

The modulefile command :mfcmd:`versioncmp` is also introduced to provide a
simple way to compare two version strings and return if first version string
is less than, equal to or greater than second one.

.. code-block:: tcl

    if {[info exists ModuleTool] && $ModuleTool eq {Modules}
        && [versioncmp $ModuleToolVersion 4.7] >= 0} {
        # here some code specific for Modules 4.7 and later versions
    }

The :mfvar:`ModuleTool` and :mfvar:`ModuleToolVersion` variables and the
:mfcmd:`versioncmp` modulefile command are supported by the `Lmod`_ project
starting version ``8.4.8``.

Symbolic version to designate module loaded version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the `Advanced module version specifiers`_ is enabled, the ``loaded``
symbolic version may be used to designate the currently loaded version of
specified module.

.. parsed-literal::

    :ps:`$` ml display :noparse:`foo@loaded`
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:
    
    :sgrcm:`module-whatis`   foo/1.0
    -------------------------------------------------------------------

If no version of specified module can be found loaded, an error is returned.

.. parsed-literal::

    :ps:`$` ml display :noparse:`foo@loaded`
    :sgrer:`ERROR`: No loaded version found for 'foo' module

Module tags
^^^^^^^^^^^

Module tags are piece of information that can be associated to individual
modulefiles. Tags could be purely informational or may lead to specific
behaviors.

Module tags may be inherited from the module state set by a modulefile command
or consequence of a module action. Tags may also be associated to modules by
using the new :mfcmd:`module-tag` modulefile command.

Module tags are reported along the module they are associated to on
:subcmd:`avail` and :subcmd:`list` sub-command results. Tags could be reported
either:

* along the module name, all tags set within angle brackets, each tag
  separated from the others with a colon character (e.g.,
  ``foo/1.2 <tag1:tag2>``).

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/.modulerc
    #%Module
    module-tag mytag foo
    module-tag othertag foo/1.0
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/1.0 <mytag:othertag>  foo/2.0 <mytag>
    :ps:`$` ml foo/1.0
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) foo/1.0 <mytag:othertag>

* graphically rendered over the module name for each tag associated to a
  Select Graphic Rendition (SGR) code in the color palette (see
  :envvar:`MODULES_COLORS`)

.. parsed-literal::

    :ps:`$` # set SGR code to report 'mytag' with blue background color
    :ps:`$` ml config colors "hi=1:di=94:L=90;47:mytag=102"
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    :sgrl:`foo`:sgrss:`/1.0` <othertag>  :sgrss:`foo/2.0`
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrl:`foo`:sgrss:`/1.0` <othertag>

The :mconfig:`tag_abbrev` configuration option is available to define
abbreviated strings for module tags and then use these abbreviations instead
of tag names when reporting tags on :subcmd:`avail` and :subcmd:`list` command
results.

.. parsed-literal::

    :ps:`$` # add abbreviation for 'othertag' tag
    :ps:`$` ml config tag_abbrev loaded=L:othertag=oT
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    :sgrl:`foo`:sgrss:`/1.0` <oT>  :sgrss:`foo/2.0`
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrl:`foo`:sgrss:`/1.0` <oT>

When a SGR code is set for a tag in the color palette, this graphical
rendition is applied by default over the module name and the tag name or its
abbreviation is not displayed. If tag name or abbreviation is added to the
:mconfig:`tag_color_name` configuration option, graphical rendering is applied
to the tag name or abbreviation rather than over the module name they are
attached to.

.. parsed-literal::

    :ps:`$` # add SGR code for 'oT' tag and set rendition over tag name
    :ps:`$` ml config colors "hi=1:di=94:L=90;47:mytag=44:oT=41"
    :ps:`$` ml config tag_color_name oT
    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    :sgrl:`foo`:sgrss:`/1.0` <:sgrf:`oT`>  :sgrss:`foo/2.0`
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrl:`foo`:sgrss:`/1.0` <:sgrf:`oT`>

Tags inherited from module state, consequence of a module action or set by
using :mfcmd:`module-tag` but that have a special meaning currently are:

.. only:: html

    +------------------+-------------------------+------------------------+-------+------------------------+
    | Tag              | Description             | Set with               | Abbr. | Color                  |
    |                  |                         |                        |       |                        |
    +==================+=========================+========================+=======+========================+
    | auto-loaded      | Module has been loaded  | Inherited              | aL    | .. parsed-literal::    |
    |                  | automatically           |                        |       |                        |
    |                  |                         |                        |       |     :sgral:`mod/1.0`   |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | forbidden        | Module cannot be loaded | Inherited from         | F     | .. parsed-literal::    |
    |                  |                         | :mfcmd:`module-forbid` |       |                        |
    |                  |                         |                        |       |     :sgrf:`mod/1.0`    |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | hidden           | Module is not visible   | Inherited from         | H     | .. parsed-literal::    |
    |                  | on :subcmd:`avail`      | :mfcmd:`module-hide`   |       |                        |
    |                  |                         |                        |       |     :sgrh:`mod/1.0`    |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | hidden-loaded    | See `Hiding loaded      | Inherited from         | H     | .. parsed-literal::    |
    |                  | modules`_               | :mfcmd:`module-hide`   |       |                        |
    |                  |                         |                        |       |     :sgrh:`mod/1.0`    |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | loaded           | Module is currently     | Inherited              | L     | .. parsed-literal::    |
    |                  | loaded                  |                        |       |                        |
    |                  |                         |                        |       |     :sgrl:`mod/1.0`    |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | nearly-forbidden | Module will soon not be | Inherited from         | nL    | .. parsed-literal::    |
    |                  | able to load anymore    | :mfcmd:`module-forbid` |       |                        |
    |                  |                         |                        |       |     :sgrnf:`mod/1.0`   |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | sticky           | See `Sticky modules`_   | :mfcmd:`module-tag`    | S     | .. parsed-literal::    |
    |                  |                         |                        |       |                        |
    |                  |                         |                        |       |     :sgrs:`mod/1.0`    |
    +------------------+-------------------------+------------------------+-------+------------------------+
    | super-sticky     | See `Sticky modules`_   | :mfcmd:`module-tag`    | sS    | .. parsed-literal::    |
    |                  |                         |                        |       |                        |
    |                  |                         |                        |       |     :sgrss:`mod/1.0`   |
    +------------------+-------------------------+------------------------+-------+------------------------+

.. only:: not html

    +------------------+-------------------------+------------------------+-------+
    | Tag              | Description             | Set with               | Abbr. |
    |                  |                         |                        |       |
    +==================+=========================+========================+=======+
    | auto-loaded      | Module has been loaded  | Inherited              | aL    |
    |                  | automatically           |                        |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | forbidden        | Module cannot be loaded | Inherited from         | F     |
    |                  |                         | :mfcmd:`module-forbid` |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | hidden           | Module is not visible   | Inherited from         | H     |
    |                  | on :subcmd:`avail`      | :mfcmd:`module-hide`   |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | hidden-loaded    | See `Hiding loaded      | Inherited from         | H     |
    |                  | modules`_               | :mfcmd:`module-hide`   |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | loaded           | Module is currently     | Inherited              | L     |
    |                  | loaded                  |                        |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | nearly-forbidden | Module will soon not be | Inherited from         | nL    |
    |                  | able to load anymore    | :mfcmd:`module-forbid` |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | sticky           | See `Sticky modules`_   | :mfcmd:`module-tag`    | S     |
    |                  |                         |                        |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+
    | super-sticky     | See `Sticky modules`_   | :mfcmd:`module-tag`    | sS    |
    |                  |                         |                        |       |
    |                  |                         |                        |       |
    +------------------+-------------------------+------------------------+-------+

Hiding loaded modules
^^^^^^^^^^^^^^^^^^^^^

The ``--hidden-loaded`` option has been added to the :mfcmd:`module-hide`
modulefile command and it indicates that designated hidden modules remain
hidden after being loaded.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.0
    #%Module
    module load bar
    :ps:`$` cat /path/to/modulefiles/bar/.modulerc
    #%Module4.7
    module-hide --soft --hidden-loaded bar

In this example, *foo* depends on *bar* which is set soft hidden and hidden
once loaded. As a consequence, automated load of *bar* module will not be
reported and *bar/1.0* will not appear in loaded module list by default:

.. parsed-literal::

    :ps:`$` ml foo
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) foo/1.0

However *bar/1.0* is loaded. Hidden loaded modules can be unveiled with the
:option:`--all`/:option:`-a` option set on the :subcmd:`list` sub-command.
``hidden-loaded`` tag (abbreviated by default to ``H`` when colored output is
disabled) applies to such modules.

.. parsed-literal::

    :ps:`$` ml -a
    Currently Loaded Modulefiles:
     1) :sgral:`bar`:sgrh:`/1.0`   2) foo/1.0

To also get the informational messages about hidden loaded module automated
load or unload, the new verbosity level ``verbose2`` can be used (with
:option:`-vv` option for instance):

.. parsed-literal::

    :ps:`$` ml purge
    :ps:`$` ml -vv foo
    Loading bar/1.0

    Loading :sgrhi:`foo/1.0`
      :sgrin:`Loading requirement`: bar/1.0

Sticky modules
^^^^^^^^^^^^^^

Module stickiness is introduced, in a similar fashion than on the `Lmod`_
project, to allow to glue modules to the loaded environment. A sticky module
cannot be unloaded, unless if the unload action is forced or if the module
reloads after being unloaded.

A modulefile is declared *sticky* by applying it the ``sticky`` tag with the
:mfcmd:`module-tag` modulefile command.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/.modulerc
    #%Module4.7
    module-tag sticky foo/1.0
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrs:`foo/1.0`
    :ps:`$` ml -foo
    Unloading :sgrhi:`foo/1.0`
      :sgrer:`ERROR`: Unload of sticky module 'foo/1.0' skipped
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrs:`foo/1.0`
    :ps:`$` ml --force -foo
    Unloading :sgrhi:`foo/1.0`
      :sgrwa:`WARNING`: Unload of sticky module 'foo/1.0' forced
    :ps:`$` ml
    No Modulefiles Currently Loaded.


Modulefile can also be defined ``super-sticky`` by applying the corresponding
module tag. *Super-sticky* module cannot be unloaded even if the unload action
is forced. It can only be unloaded if the module reloads afterward.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/.modulerc
    #%Module4.7
    module-tag super-sticky bar/1.0
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrss:`bar/1.0`
    :ps:`$` ml purge
    Unloading :sgrhi:`bar/1.0`
      :sgrer:`ERROR`: Unload of super-sticky module 'bar/1.0' skipped
    :ps:`$` ml purge -f
    Unloading :sgrhi:`bar/1.0`
      :sgrer:`ERROR`: Unload of super-sticky module 'bar/1.0' skipped
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrss:`bar/1.0`

Modulefiles targeted by a ``sticky`` or a ``super-sticky`` tag are colored on
:subcmd:`avail` and :subcmd:`list` sub-command outputs to indicate such tag
applies. If colored output is disabled a tag abbreviation is reported along
module designation (respectively ``S`` and ``sS``).

In case the stickiness applies to the generic module name (and does not target
a specific module version or version-set), one version of the sticky or
super-sticky module can be swapped by another version of this same module:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/baz/.modulerc
    #%Module4.7
    module-tag sticky baz
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrs:`baz/2.0`
    :ps:`$` ml switch baz/1.0
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrs:`baz/1.0`

Explaining avail/list output
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A *Key* section is added at the end of the :subcmd:`avail` and :subcmd:`list`
sub-commands output to give hints on the meaning of the graphical rendition
applied to elements or what the elements set in parentheses or chevrons along
module name stand for.

.. parsed-literal::

    :ps:`$` ml av
    ------------------ :sgrdi:`/path/to/modulefiles` ------------------
    :sgrs:`foo`:sgrl:`/1.0` <oT>  :sgrde:`foo/2.0`  :sgrali:`foo/3.0`

    Key:
    :sgrl:`loaded`      :sgrde:`default-version`  :sgrs:`sticky`        <oT>=othertag
    :sgrdi:`modulepath`  :sgrali:`module-alias`     <module-tag>

Configuring avail/list output
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

New configuration options are introduced to control what content to output in
addition to modules names on the regular and terse output modes of the
:subcmd:`avail` and :subcmd:`list` sub-commands.

These new configuration options named :mconfig:`avail_output`,
:mconfig:`avail_terse_output`, :mconfig:`list_output` and
:mconfig:`list_terse_output` can be updated using the :subcmd:`config`
sub-command or set at installation time respectively with the
:instopt:`--with-avail-output`, :instopt:`--with-avail-terse-output`,
:instopt:`--with-list-output` and :instopt:`--with-list-terse-output`
configure options.

The four options accept a colon separated list of elements as value. Accepted
elements for the :subcmd:`avail`-related options are: ``modulepath``,
``alias``, ``dirwsym``, ``sym``, ``tag`` and ``key``. Accepted elements for
the :subcmd:`list`-related options are: ``header``, ``idx``, ``sym``, ``tag``
and ``key``.

In the following example, default output configuration for the :subcmd:`avail`
sub-command is checked then module tags and key section are removed to get a
simpler output:

.. parsed-literal::

    :ps:`$` ml config avail_output
    Modules Release 4.7.0 (2021-02-19)

    - Config. name ---------.- Value (set by if default overridden) ---------------
    avail_output              modulepath:alias:dirwsym:sym:tag:key
    :ps:`$` ml av
    ------------------ :sgrdi:`/path/to/modulefiles` ------------------
    :sgrde:`bar/1.0`  bar/2.0  :sgrf:`foo/1.0`  :sgrs:`foo/2.0`  :sgrali:`foo/2.2`

    Key:
    :sgrdi:`modulepath`       :sgrali:`module-alias`  :sgrs:`sticky`
    :sgrde:`default-version`  :sgrf:`forbidden`
    :ps:`$` ml config avail_output modulepath:alias:dirwsym:sym
    :ps:`$` ml av
    ------------------ :sgrdi:`/path/to/modulefiles` ------------------
    :sgrde:`bar/1.0`  bar/2.0  foo/1.0  foo/2.0  :sgrali:`foo/2.2`

The :option:`--output`/:option:`-o` switches are added to define a specific
output configuration for the duration of the associated command line. The
following example shows how to limit the content reported on a module
:subcmd:`list` to the loaded index and the symbolic versions in addition to
the module names:

.. parsed-literal::

    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) :sgrde:`bar/1.0`   2) :sgrs:`foo/2.0`

    Key:
    :sgrde:`default-version`  :sgrs:`sticky`
    :ps:`$` ml -o idx:sym
     1) :sgrde:`bar/1.0`   2) foo/2.0

When the new configuration options or command line switches are set to an
empty value, the module names are the sole information reported:

.. parsed-literal::

    :ps:`$` ml -t -o ""
    bar/1.0
    foo/2.0

In case the ``modulepath`` element is withdrawn from the :subcmd:`avail`
sub-command output configuration, the available modules from all enabled
modulepaths are reported as a single list:

.. parsed-literal::

    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/other/modulefiles` ---------------
    baz/1.0  baz/2.0

    ------------------ :sgrdi:`/path/to/modulefiles` ------------------
    :sgrde:`bar/1.0`  bar/2.0  :sgrf:`foo/1.0`  :sgrs:`foo/2.0`  :sgrali:`foo/2.2`

    Key:
    :sgrdi:`modulepath`       :sgrali:`module-alias`  :sgrs:`sticky`
    :sgrde:`default-version`  :sgrf:`forbidden`
    :ps:`$` ml av --output=alias:tag
    bar/1.0  baz/1.0  :sgrf:`foo/1.0`  :sgrali:`foo/2.2`
    bar/2.0  baz/2.0  :sgrs:`foo/2.0`

.. note:: The ``avail_report_dir_sym`` and ``avail_report_mfile_sym`` locked
   configuration options have been removed. Their behaviors can now be
   obtained by respectively adding the ``dirwsym`` and ``sym`` elements to the
   :mconfig:`avail_output` or :mconfig:`avail_terse_output` configuration
   options.

v4.6
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.6 release notes<4.6 release notes>` for a complete
list of the changes between Modules v4.5 and v4.6.

.. _sh-to-mod_sub-command:

sh-to-mod sub-command
^^^^^^^^^^^^^^^^^^^^^

The :subcmd:`sh-to-mod` sub-command is added to output as a modulefile content
the environment changes done by the evaluation of a shell script passed as
argument. :subcmd:`sh-to-mod` is especially useful for software providing a
shell script for their enablement in shell session: it can convert these
scripts into modulefiles.

Say for instance, a *foo* software has been installed and it provides a
``foo-setup.sh`` script to activate *foo* software in user environment:

.. parsed-literal::

    :ps:`$` cat /path/to/foo-1.2/foo-setup.sh
    #!/bin/sh
    export FOOENV="$1"
    export PATH=/path/to/foo-1.2/bin:$PATH
    alias foo='foobin -q -l'

Calling ``module sh-to-mod`` on this shell script outputs the environment
changes it performs as a modulefile content:

.. parsed-literal::

    :ps:`$` module sh-to-mod sh /path/to/foo-1.2/foo-setup.sh arg1
    #%Module
    prepend-path    PATH /path/to/foo-1.2/bin
    set-alias       foo {foobin -q -l}
    setenv          FOOENV arg1

Changes on environment variables, shell aliases, shell functions and current
working directory are tracked. The following shells are supported: *sh*,
*dash*, *csh*, *tcsh*, *bash*, *ksh*, *ksh93*, *zsh* and *fish*.

:subcmd:`sh-to-mod` acts as a full replacement for the standalone
:command:`createmodule.sh` and :command:`createmodule.py` scripts. However
those two scripts are currently still provided for compatibility purpose.

.. _source-sh_modulefile_command:

source-sh modulefile command
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :mfcmd:`source-sh` modulefile command is introduced to source environment
changes done by the evaluation of a shell script passed as argument. With
newly introduced :subcmd:`sh-to-mod` sub-command resulting environment changes
done by script are output as modulefile commands. :mfcmd:`source-sh` applies
those modulefile commands as if they were directly written in loading
modulefile.

:mfcmd:`source-sh` is useful for software providing a shell script for their
enablement. If you want to enable such software with :command:`module` yet
using shell script provided by software for this task, just write a modulefile
using :mfcmd:`source-sh` command to call the shell script.

Keeping the same example used to describe :subcmd:`sh-to-mod` sub-command:
*foo* software provides a ``foo-setup.sh`` script for its activation. Create a
modulefile ``foo/1.2`` that calls this script:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/1.2
    #%Module4.6
    source-sh sh /path/to/foo-1.2/foo-setup.sh arg1

Displaying this modulefile indicates the environment changes done by script:

.. parsed-literal::

    :ps:`$` module display foo/1.2
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.2`:

    :sgrcm:`prepend-path`    PATH /path/to/foo-1.2/bin
    :sgrcm:`set-alias`       foo {foobin -q -l}
    :sgrcm:`setenv`          FOOENV arg1
    -------------------------------------------------------------------

Loading the modulefile applies the environment changes seen above:

.. parsed-literal::

    :ps:`$` module load -v foo/1.2
    Loading :sgrhi:`foo/1.2`
    :ps:`$` echo $FOOENV
    arg1
    :ps:`$` alias foo
    alias foo='foobin -q -l'

Track of these changes is kept in user environment to be able to undo them
when modulefile is unloaded:

.. parsed-literal::

    :ps:`$` module unload -v foo/1.2
    Unloading :sgrhi:`foo/1.2`
    :ps:`$` echo $FOOENV
    
    :ps:`$` alias foo
    bash: alias: foo: not found

Changes on environment variables, shell aliases, shell functions and current
working directory are tracked. The following shells are supported: *sh*,
*dash*, *csh*, *tcsh*, *bash*, *ksh*, *ksh93*, *zsh* and *fish*.

Querying user's name and groups membership
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Two new sub-commands are introduced for the :mfcmd:`module-info` modulefile
command: ``username`` and ``usergroups``. They respectively fetch the name of
the user currently running :file:`modulecmd.tcl` or the name of all the groups
this user is member of.

These two new modulefile commands can help to adapt code to specific users or
groups. Like for instance to instantiate a modulefile for each group the user
is member of:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/.modulerc
    #%Module4.6
    foreach grp [module-info usergroups] {
        module-virtual foo/$grp .common
    }
    :ps:`$` id -G -n
    grp1 grp2 grp3
    :ps:`$` module avail
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/grp1  foo/grp2  foo/grp3

``username`` and ``usergroups`` sub-commands of :mfcmd:`module-info`
modulefile command are only supported on Unix platform.

Hiding modules
^^^^^^^^^^^^^^

The newly introduced :mfcmd:`module-hide` modulefile command enables to
dynamically hide modulefiles, module aliases or symbolic versions specified to
it:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/.modulerc
    #%Module4.6
    module-version bar/1.0 old
    # hide 'old' symbolic version
    module-hide bar/old
    # hide all version 2 and above
    module-hide bar@2:
    :ps:`$` cat /path/to/modulefiles/.modulerc
    #%Module4.6
    # hide all versions of foo module
    module-hide foo

:mfcmd:`module-hide` commands should be placed in module rc files and can
leverage the `Advanced module version specifiers`_ syntax as shown in the
above example.

Hidden modules are excluded from available module search or module selection
unless query refers to hidden module by its exact name:

.. parsed-literal::

    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0  bar/2.0
    :ps:`$` module load -v foo
    :sgrer:`ERROR`: Unable to locate a modulefile for 'foo'
    :ps:`$` module load -v foo/1.0
    Loading foo/1.0
    :ps:`$` module avail bar/old
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0\ :sgrse:`(`:sgrsy:`old`:sgrse:`)`

:mfcmd:`module-hide` command accepts a ``--soft`` option to apply a lighter of
hiding to modules:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/qux/.modulerc
    #%Module4.6
    # softly hide all qux modules
    module-hide --soft qux

The soft hiding mode enables to hide modules from full availability listing
yet keeping the ability to select such module for load without having to use
module exact name:

.. parsed-literal::

    :ps:`$` ml av
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0  bar/2.0
    :ps:`$` ml av qux
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    qux/1.0  qux/2.0
    :ps:`$` module load -v qux
    Loading :sgrhi:`qux/2.0`

Alternatively, a ``--hard`` option can be set on :mfcmd:`module-hide` command
to ensure designated modules do not unveil even if referred by their exact
name:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/qux/.modulerc
    #%Module4.6
    # softly hide all qux modules
    module-hide --soft qux
    # set highest version of qux hard hidden
    module-hide --hard qux/3.0
    :ps:`$` ml av qux/3.0
    :ps:`$` ml qux/3.0
    :sgrer:`ERROR`: Unable to locate a modulefile for 'qux/3.0'

Some users or groups can be set unaffected by hiding mechanism with
the ``--not-user`` or ``--not-group`` options:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/quuz/.modulerc
    #%Module4.6
    # hiding does not apply to grp1 and grp2 groups
    module-hide --not-group {grp1 grp2} quuz

.. parsed-literal::

    :ps:`$` id --groups --name
    grp1 grp7
    :ps:`$` ml av quuz
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    quuz/1.0  quuz/2.0
    :ps:`$` ml -v quuz
    Loading :sgrhi:`quuz/2.0`

Hiding mechanism can also be set effective only before or after a given date
time with the ``--before`` and ``--after`` options. Accepted date time format
is ``YYYY-MM-DD[THH:MM]``.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/fum/.modulerc
    #%Module4.6
    # hide only before a given date
    module-hide --hard --before 2020-09-01T12:00 fum/1.0
    # hide only after a given date
    module-hide --hard --after 2020-09-01 fum/2.0

.. parsed-literal::

    :ps:`$` date
    Fri 04 Sep 2020 06:21:48 AM CEST
    :ps:`$` ml av fum
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    fum/1.0

Hidden modules can be included in available module searches if option
:option:`--all`/:option:`-a` is set on :subcmd:`avail`, :subcmd:`aliases`,
:subcmd:`whatis` or :subcmd:`search` sub-commands. Hard hidden modules are
unaffected by this option and stay hidden.

.. parsed-literal::

    :ps:`$` ml av -a
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    bar/1.0\ :sgrse:`(`:sgrsy:`old`:sgrse:`)`  foo/1.0  fum/1.0   quuz/2.0  qux/2.0
    bar/2.0       foo/2.0  quuz/1.0  qux/1.0

Forbidding use of modules
^^^^^^^^^^^^^^^^^^^^^^^^^

The :mfcmd:`module-forbid` modulefile command is added to dynamically forbid
the evaluation of modulefiles it specifies. When forbidden, a module cannot be
loaded and an access error is returned when an attempt is made to evaluate it.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/foo/.modulerc
    #%Module4.6
    module-forbid foo@1:
    :ps:`$` ml foo/1.0
    :sgrer:`ERROR`: Access to module 'foo/1.0' is denied
    :ps:`$` ml
    No Modulefiles Currently Loaded.

:mfcmd:`module-forbid` statements can be coupled with :mfcmd:`module-hide`
statements to hide modules in addition to forbid their use.
:mfcmd:`module-forbid` supports the ``--not-user``, ``--not-group``,
``--before`` and ``--after`` options to still allow some users or forbid
modules before or after a given date time.

An additional error message can be defined with the ``--message`` option
to guide for instance users when they try to evaluate a forbidden module:

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/bar/.modulerc
    #%Module4.6
    module-forbid --message {Software bar/1.0 is decommissioned, please now use\\
        bar/2.0} --after 2020-09-01 bar/1.0
    :ps:`$` ml bar/1.0
    :sgrer:`ERROR`: Access to module 'bar/1.0' is denied
      Software bar/1.0 is decommissioned, please now use bar/2.0

When an evaluated module will soon be forbidden, a message is returned to the
user to warn them of the near limit. An additional warning message can also be
defined here with the ``--nearly-message`` option to guide users.

.. parsed-literal::

    :ps:`$` cat /path/to/modulefiles/qux/.modulerc
    #%Module4.6
    module-forbid --nearly-message {Version 1.0 will soon expire, please now use\\
        version 2.0} --after 2020-09-15 qux/1.0
    :ps:`$` date
    Tue 08 Sep 2020 06:49:43 AM CEST
    :ps:`$` ml qux/1.0
    Loading :sgrhi:`qux/1.0`
      :sgrwa:`WARNING`: Access to module will be denied starting '2020-09-15'
        Version 1.0 will soon expire, please now use version 2.0

The range of time the *nearly forbidden* warning appears can be controlled
with the :mconfig:`nearly_forbidden_days` configuration option, whose value
equals to the number of days prior the module starts to be forbidden. This
configuration is set to ``14`` (days) by default and this value can be
controlled at :file:`configure` time with
:instopt:`--with-nearly-forbidden-days` option. When the
:mconfig:`nearly_forbidden_days` configuration is set through the
:subcmd:`config` sub-command, the :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS`
environment variable is set.

Tracing module execution
^^^^^^^^^^^^^^^^^^^^^^^^

The ``trace`` verbosity is introduced between the ``verbose`` and ``debug``
levels to report details on module searches, resolutions, selections and
evaluations. Trace mode can be enabled by setting the :mconfig:`verbosity`
config to the ``trace`` value or by using the :option:`-T`/:option:`--trace`
command-line switches.

To specifically render trace messages, the ``tr`` key is added to the color
palette with a default value of ``2`` (decreased intensity).

.. parsed-literal::

    :ps:`$` ml -T foo
    :sgrtr:`Evaluate modulerc: '/path/to/modulefiles/.modulerc'`
    :sgrtr:`Get modules: {foo} matching 'foo' in '/path/to/modulefiles'`
    :sgrtr:`Resolve: 'foo' into 'bar'`
    :sgrtr:`Get modules: {bar bar/1.0} matching 'bar' in '/path/to/modulefiles'`
    :sgrtr:`Select module: 'bar/1.0' (/path/to/modulefiles/bar/1.0) matching 'bar/1.0'`

    Loading :sgrhi:`bar/1.0`
      :sgrtr:`Evaluate modulefile: '/path/to/modulefiles/bar/1.0' as 'bar/1.0'`


v4.5
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.5 release notes<4.5 release notes>` for a complete
list of the changes between Modules v4.4 and v4.5.

ml command
^^^^^^^^^^

The ``ml`` command is added to Modules. ``ml`` is a frontend to the ``module``
command that reduces the number of characters to type to trigger module
actions.

With no argument provided ``ml`` is equivalent to ``module list``, ``ml foo``
corresponds to ``module load foo`` and ``ml -foo`` means ``module unload
foo``:

.. parsed-literal::

    :ps:`$` ml foo
    :ps:`$` ml
    Currently Loaded Modulefiles:
     1) foo/2
    :ps:`$` ml -foo
    :ps:`$` ml
    No Modulefiles Currently Loaded.

Multiple modules to either load or unload can be combined on a single command.
The unloads are first processed then the loads.

``ml`` accepts all command-line switches and sub-commands accepted by
``module`` command:

.. parsed-literal::

    :ps:`$` ml avail -t foo
    foo/1
    foo/2

This handy interface has been originally developed by the `Lmod`_ project.
Having this command line interface also supported on Modules helps to provide
a similar user experience whatever the module implementation used.

.. _Lmod: https://github.com/TACC/Lmod

JSON format output
^^^^^^^^^^^^^^^^^^

The ``-j`` and ``--json`` command line switches are added for the ``avail``,
``list``, ``savelist``, ``whatis`` and ``search`` module sub-commands. When
set, the output result of these sub-commands is rendered in `JSON`_ format:

.. parsed-literal::

    :ps:`$` module avail --json bar | python -mjson.tool
    {
        "/path/to/modulefiles": {
            "bar/2.3": {
                "name": "bar/2.3",
                "pathname": "/path/to/modulefiles/bar/2.3",
                "symbols": [
                    "default"
                ],
                "type": "modulefile"
            },
            "bar/3.4": {
                "name": "bar/3.4",
                "pathname": "/path/to/modulefiles/bar/3.4",
                "symbols": [],
                "type": "modulefile"
            }
        }
    }
    :ps:`$` ml whatis -j foo/1.2.3 | python -mjson.tool
    {
        "/path/to/modulefiles": {
            "foo/1.2.3": {
                "name": "foo/1.2.3",
                "whatis": [
                    "The foo/1.2.3 modulefile"
                ]
            }
        }
    }

.. _JSON: https://tools.ietf.org/html/rfc8259

Improved Windows support
^^^^^^^^^^^^^^^^^^^^^^^^

A new option to the ``./configure`` script named
:instopt:`--enable-windows-support` is introduced to install additional files
relative to the enablement of Modules on the Windows platform. When set, this
option installs ``module.cmd``, ``ml.cmd`` and ``envml.cmd`` scripts in
``bindir`` and initialization script ``cmd.cmd`` in ``initdir``. With these
four files the Modules installation may be used from either a Unix or a
Windows platform.

``module.cmd``, ``ml.cmd`` and ``envml.cmd`` scripts respectively provide the
``module``, ``ml`` and ``envml`` commands for Windows ``cmd`` terminal shell,
relying on ``modulecmd.tcl`` script which was already able to produce shell
code for this Windows shell. Initialization script ``cmd.cmd`` adds the
directory of ``module.cmd``, ``ml.cmd`` and ``envml.cmd`` to ``PATH``.

These Windows-specific files are relocatable: ``module.cmd``, ``ml.cmd`` and
``envml.cmd`` scripts expect to find initialization script ``cmd.cmd`` in the
``init`` directory next to them (to setup Modules-specific variables in
current environment) and ``cmd.cmd`` expects ``modulecmd.tcl`` to be found in
``libexec`` directory and the 3 commands in ``bin`` directory next to it.

Starting from this ``4.5`` release a distribution zipball is published to
install Modules on Windows. This zip archive ships an install and an uninstall
scripts (``INSTALL.bat`` and ``UNINSTALL.bat``). The zipball can be built
locally from Modules sources by running ``make dist-win``.

The :ref:`INSTALL-win` document describes how to install Modules on Windows
from the distribution zipball.

Error stack trace
^^^^^^^^^^^^^^^^^

Error messages will now embed a stack trace for unknown errors to help
localize the root cause of issues. This change applies to modulefile
evaluation:

.. parsed-literal::

    Loading :sgrhi:`foo/1.2`
      :sgrme:`Module ERROR`: add-path cannot handle path equals to separator string
            while executing
        "append-path PATH :"
            (file "/path/to/modulefiles/foo/1.2" line 24)
        Please contact <:noparse:`root@localhost`>

A stack trace is also returned when an unknown error occurs in
``modulecmd.tcl`` script, which facilitates issue report and analysis:

.. parsed-literal::

    :ps:`$` module load bar
    :sgrer:`ERROR`: invalid command name "badcommand"
          while executing
      "badcommand"
          (procedure "module" line 14)
          invoked from within
      "module load bar"
          ("eval" body line 1)
          invoked from within
      "eval $execcmdlist"
      Please report this issue at :noparse:`https://github.com/envmodules/modules/issues`

.. _Automatic default and latest syms:

Automatic default and latest symbolic versions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the implicit default mechanism and the `Advanced module version
specifiers`_ are both enabled, a ``default`` and a ``latest`` symbolic
versions are automatically defined for each module name.

This new feature gives the ability to select the highest version available for
a module, without knowing beforehand this version name:

.. parsed-literal::

    :ps:`$` module load -v :noparse:`foo@latest`
    Loading foo/1.10

The symbolic versions are automatically defined unless a symbolic version, an
alias or a regular module version already exists for these ``default`` or
``latest`` version names.


v4.4
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.4 release notes<4.4 release notes>` for a complete
list of the changes between Modules v4.3 and v4.4.

.. warning:: Modules configuration option handling has been reworked
   internally to provide a unified way for all options to get initialized,
   retrieved or set. Existing site-specific configuration script should be
   reviewed to make use of the new ``getConf``, ``setConf``, ``unsetConf``
   and ``lappendConf`` procedures to manipulate configuration options.

.. _Insensitive case:

Specify modules in a case insensitive manner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ability to match module name in a case insensitive manner has been added.
This feature can be enabled at different level with the following values set
to the ``icase`` configuration option:

* ``never``: a case sensitive match is applied in any cases
* ``search``: a case insensitive match is applied to the ``avail``, ``whatis``
  and ``paths`` sub-commands
* ``always``: a case insensitive match is applied to search contexts and also
  to the other module sub-commands and modulefile Tcl commands for the module
  specification they receive as argument.

It can help for instance to load a module without knowing the case used to
name its relative modulefile:

.. parsed-literal::

    :ps:`$` module config icase always
    :ps:`$` module load -v mysoftware
    Loading :sgrhi:`MySoftware/1.0`

Insensitive case match activation can be controlled at configure time with
the ``--with-icase`` option, which could be passed any of the above activation
levels. This option could be superseded with the ``MODULES_ICASE`` environment
variable, which could be set through the **config** sub-command with the
``icase`` option. Command-line switch **--icase** supersedes in turns any
other icase configurations. When this command-line switch is passed, ``icase``
mode equals ``always``.

Extended default
^^^^^^^^^^^^^^^^

The extended default mechanism has been introduced to help selecting a module
when only the first numbers in its version are specified. Starting portion of
the version, part separated from the rest of the version string by a ``.``
character, could be used to refer to a more precise version number.

This mechanism is activated through the new configuration option
``extended_default``. It enables to refer to a module named ``foo/1.2.3`` as
``foo/1.2`` or ``foo/1``:

.. parsed-literal::

    :ps:`$` module config extended_default 1
    :ps:`$` module load -v foo/1
    Loading :sgrhi:`foo/1.2.3`

When multiple versions match partial version specified and only one module
should be selected, the default version (whether implicitly or explicitly
defined) among matches is returned. The following example shows that
``foo/1.1.1``, the *foo* module default version, is selected when it matches
query. Elsewhere the highest version (also called the latest version or the
implicit default) among matching modules is returned:

.. parsed-literal::

    :ps:`$` module av foo
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/1.1.1\ :sgrse:`(`:sgrsy:`default`:sgrse:`)`  foo/1.2.1  foo/1.10
    foo/1.1.10          foo/1.2.3
    :ps:`$` module load -v foo/1.1
    Loading :sgrhi:`foo/1.1.1`
    :ps:`$` module purge
    :ps:`$` module load -v foo/1.2
    Loading :sgrhi:`foo/1.2.3`
    :ps:`$` module purge
    :ps:`$` module load -v foo/1
    Loading :sgrhi:`foo/1.1.1`

In case ``implicit_default`` option is disabled and no explicit default is
found among matches, an error is returned:

.. parsed-literal::

    :ps:`$` module config implicit_default 0
    :ps:`$` module load -v foo/1.2
    :sgrer:`ERROR`: No default version defined for 'foo/1.2'

When it is enabled, extended default applies everywhere a module could be
specified, which means it could be used with any module sub-command or any
modulefile Tcl command receiving a module specification as argument. It may
help for instance to declare dependencies between modules:

.. parsed-literal::

    :ps:`$` module show bar/3
    ----------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/3.4`:

    :sgrcm:`prereq`		foo/1.2
    ----------------------------------------------------------
    :ps:`$` module load --auto bar/3
    Loading :sgrhi:`bar/3.4`
      :sgrin:`Loading requirement`: foo/1.2.3

Extended default activation can be controlled at configure time with the
``--enable-extended-default`` option. This option could be superseded with the
``MODULES_EXTENDED_DEFAULT`` environment variable, which could be set through
the **config** sub-command with the ``extended_default`` option.

Advanced module version specifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ability to specify finer constraints on module version has been added to
Modules. It enables to filter the module selection to a given version list or
range by specifying after the module name a version constraint prefixed by the
``@`` character.

This new feature leverages the `version specifier syntax`_ of the `Spack`_
package manager as this syntax covers all the needs for a fine-grained
selection of module versions. It copes very well with command-line typing, by
avoiding characters having a special meaning on shells. Moreover the users of
Spack that also are users of Modules may already be familiar with this syntax.

.. _version specifier syntax: https://spack.readthedocs.io/en/latest/basic_usage.html#version-specifier
.. _Spack: https://github.com/spack/spack

The mechanism introduced here is called *advanced module version specifier*
and it can be activated through the new configuration option
``advanced_version_spec``. Constraints can be expressed to refine the
selection of module version to:

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

This new feature enables for instance to list available versions of module
``foo`` higher or equal to ``1.2``:

.. parsed-literal::

    :ps:`$` module config advanced_version_spec 1
    :ps:`$` module av foo
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/1.1.1\ :sgrse:`(`:sgrsy:`default`:sgrse:`)`  foo/1.2.1  foo/1.10
    foo/1.1.10          foo/1.2.3
    :ps:`$` module av :noparse:`foo@1.2:`
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/1.2.1  foo/1.2.3  foo/1.10

Then choose to load for instance a version higher than or equal to ``1.2`` and
less than or equal to ``1.3``. Default version is selected if it corresponds
to a version included in the range, elsewhere the highest version (also called
latest version or implicit default) is selected:

.. parsed-literal::

    :ps:`$` module load -v :noparse:`foo@1.2:1.3`
    Loading :sgrhi:`foo/1.2.3`

In case ``implicit_default`` option is disabled and no explicit default is
found among version specifier matches, an error is returned:

.. parsed-literal::

    :ps:`$` module config implicit_default 0
    :ps:`$` module load -v :noparse:`foo@1.2:1.3`
    :sgrer:`ERROR`: No default version defined for ':noparse:`foo@1.2:1.3`'

When advanced module version specifier is enabled, it applies everywhere a
module could be specified, which means it could be used with any module
sub-command or any modulefile Tcl command receiving a module specification
as argument. It may help for instance to declare smoother dependencies between
modules:

.. parsed-literal::

    :ps:`$` module show bar@:2
    ----------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/bar/2.3`:

    :sgrcm:`prereq`          :noparse:`foo@1.1.10,1.2.1`
    ----------------------------------------------------------
    :ps:`$` module load --auto bar@:2
    Loading :sgrhi:`bar/2.3`
      :sgrin:`Loading requirement`: foo/1.2.1

Advanced specification of single version or list of versions may benefit from
the activation of the `Extended default`_ mechanism (range of versions
natively handles abbreviated versions):

.. parsed-literal::

    :ps:`$` module config extended_default 1
    :ps:`$` module load -v :noparse:`foo@1.2`
    Loading :sgrhi:`foo/1.2.3`
    :ps:`$` module unload -v foo @1.2,1.5
    Unloading :sgrhi:`foo/1.2.3`

Advanced module version specifier activation can be controlled at configure
time with the ``--enable-advanced-version-spec`` option. This option could be
superseded with the ``MODULES_ADVANCED_VERSION_SPEC`` environment variable,
which could be set through the **config** sub-command with the
``advanced_version_spec`` option.


v4.3
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.3 release notes<4.3 release notes>` for a complete
list of the changes between Modules v4.2 and v4.3.

Modulepath rc file
^^^^^^^^^^^^^^^^^^

A ``.modulerc`` file found at the root of an enabled modulepath directory is
now evaluated when modulepath is walked through to locate modulefiles. This
modulepath rc file gives for instance the ability to define module alias whose
name does not correspond to any module directory in this modulepath. Thus this
kind of module alias would not be found unless if it is defined at the
modulepath global scope.

Further I/O operations optimization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Additional work has been performed to save a significant number of filesystem
I/O operations made to search and evaluate modulefiles.

When fully read, the content of a modulefile is now cached in memory to avoid
new I/O operations in case this modulefile should be read one more time during
the same module command evaluation.

Except for ``path``, ``paths``, ``list``, ``avail`` and ``aliases`` module
commands always fully read a modulefile whether its full content is needed or
just its header to verify its validity. This way modulefiles are only read
once on commands that first check modulefile validity then read again valid
files to get their full content.

Last but not least, Modules Tcl extension library is introduced to extend the
Tcl language in order to provide more optimized I/O commands to read a file or
a directory content than native Tcl commands do. This library is built and
enabled in ``modulecmd.tcl`` script with ``--enable-libtclenvmodules``
configure argument (it is enabled by default). As this library is written in
C, it must be compiled and ``--with-tcl`` or ``--with-tclinclude`` configure
arguments may be used to indicate where to find Tcl development files.

Modules Tcl extension library greatly reduces the number of filesystem I/O
operations by removing unneeded ``ioctl``, ``fcntl`` and ``lstat`` system
calls done (by Tcl ``open`` command) to read each modulefile. Directory
content read is also improved by fetching hidden and regular files in one
pass. Moreover ``.modulerc`` and ``.version`` read access is tested only if
these files are found in the directory.

Colored output
^^^^^^^^^^^^^^

The ability to graphically enhance some part of the produced output has been
added to improve readability. Among others, error, warning and info message
prefixes can be colored as well as modulepath, module alias and symbolic
version.

Color mode can be set to ``never``, ``auto`` or ``always``. When color mode is
set to ``auto``, output is colored only if the standard error output channel
is attached to a terminal.

Default color mode could be controlled at configure time with the
``--enable-color`` and the ``--disable-color`` option, which respectively
correspond to the ``auto`` and ``never`` color mode. This default mode could
be superseded with the ``CLICOLOR``, ``CLICOLOR_FORCE`` and ``MODULES_COLOR``
environment variables and the ``--color`` command-line switch.

Color to apply to each element can be controlled with the ``MODULES_COLORS``
environment variable or the ``--with-dark-background-colors`` and
``--with-light-background-colors`` configure options. These variable and
options take as value a colon-separated list in the same fashion ``LS_COLORS``
does. In this list, output item that should be highlighted is designated by
a key which is associated to a `Select Graphic Rendition (SGR) code`_.

.. _Select Graphic Rendition (SGR) code: https://en.wikipedia.org/wiki/ANSI_escape_code#Select_Graphic_Rendition_parameters

The ``MODULES_TERM_BACKGROUND`` environment variable and the
``--with-terminal-background`` configure option help Modules to determine if
the color set for dark background or the color set for light background should
be used to color output in case no specific color set is defined with the
``MODULES_COLORS`` variable.

Output items able to be colorized and their relative key are: highlighted
element (``hi``), debug information (``db``), tag separator (``se``); Error
(``er``), warning (``wa``), module error (``me``) and info (``in``) message
prefixes; Modulepath (``mp``), directory (``di``), module alias (``al``),
module symbolic version (``sy``), module ``default`` version (``de``) and
modulefile command (``cm``).

For instance the default color set for a terminal with dark background is
defined to:

.. parsed-literal::

    :noparse:`hi=1:db=2:se=2:er=91:wa=93:me=95:in=94:mp=1;94:di=94:al=96:sy=95:de=4:cm=92`

When colored output is enabled and a specific graphical rendition is defined
for module *default* version, the ``default`` symbol is omitted and instead
the defined graphical rendition is applied to the relative modulefile. When
colored output is enabled and a specific graphical rendition is defined for
module alias, the ``@`` symbol is omitted.

``CLICOLOR`` and ``CLICOLOR_FORCE`` environment variables are also honored to
define color mode. The ``never`` mode is set if ``CLICOLOR`` equals to ``0``.
If ``CLICOLOR`` is set to another value, it corresponds to the ``auto`` mode.
The ``always`` mode is set if ``CLICOLOR_FORCE`` is set to a value different
than ``0``. Color mode set with these two variables is superseded by mode set
with ``MODULES_COLOR`` environment variable.

Configure modulecmd with config sub-command
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The **config** sub-command has been added to ``module`` to help getting or
setting the **modulecmd.tcl** options. With no additional command-line
argument, this sub-command reports the current value of all existing options
with a mention to indicate if this value has been overridden from a
command-line switch or from an environment variable.

See the description of this sub-command in the :ref:`module(1)` man page for a
complete reference on existing configuration options.

Most of the options can be altered by passing the option name and a value to
the sub-command. Setting an option by this mean overrides its default value,
set at installation time in **modulecmd.tcl** script, by defining the
environment variable which supersedes this default.:

.. parsed-literal::

    :ps:`$` module config auto_handling 1
    :ps:`$` module config auto_handling
    Modules Release 4.3.0 (2019-07-26)
    
    - Config. name ---------.- Value (set by if default overridden) ---------------
    auto_handling             1 (env-var)

Setting options with ``module config`` could be done in the Modules
initialization RC file to change default value of options when ``module``
command is initialized.

When command-line switch ``--reset`` and an option name is passed to the
**config** sub-command, it restores default value for configuration option by
unsetting related environment variable.

With command-line switch ``--dump-state``, the **config** sub-command reports,
in addition to currently set options, the current state of **modulecmd.tcl**
script and Modules-related environment variables. Providing the output of the
``module config --dump-state`` command when submitting an issue to the Modules
project will help to analyze the situation.

Control module command verbosity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ability to control message verbosity has been added so ``module`` command
can be configured whether it should display more or less information.
Available verbosity levels from the least to the most verbose are:

* ``silent``: turn off error, warning and informational messages but does not
  affect module command output result.
* ``concise``: enable error and warning messages but disable informational
  messages.
* ``normal``: turn on informational messages, like a report of the additional
  module evaluations triggered by loading or unloading modules, aborted
  evaluation issues or a report of each module evaluation occurring during a
  **restore** or **source** sub-commands.
* ``verbose``: add additional informational messages, like a systematic report
  of the loading or unloading module evaluations.
* ``debug``: print debugging messages about module command execution.

Default verbosity level can be controlled at configure time with the
``--with-verbosity`` option, which could be passed any of the above level
names. This default verbosity level could be superseded with the
``MODULES_VERBOSITY`` environment variable, which could be set through the
**config** sub-command with the ``verbosity`` option. Command-line switches
**--silent**, **--verbose** and **--debug** supersede in turns any other
verbosity configuration to respectively set module command silent, verbose or
in debug mode.

Other new sub-commands, command-line switches and environment variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* The **avail** sub-command gets two new command-line switches: **--indepth**
  and **--no-indepth**. These options control whether search results should
  recursively include or not modulefiles from directories matching search
  query. Shell completion scripts have been updated to complete available
  modulefiles in the no in depth mode.

* The **MODULES_AVAIL_INDEPTH** environment variable defines if the **avail**
  sub-command should include or exclude by default the modulefiles from
  directories matching search query. Its value is superseded by the use of the
  **--indepth** and **--no-indepth** command-line switches.

* The **clear** sub-command, which was available on Modules version 3.2, has
  been reintroduced. This sub-command resets the Modules runtime information
  but does not apply further changes to the environment at all. This
  sub-command now leverages the **--force** command-line switch to skip its
  confirmation dialog.

* The **MODULES_SITECONFIG** environment variable defines an additional
  siteconfig script which is loaded if it exists after the siteconfig script
  configured at build time in ``modulecmd.tcl``. This ability is enabled by
  default and could be disabled with configure option
  ``--with-locked-configs=extra_siteconfig``.

* The **MODULES_UNLOAD_MATCH_ORDER** environment variable sets whether the
  firstly or the lastly loaded module should be selected for unload when
  multiple loaded modules match unload request. Configure option
  ``--with-unload-match-order`` defines this setting which can be superseded
  by the environment variable. By default, lastly loaded module is selected
  and it is recommended to keep this behavior when used modulefiles express
  dependencies between each other.

* The **MODULES_IMPLICIT_DEFAULT** environment variable sets whether an
  implicit default version should be defined for modules with no default
  version explicitly defined. When enabled, which is the default behavior, a
  module version is automatically selected (latest one) when the generic
  name of the module is passed. When implicit default is disabled and no
  default version is explicitly defined for a module, the name of this module
  to evaluate should be fully qualified elsewhere an error is returned.
  Configure option ``--enable-implicit-default`` defines this setting which
  can be superseded by the environment variable. This superseding mechanism
  can be disabled with configure option
  ``--with-locked-configs=implicit_default``.

* The **MODULES_SEARCH_MATCH** environment variable defines the matching style
  to perform when searching for available modules. With **starts_with** value,
  modules whose name begins by search query string are returned. When search
  match style is set to **contains**, modules returned are those whose fully
  qualified name contains search query string. Configure option
  ``--with-search-match`` defines this setting which can be superseded by the
  environment variable, which in turns can be superseded by the
  **--starts-with** and **--contains** command-line switches of **avail**
  module sub-command.

* The **MODULES_SET_SHELL_STARTUP** environment variable controls whether or
  not shell startup file should be set to ensure ``module`` command is defined
  once shell has been initialized. When enabled, the ``ENV`` and ``BASH_ENV``
  environment variables are set, when ``module`` function is defined, to the
  Modules bourne shell initialization script. Configure options
  ``--enable-set-shell-startup`` and ``--disable-set-shell-startup`` define
  this setting which can be superseded by the environment variable.

* When initializing the ``module`` command in a shell session, initialization
  configuration files stored in the defined configuration directory are taken
  into account if present instead of the configuration files stored in the
  initialization script directory. When they are stored in the configuration
  directory, these configuration files are named ``initrc`` and
  ``modulespath`` instead of respectively ``modulerc`` and ``.modulespath``.
  The location of the installation of those files can be controlled with
  configure option ``--with-initconf-in``, which accepts ``etcdir`` and
  ``initdir`` values.

* The **MODULES_WA_277** environment variable helps to define an alternative
  ``module`` alias on Tcsh shell when set to *1*. It workarounds an issue on
  Tcsh history mechanism occurring with default ``module`` command alias:
  erroneous history entries are recorded each time the ``module`` command is
  called. However the alternative definition of the module alias weakens shell
  evaluation of the code produced by modulefiles. Characters with special
  meaning for Tcsh shell (like *{* and *}*) may not be used anymore in shell
  alias definition elsewhere the evaluation of the code produced by
  modulefiles will return a syntax error.


v4.2
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.2 release notes<4.2 release notes>` for a complete
list of the changes between Modules v4.1 and v4.2.

.. _v42-conflict-constraints-consistency:

Modulefile conflict constraints consistency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With the **conflict** modulefile command, a given modulefile can list the
other modulefiles it conflicts with. To load this modulefile, the modulefiles
it conflicts with cannot be loaded.

This constraint was until now satisfied when loading the modulefile declaring
the **conflict** but it vanished as soon as this modulefile was loaded. In the
following example ``a`` modulefile declares a conflict with ``b``:

.. parsed-literal::

    :ps:`$` module load b a
    WARNING: a cannot be loaded due to a conflict.
    HINT: Might try "module unload b" first.
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) b
    :ps:`$` module purge
    :ps:`$` module load a b
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a   2) b

Consistency of the declared **conflict** is now ensured to satisfy this
constraint even after the load of the modulefile declaring it. This is
achieved by keeping track of the conflict constraints of the loaded
modulefiles in an environment variable called ``MODULES_LMCONFLICT``:

.. parsed-literal::

    :ps:`$` module load a b
    ERROR: WARNING: b cannot be loaded due to a conflict.
    HINT: Might try "module unload a" first.
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a

An environment variable is used to keep track of this conflict information to
proceed the same way than used to keep track of the loaded modulefiles with
the ``LOADEDMODULES`` environment variable.

In case a conflict constraint toward a modulefile is set by an already loaded
modulefile, loading the conflicting modulefile will lead to a load evaluation
attempt in order for this modulefile to get the chance to solve the constraint
violation. If at the end of the load evaluation, the conflict has not been
solved, modulefile load will be discarded.

.. warning:: On versions ``4.2.0`` and ``4.2.1``, a conflict constraint set by
   an already loaded modulefile forbade the load of the conflicting
   modulefile. This has been changed starting version ``4.2.2`` to better cope
   with behaviors of previous Modules version: an evaluation attempt of the
   conflicting modulefile is made to give it the opportunity to solve this
   conflict by using **module unload** modulefile command.

.. _v42-prereq-constraints-consistency:

Modulefile prereq constraints consistency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With the **prereq** modulefile command, a given modulefile can list the
other modulefiles it pre-requires. To load this modulefile, the modulefiles it
pre-requires must be loaded prior its own load.

This constraint was until now satisfied when loading the modulefile declaring
the **prereq** but, as for the declared **conflict**, it vanished as soon as
this modulefile was loaded. In the following example ``c`` modulefile declares
a prereq on ``a``:

.. parsed-literal::

    :ps:`$` module load c
    WARNING: c cannot be loaded due to missing prereq.
    HINT: the following module must be loaded first: a
    :ps:`$` module list
    No Modulefiles Currently Loaded.
    :ps:`$` module load a c
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a   2) c
    :ps:`$` module unload a
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) c

Consistency of the declared **prereq** is now ensured to satisfy this
constraint even after the load of the modulefile declaring it. This is
achieved, like for the conflict consistency, by keeping track of the prereq
constraints of the loaded modulefiles in an environment variable called
``MODULES_LMPREREQ``:

.. parsed-literal::

    :ps:`$` module load a c
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a   2) c
    :ps:`$` module unload a
    ERROR: WARNING: a cannot be unloaded due to a prereq.
    HINT: Might try "module unload c" first.
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a   2) c

.. _v42-by-passing-module-constraints:

By-passing module defined constraints
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ability to by-pass a **conflict** or a **prereq** constraint defined by
modulefiles is introduced with the ``--force`` command line switch (``-f`` for
short notation) for the **load**, **unload** and **switch** sub-commands.

With this new command line switch, a given modulefile is loaded even if it
conflicts with other loaded modulefiles or even if the modulefiles it
pre-requires are not loaded. Some example reusing the same modulefiles ``a``,
``b`` and ``c`` than above:

.. parsed-literal::

    :ps:`$` module load b
    :ps:`$` module load --force a
    WARNING: a conflicts with b
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) b   2) a
    :ps:`$` module purge
    :ps:`$` module load --force c
    WARNING: c requires a loaded
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) c

``--force`` also enables to unload a modulefile required by another loaded
modulefiles:

.. parsed-literal::

    :ps:`$` module load a c
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) a   2) c
    :ps:`$` module unload --force a
    WARNING: a is required by c
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) c

In a situation where some of the loaded modulefiles have unsatisfied
constraints corresponding to the **prereq** and **conflict** they declare, the
**save** and **reload** sub-commands do not perform and return an error.

.. _v42-automated-module-handling-mode:

Automated module handling mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

An automatic management of the dependencies between modulefiles has been added
and it is called *automated module handling mode*. This new mode consists in
additional actions triggered when loading or unloading a modulefile to satisfy
the constraints it declares.

When loading a modulefile, following actions are triggered:

* Requirement Load (ReqLo): load of the modulefiles declared as a **prereq**
  of the loading modulefile.

* Dependent Reload (DepRe): reload of the modulefiles declaring a **prereq**
  onto loaded modulefile or declaring a **prereq** onto a modulefile part of
  this reloading batch.

When unloading a modulefile, following actions are triggered:

* Dependent Unload (DepUn): unload of the modulefiles declaring a non-optional
  **prereq** onto unloaded modulefile or declaring a non-optional **prereq**
  onto a modulefile part of this unloading batch. A **prereq** modulefile is
  considered optional if the **prereq** definition order is made of multiple
  modulefiles and at least one alternative modulefile is loaded.

* Useless Requirement Unload (UReqUn): unload of the **prereq** modulefiles
  that have been automatically loaded for either the unloaded modulefile, an
  unloaded dependent modulefile or a modulefile part of this useless
  requirement unloading batch. Modulefiles are added to this unloading batch
  only if they are not required by any other loaded modulefiles.
  ``MODULES_LMNOTUASKED`` environment variable helps to keep track of these
  automatically loaded modulefiles and to distinguish them from modulefiles
  asked by user.

* Dependent Reload (DepRe): reload of the modulefiles declaring a **conflict**
  or an optional **prereq** onto either the unloaded modulefile, an unloaded
  dependent or an unloaded useless requirement or declaring a **prereq** onto
  a modulefile part of this reloading batch.

In case a loaded modulefile has some of its declared constraints unsatisfied
(pre-required modulefile not loaded or conflicting modulefile loaded for
instance), this loaded modulefile is excluded from the automatic reload
actions described above.

For the specific case of the **switch** sub-command, where a modulefile is
unloaded to then load another modulefile. Dependent modulefiles to Unload are
merged into the Dependent modulefiles to Reload that are reloaded after the
load of the switched-to modulefile.

This automated module handling mode integrates concepts (like the Dependent
Reload mechanism) of the Flavours_ extension, which was designed for Modules
compatibility version. As a whole, automated module handling mode can be seen
as a generalization and as an expansion of the Flavours_ concepts.

.. _Flavours: https://sourceforge.net/projects/flavours/

This new feature can be controlled at build time with the
``--enable-auto-handling`` configure option. This default configuration can be
superseded at run-time with the ``MODULES_AUTO_HANDLING`` environment variable
or the command line switches ``--auto`` and ``--no-auto``.

By default, automated module handling mode is disabled and will stay so until
the next major release version (5.0) where it will be enabled by default. This
new feature is currently considered experimental and the set of triggered
actions will be refined over the next feature releases.

.. _v42-consistency-module-load-unload-commands:

Consistency of module load/unload commands in modulefile
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With the **module load** modulefile command, a given modulefile can
automatically load a modulefile it pre-requires. Similarly with the **module
unload** modulefile command, a given modulefile can automatically unload a
modulefile it conflicts with.

Both commands imply additional actions on the loaded environment (loading or
unloading extra modulefiles) that should cope with the constraints defined by
the loaded environment.

Additionally **module load** and **module unload** modulefile commands express
themselves constraints on loaded environment that should stay satisfied to
ensure consistency.

To ensure the consistency of **module load** modulefile command once the
modulefile defining it has been loaded, this command is assimilated to a
**prereq** command. Thus the defined constraint is recorded in the
``MODULES_LMPREREQ`` environment variable. Same approach is used for **module
unload** modulefile command which is assimilated to a **conflict** command.
Thus the defined constraint is recorded in the ``MODULES_LMCONFLICT``
environment variable.

To ensure the consistency of the loaded environment, the additional actions of
the **module load** and **module unload** modulefile commands have been
adapted in particular situations:

* When unloading modulefile, **module load** command will unload the
  modulefile it targets only if no other loaded modulefile requires it and if
  this target has not been explicitly loaded by user.

* When unloading modulefile, **module unload** command does nothing as the
  relative conflict registered at load time ensure environment consistency and
  will forbid conflicting modulefile load.

Please note that loading and unloading results may differ than from previous
Modules version now that consistency is checked:

* Modulefile targeted by a **module load** modulefile command may not be able
  to load due to a registered conflict in the currently loaded environment.
  Which in turn will break the load of the modulefile declaring the **module
  load** command.

* Modulefile targeted by a **module unload** modulefile command may not be
  able to unload due to a registered prereq in the loaded environment. Which
  in turn will break the load of the modulefile declaring the **module
  unload** command.

* If automated module handling mode is enabled, **module load** modulefile
  command is interpreted when unloading modulefile as part of the Useless
  Requirement Unload (UReqUn) mechanism not through modulefile evaluation.
  As a consequence, an error occurring when unloading the modulefile targeted
  by the **module load** command does not break the unload of the modulefile
  declaring this command. Moreover unload of the **module load** targets is
  done in the reverse loaded order, not in the **module load** command
  definition order.

.. _v42-alias-symbolic-name-consistency:

Modulefile alias and symbolic modulefile name consistency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

With the **module-alias** and **module-version** modulefile commands,
alternative names can be given to a modulefile. When these names are used to
load for instance a modulefile, they are resolved to the modulefile they
target which is then processed for the load action.

Until now, the alias and symbolic version names were correctly resolved for
the **load** and **unload** actions and also for the querying sub-commands
(like **avail** or **whatis**). However this alternative name information
vanishes once the modulefile it resolves to is loaded. As a consequence there
was no consistency over these alternative designations. In the following
example ``f`` modulefile declares a conflict on ``e`` alias which resolves to
``d`` modulefile:

.. parsed-literal::

    :ps:`$` module load e
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) d
    :ps:`$` module info-loaded e
    :ps:`$` module load f
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) d   2) f

Consistency of the alternative names set on a modulefile with **module-alias**
and **module-version** commands is now ensured to enable modulefile commands
**prereq**, **conflict**, **is-loaded** and **module-info loaded** using these
alternative designations as argument. This consistency is achieved, like for
the conflict and prereq consistencies, by keeping track of the alternative
names of the loaded modulefiles in an environment variable called
``MODULES_LMALTNAME``:

.. parsed-literal::

    :ps:`$` module load e
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) d
    :ps:`$` module info-loaded e
    d
    :ps:`$` module load f
    WARNING: f cannot be loaded due to a conflict.
    HINT: Might try "module unload e" first.
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) d

.. _v42-variable-change-through-modulefile-evaluation:

Environment variable change through modulefile evaluation context
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

All environment variable edition commands (``setenv``, ``unsetenv``,
``append-path``, ``prepend-path`` and ``remove-path``) have been updated to:

* Reflect environment variable value change on the environment of the current
  modulefile Tcl interpreter. So using ``$env(VAR)`` will return the currently
  defined value for environment variable ``VAR``, not the one found prior
  modulefile evaluation.
* Clear environment variable content instead of unsetting it on the
  environment of the current modulefile Tcl interpreter to avoid raising
  error about accessing an undefined element in ``$env()``. Code is still
  produced to purely unset environment variable in shell environment.

Exception is made for the ``whatis`` evaluation mode: environment variables
targeted by variable edition commands are not set to the defined value in the
evaluation context during this ``whatis`` evaluation. These variables are
only initialized to an empty value if undefined. This exception is made to
save performances on this global evaluation mode.

.. _v42-versioned-magic-cookie:

Express Modules compatibility of modulefile with versioned magic cookie
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Any modulefile should start with the ``#%Module`` file signature (also called
the Modules magic cookie) and sometimes a version number may be placed right
after this string. Until now this version number corresponded to a modulefile
format version but it was never checked.

Starting with this new Modules release, this version number reflects the
minimum version of Modules required to interpret the modulefile. If the
version number is set along the magic cookie string it is now checked and the
modulefile is interpreted only if Modules version is greater or equal to this
version number. For instance, if a modulefile begins with the ``#%Module4.3``
string, it can only be evaluated by Modules version 4.3 and above. Elsewhere
the modulefile is ignored like files without the ``#%Module`` magic cookie
set.

.. _v42-module-message-report:

Improved module message report
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Module sub-commands like ``load``, ``unload`` or ``switch``, may perform
multiple load or unload modulefile evaluations in a row. Also these kind of
evaluation modes may sometimes trigger additional load or unload evaluations,
when for instance a modulefile contains a ``module load`` command.

To improve the readability of the module messages produced relatively to
a load or an unload evaluation, these messages are now stacked under a
*Loading* or an *Unloading* message block that gathers all the messages
produced for a given modulefile evaluation:

.. parsed-literal::

    :ps:`$` module load --no-auto foo
    Loading foo/1.2
      ERROR: foo/1.2 cannot be loaded due to missing prereq.
        HINT: the following module must be loaded first: bar/4.5

In addition, foreground ``load``, ``unload``, ``switch`` and ``restore``
actions (i.e., asked on the command-line) now report a summary of the
additional load and unload evaluations that were eventually triggered in
the process:

.. parsed-literal::

    :ps:`$` module load --auto foo
    Loading foo/1.2
      Loading requirement: bar/4.5

New modulefile commands
^^^^^^^^^^^^^^^^^^^^^^^

2 new modulefile Tcl commands have been introduced:

* **set-function**: define a shell function on sh-kind and fish shells.
* **unset-function**: unset a shell function on sh-kind and fish shells.


v4.1
----

This new version is backward-compatible with previous version 4 releases. It
fixes bugs but also introduces new functionalities that are described in this
section. See the :ref:`4.1 release notes<4.1 release notes>` for a complete
list of the changes between Modules v4.0 and v4.1.

.. _Virtual modules:

Virtual modules
^^^^^^^^^^^^^^^

A virtual module stands for a module name associated to a modulefile. The
modulefile is the script interpreted when loading or unloading the virtual
module which appears or can be found with its virtual name.

The **module-virtual** modulefile command is introduced to give the ability
to define these virtual modules. This new command takes a module name as
first argument and a modulefile location as second argument::

    module-virtual app/1.2.3 /path/to/virtualmod/app

With this feature it is now possible to dynamically define modulefiles
depending on the context.

Extend module command with site-specific Tcl code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``module`` command can now be extended with site-specific Tcl
code. ``modulecmd.tcl`` now looks at a **siteconfig.tcl** file in an
``etcdir`` defined at configure time (by default ``$prefix/etc``). If
it finds this Tcl script file, it is sourced within ``modulecmd.tcl`` at the
beginning of the main procedure code.

``siteconfig.tcl`` enables to supersede any global variable or procedure
definitions made in ``modulecmd.tcl`` with site-specific code. A module
sub-command can for instance be redefined to make it fit local needs
without having to touch the main ``modulecmd.tcl``.

.. _Quarantine mechanism:

Quarantine mechanism to protect module execution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To protect the module command run-time environment from side effect
coming from the current environment definition a quarantine mechanism
is introduced. This mechanism, sets within module function definition
and shell initialization script, modifies the ``modulecmd.tcl`` run-time
environment to sanitize it.

The mechanism is piloted by environment variables. First of all
``MODULES_RUN_QUARANTINE``, a space-separated list of environment variable
names. Every variable found in ``MODULES_RUN_QUARANTINE`` will be set in
quarantine during the ``modulecmd.tcl`` run-time. Their value will be set
empty or set to the value of the corresponding ``MODULES_RUNENV_<VAR>``
environment variable if defined. Once ``modulecmd.tcl`` is started it
restores quarantine variables to their original values.

``MODULES_RUN_QUARANTINE`` and ``MODULES_RUNENV_<VAR>`` environment variables
can be defined at build time by using the following configure option::

    --with-quarantine-vars='VARNAME[=VALUE] ...'

Quarantine mechanism is available for all supported shells except ``csh``
and ``tcsh``.

Pager support
^^^^^^^^^^^^^

The informational messages Modules sends on the *stderr* channel may
sometimes be quite long. This is especially the case for the avail
sub-command when hundreds of modulefiles are handled. To improve the
readability of those messages, *stderr* output can now be piped into a
paging command.

This new feature can be controlled at build time with the ``--with-pager``
and ``--with-pager-opts`` configure options. Default pager command is set
to ``less`` and its relative options are by default ``-eFKRX``. Default
configuration can be supersedes at run-time with ``MODULES_PAGER`` environment
variables or command-line switches (``--no-pager``, ``--paginate``).

.. warning:: On version ``4.1.0``, the ``PAGER`` environment variable was
   taken in consideration to supersede pager configuration at run-time. Since
   version ``4.1.1``, ``PAGER`` environment variable is ignored to avoid side
   effects coming from the system general pager configuration.

Module function to return value in scripting languages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On Tcl, Perl, Python, Ruby, CMake and R scripting shells, module function
was not returning value and until now an occurred error led to raising a
fatal exception.

To make ``module`` function more friendly to use on these scripting shells
it now returns a value. False in case of error, true if everything goes well.

As a consequence, returned value of a module sub-command can be checked. For
instance in Python::

    if module('load', 'foo'):
      # success
    else:
      # failure

New modulefile commands
^^^^^^^^^^^^^^^^^^^^^^^

4 new modulefile Tcl commands have been introduced:

* **is-saved**: returns true or false whether a collection, corresponding to
  currently set collection target, exists or not.
* **is-used**: returns true or false whether a given directory is currently
  enabled in ``MODULEPATH``.
* **is-avail**: returns true or false whether a given modulefile exists in
  currently enabled module paths.
* **module-info loaded**: returns the exact name of the modulefile currently
  loaded corresponding to the name argument.

Multiple collections, paths or modulefiles can be passed respectively to
``is-saved``, ``is-used`` and ``is-avail`` in which case true is returned if
at least one argument matches condition (acts as a OR boolean operation). No
argument may be passed to ``is-loaded``, ``is-saved`` and ``is-used``
commands to return if anything is respectively loaded, saved or used.

If no loaded modulefile matches the ``module-info loaded`` query, an empty
string is returned.

New module sub-commands
^^^^^^^^^^^^^^^^^^^^^^^

Modulefile-specific commands are sometimes wished to be used outside of a
modulefile context. Especially for the commands managing path variables
or commands querying current environment context. So the following
modulefile-specific commands have been made reachable as module sub-commands
with same arguments and properties as if called from within a modulefile:

* **append-path**
* **prepend-path**
* **remove-path**
* **is-loaded**
* **info-loaded**

The ``is-loaded`` sub-command returns a boolean value. Small Python example::

    if module('is-loaded', 'app'):
      print 'app is loaded'
    else:
      print 'app not loaded'

``info-loaded`` returns a string value and is the sub-command counterpart
of the ``module-info loaded`` modulefile command:

.. parsed-literal::

    :ps:`$` module load app/0.8
    :ps:`$` module info-loaded app
    app/0.8


v4.0
----

Major evolution occurs with this v4.0 release as the traditional *module*
command implemented in C is replaced by the native Tcl version. This full
Tcl rewrite of the Modules package was started in 2002 and has now reached
maturity to take over the binary version. This flavor change enables to
refine and push forward the *module* concept.

This document provides an outlook of what is changing when migrating from
v3.2 to v4.0 by first describing the introduced new features. Both v3.2
and v4.0 are quite similar and transition to the new major version should
be smooth. Slights differences may be noticed in a few use-cases. So the
second part of the document will help to learn about them by listing the
features that have been discontinued in this new major release or the
features where a behavior change can be noticed.

New features
^^^^^^^^^^^^

On its overall this major release brings a lot more robustness to the
*module* command with now more than 4000 non-regression tests crafted
to ensure correct operations over the time. This version 4.0 also comes
with fair amount of improved functionalities. The major new features are
described in this section.

Additional shells supported
"""""""""""""""""""""""""""

Modules v4 introduces support for **fish**, **lisp**, **tcl** and **R**
code output.

Non-zero exit code in case of error
"""""""""""""""""""""""""""""""""""

All module sub-commands will now return a non-zero exit code in case of error
whereas Modules v3.2 always returned zero exit code even if issue occurred.

Output redirect
"""""""""""""""

Traditionally the *module* command output text that should be seen by the
user on *stderr* since shell commands are output to *stdout* to change
shell's environment. Now on *sh*, *bash*, *ksh*, *zsh* and *fish* shells,
output text is redirected to *stdout* after shell command evaluation if
shell is in interactive mode.

Filtering avail output
""""""""""""""""""""""

Results obtained from the **avail** sub-command can now be filtered to only
get the default version of each module name with use of the **--default**
or **-d** command line switch. Default version is either the explicitly
set default version or the highest numerically sorted modulefile or module
alias if no default version set.

It is also possible to filter results to only get the highest numerically
sorted version of each module name with use of the **--latest** or **-L**
command line switch.

Extended support for module alias and symbolic version
""""""""""""""""""""""""""""""""""""""""""""""""""""""

Module aliases are now included in the result of the **avail**, **whatis**
and **apropos** sub-commands. They are displayed in the module path
section where they are defined or in a *global/user modulerc* section for
aliases set in user's or global ``modulerc`` file. A **@** symbol is added
in parenthesis next to their name to distinguish them from modulefiles.

Search may be performed with an alias or a symbolic version-name passed
as argument on **avail**, **whatis** and **apropos** sub-commands.

Modules v4 resolves module alias or symbolic version passed to **unload**
command to then remove the loaded modulefile pointed by the mentioned
alias or symbolic version.

A symbolic version sets on a module alias is now propagated toward the
resolution path to also apply to the relative modulefile if it still
correspond to the same module name.

Hiding modulefiles
""""""""""""""""""

Visibility of modulefiles can be adapted by use of file mode bits or file
ownership. If a modulefile should only be used by a given subset of persons,
its mode an ownership can be tailored to provide read rights to this group of
people only. In this situation, module only reports the modulefile, during an
**avail** command for instance, if this modulefile can be read by the current
user.

These hidden modulefiles are simply ignored when walking through the
modulepath content. Access issues (permission denied) occur only when trying
to access directly a hidden modulefile or when accessing a symbol or an alias
targeting a hidden modulefile.

Improved modulefiles location
"""""""""""""""""""""""""""""

When looking for an implicit default in a modulefile directory, aliases
are now taken into account in addition to modulefiles and directories to
determine the highest numerically sorted element.

Modules v4 resolves module alias or symbolic version when it points to a
modulefile located in another modulepath.

Access issues (permission denied) are now distinguished from find issues
(cannot locate) when trying to access directly a directory or a modulefile
as done on **load**, **display** or **whatis** commands. In addition,
on this kind of access not readable ``.modulerc`` or ``.version`` files are
ignored rather producing a missing magic cookie error.

Module collection
"""""""""""""""""

Modules v4 introduces support for module *collections*. Collections
describe a sequence of **module use** then **module load** commands that
are interpreted by Modules to set the user environment as described by this
sequence. When a collection is activated, with the **restore** sub-command,
modulepaths and loaded modules are unused or unloaded if they are not part
or if they are not ordered the same way as in the collection.

Collections are generated by the **save** sub-command that dumps the current
user environment state in terms of modulepaths and loaded modules. By default
collections are saved under the ``$HOME/.module`` directory. Collections
can be listed with **savelist** sub-command, displayed with **saveshow**
and removed with **saverm**.

Collections may be valid for a given target if they are suffixed. In this
case these collections can only be restored if their suffix correspond
to the current value of the ``MODULES_COLLECTION_TARGET`` environment
variable. Saving collection registers the target footprint by suffixing
the collection filename with ``.$MODULES_COLLECTION_TARGET``.

Path variable element counter
"""""""""""""""""""""""""""""

Modules 4 provides path element counting feature which increases a
reference counter each time a given path entry is added to a given
path-like environment variable. As consequence a path entry element is
removed from a path-like variable only if the related element counter is
equal to 1. If this counter is greater than 1, path element is kept in
variable and reference counter is decreased by 1.

This feature allows shared usage of particular path elements. For instance,
modulefiles can append ``/usr/local/bin`` to ``PATH``, which is not unloaded
until all the modulefiles that loaded it unload too.

Optimized I/O operations
""""""""""""""""""""""""

Substantial work has been done to reduce the number of I/O operations
done during global modulefile analysis commands like **avail** or
**whatis**. ``stat``, ``open``, ``read`` and ``close`` I/O operations have
been cut down to the minimum required when walking through the modulepath
directories to check if files are modulefiles or to resolve module aliases.

Interpretation of modulefiles and modulerc are handled by the minimum
required Tcl interpreters. Which means a configured Tcl interpreter is
reused as much as possible between each modulefile interpretation or
between each modulerc interpretation.

.. _Sourcing modulefiles:

Sourcing modulefiles
""""""""""""""""""""

Modules 4 introduces the possibility to **source** a modulefile rather
loading it. When it is sourced, a modulefile is interpreted into the shell
environment but then it is not marked loaded in shell environment which
differ from **load** sub-command.

This functionality is used in shell initialization scripts once **module**
function is defined. There the ``etc/modulerc`` modulefile is sourced to
setup the initial state of the environment, composed of *module use*
and *module load* commands.


Removed features and substantial behavior changes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Following sections provide list of Modules v3.2 features that are
discontinued on Modules v4 or features with a substantial behavior change
that should be taken in consideration when migrating to v4.

Package initialization
""""""""""""""""""""""

``MODULESBEGINENV`` environment snapshot functionality is not supported
anymore on Modules v4. Modules collection mechanism should be used instead to
**save** and **restore** sets of enabled modulepaths and loaded modulefiles.

Command line switches
"""""""""""""""""""""

Some command line switches are not supported anymore on v4.0. When still
using them, a warning message is displayed and the command is ran with these
unsupported switches ignored. Following command line switches are concerned:

* ``--force``, ``-f``
* ``--human``
* ``--verbose``, ``-v``
* ``--silent``, ``-s``
* ``--create``, ``-c``
* ``--icase``, ``-i``
* ``--userlvl`` lvl, ``-u`` lvl

Module sub-commands
"""""""""""""""""""

During an **help** sub-command, Modules v4 does not redirect output made
on stdout in *ModulesHelp* Tcl procedure to stderr. Moreover when running
**help**, version 4 interprets all the content of the modulefile, then call
the *ModulesHelp* procedure if it exists, whereas Modules 3.2 only interprets
the *ModulesHelp* procedure and not the rest of the modulefile content.

When **load** is asked on an already loaded modulefiles, Modules v4 ignores
this new load order whereas v3.2 refreshed shell alias definitions found
in this modulefile.

When **switching** on version 4 an *old* modulefile by a *new* one,
no error is raised if *old* modulefile is not currently loaded. In this
situation v3.2 threw an error and abort switch action. Additionally on
**switch** sub-command, *new* modulefile does not keep the position held
by *old* modulefile in loaded modules list on Modules v4 as it was the
case on v3.2. Same goes for path-like environment variables: replaced
path component is appended to the end or prepended to the beginning of
the relative path-like variable, not appended or prepended relatively to
the position hold by the swapped path component.

During a **switch** command, version 4 interprets the swapped-out modulefile
in *unload* mode, so the sub-modulefiles loaded, with ``module load``
order in the swapped-out modulefile are also unloaded during the switch.

Modules 4 provides path element counting feature which increases a reference
counter each time a given path entry is added to a given environment
variable. This feature also applies to the ``MODULEPATH`` environment
variable. As consequence a modulepath entry element is removed from the
modulepath enabled list only if the related element counter is equal to 1.
When **unusing** a modulepath if its reference counter is greater than 1,
modulepath is kept enabled and reference counter is decreased by 1.

On Modules 3.2 paths composing the ``MODULEPATH`` environment variable
may contain reference to environment variable. These variable references
are resolved dynamically when ``MODULEPATH`` is looked at during module
sub-command action. This feature has been discontinued on Modules v4.

Following Modules sub-commands are not supported anymore on v4.0:

* ``clear``
* ``update``


Modules specific Tcl commands
"""""""""""""""""""""""""""""

Modules v4 provides path element counting feature which increases a reference
counter each time a given path entry is added to a given environment
variable. As a consequence a path entry element is not always removed
from a path-like variable when calling to ``remove-path`` or calling to
``append-path`` or ``append-path`` at unloading time. The path element is
removed only if its related element counter is equal to 1. If this counter
is greater than 1, path element is kept in variable and reference counter
is decreased by 1.

On Modules v4, **module-info mode** returns during an **unload** sub-command
the ``unload`` value instead of ``remove`` on Modules v3.2. However if *mode*
is tested against ``remove`` value, true will be returned. During a **switch**
sub-command on Modules v4, ``unload`` then ``load`` is returned instead of
``switch1`` then ``switch2`` then ``switch3`` on Modules v3.2. However if
*mode* is tested against ``switch`` value, true will be returned.

When using **set-alias**, Modules v3.2 defines a shell function when
variables are in use in alias value on Bourne shell derivatives, Modules
4 always defines a shell alias never a shell function.

Some Modules specific Tcl commands are not supported anymore on v4.0. When
still using them, a warning message is displayed and these unsupported Tcl
commands are ignored. Following Modules specific Tcl commands are concerned:

* ``module-info flags``
* ``module-info trace``
* ``module-info tracepat``
* ``module-info user``
* ``module-log``
* ``module-trace``
* ``module-user``
* ``module-verbosity``


Further reading
^^^^^^^^^^^^^^^

To get a complete list of the differences between Modules v3.2 and v4,
please read the :ref:`changes` document.

A significant number of issues reported for v3.2 have been closed on v4.
List of these closed issues can be found at:

https://github.com/envmodules/modules/milestone/1?closed=1
