.. _INSTALL-win:

Installing Modules on Windows
=============================

This document is an overview of building and installing Modules on a Windows
platform.


Requirements
------------

Modules consists of one Tcl script so to run it from a user shell the only
requirement is to have a working version of ``tclsh`` (version 8.5 or later)
available on your system. ``tclsh`` is a part of `Tcl`_.

.. _Tcl: http://www.tcl-lang.org/software/tcltk/

A specific distribution zipball is provided to install Modules on a Windows
platform. Content of this distribution zipball is ready for use and does not
require a specific build step. All scripts and documentation found in this
zipball are pre-built so there is no specific tools are required to install
Modules from the Windows-specific distribution zipball.


Installation instructions
-------------------------

1. Install a Tcl binary distribution for Windows like `ActiveTcl`_ or
   `Magicsplat Tcl/Tk for Windows`_. Follow instructions provided with the
   chosen distribution to install it.

.. _ActiveTcl: https://www.activestate.com/tcl/
.. _Magicsplat Tcl/Tk for Windows: https://www.magicsplat.com/tcl-installer/

2. Once installed, verify that the ``tclsh`` command is correctly found in
   defined ``PATH`` by typing the following command from a Windows ``cmd``
   shell (``windows`` string should be obtained as result)::

        > echo puts $tcl_platform(platform) | tclsh
        windows

3. Download Modules specific distribution zipball for Windows from
   `SourceForge`_ or `GitHub`_. Such distribution archives are available
   for Modules release starting version ``4.5.0`` and can be distinguished
   from the source tarball by the ``-win`` suffix in their name.

.. _SourceForge: https://sourceforge.net/projects/modules/files/Modules/
.. _GitHub: https://github.com/envmodules/modules/releases

4. Unpack downloaded zip file then enter deflated directory and execute the
   ``INSTALL.bat`` script file found in it. This script installs files by
   default in ``C:\Program Files\Environment Modules\`` directory and adds the
   ``bin`` directory in this installation location to the system-wide ``PATH``
   environment variable.

   If you use Powershell Core on Windows, please use the ``INSTALL_PWSH.bat``
   instead. It won't add the ``bin`` directory to the system-wide ``PATH``
   environment variable because the ``module`` command will interfere with
   Powershell's ``module`` keyword.

.. note:: ``INSTALL.bat`` and ``INSTALL_PWSH.bat`` scripts may require to be
   run with administrator rights to perform installation correctly.

5. Once installed, verify that the ``module`` command is correctly found. If
   you used the ``INSTALL.bat`` script, the commands should be in the defined
   ``PATH``. Verify by typing the following command from a Windows ``cmd``
   shell::

        > module -V
        Modules Release 5.5.0 (2024-11-11)

   If your used the ``INSTALL_PWSH.bat`` script, the environment has to be
   initialized first. Verify by typing the following commands from a Windows
   ``cmd`` shell::

        > call "C:\Program Files\Environment Modules\init\cmd.cmd"
        > module -V
        Modules Release 5.5.0 (2024-11-11)

   And the following commands from a Windows ``pwsh`` shell::

        > . "C:\Program Files\Environment Modules\init\pwsh.ps1"
        > envmodule --version
        Modules Release 5.5.0 (2024-11-11)

Installation location can be adapted by running the ``INSTALL.bat`` and
``INSTALL_PWSH.bat`` scripts from a ``cmd`` console shell and passing desired
installation target as argument. For instance to install Modules in
``C:\EnvironmentModules`` directory::

        > INSTALL.bat C:\EnvironmentModules


For PowerShell, you may adapt profile script to make ``envmodule`` command
initialized when ``pwsh`` shell starts. See the PowerShell documentation on
how to `customize your shell environment <https://learn.microsoft.com/en-us/powershell/scripting/learn/shell/creating-profiles>`_.

Alternatively, if you use `Windows Terminal`_, a PowerShell or ``pwsh``
profile can be set to initialize Modules on startup without altering the
system-wide ``PATH`` environment variable and without running an install
script. Once the Windows-specific distribution zipball has been unpacked to
a directory of your choice (for instance ``C:\Program Files\Environment
Modules``), open the Windows Terminal settings, select the profile to
adapt and set its *Command line* to::

        pwsh.exe -NoExit -Command "& Import-Module 'C:\Program Files\Environment Modules\init\pwsh.ps1'"

Use ``powershell.exe`` instead of ``pwsh.exe`` to rely on the Windows
built-in PowerShell rather than PowerShell Core, and adapt the path passed
to ``Import-Module`` to match where the distribution zipball was unpacked.
The ``envmodule`` command then gets initialized every time this profile
starts.

.. _Windows Terminal: https://learn.microsoft.com/en-us/windows/terminal/

Modules installation is now operational and you can setup your modulefiles. By
default, the ``modulefiles`` directory in installation directory is defined as
a modulepath and contains few modulefile examples::

        > module avail
        ------- C:/Program Files/Environment Modules/modulefiles --------
        module-git  module-info  null

Documentation of the :ref:`module(1)`, :ref:`ml(1)` and :ref:`envml(1)`
commands and :ref:`modulefile(5)` syntax can be found in the ``doc`` directory
in installation directory.

.. warning:: If both Modules and the *MSVC x86 toolchain* are installed and
   Modules has been initialized in the current shell session, the command
   ``ml`` will refer to the Modules version rather than the *MSVC assembler*.
   To invoke the *MSVC assembler* while Modules is active, you must call it
   explicitly as ``ml.exe``.
