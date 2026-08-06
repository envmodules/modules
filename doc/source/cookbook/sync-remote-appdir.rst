.. _sync-remote-appdir:

Sync remote application directories on first load
=================================================

Some workstations and laptops mount a network share holding all kind of
software installations that may be used on this machine, alongside their own
local, faster disk. Reading application files directly from this network
share on every use works, but it is slower than reading them from local
disk, and it stops working entirely when the machine goes offline.

This recipe describes how to keep modulefiles pointing at application
directories on a network share mounted under :file:`/remote_apps`, while
transparently copying, with the `rsync`_ tool, the directory of a given
application to :file:`/local_apps` the first time the corresponding module
is loaded. Every later load of the same module finds its application
directory already synced locally and skips the copy.

.. _rsync: https://rsync.samba.org/

Implementation
--------------

A :file:`.module_appdir_map` file, located at the root of the
:file:`/remote_apps` network share, maps each module name and version to the
basename of its application directory under :file:`/remote_apps`:

.. literalinclude:: ../../example/sync-remote-appdir/.module_appdir_map
   :caption: /remote_apps/.module_appdir_map

The :file:`.modulerc` file at the root of the modulepath reads this map file
and applies the ``remote`` tag, with the :mfcmd:`module-tag` modulefile
command, to every module listed in it whose application directory has not
been synced locally yet -- tracked by the presence of a
:file:`.<basename>.synced` marker file under :file:`/local_apps`:

.. literalinclude:: ../../example/sync-remote-appdir/modulefiles/.modulerc
   :language: tcl
   :caption: modulefiles/.modulerc

The actual sync is performed by a :mhook:`before-modulefile-eval` hook,
registered with the ``add-hook`` siteconfig command (see the :ref:`hook-api`
design notes and the *Hooks* section of :manpage:`module(1)` man page). The
hook procedure returns immediately if the evaluation mode is not ``load``,
or if the module being evaluated is not tagged ``remote`` -- checked with
:mfcmd:`module-info tags<module-info>`, run in the modulefile Tcl
interpreter reached through ``getCurrentModfileInterpName``, exactly as
already documented for a hook procedure that needs to run modulefile
commands. Otherwise, it looks up the application directory basename mapped
to the module in :file:`.module_appdir_map`, and skips the sync if this
directory was already marked as synced by a previous load. Otherwise it
copies the application directory with ``rsync`` and, on success, touches
the :file:`.<basename>.synced` marker file so later loads skip the copy.

Because the modulepath root :file:`.modulerc` tags a module ``remote`` ahead
of the sync actually happening, this tag would otherwise still be recorded
as applying to the module once loaded, which is misleading once its
application directory has just been synced locally. The ``remote`` tag is
therefore added to the :mconfig:`non_exportable_tags` configuration option,
introduced in Modules v5.7 together with the hook API, so it is dropped from
the tag list persisted once a module is loaded, without affecting how it is
reported beforehand, for instance on an :subcmd:`avail` listing. The
``remote`` tag is also given its own abbreviation and color, so modules
whose application directory has not been synced yet stand out on an
:subcmd:`avail` or :subcmd:`spider` listing. These ``module config`` calls
are set in |file etcdir_initrc|, evaluated once when the ``module`` shell
function initializes with :subcmd:`autoinit`, the only context ``module
config`` is usable from within a file evaluated by Modules itself:

.. literalinclude:: ../../example/sync-remote-appdir/initrc
   :language: tcl
   :caption: initrc

The sync itself is triggered by the hook procedure, defined and registered
in :file:`siteconfig.tcl`:

.. literalinclude:: ../../example/sync-remote-appdir/siteconfig.tcl
   :language: tcl
   :caption: siteconfig.tcl

Since the hook fires before the modulefile itself is evaluated, and the sync
is performed with a blocking ``exec`` call, ``module load`` waits for the
copy to complete before the modulefile that relies on the now-local
application directory gets evaluated. A hook procedure cannot abort the
evaluation it wraps, so a sync failure is reported as an error but does not
prevent the module from loading afterward, even though its application
directory may still be missing locally in that case.

**Compatible with Modules v5.7+**

Installation
------------

Create site-specific configuration directory if it does not exist yet:

.. parsed-literal::

    $ mkdir \ |etcdir|

Copy the site-specific configuration script and initialization file of this
recipe:

.. parsed-literal::

    $ cp example/sync-remote-appdir/siteconfig.tcl \ |etcdir|\ /
    $ cp example/sync-remote-appdir/initrc \ |etcdir|\ /

.. note::

   Defined location for the site-specific configuration script may vary from
   one installation to another. To determine the expected location for this
   file on your setup, check the value of the ``siteconfig`` configuration
   option:

   .. parsed-literal::

       :ps:`$` module config siteconfig

Adapt :file:`modulefiles/.modulerc` to your modulepath, and copy it at its
root, next to the modulefiles it applies to. Finally, create
:file:`/remote_apps/.module_appdir_map` on the network share, with one
``<module_name_and_version> <software_install_directory_basename>`` entry
per line for each application directory that should be synced this way.

Usage example
-------------

The application directory of ``foo/2.1`` has not been synced locally yet, so
it shows up tagged ``remote`` on an :subcmd:`avail` listing, using the
abbreviation and color configured for this tag:

.. parsed-literal::

    :ps:`$` module avail foo
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/2.1 <R>

    Key:
    <module-tag>  <R>=remote

Loading it triggers the sync, then proceeds with the load once the copy
completes:

.. parsed-literal::

    :ps:`$` module load foo/2.1
    Syncing 'foo-2.1-build3' application directory from remote share...
    Loading :sgrhi:`foo/2.1`

Once loaded, the module no longer carries the ``remote`` tag, since its
application directory now lives on local disk:

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) foo/2.1

A later load, after the module has been unloaded, finds the
:file:`.foo-2.1-build3.synced` marker file and skips the sync entirely,
and the module no longer shows up tagged ``remote`` on :subcmd:`avail`
either:

.. parsed-literal::

    :ps:`$` module unload foo/2.1
    :ps:`$` module avail foo
    --------------- :sgrdi:`/path/to/modulefiles` ---------------
    foo/2.1
    :ps:`$` module load foo/2.1
    Loading :sgrhi:`foo/2.1`

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
