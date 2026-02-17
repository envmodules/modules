.. _module(1):

module
======


SYNOPSIS
--------

**module** [*switches*] [*sub-command* [*sub-command-args*]]

.. _module DESCRIPTION:

DESCRIPTION
-----------

:command:`module` is a user interface to the Modules package. The Modules
package provides for the dynamic modification of the user's environment
via *modulefiles*.

Each *modulefile* contains the information needed to configure the
shell for an application. Once the Modules package is initialized, the
environment can be modified on a per-module basis using the :command:`module`
command which interprets *modulefiles*. Typically *modulefiles* instruct
the :command:`module` command to alter or set shell environment variables such
as :envvar:`PATH`, :envvar:`MANPATH`, etc. *Modulefiles* may be shared by many
users on a system and users may have their own set to supplement or replace
the shared *modulefiles*.

The *modulefiles* are added to and removed from the current environment
by the user. The environment changes contained in a *modulefile* can be
summarized through the :command:`module` command as well. If no arguments are
given, a summary of the :command:`module` usage and *sub-commands* are shown.

The action for the :command:`module` command to take is described by the
*sub-command* and its associated arguments.


.. _Package Initialization:

Package Initialization
^^^^^^^^^^^^^^^^^^^^^^

The Modules package and the :command:`module` command are initialized when a
shell-specific initialization script is sourced into the shell. The script
executes the :subcmd:`autoinit` sub-command of the :file:`modulecmd.tcl`
program located in |file libexecdir| for the corresponding shell. The output
of this execution is evaluated by shell which creates the :command:`module`
command as either an alias or function and creates Modules environment
variables.

During this initialization process, if the Modules environment is found
undefined (when both :envvar:`MODULEPATH` and :envvar:`LOADEDMODULES` are
found either unset or empty), the :file:`modulespath` and :file:`initrc`
configuration files located in |file etcdir| are evaluated if present and
following this order. :file:`modulespath` file contains the list of
modulepaths to enable during initialization. In this file, the modulepaths are
separated by newline or colon characters. :file:`initrc` is a modulefile that
defines during initialization the modulepaths to enable, the modules to load
and the :command:`module` configuration to apply.

During the initialization process, if the Modules environment is found defined
a :subcmd:`module refresh<refresh>` is automatically applied to restore in the
current environment all non-persistent components set by loaded modules.

The :command:`module` alias or function executes the :file:`modulecmd.tcl`
program and has the shell evaluate the command's output. The first argument to
:file:`modulecmd.tcl` specifies the type of shell.

The initialization scripts are kept in |file initdir_shell| where
*<shell>* is the name of the sourcing shell. For example, a C Shell user
sources the |file initdir_csh| script. The sh, csh, tcsh, bash, ksh,
zsh, fish, cmd and pwsh shells are supported by :file:`modulecmd.tcl`. In
addition, python, perl, ruby, tcl, cmake, r and lisp "shells" are supported
which writes the environment changes to stdout as python, perl, ruby, tcl,
lisp, r or cmake code.

Initialization may also be performed by directly calling the
:subcmd:`autoinit` sub-command of the :file:`modulecmd.tcl` program.

A :command:`ml` alias or function may also be defined at initialization time
if enabled (see :envvar:`MODULES_ML` section). :command:`ml` is a handy
frontend leveraging all :command:`module` command capabilities with less
character typed. See :ref:`ml(1)` for detailed information.

A :command:`mogui` alias or function may also be defined at initialization
time if :command:`mogui-cmd` command is found in :envvar:`PATH`.
:command:`mogui` is the Graphical User Interface for Modules. Environment
changes performed in the GUI is applied onto the shell session that executed
:command:`mogui`.

.. only:: html or latex

   .. versionchanged:: 5.5
      Definition of :command:`mogui` alias or function added


Examples of initialization
^^^^^^^^^^^^^^^^^^^^^^^^^^

C Shell initialization (and derivatives):

.. parsed-literal::

     source \ |initdir|\ /csh
     module load modulefile modulefile ...

Bourne Shell (sh) (and derivatives):

.. parsed-literal::

     . \ |initdir|\ /sh
     module load modulefile modulefile ...

PowerShell (pwsh):

.. parsed-literal::

     . \ |initdir|\ /pwsh.ps1
     envmodule load modulefile modulefile ...

Perl:

.. parsed-literal::

     require "\ |initdir|\ /perl.pm";
     &module('load', 'modulefile', 'modulefile', '...');

Python:

.. parsed-literal::

     import os
     exec(open("\ |initdir|\ /python.py").read(), globals())
     module("load", "modulefile", "modulefile", "...")

Ruby:

.. parsed-literal::

     require '\ |initdir|\ /ruby.rb'
     ENVModule.module('load', 'modulefile', 'modulefile', '...')

Bourne Shell (sh) (and derivatives) with :subcmd:`autoinit` sub-command:

.. parsed-literal::

     eval "$(\ |libexecdir|\ /modulecmd.tcl sh autoinit)"


.. _Modulecmd startup:

Modulecmd startup
^^^^^^^^^^^^^^^^^

Upon invocation :file:`modulecmd.tcl` sources a site-specific configuration
script if it exists. Siteconfig script is a Tcl script located at
|file etcdir_siteconfig|. It enables to supersede any global variable or
procedure definition of :file:`modulecmd.tcl`. See :ref:`Site-specific
configuration` for detailed information.

Afterward, :file:`modulecmd.tcl` sources rc files which contain global,
user and *modulefile* specific setups. These files are interpreted as
*modulefiles*. See :ref:`modulefile(5)` for detailed information.

Upon invocation of :file:`modulecmd.tcl` module run-command files are sourced
in the following order:

1. Global RC file(s) as specified by :envvar:`MODULERCFILE` variable or
   |file etcdir_rc|. If a path element in :envvar:`MODULERCFILE` points to a
   directory, the :file:`modulerc` file in this directory is used as a global
   RC file.

2. User specific module RC file :file:`$HOME/.modulerc`

3. All :file:`.modulerc` and :file:`.version` files found during modulefile
   seeking.

These module run-command files must begins like *modulefiles* with the
``#%Module`` file signature, also called the Modules magic cookie. A version
number may be placed after this string. The version number reflects the
minimum version of :file:`modulecmd.tcl` required to interpret the run-command
file. If a version number doesn't exist, then :file:`modulecmd.tcl` will
assume the run-command file is compatible. Files without the magic cookie or
with a version number greater than the current version of
:file:`modulecmd.tcl` will not be interpreted and an error is reported. Such
error does not abort the whole :command:`module` evaluation. If the
:mconfig:`mcookie_version_check` configuration is disabled the version number
set is not checked.

.. note:: Run-command files are intended to set parameters for modulefiles,
   not to configure the :command:`module` command itself.

.. _Command line switches:

Command line switches
^^^^^^^^^^^^^^^^^^^^^

The :command:`module` command accepts command line switches as its first
parameter. These may be used to control output format of all information
displayed and the :command:`module` behavior in case of locating and
interpreting *modulefiles*.

All switches may be entered either in short or long notation. The following
switches are accepted:

.. option:: --all, -a

 Include hidden modules in search performed with :subcmd:`avail`,
 :subcmd:`aliases`, :subcmd:`list`, :subcmd:`lint`, :subcmd:`savelist`,
 :subcmd:`search`, :subcmd:`spider` or :subcmd:`whatis` sub-commands.
 Hard-hidden modules are not affected by this option.

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 4.7
       Support for :subcmd:`list` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`lint` and :subcmd:`savelist` sub-commands added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --auto

 Enable automated module handling mode on sub-commands that load or unload
 modulefiles. See also :envvar:`MODULES_AUTO_HANDLING` section.

 .. only:: html or latex

    .. versionadded:: 4.2

.. option:: --color=<WHEN>

 Colorize the output. *WHEN* defaults to ``always`` or can be ``never`` or
 ``auto``. See also :envvar:`MODULES_COLOR` section.

 .. only:: html or latex

    .. versionadded:: 4.3

.. option:: --contains, -C

 On :subcmd:`avail`, :subcmd:`list`, :subcmd:`savelist` and :subcmd:`spider`
 sub-commands, return modules or collections whose fully qualified name
 contains search query string.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.1
       Support for :subcmd:`list` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`savelist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --debug, -D, -DD

 Debug mode. Causes :command:`module` to print debugging messages about its
 progress. Multiple :option:`-D` options increase the debug verbosity. The
 maximum is 2.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 4.6
       Option form :option:`-DD` added

.. option:: --default, -d

 On :subcmd:`avail` and :subcmd:`spider` sub-commands, display only the
 default version of each module name. Default version is the explicitly set
 default version or also the implicit default version if the configuration
 option :mconfig:`implicit_default` is enabled (see :ref:`Locating
 Modulefiles` section in the :ref:`modulefile(5)` man page for further details
 on implicit default version).

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --dumpname

 Report the name of the current implementation of the :command:`module`
 command. This option returns ``Modules`` for this implementation. The command
 then terminates without further processing.

 .. only:: html or latex

    .. versionadded:: 5.6

.. option:: --force, -f

 On :subcmd:`load`, :subcmd:`unload`, :subcmd:`switch`, :subcmd:`load-any`,
 :subcmd:`try-load`, :subcmd:`mod-to-sh` and :subcmd:`source` sub-commands
 by-pass any unsatisfied modulefile constraint corresponding to the declared
 :mfcmd:`prereq`, :ref:`via requirement<MODULES_REQUIRE_VIA>` and
 :mfcmd:`conflict`. Which means for instance that a *modulefile* will be
 loaded even if it comes in conflict with another loaded *modulefile* or that
 a *modulefile* will be unloaded even if it is a requirement of another
 *modulefile*.

 On :subcmd:`load`, :command:`ml`, :subcmd:`mod-to-sh`, :subcmd:`purge`,
 :subcmd:`reload`, :subcmd:`switch`, :subcmd:`try-load` and :subcmd:`unload`
 sub-commands applies *continue on error* behavior when an error occurs even
 if :mconfig:`abort_on_error` option is enabled.

 On :command:`ml`, :subcmd:`purge`, :subcmd:`reload`, :subcmd:`reset`,
 :subcmd:`restore`, :subcmd:`stash`, :subcmd:`stashpop`, :subcmd:`switch` and
 :subcmd:`unload` sub-commands, unloads modulefile anyway even if an
 evaluation error occurs.

 On :subcmd:`clear` sub-command, skip the confirmation dialog and proceed.

 On :subcmd:`purge` sub-command also unload `sticky modules`_ and modulefiles
 that are depended by non-unloadable modules.

 .. only:: html or latex

    .. versionadded:: 4.3
       :option:`--force`/:option:`-f` support was dropped on version `4.0`
       but reintroduced starting version `4.2` with a different meaning:
       instead of enabling an active dependency resolution mechanism
       :option:`--force` command line switch now enables to by-pass dependency
       consistency when loading or unloading a *modulefile*.

    .. versionchanged:: 4.7
       Support for :subcmd:`purge` sub-command added

    .. versionchanged:: 4.8
       Support for :subcmd:`try-load` sub-command added

    .. versionchanged:: 5.1
       Support for :subcmd:`load-any` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`mod-to-sh` sub-command added

    .. versionchanged:: 5.4
       Unloads modulefile anyway even if an evaluation error occurs

    .. versionchanged:: 5.4
       Disables :mconfig:`abort_on_error` configuration option

.. option:: --help, -h

 Give some helpful usage information, and terminates the command.

.. option:: --icase, -i

 Match module specification arguments in a case insensitive manner.

 .. only:: html or latex

    .. versionadded:: 4.4
       :option:`--icase`/:option:`-i` support was dropped on version `4.0`
       but reintroduced starting version `4.4`. When set, it now applies to
       search query string and module specification on all sub-commands and
       modulefile Tcl commands.

.. option:: --ignore-cache

 Ignore module cache.

 .. only:: html or latex

    .. versionadded:: 5.3

.. option:: --ignore-user-rc

 Skip evaluation of user-specific module rc file (:file:`$HOME/.modulerc`).

 .. only:: html or latex

    .. versionadded:: 5.3

.. option:: --indepth

 On :subcmd:`avail` and :subcmd:`spider` sub-commands, include in search
 results the matching modulefiles and directories and recursively the
 modulefiles and directories contained in these matching directories.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --json, -j

 Display :subcmd:`avail`, :subcmd:`list`, :subcmd:`savelist`,
 :subcmd:`search`, :subcmd:`spider`, :subcmd:`stashlist` and :subcmd:`whatis`
 output in JSON format.

 .. only:: html or latex

    .. versionadded:: 4.5

    .. versionchanged:: 5.2
       Support for :subcmd:`stashlist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added


.. option:: --latest, -L

 On :subcmd:`avail` and :subcmd:`spider` sub-commands, display only the
 highest numerically sorted version of each module name (see :ref:`Locating
 Modulefiles` section in the :ref:`modulefile(5)` man page).

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --long, -l

 Display :subcmd:`avail`, :subcmd:`list`, :subcmd:`savelist`, :subcmd:`spider`
 and :subcmd:`stashlist` output in long format.

 .. only:: html or latex

    .. versionchanged:: 4.0
       Support for :subcmd:`savelist` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`stashlist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --no-auto

 Disable automated module handling mode on sub-commands that load or unload
 modulefiles. See also :envvar:`MODULES_AUTO_HANDLING` section.

 .. only:: html or latex

    .. versionadded:: 4.2

.. option:: --no-indepth

 On :subcmd:`avail` and :subcmd:`spider` sub-commands, limit search results to
 the matching modulefiles and directories found at the depth level expressed
 by the search query. Thus modulefiles contained in directories part of the
 result are excluded.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --no-pager, -P

 Do not pipe message output into a pager. See also :envvar:`MODULES_PAGINATE`
 section.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.7
       Short form option :option:`-P` added

.. option:: --no-redirect

 Do not send message output to stdout. Keep it on stderr.

 .. only:: html or latex

    .. versionadded:: 5.1

.. _--output:

.. option:: --output=LIST, -o LIST

 Define the content to report in addition to module names. This option is
 supported by :subcmd:`avail`, :subcmd:`list` and :subcmd:`spider`
 sub-commands on their regular or terse output modes. Accepted values are a
 *LIST* of elements to report separated by colon character (``:``). The order
 of the elements in *LIST* does not matter.

 Accepted elements in *LIST* for :subcmd:`avail` and :subcmd:`spider`
 sub-command are: *modulepath*, *alias*, *provided-alias*, *dirwsym*,
 *indesym*, *sym*, *tag*, *key*, *hidden*, *variant*, *variantifspec* and
 *via*. *via* element is not accepted on terse output mode.

 Accepted elements in *LIST* for :subcmd:`list` sub-command are: *header*,
 *idx*, *variant*, *alias*, *indesym*, *sym*, *tag*, *hidden* and *key*.

 The order of the elements in *LIST* does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 *LIST* may be prefixed by ``+`` or ``-`` character to indicate respectively
 to append it to or subtract it from current configuration option value.

 See also :envvar:`MODULES_AVAIL_OUTPUT`, :envvar:`MODULES_LIST_OUTPUT` and
 :envvar:`MODULES_SPIDER_OUTPUT`.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 4.8
       Element *variant* added for :subcmd:`list` sub-command

    .. versionchanged:: 5.3
       Elements *variant* and *variantifspec* added for :subcmd:`avail`
       sub-command

    .. versionchanged:: 5.3
       Prefixes ``+`` and ``-`` added to append and subtract elements

    .. versionchanged:: 5.3.1
       Element *indesym* added for :subcmd:`avail` sub-command

    .. versionchanged:: 5.4
       Elements *alias* and *indesym* added for :subcmd:`list` sub-command

    .. versionchanged:: 5.6
       Sub-command :subcmd:`spider` supported

    .. versionchanged:: 5.6
       Element *hidden* added for :subcmd:`avail`, :subcmd:`list` and
       :subcmd:`spider` sub-commands

    .. versionchanged:: 5.6
       Elements *provided-alias* and *via* added for :subcmd:`avail` and
       :subcmd:`spider` sub-commands

.. option:: --paginate, -p

 Pipe all message output into :command:`less` (or if set, to the command
 referred in :envvar:`MODULES_PAGER` variable) if error output stream is a
 terminal. See also :envvar:`MODULES_PAGINATE` section.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.7
       Short form option :option:`-p` added

.. option:: --redirect

 Send message output to stdout instead of stderr. Only supported on sh, bash,
 ksh, zsh and fish shells.

 .. only:: html or latex

    .. versionadded:: 5.1

.. option:: --silent, -s

 Turn off error, warning and informational messages. :command:`module` command
 output result is not affected by silent mode.

 .. only:: html or latex

    .. versionadded:: 4.3
       :option:`--silent`/:option:`-s` support was dropped on version `4.0`
       but reintroduced starting version `4.3`.

.. option:: --starts-with, -S

 On :subcmd:`avail`, :subcmd:`list`, :subcmd:`savelist` and :subcmd:`spider`
 sub-commands, return modules or collections whose name starts with search
 query string.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.1
       Support for :subcmd:`list` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`savelist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --tag=LIST

 On :subcmd:`load`, :subcmd:`load-any`, :subcmd:`switch` and
 :subcmd:`try-load` sub-commands, apply LIST of module tags to the loading
 *modulefile*. *LIST* corresponds to the concatenation of multiple tags
 separated by colon character (``:``). *LIST* should not contain tags
 inherited from *modulefile* state or from other modulefile commands. If
 module is already loaded, tags from *LIST* are added to the list of tags
 already applied to this module.

 .. only:: html or latex

    .. versionadded:: 5.1

.. option:: --terse, -t

 Display :subcmd:`avail`, :subcmd:`list`, :subcmd:`savelist`, :subcmd:`spider`
 and :subcmd:`stashlist` output in short format.

 .. only:: html or latex

    .. versionchanged:: 4.0
       Support for :subcmd:`savelist` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`stashlist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. option:: --timer

 Prints at the end of the output an evaluation of the total execution time of
 the :command:`module` command. When mixed with a single or multiple
 :option:`--debug` options, replaces regular debug messages by reports of the
 execution time of every internal procedure calls.

 .. only:: html or latex

    .. versionadded:: 5.2

.. option:: --trace, -T

 Trace mode. Report details on module searches, resolutions, selections and
 evaluations in addition to printing verbose messages.

 .. only:: html or latex

    .. versionadded:: 4.6

.. option:: --verbose, -v, -vv

 Enable verbose messages during :command:`module` command execution. Multiple
 :option:`-v` options increase the verbosity level. The maximum is 2.

 .. only:: html or latex

    .. versionadded:: 4.3
       :option:`--verbose`/:option:`-v` support was dropped on version `4.0`
       but reintroduced starting version `4.3`.

    .. versionchanged:: 4.7
       Option form :option:`-vv` added

.. option:: --version, -V

 Lists the current version of the :command:`module` command. The command then
 terminates without further processing.

.. option:: --width=COLS, -w COLS

 Set the width of the output to *COLS* columns. See also
 :envvar:`MODULES_TERM_WIDTH` section.

 .. only:: html or latex

    .. versionadded:: 4.7


.. _Module Sub-Commands:

Module Sub-Commands
^^^^^^^^^^^^^^^^^^^

.. subcmd:: add [options] modulefile...

 See :subcmd:`load`.

.. subcmd:: add-any [options] modulefile...

 See :subcmd:`load-any`.

 .. only:: html or latex

    .. versionadded:: 5.1

.. subcmd:: aliases [-a]

 List all available symbolic version-names and aliases in the current
 :envvar:`MODULEPATH`. All directories in the :envvar:`MODULEPATH` are
 recursively searched in the same manner than for the :subcmd:`avail`
 sub-command. Only the symbolic version-names and aliases found in the search
 are displayed.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 4.6
       Option :option:`--all`/:option:`-a` added

.. subcmd:: append-path [options] variable value...

 Append *value* to environment *variable*. The *variable* is a colon, or
 *delimiter*, separated list. See :mfcmd:`append-path` in the
 :ref:`modulefile(5)` man page for *options* description and further
 explanation.

 When :subcmd:`append-path` is called as a module sub-command, the reference
 counter variable, which denotes the number of times *value* has been added to
 environment *variable*, is not updated unless if the ``--duplicates`` option
 is set.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       Reference counter environment variable is not updated anymore unless if
       the ``--duplicates`` option is set

.. subcmd:: apropos [-a] [-j] string

 See :subcmd:`search`.

.. subcmd:: avail [-d|-L] [-t|-l|-j] [-a] [-o LIST] [-S|-C] [--indepth|--no-indepth] [pattern...]

 List all available *modulefiles* in the current :envvar:`MODULEPATH`. All
 directories in the :envvar:`MODULEPATH` are recursively searched for files
 containing the Modules magic cookie. If a *pattern* argument is given, then
 each directory in the :envvar:`MODULEPATH` is searched for *modulefiles*
 whose pathname, symbolic version-name or alias match *pattern* in a case
 insensitive manner by default. *pattern* may contain wildcard characters.
 Multiple versions of an application can be supported by creating a
 subdirectory for the application containing *modulefiles* for each version.

 Symbolic version-names and aliases found in the search are displayed in the
 result of this sub-command. Symbolic version-names are displayed next to
 the *modulefile* they are assigned to within parenthesis. Aliases are listed
 in the :envvar:`MODULEPATH` section where they have been defined. To
 distinguish aliases from *modulefiles* a ``@`` symbol is added within
 parenthesis next to their name. Aliases defined through a global or user
 specific module RC file are listed under the **global/user modulerc**
 section.

 When colored output is enabled and a specific graphical rendition is defined
 for module *default* version, the ``default`` symbol is omitted and instead
 the defined graphical rendition is applied to the relative modulefile. When
 colored output is enabled and a specific graphical rendition is defined for
 module alias, the ``@`` symbol is omitted. The defined graphical rendition
 applies to the module alias name. See :envvar:`MODULES_COLOR` and
 :envvar:`MODULES_COLORS` sections for details on colored output.

 Module tags applying to the available *modulefiles* returned by the
 :subcmd:`avail` sub-command are reported along the module name they are
 associated to (see `Module tags`_ section).

 Module variants and their available values may be reported along the module
 name they belong to (see `Module variants`_ section) if defined in avail
 output configuration option (see :option:`--output`/:option:`-o` option). The
 :ref:`extra match search` process is triggered to collect variant
 information.

 A *Key* section is added at the end of the output in case some elements are
 reported in parentheses or chevrons along module name or if some graphical
 rendition is made over some output elements. This *Key* section gives hints
 on the meaning of such elements.

 The parameter *pattern* may also refer to a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If *pattern* contains variant specification or :ref:`extra specifier`, the
 :ref:`extra match search` process is triggered to collect command information
 used in modulefiles. Modules are included in results only if they match
 *pattern* variant specification and extra specifier. *pattern* may be a bare
 variant specification or extra specifier without mention of a module name.

 When several *patterns* are provided all modulefiles matching at least one of
 these *patterns* are listed.

 .. only:: html or latex

    .. versionchanged:: 4.0
       Options :option:`--default`/:option:`-d`,
       :option:`--latest`/:option:`-L` added

    .. versionchanged:: 4.3
       Options :option:`--starts-with`/:option:`-S`,
       :option:`--contains`/:option:`-C`, :option:`--indepth`,
       :option:`--no-indepth` added

    .. versionchanged:: 4.5
       Option :option:`--json`/:option:`-j` added

    .. versionchanged:: 4.6
       Option :option:`--all`/:option:`-a` added

    .. versionchanged:: 4.7
       *Key* section added at end of output

    .. versionchanged:: 4.7
       Option :option:`--output`/:option:`-o` added, compatible with regular
       and terse output modes

    .. versionchanged:: 5.3
       Module variants may be reported if defined in avail output
       configuration

    .. versionchanged:: 5.3
       *pattern* may include variant specification or extra specifier to
       filter results

    .. versionchanged:: 5.6
       Results from a multi *pattern* search are consolidated under a single
       output

.. subcmd:: cachebuild [modulepath...]

 Build module cache file for designated modulepaths. If no argument is
 provided cache file is built for every modulepath currently enabled. Cache
 file creation is skipped for modulepaths where user cannot write in.

 The name and content of every readable modulefiles and rc files are recorded
 into cache file. Also last modification time of modulefiles and invalid
 modulefile error messages are recorded. With all these information, the sole
 cache file is evaluated to know what is available within modulepath.

 See :ref:`Module cache` section for more details on module cache mechanism.

 .. only:: html or latex

    .. versionadded:: 5.3

.. subcmd:: cacheclear

 Delete module cache file in every modulepath currently enabled. If user
 cannot write in a modulepath directory, cache file deletion is skipped for
 this modulepath.

 See :ref:`Module cache` section for more details on module cache mechanism.

 .. only:: html or latex

    .. versionadded:: 5.3

.. subcmd:: clear [-f]

 Force the Modules package to believe that no modules are currently loaded. A
 confirmation is requested if command-line switch :option:`-f` (or
 :option:`--force`) is not passed. Typed confirmation should equal to ``yes``
 or ``y`` in order to proceed.

 .. only:: html or latex

    .. versionadded:: 4.3
       :subcmd:`clear` support was dropped on version `4.0` but reintroduced
       starting version `4.3`.

.. subcmd:: config [--dump-state|name [value]|--reset name]

 Gets or sets :file:`modulecmd.tcl` options. Reports the currently set value
 of passed option *name* or all existing options if no *name* passed. If a
 *name* and a *value* are provided, the value of option *name* is set to
 *value*. If command-line switch ``--reset`` is passed in addition to a
 *name*, overridden value for option *name* is cleared.

 When a reported option value differs from default value a mention is added
 to indicate whether the overridden value is coming from a command-line switch
 (``cmd-line``) or from an environment variable (``env-var``). When a reported
 option value is locked and cannot be altered a (``locked``) mention is added.

 If no value is currently set for an option *name*, the mention ``<undef>`` is
 reported.

 For options whose value is a colon-separated list, *value* may be prefixed by
 ``+`` or ``-`` character. It indicates respectively to append it to or
 subtract it from current option value.

 When command-line switch ``--dump-state`` is passed, current
 :file:`modulecmd.tcl` state and Modules-related environment variables are
 reported in addition to currently set :file:`modulecmd.tcl` options.

 Existing option *names* are:

 .. mconfig:: abort_on_error

  List of module sub-commands that abort evaluation sequence when an error is
  raised by an evaluated module. Evaluations already performed are withdrawn
  and remaining modules to evaluate are skipped.

  This configuration option can be changed at installation time with
  :instopt:`--with-abort-on-error` option. The
  :envvar:`MODULES_ABORT_ON_ERROR` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_ABORT_ON_ERROR` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.4

 .. mconfig:: advanced_version_spec

  Advanced module version specification to finely select modulefiles.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-advanced-version-spec<--enable-advanced-version-spec>`
  option. The :envvar:`MODULES_ADVANCED_VERSION_SPEC` environment variable is
  defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. See :envvar:`MODULES_ADVANCED_VERSION_SPEC`
  description for details.

  .. only:: html or latex

     .. versionadded:: 4.4

 .. mconfig:: auto_handling

  Automated module handling mode.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-auto-handling<--enable-auto-handling>` option. The
  :envvar:`MODULES_AUTO_HANDLING` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--auto` and :option:`--no-auto`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_AUTO_HANDLING` description for details.

 .. mconfig:: avail_indepth

  :subcmd:`avail` sub-command in depth search mode.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-avail-indepth<--enable-avail-indepth>` option. The
  :envvar:`MODULES_AVAIL_INDEPTH` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--indepth` and :option:`--no-indepth`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_AVAIL_INDEPTH` description for details.

 .. mconfig:: avail_output

  Content to report in addition to module names on :subcmd:`avail` sub-command
  regular output mode.

  Default value is ``modulepath:alias:dirwsym:sym:tag:variantifspec:key``. It
  can be changed at installation time with :instopt:`--with-avail-output`
  option. The :envvar:`MODULES_AVAIL_OUTPUT` environment variable is defined
  by :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--output`/:option:`-o` command line switches
  change the value of this configuration option. See
  :envvar:`MODULES_AVAIL_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: avail_terse_output

  Content to report in addition to module names on :subcmd:`avail` sub-command
  terse output mode.

  Default value is ``modulepath:alias:dirwsym:sym:tag:variantifspec``. It can
  be changed at installation time with :instopt:`--with-avail-terse-output`
  option. The :envvar:`MODULES_AVAIL_TERSE_OUTPUT` environment variable is
  defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. The :option:`--output`/:option:`-o` command
  line switches change the value of this configuration option. See
  :envvar:`MODULES_AVAIL_TERSE_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: cache_buffer_bytes

  Size of the buffer used when reading or writing cache files.

  Default value is ``32768``. Values between 4096 and 1000000 are accepted.
  The :envvar:`MODULES_CACHE_BUFFER_BYTES` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value.

  .. only:: html or latex

     .. versionadded:: 5.3

 .. mconfig:: cache_expiry_secs

  Number of seconds a cache file is considered valid after being generated.

  Default value is ``0``. Values between 0 and 31536000 are accepted.
  The :envvar:`MODULES_CACHE_EXPIRY_SECS` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value.

  .. only:: html or latex

     .. versionadded:: 5.3

 .. mconfig:: collection_pin_version

  Register exact modulefile version in collection.

  Default value is ``0``. The :envvar:`MODULES_COLLECTION_PIN_VERSION`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_COLLECTION_PIN_VERSION` description for details.

 .. mconfig:: collection_pin_tag

  Register full tag list applying to modulefiles in collection.

  Default value is ``0``. The :envvar:`MODULES_COLLECTION_PIN_TAG`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_COLLECTION_PIN_TAG` description for details.

  .. only:: html or latex

     .. versionadded:: 5.1

 .. mconfig:: collection_target

  Collection target which is valid for current system.

  This configuration option is unset by default. The
  :envvar:`MODULES_COLLECTION_TARGET` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_COLLECTION_TARGET` description for
  details.

 .. mconfig:: color

  Colored output mode.

  Default value is ``auto``. It can be changed at installation time with
  :instopt:`--disable-color<--enable-color>` option. The
  :envvar:`MODULES_COLOR` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--color` command line switches changes the
  value of this configuration option. See :envvar:`MODULES_COLOR` description
  for details.

 .. mconfig:: colors

  Chosen colors to highlight output items.

  Default value is ``hi=1:db=2:tr=2:se=2:er=91:wa=93:me=95:in=94:mp=1;94:di=94:al=96:va=93:sy=95:de=4:cm=92:aL=100:L=90;47:H=2:F=41:nF=31;43:S=46:sS=44:kL=30;48;5;109:W=30;43``.
  It can be changed at installation time with
  :instopt:`--with-dark-background-colors` or
  :instopt:`--with-light-background-colors` options in conjunction with
  :instopt:`--with-terminal-background`. The :envvar:`MODULES_COLORS`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_COLORS` description for details.

 .. mconfig:: conflict_unload

  Automated unload of conflicting modules when loading a module. This
  mechanism is part of the :ref:`automated module handling
  mode<MODULES_AUTO_HANDLING>` and also requires enablement of
  :mconfig:`auto_handling` configuration option.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-conflict-unload` option. The
  :envvar:`MODULES_CONFLICT_UNLOAD` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_CONFLICT_UNLOAD` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.5

 .. mconfig:: contact

  Modulefile contact address.

  Default value is ``root@localhost``. The :envvar:`MODULECONTACT` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. See :envvar:`MODULECONTACT`
  description for details.

 .. mconfig:: extended_default

  Allow partial module version specification.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-extended-default<--enable-extended-default>` option. The
  :envvar:`MODULES_EXTENDED_DEFAULT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_EXTENDED_DEFAULT` description for
  details.

  .. only:: html or latex

     .. versionadded:: 4.4

 .. mconfig:: editor

  Text editor command to open modulefile with through :subcmd:`edit`
  sub-command.

  Default value is ``vi``. It can be changed at installation time with
  :instopt:`--with-editor` option. The :envvar:`MODULES_EDITOR` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. See :envvar:`MODULES_EDITOR`
  description for details.

  .. only:: html or latex

     .. versionadded:: 4.8

 .. mconfig:: extra_siteconfig

  Additional site-specific configuration script location. See
  :ref:`Site-specific configuration` section for details.


  This configuration option is unset by default. The
  :envvar:`MODULES_SITECONFIG` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_SITECONFIG` description for details.

 .. mconfig:: hide_auto_loaded

  Tag automatically loaded modules ``hidden-loaded``

  Default is ``0``. The :envvar:`MODULES_HIDE_AUTO_LOADED` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value.

  .. only:: html or latex

     .. versionadded:: 5.5

 .. mconfig:: home

  Location of Modules package main directory.

  Default value is |file prefix|. It can be changed at installation time with
  :instopt:`--prefix` or :instopt:`--with-moduleshome` options. The
  :envvar:`MODULESHOME` environment variable is defined by :subcmd:`config`
  sub-command when changing this configuration option from its default value.
  See :envvar:`MODULESHOME` description for details.

  .. only:: html or latex

     .. versionadded:: 4.4

 .. mconfig:: icase

  Enable case insensitive match.

  Default value is ``search``. It can be changed at installation time with
  :instopt:`--with-icase` option. The :envvar:`MODULES_ICASE` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. The
  :option:`--icase`/:option:`-i` command line switches change the value of
  this configuration option. See :envvar:`MODULES_ICASE` description for
  details.

  .. only:: html or latex

     .. versionadded:: 4.4

 .. mconfig:: ignore_cache

  Ignore module cache.

  Default is ``0``. The :envvar:`MODULES_IGNORE_CACHE` environment variable
  is defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. The :option:`--ignore-cache` command line
  switch changes the value of this configuration option.

  .. only:: html or latex

     .. versionadded:: 5.3

 .. mconfig:: ignore_user_rc

  Skip evaluation of user-specific module rc file (:file:`$HOME/.modulerc`).

  Default is ``0``. The :envvar:`MODULES_IGNORE_USER_RC` environment variable
  is defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. The :option:`--ignore-user-rc` command line
  switch changes the value of this configuration option.

  .. only:: html or latex

     .. versionadded:: 5.3

 .. mconfig:: ignored_dirs

  Directories ignored when looking for modulefiles.

  Default value is ``CVS RCS SCCS .svn .git .SYNC .sos``. The value of this
  option cannot be altered.

 .. mconfig:: implicit_default

  Set an implicit default version for modules.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-implicit-default<--enable-implicit-default>` option. The
  :envvar:`MODULES_IMPLICIT_DEFAULT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_IMPLICIT_DEFAULT` description for
  details.

 .. mconfig:: implicit_requirement

  Implicitly define a requirement onto modules specified on :mfcmd:`module`
  commands in modulefile.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-implicit-requirement<--enable-implicit-requirement>`
  option. The :envvar:`MODULES_IMPLICIT_REQUIREMENT` environment variable is
  defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. See :envvar:`MODULES_IMPLICIT_REQUIREMENT`
  description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: list_output

  Content to report in addition to module names on :subcmd:`list` sub-command
  regular output mode.

  Default value is ``header:idx:variant:sym:tag:key``. It can be changed at
  installation time with :instopt:`--with-list-output` option. The
  :envvar:`MODULES_LIST_OUTPUT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--output`/:option:`-o` command line switches
  change the value of this configuration option. See
  :envvar:`MODULES_LIST_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: list_terse_output

  Content to report in addition to module names on :subcmd:`list` sub-command
  terse output mode.

  Default value is ``header``. It can be changed at installation time with
  :instopt:`--with-list-terse-output` option. The
  :envvar:`MODULES_LIST_TERSE_OUTPUT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--output`/:option:`-o` command line switches
  change the value of this configuration option. See
  :envvar:`MODULES_LIST_TERSE_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: locked_configs

  Configuration options that cannot be superseded. All options referred in
  :mconfig:`locked_configs` value are locked, thus their value cannot be
  altered.

  This configuration option is set to an empty value by default. It can be
  changed at installation time with :instopt:`--with-locked-configs` option.
  The value of this option cannot be altered.

 .. mconfig:: logged_events

  List of the events to log.

  This configuration option is set to an empty value by default. It can be
  changed at installation time with :instopt:`--with-logged-events` option.
  The :envvar:`MODULES_LOGGED_EVENTS` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_LOGGED_EVENTS` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.5

 .. mconfig:: logger

  Command to log messages.

  Default value is ``logger -t modules``. It can be changed at installation
  time with :instopt:`--with-logger` and :instopt:`--with-logger-opts`
  options. The :envvar:`MODULES_LOGGER` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_LOGGER` description for details.

  .. only:: html or latex

     .. versionadded:: 5.5

 .. mconfig:: mcookie_check

  Defines if the Modules magic cookie (i.e., ``#%Module`` file signature)
  should be checked to determine if a file is a modulefile.

  Default value is ``always``. The :envvar:`MODULES_MCOOKIE_CHECK` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. See
  :envvar:`MODULES_MCOOKIE_CHECK` description for details.

  .. only:: html or latex

     .. versionadded:: 5.1

 .. mconfig:: mcookie_version_check

  Defines if the version set in the Modules magic cookie used in modulefile
  should be checked against the version of :file:`modulecmd.tcl` to determine
  if the modulefile could be evaluated or not.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-mcookie-version-check<--enable-mcookie-version-check>`
  option. The :envvar:`MODULES_MCOOKIE_VERSION_CHECK` environment variable is
  defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. See :envvar:`MODULES_MCOOKIE_VERSION_CHECK`
  description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: ml

  Define :command:`ml` command at initialization time.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-ml<--enable-ml>` option. The :envvar:`MODULES_ML`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_ML` description for details.

  .. only:: html or latex

     .. versionadded:: 4.5

 .. mconfig:: nearly_forbidden_days

  Set the number of days a module should be considered *nearly forbidden*
  prior reaching its expiry date.

  Default value is ``14``. It can be changed at installation time with
  :instopt:`--with-nearly-forbidden-days` option. The
  :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS` description
  for details.

  .. only:: html or latex

     .. versionadded:: 4.6

 .. mconfig:: non_exportable_tags

  Prevent export of listed tags to modules once loaded. (colon ``:``
  separator)

  This configuration option is set to an empty value by default. The
  :envvar:`MODULES_NON_EXPORTABLE_TAGS` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_NON_EXPORTABLE_TAGS` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.7

 .. mconfig:: pager

  Text viewer to paginate message output.

  Default value is ``less -eFKRX``. It can be changed at installation time
  with :instopt:`--with-pager` and :instopt:`--with-pager-opts` options. The
  :envvar:`MODULES_PAGER` environment variable is defined by :subcmd:`config`
  sub-command when changing this configuration option from its default value.
  See :envvar:`MODULES_PAGER` description for details.

 .. mconfig:: paginate

  Control whether or not the output of module command should be piped into
  :mconfig:`pager` command.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--enable-paginate` option. The :envvar:`MODULES_PAGINATE`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. The
  :option:`--paginate`/:option:`-p` and :option:`--no-pager`/:option:`-P`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_PAGINATE` description for details.

  .. only:: html or latex

     .. versionadded:: 5.7

 .. mconfig:: path_entry_reorder

  Change order of entry in a path-like environment variable, when 
  :mfcmd:`prepend-path`, :mfcmd:`append-path` or :subcmd:`use` target a path
  entry that is already defined in the environment variable.

  Default value is ``0``. It can be changed at installation time with the
  :instopt:`--enable-path-entry-reorder` option. The
  :envvar:`MODULES_PATH_ENTRY_REORDER` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_PATH_ENTRY_REORDER` description
  for details.

  .. only:: html or latex

     .. versionadded:: 5.7

 .. mconfig:: protected_envvars

  Prevents any modification of listed environment variables (colon ``:``
  separator).

  This configuration option is unset by default. The
  :envvar:`MODULES_PROTECTED_ENVVARS` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_PROTECTED_ENVVARS` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.2

 .. mconfig:: quarantine_support

  Defines if code for quarantine mechanism support should be generated in
  :command:`module` shell function definition.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-quarantine-support` option. The
  :envvar:`MODULES_QUARANTINE_SUPPORT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_QUARANTINE_SUPPORT` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.0

 .. mconfig:: rcfile

  Location of global run-command file(s).

  This configuration option is unset by default. The :envvar:`MODULERCFILE`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULERCFILE` description for details.

 .. mconfig:: redirect_output

  Control whether or not the output of module command should be redirected
  from stderr to stdout.

  Default value is ``1``. The :envvar:`MODULES_REDIRECT_OUTPUT` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. The :option:`--redirect` and
  :option:`--no-redirect` command line switches change the value of this
  configuration option. See :envvar:`MODULES_REDIRECT_OUTPUT` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.1

 .. mconfig:: require_via

  Consider loaded module enabling a modulepath a requirement for loaded
  modules stored in this modulepath.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-require-via` option. The :envvar:`MODULES_REQUIRE_VIA`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_REQUIRE_VIA` description for details.

  .. only:: html or latex

     .. versionadded:: 5.6

 .. mconfig:: reset_target_state

  Control behavior of :subcmd:`reset` sub-command. Whether environment should
  be purged (``__purge__``), initial environment (``__init__``) or a named
  collection (any other value) should restored.

  Default value is ``__init__``. The :envvar:`MODULES_RESET_TARGET_STATE`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_RESET_TARGET_STATE` description for details.

  .. only:: html or latex

     .. versionadded:: 5.2

 .. mconfig:: run_quarantine

  Environment variables to indirectly pass to :file:`modulecmd.tcl`.

  This configuration option is set to an empty value by default. It can be
  changed at installation time with :instopt:`--with-quarantine-vars` option
  that sets :envvar:`MODULES_RUN_QUARANTINE`. This environment variable is
  also defined by :subcmd:`config` sub-command when changing this
  configuration option. See :envvar:`MODULES_RUN_QUARANTINE` description for
  details.

 .. mconfig:: search_match

  Module search match style.

  Default value is ``starts_with``. It can be changed at installation time
  with :instopt:`--with-search-match` option. The
  :envvar:`MODULES_SEARCH_MATCH` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--contains` and :option:`--starts-with`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_SEARCH_MATCH` description for details.

 .. mconfig:: set_shell_startup

  Ensure module command definition by setting shell startup file.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-set-shell-startup` option. The
  :envvar:`MODULES_SET_SHELL_STARTUP` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_SET_SHELL_STARTUP` description for
  details.

 .. mconfig:: shells_with_ksh_fpath

  Ensure module command is defined in ksh when it is started as a sub-shell
  from the listed shells.

  This configuration option is set to an empty value by default. The
  :envvar:`MODULES_SHELLS_WITH_KSH_FPATH` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_SHELLS_WITH_KSH_FPATH` description
  for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: silent_shell_debug

  Disablement of shell debugging property for the module command. Also defines
  if code to silence shell debugging property should be generated in
  :command:`module` shell function definition.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-silent-shell-debug-support` option. The
  :envvar:`MODULES_SILENT_SHELL_DEBUG` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_SILENT_SHELL_DEBUG` description for
  details.

 .. mconfig:: siteconfig

  Primary site-specific configuration script location. See
  :ref:`Site-specific configuration` section for details.


  Default value is |file etcdir_siteconfig|. It can be changed at installation
  time with :instopt:`--prefix` or :instopt:`--etcdir` options. The value of
  this option cannot be altered.

 .. mconfig:: source_cache

  Cache content of files evaluated in modulefile through :manpage:`source(n)`
  Tcl command.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-source-cache` option. The :envvar:`MODULES_SOURCE_CACHE`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. See
  :envvar:`MODULES_SOURCE_CACHE` description for details.

  .. only:: html or latex

     .. versionadded:: 5.4

 .. mconfig:: spider_indepth

  :subcmd:`spider` sub-command in depth search mode.

  Default value is ``1``. It can be changed at installation time with
  :instopt:`--disable-spider-indepth<--enable-spider-indepth>` option. The
  :envvar:`MODULES_SPIDER_INDEPTH` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--indepth` and :option:`--no-indepth`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_SPIDER_INDEPTH` description for details.

  .. only:: html or latex

     .. versionadded:: 5.6

 .. mconfig:: spider_output

  Content to report in addition to module names on :subcmd:`spider`
  sub-command regular output mode.

  Default value is ``modulepath:alias:dirwsym:sym:tag:variantifspec:via:key``.
  It can be changed at installation time with :instopt:`--with-spider-output`
  option. The :envvar:`MODULES_SPIDER_OUTPUT` environment variable is defined
  by :subcmd:`config` sub-command when changing this configuration option from
  its default value. The :option:`--output`/:option:`-o` command line switches
  change the value of this configuration option. See
  :envvar:`MODULES_SPIDER_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 5.6

 .. mconfig:: spider_terse_output

  Content to report in addition to module names on :subcmd:`spider`
  sub-command terse output mode.

  Default value is ``modulepath:alias:dirwsym:sym:tag:variantifspec``. It can
  be changed at installation time with :instopt:`--with-spider-terse-output`
  option. The :envvar:`MODULES_SPIDER_TERSE_OUTPUT` environment variable is
  defined by :subcmd:`config` sub-command when changing this configuration
  option from its default value. The :option:`--output`/:option:`-o` command
  line switches change the value of this configuration option. See
  :envvar:`MODULES_SPIDER_TERSE_OUTPUT` description for details.

  .. only:: html or latex

     .. versionadded:: 5.6

 .. mconfig:: sticky_purge

  Error behavior when unloading sticky or super-sticky module during a module
  :subcmd:`purge`.

  Raise an ``error`` (default) or emit a ``warning`` or be ``silent``. It can
  be changed at installation time with :instopt:`--with-sticky-purge` option.
  The :envvar:`MODULES_STICKY_PURGE` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_STICKY_PURGE` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.4

 .. mconfig:: tag_abbrev

  Abbreviations to use to report module tags.

  Default value is ``auto-loaded=aL:loaded=L:hidden=H:hidden-loaded=H:forbidden=F:nearly-forbidden=nF:sticky=S:super-sticky=sS:keep-loaded=kL:warning=W``.
  It can be changed at installation time with :instopt:`--with-tag-abbrev`
  option. The :envvar:`MODULES_TAG_ABBREV` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_TAG_ABBREV` description for details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: tag_color_name

  Tags whose name should be colored instead of module name.

  This configuration option is set to an empty value by default. It can be
  changed at installation time with :instopt:`--with-tag-color-name` option.
  The :envvar:`MODULES_TAG_COLOR_NAME` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_TAG_COLOR_NAME` description for
  details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: tcl_ext_lib

  Modules Tcl extension library location.

  Default value is |file libdir_tcl_ext_lib|. It can be changed at
  installation time with :instopt:`--prefix` or :instopt:`--libdir` options.
  The value of this option cannot be altered.

 .. mconfig:: tcl_linter

  Command to check syntax of modulefiles with through :subcmd:`lint`
  sub-command.

  Default value is ``nagelfar.tcl``. It can be changed at installation time
  with :instopt:`--with-tcl-linter` and :instopt:`--with-tcl-linter-opts`
  options. The :envvar:`MODULES_TCL_LINTER` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_TCL_LINTER` description for details.

  .. only:: html or latex

     .. versionadded:: 5.2

 .. mconfig:: term_background

  Terminal background color kind.

  Default value is ``dark``. It can be changed at installation time with
  :instopt:`--with-terminal-background` option. The
  :envvar:`MODULES_TERM_BACKGROUND` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_TERM_BACKGROUND` description for
  details.

 .. mconfig:: term_width

  Set the width of the output.

  Default value is ``0``. The :envvar:`MODULES_TERM_WIDTH` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. The
  :option:`--width`/:option:`-w` command line switches change the value of
  this configuration option. See :envvar:`MODULES_TERM_WIDTH` description for
  details.

  .. only:: html or latex

     .. versionadded:: 4.7

 .. mconfig:: unique_name_loaded

  Only one module loaded per module name.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-unique-name-loaded` option. The
  :envvar:`MODULES_UNIQUE_NAME_LOADED` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_UNIQUE_NAME_LOADED` description for
  details.

  .. only:: html or latex

     .. versionadded:: 5.4

 .. mconfig:: unload_match_order

  Unload firstly loaded or lastly loaded module matching request.

  Default value is ``returnlast``. It can be changed at installation time with
  :instopt:`--with-unload-match-order` option. The
  :envvar:`MODULES_UNLOAD_MATCH_ORDER` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_UNLOAD_MATCH_ORDER` description for
  details.

 .. mconfig:: variant_shortcut

  Shortcut characters that could be used to specify or report module variants.

  This configuration option is set to an empty value by default. It can be
  changed at installation time with :instopt:`--with-variant-shortcut` option.
  The :envvar:`MODULES_VARIANT_SHORTCUT` environment variable is defined by
  :subcmd:`config` sub-command when changing this configuration option from
  its default value. See :envvar:`MODULES_VARIANT_SHORTCUT` description for
  details.

  .. only:: html or latex

     .. versionadded:: 4.8

 .. mconfig:: verbosity

  Module command verbosity level.

  Default value is ``normal``. It can be changed at installation time with
  :instopt:`--with-verbosity` option. The :envvar:`MODULES_VERBOSITY`
  environment variable is defined by :subcmd:`config` sub-command when
  changing this configuration option from its default value. The
  :option:`--debug`/:option:`-D`, :option:`--silent`/:option:`-s`,
  :option:`--trace`/:option:`-T` and :option:`--verbose`/:option:`-v`
  command line switches change the value of this configuration option. See
  :envvar:`MODULES_VERBOSITY` description for details.

 .. mconfig:: wa_277

  Workaround for Tcsh history issue.

  Default value is ``0``. It can be changed at installation time with
  :instopt:`--enable-wa-277` option. The :envvar:`MODULES_WA_277` environment
  variable is defined by :subcmd:`config` sub-command when changing this
  configuration option from its default value. See :envvar:`MODULES_WA_277`
  description for details.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.3
       *Value* prefixes ``+`` and ``-`` added to append and subtract elements
       to list-value options

.. subcmd:: describe [collection]

 See :subcmd:`saveshow`.

 .. only:: html or latex

    .. versionadded:: 5.6

.. subcmd:: disable [collection]

 See :subcmd:`saverm`.

 .. only:: html or latex

    .. versionadded:: 5.6

.. subcmd:: display modulefile...

 Display information about one or more *modulefiles*. The display sub-command
 will list the full path of the *modulefile* and the environment changes
 the *modulefile* will make if loaded. (Note: It will not display any
 environment changes found within conditional statements.)

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are evaluated sequentially in the
 specified order. If one modulefile evaluation raises an error, display
 sequence continues.

.. subcmd:: edit modulefile

 Open *modulefile* for edition with text editor command designated by the
 :mconfig:`editor` configuration option.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 .. only:: html or latex

    .. versionadded:: 4.8

.. subcmd:: help [modulefile...]

 Print the usage of each sub-command. If an argument is given, print the
 Module-specific help information for the *modulefile*.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are evaluated sequentially in the
 specified order. If one modulefile evaluation raises an error, help sequence
 continues.

.. subcmd:: info-loaded modulefile

 Returns the names of currently loaded modules matching passed *modulefile*.
 Returns an empty string if passed *modulefile* does not match any loaded
 modules. See :mfcmd:`module-info loaded<module-info>` in the
 :ref:`modulefile(5)` man page for further explanation.

 .. only:: html or latex

    .. versionadded:: 4.1

.. subcmd:: initadd modulefile...

 Add *modulefile* to the shell's initialization file in the user's home
 directory. The startup files checked (in order) are:

 C Shell

  :file:`.modules`, :file:`.cshrc`, :file:`.csh_variables` and :file:`.login`

 TENEX C Shell

  :file:`.modules`, :file:`.tcshrc`, :file:`.cshrc`, :file:`.csh_variables`
  and :file:`.login`

 Bourne and Korn Shells

  :file:`.modules`, :file:`.profile`

 GNU Bourne Again Shell

  :file:`.modules`, :file:`.bash_profile`, :file:`.bash_login`,
  :file:`.profile` and :file:`.bashrc`

 Z Shell

  :file:`.modules`, :file:`.zshrc`, :file:`.zshenv` and :file:`.zlogin`

 Friendly Interactive Shell

  :file:`.modules`, :file:`.config/fish/config.fish`

 If a ``module load`` line is found in any of these files, the *modulefiles*
 are appended to any existing list of *modulefiles*. The ``module load``
 line must be located in at least one of the files listed above for any of
 the :subcmd:`init<initadd>` sub-commands to work properly. If the
 ``module load`` line is found in multiple shell initialization files, all of
 the lines are changed.

.. subcmd:: initclear

 Clear all of the *modulefiles* from the shell's initialization files.

.. subcmd:: initlist

 List all of the *modulefiles* loaded from the shell's initialization file.

.. subcmd:: initprepend modulefile...

 Does the same as :subcmd:`initadd` but prepends the given modules to the
 beginning of the list.

.. subcmd:: initrm modulefile...

 Remove *modulefile* from the shell's initialization files.

.. subcmd:: initswitch modulefile1 modulefile2

 Switch *modulefile1* with *modulefile2* in the shell's initialization files.

.. subcmd:: is-avail modulefile...

 Returns a true value if any of the listed *modulefiles* exists in enabled
 :envvar:`MODULEPATH`. Returns a false value otherwise. See :mfcmd:`is-avail`
 in the :ref:`modulefile(5)` man page for further explanation.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 .. only:: html or latex

    .. versionadded:: 4.1

.. subcmd:: is-loaded [modulefile...]

 Returns a true value if any of the listed *modulefiles* has been loaded or if
 any *modulefile* is loaded in case no argument is provided. Returns a false
 value otherwise. See :mfcmd:`is-loaded` in the :ref:`modulefile(5)` man page
 for further explanation.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 .. only:: html or latex

    .. versionadded:: 4.1

.. subcmd:: is-saved [collection...]

 Returns a true value if any of the listed *collections* exists or if any
 *collection* exists in case no argument is provided. Returns a false value
 otherwise. See :mfcmd:`is-saved` in the :ref:`modulefile(5)` man page for
 further explanation.

 .. only:: html or latex

    .. versionadded:: 4.1

.. subcmd:: is-used [directory...]

 Returns a true value if any of the listed *directories* has been enabled in
 :envvar:`MODULEPATH` or if any *directory* is enabled in case no argument is
 provided. Returns a false value otherwise. See :mfcmd:`is-used` in the
 :ref:`modulefile(5)` man page for further explanation.

 .. only:: html or latex

    .. versionadded:: 4.1

.. subcmd:: keyword [-a] [-j] string

 See :subcmd:`search`.

.. subcmd:: lint [-a] [modulefile...]

 Analyze syntax of one or more *modulefiles* with the linter command
 designated by the :mconfig:`tcl_linter` configuration option.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If no *modulefile* is specified, all the *modulefiles* and modulerc
 available in enabled modulepaths are analyzed as well as global rc, user rc
 and modulecache files . Hidden modulefiles are also analyzed when
 :option:`--all`/:option:`-a` option is set.

 When :command:`nagelfar.tcl` is the selected linter command, a static Tcl
 syntax analysis is performed. In addition, syntax of modulefile commands are
 checked in these files based on their kind (global/user rc, modulerc,
 modulecache or modulefile).

 .. only:: html or latex

    .. versionadded:: 5.2

    .. versionchanged:: 5.6
       Also lint :file:`.modulecache` files

.. subcmd:: list [-t|-l|-j] [-a] [-o LIST] [-S|-C] [pattern...]

 List loaded modules. If a *pattern* is given, then the loaded modules are
 filtered to only list those whose name matches this *pattern*. It may contain
 wildcard characters. *pattern* is matched in a case insensitive manner by
 default. If multiple *patterns* are given, loaded module has to match at
 least one of them to be listed.

 Module tags applying to the loaded modules are reported along the module name
 they are associated to (see `Module tags`_ section).

 Module variants selected on the loaded modules are reported along the module
 name they belong to (see `Module variants`_ section).

 A *Key* section is added at the end of the output in case some elements are
 reported in parentheses or chevrons along module name or if some graphical
 rendition is made over some output elements. This *Key* section gives hints
 on the meaning of such elements.

 The parameter *pattern* may also refer to a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If *pattern* contains variant specification, loaded modules are included in
 results only if they match it. *pattern* may be a bare variant specification
 without mention of a module name.

 .. only:: html or latex

    .. versionchanged:: 4.5
       Option :option:`--json`/:option:`-j` added

    .. versionchanged:: 4.7
       Option :option:`--all`/:option:`-a` added

    .. versionchanged:: 4.7
       *Key* section added at end of output

    .. versionchanged:: 4.7
       Option :option:`--output`/:option:`-o` added, compatible with regular
       and terse output modes.

    .. versionchanged:: 4.8
       Report if enabled the variants selected on loaded modules

    .. versionchanged:: 5.1
       *pattern* search to filter loaded modules added

    .. versionchanged:: 5.1
       Options :option:`--starts-with`/:option:`-S` and
       :option:`--contains`/:option:`-C` added

    .. versionchanged:: 5.3
       *pattern* may include variant specification to filter results

.. subcmd:: load [options] modulefile...

 Load *modulefile* into the shell environment.

 :subcmd:`load` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``
 * ``--tag=taglist``

 Once loaded, the ``loaded`` module tag is associated to the loaded module. If
 module has been automatically loaded by another module, the ``auto-loaded``
 tag is associated instead (see `Module tags`_ section).

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are loaded sequentially in the
 specified order. If one modulefile evaluation raises an error, load sequence
 continues: loaded modules prior the evaluation error are kept loaded and
 sequence is resumed with the load of remaining modulefile in list.
 Conversely, load sequence is aborted and already loaded modulefiles are
 withdrawn if :subcmd:`load` sub-command is defined in
 :mconfig:`abort_on_error` configuration option and :option:`--force` option
 is not set.

 The :option:`--tag` option accepts a list of module tags to apply to
 *modulefile* once loaded. If module is already loaded, tags from *taglist*
 are added to the list of tags already applied to this module.

 .. only:: html or latex

    .. versionchanged:: 4.2
       Options :option:`--auto`, :option:`--no-auto`,
       :option:`--force`/:option:`-f` added

    .. versionchanged:: 5.1
       Option :option:`--tag` added

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: load-any [options] modulefile...

 Load into the shell environment one of the *modulefile* specified. Try to
 load each *modulefile* specified in list from the left to the right until
 one got loaded or is found already loaded. Do not complain if *modulefile*
 cannot be found. But if its evaluation fails, an error is reported and next
 modulefile in list is evaluated.

 :subcmd:`load-any` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``
 * ``--tag=taglist``

 Once loaded, the ``loaded`` module tag is associated to the loaded module. If
 module has been automatically loaded by another module, the ``auto-loaded``
 tag is associated instead (see `Module tags`_ section).

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 The :option:`--tag` option accepts a list of module tags to apply to
 *modulefile* once loaded. If module is already loaded, tags from *taglist*
 are added to the list of tags already applied to this module.

 .. only:: html or latex

    .. versionadded:: 5.1

.. subcmd:: mod-to-sh [options] shell modulefile...

 Evaluate *modulefile* and report resulting environment changes as code for
 *shell*.

 :subcmd:`mod-to-sh` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``

 An attempt to load *modulefile* is made to get its environment changes. This
 evaluation does not change the current shell environment. Like for
 :subcmd:`load` sub-command, no evaluation occurs if *modulefile* is found
 loaded in current environment.

 Changes made on environment variable intended for Modules private use (e.g.,
 :envvar:`LOADEDMODULES`, :envvar:`_LMFILES_`, ``__MODULES_*``) are ignored.

 *Shell* could be any shell name supported by :file:`modulecmd.tcl`.

 Produced *shell* code is returned on the message output channel by
 :file:`modulecmd.tcl`. Thus it is not rendered in current environment by the
 :command:`module` shell function.

 :subcmd:`mod-to-sh` automatically set :mconfig:`verbosity` to the ``silent``
 mode, to avoid messages to mix with the produced shell code. Verbosity is not
 changed if set to the ``trace`` mode or any higher debugging level.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are evaluated sequentially in the
 specified order. If one modulefile evaluation raises an error, mod-to-sh
 sequence continues: environment change from modules evaluated prior the
 error are preserved and sequence is resumed with the evaluation of remaining
 modulefile in list. Conversely, mod-to-sh sequence is aborted and changes
 from already evaluated modules are withdrawn if :subcmd:`mod-to-sh`
 sub-command is defined in :mconfig:`abort_on_error` configuration option and
 :option:`--force` option is not set.

 .. only:: html or latex

    .. versionadded:: 5.2

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: path modulefile

 Print path to *modulefile*.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 .. only:: html or latex

    .. versionadded:: 4.0

.. subcmd:: paths pattern

 Print path of available *modulefiles* matching *pattern*.

 The parameter *pattern* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If *pattern* contains variant specification or :ref:`extra specifier`, the
 :ref:`extra match search` process is triggered to collect command information
 used in modulefiles. Modules are included in results only if they match
 *pattern* variant specification and extra specifier. *pattern* may be a bare
 variant specification or extra specifier without mention of a module name.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.3
       *pattern* may include variant specification or extra specifier to
       filter results

.. subcmd:: prepend-path [options] variable value...

 Prepend *value* to environment *variable*. The *variable* is a colon, or
 *delimiter*, separated list. See :mfcmd:`prepend-path` in the
 :ref:`modulefile(5)` man page for *options* description and further
 explanation.

 When :subcmd:`prepend-path` is called as a module sub-command, the reference
 counter variable, which denotes the number of times *value* has been added to
 environment *variable*, is not updated unless if the ``--duplicates`` option
 is set.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       Reference counter environment variable is not updated anymore unless if
       the ``--duplicates`` option is set

.. subcmd:: purge [-f]

 Unload all loaded *modulefiles*.

 When the :option:`--force` option is set, also unload `sticky modules`_,
 modulefiles that are depended by non-unloadable modules and modulefiles
 raising an evaluation error.

 If one modulefile unload evaluation raises an error, purge sequence
 continues: unloaded modules prior the evaluation error are kept unloaded and
 sequence is resumed with the unload of remaining modulefiles. Conversely,
 purge sequence is aborted and already unloaded modulefiles are restored if
 :subcmd:`purge` sub-command is defined in :mconfig:`abort_on_error`
 configuration option and :option:`--force` option is not set.

 .. only:: html or latex

    .. versionchanged:: 4.7
       Option :option:`--force`/:option:`-f` added

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: refresh

 Force a refresh of all non-persistent components of currently loaded modules.
 This should be used on derived shells where shell completions, shell aliases
 or shell functions need to be reinitialized but the environment variables
 have already been set by the currently loaded modules.

 Loaded modules are evaluated in ``refresh`` mode following their load order.
 In this evaluation mode only the :mfcmd:`complete`, :mfcmd:`set-alias`,
 :mfcmd:`set-function` and :mfcmd:`puts` modulefile commands will produce
 environment changes. Other modulefile commands that produce environment
 changes (like :mfcmd:`setenv` or :mfcmd:`append-path`) are ignored during a
 ``refresh`` evaluation as their changes should already be applied.

 Only the loaded modules defining non-persistent environment changes are
 evaluated in ``refresh`` mode. Such loaded modules are listed in the
 :envvar:`__MODULES_LMREFRESH` environment variable.

 If one modulefile evaluation raises an error, refresh sequence continues:
 environment changes from refreshed modules prior the evaluation error are
 preserved and sequence is resumed with the refresh of remaining modulefiles.

 .. only:: html or latex

    .. versionchanged:: 4.0
       Sub-command made as an alias of :subcmd:`reload` sub-command

    .. versionchanged:: 5.0
       Behavior of version 3.2 :subcmd:`refresh` sub-command restored

    .. versionchanged:: 5.2
       Only evaluate modules listed in :envvar:`__MODULES_LMREFRESH`

.. subcmd:: reload [-f]

 Unload then load all loaded *modulefiles*.

 No unload then load is performed and an error is returned if the loaded
 *modulefiles* have unsatisfied constraint corresponding to the
 :mfcmd:`prereq` and :mfcmd:`conflict` they declare.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 If one modulefile load or unload evaluation raises an error, reload sequence
 aborts: environment changes coming from already evaluated modulefiles are
 withdrawn and remaining modulefile evaluations are skipped. Conversely, if
 :subcmd:`reload` is removed from :mconfig:`abort_on_error` configuration
 option list or if :option:`--force` option is set, reload sequence continues:
 already achieved module evaluations are kept and reload sequence is resumed
 with the remaining modulefiles.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

    .. versionchanged:: 5.4
       Option :option:`--force`/:option:`-f` added

.. subcmd:: remove-path [options] variable value...

 Remove *value* from the colon, or *delimiter*, separated list in environment
 *variable*. See :mfcmd:`remove-path` in the :ref:`modulefile(5)` man page for
 *options* description and further explanation.

 When :subcmd:`remove-path` is called as a module sub-command, the reference
 counter variable, which denotes the number of times *value* has been added to
 environment *variable*, is ignored and *value* is removed whatever the
 reference counter value set.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       *value* is removed whatever its reference counter value

.. subcmd:: reset [-f]

 Restore initial environment, which corresponds to the loaded state after
 :ref:`Modules initialization<Package Initialization>`.

 :subcmd:`reset` sub-command restores the environment definition found in
 :envvar:`__MODULES_LMINIT` environment variable.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 :subcmd:`reset` behavior can be changed with :mconfig:`reset_target_state`.
 This configuration option is set by default to ``__init__``, which
 corresponds to the above behavior description. When set to ``__purge__``,
 :subcmd:`reset` performs a :subcmd:`purge` of the environment. When set to
 any other value, :subcmd:`reset` performs a :subcmd:`restore` of
 corresponding name collection.

 .. only:: html or latex

    .. versionadded:: 5.2

    .. versionchanged:: 5.4
       Option :option:`--force`/:option:`-f` added

.. subcmd:: restore [-f] [collection]

 Restore the environment state as defined in *collection*. If *collection*
 name is not specified, then it is assumed to be the *default* collection if
 it exists, ``__init__`` special collection otherwise. If *collection* is a
 fully qualified path, it is restored from this location rather than from a
 file under the user's collection directory. If
 :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the value
 of this variable is appended to the *collection* file name to restore.

 If *collection* name is ``__init__``, initial environment state defined in
 :envvar:`__MODULES_LMINIT` environment variable is restored.

 When restoring a *collection*, the currently set :envvar:`MODULEPATH`
 directory list and the currently loaded *modulefiles* are unused and
 unloaded then used and loaded to exactly match the :envvar:`MODULEPATH` and
 loaded *modulefiles* lists saved in this *collection* file. The order
 of the paths and modulefiles set in *collection* is preserved when
 restoring. It means that currently loaded modules are unloaded to get
 the same :envvar:`LOADEDMODULES` root than collection and currently used
 module paths are unused to get the same :envvar:`MODULEPATH` root. Then
 missing module paths are used and missing modulefiles are loaded.

 If a module, without a default version explicitly defined, is recorded in a
 *collection* by its bare name: loading this module when restoring the
 collection will fail if the configuration option :mconfig:`implicit_default`
 is disabled.

 If one modulefile load or unload evaluation raises an error, restore sequence
 continues: environment changes from modules unloaded or loaded prior the
 evaluation error are preserved and sequence is resumed with the unload or
 load of remaining modulefiles.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.2
       Restore initial environment when *collection* name is ``__init__`` or
       when no collection name is specified and no *default* collection exists

    .. versionchanged:: 5.4
       Option :option:`--force`/:option:`-f` added

.. subcmd:: rm [--auto|--no-auto] [-f] modulefile...

 See :subcmd:`unload`.

.. subcmd:: save [collection]

 Record the currently set :envvar:`MODULEPATH` directory list and the
 currently loaded *modulefiles* in a *collection* file under the user's
 collection directory :file:`$HOME/.module`. If *collection* name is not
 specified, then it is assumed to be the ``default`` collection. If
 *collection* is a fully qualified path, it is saved at this location rather
 than under the user's collection directory.

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable will be appended to the *collection* file name.

 By default, if a loaded modulefile corresponds to the explicitly defined
 default module version, the bare module name is recorded. If the
 configuration option :mconfig:`implicit_default` is enabled, the bare module
 name is also recorded for the implicit default module version. If
 :envvar:`MODULES_COLLECTION_PIN_VERSION` is set to ``1``, module version is
 always recorded even if it is the default version.

 By default, only the module tags specifically set with the :option:`--tag`
 option or resulting from a specific module state (like ``auto-loaded`` and
 ``keep-loaded`` tags) are recorded in collection. If
 :envvar:`MODULES_COLLECTION_PIN_TAG` is set to ``1``, all tags are recorded
 in collection except ``nearly-forbidden`` tag.

 No *collection* is recorded and an error is returned if the loaded
 *modulefiles* have unsatisfied constraint corresponding to the
 :mfcmd:`prereq` and :mfcmd:`conflict` they declare.

 .. only:: html or latex

    .. versionadded:: 4.0

.. subcmd:: savelist [-t|-l|-j] [-a] [-S|-C] [pattern...]

 List collections that are currently saved under the user's collection
 directory. If :envvar:`MODULES_COLLECTION_TARGET` is set, only collections
 matching the target suffix will be displayed unless if the
 :option:`--all`/:option:`-a` option is set.

 If a *pattern* is given, then the collections are filtered to only list
 those whose name matches this *pattern*. It may contain wildcard characters.
 *pattern* is matched in a case insensitive manner by default. If multiple
 *patterns* are given, collection has to match at least one of them to be
 listed.

 Stash collections are not listed unless if the :option:`--all`/:option:`-a`
 option is set. Stash collections can be listed with :subcmd:`stashlist`
 sub-command.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 4.5
       Option :option:`--json`/:option:`-j` added

    .. versionchanged:: 5.2
       *pattern* search to filter collections added

    .. versionchanged:: 5.2
       Options :option:`--starts-with`/:option:`-S`,
       :option:`--contains`/:option:`-C` and :option:`--all`/:option:`-a`
       added

.. subcmd:: saverm [collection]

 Delete the *collection* file under the user's collection directory. If
 *collection* name is not specified, then it is assumed to be the *default*
 collection. If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix
 equivalent to the value of this variable will be appended to the *collection*
 file name.

 .. only:: html or latex

    .. versionadded:: 4.0

.. subcmd:: saveshow [collection]

 Display the content of *collection*. If *collection* name is not specified,
 then it is assumed to be the *default* collection if it exists, ``__init__``
 special collection otherwise. If *collection* is a fully qualified path, this
 location is displayed rather than a collection file under the user's
 collection directory. If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix
 equivalent to the value of this variable will be appended to the *collection*
 file name.

 If *collection* name is ``__init__``, initial environment content defined in
 :envvar:`__MODULES_LMINIT` environment variable is displayed.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.2
       Display content of initial environment when *collection* name is
       ``__init__`` or when no collection name is specified and no *default*
       collection exists

.. subcmd:: search [-a] [-j] string

 Seeks through the :mfcmd:`module-whatis` information of all *modulefiles*
 for the specified *string*. All *module-whatis* information matching the
 *string* in a case insensitive manner will be displayed. *string* may contain
 wildcard characters.

 .. only:: html or latex

    .. versionadded:: 4.0
       Prior version `4.0` :mfcmd:`module-whatis` information search was
       performed with :subcmd:`apropos` or :subcmd:`keyword` sub-commands.

    .. versionchanged:: 4.5
       Option :option:`--json`/:option:`-j` added

    .. versionchanged:: 4.6
       Option :option:`--all`/:option:`-a` added

.. subcmd:: sh-to-mod shell script [arg...]

 Evaluate with *shell* the designated *script* with defined *arguments* to
 find out the environment changes it does. Environment prior and after
 *script* evaluation are compared to determine these changes. They are
 translated into *modulefile* commands to output the modulefile content
 equivalent to the evaluation of shell script.

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

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 5.1
       Changes on Modules private environment variable are ignored

    .. versionchanged:: 5.1
       Support for tracking shell completion changes on bash, tcsh and fish
       shells added

    .. versionchanged:: 5.4
       Support for ``bash-eval`` shell mode added

.. subcmd:: show modulefile...

 See :subcmd:`display`.

.. subcmd:: source [options] modulefile...

 Execute *modulefile* into the shell environment. Once executed *modulefile*
 is not marked loaded in shell environment which differ from :subcmd:`load`
 sub-command.

 :subcmd:`source` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``

 If *modulefile* corresponds to a fully qualified path, this file is executed.
 Otherwise *modulefile* is searched among the available modulefiles.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are evaluated sequentially in the
 specified order. If one modulefile evaluation raises an error, source
 sequence continues: environment changes from modules sourced prior the
 evaluation error are preserved and sequence is resumed with the source of
 remaining modulefile in list.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.2
       Accept modulefile specification as argument

.. subcmd:: spider [-d|-L] [-t|-l|-j] [-a] [-o LIST] [-S|-C] [--indepth|--no-indepth] [pattern...]

 List all available *modulefiles* found in enabled modulepaths and recursively
 found in modulepaths enabled by available *modulefiles*.

 :subcmd:`spider` sub-command first performs an :ref:`extra match search` to
 get all modulepaths to look at. These modulepaths are collected from the
 directory arguments set to the :mfcmd:`module use<module>`,
 :mfcmd:`append-path MODULEPATH<append-path>` or :mfcmd:`prepend-path
 MODULEPATH<prepend-path>` modulefile commands. Collecting modulepaths is
 first achieved in the global/user rc section and modulepaths defined in
 :envvar:`MODULEPATH` then in each modulepath collected from modulefiles, and
 so on. As collecting modulepaths implies evaluating every available
 modulefiles, it is advised to build and use :ref:`Module cache` to improve
 search speed.

 Once modulepaths are gathered, :subcmd:`spider` proceeds and reports like
 :subcmd:`avail` sub-command. The same set of options are supported.

 If a *pattern* argument is given, then each collected modulepath is searched
 for *modulefiles* whose pathname, symbolic version-name or alias
 match *pattern* in a case insensitive manner by default. *pattern* may
 contain wildcard characters.i

 Symbolic version-names and aliases found in the search are displayed in the
 result of this sub-command. Symbolic version-names are displayed next to
 the *modulefile* they are assigned to within parenthesis. Aliases are listed
 in the modulepath section where they have been defined. To distinguish
 aliases from *modulefiles* a ``@`` symbol is added within parenthesis next to
 their name. Aliases defined through a global or user specific module RC file
 are listed under the **global/user modulerc** section.

 When colored output is enabled and a specific graphical rendition is defined
 for module *default* version, the ``default`` symbol is omitted and instead
 the defined graphical rendition is applied to the relative modulefile. When
 colored output is enabled and a specific graphical rendition is defined for
 module alias, the ``@`` symbol is omitted. The defined graphical rendition
 applies to the module alias name. See :envvar:`MODULES_COLOR` and
 :envvar:`MODULES_COLORS` sections for details on colored output.

 Module tags applying to the available *modulefiles* returned by the
 :subcmd:`spider` sub-command are reported along the module name they are
 associated to (see `Module tags`_ section).

 Module variants and their available values may be reported along the module
 name they belong to (see `Module variants`_ section) if defined in spider
 output configuration option (see :option:`--output`/:option:`-o` option). The
 :ref:`extra match search` process is triggered to collect variant
 information.

 A *Key* section is added at the end of the output in case some elements are
 reported in parentheses or chevrons along module name or if some graphical
 rendition is made over some output elements. This *Key* section gives hints
 on the meaning of such elements.

 The parameter *pattern* may also refer to a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If *pattern* contains variant specification or :ref:`extra specifier`, the
 :ref:`extra match search` process is triggered to collect command information
 used in modulefiles. Modules are included in results only if they match
 *pattern* variant specification and extra specifier. *pattern* may be a bare
 variant specification or extra specifier without mention of a module name.

 When several *patterns* are provided all modulefiles matching at least one of
 these *patterns* are listed.

 .. only:: html or latex

    .. versionadded:: 5.6

.. subcmd:: stash [-f]

 :subcmd:`Save<save>` current environment in a stash collection then
 :subcmd:`reset` to initial environment.

 A collection is created only if current environment state differs from
 initial environment. Stash collection is named
 *stash-<unix_millis_timestamp>* where *<unix_millis_timestamp>* is the number
 of milliseconds between Unix Epoch and when this command is run.

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable will be appended to the stash collection file name.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 .. only:: html or latex

    .. versionadded:: 5.2

    .. versionchanged:: 5.4
       Option :option:`--force`/:option:`-f` added

.. subcmd:: stashclear

 Remove all stash collection files of current :mconfig:`collection_target`. If
 no collection target is currently set, remove stash collection files without
 a target suffix.

 .. only:: html or latex

    .. versionadded:: 5.2

.. subcmd:: stashlist [-t|-l|-j]

 List all stash collection files of current :mconfig:`collection_target`. If
 no collection target is currently set, list stash collection files without a
 target suffix.

 .. only:: html or latex

    .. versionadded:: 5.2

.. subcmd:: stashpop [-f] [stash]

 :subcmd:`Restore<restore>` *stash* collection then delete corresponding
 collection file.

 *stash* is either a full stash collection name (i.e.,
 *stash-<unix_millis_timestamp>*) or a stash index. Most recent stash
 collection has index *0*, *1* is the one before it. When no *stash* is given
 the latest stash collection is assumed (that is stash index *0*).

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable will be appended to the stash collection file name to
 restore.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 .. only:: html or latex

    .. versionadded:: 5.2

    .. versionchanged:: 5.4
       Option :option:`--force`/:option:`-f` added

.. subcmd:: stashrm [stash]

 :subcmd:`Remove<saverm>` *stash* collection file.

 *stash* is either a full stash collection name (i.e.,
 *stash-<unix_millis_timestamp>*) or a stash index. Most recent stash
 collection has index *0*, *1* is the one before it. When no *stash* is given
 the latest stash collection is assumed (that is stash index *0*).

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable will be appended to the stash collection file name to
 delete.

 .. only:: html or latex

    .. versionadded:: 5.2

.. subcmd:: stashshow [stash]

 :subcmd:`Display<saveshow>` the content of *stash* collection file.

 *stash* is either a full stash collection name (i.e.,
 *stash-<unix_millis_timestamp>*) or a stash index. Most recent stash
 collection has index *0*, *1* is the one before it. When no *stash* is given
 the latest stash collection is assumed (that is stash index *0*).

 If :envvar:`MODULES_COLLECTION_TARGET` is set, a suffix equivalent to the
 value of this variable will be appended to the stash collection file name to
 display.

 .. only:: html or latex

    .. versionadded:: 5.2

.. subcmd:: state [name]

 Gets :file:`modulecmd.tcl` states. Reports the currently set value
 of passed state *name* or all existing states if no *name* passed.

 .. only:: html or latex

    .. versionadded:: 5.1

.. subcmd:: swap [options] [modulefile1] modulefile2

 See :subcmd:`switch`.

.. subcmd:: switch [options] [modulefile1] modulefile2

 Switch loaded *modulefile1* with *modulefile2*. If *modulefile1* is not
 specified, it is assumed to be the currently loaded module that shares the
 same root name as *modulefile2*. The root name is defined as the initial part
 of a module name, i.e., all characters preceding the first ``/``.

 :subcmd:`switch` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``
 * ``--tag=taglist``

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 The :option:`--tag` option accepts a list of module tags to apply to
 *modulefile* once loaded. If module is already loaded, tags from *taglist*
 are added to the list of tags already applied to this module.

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 If unload evaluation of *modulefile1* raises an error, switch sequence
 aborts: no environment change from *modulefile1* unload is applied and load
 of *modulefile2* is skipped. Conversely, if ``switch_unload`` value is
 removed from :mconfig:`abort_on_error` configuration option list (and
 ``switch`` value is not set there) or if :option:`--force` option is set,
 switch sequence continues. If *modulefile1* is tagged ``super-sticky``,
 switch sequence aborts in any case.

 If load evaluation of *modulefile2* raises an error, switch sequence
 continues: environment changes from *modulefile1* unload are applied but not
 those from failed *modulefile2* load. Conversely, whole switch sequence is
 aborted and unloaded *modulefile1* is restored if :subcmd:`switch`
 sub-command is defined in :mconfig:`abort_on_error` configuration option and
 :option:`--force` option is not set.

 .. only:: html or latex

    .. versionchanged:: 4.2
       Options :option:`--auto`, :option:`--no-auto`,
       :option:`--force`/:option:`-f` added

    .. versionchanged:: 5.1
       Option :option:`--tag` added

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: test modulefile...

 Execute and display results of the Module-specific tests for the
 *modulefile*.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When several *modulefiles* are passed, they are evaluated sequentially in the
 specified order. If one modulefile evaluation raises an error, test sequence
 continues.

 .. only:: html or latex

    .. versionadded:: 4.0

.. subcmd:: try-add [options] modulefile...

 See :subcmd:`try-load`.

 .. only:: html or latex

    .. versionadded:: 4.8

.. subcmd:: try-load [options] modulefile...

 Like :subcmd:`load` sub-command, load *modulefile* into the shell
 environment, but do not complain if *modulefile* cannot be found. If
 *modulefile* is found but its evaluation fails, error is still reported.

 :subcmd:`try-load` command accepts the following options:

 * ``--auto|--no-auto``
 * ``-f|--force``
 * ``--tag=taglist``

 Once loaded, the ``loaded`` module tag is associated to the loaded module. If
 module has been automatically loaded by another module, the ``auto-loaded``
 tag is associated instead (see `Module tags`_ section).

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 The :option:`--tag` option accepts a list of module tags to apply to
 *modulefile* once loaded. If module is already loaded, tags from *taglist*
 are added to the list of tags already applied to this module.

 When several *modulefiles* are passed, they are try-loaded sequentially in
 the specified order. If one modulefile evaluation raises an error, try-load
 sequence continues: loaded modules prior the evaluation error are kept loaded
 and sequence is resumed with the load of remaining modulefile in list.
 Conversely, try-load sequence is aborted and already loaded modulefiles are
 withdrawn if :subcmd:`try-load` sub-command is defined in
 :mconfig:`abort_on_error` configuration option and :option:`--force` option
 is not set.

 .. only:: html or latex

    .. versionadded:: 4.8

    .. versionchanged:: 5.1
       Option :option:`--tag` added

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: unload [--auto|--no-auto] [-f] modulefile...

 Remove *modulefile* from the shell environment.

 The parameter *modulefile* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 When the :option:`--force` option is set, unload modulefiles anyway even if
 an evaluation error occurs.

 When several *modulefiles* are passed, they are unloaded sequentially in the
 specified order. If one modulefile evaluation raises an error, unload
 sequence continues: unloaded modules prior the evaluation error are kept
 unloaded and sequence is resumed with the unload of remaining modulefile in
 list. Conversely, unload sequence is aborted and already unloaded modulefiles
 are restored if :subcmd:`unload` sub-command is defined in
 :mconfig:`abort_on_error` configuration option and :option:`--force` option
 is not set.

 .. only:: html or latex

    .. versionchanged:: 4.2
       Options :option:`--auto`, :option:`--no-auto`,
       :option:`--force`/:option:`-f` added

    .. versionchanged:: 5.4
       Support for :mconfig:`abort_on_error` configuration option added

.. subcmd:: unuse directory...

 Remove one or more *directories* from the :envvar:`MODULEPATH` environment
 variable.

 If :mfcmd:`module unuse<module>` is called during a modulefile evaluation,
 the reference counter environment variable
 :envvar:`__MODULES_SHARE_MODULEPATH<__MODULES_SHARE_\<VAR\>>`, which denotes
 the number of times *directory* has been enabled, is checked and *directory*
 is removed only if its relative counter is equal to 1 or not defined.
 Otherwise *directory* is kept and reference counter is decreased by 1. When
 :subcmd:`module unuse<unuse>` is called from the command-line or within an
 initialization modulefile script *directory* is removed whatever the
 reference counter value set.

 If *directory* corresponds to the concatenation of multiple paths separated
 by colon character, each path is treated separately.

 .. only:: html or latex

    .. versionchanged:: 5.0
       *directory* is removed whatever its reference counter value if
       :subcmd:`module unuse<unuse>` is called from the command-line or within
       an initialization modulefile script

    .. versionchanged:: 5.0
       Accept several modulepaths passed as a single string

.. subcmd:: update [-f]

 See :subcmd:`reload`.

 .. only:: html or latex

    .. versionadded:: 5.6

.. subcmd:: use [-a|--append] directory...

 Prepend one or more *directories* to the :envvar:`MODULEPATH` environment
 variable. The ``--append`` flag will append the *directory* to
 :envvar:`MODULEPATH`.

 When *directory* is already defined in :envvar:`MODULEPATH`, it is not added
 again or moved at the end or at the beginning of the environment variable.

 If :mfcmd:`module use<module>` is called during a modulefile evaluation, the
 reference counter environment variable
 :envvar:`__MODULES_SHARE_MODULEPATH<__MODULES_SHARE_\<VAR\>>` is also set to
 increase the number of times *directory* has been added to
 :envvar:`MODULEPATH`. Reference counter is not updated when
 :subcmd:`module use<use>` is called from the command-line or within an
 initialization modulefile script.

 A *directory* that does not exist yet can be specified as argument and then
 be added to :envvar:`MODULEPATH`.

 .. only:: html or latex

    .. versionchanged:: 5.0
       Accept non-existent modulepath

    .. versionchanged:: 5.0
       Reference counter value of *directory* is not anymore increased if
       :subcmd:`module use<use>` is called from the command-line or within an
       initialization modulefile script

.. subcmd:: whatis [-a] [-j] [pattern...]

 Display the information set up by the :mfcmd:`module-whatis` commands inside
 *modulefiles* matching *pattern*. *pattern* may contain wildcard characters.
 If no *pattern* is specified, all :mfcmd:`module-whatis` lines will be shown.

 The parameter *pattern* may also be a symbolic modulefile name or a
 modulefile alias. It may also leverage a specific syntax to finely select
 module version (see `Advanced module version specifiers`_ section below).

 If *pattern* contains variant specification or :ref:`extra specifier`, the
 :ref:`extra match search` process is triggered to collect command information
 used in modulefiles. Modules are included in results only if they match
 *pattern* variant specification and extra specifier. *pattern* may be a bare
 variant specification or extra specifier without mention of a module name.

 .. only:: html or latex

    .. versionchanged:: 4.5
       Option :option:`--json`/:option:`-j` added

    .. versionchanged:: 4.6
       Option :option:`--all`/:option:`-a` added

    .. versionchanged:: 5.3
       *pattern* may include variant specification or extra specifier to
       filter results

    .. versionchanged:: 5.6
       Results from a multi *pattern* search are consolidated under a single
       output


Modulefiles
^^^^^^^^^^^

*modulefiles* are written in the Tool Command Language (Tcl) and are
interpreted by :file:`modulecmd.tcl`. *modulefiles* can use conditional
statements. Thus the effect a *modulefile* will have on the environment
may change depending upon the current state of the environment.

Environment variables are unset when unloading a *modulefile*. Thus, it is
possible to :subcmd:`load` a *modulefile* and then :subcmd:`unload` it without
having the environment variables return to their prior state.


.. _Advanced module version specifiers:

Advanced module version specifiers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the advanced module version specifiers mechanism is enabled (see
:envvar:`MODULES_ADVANCED_VERSION_SPEC`), the specification of modulefile
passed on Modules sub-commands changes. After the module name a version
constraint and variants may be added.

Version specifiers
""""""""""""""""""

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
:envvar:`MODULES_EXTENDED_DEFAULT`) to use an abbreviated notation like ``@1``
to refer to more precise version numbers like ``1.2.3``. Range of versions on
its side natively handles abbreviated versions.

In order to be specified in a range of versions or compared to a range of
versions, the version major element should corresponds to a number. For
instance ``10a``, ``1.2.3``, ``1.foo`` are versions valid for range
comparison whereas ``default`` or ``foo.2`` versions are invalid for range
comparison.

Range of versions can be specified in version list, for instance
``foo@:1.2,1.4:1.6,1.8:``. Such specification helps to exclude specific
versions, like versions ``1.3`` and ``1.7`` in previous example.

If the implicit default mechanism is also enabled (see
:envvar:`MODULES_IMPLICIT_DEFAULT`), a ``default`` and ``latest`` symbolic
versions are automatically defined for each module name (also at each
directory level for deep *modulefiles*). These automatic version symbols are
defined unless a symbolic version, alias, or regular module version already
exists for these ``default`` or ``latest`` version names. Using the
``mod@latest`` (or ``mod/latest``) syntax ensures highest available version
will be selected.

The symbolic version ``loaded`` may be used over loaded module name to
designate the loaded version of the module with associated selected variants.
This version symbol should be specified using the ``@`` prefix notation (e.g.,
``foo@loaded``). An error is returned if no version of designated module is
currently loaded.

.. only:: html or latex

   .. versionadded:: 4.4

   .. versionchanged:: 4.8
      Use of version range is allowed in version list

Variants
""""""""

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

A variant shortcut must be of one character length and must avoid characters
used for other concerns or in module names or version specifications (i.e.,
*[-+~/@=:,a-zA-Z0-9]*).

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

.. _Extra specifier:

Extra specifier
"""""""""""""""

After the module name, extra specifiers can be defined in module search
context. Extra specifiers are an extra query to list available modulefiles
based on their content definition. They rely on the :ref:`Extra match search`
mechanism that collects content of available modulefiles.

Extra specifier can be set with the ``element:name[,name,...]`` syntax where
*element* is a Tcl modulefile command and *name* an item defined by this
command. Depending on the kind of Tcl modulefile command, *name* can refer to
an environment variable, a shell alias, a module specification, etc.

Supported extra specifier *elements* are:

* ``variant``, ``complete``, ``uncomplete``, ``set-alias``, ``unset-alias``,
  ``set-function``, ``unset-function``, ``chdir``, ``tag``
* ``setenv``, ``unsetenv``, ``append-path``, ``prepend-path``, ``remove-path``
  and ``pushenv``: these elements related to environment variable handling may
  also be aliased ``envvar``
* ``family`` and ``provide``: these elements related to module alias may also
  be aliases ``provided-alias``
* ``prereq``, ``prereq-any``, ``prereq-all``, ``depends-on``,
  ``depends-on-any``, ``always-load``, ``load``, ``load-any``, ``try-load``,
  ``switch`` and ``switch-on``: these elements related to module requirement
  definition accept a module specification as value *name* and may be aliased
  ``require``
* ``conflict``, ``unload``, ``switch`` and ``switch-off``: these elements
  related to module incompatibility definition accept a module specification
  as value *name* and may be aliased ``incompat``
* ``use``

Each of the above supported *elements* corresponds to a Tcl modulefile
command. ``load``, ``load-any``, ``try-load``, ``switch``, ``unload`` and
``use`` match corresponding module sub-commands. ``prereq-any`` is an alias on
``prereq``, ``depends-on-any`` and vice versa as both Tcl modulefile commands
are the same. Following the same trend ``prereq-all`` is an alias on
``depends-on`` and vice versa. Regarding ``switch-off`` and ``switch-on``
elements they correspond respectively to the module to unload (if specified)
and the module to load on a ``module switch`` command. ``switch`` is an alias
that matches both ``switch-off`` and ``switch-on`` elements. ``require`` and
``incompat`` *elements* do not match module commands where ``--not-req``
option is set. Setting the ``MODULEPATH`` environment variable with
``append-path`` or ``prepend-path`` commands can be queried with ``use``
element.

When several *names* are set on one *element* criterion (e.g.,
``env:PATH,LD_LIBRARY_PATH``), they act as an *OR* operation. Which means
modules listed in result are those matching any of the *element* *names*
defined.

When several extra specifiers are set on a module search query (e.g.,
``env:PATH env:LD_LIBRARY_PATH``), they act as an *AND* operation. Which means
modules listed in result are those matching all extra specifiers defined.

When an extra specifier is prefixed by ``not:`` (e.g., ``not:env:PATH``), it
acts as a *NOT* operation. Which means modules listed in result are those not
matching the extra specifier defined.

Module specification used as *name* value for some extra specifier *elements*
may leverage :ref:`Advanced module version specifiers` syntax. However if a
module version range or list is implied, it is currently resolved to existing
modules. Thus it may not match modulefile definitions targeting modules that
do not exist. In addition, module aliases and symbolic versions are not
resolved to their target either if set in extra specifier query or in
modulefile definition.

Extra specifier can only be set in a module search context (:subcmd:`avail`,
:subcmd:`spider`, :subcmd:`whatis` and :subcmd:`paths` sub-commands). An error
is raised if used on a module specification query in another context. An error
is also raised if an unknown extra specifier *element* is defined in search
query.

.. only:: html or latex

   .. versionadded:: 5.3

   .. versionchanged:: 5.4
      Extra specifier ``tag`` added

   .. versionchanged:: 5.4
      Multiple names may be set on one extra specifier criterion to select
      modules matching any of these names

   .. versionchanged:: 5.5
      ``not:`` prefix for extra specifier criterion added to select modules
      not matching specified names

   .. versionchanged:: 5.6
      Extra specifiers ``use`` and ``depends-on-any`` added

   .. versionchanged:: 5.6
      Support for :subcmd:`spider` sub-command added

   .. versionchanged:: 5.6
      Extra specifiers ``provide`` and ``provided-alias`` added


.. _Module tags:

Module tags
^^^^^^^^^^^

Module tags are piece of information that can be associated to individual
modulefiles. Tags could be purely informational or may lead to specific
behaviors.

Module tags may be inherited from the module state set by a modulefile command
or consequence of a module action. The inherited tags are:

* ``auto-loaded``: module has been automatically loaded by another module
* ``forbidden``: module has been set *forbidden* through the use of the
  :mfcmd:`module-forbid` command and thus this module cannot be loaded.
* ``hidden``: module has been set *hidden* through the use of the
  :mfcmd:`module-hide` command and thus it is not reported by default among
  the result of :subcmd:`avail` or :subcmd:`spider` sub-commands.
* ``hidden-loaded``: module has been set *hidden once loaded* through the use
  of the :mfcmd:`module-hide --hidden-loaded<module-hide>` command thus it is
  not reported by default among the result of a :subcmd:`list` sub-command.
* ``loaded``: module is currently loaded
* ``nearly-forbidden``: module will soon be *forbidden*, which has been set
  through the use of the :mfcmd:`module-forbid` command. Thus this module
  will soon not be able to load anymore.
* ``warning``: a warning message for the use of the module is set through the
  use of the :mfcmd:`module-warn` command.

Tags may also be associated to modules by using the :mfcmd:`module-tag`
modulefile command. Among tags that could be set this way, some have a special
meaning:

* ``keep-loaded``: auto-loaded module cannot be automatically unloaded. This
  tag is also set through the use of the :mfcmd:`always-load` command.
* ``sticky``: module once loaded cannot be unloaded unless forced or reloaded
  (see `Sticky modules`_ section)
* ``super-sticky``: module once loaded cannot be unloaded unless reloaded,
  module cannot be unloaded even if forced (see `Sticky modules`_ section)

The :option:`--tag` option helps to apply additional tags to modules. It is
available on :subcmd:`load`, :subcmd:`load-any`, :subcmd:`switch` and
:subcmd:`try-load` sub-commands and on :mfcmd:`always-load`,
:mfcmd:`depends-on`, :mfcmd:`depends-on-any`, :mfcmd:`module`,
:mfcmd:`prereq`, :mfcmd:`prereq-all` and :mfcmd:`prereq-any` modulefile
commands. In case the designated module is already loaded, the additional tags
are added to the list of tags already applied to this module.

Module tags are reported along the module they are associated to on
:subcmd:`avail`, :subcmd:`list` and :subcmd:`spider` sub-command results and
also when module's loading, unloading, refreshing or tagging evaluation is
mentioned. Tags could be reported either:

* along the module name, all tags set within angle brackets, each tag
  separated from the others with a colon character (e.g.,
  ``foo/1.2 <tag1:tag2>``).
* graphically rendered over the module name for each tag associated to a
  Select Graphic Rendition (SGR) code in the color palette (see
  :envvar:`MODULES_COLORS`)

When an abbreviated string is associated to a tag name (see
:envvar:`MODULES_TAG_ABBREV`), this abbreviation is used to report tag along
the module name or the tag is graphically rendered over the module name if a
SGR code is associated with tag abbreviation in the color palette. With an
abbreviation set, the SGR code associated to the tag full name is ignored thus
an SGR code should be associated to the abbreviation to get a graphical
rendering of tag. If the abbreviation associated to a tag corresponds to the
empty string, tag is not reported.

Graphical rendering is made over the tag name or abbreviation instead of over
the module name for each tag name or abbreviation set in the
:envvar:`MODULES_TAG_COLOR_NAME` environment variable.

When several tags have to be rendered graphically over the same module name,
each tag is rendered over a sub-part of the module name. In case more tags
need to be rendered than the total number of characters in the module name,
the remaining tags are graphically rendered over the tag name instead of over
the module name.

When the JSON output mode is enabled (with :option:`--json`), tags are
reported by their name under the ``tags`` attribute. Tag abbreviation and
color rendering do not apply on JSON output.

Module tags cannot be used in search query to designate a modulefile.

.. only:: html or latex

   .. versionadded:: 4.7

   .. versionchanged:: 5.1
      Tag ``keep-loaded`` added

   .. versionchanged:: 5.6
      Support for :subcmd:`spider` sub-command added

   .. versionchanged:: 5.6
      Tag ``warning`` added

.. _Sticky modules:

Sticky modules
^^^^^^^^^^^^^^

Modules are said *sticky* when they cannot be unloaded (they stick to the
loaded environment). Two kind of stickiness can be distinguished:

* ``sticky`` module: cannot be unloaded unless if the unload is forced or if
  the module is reloaded after being unloaded or if restoring a collection.
* ``super-sticky`` module: cannot be unloaded unless if the module is reloaded
  after being unloaded; super-sticky modules cannot be unloaded even if the
  unload is forced.

Modules are designated sticky by associating them the ``sticky`` or the
``super-sticky`` :ref:`module tag<Module tags>` with the :mfcmd:`module-tag`
modulefile command.

When stickiness is defined over the generic module name (and not over a
specific module version, a version list or a version range), sticky or
super-sticky module can be swapped by another version of module. For instance
if the ``sticky`` tag is defined over *foo* module, loaded module *foo/1.2*
can be swapped by *foo/2.0*. Such stickiness definition means one version of
module should stay loaded whatever version it is.

When restoring a :ref:`collection<Collections>` or resetting to the initial
environment, sticky modules are unloaded to ensure :subcmd:`restore` or
:subcmd:`reset` sub-commands fully set the environment in target collection or
initial state. Super-sticky modules still cannot be unloaded with
:subcmd:`restore` and :subcmd:`reset` sub-commands.

.. only:: html or latex

   .. versionadded:: 4.7

    .. versionchanged:: 5.2
       Unload sticky modules when restoring a collection or resetting to the
       initial environment


.. _Module variants:

Module variants
^^^^^^^^^^^^^^^

Module variants are alternative evaluation of the same *modulefile*. A variant
is specified by associating a value to its name when designating module.
Variant specification relies on the :ref:`Advanced module version specifiers`
mechanism.

Once specified, variant's value is transmitted to the evaluating *modulefile*
which instantiates the variant in the :mfvar:`ModuleVariant` array variable
when reaching the :mfcmd:`variant` modulefile command declaring this variant.
For instance the ``module load foo/1.2 bar=value1`` command leads to the
evaluation of *foo/1.2* modulefile with *bar=value1* variant specification.
When reaching the ``variant bar value1 value2 value3`` command in modulefile
during its evaluation, the ``ModuleVariant(bar)`` array element is set to
the ``value1`` string.

Once variants are instantiated, modulefile's code could check the variant
values to adapt the evaluation and define for instance different module
requirements or produce different environment variable setup.

Variants are interpreted in contexts where *modulefiles* are evaluated.
Variants specified on module designation are ignored by the
:subcmd:`is-avail` or :subcmd:`path` sub-commands. On search sub-commands
(:subcmd:`avail`, :subcmd:`spider`, :subcmd:`whatis` and :subcmd:`paths`),
variants are interpreted and trigger the :ref:`extra match search` process to
filter results.

When modulefile is evaluated a value should be specified for each variant this
modulefile declares. When reaching the :mfcmd:`variant` modulefile command
declaring a variant, an error is raised if no value is specified for this
variant and if no default value is declared. Specified variant value should
match a value from the declared accepted value list if such list is defined
otherwise an error is raised. Additionally if a variant is specified but does
not correspond to a variant declared in modulefile, an error is raised.

When searching for modules with variants specified in search query, the
:ref:`extra match search` process triggers a specific *scan* modulefile
evaluation. Variants defined in modulefile are collected during this
evaluation then compared to the variants specified in search query. If there
is a match, module is included in search results otherwise it is withdrawn.

When searching for available modules, if one variant is specified multiple
times, matching modules are those providing all specified variant values. For
instance ``bar=value1 bar=value2`` will return modules defining a ``bar``
variant with ``value1`` and ``value2`` as available values. On a module
selection context, only the last specified value is retained. Which means on
previous example that ``bar`` variant is set to ``value2``.

When searching for available modules, multiple values may be set on one
variant criterion, which matches modules that provide any of these variant
values. For instance ``bar=value1,value2`` will return modules defining a
``bar`` variant with either ``value1`` or ``value2`` as available value.

When searching for available modules, ``not:`` prefix may be added on variant
criterion, which matches modules that do not provide these variant values. For
instance ``not:bar=value1`` will return modules not defining a ``bar`` variant
or defining a ``bar`` variant but without ``value1`` among available values.

Module variants are reported along the module they are associated to on
:subcmd:`list` sub-command results. They are also reported on :subcmd:`avail`
and :subcmd:`spider` sub-commands if specified in search query or added to the
element to report in sub-command output (see :option:`--output`/:option:`-o`
option).

Variants are reported within curly braces next to module name, each variant
definition separated from the others with a colon character (e.g.,
``foo/1.2{variant1=value:+variant2}``). Boolean variants are reported with the
``+name`` or ``-name`` syntaxes on :subcmd:`list` sub-command or with the
``name=on,off`` syntax on :subcmd:`avail` and :subcmd:`spider` sub-commands.
When a shortcut character is defined for a variant (see
:envvar:`MODULES_VARIANT_SHORTCUT`) it is reported with the
``<shortcut>value`` syntax. For instance if ``%`` character is defined as a
shortcut for *variant1*: ``foo/1.2{%value:+variant2}``.

When the JSON output mode is enabled (with :option:`--json`), variants are
reported under the ``variants`` JSON object as name/value pairs. Values of
Boolean variant are set as JSON Boolean. Other values are set as JSON strings.
Variant shortcut and color rendering do not apply on JSON output.

.. only:: html or latex

   .. versionadded:: 4.8

   .. versionchanged:: 5.3
      Variants specified in :subcmd:`avail`, :subcmd:`whatis` or
      :subcmd:`paths` search query interpreted to filter results

   .. versionchanged:: 5.4
      Multiple values may be set on one variant search criterion to select
      modules providing any of these variant values

   .. versionchanged:: 5.5
      ``not:`` prefix for variant search criterion added to select modules not
      matching specified variant values

   .. versionchanged:: 5.6
      Variants specified in :subcmd:`spider` search query interpreted to
      filter results

.. _Extra match search:

Extra match search
^^^^^^^^^^^^^^^^^^

Extra match search is a mechanism that evaluates available modulefiles during
a module search to find those matching an extra query or to report additional
information. After selecting modulefiles that match the module name and
version specified in search query, these remaining modulefiles are evaluated
to collect their content.

Extra match search is available on the following module search sub-commands:
:subcmd:`avail`, :subcmd:`spider`, :subcmd:`whatis` and :subcmd:`paths`.

Extra match search is triggered when:

* :ref:`Module variants` and their available values have to be reported in
  avail and spider outputs (see :option:`--output`/:option:`-o` option): extra
  match search is triggered to collect variant information
* Provided module aliases have to be reported in avail and spider outputs (see
  :option:`--output`/:option:`-o` option): extra match search is triggered to
  collect these module aliases defined within modulefiles
* Module variant is specified in search query: extra match search is triggered
  to collect variant information then match them against variant specified in
  query
* :ref:`Extra specifier` is specified in search query: extra match search is
  triggered to collect commands used in modulefiles or modulercs then match
  them against extra specifier query

If search query does not contain an extra query and if variant or provided
alias information should not be reported, no extra match search is performed.
If search query does not contain any module name and version but contains an
extra query or if variant information should be reported, extra match search
is applied to all available modulefiles. If provided alias information should
be reported, extra match search is applied to all available modulefiles even
if search query contains a module specification.

During this specific evaluation, modulefiles are interpreted in *scan* mode.
This mode aims to collect the different Tcl modulefile commands used. Special
care should be given when writing modulefiles to ensure they cope with such
evaluation mode.

Modulefiles tagged *forbidden* are excluded from extra match search
evaluation. Thus they are excluded from result when this mechanism is
triggered.

No *scan* modulefile evaluation is performed if search query is only composed
of ``tag`` extra specifier. Module tags are defined in modulercs thus no
modulefile evaluation is required to get tags applying to a modulefile.

As extra match search implies additional modulefile evaluations, it is advised
to build and use :ref:`Module cache` to improve search speed.

.. only:: html or latex

   .. versionadded:: 5.3

   .. versionchanged:: 5.6
      Support for :subcmd:`spider` sub-command added

   .. versionchanged:: 5.6
      Extra match search triggered when reporting provided module aliases

.. _collections:

Collections
^^^^^^^^^^^

Collections describe a sequence of :subcmd:`module use<use>` then
:subcmd:`module load<load>` commands that are interpreted by
:file:`modulecmd.tcl` to set the user environment as described by this
sequence.

Collections are generated by the :subcmd:`save` sub-command that dumps the
current user environment state in terms of module paths and loaded modules. By
default collections are saved under the :file:`$HOME/.module` directory.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.2   2) bar/2.0   3) qux/3.5
    :ps:`$` module save foo
    :ps:`$` cat $HOME/.module/foo
    module use --append /path/to/modulefiles
    module load foo
    module load bar/2.0
    module load qux/3.5

The content of a collection can also be displayed with the :subcmd:`saveshow`
sub-command. Note that in the above example, bare module name is recorded for
``foo`` modulefile as loaded version is the implicit default. Loaded version
recording can be enforced by enabling :mconfig:`collection_pin_version`
configuration option.

.. parsed-literal::

    :ps:`$` module config collection_pin_version 1
    :ps:`$` module save foo
    :ps:`$` module saveshow foo
    -------------------------------------------------------------------
    :sgrhi:`/home/user/.module/foo`:

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foo/1.2
    :sgrcm:`module` load bar/2.0
    :sgrcm:`module` load qux/3.5

    -------------------------------------------------------------------

When a collection is activated, with the :subcmd:`restore`
sub-command, module paths and loaded modules are unused or unloaded if they
are not part or if they are not ordered the same way as in the collection.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.2   2) bar/2.1   3) qux/3.5
    :ps:`$` module restore foo
    Unloading :sgrhi:`qux/3.5`
    Unloading :sgrhi:`bar/2.1`
    Loading :sgrhi:`bar/2.0`
    Loading :sgrhi:`qux/3.5`
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.2   2) bar/2.0   3) qux/3.5

In the above example, second and third module loaded are changed. First loaded
module is not changed or reloaded as it is the same module between current
environment and collection. As second loaded module was different, this module
and all those loaded afterward are unloaded to then load the sequence
described by collection. As a result, third loaded module is reloaded, even if
is was the same module between current environment and collection.

Existing collections can be listed with :subcmd:`savelist` sub-command. They
can be deleted with :subcmd:`saverm` sub-command.

.. parsed-literal::

    :ps:`$` module savelist
    Named collection list:
     1) default   2) foo
    :ps:`$` module saverm default
    :ps:`$` module savelist
    Named collection list:
     1) foo

When no argument is provided to :subcmd:`save`, :subcmd:`restore`,
:subcmd:`saveshow` or :subcmd:`saverm` sub-commands, the ``default``
collection is assumed.

Collection can also be specified as a full pathname:

.. parsed-literal::

    :ps:`$` module save /path/to/collections/bar
    :ps:`$` module saveshow /path/to/collections/bar
    -------------------------------------------------------------------
    :sgrhi:`/path/to/collections/bar`:

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foo/1.2
    :sgrcm:`module` load bar/2.0
    :sgrcm:`module` load qux/3.5

    -------------------------------------------------------------------

Initial environment
"""""""""""""""""""

Initial environment state, which corresponds to modulepaths enabled and
modules loaded during :ref:`Modules initialization<Package Initialization>`,
is referred as the ``__init__`` collection. This collection is virtual as
its content is stored in the :envvar:`__MODULES_LMINIT` and not in a file. It
can be displayed with :subcmd:`saveshow` and restored with :subcmd:`restore`
sub-command.

.. parsed-literal::

    :ps:`$` module saveshow __init__
    -------------------------------------------------------------------
    :sgrhi:`initial environment`:

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foo/1.2

    -------------------------------------------------------------------

If the ``default`` collection does not exist, :subcmd:`saveshow` and
:subcmd:`restore` sub-commands assume ``__init__`` collection when no argument
provided to them.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.2   2) bar/2.1   3) qux/3.5
    :ps:`$` module savelist
    Named collection list:
     1) foo
    :ps:`$` module restore
    Unloading :sgrhi:`qux/3.5`
    Unloading :sgrhi:`bar/2.1`

Initial environment state can also be restored with the :subcmd:`reset`
sub-command. This sub-command behavior can be changed with
:mconfig:`reset_target_state` configuration option to choose to just purge
loaded modules or to restore a specific collection.

Collection targets
""""""""""""""""""

A collection target can be defined for current environment session with the
:mconfig:`collection_target` configuration option. When set, available
collections are reduced to those suffixed with target name. Which means
:subcmd:`restore`, :subcmd:`saveshow`, :subcmd:`savelist` and :subcmd:`saverm`
only find collections matching currently set target.

.. parsed-literal::

    :ps:`$` module savelist
    Named collection list:
     1) foo
    :ps:`$` module config collection_target mytarget
    :ps:`$` module savelist
    No named collection (for target "mytarget").
    :ps:`$` module restore foo
    :sgrer:`ERROR`: Collection foo (for target "mytarget") cannot be found

When saving a new collection, generated file is suffixed with currently set
target name.

.. parsed-literal::

    :ps:`$` module save bar
    :ps:`$` module savelist
    Named collection list (for target "mytarget"):
     1) bar
    :ps:`$` ls $HOME/.module
    bar.mytarget  foo

Collection targets help to distinguish contexts and make collection reachable
only from the context they have been made for. For instance the same user
account may be used to access different OSes or machine architectures. With a
target set, users are ensured to only access collections built for the context
they are currently connected to. See also :envvar:`MODULES_COLLECTION_TARGET`
section.

Stash collections
"""""""""""""""""

Current user environment can be stashed with :subcmd:`stash` sub-command. When
this sub-command is called, current module environment is saved in a stash
collection then `initial environment`_ is restored.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/1.2   2) qux/4.2
    :ps:`$` module stash
    Unloading :sgrhi:`qux/4.2`

Specific sub-commands are available to handle stash collections:
:subcmd:`stashpop`, :subcmd:`stashlist`, :subcmd:`stashshow`,
:subcmd:`stashrm` and :subcmd:`stashclear`. A stash collection is restored
with :subcmd:`stashpop` which also deletes the collection once restored.

.. parsed-literal::

    :ps:`$` module stashlist
    Stash collection list (for target "mytarget"):
     0) stash-1667669750191
    :ps:`$` module stashpop
    Loading :sgrhi:`qux/4.2`
    :ps:`$` module stashlist
    No stash collection (for target "mytarget").

Stash collections have same format and are saved in the same location than
other collections. Collection target also applies to stash collection.
Creation timestamp is saved in stash collection name.

Stash collection can be designated by their full collection name (i.e.,
*stash-<creation_timestamp>*) or a stash index. Most recent stash
collection has index *0*, *1* is the one before it. When no argument is
provided on stash sub-commands, the latest stash collection is assumed (that
is stash index *0*).

.. parsed-literal::

    :ps:`$` module stashlist
    Stash collection list (for target "mytarget"):
     0) stash-1667669750783   1) stash-1667669750253
    :ps:`$` module stashshow 1
    -------------------------------------------------------------------
    :sgrhi:`/home/user/.module/stash-1667669750253.mytarget:`

    :sgrcm:`module` use --append /path/to/modulefiles
    :sgrcm:`module` load foo/1.2
    :sgrcm:`module` load bar/2.0

    -------------------------------------------------------------------

.. only:: html or latex

   .. versionadded:: 4.0

   .. versionchanged:: 5.2
      Initial environment state introduced

   .. versionchanged:: 5.2
      Stash collection introduced

.. _Site-specific configuration:

Site-specific configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Siteconfig, the site-specific configuration script, is a way to extend
:file:`modulecmd.tcl`. Siteconfig is a Tcl script. Its location is
|file etcdir_siteconfig|.

When :file:`modulecmd.tcl` is invoked it sources siteconfig script if it
exists. Any global variable or procedure of :file:`modulecmd.tcl` can be
redefined in siteconfig.

An additional siteconfig script may be specified through the
:mconfig:`extra_siteconfig` configuration option. The
:envvar:`MODULES_SITECONFIG` environment variable is defined by
:subcmd:`config` sub-command when setting :mconfig:`extra_siteconfig`. If it
exists the extra siteconfig is sourced by :file:`modulecmd.tcl` right after
main siteconfig script.

Hooks
"""""

Siteconfig relies on the ability of the Tcl language to overwrite previously
defined variables and procedures. Sites may deploy their own Tcl code in
siteconfig to adapt :file:`modulecmd.tcl` to their specific needs. The
``trace`` Tcl command may especially be used to define hooks that are run when
entering or leaving a given procedure, or when a variable is read or written.
See :manpage:`trace(n)` man page for detailed information. The following
example setup a procedure that is executed before each modulefile evaluation:

.. code-block:: tcl

    proc beforeEval {cmdstring code result op} {
       # code to run right before each modulefile evaluation
    }
    trace add execution execute-modulefile enter beforeEval

Another possibility is to override the definition of an existing procedure by
first renaming its original version then creating a new procedure that will add
specific code and rely on the renamed original procedure for the rest. See
:manpage:`rename(n)` man page for details. As an example, the following code
adds a new query option to the :mfcmd:`module-info` modulefile command:

.. code-block:: tcl

    rename module-info __module-info
    proc module-info {what {more {}}} {
       switch -- $what {
          platform { return myhost-$::tcl_platform(machine) }
          default { return [__module-info $what $more] }
       }
    }

If a hook procedure needs to execute modulefile commands (for example, to
define environment variables), these commands should be run through the
current modulefile Tcl interpreter. This ensures that the commands behave
consistently with the current modulefile evaluation mode.

.. code-block:: tcl

    proc hook_procedure {value} {
        # get the name of the current modulefile Tcl interpreter
        set modfile_interp [getCurrentModfileInterpName]

        # execute a modulefile command in the current interpreter context
        interp eval $modfile_interp setenv MYVAR $value
    }

Siteconfig hook variables
"""""""""""""""""""""""""

Some Tcl variables can be defined in siteconfig script with special hook
meaning. The following variables are recognized:

.. sitevar:: modulefile_extra_vars

 List of variable names and associated values to setup in modulefile
 evaluation context. These variables can be accessed when modulefile is
 executed. In case code in a modulefile changes the value of such variable,
 its value is reset to the one defined in :sitevar:`modulefile_extra_vars`
 prior the evaluation of the next modulefile.

 .. code-block:: tcl

    set modulefile_extra_vars {myvar 1 othervar {some text}}

 In the above siteconfig example, :sitevar:`modulefile_extra_vars` sets the
 ``myvar`` and ``othervar`` variables in the modulefile evaluation context
 with respectively ``1`` and ``some text`` as value.

 .. only:: html or latex

    .. versionadded:: 5.2

.. sitevar:: modulefile_extra_cmds

 List of command and associated local procedure to setup in modulefile
 evaluation context. These commands can be called from the modulefile to
 execute associated procedure. In case a modulefile changes the definition
 of such command, its definition is bound again on the procedure defined in
 :sitevar:`modulefile_extra_cmds` prior the evaluation of the next modulefile.

 .. code-block:: tcl

    proc mycmd {} {
        # Tcl code
    }
    proc anotherproc {args} {
        # Tcl code
    }
    set modulefile_extra_cmds {mycmd mycmd othercmd anotherproc}

 In the above siteconfig example, :sitevar:`modulefile_extra_cmds` sets the
 ``mycmd`` and ``othercmd`` commands in the modulefile evaluation context and
 bind them respectively to the ``mycmd`` and ``anotherproc`` procedures
 defined in siteconfig script.

 .. only:: html or latex

    .. versionadded:: 5.2

.. sitevar:: modulerc_extra_vars

 List of variable names and associated values to setup in modulerc evaluation
 context. These variables can be accessed when modulerc is executed. In case
 code in a modulerc changes the value of such variable, its value
 is reset to the one defined in :sitevar:`modulerc_extra_vars` prior the
 evaluation of the next modulerc.

 .. code-block:: tcl

    set modulerc_extra_vars {myvar 1 othervar {some text}}

 In the above siteconfig example, :sitevar:`modulerc_extra_vars` sets the
 ``myvar`` and ``othervar`` variables in the modulerc evaluation context with
 respectively ``1`` and ``some text`` as value.

 .. only:: html or latex

    .. versionadded:: 5.2

.. sitevar:: modulerc_extra_cmds

 List of command and associated local procedure to setup in modulerc
 evaluation context. These commands can be called from the modulerc to execute
 associated procedure. In case a modulerc changes the definition of such
 command, its definition is bound again on the procedure defined in
 :sitevar:`modulerc_extra_cmds` prior the evaluation of the next modulerc.

 .. code-block:: tcl

    proc mycmd {} {
        # Tcl code
    }
    proc anotherproc {args} {
        # Tcl code
    }
    set modulerc_extra_cmds {mycmd mycmd othercmd anotherproc}

 In the above siteconfig example, :sitevar:`modulerc_extra_cmds` sets the
 ``mycmd`` and ``othercmd`` commands in the modulerc evaluation context and
 bind them respectively to the ``mycmd`` and ``anotherproc`` procedures
 defined in siteconfig script.


 .. only:: html or latex

    .. versionadded:: 5.2

.. only:: html or latex

   .. versionadded:: 4.1

   .. versionchanged:: 4.3
      Additional site-specific configuration script introduced

.. _Module cache:

Module cache
^^^^^^^^^^^^

To improve module search efficiency, a module cache can be setup in each
modulepath. A module cache is represented by a :file:`.modulecache` file
stored at the root of modulepath directory. This file aggregates contents of
all valid modulercs and modulefiles and issue description of all
non-modulefiles stored in modulepath directory.

When cache file is available, a module search analyzes this file rather
walking through the content of modulepath directory to check if files are
modulefiles or not. Cache file reduces module search processing time
especially when hundreds of modulefiles are available and if these files are
located on busy storage systems. Having one file to read per modulepath rather
walking through a whole directory content extremely reduces the number of
required I/O operations.

When modulefiles or directories in the modulepath are not accessible for
everyone, a *limited access* indication is recorded in cache file rather
content of these modulefiles and content of these directories. When cache file
containing such indication is processed, the limited access modulefiles are
tested to check if they are available to the current running user. Limited
access directories are walked down to find all available modulefiles and
modulercs.

Cache files are generated with :subcmd:`cachebuild` sub-command. This command
has to be run by someone who owns write access in modulepath directory to
create cache file.

Cache files are used any time a module search occurs in modulepaths. They are
analyzed for instance during :subcmd:`avail`, :subcmd:`spider`,
:subcmd:`load`, :subcmd:`display` or :subcmd:`whatis` sub-commands.

Cache files are removed with :subcmd:`cacheclear` sub-command. This command
has to be run by someone who own write access in modulepath directory to
effectively delete cache file.


EXIT STATUS
-----------

The :command:`module` command exits with ``0`` if its execution succeed.
Otherwise ``1`` is returned.


.. _module ENVIRONMENT:

ENVIRONMENT
-----------

.. envvar:: __MODULES_AUTOINIT_INPROGRESS

 If set to ``1``, the :subcmd:`autoinit` sub-command process is skipped.

 This environment variable is set to ``1`` by the :subcmd:`autoinit`
 sub-command after checking it is not set. It ensures no nested initialization
 of Modules occur. At the end of the processing of the :subcmd:`autoinit`
 sub-command, :envvar:`__MODULES_AUTOINIT_INPROGRESS` is unset.

 .. only:: html or latex

    .. versionadded:: 5.0

.. envvar:: __MODULES_LMALTNAME

 A colon separated list of the alternative names set through
 :mfcmd:`module-version` and :mfcmd:`module-alias` statements corresponding to
 all loaded *modulefiles*. Each element in this list starts by the name of the
 loaded *modulefile* followed by all alternative names resolving to it. The
 loaded modulefile and its alternative names are separated by the ampersand
 character.

 Each alternative name stored in :envvar:`__MODULES_LMALTNAME` is prefixed by
 the ``al|`` string if it corresponds to a module alias or prefixed by the
 ``as|`` string if it corresponds to an automatic version symbol. These
 prefixes help to distinguish the different kind of alternative name.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the alternative names matching loaded *modulefiles*
 in order to keep environment consistent when conflicts or pre-requirements
 are set over these alternative designations. It also helps to find a match
 after *modulefiles* being loaded when :subcmd:`unload`, :subcmd:`is-loaded`
 or :subcmd:`info-loaded` actions are run over these names.

 Starting version 4.7 of Modules, :envvar:`__MODULES_LMALTNAME` is also used
 on :subcmd:`list` sub-command to report the symbolic versions associated with
 the loaded modules.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMALTNAME`` to ``__MODULES_LMALTNAME``

.. envvar:: __MODULES_LMCONFLICT

 A colon separated list of the :mfcmd:`conflict` statements defined by all
 loaded *modulefiles*. Each element in this list starts by the name of the
 loaded *modulefile* declaring the conflict followed by the name of all
 modulefiles it declares a conflict with. These loaded modulefiles and
 conflicting modulefile names are separated by the ampersand character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the conflicts declared by the loaded *modulefiles*
 in order to keep environment consistent when a conflicting module is asked
 for load afterward.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMCONFLICT`` to
       ``__MODULES_LMCONFLICT``

.. envvar:: __MODULES_LMEXTRATAG

 A colon separated list of the tags corresponding to all loaded *modulefiles*
 that have been set through the :option:`--tag` option. Each element in this
 list starts by the name of the loaded *modulefile* followed by all explicitly
 set tags applying to it. The loaded modulefile and its tags are separated by
 the ampersand character.

 This environment variable is intended for :command:`module` command internal
 use to distinguish from all tags those that have been specifically set with
 :option:`--tag` option.

 .. only:: html or latex

    .. versionadded:: 5.1

.. envvar:: __MODULES_LMINIT

 A colon separated list describing the modulepaths that have been enabled and
 the *modulefiles* that have been loaded with their tags during :ref:`Modules
 initialization<Package Initialization>`. Each element in this list
 corresponds to a :ref:`collection<collections>` definition line.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the initial loaded state after initialization.

 This initial environment state can then be restored with :subcmd:`reset`
 sub-command. It can also be restored with :subcmd:`restore` sub-command when
 ``__init__`` collection name is specified or when no collection name is
 specified and no *default* collection exists.

 The content of the initial environment can be displayed with
 :subcmd:`saveshow` sub-command when ``__init__`` collection name is specified
 or when no collection name is specified and no *default* collection exists.

 .. only:: html or latex

    .. versionadded:: 5.2

.. envvar:: __MODULES_LMPREREQ

 A colon separated list of the :mfcmd:`prereq` statements defined by all
 loaded *modulefiles*. Each element in this list starts by the name of the
 loaded *modulefile* declaring the pre-requirement followed by the name of all
 modulefiles it declares a :mfcmd:`prereq` with. These loaded modulefiles and
 pre-required modulefile names are separated by the ampersand character. When
 a :mfcmd:`prereq` statement is composed of multiple modulefiles, these
 modulefile names are separated by the pipe character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the pre-requirement declared by the loaded
 *modulefiles* in order to keep environment consistent when a pre-required
 module is asked for unload afterward.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMPREREQ`` to ``__MODULES_LMPREREQ``

.. envvar:: __MODULES_LMPREREQPATH

 A colon separated list of the :mfcmd:`prereq` statements set with a specific
 ``--modulepath`` option defined by all loaded *modulefiles*. Each element in
 this list starts by the name of the loaded *modulefile* declaring the
 pre-requirement followed by the name of all modulefiles it declares a
 :mfcmd:`prereq` with and their specific modulepath. These loaded modulefiles,
 pre-required modulefile names and specific modulepaths set are separated by
 the ampersand character. When a :mfcmd:`prereq` statement is composed of
 multiple modulefiles or multiple specific modulepaths, these names are
 separated by the pipe character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the pre-requirement declared by the loaded
 *modulefiles* in order to keep environment consistent.

 .. only:: html or latex

    .. versionadded:: 5.5

.. envvar:: __MODULES_LMREFRESH

 A colon separated list of the loaded modules that are qualified for refresh
 evaluation. Loaded modules listed in this variable are those defining
 volatile environment changes like shell completion, alias and function.

 .. only:: html or latex

    .. versionadded:: 5.2

.. envvar:: __MODULES_LMSOURCESH

 A colon separated list of the :mfcmd:`source-sh` statements defined by all
 loaded *modulefiles*. Each element in this list starts by the name of the
 loaded *modulefile* declaring the environment changes made by the evaluation
 of :mfcmd:`source-sh` scripts. This name is followed by each
 :mfcmd:`source-sh` statement call and corresponding result achieved in
 modulefile. The loaded modulefile name and each :mfcmd:`source-sh` statement
 description are separated by the ampersand character. The :mfcmd:`source-sh`
 statement call and each resulting modulefile command (corresponding to the
 environment changes done by sourced script) are separated by the pipe
 character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the modulefile commands applied for each
 :mfcmd:`source-sh` command when loading the modulefile. In order to reverse
 these modulefile commands when modulefile is unloaded to undo the environment
 changes.

 .. only:: html or latex

    .. versionadded:: 4.6

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMSOURCESH`` to
       ``__MODULES_LMSOURCESH``

.. envvar:: __MODULES_LMSTICKYRULE

 A colon separated list of the sticky or super-sticky tag definitions applying
 to loaded *modulefiles*. Each element in this list starts by the name of the
 loaded *modulefile* followed by the sticky tag name and the module
 specifications on which the tag applies. These loaded modulefiles and sticky
 tag definitions are separated by the ampersand character. Tag name and module
 specifications on which it applies are separated by the pipe character.

 When stickiness applies specifically to the loaded module name and version,
 sticky rule is not recorded in ``__MODULES_LMSTICKYRULE``.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the stickiness scope when sticky module is changed.

 .. only:: html or latex

    .. versionadded:: 5.4

.. envvar:: __MODULES_LMTAG

 A colon separated list of the tags corresponding to all loaded *modulefiles*
 that have been set through :mfcmd:`module-tag` statements or from other
 modulefile statements like :mfcmd:`module-forbid` (that may apply the
 `nearly-forbidden` tag in specific situation) (see `Module tags`_ section).
 Each element in this list starts by the name of the loaded *modulefile*
 followed by all tags applying to it. The loaded modulefile and its tags are
 separated by the ampersand character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the tags applying to loaded *modulefiles* in order
 to report these tags on :subcmd:`list` sub-command output or to apply
 specific behavior when unloading *modulefile*.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMTAG`` to ``__MODULES_LMTAG``

.. envvar:: __MODULES_LMUSE

 A colon separated list of the modulepaths enabled by all loaded
 *modulefiles*. Each element in this list starts by the name of the loaded
 *modulefile* enabling modulepath followed by all modulepaths it enables.
 These loaded modulefiles and enabled modulepaths are separated by the
 ampersand character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the modulepath enabled by the loaded *modulefiles*
 in order to keep environment consistent when unloading these modules whereas
 modulefiles from the enabled modulepaths are loaded.

 .. only:: html or latex

    .. versionadded:: 5.6

.. envvar:: __MODULES_LMVARIANT

 A colon separated list of the variant instantiated through :mfcmd:`variant`
 statements by all loaded *modulefiles* (see :ref:`Module variants` section).
 Each element in this list starts by the name of the loaded *modulefile*
 followed by all the variant definitions set during the load of this module.
 The loaded modulefile and each of its variant definition are separated by the
 ampersand character. Each variant definition starts with the variant name,
 followed by the variant value set, then a flag to know if variant is of the
 Boolean type and last element in this definition is a flag to know if the
 chosen value is the default one for this variant and if it has been
 automatically set or not. These four elements composing the variant
 definition are separated by the pipe character.

 This environment variable is intended for :command:`module` command internal
 use to get knowledge of the variant value defined by the loaded *modulefiles*
 in order to keep environment consistent when requirements are set over a
 specific variant value or just to report these variant values when listing
 loaded modules.

 .. only:: html or latex

    .. versionadded:: 4.8

    .. versionchanged:: 5.0
       Variable renamed from ``MODULES_LMVARIANT`` to ``__MODULES_LMVARIANT``

.. envvar:: __MODULES_PUSHENV_<VAR>

 Stack of saved values for :envvar:`<VAR>` environment variable. A colon-\
 separated list containing pairs of elements. A pair is formed by a loaded
 module name followed by the value set to :envvar:`<VAR>` in this module with
 :mfcmd:`pushenv` command. An ampersand character separates the two parts of
 the pair.

 First element in list corresponds to the lastly set value of :envvar:`<VAR>`.
 If a value were set to :envvar:`<VAR>` prior the first evaluated
 :mfcmd:`pushenv` command, this value is associated to an empty module name to
 record it as a pair element in :envvar:`__MODULES_PUSHENV_\<VAR\>`.

 .. only:: html or latex

    .. versionadded:: 5.1

.. envvar:: __MODULES_QUAR_<VAR>

 Value of environment variable :envvar:`<VAR>` passed to :file:`modulecmd.tcl`
 in order to restore :envvar:`<VAR>` to this value once started.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       Variable renamed from ``<VAR>_modquar`` to ``__MODULES_QUAR_<VAR>``

.. envvar:: __MODULES_QUARANTINE_SET

 If set to ``1``, restore the environment variables set on hold by the
 quarantine mechanism when starting :file:`modulecmd.tcl` script. This
 variable is automatically defined by Modules shell initialization scripts or
 :command:`module` shell function when they apply the quarantine mechanism.
 (see :envvar:`MODULES_QUARANTINE_SUPPORT`).

 .. only:: html or latex

    .. versionadded:: 5.0

.. envvar:: __MODULES_SHARE_<VAR>

 Reference counter variable for path-like variable :envvar:`<VAR>`. A colon
 separated list containing pairs of elements. A pair is formed by a path
 element followed its usage counter which represents the number of times
 this path has been enabled in variable :envvar:`<VAR>`. A colon separates the
 two parts of the pair.

 An element of a path-like variable is added to the reference counter variable
 as soon as it is added more than one time. When an element of a path-like
 variable is not found in the reference counter variable, it means this
 element has only be added once to the path-like variable.

 When an empty string is added as an element in the path-like variable, it is
 added to the reference counter variable even if added only once to
 distinguish between an empty path-like variable and a path-like variable
 containing an empty string as single element.

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 5.0
       Variable renamed from ``<VAR>_modshare`` to ``__MODULES_SHARE_<VAR>``

    .. versionchanged:: 5.0
       Elements are added to the reference counter variable only if added more
       than one time in the relative path-like variable


.. envvar:: _LMFILES_

 A colon separated list of the full pathname for all loaded *modulefiles*.

 This environment variable is generated by :command:`module` command and
 should not be modified externally.

.. envvar:: LOADEDMODULES

 A colon separated list of all loaded *modulefiles*.

 This environment variable is generated by :command:`module` command and
 should not be modified externally.

.. envvar:: MODULECONTACT

 Email address to contact in case any issue occurs during the interpretation
 of modulefiles.

 This environment variable value supersedes the default value set in the
 :mconfig:`contact` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.0

.. envvar:: MODULEPATH

 The path that the :command:`module` command searches when looking for
 *modulefiles*. Typically, it is set to the main *modulefiles* directory,
 |file modulefilesdir|, by the initialization script. :envvar:`MODULEPATH`
 can be set using :subcmd:`module use<use>` or by the module initialization
 script to search group or personal *modulefile* directories before or after
 the main *modulefile* directory.

 Path elements registered in the :envvar:`MODULEPATH` environment variable may
 contain reference to environment variables which are converted to their
 corresponding value by :command:`module` command each time it looks at the
 :envvar:`MODULEPATH` value. If an environment variable referred in a path
 element is not defined, its reference is converted to an empty string.

.. envvar:: MODULERCFILE

 The location of a global run-command file(s) containing *modulefile* specific
 setup. See `Modulecmd startup`_ section for detailed information.

 Several global run-command files may be defined in this environment variable
 by separating each of them by colon character.

 This environment variable value supersedes the default value set in the
 :mconfig:`rcfile` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

.. envvar:: MODULES_ABORT_ON_ERROR

 A colon separated list of the module sub-commands that abort their evaluation
 sequence when an error is raised by an evaluated module. When error occurs,
 evaluations already done are withdrawn and the remaining modules to evaluate
 are skipped.

 Accepted sub-commands that can be set in value list are:

 * :subcmd:`load`
 * :command:`ml`
 * :subcmd:`mod-to-sh`
 * :subcmd:`purge`
 * :subcmd:`reload`
 * :subcmd:`switch`
 * :subcmd:`switch_unload<switch>`
 * :subcmd:`try-load`
 * :subcmd:`unload`

 Module sub-commands not configured to follow the *abort on error* behavior,
 apply the *continue on error* behavior. In this case if one modulefile
 evaluation fails, sequence continues with remaining modulefiles. When
 :option:`--force` option is used, *continue on error* behavior applies.

 This environment variable value supersedes the default value set in the
 :mconfig:`abort_on_error` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. envvar:: MODULES_ADVANCED_VERSION_SPEC

 If set to ``1``, enable advanced module version specifiers (see `Advanced
 module version specifiers`_ section). If set to ``0``, disable advanced
 module version specifiers.

 This environment variable value supersedes the default value set in the
 :mconfig:`advanced_version_spec` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

.. _MODULES_AUTO_HANDLING:

.. envvar:: MODULES_AUTO_HANDLING

 If set to ``1``, enable automated module handling mode. If set to ``0``
 disable automated module handling mode. Other values are ignored.

 Automated module handling mode consists in additional actions triggered when
 loading or unloading a *modulefile* to satisfy the constraints it declares.
 When loading a *modulefile*, following actions are triggered:

 * Conflict Unload: unload of the *modulefiles* declared as a
   :mfcmd:`conflict` of the loading *modulefile* or if it is the same
   *modulefile* than the one loading but with a different set of variant or
   coming from a different modulepath.

 * Requirement Load: load of the *modulefiles* declared as a :mfcmd:`prereq`
   of the loading *modulefile*.

 * Useless Requirement Unload: unload of the :mfcmd:`prereq` modulefiles that
   have been automatically loaded for either an unloaded conflicting
   modulefile or a modulefile part of this useless requirement unloading
   batch. Modulefiles are added to this unloading batch only if they are not
   required by any other loaded modulefiles and if they are not tagged
   ``keep-loaded``, ``sticky`` or ``super-sticky``.

 * Dependent Reload: reload of the modulefiles declaring a :mfcmd:`prereq`
   onto loading *modulefile* or declaring a :mfcmd:`prereq` or a :ref:`via
   requirement<MODULES_REQUIRE_VIA>` onto a *modulefile* part of this
   reloading batch.

 When unloading a *modulefile*, following actions are triggered:

 * Dependent Unload: unload of the modulefiles declaring a non-optional
   :mfcmd:`prereq` or a :ref:`via requirement<MODULES_REQUIRE_VIA>` onto
   unloaded modulefile or a modulefile part of this unloading batch. A
   :mfcmd:`prereq` modulefile is considered optional if the :mfcmd:`prereq`
   definition order is made of multiple modulefiles and at least one
   alternative modulefile is loaded.

 * Useless Requirement Unload: unload of the :mfcmd:`prereq` modulefiles that
   have been automatically loaded for either the unloaded modulefile, an
   unloaded dependent modulefile or a modulefile part of this useless
   requirement unloading batch. Modulefiles are added to this unloading batch
   only if they are not required by any other loaded modulefiles and if they
   are not tagged ``keep-loaded``, ``sticky`` or ``super-sticky``.

 * Dependent Reload: reload of the modulefiles declaring a :mfcmd:`conflict`
   or an optional :mfcmd:`prereq` onto either the unloaded modulefile, an
   unloaded dependent or an unloaded useless requirement or declaring a
   :mfcmd:`prereq` or a :ref:`via requirement<MODULES_REQUIRE_VIA>` onto a
   modulefile part of this reloading batch.

 In case a loaded *modulefile* has some of its declared constraints
 unsatisfied (pre-required modulefile not loaded or conflicting modulefile
 loaded for instance), this loaded *modulefile* is excluded from the automatic
 reload actions described above.

 For the specific case of the :subcmd:`switch` sub-command, where a modulefile
 is unloaded to then load another modulefile. Dependent modulefiles to Unload
 are merged into the Dependent modulefiles to Reload that are reloaded after
 the load of the switched-to modulefile. Such process also applies to the
 Dependent Unload modulefiles of Conflict Unload modules.

 The reload phase of all Dependent Reload modulefiles occurs after the
 evaluation of the main *modulefile* (either load, unload or switch
 evaluation).

 The reload phase of a Dependent Reload modulefile is skipped if any of the
 following conditions are met:

 * The required modules for this modulefile are not loaded.
 * A conflict is detected with the currently loaded environment.
 * The enabled modulepaths have changed, and the modulefile is no longer
   available.

 However, reload is always attempted if the modulefile is tagged as
 ``super-sticky`` or ``sticky``, and force mode is not enabled. *Abort on
 error* behavior is applied if reload of such module kind fails whatever the
 value of the :mconfig:`abort_on_error` configuration option. Dependent
 Reload modulefiles whose reload has been skipped are treated as Dependent
 Unload modulefiles.

 Conflict Unload mechanism is activated only if :mconfig:`conflict_unload`
 configuration option is also enabled.

 This environment variable value supersedes the default value set on the
 :mconfig:`auto_handling` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--auto` and :option:`--no-auto`
 command line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.1
       Modules with keep-loaded tag set are excluded from Useless Requirement
       Unload mechanism

    .. versionchanged:: 5.5
       Modules with sticky or super-sticky tag set are excluded from Useless
       Requirement Unload mechanism

    .. versionchanged:: 5.5
       Conflict Unload and Useless Requirement Unload mechanisms added on
       module load context

    .. versionchanged:: 5.5
       Reload of a Dependent Reload module is skipped if it is not loadable

    .. versionchanged:: 5.5
       Reload of all Dependent Reload modules occurs after the main evaluation

    .. versionchanged:: 5.6
       *Abort on error* behavior is always applied if reload of a Dependent
       Reload sticky or super-sticky module fails

.. envvar:: MODULES_AVAIL_INDEPTH

 If set to ``1``, enable in depth search results for :subcmd:`avail`
 sub-command. If set to ``0`` disable :subcmd:`avail` sub-command in depth
 mode. Other values are ignored.

 When in depth mode is enabled, modulefiles and directories contained in
 directories matching search query are also included in search results. When
 disabled these modulefiles and directories contained in matching directories
 are excluded.

 This environment variable value supersedes the default value set in the
 :mconfig:`avail_indepth` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--indepth` and
 :option:`--no-indepth` command line switches override this environment
 variable.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_AVAIL_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`avail` sub-command regular output mode.

 Accepted elements that can be set in value list are:

 * ``alias``: module aliases.
 * ``provided-alias``: show module aliases and evaluate all modulefiles to get
   aliases provided by them.
 * ``dirwsym``: directories associated with symbolic versions.
 * ``hidden``: show all hidden modules.
 * ``indesym``: symbolic versions reported independently from the module or
   directory they are attached to.
 * ``key``: legend appended at the end of the output to explain it.
 * ``modulepath``: modulepath names set as header prior the list of available
   modules found in them.
 * ``sym``: symbolic versions associated with available modules.
 * ``tag``: tags associated with available modules.
 * ``variant``: variants and their possible values associated with available
   modules.
 * ``variantifspec``: like ``variant`` but only if a variant has been
   specified in search query.
 * ``via``: mention next to modulepath name which loaded module enables it if
   any.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 In case the ``modulepath`` element is missing from value list, the available
 modules from global/user rc and all enabled modulepaths are reported as a
 single list.

 When ``indesym`` element is set, ``dirwsym`` and ``sym`` elements are
 disabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`avail_output` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The :option:`--output`/:option:`-o` command
 line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.3
       Elements ``variant`` and ``variantifspec`` added

    .. versionchanged:: 5.3.1
       Element ``indesym`` added

    .. versionchanged:: 5.6
       Elements ``hidden``, ``provided-alias`` and ``via`` added

.. envvar:: MODULES_AVAIL_TERSE_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`avail` sub-command terse output mode.

 See :envvar:`MODULES_AVAIL_OUTPUT` to get the accepted elements that can be
 set in value list. Exception for ``via`` element which is not accepted for
 terse output mode.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 This environment variable value supersedes the default value set in the
 :mconfig:`avail_terse_output` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The :option:`--output`/:option:`-o`
 command line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.3
       Elements ``variant`` and ``variantifspec`` added

    .. versionchanged:: 5.6
       Elements ``hidden`` and ``provided-alias`` added

.. envvar:: MODULES_CACHE_BUFFER_BYTES

 Size of the buffer used when reading or writing cache files. Accepted values
 are integers comprised between 4096 and 1000000.

 .. only:: html or latex

    .. versionadded:: 5.3

.. envvar:: MODULES_CACHE_EXPIRY_SECS

 Number of seconds a cache file is considered valid after being generated. For
 example, if set to ``3600`` it means a cache file expires one hour after
 being generated and is then ignored.

 When set to ``0`` cache file never expires. Accepted values are integers
 comprised between 0 (cache files never expire) and 31536000 (equivalent to
 one year duration).

 .. only:: html or latex

    .. versionadded:: 5.3

.. envvar:: MODULES_CMD

 The location of the active module command script.

 This environment variable is generated by :command:`module` command and
 should not be modified externally.

 .. only:: html or latex

    .. versionadded:: 4.1

.. envvar:: MODULES_COLLECTION_PIN_VERSION

 If set to ``1``, register exact version number of modulefiles when saving a
 collection. Otherwise modulefile version number is omitted if it corresponds
 to the explicitly set default version and also to the implicit default when
 the configuration option :mconfig:`implicit_default` is enabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`collection_pin_version` configuration option. It can be defined
 with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

.. envvar:: MODULES_COLLECTION_PIN_TAG

 If set to ``1``, register all tags applying to modulefiles when saving a
 collection. Otherwise only the extra tags set through the :option:`--tag`
 option and tags resulting from specific module states (like ``auto-loaded``
 and ``keep-loaded`` tags) are recorded in collection. Note that the
 ``nearly-forbidden`` tag due to its temporal meaning is not saved in
 collection even when this configuration option is enabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`collection_pin_tag` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.1

.. envvar:: MODULES_COLLECTION_TARGET

 The collection target that determines what collections are valid thus
 reachable on the current system.

 Collection directory may sometimes be shared on multiple machines which may
 use different modules setup. For instance modules users may access with the
 same :envvar:`HOME` directory multiple systems using different OS versions.
 When it happens a collection made on machine 1 may be erroneous on machine 2.

 When a target is set, only the collections made for that target are
 available to the :subcmd:`restore`, :subcmd:`savelist`, :subcmd:`saveshow`,
 :subcmd:`saverm`, :subcmd:`stash`, :subcmd:`stashpop`, :subcmd:`stashlist`,
 :subcmd:`stashshow`, and :subcmd:`stashrm` sub-commands. Saving a collection
 registers the target footprint by suffixing the collection filename with
 ``.$MODULES_COLLECTION_TARGET``. The collection target is not involved when
 collection is specified as file path on the :subcmd:`saveshow`,
 :subcmd:`restore` and :subcmd:`save` sub-commands.

 For example, the :envvar:`MODULES_COLLECTION_TARGET` variable may be set with
 results from commands like :command:`lsb_release`, :command:`hostname`,
 :command:`dnsdomainname`, etc.

 This environment variable value supersedes the default value set in the
 :mconfig:`collection_target` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.0

.. envvar:: MODULES_COLOR

 Defines if output should be colored or not. Accepted values are ``never``,
 ``auto`` and ``always``.

 When color mode is set to ``auto``, output is colored only if the standard
 error output channel is attached to a terminal.

 This environment variable value supersedes the default value set in the
 :mconfig:`color` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--color` command line switch
 overrides this environment variable.

 :envvar:`NO_COLOR`, :envvar:`CLICOLOR` and :envvar:`CLICOLOR_FORCE`
 environment variables are also honored to define color mode. The ``never``
 mode is set if :envvar:`NO_COLOR` is defined (regardless of its value) or if
 :envvar:`CLICOLOR` equals to ``0``. If :envvar:`CLICOLOR` is set to another
 value, it corresponds to the ``auto`` mode. The ``always`` mode is set if
 :envvar:`CLICOLOR_FORCE` is set to a value different than ``0``.
 :envvar:`NO_COLOR` variable prevails over :envvar:`CLICOLOR` and
 :envvar:`CLICOLOR_FORCE`. Color mode set with these three variables is
 superseded by mode set with :envvar:`MODULES_COLOR` environment variable or
 with :option:`--color` command line switch..

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_COLORS

 Specifies the colors and other attributes used to highlight various parts of
 the output. Its value is a colon-separated list of output items associated to
 a Select Graphic Rendition (SGR) code. It follows the same syntax than
 :envvar:`LS_COLORS`.

 Output items are designated by keys. Items able to be colorized are:
 highlighted element (``hi``), debug information (``db``), trace information
 (``tr``), tag separator (``se``); Error (``er``), warning (``wa``), module
 error (``me``) and info (``in``) message prefixes; Modulepath (``mp``),
 directory (``di``), module alias (``al``), module variant (``va``), module
 symbolic version (``sy``), module ``default`` version (``de``) and modulefile
 command (``cm``).

 `Module tags`_ can also be colorized. The key to set in the color palette to
 get a graphical rendering of a tag is the tag name or the tag abbreviation if
 one is defined for tag. The SGR code applied to a tag name is ignored if an
 abbreviation is set for this tag thus the SGR code should be defined for this
 abbreviation to get a graphical rendering. Each basic tag has by default a
 key set in the color palette, based on its abbreviated string: auto-loaded
 (``aL``), forbidden (``F``), hidden and hidden-loaded (``H``), loaded
 (``L``), nearly-forbidden (``nF``), sticky (``S``), super-sticky (``sS``),
 keep-loaded (``kL``) and warning (``W``).

 See the Select Graphic Rendition (SGR) section in the documentation of the
 text terminal that is used for permitted values and their meaning as
 character attributes. These substring values are integers in decimal
 representation and can be concatenated with semicolons. Modules takes care of
 assembling the result into a complete SGR sequence (``\33[...m``). Common
 values to concatenate include ``1`` for bold, ``4`` for underline, ``30`` to
 ``37`` for foreground colors and ``90`` to ``97`` for 16-color mode
 foreground colors. See also https://en.wikipedia.org/wiki/ANSI_escape_code#Select_Graphic_Rendition_parameters
 for a complete SGR code reference.

 No graphical rendition will be applied to an output item that could normally
 be colored but which is not defined in the color set. Thus if
 :envvar:`MODULES_COLORS` is defined empty, no output will be colored at all.

 This environment variable value supersedes the default value set in the
 :mconfig:`colors` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 4.6
       Output item for trace information (``tr``) added

    .. versionchanged:: 4.7
       Output items for module tags auto-loaded (``aL``), forbidden (``F``),
       hidden and hidden-loaded (``H``), loaded (``L``), nearly-forbidden
       (``nF``), sticky (``S``) and super-sticky (``sS``) added

    .. versionchanged:: 4.8
       Output item for module variant (``va``) added

    .. versionchanged:: 5.1
       Output item for keep-loaded module tag (``kL``) added

    .. versionchanged:: 5.6
       Output item for warning module tag (``W``) added

.. envvar:: MODULES_CONFLICT_UNLOAD

 If set to ``1``, enable automated unload of conflicting modules when loading
 a module. If set to ``0``, disable this automated conflict unload mechanism.

 Conflict Unload is a mechanism part of the :ref:`automated module handling
 mode<MODULES_AUTO_HANDLING>`. To activate this mechanism,
 :mconfig:`auto_handling` configuration option should also be enabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`conflict_unload` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. envvar:: MODULES_EDITOR

 Text editor command name or path for use to open modulefile through the
 :subcmd:`edit` sub-command.

 This environment variable value supersedes the default value set in the
 :mconfig:`editor` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 Text editor could also be defined through the :envvar:`VISUAL` or
 :envvar:`EDITOR` environment variables. These environment variables are
 overridden by :envvar:`MODULES_EDITOR`.

 .. only:: html or latex

    .. versionadded:: 4.8

.. envvar:: MODULES_EXTENDED_DEFAULT

 If set to ``1``, a specified module version is matched against starting
 portion of existing module versions, where portion is a substring separated
 from the rest of the version string by a ``.`` character. For example
 specified modules ``mod/1`` and ``mod/1.2`` will match existing modulefile
 ``mod/1.2.3``.

 In case multiple modulefiles match the specified module version and a single
 module has to be selected, the explicitly set default version is returned if
 it is part of matching modulefiles. Otherwise the implicit default among
 matching modulefiles is returned if defined (see
 :envvar:`MODULES_IMPLICIT_DEFAULT` section)

 This environment variable value supersedes the default value set in the
 :mconfig:`extended_default` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

.. envvar:: MODULES_FAMILY_<NAME>

 Module name minus version that provides for the *name* family in currently
 loaded environment. This environment variable is defined through the use of
 the :mfcmd:`family` modulefile command.

 For instance if loading modulefile ``foo/1.0`` defines being member of the
 ``bar`` family, the :envvar:`MODULES_FAMILY_BAR<MODULES_FAMILY_\<NAME\>>`
 will be set to the ``foo`` value.

 This environment variable is generated by :command:`module` command and
 should not be modified externally.

 .. only:: html or latex

    .. versionadded:: 5.1

.. envvar:: MODULES_HIDE_AUTO_LOADED

 If set to ``1``, tag automatically loaded modules ``hidden-loaded``. These
 modules will not appear on :subcmd:`list` sub-command unless :option:`--all`
 option is set.

 This environment variable value supersedes the default value set in the
 :mconfig:`hide_auto_loaded` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. envvar:: MODULES_ICASE

 When module specification are passed as argument to module sub-commands or
 modulefile Tcl commands, defines the case sensitiveness to apply to match
 them. When :envvar:`MODULES_ICASE` is set to ``never``, a case sensitive
 match is applied in any cases. When set to ``search``, a case insensitive
 match is applied to the :subcmd:`avail`, :subcmd:`list`, :subcmd:`whatis`,
 :subcmd:`paths`, :subcmd:`savelist` and :subcmd:`spider` sub-commands. When
 set to ``always``, a case insensitive match is also applied to the other
 module sub-commands and modulefile Tcl commands for the module specification
 they receive as argument.

 This environment variable value supersedes the default value set in the
 :mconfig:`icase` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--icase`/:option:`-i` command line
 switches, which correspond to the ``always`` mode, override this environment
 variable.

 .. only:: html or latex

    .. versionadded:: 4.4

    .. versionchanged:: 5.1
       Search mode applied to :subcmd:`list` sub-command

    .. versionchanged:: 5.2
       Search mode applied to :subcmd:`savelist` sub-command

    .. versionchanged:: 5.6
       Search mode applied to :subcmd:`spider` sub-command

.. envvar:: MODULES_IGNORE_CACHE

 Ignore (if set to ``1``) or not (if set to ``0``) module cache.

 This environment variable value supersedes the default value set in the
 :mconfig:`ignore_cache` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--ignore-cache` command line
 switch overrides this environment variable.

 .. only:: html or latex

    .. versionadded:: 5.3

.. envvar:: MODULES_IGNORE_USER_RC

 Skip evaluation (if set to ``1``) or not (if set to ``0``) of user-specific
 module rc file (:file:`$HOME/.modulerc`).

 This environment variable value supersedes the default value set in the
 :mconfig:`ignore_user_rc` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--ignore-user-rc` command line
 switch overrides this environment variable.

 .. only:: html or latex

    .. versionadded:: 5.3

.. envvar:: MODULES_IMPLICIT_DEFAULT

 Defines (if set to ``1``) or not (if set to ``0``) an implicit default
 version for modules without a default version explicitly defined (see
 :ref:`Locating Modulefiles` section in the :ref:`modulefile(5)` man page).

 Without either an explicit or implicit default version defined a module must
 be fully qualified (version should be specified in addition to its name) to
 get:

 * targeted by module :subcmd:`load`, :subcmd:`switch`, :subcmd:`display`,
   :subcmd:`help`, :subcmd:`test` and :subcmd:`path` sub-commands.

 * restored from a collection, unless already loaded in collection-specified
   order.

 * automatically loaded by :ref:`automated module handling
   mechanisms<MODULES_AUTO_HANDLING>` when declared as module requirement,
   with :mfcmd:`prereq` or :mfcmd:`module load<module>` modulefile commands.

 An error is returned in the above situations if either no explicit or
 implicit default version is defined.

 This environment variable value supersedes the default value set in the
 :mconfig:`implicit_default` configuration option. It can be defined with the
 :subcmd:`config` sub-command. This environment variable is ignored if
 :mconfig:`implicit_default` has been declared locked in
 :mconfig:`locked_configs` configuration option.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_IMPLICIT_REQUIREMENT

 Defines (if set to ``1``) or not (if set to ``0``) an implicit prereq or
 conflict requirement onto modules specified respectively on
 :mfcmd:`module load<module>` or :mfcmd:`module unload<module>` commands in
 modulefile. When enabled an implicit conflict requirement onto switched-off
 module and a prereq requirement onto switched-on module are also defined for
 :mfcmd:`module switch <module>` commands used in modulefile.

 This environment variable value supersedes the default value set in the
 :mconfig:`implicit_requirement` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The ``--not-req`` option, applied to a
 :mfcmd:`module` command in a modulefile, overrides this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_LIST_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`list` sub-command regular output mode.

 Accepted elements that can be set in value list are:

 * ``alias``: module aliases targeting loaded modules.
 * ``header``: sentence to introduce the list of loaded modules or to state
   that no modules are loaded currently.
 * ``hidden``: show hidden loaded modules.
 * ``idx``: index position of each loaded module.
 * ``indesym``: symbolic versions reported independently from the loaded
   module they are attached to.
 * ``key``: legend appended at the end of the output to explain it.
 * ``variant``: variant values selected for loaded modules.
 * ``sym``: symbolic versions associated with loaded modules.
 * ``tag``: tags associated with loaded modules.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 This environment variable value supersedes the default value set in the
 :mconfig:`list_output` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--output`/:option:`-o` command
 line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 4.8
       Element ``variant`` added

    .. versionchanged:: 5.4
       Elements ``alias`` and ``indesym`` added

    .. versionchanged:: 5.6
       Element ``hidden`` added

.. envvar:: MODULES_LIST_TERSE_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`list` sub-command terse output mode.

 See :envvar:`MODULES_LIST_OUTPUT` to get the accepted elements that can be
 set in value list.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 This environment variable value supersedes the default value set in the
 :mconfig:`list_terse_output` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--output`/:option:`-o` command
 line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 4.8
       Element ``variant`` added

    .. versionchanged:: 5.4
       Elements ``alias`` and ``indesym`` added

    .. versionchanged:: 5.6
       Element ``hidden`` added

.. envvar:: MODULES_LOGGED_EVENTS

 A colon separated list of the events to log. Accepted events that can be set
 in value list are:

 * ``auto_eval``: log automatically triggered modulefile evaluations
 * ``requested_eval``: log modulefile evaluations directly requested by user
 * ``requested_cmd``: log module commands directly requested by user

 This environment variable value supersedes the default value set in the
 :mconfig:`logged_events` configuration option. It can be defined with the
 :subcmd:`config` sub-command. This environment variable is ignored if
 :mconfig:`logged_events` has been declared locked in
 :mconfig:`locked_configs` configuration option.

 .. only:: html or latex

    .. versionadded:: 5.5

.. envvar:: MODULES_LOGGER

 Command to log informational messages. The value of this variable is composed
 of a logger command name or path eventually followed by command-line options.

 This environment variable value supersedes the default value set in the
 :mconfig:`logger` configuration option. It can be defined with the
 :subcmd:`config` sub-command. This environment variable is ignored if
 :mconfig:`logger` has been declared locked in :mconfig:`locked_configs`
 configuration option.

 If :envvar:`MODULES_LOGGER` variable is set to an empty string, logger
 will not be launched.

 .. only:: html or latex

    .. versionadded:: 5.5

.. envvar:: MODULES_MCOOKIE_CHECK

 If set to ``eval``, the Modules magic cookie (i.e., ``#%Module``
 file signature) is only checked to determine if a file is a modulefile when
 evaluating these files. If set to ``always``, the Modules magic cookie is
 also checked when searching for modules.

 The ``eval`` mode is made to significantly reduce file checks when walking
 through modulepaths to search for *modulefiles*. Special care should be given
 to the content of modulepaths when this ``eval`` mode is set as the following
 kind of files are included in search results:

 * *modulefiles* with a magic cookie requiring a higher version of
   :file:`modulecmd.tcl`
 * files not beginning with the magic cookie ``#%Module``
 * read-protected files

 When a :ref:`module cache<Module cache>` file is available for a given
 modulepath, ``eval`` mode is not applied as cache content is generated in
 ``always`` mode.

 This environment variable value supersedes the default value set in the
 :mconfig:`mcookie_check` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.1

.. envvar:: MODULES_MCOOKIE_VERSION_CHECK

 If set to ``1``, the version set in the Modules magic cookie in modulefile
 is checked against the current version of :file:`modulecmd.tcl` to determine
 if the modulefile can be evaluated.

 When a :ref:`module cache<Module cache>` file is available for a given
 modulepath, version check is considered enabled as cache content is generated
 in this mode.

 This environment variable value supersedes the default value set in the
 :mconfig:`mcookie_version_check` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_ML

 If set to ``1``, define :command:`ml` command when initializing Modules (see
 `Package Initialization`_ section). If set to ``0``, :command:`ml` command is
 not defined.

 This environment variable value supersedes the default value set in the
 :mconfig:`ml` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 To enable or disable :command:`ml` command, :envvar:`MODULES_ML` should be set
 prior Modules initialization or the :mconfig:`ml` configuration option should
 be set in the :file:`initrc` configuration file.

 .. only:: html or latex

    .. versionadded:: 4.5

.. envvar:: MODULES_NEARLY_FORBIDDEN_DAYS

 Number of days a module is considered *nearly forbidden* prior reaching its
 expiry date set by :mfcmd:`module-forbid` modulefile command. When a *nearly
 forbidden* module is evaluated a warning message is issued to inform module
 will soon be forbidden. If set to ``0``, modules will never be considered
 *nearly forbidden*. Accepted values are integers comprised between 0 and 365.

 This environment variable value supersedes the default value set in the
 :mconfig:`nearly_forbidden_days` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.6

.. envvar:: MODULES_NON_EXPORTABLE_TAGS

 A colon separated list of tags that should not be exported to the module once
 it is loaded.

 This environment variable value supersedes the default value set in the
 :mconfig:`non_exportable_tags` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.7

.. envvar:: MODULES_PAGER

 Text viewer for use to paginate message output. The value of this variable is
 composed of a pager command name or path eventually followed by command-line
 options. See :envvar:`MODULES_PAGINATE` to learn how pagination is enabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`pager` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.5
       No pager when :file:`modulecmd.tcl` is run for scripting languages

.. envvar:: MODULES_PAGINATE

 If set to ``1``, output of module command is piped into defined pager
 command. See :envvar:`MODULES_PAGER` variable for pager command definition.

 Pagination is automatically disabled in the following situations:

 * :envvar:`MODULES_PAGER` variable is set to an empty string or to the value
   ``cat``.
 * :file:`modulecmd.tcl` program is run for scripting language rather shells.
 * :file:`modulecmd.tcl` error output stream is not attached to a terminal.
 * :subcmd:`clear` or :subcmd:`edit` sub-commands are run.

 The :envvar:`MODULES_PAGINATE` environment variable value supersedes the
 default value set in the :mconfig:`paginate` configuration option. It can be
 defined with the :subcmd:`config` sub-command. The
 :option:`--paginate`/:option:`-p` and :option:`--no-pager`/:option:`-P`
 command line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 5.7

.. envvar:: MODULES_PATH_ENTRY_REORDER

 This environment variable changes the behavior of :mfcmd:`prepend-path`,
 :mfcmd:`append-path` and :mfcmd:`module use<module>` modulefile commands and
 sub-commands.
 
 If set to ``1``, and one of these commands targets a path entry that already
 exists in the environment variable, the entry is moved to the beginning or
 end (depending on the command), unless duplicates are allowed. If set to
 ``0``, the environment variable is not modified when the entry already
 exists.

 .. parsed-literal::

     :ps:`$` module config path_entry_reorder 0
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

 .. only:: html or latex

    .. versionadded:: 5.7

.. envvar:: MODULES_PROTECTED_ENVVARS

 A colon separated list of environment variable names that should not be
 modified by any modulefile command.

 Prevents modifications by :mfcmd:`append-path`, :mfcmd:`prepend-path`,
 :mfcmd:`remove-path`, :mfcmd:`setenv` and :mfcmd:`unsetenv`. When these
 modulefile commands attempt to modify a protected environment variable,
 a warning message is emitted and modification is ignored.

 This environment variable value supersedes the default value set in the
 :mconfig:`protected_envvars` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.2

.. envvar:: MODULES_QUARANTINE_SUPPORT

 If set to ``1``, produces the shell code for quarantine mechanism when the
 :subcmd:`autoinit` sub-command generates the :command:`module` shell
 function.

 The generated shell code for quarantine mechanism indirectly passes the
 environment variable defined in :envvar:`MODULES_RUN_QUARANTINE` to the
 :file:`modulecmd.tcl` script to protect its run-time environment from
 side-effect coming from the current definition of these variables.

 To enable quarantine support, :envvar:`MODULES_QUARANTINE_SUPPORT` should be
 set to ``1`` prior Modules initialization or the
 :mconfig:`quarantine_support` configuration should be set to ``1`` in the
 :file:`initrc` configuration file.

 Generated code for quarantine mechanism sets the
 :envvar:`__MODULES_QUARANTINE_SET` environment variable when calling the
 :file:`modulecmd.tcl` script to make it restore the environment variable put
 in quarantine.

 This environment variable value supersedes the default value set in the
 :mconfig:`quarantine_support` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.0

.. envvar:: MODULES_REDIRECT_OUTPUT

 If set to ``0``, the output generated by module command is kept on stderr and
 not redirected to stdout channel.

 This environment variable value supersedes the default value set in the
 :mconfig:`redirect_output` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The :option:`--redirect` and
 :option:`--no-redirect` command line switches override this environment
 variable.

 .. only:: html or latex

    .. versionadded:: 5.1

.. _MODULES_REQUIRE_VIA:

.. envvar:: MODULES_REQUIRE_VIA

 If set to ``1``, consider loaded module that enables a modulepath (through
 the use of the modulefile commands :mfcmd:`module use<module>`,
 :mfcmd:`append-path MODULEPATH<append-path>`, or :mfcmd:`prepend-path
 MODULEPATH<prepend-path>`) a requirement for loaded modules stored in this
 modulepath. If set to ``0``, no dependency is made between these modules.

 This environment variable value supersedes the default value set in the
 :mconfig:`require_via` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. envvar:: MODULES_RESET_TARGET_STATE

 Defines behavior of :subcmd:`reset` sub-command. When set to ``__init__``,
 initial environment is restored. When set to ``__purge__``, :subcmd:`reset`
 performs a :subcmd:`purge` sub-command. Any other value designates a name
 collection to :subcmd:`restore`.

 This environment variable value supersedes the default value set in the
 :mconfig:`reset_target_state` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.2

.. envvar:: MODULES_RUN_QUARANTINE

 A space separated list of environment variable names that should be passed
 indirectly to :file:`modulecmd.tcl` to protect its run-time environment from
 side-effect coming from their current definition.

 If the quarantine mechanism has been included in :command:`module` shell
 function (see :envvar:`MODULES_QUARANTINE_SUPPORT`), each variable found in
 :envvar:`MODULES_RUN_QUARANTINE` will have its value emptied or set to the
 value of the corresponding :envvar:`MODULES_RUNENV_\<VAR\>` variable when
 defining :file:`modulecmd.tcl` run-time environment.

 Original values of these environment variables set in quarantine are passed
 to :file:`modulecmd.tcl` via :envvar:`__MODULES_QUAR_\<VAR\>` variables.

 This environment variable value supersedes the default value set in the
 :mconfig:`run_quarantine` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

.. envvar:: MODULES_RUNENV_<VAR>

 Value to set to environment variable :envvar:`<VAR>` for
 :file:`modulecmd.tcl` run-time execution if :envvar:`<VAR>` is referred in
 :envvar:`MODULES_RUN_QUARANTINE`.

 .. only:: html or latex

    .. versionadded:: 4.1

.. envvar:: MODULES_SEARCH_MATCH

 When searching for modules with :subcmd:`avail`, :subcmd:`list`,
 :subcmd:`spider` or collections with :subcmd:`savelist` sub-commands, defines
 the way query string should match against available module/collection names.
 With ``starts_with`` value, returned modules/collections are those whose
 name begins by search query string. When set to ``contains``, any
 modules/collections whose fully qualified name contains search query string
 are returned.

 This environment variable value supersedes the default value set in the
 :mconfig:`search_match` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--starts-with` and
 :option:`--contains` command line switches override this environment
 variable.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.1
       Support for :subcmd:`list` sub-command added

    .. versionchanged:: 5.2
       Support for :subcmd:`savelist` sub-command added

    .. versionchanged:: 5.6
       Support for :subcmd:`spider` sub-command added

.. envvar:: MODULES_SET_SHELL_STARTUP

 If set to ``1``, defines when :command:`module` command initializes the shell
 startup file to ensure that the :command:`module` command is still defined in
 sub-shells. Setting shell startup file means defining the :envvar:`ENV` and
 :envvar:`BASH_ENV` environment variable to the Modules bourne shell
 initialization script. If set to ``0``, shell startup file is not defined.

 This environment variable value supersedes the default value set in the
 :mconfig:`set_shell_startup` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 To enable shell startup file, :envvar:`MODULES_SET_SHELL_STARTUP` should be
 set to ``1`` prior Modules initialization or the :mconfig:`set_shell_startup`
 configuration option should be set to ``1`` in the :file:`initrc`
 configuration file.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_SHELLS_WITH_KSH_FPATH

 A list of shell on which the :envvar:`FPATH` environment variable should be
 defined at initialization time to point to the :file:`ksh-functions`
 directory where the ksh initialization script for module command is located.
 It enables for the listed shells to get module function defined when starting
 ksh as sub-shell from there.

 Accepted values are a list of shell among *sh*, *bash*, *csh*, *tcsh* and
 *fish* separated by colon character (``:``).

 This environment variable value supersedes the default value set in the
 :mconfig:`shells_with_ksh_fpath` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 To enable the setup of :envvar:`FPATH` for some shells,
 :envvar:`MODULES_SHELLS_WITH_KSH_FPATH` should be set to the list of these
 shells prior Modules initialization or the :mconfig:`shells_with_ksh_fpath`
 configuration option should be set to the list of these shells in the
 :file:`initrc` configuration file.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_SILENT_SHELL_DEBUG

 If set to ``1``, disable any ``xtrace`` or ``verbose`` debugging property set
 on current shell session for the duration of either the :command:`module`
 command or the module shell initialization script. Only applies to Bourne
 Shell (sh) and its derivatives.

 This environment variable value supersedes the default value set in the
 :mconfig:`silent_shell_debug` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 To generate the code to silence shell debugging property in the
 :command:`module` shell function, :envvar:`MODULES_SILENT_SHELL_DEBUG` should
 be set to ``1`` prior Modules initialization or the
 :mconfig:`silent_shell_debug` configuration option should be set to ``1`` in
 the :file:`initrc` configuration file.

 .. only:: html or latex

    .. versionadded:: 4.1

.. envvar:: MODULES_SITECONFIG

 Location of a site-specific configuration script to source into
 :file:`modulecmd.tcl`. See :ref:`Site-specific configuration` section for
 details.

 This environment variable value supersedes the default value set in the
 :mconfig:`extra_siteconfig` configuration option. It can be defined with the
 :subcmd:`config` sub-command. This environment variable is ignored if
 :mconfig:`extra_siteconfig` has been declared locked in
 :mconfig:`locked_configs` configuration option.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_SOURCE_CACHE

 If set to ``1``, cache content of files evaluated in modulefile through
 :manpage:`source(n)` Tcl command. When same file is sourced multiple times,
 cached content is reused rather reading file again.

 This environment variable value supersedes the default value set in the
 :mconfig:`source_cache` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. envvar:: MODULES_SPIDER_INDEPTH

 If set to ``1``, enable in depth search results for :subcmd:`spider`
 sub-command. If set to ``0`` disable :subcmd:`spider` sub-command in depth
 mode. Other values are ignored.

 When in depth mode is enabled, modulefiles and directories contained in
 directories matching search query are also included in search results. When
 disabled these modulefiles and directories contained in matching directories
 are excluded.

 This environment variable value supersedes the default value set in the
 :mconfig:`spider_indepth` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--indepth` and
 :option:`--no-indepth` command line switches override this environment
 variable.

 .. only:: html or latex

    .. versionadded:: 5.6

.. envvar:: MODULES_SPIDER_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`spider` sub-command regular output mode.

 Accepted elements that can be set in value list are:

 * ``alias``: module aliases.
 * ``provided-alias``: show module aliases and evaluate all modulefiles to get
   aliases provided by them.
 * ``dirwsym``: directories associated with symbolic versions.
 * ``hidden``: show all hidden modules.
 * ``indesym``: symbolic versions reported independently from the module or
   directory they are attached to.
 * ``key``: legend appended at the end of the output to explain it.
 * ``modulepath``: modulepath names set as header prior the list of available
   modules found in them.
 * ``sym``: symbolic versions associated with available modules.
 * ``tag``: tags associated with available modules.
 * ``variant``: variants and their possible values associated with available
   modules.
 * ``variantifspec``: like ``variant`` but only if a variant has been
   specified in search query.
 * ``via``: mention next to modulepath name which module enables it if any.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 In case the ``modulepath`` element is missing from value list, the available
 modules from global/user rc and all enabled modulepaths are reported as a
 single list.

 When ``indesym`` element is set, ``dirwsym`` and ``sym`` elements are
 disabled.

 This environment variable value supersedes the default value set in the
 :mconfig:`spider_output` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The :option:`--output`/:option:`-o` command
 line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 5.6

.. envvar:: MODULES_SPIDER_TERSE_OUTPUT

 A colon separated list of the elements to report in addition to module names
 on :subcmd:`spider` sub-command terse output mode.

 See :envvar:`MODULES_SPIDER_OUTPUT` to get the accepted elements that can be
 set in value list. Exception for ``via`` element which is not accepted for
 terse output mode.

 The order of the elements in the list does not matter. Module names are the
 only content reported when *LIST* is set to an empty value.

 This environment variable value supersedes the default value set in the
 :mconfig:`spider_terse_output` configuration option. It can be defined with
 the :subcmd:`config` sub-command. The :option:`--output`/:option:`-o`
 command line switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 5.6

.. envvar:: MODULES_STICKY_PURGE

 When unloading a sticky or super-sticky module during a module
 :subcmd:`purge`, raise an ``error`` or emit a ``warning`` message or be
 ``silent``.

 This environment variable value supersedes the default value set in the
 :mconfig:`sticky_purge` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. envvar:: MODULES_TAG_ABBREV

 Specifies the abbreviation strings used to report module tags (see `Module
 tags`_ section). Its value is a colon-separated list of module tag names
 associated to an abbreviation string (e.g. *tagname=abbrev*).

 If a tag is associated to an empty string abbreviation, this tag will not be
 reported. In case the whole :envvar:`MODULES_TAG_ABBREV` environment variable
 is set to an empty string, tags are reported but not abbreviated.

 This environment variable value supersedes the default value set in the
 :mconfig:`tag_abbrev` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_TAG_COLOR_NAME

 Specifies the tag names or abbreviations whose graphical rendering should be
 applied over themselves instead of being applied over the name of the module
 they are attached to. Value of :envvar:`MODULES_TAG_COLOR_NAME` is a
 colon-separated list of module tag names or abbreviation strings (see `Module
 tags`_ section).

 When a select graphic rendition is defined for a tag name or a tag
 abbreviation string, it is applied over the module name associated with the
 tag and tag name or abbreviation is not displayed. When listed in
 :envvar:`MODULES_TAG_COLOR_NAME` environment variable, a tag name or
 abbreviation is displayed and select graphic rendition is applied over it.

 This environment variable value supersedes the default value set in the
 :mconfig:`tag_color_name` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_TCL_LINTER

 Command name or path for use to check syntax of modulefile through the
 :subcmd:`lint` sub-command.

 This environment variable value supersedes the default value set in the
 :mconfig:`tcl_linter` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.2

.. envvar:: MODULES_TERM_BACKGROUND

 Inform Modules of the terminal background color to determine if the color set
 for dark background or the color set for light background should be used to
 color output in case no specific color set is defined with the
 :envvar:`MODULES_COLORS` variable. Accepted values are ``dark`` and
 ``light``.

 This environment variable value supersedes the default value set in the
 :mconfig:`term_background` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_TERM_WIDTH

 Specifies the number of columns of the output. If set to ``0``, the output
 width will be the full terminal width, which is automatically detected by
 the module command. Accepted values are integers comprised between 0 and
 1000.

 This environment variable value supersedes the default value set in the
 :mconfig:`term_width` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--width`/:option:`-w` command line
 switches override this environment variable.

 .. only:: html or latex

    .. versionadded:: 4.7

.. envvar:: MODULES_UNIQUE_NAME_LOADED

 If set to ``1``, allows only one module loaded per module name. A conflict is
 raised when loading a module whose name or alternative names are shared by an
 already loaded module.

 This environment variable value supersedes the default value set in the
 :mconfig:`unique_name_loaded` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. envvar:: MODULES_UNLOAD_MATCH_ORDER

 When a module unload request matches multiple loaded modules, unload firstly
 loaded module or lastly loaded module. Accepted values are ``returnfirst``
 and ``returnlast``.

 This environment variable value supersedes the default value set in the
 :mconfig:`unload_match_order` configuration option. It can be defined with
 the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULES_VARIANT_SHORTCUT

 Specifies the shortcut characters that could be used to specify and report
 module variants (see :ref:`Module variants` section). Its value is a
 colon-separated list of variant names associated to a shortcut character
 (e.g., *variantname=shortcutchar*).

 A variant shortcut must be of one character length and must avoid characters
 used for other concerns or in module names or version specifications (i.e.,
 *[-+~/@=:,a-zA-Z0-9]*).

 If a shortcut is associated to an empty string or an invalid character, this
 shortcut definition will be ignored.

 This environment variable value supersedes the default value set in the
 :mconfig:`variant_shortcut` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.8

.. envvar:: MODULES_VERBOSITY

 Defines the verbosity level of the module command. Available verbosity levels
 from the least to the most verbose are:

 * ``silent``: turn off error, warning and informational messages but does not
   affect module command output result.
 * ``concise``: enable error and warning messages but disable informational
   messages.
 * ``normal``: turn on informational messages, like a report of the additional
   module evaluations triggered by loading or unloading modules, aborted
   evaluation issues or a report of each module evaluation occurring during a
   :subcmd:`restore` or :subcmd:`source` sub-commands.
 * ``verbose``: add additional informational messages, like a systematic
   report of the loading or unloading module evaluations.
 * ``verbose2``: report loading or unloading module evaluations of
   hidden-loaded modules, report if loading module is already loaded or if
   unloading module is not loaded.
 * ``trace``: provide details on module searches, resolutions, selections and
   evaluations.
 * ``debug``: print debugging messages about module command execution.
 * ``debug2``: report :file:`modulecmd.tcl` procedure calls in addition to
   printing debug messages.

 This environment variable value supersedes the default value set in the
 :mconfig:`verbosity` configuration option. It can be defined with the
 :subcmd:`config` sub-command. The :option:`--silent`, :option:`--verbose`,
 :option:`--debug` and :option:`--trace` command line switches override this
 environment variable.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 4.6
       Verbosity levels ``trace`` and ``debug2`` added

    .. versionchanged:: 4.7
       Verbosity level ``verbose2`` added

.. envvar:: MODULES_WA_277

 If set to ``1`` prior to Modules package initialization, enables workaround
 for Tcsh history issue (see https://github.com/envmodules/modules/issues/277).
 This issue leads to erroneous history entries under Tcsh shell. When
 workaround is enabled, an alternative *module* alias is defined which fixes
 the history mechanism issue. However the alternative definition of the
 *module* alias weakens shell evaluation of the code produced by modulefiles.
 Characters with a special meaning for Tcsh shell (like ``{`` and ``}``) may
 not be used anymore in shell alias definition otherwise the evaluation of the
 code produced by modulefiles will return a syntax error.

 This environment variable value supersedes the default value set in the
 :mconfig:`wa_277` configuration option. It can be defined with the
 :subcmd:`config` sub-command.

 To enable this workaround, :envvar:`MODULES_WA_277` should be set to ``1``
 prior Modules initialization or the :mconfig:`wa_277` configuration option
 should be set to ``1`` in the :file:`initrc` configuration file.

 .. only:: html or latex

    .. versionadded:: 4.3

.. envvar:: MODULESHOME

 The location of the main Modules package file directory containing module
 command initialization scripts, the executable program :file:`modulecmd.tcl`,
 and a directory containing a collection of main *modulefiles*.

 This environment variable value supersedes the default value set in the
 :mconfig:`home` configuration option. It can be defined with the
 :subcmd:`config` sub-command.


.. _module FILES:

FILES
-----

|file prefix|

 The :envvar:`MODULESHOME` directory.

|file etcdir_initrc|

 The configuration file evaluated by :file:`modulecmd.tcl` when it initializes
 to enable the default modulepaths, load the default modules and set
 :command:`module` command configuration.

 :file:`initrc` is a :ref:`modulefile(5)` so it is written as a Tcl script and
 defines modulepaths to enable with :mfcmd:`module use<module>`, modules to
 load with :mfcmd:`module load<module>` and configuration to apply with
 :subcmd:`module config<config>`. As any modulefile :file:`initrc` must begin
 with the Modules magic cookie (i.e., ``#%Module`` file signature).

 :file:`initrc` is optional. When this configuration file is present it is
 evaluated after the :file:`modulespath` configuration file. See the
 :ref:`Package Initialization` section for details.

|file etcdir_modulespath|

 The configuration file evaluated by :file:`modulecmd.tcl` when it initializes
 to enable the default modulepaths. This file contains the list of modulepaths
 separated by either newline or colon characters.

 :file:`modulespath` is optional. When this configuration file is present it
 is evaluated before the :file:`initrc` configuration file. See the
 :ref:`Package Initialization` section for details.

|file etcdir_siteconfig|

 The site-specific configuration script of :file:`modulecmd.tcl`. An
 additional configuration script could be defined using the
 :envvar:`MODULES_SITECONFIG` environment variable. See :ref:`Site-specific
 configuration` for detailed information.

|file etcdir_rc|

 The system-wide modules rc file. The location of this file can be changed
 using the :envvar:`MODULERCFILE` environment variable as described above.

:file:`$HOME/.modulerc`

 The user specific modules rc file.

:file:`$HOME/.module`

 The user specific collection directory.

|file modulefilesdir|

 The directory for system-wide *modulefiles*. The location of the directory
 can be changed using the :envvar:`MODULEPATH` environment variable as
 described above.

:file:`<modulepath>/.modulerc`

 Modulepath-specific module rc file.

:file:`<modulepath>/.modulecache`

 Modulepath-specific :ref:`module cache<Module cache>` file.

|file libexecdir_modulecmd|

 Modules execution engine, interpreting *modulefile* upon each invocation
 of :command:`module`.

|file bindir_modulecmd|

 Generic wrapper command pointing to Modules execution engine.

|file initdir_shell|

 The Modules package initialization file sourced into the user's environment.


SEE ALSO
--------

:ref:`envml(1)`, :ref:`ml(1)`, :ref:`modulecmd(1)`, :ref:`modulefile(5)`

