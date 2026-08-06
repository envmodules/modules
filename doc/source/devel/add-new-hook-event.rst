.. _add-new-hook-event:

Add new hook event
==================

This document is a guide for Modules developers that wish to introduce a new
hook event for the ``add-hook`` siteconfig command. See the :ref:`hook-api`
design notes for the rationale behind this mechanism, and the *Hooks*
section of :manpage:`module(1)` man page for the events already available.

Core code
---------

A hook event is a name registered in ``g_hookEvents``, plus a ``runHooks``
call placed at the exact point in the internal code where site procedures
registered on that event should run.

#. Declare the new event name in the ``g_hookEvents`` list.

    - File to edit: :file:`tcl/init.tcl.in`

   Event names are lower-case, dash-separated, and usually paired as
   ``before-<something>``/``after-<something>`` when they bracket an
   operation, following the existing ``before-modulefile-eval``/
   ``after-modulefile-eval`` and ``before-modulerc-eval``/
   ``after-modulerc-eval`` events.

#. Add a ``runHooks <event-name> <arg> ...`` call at the point in the
   internal code where the event should fire.

    - File to edit: depends on the touch point the event relates to. The
      four existing events all fire from :file:`tcl/interp.tcl.in`, around
      the ``evaluateModulefile``/``evaluateModulerc`` calls inside
      ``execute-modulefile``/``execute-modulerc``. A hook event covering a
      different touch point (for instance module load/unload completion, or
      collection save/restore, both mentioned as future candidates in the
      :ref:`hook-api` design notes) would instead be added next to the
      internal code implementing that operation.

   Decide on a fixed, positional argument list for the event: this argument
   contract *is* the stable API a hook procedure relies on, so it should be
   descriptive enough on its own (an absolute file path rather than a
   relative one, a resolved value rather than an internal handle, etc.) and
   should not change once released. Look at the argument list of the
   existing events for the kind of information usually passed: paths,
   resolved names, current mode, and a trailing ``status`` argument on
   ``after-*`` events reporting whether the wrapped operation succeeded.

   ``runHooks`` catches an error raised by a hook procedure, reports it, and
   keeps going: neither the other procedures registered on the same event
   nor the operation the hook wraps are interrupted. This is the right
   default for an event that is purely informational, like the four
   existing ones, since a buggy hook procedure must not be able to lock
   site-wide command usage. If the new event is deliberately designed to let
   a hook procedure influence the operation it wraps -- aborting it, or
   altering a value used afterward -- that is a different contract that
   ``runHooks`` does not provide as-is; the call site needs its own code to
   read back a value or catch a raised error and act on it, and this
   divergence from the informational-only default should be spelled out
   clearly in the event's documentation.

Documentation
-------------

Man page and other user documentation have to be updated to describe the
introduced event.

Files that should be edited:

- :file:`doc/source/module.rst` (module manpage)

  - add event description with ``mhook`` anchor under the *Hooks*
    subsection, following the pattern of the existing four events: argument
    list in the directive signature, prose describing each argument, and a
    note on whether the value a registered procedure returns is used or
    ignored

- :file:`doc/source/changes.rst`

  - add the event to the table under the *Siteconfig hooks* subsection of
    the current Modules major version, next to the version it is introduced
    in

- :file:`NEWS.rst`

  - add an entry under the in-development version's bullet list, at the end
    of it

- :file:`MIGRATING.rst`

  - the *Hook API* entry already announces that more hook events will be
    added over time, so a single new event usually does not need its own
    highlight there; consider adding or extending an entry if the new event
    opens up a use case significant enough to be worth a dedicated
    highlight (a new category of touch point, for instance, rather than
    another modulefile/modulerc-evaluation event)

- :file:`doc/source/design/hook-api.rst`

  - a new event covering the same kind of touch point as the existing ones
    (modulefile/modulerc evaluation) can usually just be documented in
    :file:`module.rst` as above; a new event opening up a different touch
    point (see the *Open questions and future work* section of this design
    document) is significant enough to warrant its own design notes first,
    following this document as a template

Testsuite
---------

Non-regression testsuite must be adapted to check the behavior of the added
event and ensure overall code coverage does not drop.

#. Register a procedure on the new event, following the existing
   ``switch --`` cases already used to select which hook scenario a test
   run exercises.

    - File to edit: :file:`testsuite/example/siteconfig.tcl-1`

#. Craft tests that validate the event fires at the right point with the
   correct arguments, on both a successful and a failing operation if
   applicable.

    - File to edit: :file:`testsuite/modules.50-cmds/740-hook.exp` if the
      new event relates to modulefile/modulerc evaluation like the existing
      ones, a new dedicated ``.exp`` file otherwise, following the existing
      naming and numbering pattern of the directory the new touch point
      belongs to

   The generic ``add-hook`` behaviors (unknown event name, several
   procedures registered on the same event, a hook procedure error not
   interrupting the wrapped operation, wrong argument count) are already
   covered for the existing events and do not need to be duplicated; focus
   new tests on what is specific to the new event: its firing point and its
   argument values.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
