.. _umask:

umask modulefile command
========================

This design document describes the :mfcmd:`umask` Tcl command that sets the
file mode creation mask of the shell session a modulefile is loaded into.

The file mode creation mask is a property of the shell process. It cannot be
set through an environment variable, so it requires a dedicated modulefile
command that produces the shell code changing it, like :mfcmd:`chdir` does for
the current working directory.

Command specification
---------------------

The command has following syntax::

    umask value

*value* is the mask to set, expressed as an octal number made of one to four
digits. An error is raised otherwise. Symbolic modes are not supported: only
the *sh* family shells understand them and they are relative to the mask in
effect, whereas an octal number is rendered the same way for every shell.

*value* is normalized to a four-digit number (``22`` becomes ``0022``). This
canonical form is the one recorded, compared and rendered.

This command is only available in modulefile evaluation contexts. It is
advised not to use it in global rc files.

Evaluation modes
----------------

* ``load``: the mask is set
* ``unload``: the previous mask is restored (see `Restoring previous mask`_)
* ``display``: the command and its argument are reported
* ``scan``: the mask is recorded, as written in modulefile, to be matched by
  the ``umask`` extra specifier
* ``help``, ``test``, ``whatis``, ``refresh``: *no-operation*

Nothing has to be done on ``refresh`` mode. Unlike shell aliases or functions,
the file mode creation mask is inherited by the processes started from the
shell session, sub-shells included.

When a modulefile calls ``umask`` several times, the last mask set is the one
retained.

If the evaluation of the modulefile fails after a ``umask`` command, the mask
is not changed, like for any other environment change of this modulefile.

Reading current mask
--------------------

The mask in effect has to be known to restore it later on. Tcl provides no
command to read it. :file:`modulecmd.tcl` is run as a child process of the
shell session, so it inherits its mask. The ``umask`` state holds this value,
which is fetched the first time it is needed:

* by the ``initStateUmask`` command of the Modules Tcl extension library, that
  relies on the :manpage:`umask(2)` system call
* by running the ``umask`` command through :command:`sh` when the extension
  library is not available

The mask is only read when a modulefile sets a mask and no mask has been saved
yet. Modulefiles that do not use ``umask`` are not impacted.

Restoring previous mask
-----------------------

Masks set by loaded modules are recorded in the :envvar:`__MODULES_UMASK`
environment variable. It has the same structure than the
:envvar:`__MODULES_PUSHENV_\<VAR\>` variables used by :mfcmd:`pushenv`: a
colon-separated stack whose first entry is the last mask set. An entry is
formed by the name of the module, an ampersand character and the mask. The
mask in effect prior the first ``umask`` command is saved in an entry with an
empty module name.

On ``load``:

* if stack is empty, the current mask is pushed with an empty module name
* any entry of the loading module is removed from the stack
* an entry for the loading module is pushed

On ``unload``:

* the entry of the unloading module is removed from the stack
* if this entry was on top of the stack and if the current mask equals the
  mask recorded in it, the mask of the entry that is now on top is set
* if the only entry remaining in the stack is the one with an empty module
  name, it is removed, which clears the stack

The previous mask is thus restored only if the mask set by the unloading
module is still in effect. Two situations lead to keep the current mask:

* another module has set a mask after the unloading one: its mask remains
* the mask has been changed in the shell session with the ``umask`` shell
  command after the module load: this explicit choice is preserved

The current mask is the one of the shell session, unless a modulefile
evaluated earlier in the same :command:`module` command run has set or
restored a mask. When several modules are unloaded at once (e.g., with
:subcmd:`purge` sub-command), each one finds the mask restored by the
previous one, so the stack is unwound up to the initial mask.

Shell code produced
-------------------

Mask is rendered after the change of current working directory.

+-------------------------+------------------------------------+
| Shell                   | Code for mask ``0077``             |
+=========================+====================================+
| sh, bash, ksh, zsh,     | ``umask 0077;``                    |
| csh, tcsh, fish         |                                    |
+-------------------------+------------------------------------+
| perl                    | ``umask(0077);``                   |
+-------------------------+------------------------------------+
| python                  | ``os.umask(0o0077)``               |
+-------------------------+------------------------------------+
| ruby                    | ``File.umask(0077)``               |
+-------------------------+------------------------------------+
| r                       | ``Sys.umask('0077')``              |
+-------------------------+------------------------------------+
| lisp                    | ``(set-default-file-modes #o0700)``|
+-------------------------+------------------------------------+

Emacs Lisp expresses the setting as the permissions granted to new files,
which is the complement of the mask.

No code is produced for *tcl*, *cmake*, *cmd* and *pwsh*: these shells have no
mean to change their own mask. The command is silently ignored for them, as
done for the other modulefile commands a shell cannot honor.

On Windows platform, an error is raised when ``umask`` is evaluated in
``load`` mode: there is no file mode creation mask to read or to set there.

Mask changed by shell script
----------------------------

:mfcmd:`source-sh` modulefile command and :subcmd:`sh-to-mod` sub-command
track the mask change made by the shell script they evaluate. The ``umask``
shell command is run prior and after script evaluation. If the two masks
differ, a ``umask`` modulefile command setting the resulting mask is produced.

Shells do not report the mask with the same number of digits, so both masks
are normalized before being compared.

``umask`` element can be set on the ``--ignore`` option of ``source-sh`` to
ignore this change.

Limitations
-----------

* A session that gets the loaded environment of another session without
  inheriting its mask (e.g., environment variables forwarded to a new login
  session) sees the module loaded whereas its mask is not applied.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
