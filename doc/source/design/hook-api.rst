.. _hook-api:

Hook API
========

It is sometimes desired to execute specific site procedures at the beginning
or at the end of a modulefile or modulerc evaluation.

This is currently possible with either the ``trace`` Tcl command or by
superseding one of the internal Tcl procedures (like ``execute-modulefile``),
as described in the *Hooks* section of :manpage:`module(1)` man page. Both
techniques bind site code to internal implementation details: procedure
names and call signatures that may change from one Modules version to the
next. Sites relying on them have to re-review this internal code on every
upgrade to determine whether their hook code or its connection point still
applies.

This document defines a stable, documented ``add-hook`` API to replace this
need for most cases, without removing the lower-level ``trace``/rename
techniques, which remain available for anything not covered by a hook
event. This first change introduces 4 events; the API is designed so more
can be added later without changing how existing ones behave.

The ``add-hook`` command
------------------------

A new ``add-hook`` command is introduced, usable from :file:`siteconfig.tcl`
(and any script it sources). Like ``trace`` or ``rename``, it is only
meaningful in the main Tcl interpreter: :file:`siteconfig.tcl` is sourced
once at startup, before any modulefile or modulerc sub-interpreter is
created, so hook procedures execute in that same main-interpreter context —
exactly like ``trace``-based hooks do today. A hook procedure that needs to
act on the modulefile or modulerc currently being evaluated reaches it the
same way an existing ``trace``-based hook would: through
``getCurrentModfileInterpName`` and ``interp eval``, as already documented
for the current hook technique.

Syntax::

    add-hook <event> <procedure>

* ``event`` must be one of the event names defined below. An unknown event
  name is a configuration mistake, so it raises an error immediately, at the
  time ``add-hook`` is called — the same treatment already given to other
  siteconfig configuration mistakes (for instance an odd-length
  :sitevar:`modulefile_extra_vars` list).
* ``procedure`` is the name of a Tcl procedure, defined in
  :file:`siteconfig.tcl` or a script it sources, that will be called when
  the event occurs. It is looked up by name at call time, not validated at
  registration time.

Several procedures can be registered on the same event. They are called in
their registration order. This lets independent site concerns (say,
logging and environment tuning) each register their own procedure on the
same event rather than being forced to share a single procedure body — a
constraint the existing ``ModulesHelp``/``ModulesDisplay``/``ModulesTest``
fixed-proc-name convention would have imposed if reused here.

First hook events and their argument contract
---------------------------------------------

The first 4 events introduced cover the beginning and the end of
modulefile and modulerc evaluation. Each one calls the registered
procedure with a fixed, positional argument list — this argument contract
*is* the stable API: it is what lets a hook procedure survive a Modules
upgrade unchanged.

``before-modulefile-eval``
   Called immediately before a modulefile is evaluated.

   ``proc {modfile modname modnamevr modspec mode requested} {...}``

``after-modulefile-eval``
   Called immediately after a modulefile has been evaluated.

   ``proc {modfile modname modnamevr modspec mode requested status} {...}``

``before-modulerc-eval``
   Called immediately before a modulerc (or ``.version`` file) is evaluated.

   ``proc {modfile modname} {...}``

``after-modulerc-eval``
   Called immediately after a modulerc (or ``.version`` file) has been
   evaluated.

   ``proc {modfile modname status} {...}``

Argument meaning, common to these events:

* ``modfile`` — absolute path of the modulefile or modulerc being evaluated.
* ``modname`` — module name and version being evaluated, without its variant
  specification.
* ``modnamevr`` (``*-modulefile-eval`` events only) — module name, version
  and variant currently resolved for this evaluation. Modulerc evaluation
  is not tied to one resolved module the way modulefile evaluation is, so
  this argument is omitted for the two modulerc events, which only get the
  bare ``modname``.
* ``modspec`` (``*-modulefile-eval`` events only) — module specification as
  it was passed to the internal evaluation call, prior to any resolution:
  typically what the user typed on the command line (or the raw entry read
  from a collection or loaded-modules list), which may still differ from
  ``modnamevr`` (for instance a partial version, or a variant specification
  merged in as a separate list element). Modulerc evaluation has no
  equivalent notion, so this argument is also omitted for the two modulerc
  events.
* ``mode`` — current evaluation mode (``load``, ``unload``, ``display``,
  ``help``, ``test``, ``whatis``, ``refresh``, ``scan`` or ``dep``).
  Modulerc evaluation is not mode-specific the way modulefile evaluation is,
  so this argument is omitted for the two modulerc events.
* ``requested`` — boolean, true if this module was directly requested by the
  user, false if it is being evaluated as a side effect (for instance an
  auto-loaded dependency). Modulerc evaluation has no equivalent notion, so
  this argument is also omitted for the two modulerc events.
* ``status`` (``after-*`` events only) — ``0`` if evaluation succeeded,
  ``1`` if it raised an error, mirroring the return-code convention already
  used internally around modulefile/modulerc evaluation.

The before/after events fire around the actual evaluation step, skipped
whenever interpretation itself is skipped (for instance when interpretation
is inhibited during a dependency-resolution pass) — so a hook only fires for
evaluations that really read and interpret the target file.
``before-modulefile-eval`` and ``before-modulerc-eval`` fire after the
target modulefile's or modulerc's dedicated Tcl sub-interpreter has been
created and reset to its initial state, so a hook procedure can already
reach it (see ``getCurrentModfileInterpName`` in :manpage:`module(1)` man
page) to run modulefile commands there.

These hooks are informational for this first iteration: the value a hook
procedure returns is ignored, and it cannot cancel or otherwise alter the
evaluation it wraps — unlike :mfcmd:`module-forbid` or :mfcmd:`module-warn`,
which are dedicated mechanisms for that purpose. See `Open questions and
future work`_ below.

Error handling
--------------

If a hook procedure raises a Tcl error, that error is caught and reported,
but does not abort the ``module`` command being run. In particular:

* when several procedures are registered on the same event, one procedure
  raising an error does not prevent the other procedures registered on that
  event from running: each remaining procedure in the list is still called,
  in its registration order;
* the modulefile or modulerc evaluation being wrapped by the hook still
  proceeds normally.

This differs from how a load-time error in :file:`siteconfig.tcl` itself is
handled today (which is fatal). The distinction is deliberate: a
``before-``/``after-*-eval`` hook fires on essentially every modulefile or
modulerc evaluation, so letting a single buggy hook procedure abort every
``module`` invocation site-wide would be far more disruptive than letting a
malformed :file:`siteconfig.tcl` fail once, loudly, at startup.

Relation to existing trace/rename-based hooks
---------------------------------------------

The ``trace``/rename techniques described in :manpage:`module(1)` man page
keep working unchanged — nothing is removed. The *Hooks* section of that man
page is restructured to present ``add-hook`` as the primary, recommended
mechanism for the events it supports, and the ``trace``/rename techniques
as an advanced, lower-level fallback for connection points ``add-hook``
does not (yet) cover.

Documentation
-------------

Hook events are documented with a new Sphinx object type, ``mhook``
(``.. mhook::``/``:mhook:``), defined the same way existing ``mfcmd``,
``mfvar`` and ``sitevar`` object types are in ``doc/source/conf.py``. A
distinct name from the generic "hook" is used to avoid ambiguity with the
other unrelated uses of that word already in the docs (git commit hooks in
``CONTRIBUTING.rst``, and the existing ``trace``-based hook technique
described in ``module.rst``).

Touch points for implementation
-------------------------------

This section lists the files a future implementation is expected to touch;
it is not itself an implementation plan.

* ``tcl/interp.tcl.in`` — hook registry (populated by ``add-hook``), a small
  dispatch helper, and the four call sites added around the existing
  ``evaluateModulefile``/``evaluateModulerc`` calls inside
  ``execute-modulefile``/``execute-modulerc``.
* ``siteconfig.tcl`` (root template, and its installed copy) — a new
  commented example of how to register a hook with ``add-hook``, pointing
  at :manpage:`module(1)` man page for the current list of events, next to
  the existing commented-out
  :sitevar:`modulefile_extra_vars`/:sitevar:`modulefile_extra_cmds`/
  :sitevar:`modulerc_extra_vars`/:sitevar:`modulerc_extra_cmds` examples.
* ``doc/source/conf.py`` — register the new ``mhook`` object type.
* ``doc/source/module.rst`` — restructure the *Hooks* section: document
  ``add-hook`` and the four ``mhook`` entries, demote the ``trace``/rename
  description to the advanced fallback case.
* ``doc/source/changes.rst`` and ``NEWS.rst`` — new entry under the
  in-development ``Modules 5.7.0`` section (appended at the end of its
  bullet list, per project convention).
* Nagelfar syntax db (``share/``) — check whether ``make testlint`` requires
  it to be regenerated for the new ``add-hook`` command to lint cleanly in
  :file:`siteconfig.tcl` examples.
* Testsuite — a new, dedicated ``.exp`` file (kept separate from
  ``testsuite/modules.50-cmds/560-siteconfig-interp.exp``, which already
  covers the older extra_vars/extra_cmds mechanism), with a matching new
  ``testsuite/example/siteconfig.tcl-N`` fixture, following the existing
  naming and numbering pattern in that directory.

Open questions and future work
------------------------------

* A ``remove-hook`` command, and/or a way to introspect which procedures are
  currently registered on a given event, is not part of this first pass.
  The registry design should not preclude adding one later.
* Future hook events (for instance around module load/unload completion, or
  collection save/restore) will be exposed through this same ``add-hook``
  mechanism, once real use cases for them emerge.
* Future hook events may be designed to influence the evaluation they wrap --
  altering argument values, changing the execution flow, or raising an error
  that aborts it -- but only where the event is purposely built for that and
  the calling code is written to expect it, unlike the events introduced
  here.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
