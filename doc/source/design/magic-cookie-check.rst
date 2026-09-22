.. _magic-cookie-check:

Module magic cookie check
=========================

A file should start with a specific string as header line to be considered as
a modulefile. This specific string is called the magic cookie and is equal to
``#%Module`` optionally followed by a version number to indicate the minimum
version of :file:`modulecmd.tcl` required to interpret this file.

Magic cookie applies to modulefiles and module RC files. More recently it also
applies to the :file:`initrc` configuration file and collections.

Magic cookie is checked in two different situations:

* When searching for a modulefile: all files located under a directory used as
  a modulepath are checked to determine if they are modulefiles to take them
  into account in the module search.

* When evaluating a modulefile: when reading file to pass it down to the
  modulefile or modulerc interpreter, the magic cookie is checked to ensure
  file can be evaluated.

The :mconfig:`mcookie_check` configuration option is introduced to be able to
disable the magic cookie check. Option accepts the following values:

* ``always``: This is the default value, magic cookie is checked in both
  situations described above
* ``eval``: magic cookie is only checked prior evaluating file, not when
  searching for modulefiles

The :mconfig:`mcookie_check` option works like the :mconfig:`icase` option
with value determining a level of cumulative support.

*FUTURE*: a third value, ``never``, may be interesting to disable the magic
cookie check in all situations.


Skipping check when searching modules
-------------------------------------

When setting :mconfig:`mcookie_check` to ``eval``, module magic cookie is not
checked when analyzing the files located under an enabled modulepath. This
mode significantly diminishes the I/O load when looking at the content of a
modulepath as files are not opened and header read for the check.

This mode requires a perfect control on the files located within the hierarchy
of the modulepath directories as:

* non-modulefiles will be considered modulefiles and will be reported in
  module search results and used to locate a module corresponding to a query

* files hidden through restrictive permissions are reported in search results
  and used to locate a module corresponding to a query

For these non-modulefiles or read-protected files an error is obtained when
trying to evaluate them, as the magic cookie is checked at this step.

Also the files specified full path are not checked prior evaluation if
``mcookie_check`` is set to ``eval``, so if these files are not modulefile an
error will be obtained when trying to evaluate them.

The ``eval`` mode of ``mcookie_check`` configuration option has no impact on
the :file:`initrc` configuration file and collections as such files are not
searched like modulefiles. Their header is only checked at evaluation time.


Implementation of ``eval`` mode
-------------------------------

Modulefiles or modulercs are read through the ``readModuleContent`` procedure
which is called by:

* ``execute-modulerc`` or ``execute-modulefile`` procedures when files need to
  get fully read to get evaluated
* ``checkValidModule`` procedure to verify file is a readable modulefile when
  search for modules

The ``checkValidModule`` procedure is the one to update when ``mcookie_check``
configuration option is not set to ``always`` as this procedure is called by
all module search contexts. It is called by:

* ``findModules`` to check files in directories within modulepaths
* ``getModules`` to check files pointed by :mfcmd:`module-virtual`
* ``getPathToModule`` to check files transmitted as full path file

.. note:: File readability (permission check) is not verified when
   ``mcookie_check`` option is set to ``eval`` to keep the full benefit of
   this mode regarding the I/O load optimization.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
