.. _INSTALL:




Installing Modules on Unix
==========================

This document is an overview of building and installing Modules on a Unix
system.


Requirements
------------

Modules consists of one Tcl script so to run it from a user shell the only
requirement is to have a working version of ``tclsh`` (version 8.5 or later)
available on your system. ``tclsh`` is a part of Tcl
(http://www.tcl-lang.org/software/tcltk/).

To install Modules from a distribution tarball or a clone of the git
repository, a build step is there to tailor the :file:`modulecmd.tcl` and the
initialization scripts to the chosen installation configuration and create the
documentation files. This build step requires the tools to be found on your
system:

* bash
* make
* sed
* runtest

When also installing Modules Tcl extension library (enabled by default), these
additional tools are needed:

* grep
* gcc
* tcl-devel >= 8.5

When installing from a distribution tarball, documentation is pre-built and
scripts to configure Modules Tcl extension library build are already
generated. Thus no additional software is required. When installing from a
clone of the git repository or from a git archive export, documentation and
scripts to prepare for compilation have to be built and the following tools
are required:

* autoconf
* automake
* autopoint
* m4
* python
* sphinx >= 1.0
* gzip

The following features of Modules rely on external tools. Default tool may be
changed or their location on target system may be specified. Alternatively
these features may also be disabled.

+----------------+-----------------------+-------------------------------+
| Feature option | Default external tool | Installation options          |
+================+=======================+===============================+
| pager          | ``less``              | :instopt:`--with-pager`,      |
|                |                       | ``--without-pager``           |
+----------------+-----------------------+-------------------------------+
| logger         | ``logger``            | :instopt:`--with-logger`,     |
|                |                       | ``--without-logger``          |
+----------------+-----------------------+-------------------------------+
| tcl_linter     | ``nagelfar.tcl``      | :instopt:`--with-tcl-linter`, |
|                |                       | ``--without-linter``          |
+----------------+-----------------------+-------------------------------+

Get Modules
-----------

Modules can usually be installed with the package manager of your Unix system.
It it is available by default `on most Linux distributions, on OS X and
FreeBSD <https://repology.org/project/environment-modules/versions>`_ either
under the name of ``modules`` or ``environment-modules``.

If you want to install Modules from sources, tarballs from all Modules'
releases can be retrieved from one of the following link:

* https://github.com/envmodules/modules/releases/
* https://sourceforge.net/projects/modules/files/Modules/

For instance to download then unpack the last release of Modules:

.. parsed-literal::

    :ps:`$` curl -LJO |gh_tgz_dl_url|
    :ps:`$` tar xfz modules-\ |version|\ .tar.gz

Installation instructions
-------------------------

The simplest way to build and install Modules is:

.. parsed-literal::

    :ps:`$` ./configure
    :ps:`$` make
    :ps:`$` make install

Some explanation, step by step:

1. ``cd`` to the directory containing the package's source code. Your system
   must have the above requirements installed to properly build scripts, and
   documentation if build occurs from a clone of the git repository.

2. Type ``./configure`` to adapt the installation for your system. At this
   step you can choose the installation paths and the features you want to
   enable in the initialization scripts (see `Build and installation options`_
   section below for a complete overview of the available options)

3. Type ``make`` to adapt scripts to the configuration, build Tcl extension
   library if enabled and build documentation if working from git repository.

4. Optionally, type ``make test QUICKTEST=1`` to run the lightweight version
   of the non-regression test suite.

5. Type ``make install`` to install modulecmd.tcl, initialization scripts and
   documentation.

6. Optionally, type ``make testinstall`` to run the installation test suite.

7. You can remove the built files from the source code directory by typing
   ``make clean``. To also remove the files that ``configure`` created, type
   ``make distclean``.

A default installation process like described above will install Modules
under ``/usr/local/Modules``. You can change this with the :instopt:`--prefix`
option. By default, ``/usr/local/Modules/modulefiles`` will be setup as
the default directory containing modulefiles. :instopt:`--modulefilesdir`
option enables to change this directory location. For example:

.. parsed-literal::

    :ps:`$` ./configure --prefix=/usr/share/Modules \\
                  --modulefilesdir=/etc/modulefiles

See `Build and installation options`_ section to discover all ``./configure``
option available.

.. note:: GNU Make is excepted to be used for this build and installation
   process. On non-Linux systems, the ``gmake`` should be called instead of
   ``make``.

.. _enable-modules-in-shells:

Enable Modules in shells
------------------------

Shell initialization scripts should be adapted to enable Modules during their
startup. Enabling Modules means defining the ``module`` shell function and
applying its configuration.

An easy way to achieve that is to make Modules initialization scripts part of
the system-wide environment setup in ``/etc/profile.d``.To do so, make a link
in this directory to the profile scripts that can be found in your Modules
installation init directory. For instance, if Modules has been installed in
``/usr/share/modules``:

.. parsed-literal::

    :ps:`$` ln -s /usr/share/modules/init/profile.sh /etc/profile.d/modules.sh
    :ps:`$` ln -s /usr/share/modules/init/profile.csh /etc/profile.d/modules.csh

These profile scripts will automatically adapt to the kind of ``sh`` or
``csh`` shell you are running.

Another approach is to get the Modules initialization script sourced from the
shell configuration startup file. For instance following line could be added
to the end of the ``~/.bashrc`` file if running Bash shell::

    . /usr/share/modules/init/bash

Beware that shells have multiple ways to initialize depending if they are a
login shell or not and if they are launched in interactive mode or not.

Depending on your OS distribution system-wide profile scripts may be ignored
when initializing non-interactive shells. This is for instance the case on
Debian distribution and its derivatives like Ubuntu. On such system, Modules
initialization script should be sourced by shell initialization files to get
``module`` function defined when executing a command through ``ssh`` or
running a script. Add the following code snippets to the initialization files
of the shell you use.

* For **Bash**, update either system-wide (``/etc/bash.bashrc`` on Debian-like
  systems) or personal (``~/.bashrc``) initialization file:

  .. code-block:: sh

      # enable module command in non-login shells
      if ! shopt -q login_shell; then
          . /usr/share/modules/init/bash
      fi

* For **Csh**/**Tcsh**, add Modules initialization file into Csh rc directory
  (``/etc/csh/cshrc.d`` on Debian-like systems)::

      ln -s /usr/share/modules/init/csh /etc/csh/cshrc.d/modules

  Or update personal (``~/.cshrc``) initialization file:

  .. code-block:: csh

      # enable module command in non-login shells
      if (! $?loginsh) then
          source /usr/share/modules/init/csh
      endif

* For **Zsh**, update either system-wide (``/etc/zsh/zshenv`` on Debian-like
  systems) or personal (``~/.zshenv``) initialization file:

  .. code-block:: sh

      # enable module command
      . /usr/share/modules/init/zsh

* For **Ksh**, update personal (``~/.kshrc``) initialization file:

  .. code-block:: sh

      # enable module command
      . /usr/share/modules/init/ksh

* For **Fish**, add Modules initialization file into Fish system-wide config
  directory (``/etc/fish/conf.d``)::

      ln -s /usr/share/modules/init/fish /etc/fish/conf.d/modules.fish

  Or into Fish personal config directory (``~/.config/fish/conf.d``)::

      ln -s /usr/share/modules/init/fish ~/.config/fish/conf.d/modules.fish

Configuration
-------------

Once installed you should review and adapt the configuration to make it fit
your needs. The following steps are provided for example. They are not
necessarily mandatory as it depends of the kind of setup you want to achieve.

1. Define module paths to enable by default. Edit :file:`initrc` configuration
   file in the directory designated by the :instopt:`--etcdir` option or edit
   :file:`modulespath` in the same directory.

   If you use :file:`modulespath` configuration file, add one line mentioning
   each modulefile directory::

       /path/to/regular/modulefiles
       /path/to/other/modulefiles

   If you use :file:`initrc` configuration file, add one line mentioning each
   modulefile directory prefixed by the :subcmd:`module use<use>` command:

   .. code-block:: tcl

       module use /path/to/regular/modulefiles
       module use /path/to/other/modulefiles

   In case both configuration files :file:`initrc` and :file:`modulespath` are
   present, Modules initialization process will first evaluate
   :file:`modulespath` then :file:`initrc`.

   By default, the modulepaths specified on the :instopt:`--with-modulepath`
   installation option are automatically defined for use in :file:`initrc` (or
   in :file:`modulespath` if the :instopt:`--enable-modulespath` installation
   option has been set).

   .. note:: If you have set :instopt:`--with-initconf-in` to ``initdir`` to
      install the Modules initialization configurations in the configuration
      directory designated by the :instopt:`--initdir` option, the configuration
      files :file:`initrc` and :file:`modulespath` are respectively named
      ``modulerc`` and ``.modulespath``.

2. Define modulefiles to load by default. Edit :file:`initrc` configuration
   file. Modulefiles to load cannot be specified in :file:`modulespath` file.
   Add there all the modulefiles you want to load by default at Modules
   initialization time.

   Add one line mentioning each modulefile to load prefixed by the
   :subcmd:`module load<load>` command:

   .. code-block:: tcl

       module load foo
       module load bar

   By default, the modules specified on the :instopt:`--with-loadedmodules`
   installation option are automatically defined for load in :file:`initrc`.

   Alternatively, if users have :ref:`module collections<collections>` saved
   in their :envvar:`HOME` directory, you may prefer restoring their default
   collection when Modules initializes rather loading the default module list:

   .. code-block:: tcl

       if {[is-saved default]} {
           module restore
       } else {
           module load foo
           module load bar
       }

   In fact you can add to the :file:`initrc` configuration file any kind of
   supported module command, like :subcmd:`module config<config>` commands to
   tune :command:`module`'s default behaviors. This configuration way is
   recommended over directly modifying the shell initialization scripts.

See the `Configuration options`_ section to discover all Modules
:subcmd:`config` options available, their default value and the installation
options linked to them.

If you go through the above steps you should have a valid setup tuned to your
needs. After that you still have to write modulefiles to get something to
load and unload in your newly configured Modules setup. In case you want to
achieve a specific setup, some additional steps may be required:

3. In case the configuration you expect cannot be achieved through the
   :file:`initrc` configuration file, you may review and tune the
   initialization scripts. These files are located in the directory designated
   by the :instopt:`--initdir` option. Beware that these scripts could be
   overwritten when upgrading to a newer version of Modules, so configuration
   should be done through the :file:`initrc` file as far as possible.

4. If you want to alter the way the :file:`modulecmd.tcl` script operates, the
   :file:`siteconfig.tcl` script may be used. This Tcl file is located in the
   directory designated by the :instopt:`--etcdir` option. Every time the
   :command:`module` command is called, it executes the :file:`modulecmd.tcl`
   script which in turns sources the :file:`siteconfig.tcl` script during its
   startup phase. The site-specific configuration script could override
   default configuration values and more largely could supersede all
   procedures defined in :file:`modulecmd.tcl` to obtain specific behaviors.

5. Prior running the module sub-command specified as argument, the
   :file:`modulecmd.tcl` script evaluates the global run-command files. These
   files are either the :file:`rc` file in the directory designated by the
   :instopt:`--etcdir` option, the file(s) designated in the
   :envvar:`MODULERCFILE` environment variable or the user-specific RC file
   located in :file:`$HOME/.modulerc`. The RC files are modulefiles (limited
   to a subset of the :ref:`modulefile Tcl
   commands<Modules specific Tcl commands>`) that could define global module
   aliases, virtual modules or module properties such as tags, forbidding
   rules, etc.

   .. note:: Run-command files are intended to set parameters for
      modulefiles, not to configure the :command:`module` command itself.

To learn more about siteconfig and run-command files, see the
:ref:`Modulecmd startup` section in :ref:`module(1)` reference manual. You may
also look at the available :ref:`setup recipes<cookbook>` to get concrete
deployment examples of these files.

Upgrading
---------

In case you want to upgrade a pre-existing Modules installation, it is
suggested to:

1. Backup configuration files stored in *etcdir* (like :file:`siteconfig.tcl`
   or :file:`initrc`);
2. Remove previous Modules installation;
3. Install new Modules version;
4. Review specific configuration of previous installation and adapt
   configuration files of new version.

It is advised to look at the different documents describing changes and new
features appearing between versions. By reading these documents you will be
able to determine the specific configuration options to apply to satisfy your
use cases.

* :ref:`changes`
* :ref:`NEWS`
* :ref:`MIGRATING`

In case you install Modules with the :instopt:`--enable-versioning` option
set, you may be able to install a new version of Modules alongside existing
ones (if they also have been installed with this option set).

Build and installation options
------------------------------

Options available at the ``./configure`` installation step are described
below. These options enable to choose the installation paths and the features
to enable or disable. You can also get a description of these options by
typing ``./configure --help``.

Fine tuning of the installation directories (the default value for each option
is displayed within brackets):

.. instopt:: --bindir=DIR

 Directory for executables reachable by users [``PREFIX/bin``]

.. instopt:: --datarootdir=DIR

 Base directory to set the man and doc directories [``PREFIX/share``]

.. instopt:: --docdir=DIR

 Directory to host documentation other than man pages like README, license
 file, etc [``DATAROOTDIR/doc``]

.. instopt:: --emacsdatadir=DIR

 Directory to host Emacs addon files [``DATAROOTDIR/emacs/lisp``]

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --etcdir=DIR

 Directory for the executable configuration scripts
 [``PREFIX/etc``]

 .. only:: html or latex

    .. versionadded:: 4.1

.. instopt:: --initdir=DIR

 Directory for the per-shell environment initialization scripts
 [``PREFIX/init``]

.. instopt:: --libdir=DIR

 Directory for object code libraries like libtclenvmodules.so [``PREFIX/lib``]

.. instopt:: --libexecdir=DIR

 Directory for executables called by other executables like modulecmd.tcl
 [``PREFIX/libexec``]

.. instopt:: --mandir=DIR

 Directory to host man pages [``DATAROOTDIR/man``]

.. instopt:: --modulefilesdir=DIR

 Directory of main modulefiles also called system modulefiles
 [``PREFIX/modulefiles``]

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --nagelfardatadir=DIR

 Directory to host Nagelfar linter addon files [``DATAROOTDIR/nagelfar``]

 .. only:: html or latex

    .. versionadded:: 5.2

.. instopt:: --prefix=PREFIX

 Installation root directory [``/usr/local/Modules``]

.. instopt:: --vimdatadir=DIR

 Directory to host Vim addon files [``DATAROOTDIR/vim/vimfiles``]

 .. only:: html or latex

    .. versionadded:: 4.3

Optional Features (the default for each option is displayed within
parenthesis, to disable an option replace ``enable`` by ``disable`` for
instance :instopt:`--disable-set-manpath<--enable-set-manpath>`):

.. instopt:: --enable-advanced-version-spec

 Activate the advanced module version specifiers which enables to finely
 select module versions by specifying after the module name a version
 constraint prefixed by the ``@`` character. This option also allows to
 specify module variants. (default=yes)

 This installation option defines the default value of the
 :mconfig:`advanced_version_spec` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

    .. versionchanged:: 5.0
       Configuration option default set to ``yes``

.. instopt:: --enable-append-binpath

 Append rather prepend binary directory to the PATH environment variable when
 the :instopt:`--enable-set-binpath` option is enabled. (default=no)

 .. only:: html or latex

    .. versionadded:: 4.2

.. instopt:: --enable-append-manpath

 Append rather prepend man page directory to the MANPATH environment variable
 when the :instopt:`--enable-set-manpath` option is enabled. (default=no)

 .. only:: html or latex

    .. versionadded:: 4.2

.. instopt:: --enable-auto-handling

 Set modulecmd.tcl to automatically apply automated modulefiles handling
 actions, like loading the pre-requisites of a modulefile when loading this
 modulefile. (default=yes)

 This installation option defines the default value of the
 :mconfig:`auto_handling` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.0
       Configuration option default set to ``yes``

.. instopt:: --enable-avail-indepth

 When performing an :subcmd:`avail` sub-command, include in search results the
 matching modulefiles and directories and recursively the modulefiles and
 directories contained in these matching directories when enabled or limit
 search results to the matching modulefiles and directories found at the depth
 level expressed by the search query if disabled. (default=yes)

 This installation option defines the default value of the
 :mconfig:`avail_indepth` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --enable-color

 Control if output should be colored by default or not. A value of ``yes``
 equals to the ``auto`` color mode. ``no`` equals to the ``never`` color
 mode. (default=yes)

 This installation option defines the default value of the
 :mconfig:`color` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.0
       Configuration option default set to ``yes``

.. instopt:: --enable-conflict-unload

 Apply automated unload of conflicting modulefiles when loading a module.
 (default=no)

 This installation option defines the default value of the
 :mconfig:`conflict_unload` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. instopt:: --enable-doc-install

 Install the documentation files in the documentation directory defined with
 the :instopt:`--docdir` option. This feature has no impact on manual pages
 installation. Disabling documentation file installation is useful in case of
 installation process handled via a package manager which handles by itself
 the installation of this kind of documents. (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --enable-emacs-addons

 Install the Emacs addon files in the Emacs addons directory defined with the
 :instopt:`--emacsdatadir` option. (default=yes)

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --enable-example-modulefiles

 Install some modulefiles provided as example in the system modulefiles
 directory defined with the :instopt:`--modulefilesdir` option. (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --enable-extended-default

 Allow to specify module versions by their starting part, i.e. substring
 separated from the rest of the version string by a ``.`` character.
 (default=yes)

 This installation option defines the default value of the
 :mconfig:`extended_default` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

    .. versionchanged:: 5.0
       Configuration option default set to ``yes``

.. instopt:: --enable-implicit-default

 Define an implicit default version, for modules with none explicitly defined,
 to select when the name of the module to evaluate is passed without the
 mention of a specific version. When this option is disabled the name of the
 module passed for evaluation should be fully qualified elsewhere an error is
 returned. (default=yes)

 This installation option defines the default value of the
 :mconfig:`implicit_default` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --enable-implicit-requirement

 Implicitly define a prereq or a conflict requirement toward modules specified
 respectively on :mfcmd:`module load<module>` or :mfcmd:`module
 unload<module>` commands in modulefile. (default=yes)

 This installation option defines the default value of the
 :mconfig:`implicit_requirement` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. instopt:: --enable-libtclenvmodules

 Build and install the Modules Tcl extension library which provides optimized
 Tcl commands for the modulecmd.tcl script. (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --enable-mcookie-version-check

 Enable check of the version specified right after Modules magic cookie
 (i.e., ``#%Module`` file signature) in modulefiles, which defines the minimal
 version of the Modules tool to use in order to evaluate the modulefile.
 (default=yes)

 This installation option defines the default value of the
 :mconfig:`mcookie_version_check` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. instopt:: --enable-ml

 Define the :command:`ml` command, a handy frontend to the module command,
 when Modules initializes. (default=yes)

 This installation option defines the default value of the :mconfig:`ml`
 configuration option which could be changed after installation with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.5

.. instopt:: --enable-modulespath, --enable-dotmodulespath

 Set the module paths defined by :instopt:`--with-modulepath` option in a
 :file:`modulespath` file (following C version fashion) within the
 initialization directory defined by the :instopt:`--etcdir` option rather
 than within the :file:`initrc` file. Or respectively, if option
 :instopt:`--with-initconf-in` has been set to ``initdir``, in a
 ``.modulespath`` file within the configuration directory defined by the
 :instopt:`--initdir` option rather than within the ``modulerc`` file.
 (default=no)

 .. only:: html or latex

    .. versionadded:: 4.0

    .. versionchanged:: 4.3
       Option ``--enable-modulespath`` added

.. instopt:: --enable-multilib-support

 Support multilib systems by looking in modulecmd.tcl at an alternative
 location where to find the Modules Tcl extension library depending on current
 machine architecture. (default=no)

 .. only:: html or latex

    .. versionadded:: 4.6

.. instopt:: --enable-nagelfar-addons

 Install the Nagelfar linter addon files (syntax databases and plugins to lint
 modulefiles and modulercs) in the Nagelfar addons directory defined with the
 :instopt:`--nagelfardatadir` option. (default=yes)

 .. only:: html or latex

    .. versionadded:: 5.2

.. instopt:: --enable-new-features

 Enable all new features that are disabled by default due to the substantial
 behavior changes they imply on Modules 5. This option is equivalent to the
 cumulative use of
 :instopt:`--with-abort-on-error=load:ml:reload:switch<--with-abort-on-error>`,
 :instopt:`--enable-conflict-unload` and :instopt:`--enable-require-via`.
 (default=no)

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.0
       Configuration option has been reset following major version change as
       :instopt:`--enable-auto-handling`, :instopt:`--enable-color`,
       :instopt:`--with-icase=search<--with-icase>`,
       :instopt:`--enable-extended-default` and
       :instopt:`--enable-advanced-version-spec` are set by default on Modules
       5.

    .. versionchanged:: 5.4
       Enables *abort on error* behavior on :subcmd:`load` and
       :subcmd:`switch` sub-commands.

    .. versionchanged:: 5.5
       Enables automated *conflict unload* mechanism

    .. versionchanged:: 5.6
       Enables automated *require via* mechanism


.. instopt:: --enable-quarantine-support

 Generate code in module function definition to add support for the
 environment variable quarantine mechanism (default=no)

 This installation option defines the default value of the
 :mconfig:`quarantine_support` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       Configuration option default set to ``no``

.. instopt:: --enable-require-via

 Consider loaded module that enables a modulepath, a requirement of loaded
 modules stored in this modulepath. (default=no)

 This installation option defines the default value of the
 :mconfig:`require_via` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --enable-set-binpath

 Prepend binary directory defined by the :instopt:`--bindir` option to the
 PATH environment variable in the shell initialization scripts. (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --enable-set-manpath

 Prepend man page directory defined by the :instopt:`--mandir` option to the
 MANPATH environment variable in the shell initialization scripts.
 (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --enable-set-shell-startup

 Set when module function is defined the shell startup file to ensure that the
 module function is still defined in sub-shells. (default=no)

 This installation option defines the default value of the
 :mconfig:`set_shell_startup` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.0
       Configuration option default set to ``no``

.. instopt:: --enable-silent-shell-debug-support

 Generate code in module function definition to add support for silencing
 shell debugging properties (default=no)

 This installation option defines the default value of the
 :mconfig:`silent_shell_debug` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.2

    .. versionchanged:: 5.0
       Configuration option default set to ``no``

.. instopt:: --enable-source-cache

 Cache content of files evaluated through :manpage:`source(n)` Tcl command in
 modulefile. When same file is sourced multiple times, cached content is
 reused rather reading file again.

 This installation option defines the default value of the
 :mconfig:`source_cache` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. instopt:: --enable-spider-indepth

 When performing an :subcmd:`spider` sub-command, include in search results
 the matching modulefiles and directories and recursively the modulefiles and
 directories contained in these matching directories when enabled or limit
 search results to the matching modulefiles and directories found at the depth
 level expressed by the search query if disabled. (default=yes)

 This installation option defines the default value of the
 :mconfig:`spider_indepth` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --enable-versioning

 Append Modules version to installation prefix and deploy a ``versions``
 modulepath shared between all versioning enabled Modules installation. A
 modulefile corresponding to Modules version is added to the shared modulepath
 and enables to switch from one Modules version to another. (default=no)

.. instopt:: --enable-unique-name-loaded

 Only allow one module loaded per module name. A conflict is raised when
 loading a module whose name or alternative names are shared by an already
 loaded module. (default=no)

 This installation option defines the default value of the
 :mconfig:`unique_name_loaded` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. instopt:: --enable-vim-addons

 Install the Vim addon files in the Vim addons directory defined with the
 :instopt:`--vimdatadir` option. (default=yes)

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --enable-wa-277

 Activate workaround for issue #277 related to Tcsh history mechanism which
 does not cope well with default module alias definition. Note that enabling
 this workaround solves Tcsh history issue but weakens shell evaluation of the
 code produced by modulefiles. (default=no)

 This installation option defines the default value of the :mconfig:`wa_277`
 configuration option which could be changed after installation with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --enable-windows-support

 Install all required files for Windows platform (:command:`module`,
 :command:`ml` and :command:`envml` command batch file and ``cmd.cmd``
 initialization script). (default=no)

 .. only:: html or latex

    .. versionadded:: 4.5


Optional Packages (the default for each option is displayed within
parenthesis, to disable an option replace ``with`` by ``without`` for
instance :instopt:`--without-modulepath<--with-modulepath>`):

.. instopt:: --with-abort-on-error=LIST

 When evaluating multiple modulefiles, if one fails abort evaluation sequence
 and withdraw already evaluated modulefiles for listed module sub-commands.
 Sub-commands accepted in LIST are: :subcmd:`load`, :command:`ml`,
 :subcmd:`mod-to-sh`, :subcmd:`purge`, :subcmd:`reload`, :subcmd:`switch`,
 :subcmd:`switch_unload<switch>`, :subcmd:`try-load` and :subcmd:`unload`
 (elements in LIST are separated by ``:``).
 (default=\ ``ml:reload:switch_unload``)

 This installation option defines the default value of the
 :mconfig:`abort_on_error` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. instopt:: --with-avail-output=LIST

 Specify the content to report on avail sub-command regular output in addition
 to the available module names. Elements accepted in LIST are: ``modulepath``,
 ``alias``, ``provided-alias``, ``dirwsym``, ``indesym``, ``sym``, ``tag``,
 ``key``, ``hidden``, ``variant``, ``variantifspec`` and ``via`` (elements in
 LIST are separated by ``:``). The order of the elements in LIST does not
 matter. (default=\ ``modulepath:alias:dirwsym:sym:tag:variantifspec:key``)

 This installation option defines the default value of the
 :mconfig:`avail_output` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.3
       Element ``variant`` added

    .. versionchanged:: 5.3
       Element ``variantifspec`` added and set by default

    .. versionchanged:: 5.3.1
       Element ``indesym`` added

    .. versionchanged:: 5.6
       Elements ``hidden``, ``provided-alias`` and ``via`` added

.. instopt:: --with-avail-terse-output=LIST

 Specify the content to report on avail sub-command terse output in addition
 addition to the available module names. Elements accepted in LIST are:
 ``modulepath``, ``alias``, ``provided-alias``, ``dirwsym``, ``indesym``,
 ``sym``, ``tag``, ``key``, ``hidden``, ``variant`` and ``variantifspec``
 (elements in LIST are separated by ``:``). The order of the elements in LIST
 does not matter.
 (default=\ ``modulepath:alias:dirwsym:sym:tag:variantifspec``)

 This installation option defines the default value of the
 :mconfig:`avail_terse_output` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.3
       Element ``variant`` added

    .. versionchanged:: 5.3
       Element ``variantifspec`` added and set by default

    .. versionchanged:: 5.3.1
       Element ``indesym`` added

    .. versionchanged:: 5.6
       Elements ``hidden`` and ``provided-alias`` added

.. instopt:: --with-bashcompletiondir=DIR

 Directory for Bash completion scripts. When this option is not set Bash
 completion script for Modules is installed in the initialization script
 directory and is sourced from Modules Bash initialization script. (default=)

 .. only:: html or latex

    .. versionadded:: 5.1

.. instopt:: --with-bin-search-path=PATHLIST

 List of paths to look at when searching the location of tools required to
 build and configure Modules (default=\ ``/usr/bin:/bin:/usr/local/bin``)

 .. only:: html or latex

    .. versionadded:: 4.2

.. instopt:: --with-dark-background-colors=SGRLIST

 Default color set to apply if terminal background color is defined to
 ``dark``. SGRLIST follows the same syntax than used in ``LS_COLORS``. Each
 element in SGRLIST is an output item associated to a Select Graphic Rendition
 (SGR) code. Elements in SGRLIST are separated by ``:``. Output items are
 designated by keys.

 Items able to be colorized are: highlighted element (``hi``), debug
 information (``db``), trace information (``tr``) tag separator (``se``);
 Error (``er``), warning (``wa``), module error (``me``) and info (``in``)
 message prefixes; Modulepath (``mp``), directory (``di``), module alias
 (``al``), module variant (``va``), module symbolic version (``sy``) and
 module ``default`` version (``de``).

 :ref:`Module tags` can also be colorized. The key to set in the color palette
 to get a graphical rendering of a tag is the tag name or the tag abbreviation
 if one is defined for tag. The SGR code applied to a tag name is ignored if
 an abbreviation is set for this tag thus the SGR code should be defined for
 this abbreviation to get a graphical rendering. Each basic tag has by default
 a key set in the color palette, based on its abbreviated string: auto-loaded
 (``aL``), forbidden (``F``), hidden and hidden-loaded (``H``), loaded
 (``L``), nearly-forbidden (``nF``), sticky (``S``), super-sticky (``sS``),
 keep-loaded (``kL``) and warning (``W``).

 For a complete SGR code reference, see
 https://en.wikipedia.org/wiki/ANSI_escape_code#Select_Graphic_Rendition_parameters.
 (default=\ ``hi=1:db=2:tr=2:se=2:er=91:wa=93:me=95:in=94:mp=1;94:di=94:al=96:va=93:sy=95:de=4:cm=92:aL=100:L=90;47:H=2:F=41:nF=31;43:S=46:sS=44:kL=30;48;5;109:W=30;43``)

 This installation option defines the default value of the :mconfig:`colors`
 configuration option when :mconfig:`term_background` configuration option
 equals ``dark``. :mconfig:`colors` could be changed after installation with
 the :subcmd:`config` sub-command.

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

    .. versionchanged:: 5.6
       Default ``nearly-forbidden`` tag color changed

.. instopt:: --with-editor=BIN

 Name or full path of default editor program to use to open modulefile through
 the :subcmd:`edit` sub-command. (default=\ ``vi``)

 This installation option defines the default value of the :mconfig:`editor`
 configuration option which could be changed after installation with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.8

.. instopt:: --with-fishcompletiondir=DIR

 Directory for Fish completion scripts. When this option is not set Fish
 completion script for Modules is installed in the initialization script
 directory and is sourced from Modules Fish initialization script. (default=)

 .. only:: html or latex

    .. versionadded:: 5.1

.. instopt:: --with-icase=VALUE

 Apply a case insensitive match to module specification on :subcmd:`avail`,
 :subcmd:`whatis` and :subcmd:`paths` sub-commands (when set to ``search``) or
 on all module sub-commands and modulefile Tcl commands for the module
 specification they receive as argument (when set to ``always``). Case
 insensitive match is disabled when this option is set to ``never``.
 (default=\ ``search``)

 This installation option defines the default value of the :mconfig:`icase`
 configuration option which could be changed after installation with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

    .. versionchanged:: 5.0
       Configuration option default set to ``search``

.. instopt:: --with-initconf-in=VALUE

 Location where to install Modules initialization configuration files. Either
 ``initdir`` or ``etcdir`` (default=\ ``etcdir``)

 .. only:: html or latex

    .. versionadded:: 4.1

    .. versionchanged:: 5.0
       Configuration option default set to ``etcdir``

.. instopt:: --with-light-background-colors=SGRLIST

 Default color set to apply if terminal background color is defined to
 ``light``. Expect the same syntax than described for
 :instopt:`--with-dark-background-colors`.
 (default=\ ``hi=1:db=2:tr=2:se=2:er=31:wa=33:me=35:in=34:mp=1;34:di=34:al=36:va=33:sy=35:de=4:cm=32:aL=107:L=47:H=2:F=101:nF=91;103:S=106:sS=104:kL=48;5;109:W=103``)

 This installation option defines the default value of the :mconfig:`colors`
 configuration option when :mconfig:`term_background` configuration option
 equals ``light``. :mconfig:`colors` could be changed after installation with
 the :subcmd:`config` sub-command.

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

    .. versionchanged:: 5.6
       Default ``nearly-forbidden`` tag color changed

.. instopt:: --with-list-output=LIST

 Specify the content to report on list sub-command regular output in addition
 to the loaded module names. Elements accepted in LIST are: ``header``,
 ``idx``, ``variant``, ``alias``, ``indesym``, ``sym``, ``tag``, ``hidden``
 and ``key`` (elements in LIST are separated by ``:``). The order of the
 elements in LIST does not matter. (default=\ ``header:idx:variant:sym:tag:key``)

 This installation option defines the default value of the
 :mconfig:`list_output` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 4.8
       Element ``variant`` added and set by default

    .. versionchanged:: 5.4
       Elements ``alias`` and ``indesym`` added

    .. versionchanged:: 5.6
       Element ``hidden`` added

.. instopt:: --with-list-terse-output=LIST

 Specify the content to report on list sub-command terse output in addition
 to the loaded module names. Elements accepted in LIST are: ``header``,
 ``idx``, ``variant``, ``alias``, ``indesym``, ``sym``, ``tag``, ``hidden``
 and ``key`` (elements in LIST are separated by ``:``). The order of the
 elements in LIST does not matter. (default=\ ``header``)

 This installation option defines the default value of the
 :mconfig:`list_terse_output` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 4.8
       Element ``variant`` added

    .. versionchanged:: 5.4
       Elements ``alias`` and ``indesym`` added

    .. versionchanged:: 5.6
       Element ``hidden`` added

.. instopt:: --with-loadedmodules=MODLIST

 Default modulefiles to load at Modules initialization time. Each modulefile
 in this list should be separated by ``:``. Defined value is registered in the
 :file:`initrc` configuration file or in the ``modulerc`` file if
 :instopt:`--with-initconf-in` is set to ``initdir``. (default=)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --with-locked-configs=CONFIGLIST

 Ignore environment variable superseding value for the listed configuration
 options. Accepted option names in CONFIGLIST are :mconfig:`extra_siteconfig`
 , :mconfig:`implicit_default`, :mconfig:`logged_events` and :mconfig:`logger`
 (each option name should be separated by whitespace character). (default=)

 This installation option defines the default value of the
 :mconfig:`locked_configs` configuration option which cannot not be changed
 after installation.

 .. only:: html or latex

    .. versionadded:: 4.3

    .. versionchanged:: 5.5
       Configs ``logged_events`` and ``logger`` added

.. instopt:: --with-logged-events=EVENTLIST

 Events to log. Accepted event names in EVENTLIST are ``auto_eval``,
 ``requested_eval`` and ``requested_cmd`` (each event name in this list should
 be separated by ``:``). The order of the elements in EVENTLIST does not
 matter. (default=)

 This installation option defines the default value of the
 :mconfig:`logged_events` configuration option which cannot not be changed
 after installation.

 .. only:: html or latex

    .. versionadded:: 5.5

.. instopt:: --with-logger=BIN

 Name or full path of default logger program to use to log information (can be
 superseded at run-time by environment variable) (default=\ ``logger``)

 This installation option and :instopt:`--with-logger-opts` define the default
 value of the :mconfig:`logger` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. instopt:: --with-logger-opts=OPTLIST

 Settings to apply to default logger program (default=\ ``-t modules``)

 This installation option and :instopt:`--with-logger` define the default
 value of the :mconfig:`logger` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.5

.. instopt:: --with-modulepath=PATHLIST

 Default path list to setup as the default modulepaths. Each path in this list
 should be separated by ``:``. Defined value is registered in the
 :file:`initrc` or :file:`modulespath` configuration file, depending on the
 :instopt:`--enable-modulespath` option. These files are respectively called
 ``modulerc`` and ``.modulespath`` if :instopt:`--with-initconf-in` is set to
 ``initdir``. The path list value is read at initialization time to populate
 the MODULEPATH environment variable. By default, this modulepath is composed
 of the directory set for the system modulefiles
 (default=\ ``PREFIX/modulefiles`` or
 ``BASEPREFIX/$MODULE_VERSION/modulefiles`` if versioning installation mode
 enabled)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --with-moduleshome

 Location of the main Modules package file directory (default=\ ``PREFIX``)

 This installation option defines the default value of the :mconfig:`home`
 configuration option which could be changed after installation with the
 :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.4

.. instopt:: --with-nearly-forbidden-days=VALUE

 Define the number of days a module is considered nearly forbidden prior
 reaching its expiry date. VALUE should be an integer comprised between 0 and
 365. (default=\ ``14``)

 This installation option defines the default value of the
 :mconfig:`nearly_forbidden_days` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.6

.. instopt:: --with-pager=BIN

 Name or full path of default pager program to use to paginate informational
 message output (can be superseded at run-time by environment variable)
 (default=\ ``less``)

 This installation option and :instopt:`--with-pager-opts` define the default
 value of the :mconfig:`pager` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

.. instopt:: --with-pager-opts=OPTLIST

 Settings to apply to default pager program (default=\ ``-eFKRX``)

 This installation option and :instopt:`--with-pager` define the default value
 of the :mconfig:`pager` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.1

.. instopt:: --with-python=BIN

 Name or full path of Python interpreter command to set as shebang for helper
 scripts. (default=\ ``python``)

 .. only:: html or latex

    .. versionadded:: 4.5

.. instopt:: --with-quarantine-vars=<VARNAME[=VALUE] ...>

 Environment variables to put in quarantine when running the module command to
 ensure it a sane execution environment (each variable should be separated by
 space character). A value can eventually be set to a quarantine variable
 instead of emptying it. (default=)

 This installation option defines the default value of the
 :envvar:`MODULES_RUN_QUARANTINE` and :envvar:`MODULES_RUNENV_\<VAR\>`
 environment variables which could be changed after installation with the
 :subcmd:`config` sub-command on :mconfig:`run_quarantine` configuration
 option.

 .. only:: html or latex

    .. versionadded:: 4.1

.. instopt:: --with-search-match=VALUE

 When searching for a module with :subcmd:`avail` sub-command, match query
 string against module name start (``starts_with``) or any part of module name
 string (``contains``). (default=\ ``starts_with``)

 This installation option defines the default value of the
 :mconfig:`search_match` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --with-spider-output=LIST

 Specify the content to report on spider sub-command regular output in
 addition to the available module names. Elements accepted in LIST are:
 ``modulepath``, ``alias``, ``provided-alias``, ``dirwsym``, ``indesym``,
 ``sym``, ``tag``, ``key``, ``hidden``, ``variant``, ``variantifspec`` and
 ``via`` (elements in LIST are separated by ``:``). The order of the elements
 in LIST does not matter.
 (default=\ ``modulepath:alias:dirwsym:sym:tag:variantifspec:via:key``)

 This installation option defines the default value of the
 :mconfig:`spider_output` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --with-spider-terse-output=LIST

 Specify the content to report on spider sub-command terse output in addition
 addition to the available module names. Elements accepted in LIST are:
 ``modulepath``, ``alias``, ``provided-alias``, ``dirwsym``, ``indesym``,
 ``sym``, ``tag``, ``key``, ``hidden``, ``variant`` and ``variantifspec``
 (elements in LIST are separated by ``:``). The order of the elements in LIST
 does not matter.
 (default=\ ``modulepath:alias:dirwsym:sym:tag:variantifspec``)

 This installation option defines the default value of the
 :mconfig:`spider_terse_output` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.6

.. instopt:: --with-sticky-purge=VALUE

 When unloading a sticky or super-sticky module during a module purge, raise
 an ``error`` or emit a ``warning`` message or be ``silent``.
 (default=\ ``error``)

 This installation option defines the default value of the
 :mconfig:`sticky_purge` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.4

.. instopt:: --with-tag-abbrev=ABBRVLIST

 Define the abbreviation to use when reporting each module tag. Each element
 in ABBRVLIST is a tag name associated to an abbreviation string (elements in
 ABBRVLIST are separated by ``:``).
 (default=\ ``auto-loaded=aL:loaded=L:hidden=H:hidden-loaded=H:forbidden=F:nearly-forbidden=nF:sticky=S:super-sticky=sS:keep-loaded=kL:warning=W``)

 This installation option defines the default value of the
 :mconfig:`tag_abbrev` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

    .. versionchanged:: 5.1
       Abbreviation for ``keep-loaded`` tag added

    .. versionchanged:: 5.6
       Abbreviation for ``warning`` tag added

.. instopt:: --with-tag-color-name=TAGLIST

 Define the tags whose graphical rendering should be applied over their name
 instead of over the name of the module they are attached to. Each element in
 TAGLIST is a tag name or abbreviation (elements in TAGLIST are separated by
 ``:``). (default=)

 This installation option defines the default value of the
 :mconfig:`tag_color_name` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.7

.. instopt:: --with-tcl

 Directory containing the Tcl configuration script ``tclConfig.sh``. Useful to
 compile Modules Tcl extension library if this file cannot be automatically
 found in default locations.

.. instopt:: --with-tclinclude

 Directory containing the Tcl header files. Useful to compile Modules Tcl
 extension library if these headers cannot be automatically found in default
 locations.

.. instopt:: --with-tclsh=BIN

 Name or full path of Tcl interpreter shell (default=\ ``tclsh``)

 .. only:: html or latex

    .. versionadded:: 4.0

.. instopt:: --with-tcl-linter=BIN

 Name or full path of program to use to lint modulefile through the
 :subcmd:`lint` sub-command. (default=\ ``nagelfar.tcl``)

 This installation option and :instopt:`--with-tcl-linter-opts` define the
 default value of the :mconfig:`tcl_linter` configuration option which could
 be changed after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.2

.. instopt:: --with-tcl-linter-opts=OPTLIST

 Settings to apply to Tcl linter program (default=)

 This installation option and :instopt:`--with-tcl-linter` define the default
 value of the :mconfig:`tcl_linter` configuration option which could be
 changed after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 5.2

.. instopt:: --with-terminal-background=VALUE

 The terminal background color that determines the color set to apply by
 default between the ``dark`` background colors or the ``light`` background
 colors (default=\ ``dark``)

 This installation option defines the default value of the
 :mconfig:`term_background` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --with-unload-match-order=VALUE

 When unloading a module if multiple loaded modules match the request, unload
 module loaded first (``returnfirst``) or module loaded last (``returnlast``)
 (default=\ ``returnlast``)

 This installation option defines the default value of the
 :mconfig:`unload_match_order` configuration option which could be changed
 after installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --with-variant-shortcut=SHORTCUTLIST

 Define the shortcut characters that could be used to specify variant names.
 Each element in SHORTCUTLIST is a variant name associated to a shortcut
 character (e.g., ``foo=%``). Shortcuts cannot exceed a length of 1 character
 and cannot be alphanumeric characters ([A-Za-z0-9]) or characters with
 already a special meaning ([+~/@=-]). Elements in SHORTCUTLIST are separated
 by ``:``. (default=)

 This installation option defines the default value of the
 :mconfig:`variant_shortcut` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.8

.. instopt:: --with-verbosity=VALUE

 Specify default message verbosity. accepted values are ``silent``,
 ``concise``, ``normal``, ``verbose``, ``verbose2``, ``trace``, ``debug`` and
 ``debug2``. (default=\ ``normal``)

 This installation option defines the default value of the
 :mconfig:`verbosity` configuration option which could be changed after
 installation with the :subcmd:`config` sub-command.

 .. only:: html or latex

    .. versionadded:: 4.3

.. instopt:: --with-zshcompletiondir=DIR

 Directory for Zsh completion scripts. When this option is not set Zsh
 completion script for Modules is installed in the initialization script
 directory and :envvar:`FPATH` is set in Zsh initialization script to point to
 this location. (default=)

 .. only:: html or latex

    .. versionadded:: 5.1


Configuration options
---------------------

Options available through the :subcmd:`config` sub-command are described
below. In addition to their default value, the related installation option,
environment variable and command-line switch are listed for each configuration
option. This table also describes if each configuration option needs to be set
prior or during Modules initialization and if it can be modified after
installation.

+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| Configuration option              | Default value                                | Related installation option, environment     | Set prior or | Cannot be |
|                                   |                                              | variable and command-line switch             | during init\ | altered   |
|                                   |                                              |                                              | ialization   |           |
+===================================+==============================================+==============================================+==============+===========+
| :mconfig:`abort_on_error`         | ``ml:reload:switch_unload``                  | :instopt:`--with-abort-on-error`,            |              |           |
|                                   |                                              | :envvar:`MODULES_ABORT_ON_ERROR`             |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`advanced_version_spec`  | ``1``                                        | :instopt:`--enable-advanced-version-spec`,   |              |           |
|                                   |                                              | :envvar:`MODULES_ADVANCED_VERSION_SPEC`      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`auto_handling`          | ``1``                                        | :instopt:`--enable-auto-handling`,           |              |           |
|                                   |                                              | :envvar:`MODULES_AUTO_HANDLING`,             |              |           |
|                                   |                                              | :option:`--auto`, :option:`--no-auto`        |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`avail_indepth`          | ``1``                                        | :instopt:`--enable-avail-indepth`,           |              |           |
|                                   |                                              | :envvar:`MODULES_AVAIL_INDEPTH`,             |              |           |
|                                   |                                              | :option:`--indepth`, :option:`--no-indepth`  |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`avail_output`           | modulepath:alias:dirwsym:sym:tag:\           | :instopt:`--with-avail-output`,              |              |           |
|                                   | variantifspec:key                            | :envvar:`MODULES_AVAIL_OUTPUT`,              |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`avail_terse_output`     | modulepath:alias:dirwsym:sym:tag:\           | :instopt:`--with-avail-terse-output`,        |              |           |
|                                   | variantifspec                                | :envvar:`MODULES_AVAIL_TERSE_OUTPUT`,        |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`cache_buffer_bytes`     | ``32768``                                    | :envvar:`MODULES_CACHE_BUFFER_BYTES`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`cache_expiry_secs`      | ``0``                                        | :envvar:`MODULES_CACHE_EXPIRY_SECS`          |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`collection_pin_version` | ``0``                                        | :envvar:`MODULES_COLLECTION_PIN_VERSION`     |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`collection_pin_tag`     | ``0``                                        | :envvar:`MODULES_COLLECTION_PIN_TAG`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`collection_target`      | *Unset by default*                           | :envvar:`MODULES_COLLECTION_TARGET`          |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`color`                  | ``auto``                                     | :instopt:`--enable-color`,                   |              |           |
|                                   |                                              | :envvar:`MODULES_COLOR`,                     |              |           |
|                                   |                                              | :option:`--color`                            |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`colors`                 | hi=1:db=2:tr=2:se=2:er=91:wa=93:\            | :instopt:`--with-dark-background-colors`,    |              |           |
|                                   | me=95:in=94:mp=1;94:di=94:al=96:va=93:sy=95\ | :instopt:`--with-light-background-colors`,   |              |           |
|                                   | :de=4:cm=92:aL=100:L=90;47:H=2:F=41:\        | :envvar:`MODULES_COLORS`                     |              |           |
|                                   | nF=31;43:S=46:sS=44:kL=30;48;5;109:W=30;43   |                                              |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`conflict_unload`        | ``0``                                        | :instopt:`--enable-conflict-unload`,         |              |           |
|                                   |                                              | :envvar:`MODULES_CONFLICT_UNLOAD`            |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`contact`                | ``root@localhost``                           | :envvar:`MODULECONTACT`                      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`extended_default`       | ``1``                                        | :instopt:`--enable-extended-default`,        |              |           |
|                                   |                                              | :envvar:`MODULES_EXTENDED_DEFAULT`           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`editor`                 | ``vi``                                       | :instopt:`--with-editor`,                    |              |           |
|                                   |                                              | :envvar:`MODULES_EDITOR`                     |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`extra_siteconfig`       | *Unset by default*                           | :envvar:`MODULES_SITECONFIG`                 |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`hide_auto_loaded`       | ``0``                                        | :envvar:`MODULES_HIDE_AUTO_LOADED`           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`home`                   | |file prefix|                                | :instopt:`--prefix`,                         |              |           |
|                                   |                                              | :instopt:`--with-moduleshome`,               |              |           |
|                                   |                                              | :envvar:`MODULESHOME`                        |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`icase`                  | ``search``                                   | :instopt:`--with-icase`,                     |              |           |
|                                   |                                              | :envvar:`MODULES_ICASE`,                     |              |           |
|                                   |                                              | :option:`--icase`                            |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`ignore_cache`           | ``0``                                        | :envvar:`MODULES_IGNORE_CACHE`,              |              |           |
|                                   |                                              | :option:`--ignore-cache`                     |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`ignore_user_rc`         | ``0``                                        | :envvar:`MODULES_IGNORE_USER_RC`,            |              |           |
|                                   |                                              | :option:`--ignore-user-rc`                   |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`ignored_dirs`           | ``CVS RCS SCCS .svn .git .SYNC .sos``        |                                              |              | X         |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`implicit_default`       | ``1``                                        | :instopt:`--enable-implicit-default`,        |              |           |
|                                   |                                              | :envvar:`MODULES_IMPLICIT_DEFAULT`           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`implicit_requirement`   | ``1``                                        | :instopt:`--enable-implicit-requirement`,    |              |           |
|                                   |                                              | :envvar:`MODULES_IMPLICIT_REQUIREMENT`       |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`list_output`            | ``header:idx:variant:sym:tag:key``           | :instopt:`--with-list-output`,               |              |           |
|                                   |                                              | :envvar:`MODULES_LIST_OUTPUT`,               |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`list_terse_output`      | ``header``                                   | :instopt:`--with-list-terse-output`,         |              |           |
|                                   |                                              | :envvar:`MODULES_LIST_TERSE_OUTPUT`,         |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`locked_configs`         | *Empty by default*                           | :instopt:`--with-locked-configs`             |              | X         |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`logged_events`          | *Empty by default*                           | :instopt:`--with-logged-events`,             |              |           |
|                                   |                                              | :envvar:`MODULES_LOGGED_EVENTS`              |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`logger`                 | ``logger -t modules``                        | :instopt:`--with-logger`,                    |              |           |
|                                   |                                              | :instopt:`--with-logger-opts`,               |              |           |
|                                   |                                              | :envvar:`MODULES_LOGGER`                     |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`mcookie_check`          | ``always``                                   | :envvar:`MODULES_MCOOKIE_CHECK`              |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`mcookie_version_check`  | ``1``                                        | :instopt:`--enable-mcookie-version-check`,   |              |           |
|                                   |                                              | :envvar:`MODULES_MCOOKIE_VERSION_CHECK`      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`ml`                     | ``1``                                        | :instopt:`--enable-ml`,                      | X            |           |
|                                   |                                              | :envvar:`MODULES_ML`                         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`nearly_forbidden_days`  | ``14``                                       | :instopt:`--with-nearly-forbidden-days`,     |              |           |
|                                   |                                              | :envvar:`MODULES_NEARLY_FORBIDDEN_DAYS`      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`pager`                  | ``less -eFKRX``                              | :instopt:`--with-pager`,                     |              |           |
|                                   |                                              | :instopt:`--with-pager-opts`,                |              |           |
|                                   |                                              | :envvar:`MODULES_PAGER`,                     |              |           |
|                                   |                                              | :option:`--paginate`, :option:`--no-pager`   |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`path_entry_reorder`     | ``0``                                        | :instopt:`--enable-path-entry-reorder`,      |              |           |
|                                   |                                              | :envvar:`MODULES_PATH_ENTRY_REORDER`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`protected_envvars`      | *Unset by default*                           | :envvar:`MODULES_PROTECTED_ENVVARS`          |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`quarantine_support`     | ``0``                                        | :instopt:`--enable-quarantine-support`,      | X            |           |
|                                   |                                              | :envvar:`MODULES_QUARANTINE_SUPPORT`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`rcfile`                 | *Unset by default*                           | :envvar:`MODULERCFILE`                       |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`redirect_output`        | ``1``                                        | :envvar:`MODULES_REDIRECT_OUTPUT`,           |              |           |
|                                   |                                              | :option:`--redirect`,                        |              |           |
|                                   |                                              | :option:`--no-redirect`                      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`require_via`            | ``0``                                        | :instopt:`--enable-require-via`,             |              |           |
|                                   |                                              | :envvar:`MODULES_REQUIRE_VIA`                |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`reset_target_state`     | ``__init__``                                 | :envvar:`MODULES_RESET_TARGET_STATE`,        |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`run_quarantine`         | *Empty by default*                           | :instopt:`--with-quarantine-vars`,           |              |           |
|                                   |                                              | :envvar:`MODULES_RUN_QUARANTINE`             |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`search_match`           | ``starts_with``                              | :instopt:`--with-search-match`,              |              |           |
|                                   |                                              | :envvar:`MODULES_SEARCH_MATCH`,              |              |           |
|                                   |                                              | :option:`--contains`,                        |              |           |
|                                   |                                              | :option:`--starts-with`                      |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`set_shell_startup`      |  ``0``                                       | :instopt:`--enable-set-shell-startup`,       | X            |           |
|                                   |                                              | :envvar:`MODULES_SET_SHELL_STARTUP`          |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`shells_with_ksh_fpath`  | *Empty by default*                           | :envvar:`MODULES_SHELLS_WITH_KSH_FPATH`      | X            |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`silent_shell_debug`     | ``0``                                        | :instopt:`--enable-silent-shell-debug-\      | X            |           |
|                                   |                                              | support`,                                    |              |           |
|                                   |                                              | :envvar:`MODULES_SILENT_SHELL_DEBUG`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`siteconfig`             | |file etcdir_siteconfig|                     | :instopt:`--prefix`, :instopt:`--etcdir`     |              | X         |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`source_cache`           | ``0``                                        | :instopt:`--enable-source-cache`,            |              |           |
|                                   |                                              | :envvar:`MODULES_SOURCE_CACHE`               |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`spider_indepth`         | ``1``                                        | :instopt:`--enable-spider-indepth`,          |              |           |
|                                   |                                              | :envvar:`MODULES_SPIDER_INDEPTH`,            |              |           |
|                                   |                                              | :option:`--indepth`, :option:`--no-indepth`  |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`spider_output`          | modulepath:alias:dirwsym:sym:tag:\           | :instopt:`--with-spider-output`,             |              |           |
|                                   | variantifspec:via:key                        | :envvar:`MODULES_SPIDER_OUTPUT`,             |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`spider_terse_output`    | modulepath:alias:dirwsym:sym:tag:\           | :instopt:`--with-spider-terse-output`,       |              |           |
|                                   | variantifspec                                | :envvar:`MODULES_SPIDER_TERSE_OUTPUT`,       |              |           |
|                                   |                                              | :option:`--output`                           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`sticky_purge`           | ``error``                                    | :instopt:`--with-sticky-purge`,              |              |           |
|                                   |                                              | :envvar:`MODULES_STICKY_PURGE`               |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`tag_abbrev`             | auto-loaded=aL:loaded=L:hidden=H:\           | :instopt:`--with-tag-abbrev`,                |              |           |
|                                   | hidden-loaded=H:forbidden=F:nearly-\         | :envvar:`MODULES_TAG_ABBREV`                 |              |           |
|                                   | forbidden=nF:sticky=S:super-sticky=sS:\      |                                              |              |           |
|                                   | keep-loaded=kL:warning=W                     |                                              |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`tag_color_name`         | *Empty by default*                           | :instopt:`--with-tag-color-name`,            |              |           |
|                                   |                                              | :envvar:`MODULES_TAG_COLOR_NAME`             |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`tcl_ext_lib`            | |file libdir_tcl_ext_lib|                    |                                              |              | X         |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`tcl_linter`             | ``nagelfar.tcl``                             | :instopt:`--with-tcl-linter`,                |              |           |
|                                   |                                              | :instopt:`--with-tcl-linter-opts`,           |              |           |
|                                   |                                              | :envvar:`MODULES_TCL_LINTER`                 |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`term_background`        | ``dark``                                     | :instopt:`--with-terminal-background`,       |              |           |
|                                   |                                              | :envvar:`MODULES_TERM_BACKGROUND`            |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`term_width`             | ``0``                                        | :envvar:`MODULES_TERM_WIDTH`,                |              |           |
|                                   |                                              | :option:`--width`                            |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`unique_name_loaded`     | ``0``                                        | :instopt:`--enable-unique-name-loaded`,      |              |           |
|                                   |                                              | :envvar:`MODULES_UNIQUE_NAME_LOADED`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`unload_match_order`     | ``returnlast``                               | :instopt:`--with-unload-match-order`,        |              |           |
|                                   |                                              | :envvar:`MODULES_UNLOAD_MATCH_ORDER`         |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`variant_shortcut`       | *Empty by default*                           | :instopt:`--with-variant-shortcut`,          |              |           |
|                                   |                                              | :envvar:`MODULES_VARIANT_SHORTCUT`           |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`verbosity`              | ``normal``                                   | :instopt:`--with-verbosity`,                 |              |           |
|                                   |                                              | :envvar:`MODULES_VERBOSITY`,                 |              |           |
|                                   |                                              | :option:`--debug`, :option:`--silent`,       |              |           |
|                                   |                                              | :option:`--trace`, :option:`--verbose`       |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
| :mconfig:`wa_277`                 | ``1``                                        | :instopt:`--enable-wa-277`,                  | X            |           |
|                                   |                                              | :envvar:`MODULES_WA_277`                     |              |           |
+-----------------------------------+----------------------------------------------+----------------------------------------------+--------------+-----------+
