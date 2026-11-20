.. _spack-like-sub-command-names:

Spack-like sub-command names
============================

People using both Modules and the `Spack`_ package manager regularly type the
command name of one tool when using the other. For instance ``spack find``
lists the installed packages and ``spack list`` the packages that could be
installed, whereas ``module avail`` lists the available modulefiles and
``module list`` the loaded ones.

This recipe describes how to make the :command:`module` command understand
the command names of Spack.

.. _Spack: https://spack.io/

Implementation
--------------

Starting version 5.8, the :mconfig:`subcmd_alias` configuration option defines
additional names for module sub-commands. Its value is a colon-separated list
of ``alias=target`` definitions.

Following table lists the Spack commands that have an equivalent among module
sub-commands and the alias definition required, if any, to make
:command:`module` accept the Spack name.

+---------------------+-------------------------------+-------------------------+
| Spack command       | Module sub-command            | Alias definition        |
+=====================+===============================+=========================+
| ``spack load``      | :subcmd:`load`                | *Same name*             |
+---------------------+-------------------------------+-------------------------+
| ``spack unload``    | :subcmd:`unload`              | *Same name*             |
+---------------------+-------------------------------+-------------------------+
| ``spack find``      | :subcmd:`avail`               | ``find=avail``          |
+---------------------+-------------------------------+-------------------------+
| ``spack list``      | :subcmd:`spider`              | ``list=spider``         |
+---------------------+-------------------------------+-------------------------+
| ``spack versions``  | :subcmd:`avail`               | ``versions=avail``      |
+---------------------+-------------------------------+-------------------------+
| ``spack info``      | :subcmd:`help`                | ``info=help``           |
+---------------------+-------------------------------+-------------------------+
| ``spack spec``      | :subcmd:`display`             | ``spec=display``        |
+---------------------+-------------------------------+-------------------------+
| ``spack location``  | :subcmd:`path`                | ``location=path``       |
+---------------------+-------------------------------+-------------------------+
| ``spack edit``      | :subcmd:`edit`                | *Same name*             |
+---------------------+-------------------------------+-------------------------+
| ``spack test``      | :subcmd:`test`                | *Same name*             |
+---------------------+-------------------------------+-------------------------+
| ``spack audit``     | :subcmd:`lint`                | ``audit=lint``          |
+---------------------+-------------------------------+-------------------------+
| ``spack reindex``   | :subcmd:`cachebuild`          | ``reindex=cachebuild``  |
+---------------------+-------------------------------+-------------------------+
| ``spack clean``     | :subcmd:`cacheclear`          | ``clean=cacheclear``    |
+---------------------+-------------------------------+-------------------------+
| ``spack config``    | :subcmd:`config`              | *Same name*             |
+---------------------+-------------------------------+-------------------------+
| ``spack commands``  | :subcmd:`help`                | ``commands=help``       |
+---------------------+-------------------------------+-------------------------+
| ``spack help``      | :subcmd:`help`                | *Same name*             |
+---------------------+-------------------------------+-------------------------+

An installed package in Spack corresponds to a modulefile available in the
enabled modulepaths. The packages Spack knows and could install correspond to
the modulefiles found by :subcmd:`spider` in all the modulepaths, including
those that are not enabled yet.

The ``list`` alias bears the name of an existing sub-command: it shadows the
:subcmd:`list` sub-command that reports the loaded modulefiles. Spack has no
dedicated command for this, as loaded packages are reported with
``spack find --loaded``. Loaded modulefiles are still obtained with the
:command:`ml` command without argument or with an abbreviation of the
shadowed sub-command, as aliases do not apply to abbreviations. An additional alias may also be defined for this purpose, like
``loaded=list``.

.. note:: Alias target is always a sub-command of :command:`module` and never
   another alias. The ``find=avail`` definition designates the
   :subcmd:`avail` sub-command, and would still do if an alias named
   ``avail`` was also defined.

Spack commands that install, build or describe the dependency graph of
packages (``install``, ``uninstall``, ``graph``, ``dependencies``, etc) have
no equivalent, as Modules does not build software. Commands made of several
words, like ``spack env activate``, cannot be mapped either: an alias only
stands for the sub-command name.

**Compatible with Modules v5.8+**

Installation
------------

To define these aliases for all users, set the configuration option in the
:file:`initrc` configuration file, which is located in the configuration
directory designated by the :instopt:`--etcdir` installation option.

.. code-block:: none
   :caption: initrc

   #%Module
   module config subcmd_alias find=avail:list=spider:info=help:spec=display:location=path:versions=avail:commands=help:audit=lint:reindex=cachebuild:clean=cacheclear

A user may define them on its own by running the same :subcmd:`config`
sub-command in a shell session or by setting the
:envvar:`MODULES_SUBCMD_ALIAS` environment variable in its shell startup
files.

.. parsed-literal::

   :ps:`$` module config subcmd_alias find=avail:list=spider:info=help:spec=display:location=path:versions=avail:commands=help:audit=lint:reindex=cachebuild:clean=cacheclear

When aliases are defined site-wide, a user may add its own definitions or
withdraw some of the site by prefixing the value with ``+`` or ``-``. For
instance to get a ``loaded`` alias in addition to those defined above:

.. parsed-literal::

   :ps:`$` module config subcmd_alias +loaded=list

Usage example
-------------

With the above configuration set, the Spack command names are accepted by the
:command:`module` and :command:`ml` commands and are completed like the
sub-command they designate:

.. parsed-literal::

   :ps:`$` module find -t foo
   /path/to/modulefiles:
   foo/1.0
   foo/2.0
   :ps:`$` module load foo/2.0
   :ps:`$` module location foo/2.0
   /path/to/modulefiles/foo/2.0
   :ps:`$` module loaded
   Currently Loaded Modulefiles:
    1) foo/2.0

Defined aliases are reported at the end of the usage message:

.. parsed-literal::

   :ps:`$` module help
   ...
   Sub-command aliases:
     audit           Alias for 'lint' sub-command
     clean           Alias for 'cacheclear' sub-command
     commands        Alias for 'help' sub-command
     find            Alias for 'avail' sub-command
     info            Alias for 'help' sub-command
     list            Alias for 'spider' sub-command
     loaded          Alias for 'list' sub-command
     location        Alias for 'path' sub-command
     reindex         Alias for 'cachebuild' sub-command
     spec            Alias for 'display' sub-command
     versions        Alias for 'avail' sub-command

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
