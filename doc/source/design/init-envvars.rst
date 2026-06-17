.. _init-envvars:

Initialize environment variables
================================

This document describes the mechanism to initialize an environment variable to
a given value the first time this variable is changed.

This is especially useful for variable like ``MANPATH`` that requires a
leading or finishing colon character in addition to the specific paths defined
to still be able to query the system man pages.

Design choices:

* If environment variable is changed and currently not defined, set it to the
  defined initial value prior applying the change
* When removing value to path-like environment variable, if after the removal
  it equals the initial value without specific reference counter, unset the
  environment variable

This mechanism applies to all path-like environment variable management
modulefile commands and module sub-commands:

* :mfcmd:`append-path`
* :mfcmd:`prepend-path`
* :mfcmd:`remove-path`

``init_envvars`` configuration option
-------------------------------------

New configuration option :mconfig:`init_envvars` is made to define the initial
value of the environment variables.

* Items are separated by colon character
* Each item has the following syntax: ``VARNAME=initial_value``

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
