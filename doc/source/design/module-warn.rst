.. _module-warn:

module-warn modulefile command
==============================

This design document describes the :mfcmd:`module-warn` Tcl command that emits
warning message when targeted module is evaluated.

Need for such command comes from `EESSI`_ software-layer where a warning
message is printed when loading modules if a file is not found.

.. _EESSI: https://www.eessi.io/

Command specification
---------------------

The command has following syntax::

    module-warn [options] --message text modulefile...

When a ``module-warn`` command applies to an evaluated modulefile:

* message is printed as a warning message when targeted module is evaluated in
  ``load``, ``display``, ``help`` or ``test`` modes.
* warning message is printed at the end of the modulefile evaluation
* ``warning`` tag is set on available or loaded module

Like other commands of this kind, modulefile specification accepts advanced
version specifiers (see
:ref:`module_version_specification_to_return_all_matching_modules`).

This command is available in modulerc and modulefile evaluation contexts. In
modulefile context, it could be replaced by :mfcmd:`reportWarning`, but it is
easier to also enables it in this context to benefit from the options that
inhibit or enable specifically the warning mechanism.

``module-warn`` accepts options that change warn mechanism:

* ``--not-user``: specify a list of unaffected users
* ``--not-group``: specify a list of groups whose member are unaffected
* ``--user``: specify a list of users specifically affected
* ``--group``: specify a list of groups whose member are specifically affected
* ``--before``: enables warn mechanism until a given date
* ``--after``: enables warn mechanism after a given date
* ``--message``: warning message to print
* ``--regexp``: module arguments are regular expressions designating the
  modules to warn about (see :ref:`module-tags`)

``warning`` tag
---------------

``warning`` tag is introduced to visibly catch modulefiles affected by
``module-warn``:

* ``W`` is the abbreviation for this tag
* ``W=30;43`` and ``W=103`` is respectively added to dark and light color
  palettes (same as nearly-forbidden modules)
* This tag is recorded into collections following standard tag recording
  mechanism
* This tag cannot be set manually with ``module-tag`` command
* If ``module-warn`` is used within modulefile, extra match search will not
  find ``warning`` tag of these modules

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
