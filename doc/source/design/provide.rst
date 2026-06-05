.. _provide:

provide modulefile command
==========================

This design document describes the :mfcmd:`provide` Tcl command that defines
one or multiple module aliases targeting currently evaluating module.

Command specification
---------------------

The command has following syntax::

    provide modulefile...

Each modulefile argument corresponds to a module alias to define onto current
modulefile. At least one argument should be provided, an error is raised
otherwise. Modulefile specification should correspond to a module name and
version. Variant cannot be specified. Each individual string is interpreted as
a module name and version.

This command is only available in modulefile evaluation contexts.

``provide`` command is only effective during ``load`` evaluations. It
corresponds to a *no-operation* on other evaluation modes.

``provide`` only defines aliases, thus ``conflict`` definitions are expected
to avoid these names to be provided by several loaded modules.

extensions modulefile command
-----------------------------

The :mfcmd:`extensions` modulefile command introduced by Lmod is now
implemented as a bare command alias onto :mfcmd:`provide`.

Provided alias
--------------

Module alias defined with ``provide`` command are not distinguished from other
aliases defined with ``family`` or ``module-alias``. These aliases are
recorded in :envvar:`__MODULES_LMALTNAME` with `al` type like other aliases.

It appears easier for the user to only face one kind of element (alias) rather
requiring them to learn multiple concepts (family, extensions, alias). All of
this is just different names applying to a given modulefile.

A new item for output configuration is introduced: ``provided-alias``. It adds
module aliases information into the generated output and enables the
evaluation of modulefiles to fetch aliases provided by them (i.e., defined
within them by ``provide`` or ``family`` modulefile commands).
``provided-alias`` implies ``alias`` item.

A given provided alias may be defined by several modulefiles. When reported
first defined target is retained. Which means that first scanned modulefile
wins.

*FUTURE*: keep all target definitions to be able to report all of them if
asked.

info_extension configuration option
-----------------------------------

The :mconfig:`info_extension` configuration option is added to control if
defined extensions should be considered with an information purpose only.

When this option is enabled, the module alias is not generated to avoid having
conflict between 2 modules defining the same extension.

This configuration option only affects extensions defined with the
:mfcmd:`extensions` modulefile command. When enabled it behaves like the
:mfcmd:`extensions` modulefile command implemented by Lmod.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
