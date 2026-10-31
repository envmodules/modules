.. _add-new-command-line-switch:

Add new command line switch
===========================

This document is a guide for Modules developers that wish to introduce a new
command line switch for the :command:`module` command, or to accept an
existing switch on an additional sub-command.

Two kinds of command line switches exist and they are parsed at different
places in :file:`modulecmd.tcl`:

- *Top-level switches* (like :option:`--timer` or :option:`--ignore-user-rc`)
  control the overall :command:`module` behavior and apply whatever the
  sub-command. They are usually placed before the sub-command name and are
  parsed in the *Main program* section of :file:`tcl/main.tcl.in`.
- *Sub-command switches* (like :option:`--tag` or :option:`--no-indepth`) only
  make sense for a limited set of sub-commands. They are usually placed after
  the sub-command name and are parsed in the ``parseModuleCommandArgs``
  procedure of :file:`tcl/main.tcl.in`, which is also called when
  :mfcmd:`module` command is evaluated within a modulefile and by the
  :command:`ml` command.

Decide first which kind the new switch belongs to, as it determines the core
code changes to make. Whatever the kind, a switch may be set either before or
after the sub-command name, so both parsing steps are involved to some extent
(see below). If the switch is a command line way to set an existing
configuration option, also read :ref:`add-new-config-option`.

Core code
---------

Top-level switch
^^^^^^^^^^^^^^^^

#. Add a case for the new switch in the main argument parsing ``switch``
   statement of the *Main program* section. Both the long form (``--name``)
   and the short form (``-X``), if any, are matched there. The usual pattern
   is to set an ``asked_<name>`` global variable that is read afterward when
   initializing the state or the configuration option the switch relates to:
   ``getConf`` and ``getState`` both look for such ``::asked_<name>`` variable
   to supersede the value of the configuration option or state named
   ``<name>``. When the switch does not map to a configuration option or a
   state, the matching case may directly call ``setState`` or perform the
   expected action.

    - File to edit: :file:`tcl/main.tcl.in`
    - Example commits: :ghcommit:`2c251a37` (:option:`--timer`),
      :ghcommit:`64b46c19` (:option:`--ignore-user-rc`)

   A switch accepting a value should handle its ``--name=VALUE`` form and, if
   a short form exists, the ``-X VALUE`` form through the ``nextargisval``
   mechanism. Report a *Missing value* error when no value is given, like
   done for :option:`--output`. Validate the value and report an *Invalid
   option* error if it is not accepted, like done for :option:`--width`.

#. If the switch relates to a state rather than a configuration option,
   declare this state in the ``g_state_defs`` definition array.

    - File to edit: :file:`tcl/init.tcl.in`
    - Example commit: :ghcommit:`2c251a37`

#. Update the Tcl code to adapt :command:`module` command behavior depending
   on the switch. This part highly depends on what the switch controls.

    - File to edit: file(s) in :file:`tcl/` directory

#. Describe the switch in the usage message reported by ``reportUsage``, in
   its *Switches* section.

    - File to edit: :file:`tcl/report.tcl.in`
    - Example commit: :ghcommit:`2c251a37`

Sub-command switch
^^^^^^^^^^^^^^^^^^

#. Add a case for the new switch in the argument parsing ``switch`` statement
   of the ``parseModuleCommandArgs`` procedure. Test there that current
   sub-command (``cmd`` argument) supports the switch and raise an
   *Unsupported option* error otherwise, unless the ``ignerr`` argument is
   set (which is the case when :command:`ml` filters out the switches to find
   the sub-command name). Switches that are silently ignored on unsupported
   sub-commands, like :option:`--terse`, are a legacy from Modules 3 and
   should not be a model for new switches.

   The parsed value is returned by ``parseModuleCommandArgs`` to its callers.
   When the switch controls something new, add a variable for it in the
   result list returned by the procedure and update every ``lassign`` of this
   result: ``moduleTop`` and ``ml`` in :file:`tcl/main.tcl.in`, ``module`` in
   :file:`tcl/mfcmd.tcl` and ``module-sc`` in :file:`tcl/modscan.tcl`. Then
   update ``formatModuleCommand`` to pass the value as argument to the
   ``cmdModule<Subcmdname>`` procedures of the sub-commands accepting the
   switch. When the switch rather alters an existing state (like
   :option:`--terse` does with ``report_format``), the sub-command code reads
   this state and no new argument is needed.

    - File to edit: :file:`tcl/main.tcl.in`
    - Example commits: :ghcommit:`a1fb42fd` (:option:`--tag`),
      :ghcommit:`963b9a2d` (:option:`--no-indepth`),
      :ghcommit:`be2caa12` (``--not-req``)

   A switch accepting a value should handle its ``--name=VALUE`` form and, if
   a short form exists, the ``-X VALUE`` form through the ``nextargisval``
   mechanism. Report a *Missing value* error when no value is given, like
   done for :option:`--tag`.

#. Register the switch in the main argument parsing ``switch`` statement of
   the *Main program* section, so that it is not rejected as an *Invalid
   option* when placed before the sub-command name. Two cases already
   exist for that purpose: one appending the switch to the ``extraargv`` list,
   which moves it after the sub-command name (used by the output formatting
   switches like :option:`--terse` or :option:`--json`), and one appending
   the switch to the ``otherargv`` list, which keeps it where it was found
   (used by switches whose position matters, like :option:`-d` that means
   ``--default`` or ``--delim`` depending on the sub-command). A switch
   accepting its value as a separate argument needs its own case, like
   :option:`-o`, to also move the value.

    - File to edit: :file:`tcl/main.tcl.in`
    - Example commit: :ghcommit:`a1fb42fd`

#. Craft in the ``cmdModule<Subcmdname>`` procedure of each supporting
   sub-command the Tcl code corresponding to the switch.

    - File to edit: :file:`tcl/subcmd.tcl.in`
    - Example commit: :ghcommit:`3ad5a888` (:option:`--terse` on
      :subcmd:`whatis` and :subcmd:`search`)

#. Describe the switch in the usage message reported by ``reportUsage``: in
   its *Switches* section and in the synopsis of each sub-command accepting
   it. When it is an existing switch that is accepted on an additional
   sub-command, only the sub-command synopsis is updated.

    - File to edit: :file:`tcl/report.tcl.in`
    - Example commits: :ghcommit:`a1fb42fd`, :ghcommit:`3ad5a888`

Initialization scripts
----------------------

New switch should be referred in the shell completion scripts. Top-level
switches are listed in the ``comp_opts`` or ``comp_long_opts`` variables of
:file:`init/Makefile` and sub-command switches in the ``comp_<subcmd>_opts``
variable of each sub-command accepting it. These variables are substituted
in the *bash* and *tcsh* completion scripts, which thus only need an edit if
no ``comp_<subcmd>_opts`` variable exists yet for a supporting sub-command.
A switch accepting a value in the ``--name=VALUE`` form is listed twice, as
``--name`` and ``--name=``.

Files that should be edited to add reference to the new switch:

- :file:`init/Makefile`
- :file:`init/bash_completion.in` and :file:`init/tcsh_completion.in` (only
  if a supporting sub-command has no ``comp_<subcmd>_opts`` variable yet)
- :file:`init/fish_completion`
- :file:`init/zsh-functions/_module.in`

Example commits:

- top-level switch: :ghcommit:`372de708`
- sub-command switch: :ghcommit:`fae13159`
- existing switch accepted on additional sub-command: :ghcommit:`3ad5a888`

Linter scripts
--------------

Sub-command switches should be described in Nagelfar syntax database if they
can be used on a :mfcmd:`module` command called within a modulefile context.

File that should be edited to add reference to the new switch:

- :file:`share/nagelfar/syntaxdb_modulefile.tcl`

  - add switch name in the ``::option(module <subcmd>)`` list of each
    sub-command accepting it (and its aliases, like ``add`` for ``load``)
  - add a ``::option(module <subcmd> --name)`` entry set to ``1`` if the
    switch accepts a value as a separate argument
  - See `Nagelfar syntax description`_

.. _Nagelfar syntax description: http://nagelfar.sourceforge.net/syntaxtokens.html

Documentation
-------------

Man pages and other user documentation have to be updated to describe the
introduced switch.

Files that should be edited:

- :file:`doc/source/module.rst` (module manpage)

  - add switch description with ``option`` anchor under *Command line
    switches* section, in alphabetical order of long form name, listing the
    sub-commands accepting it and with a ``versionadded`` directive
  - for a sub-command switch, add it to the synopsis of each sub-command
    accepting it in the ``subcmd`` directive under *Module Sub-Commands*
    section, describe its effect there and add a ``versionchanged``
    directive
  - when an existing switch is accepted on an additional sub-command, update
    the list of sub-commands in its ``option`` description and add a
    ``versionchanged`` directive there too

- :file:`doc/source/modulefile.rst` (modulefile manpage)

  - if the switch can be used on a :mfcmd:`module` command called within a
    modulefile context, describe it under :mfcmd:`module` modulefile command
    section and add a ``versionchanged`` directive

- :file:`doc/source/changes.rst`

  - add switch to the table under *Command line switches* section of
    current Modules major version
  - when an existing switch is accepted on an additional sub-command, add a
    note after the table, under the switch name, instead
  - if the switch can be used on a :mfcmd:`module` command called within a
    modulefile context, also mention it under :mfcmd:`module` in the
    *Modulefile commands* section

- :file:`NEWS.rst`

  - add an entry at the end of the current in-development version bullet
    list

Example commits:

- top-level switch: :ghcommit:`be5abb7a`
- sub-command switch: :ghcommit:`98252083`
- existing switch accepted on additional sub-command: :ghcommit:`3ad5a888`

Testsuite
---------

Non-regression testsuite must be adapted first to ensure existing tests still
pass then to add specific tests to check the behavior of the added switch and
ensure overall code coverage does not drop.

#. For a top-level switch, test it in long and short form when placed before
   a sub-command name.

    - File to edit: :file:`testsuite/modules.00-init/090-switches.exp`

#. For a sub-command switch, test it placed before and after the sub-command
   name, and test the *Unsupported option* error obtained when used on a
   sub-command that does not accept it. If the switch is instead passed
   through as a regular argument on sub-commands that do not accept it (like
   ``--append`` is), test the resulting error there.

    - Files to edit:

      - the testsuite file dedicated to the switch (see below)
      - :file:`testsuite/modules.00-init/071-args.exp` (switch passed
        through as a regular argument)

    - Example commit: :ghcommit:`9f7a2871`

#. If the switch accepts a value, test the error obtained when value is
   missing or invalid. Error message helper procedures, like
   ``err_misoptval``, are defined in the testsuite initialization file.

    - Files to edit:

      - :file:`testsuite/modules.00-init/005-init_ts.exp`
      - the testsuite file dedicated to the switch (see below)

    - Example commit: :ghcommit:`9f7a2871`

#. If the switch can be used on a :mfcmd:`module` command called within a
   modulefile context, test it from such context. If the Nagelfar syntax
   database has been updated, check with the :subcmd:`lint` sub-command that
   a modulefile using the switch reports no issue.

    - Files to edit:

      - new test file to create in :file:`testsuite/modules.50-cmds` directory
      - fixture modulefiles to add in the highest-numbered
        :file:`testsuite/modulefiles.N` directory (see
        :ref:`devel-testsuite`)
      - :file:`testsuite/modules.70-maint/420-lint.exp`

    - Example commit: :ghcommit:`36dd47f1`

#. Craft specific tests to validate the correct behavior of the switch on
   each sub-command accepting it, combined with the other switches these
   sub-commands accept (for instance the :option:`--json` output mode or the
   :option:`--all` hidden module inclusion).

    - File to edit: depends on what is impacted by the new switch, if some
      tests already exist for concerned behavior (existing testsuite file to
      update) or not (new testfile to create, in
      :file:`testsuite/modules.70-maint` for a top-level switch).

    - Example commits: :ghcommit:`a083af06` (new test file),
      :ghcommit:`3ad5a888` (existing test files updated)

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
