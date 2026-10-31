.. _add-new-sub-command:

Add new module sub-command
==========================

This document is a guide for Modules developers that wish to introduce a new
sub-command for the :command:`module` command.

Core code
---------

Introducing new configuration option means declaring it then using it (get its
value then branch code in :file:`modulecmd.tcl` script to adapt
:command:`module` command behavior.

1. First update in the ``reportUsage`` procedure the usage message of the
   :command:`module` command to report the new sub-command.

    - File to edit: :file:`tcl/report.tcl.in`
    - Example commit: :ghcommit:`697b999a`

2. Update the ``module`` procedure and its helper procedures to register the
   new sub-command. First add sub-command in the list of valid sub-commands
   defined in ``parseModuleCommandName``.

   If sub-command cannot be called within a modulefile context add it in
   ``module`` procedure to the list of sub-commands raising an error if found
   call from such context.

   Add test in ``module`` procedure to verify that the number of argument
   passed to sub-command is valid.

   Update main switch in ``module`` procedure to add case for new sub-command
   that calls the ``cmdModule<Subcmdname>`` procedure.

    - File to edit: :file:`tcl/main.tcl.in`
    - Example commit: :ghcommit:`697b999a`

3. Create the ``cmdModule<Subcmdname>`` procedure and craft in it the Tcl code
   corresponding to the sub-command introduced.

    - File to edit: :file:`tcl/subcmd.tcl.in`
    - Example commit: :ghcommit:`697b999a`

Initialization scripts
----------------------

New sub-command should be referred in the shell completion scripts.

Files that should be edited to add reference to the new sub-command:

- :file:`init/Makefile` (contains definitions to build *bash* and *tcsh*
  completion scripts
- :file:`init/bash_completion.in`
- :file:`init/fish_completion`
- :file:`init/tcsh_completion.in`
- :file:`init/zsh-functions/_module.in`

Example commit: :ghcommit:`0a96ed64`

Linter scripts
--------------

New sub-commands should be described in Nagelfar syntax databases if it can be
called within a modulefile context.

Files that should be edited to add reference to the new sub-command:

- :file:`share/nagelfar/syntaxdb_modulefile.tcl`

  - add sub-command name in ``::subCmd(module)`` list
  - add sub-command argument description in ``::syntax`` array
  - add sub-command option description in ``::option`` array
  - See `Nagelfar syntax description`_

.. _Nagelfar syntax description: http://nagelfar.sourceforge.net/syntaxtokens.html

Documentation
-------------

Man pages and other user documentation have to be updated to describe the
introduced sub-command.

Files that should be edited:

- :file:`doc/source/module.rst` (module manpage)

  - add sub-command description with ``subcmd`` anchor under *Module
    Sub-Commands* section

- :file:`doc/source/modulefile.rst` (modulefile manpage)

  - mention if sub-command can be called from the modulefile evaluation
    context under :mfcmd:`module` modulefile command section
  - if sub-command leads to modulefile evaluation, mention sub-command name
    in the list of value returned by :mfcmd:`module-info
    command<module-info>`

- :file:`doc/source/changes.rst`

  - add sub-command under *Module Sub-Commands* section of current Modules
    major version

Example commits:

- sub-command doc: :ghcommit:`b4c0e0f8`
- new value returned by ``module-info command``: :ghcommit:`5cd53523`

Testsuite
---------

Non-regression testsuite must be adapted first to add specific tests to check
the behavior of the added sub-command and ensure overall code coverage does
not drop.

#. Test the sub-command against an invalid number of arguments (too few and
   too many).

    - File to edit: :file:`testsuite/modules.01-general/071-args.exp`
    - Example commit: :ghcommit:`086ac136`

#. If the new sub-command cannot be called from a modulefile evaluation, test
   the error obtained when tried.

    - Files to edit:

      - :file:`testsuite/modules.50-cmds/151-module-onlytop.exp`
      - :file:`testsuite/modulefiles.3/modbad/<subcmdname>`

    - Example commit: :ghcommit:`086ac136`

#. If the new sub-command leads to modulefile evaluation, test value returned
   by :mfcmd:`module-info command<module-info>`.

    - Files to edit:

      - :file:`testsuite/modules.50-cmds/282-info-command.exp`
      - :file:`testsuite/modules.50-cmds/283-info-command-exp.exp`
      - :file:`testsuite/modulefiles/info/commandexp`

    - Example commit: :ghcommit:`5cd53523`

#. Craft specific tests to validate the correct behavior of the sub-command
   against valid or invalid values and valid or invalid environment.

    - File to edit: new test file to create in
      :file:`testsuite/modules.50-cmds` directory, for sub-command called
      during a modulefile evaluation, or in :file:`testsuite/modules.70-maint`
      directory otherwise.

    - Example commit: :ghcommit:`086ac136`

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
