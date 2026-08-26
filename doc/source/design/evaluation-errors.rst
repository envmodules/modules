.. _evaluation-errors:

Evaluation errors
=================

This document describes the different evaluation errors, depending on the
evaluation modes. The obtained behaviors when these errors raise and the
configuration options or command-line switches that change these behaviors.

Error kinds
-----------

The following list describes the different kind of evaluation error:

* *bad code*: modulefile has some code error (e.g., bad Tcl syntax, using
  undefined commands)
* *break*: use of ``break`` Tcl command in modulefile
* *exit*: use of ``exit`` Tcl command in modulefile
* *error*: use of ``error`` Tcl command in modulefile
* *not found*: designated modulefile cannot be found
* *hard hidden*: designated modulefile is hidden in ``--hard`` mode and cannot
  be found
* *not loaded*: when unloading a module, designated modulefile is not found
  loaded
* *already loaded*: when loading a module, designated modulefile is already
  loaded
* *conflict*: dependency issue where loading modulefile conflicts with at
  least one loaded module
* *missing requirement*: dependency issue where a loading modulefile has at
  least one requirement module not loaded
* *dependent reload*: dependency issue where a loading or unloading modulefile
  has at least one dependent module that fails to reload (either during the
  unload or load phase)
* *unloading dependent*: dependency issue where an unloading modulefile has at
  least one loaded module requiring it
* *forbidden*: evaluated modulefile is tagged forbidden
* *sticky unload*: when unloading a module tagged sticky
* *super-sticky unload*: when unloading a module tagged super-sticky
* *dependent sticky reload*: *dependent reload* special case where a sticky
  dependent module fails to reload (during the load phase)
* *dependent super-sticky reload*: *dependent reload* special case where a
  super-sticky dependent module fails to reload (during the load phase)

.. note:: Use of ``continue`` Tcl command in modulefile shortens evaluation
   but it is not considered an error.

.. note:: When a *dependent reload* issue occurs during the load or unload of
   a modulefile, the dependent module failing to reload has raised one of the
   following error kind: bad code, break, exit, error, conflict, missing
   requirement, forbidden or hard hidden.

Behavior when error raises
--------------------------

This section describes the behaviors generally obtained when the different
error kinds raise.

Other specific behavior depending on evaluation mode or configuration options
are described in the following parts of the document.

.. _default:

Default
^^^^^^^

Default behavior when an error raises:

* current modulefile evaluation is aborted
* an error message is reported
* exit code is set to 1

Ignored errors
^^^^^^^^^^^^^^

The following error kinds are *ignored errors*:

* not loaded
* already loaded

These errors lead to a different behavior:

* current modulefile evaluation is skipped
* no message reported
* no error exit code set

Errors raised during modulefile evaluation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Following errors are raised during the Tcl evaluation of a modulefile:

* bad code
* break
* exit
* error
* conflict (also raised outside modulefile evaluation)
* missing requirement

Evaluation mode or options specific behaviors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some error kinds only occur during specific evaluation mode or when
configuration options are set to a given value.

+---------------------+------------+-------------------------------+
| Error kind          | Evaluation | Configuration option          |
|                     | mode       |                               |
+=====================+============+===============================+
| conflict            | load       |                               |
+---------------------+------------+-------------------------------+
| missing requirement | load       |                               |
+---------------------+------------+-------------------------------+
| dependent reload    | load,      |                               |
|                     | unload     |                               |
+---------------------+------------+-------------------------------+
| unloading dependent | unload     | when :mconfig:`auto_handling` |
|                     |            | is disabled                   |
+---------------------+------------+-------------------------------+
| forbidden           | load       |                               |
+---------------------+------------+-------------------------------+
| hard hidden         | load       |                               |
+---------------------+------------+-------------------------------+
| already loaded      | load       |                               |
+---------------------+------------+-------------------------------+
| not loaded          | unload     |                               |
+---------------------+------------+-------------------------------+
| sticky unload       | unload     |                               |
+---------------------+------------+-------------------------------+
| super-sticky unload | unload     |                               |
+---------------------+------------+-------------------------------+
| dependent sticky    | load       |                               |
| reload              |            |                               |
+---------------------+------------+-------------------------------+
| dependent           | load       |                               |
| super-sticky reload |            |                               |
+---------------------+------------+-------------------------------+

When evaluation mode and/or configuration option matches for these error kinds
to raise, a :ref:`default error behavior<default>` error behavior is applied.

Load sub-command
----------------

Specific error behavior for modulefile load evaluation by :subcmd:`load`
sub-command.

Force mode
^^^^^^^^^^

When :option:`--force` command-line switch is used, load evaluation by-pass
following errors:

* conflict
* missing requirement
* dependent reload
* dependent sticky reload

Following behavior is observed:

* evaluation continues (error is by-passed)
* warning message reported (instead of an error message)
* no error exit code set

.. warning:: *Missing requirement* and *dependent reload* errors currently
   returns an error exit code. This behavior might be aligned with the above
   one in the future. Or the above behavior may be adapted the other way
   around.

No effect on other error kinds as it is not useful to mark loaded a broken or
nonexistent modulefile.

``abort_on_error`` configuration option is ignored when ``--force`` option is
in use. Which means *continue on error* behavior is applied.

*Abort on error* behavior is applied whatever the value of
:mconfig:`abort_on_error` if following kind of error occurs:

* dependent sticky reload and force mode is disabled.
* dependent super-sticky reload

Multiple modulefiles passed as argument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When multiple modulefiles are passed to the ``load`` sub-command for
evaluation. If the evaluation of one modulefile raises an error, behavior for
this error is applied and if:

* :mconfig:`abort_on_error` configuration option does not contain ``load`` or
  ``--force`` is set:

  * already evaluated modulefiles from the argument list are kept loaded
  * in case of an *exit* error, evaluation stops
  * for other kind of error, evaluation continues with next modulefile in
    argument list

* :mconfig:`abort_on_error` configuration option contains ``load`` and
  ``--force`` is not set:

  * already evaluated modulefiles from the argument list are withdrawn (they
    will not appear loaded and their environment changes are flushed)
  * evaluation stops

The above description only applies to ``load`` sub-command executed from the
top level context and not from a modulefile evaluation. Multiple arguments on
a ``module load`` command in modulefile are evaluated independently as an
*AND* requirement list.

.. warning:: :command:`ml` command applies the ``abort_on_error`` behavior by
   default, whatever behavior is configured for ``load``. Default behavior for
   ``load`` may be changed in next major version to align ``ml`` command
   behavior.

Load-any sub-command
--------------------

Specific error behavior for modulefile load evaluation by :subcmd:`load-any`
sub-command.

Following errors are ignored:

* not found
* forbidden
* hard hidden

However if no module is loaded after evaluating all ``load-any`` modulefile
arguments:

* an error message is reported
* an error exit code is set

For other kind of error, relative error message is reported and error exit
code is set. Even if a module is loaded after evaluating all modulefile
arguments.

Force mode
^^^^^^^^^^

Same force behavior observed than for `Load sub-command`_.

Multiple modulefiles passed as argument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:subcmd:`load-any` stops evaluation process as soon as a modulefile argument
is successfully loaded.

``load-any`` is not a valid value element for :mconfig:`abort_on_error`
configuration option.

*exit* error stops evaluation of remaining modulefiles in the argument list.

When ``module load-any`` is evaluated as a modulefile command:

* if one modulefile in the list is loaded

  * no error message is reported whatever the error kind

* if no modulefile in the list is loaded

  * an error message is reported for errors other than *not found*,
    *forbidden* and *hard hidden*
  * modulefile declaring the ``module load-any`` command raises a *missing
    requirement* error

.. warning:: An error message may also be reported for *not found*,
   *forbidden* and *hard hidden* error in the future when no modulefile in the
   list is loaded.

.. warning:: Error messages may be transformed into warnings and exit code may
   be untouched in the future if one modulefile in the list is loaded.

Try-load sub-command
--------------------

Specific error behavior for modulefile load evaluation by :subcmd:`try-load`
sub-command.

Following errors are ignored:

* not found
* forbidden
* hard hidden

Even if no module is loaded after evaluating all ``try-load`` modulefile
arguments.

Force mode
^^^^^^^^^^

Same force behavior observed than for `Load sub-command`_.

Multiple modulefiles passed as argument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Same multiple modulefile arguments behavior is observed than for `Load
sub-command`_.

Except *not found*, *forbidden* and *hard hidden* errors are ignored even if
:mconfig:`abort_on_error` configuration option contains ``try-load``.

Mod-to-sh sub-command
---------------------

Specific error behavior for modulefile load evaluation by :subcmd:`mod-to-sh`
sub-command.

Same behavior is observed than for `Load sub-command`_.

Reload sub-command
------------------

Specific error behavior for modulefile load evaluation by :subcmd:`reload`
sub-command.

In case of any error (either during unload or load phase) evaluation stops and
environment changes of already unloaded/loaded modules are flushed. Unless if
force mode is enabled or if reload is removed from :mconfig:`abort_on_error`
configuration option (where it is enabled by default). In this case, a
*continue on error* behavior is applied.

*Abort on error* behavior is applied whatever the value of
:mconfig:`abort_on_error` if:

* a sticky module is not able to reload and force mode is disabled.
* a super-sticky module is not able to reload

Prior running evaluations, dependencies of loaded modules are checked. If at
least one dependency (requirement or conflict) is not satisfied, an error is
raised.

Purge sub-command
------------------

Specific error behavior for modulefile load evaluation by :subcmd:`purge`
sub-command.

In case of error, *continue on error* behavior is applied. If purge is added
in the value list of :mconfig:`abort_on_error` configuration option and if
force mode is not set, *abort on error* behavior applies.

Starting Modules 5.7, unload of a requirement needed by a retained sticky or
super-sticky module is skipped according to :mconfig:`sticky_purge`.
``error`` raises an error and follows the above abort or continue behavior.
``warning`` and ``silent`` skip unload without an error exit code. This also
applies to indirect requirements and, even in force mode, to requirements of
super-sticky modules.

Unload sub-command
------------------

Specific error behavior for modulefile unload evaluation by :subcmd:`unload`
sub-command.

Force mode
^^^^^^^^^^

When :option:`--force` command-line switch is used, unload evaluation by-pass
following errors:

* bad code
* break
* exit
* error
* dependent reload
* unloading dependent
* sticky unload
* dependent sticky reload

Following behavior is observed:

* evaluation continues (error is by-passed)
* warning message reported (instead of an error message)
* no error exit code set

When facing an erroneous modulefile, it seems useful to be able to get rid of
it from user's loaded environment.

``abort_on_error`` configuration option is ignored when ``--force`` option is
in use. Which means *continue on error* behavior is applied.

*Abort on error* behavior is applied whatever the value of
:mconfig:`abort_on_error` if following kind of error occurs:

* dependent sticky reload and force mode is disabled.
* dependent super-sticky reload

Multiple modulefiles passed as argument
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When multiple modulefiles are passed to the ``unload`` sub-command for
evaluation. If the evaluation of one modulefile raises an error, behavior for
this error is applied and if:

* :mconfig:`abort_on_error` configuration option does not contain ``unload``
  or ``--force`` is set:

  * already evaluated modulefiles from the argument list are kept unloaded
  * for other kind of error, evaluation continues with next modulefile in
    argument list

* :mconfig:`abort_on_error` configuration option contains ``load`` and
  ``--force`` is not set:

  * already evaluated modulefiles from the argument list are withdrawn (they
    will appear loaded again and their environment changes are untouched)
  * evaluation stops

The above description only applies to ``unload`` sub-command executed from the
top level context and not from a modulefile evaluation. Multiple arguments on
a ``module unload`` command in modulefile are evaluated independently as an
*AND* conflict list.

.. warning:: :command:`ml` command applies an abort behavior when facing an
   error. Evaluation stops and already unloaded modulefiles are restored in
   loaded environment. It may be changed in the next major version to align
   unload phase of ``ml`` command on ``unload`` sub-command behavior.

.. note:: *exit* error does not lead to an evaluation inhibit of remaining
   modulefiles when evaluation is made in unload mode. Unless if an exit error
   was previously raised in a load evaluation mode prior an unload phase.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
