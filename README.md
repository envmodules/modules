# <img src="https://raw.githubusercontent.com/envmodules/modules/main/share/logo/modules_logo_text.svg" height="180" alt="Modules"/>

[![Linux Build Status](https://github.com/envmodules/modules/workflows/linux-tests/badge.svg)](https://github.com/envmodules/modules/actions?query=workflow:linux-tests)
[![OS X Build Status](https://github.com/envmodules/modules/workflows/macos-tests/badge.svg)](https://github.com/envmodules/modules/actions?query=workflow:macos-tests)
[![Windows Build Status](https://github.com/envmodules/modules/workflows/windows-tests/badge.svg)](https://github.com/envmodules/modules/actions?query=workflow:windows-tests)
[![Coverage Status](https://codecov.io/gh/envmodules/modules/branch/main/graph/badge.svg)](https://codecov.io/gh/envmodules/modules)
[![Documentation Status](https://readthedocs.org/projects/modules/badge/?version=latest)](https://modules.readthedocs.io/en/latest/?badge=latest)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/envmodules/modules/badge)](https://scorecard.dev/viewer/?uri=github.com/envmodules/modules)
[![Packaging status](https://repology.org/badge/tiny-repos/environment-modules.svg)](https://repology.org/metapackage/environment-modules/versions)
[![Bluesky](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fpublic.api.bsky.app%2Fxrpc%2Fapp.bsky.actor.getProfile%2F%3Factor%3Denvmodules.bsky.social&query=%24.followersCount&style=social&logo=bluesky&label=%40EnvModules)](https://bsky.app/profile/envmodules.bsky.social)
[![Matrix](https://img.shields.io/matrix/modules%3Amatrix.org?color=darkcyan)](https://matrix.to/#/#modules:matrix.org)

Modules, provides dynamic modification of a user's environment
==============================================================

The Modules package is a tool that simplify shell initialization and
lets users easily modify their environment during the session with
modulefiles.

Each modulefile contains the information needed to configure the shell for
an application. Once the Modules package is initialized, the environment can
be modified on a per-module basis using the module command which interprets
modulefiles. Typically modulefiles instruct the module command to alter or
set shell environment variables such as PATH, MANPATH, etc. modulefiles may
be shared by many users on a system and users may have their own collection
to supplement or replace the shared modulefiles.

Modules can be loaded and unloaded dynamically and atomically, in an clean
fashion. All popular shells are supported, including bash, ksh, zsh, sh,
csh, tcsh, fish, cmd, pwsh, as well as some scripting languages such as tcl,
perl, python, ruby, cmake and r.

Modules are useful in managing different versions of applications. Modules
can also be bundled into meta-modules that will load an entire suite of
different applications.


Quick examples
--------------

Here is an example of loading a module on a Linux machine under bash.

    $ module load gcc/12.4.0
    $ which gcc
    $ /usr/local/gcc/12.4.0/linux-x86_64/bin/gcc

Now we'll switch to a different version of the module

    $ module switch gcc/14
    $ which gcc
    /usr/local/gcc/14.2.0/linux-x86_64/bin/gcc

And now we'll unload the module altogether

    $ module unload gcc
    $ which gcc
    gcc not found

Now we'll log into a different machine, using a different shell (tcsh).

    % module load gcc/14.2
    % which gcc
    /usr/local/gcc/14.2.0/linux-aarch64/bin/gcc

Note that the command line is exactly the same, but the path has
automatically configured to the correct architecture.


Getting things running
----------------------

The simplest way to build and install Modules on a Unix system is:

    $ ./configure
    $ make
    $ make install

To learn the details on how to install modules see [`INSTALL.txt`][1] for Unix
system or [`INSTALL-win.txt`][2] for Windows.


Requirements
------------

 * Tcl >= 8.5


Documentation
-------------

See [`MIGRATING`][3] to get an overlook of the new functionalities introduced
by each released versions. [`NEWS`][4] provides the full list of changes added
in each version. The [`Changes`][5] document gives an in-depth view of the
modified behaviors and new features between major versions. You may also look
at the `ChangeLog` for the technical development details.

The `doc` directory contains both the paper and man pages describing the
user's and the module writer's usage. To generate the documentation files,
like the man pages (you need Sphinx >= 1.0 to build the documentation), just
type:

    $ ./configure
    $ make -C doc all

The following man pages are provided:

    module(1), ml(1), modulecmd(1), envml(1), modulefile(5)


Test suite
----------

Regression testing scripts are available in the `testsuite` directory (you
need DejaGnu to run the test suite):

    $ ./configure
    $ make test

Once modules is installed after running `make install`, you have the
ability to test this installation with:

    $ make testinstall


Links
-----

* Web site: https://envmodules.io
* Online documentation: https://modules.readthedocs.io
* GitHub source repository: https://github.com/envmodules/modules
* GitHub Issue tracking system: https://github.com/envmodules/modules/issues


Community
---------

Modules is an open source project. Questions, discussion, and contributions
are welcome. You can get in contact with the Modules community via:

* the [modules-interest mailing list][6]
  (`modules-interest@lists.hpsf.io`)
* the [Modules chat room][7] (`#modules:matrix.org`)
* the [Technical Steering Committee meeting][8]

The project is also present on several social media platforms:

* X/Twitter: [@EnvModules][9]
* Mastodon: [@EnvModules@mast.hpc.social][10]
* Bluesky: [@EnvModules.bsky.social][11]


Contributing
------------

Modules project welcomes contributions of all kinds! Before submitting an
issue or pull request, please take a moment to review our [Contributing
guide][12]. It includes important information about issue reporting, coding
standards, etc.

Please note that Modules project has a [Code of conduct][13]. It ensures a
respectful and inclusive environment for all contributors. By participating in
the Modules community, you agree to abide by its rules.


Governance
----------

Modules is part of the [High Performance Software Foundation](https://hpsf.io)
within the [Linux Foundation](http://linuxfoundation.org).

This project adheres to a [Technical charter][14], which defines its
governance model, decision-making process, and long-term vision.


License
-------

Modules is distributed under the GNU General Public License, either version 2
or (at your option) any later version (`GPL-2.0-or-later`). Read the file
`COPYING.GPLv2` for details.


Authors
-------

Modules current maintainers are:

* Xavier Delaruelle, xavier.delaruelle@cea.fr
* Adrien Cotte, adrien.cotte@asplus.fr

Many thanks go to the [contributors][15] of the Modules project.


Acknowledgments
---------------

We would like to express our gratitude to [CEA][16] for the resources and
funding provided to the project over the recent years.

The following people have notably contributed to Modules and Modules would not
be what it is without their contributions:

* R.K. Owen
* Kent Mein
* Mark Lakata
* Harlan Stenn
* Leo Butler
* Robert Minsk
* Jens Hamisch
* Peter W. Osel
* John L. Furlan


[1]: https://modules.readthedocs.io/en/stable/INSTALL.html
[2]: https://modules.readthedocs.io/en/stable/INSTALL-win.html
[3]: https://modules.readthedocs.io/en/stable/MIGRATING.html
[4]: https://modules.readthedocs.io/en/stable/NEWS.html
[5]: https://modules.readthedocs.io/en/stable/changes.html
[6]: https://lists.hpsf.io/g/modules-interest
[7]: https://matrix.to/#/#modules:matrix.org
[8]: https://modules.readthedocs.io/en/latest/CONTRIBUTING.html#tsc-meeting
[9]: https://x.com/EnvModules
[10]: https://mast.hpc.social/@EnvModules
[11]: https://bsky.app/profile/envmodules.bsky.social
[12]: https://modules.readthedocs.io/en/latest/CONTRIBUTING.html
[13]: CODE_OF_CONDUCT.md
[14]: https://modules.readthedocs.io/en/latest/CHARTER.html
[15]: https://github.com/envmodules/modules/graphs/contributors
[16]: https://www.cea.fr/english
