.. Home page

Environment Modules
===================

.. image:: https://img.shields.io/github/stars/envmodules/modules
    :target: https://github.com/envmodules/modules
    :alt: GitHub Repository

.. image:: https://img.shields.io/github/license/envmodules/modules?color=lightsteelblue
    :alt: GitHub License

.. image:: https://img.shields.io/github/v/release/envmodules/modules
    :target: https://github.com/envmodules/modules/releases/latest
    :alt: GitHub Release

.. image:: https://img.shields.io/twitter/url/https/twitter.com/EnvModules.svg?style=social&label=@EnvModules
    :target: https://twitter.com/EnvModules
    :alt: Twitter/X

**Welcome to the Environment Modules documentation portal. The Environment
Modules package provides for the dynamic modification of a user's environment
via modulefiles.**

The Modules package is a tool that simplifies shell initialization and
lets users easily modify their environment during a session using
modulefiles.

Each modulefile contains the information needed to configure the shell for
an application. Once the Modules package is initialized, the environment
can be modified on a per-module basis using the :command:`module` command
which interprets modulefiles. Typically modulefiles instruct the
:command:`module` command to alter or set shell environment variables such as
:envvar:`PATH`, :envvar:`MANPATH`, etc. modulefiles may be shared by many
users on a system and users may have their own collection to supplement or
replace the shared modulefiles.

Modules can be **loaded** and **unloaded** dynamically and atomically,
in an clean fashion. All popular shells are supported, including *bash*,
*ksh*, *zsh*, *sh*, *csh*, *tcsh*, *fish*, *cmd*, *pwsh*, as well as some
languages such as *tcl*, *perl*, *python*, *ruby*, *cmake* and *r*.

Modules are useful in managing different versions of applications. Modules
can also be bundled into meta-modules that will load an entire suite of
different applications.

.. note:: Modules presented here are ones that modify the shell or script
   execution environment. They should not be confused with language-specific
   modules (e.g., Perl modules, Python modules or R modules) that add specific
   capabilities to scripts.

Quick examples
--------------

Here is an example of loading a module on a Linux machine under bash.
::

    $ module load gcc/12.4.0
    $ which gcc
    $ /usr/local/gcc/12.4.0/linux-x86_64/bin/gcc

Now we'll switch to a different version of the module
::

    $ module switch gcc/14
    $ which gcc
    /usr/local/gcc/14.2.0/linux-x86_64/bin/gcc

And now we'll unload the module altogether
::

    $ module unload gcc
    $ which gcc
    gcc not found

Now we'll log into a different machine, using a different shell (tcsh).
::

    % module load gcc/14.2
    % which gcc
    /usr/local/gcc/14.2.0/linux-aarch64/bin/gcc

Note that the command line is exactly the same, but the path has
automatically configured to the correct architecture.

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Basics

   INSTALL
   INSTALL-win
   MIGRATING
   NEWS
   FAQ
   changes

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Examples

   cookbook

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Reference

   ml
   module
   modulefile

.. toctree::
   :hidden:
   :maxdepth: 2
   :caption: Development

   CONTRIBUTING
   devel
   design
   CHARTER
   GOVERNANCE
   acknowledgments


Get started with Modules
------------------------

Learn how to retrieve and install Modules :ref:`on Unix<INSTALL>` or
:ref:`on Windows<INSTALL-win>`. An overlook on the new functionalities
introduced by each version is available in the :ref:`MIGRATING` guide.
:ref:`NEWS` provides the full list of changes added in each version. The
:ref:`changes` document gives an in-depth view of the modified behaviors and
new features between major versions.

Reference manual page for the :ref:`module(1)` and :ref:`ml(1)` commands and
for :ref:`modulefile(5)` script provide details on all supported options.

A :ref:`cookbook` of recipes describes how to use the various features of
Modules and how to extend the :command:`module` command to achieve specific
needs.

Links
-----

* Web site: http://modules.sourceforge.net
* Documentation: https://modules.readthedocs.io
* Source repository: https://github.com/envmodules/modules
* Issue tracking system: https://github.com/envmodules/modules/issues
* Download releases: https://github.com/envmodules/modules/releases

Community
---------

Modules is an open source project. Questions, discussion, and contributions
are welcome. You can get in contact with the Modules community via:

* the `modules-interest mailing list`_
  (``modules-interest@lists.sourceforge.net``)
* the `Modules chat room`_ (``#modules:matrix.org``)

The project is also present on several social media platforms:

* X/Twitter: `@EnvModules`_
* Mastodon: `@EnvModules@mast.hpc.social`_
* Bluesky: `@EnvModules.bsky.social`_

.. _modules-interest mailing list: https://sourceforge.net/projects/modules/lists/modules-interest
.. _Modules chat room: https://matrix.to/#/#modules:matrix.org
.. _@EnvModules: https://x.com/EnvModules
.. _@EnvModules@mast.hpc.social: https://mast.hpc.social/@EnvModules
.. _@EnvModules.bsky.social: https://bsky.app/profile/envmodules.bsky.social

Contributing
------------

Modules project welcomes contributions of all kinds! Before submitting an
issue or pull request, please take a moment to review our :ref:`Contributing
guide<CONTRIBUTING>`. It includes important information about issue reporting,
coding standards, etc.

Please note that Modules project has a `Code of conduct`_. It ensures a
respectful and inclusive environment for all contributors. By participating in
the Modules community, you agree to abide by its rules.

This project also adheres to a :ref:`Technical charter<CHARTER>`, which
defines its governance model, decision-making process, and long-term vision.

.. _Code of conduct: https://github.com/envmodules/modules?tab=coc-ov-file#readme

License
-------

Modules is distributed under the GNU General Public License, either version 2
or (at your option) any later version (`GPL-2.0-or-later`).
