.. _linked-envvars:

Linked environment variables
============================

This document describes the mechanism to link one environment variable onto
others and apply the same value changes.

The goal is to link environment variables together and apply all changes to
both once linked.

Design choices:

* When link is being established, variable value is not synced
* Link is not reflexive: if A is linked to B, all changes made to A are
  applied to B, but direct changes to B are not applied to A unless if this
  link is also configured
* A ``module display`` shows the environment changes applying to linked
  environment variables

This mechanism applies to all environment variable management modulefile
commands and module sub-commands:

* :mfcmd:`append-path`
* :mfcmd:`prepend-path`
* :mfcmd:`pushenv`
* :mfcmd:`remove-path`
* :mfcmd:`setenv`
* :mfcmd:`unsetenv`

.. note:: Link is not effective when a value is set to the environment
   variable through the ``::env`` Tcl global array.

``linked_envvars`` configuration option
---------------------------------------

New configuration option :mconfig:`linked_envvars` is made to configure these
links between environment variables.

* Items are separated by colon character
* One variable can be linked to several ones, either through:

  - one item with several variables: ``A&B&C``
  - several items: ``A&B:A&C``

Implementation
--------------

* Define an internal state (``current_envvar``) to indicate the name of the
  environment variable currently modified
* Set a ``trace`` to execute ``mirrorEnvVarChange`` procedure at the end of
  the execution of environment variable management commands
* No trace setup if :mconfig:`linked_envvars` is empty
* ``mirrorEnvVarChange`` procedure:

  - get currently modified environment variable name through
    ``current_envvar`` state
  - get environment variable change command to execute through
    ``command-string`` trace argument
  - replace ``current_envvar`` in this command string by linked environment
    variable name
  - execute resulting command string in currently active interpreter
  - do this for each linked environment variable, including recursively linked
    ones: trace is triggered one and handle all environment variables to avoid
    cycle loop

.. note:: No other environment variable change can occur between the
   definition of the ``current_envvar`` state and the execution of the
   ``mirrorEnvVarChange`` trace procedure. The link mechanism cannot apply to
   Modules internal environment variables like ``__MODULES_SHARE_*``.

.. note:: Environment variable name argument is always positioned before any
   value, thus replacing the first occurrence found of this name will
   accurately change the name argument on all environment variable change
   commands.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
