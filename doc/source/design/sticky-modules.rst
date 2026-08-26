.. _sticky-modules:

Sticky modules
==============

Configuration
-------------

- No specific configuration

Specification
-------------

- Once loaded a sticky module cannot be unloaded unless

  - forced
  - or reloaded
  - or when restoring a collection
  - or resetting to initial environment state

- If module is super-sticky instead of sticky, it cannot be unloaded even if forced, only if it is reloaded afterward

- Stickiness definition relies on :ref:`module-tags`

  - ``module-tag sticky foo/1.0`` defines module *foo/1.0* as sticky
  - ``module-tag super-sticky foo/1.0`` defines module *foo/1.0* as super-sticky

- Stickiness specified over a symbolic version or a module alias has no effect

  - ``module-tag`` allows to specify a symbolic module version or a module alias
  - but associated tag will apply to the symbolic version or alias only
  - as modulefile targeted by symbol or alias does not inherit their tags
  - so a sticky or super-sticky tag set on a symbolic version or alias has no effect

- Sticky module can be swapped with another version from same module when stickiness is defined over module parent name

  - For instance if stickiness is defined over module *foo*, *foo/1.0* can be swapped with *foo/2.0*
  - Such swap could occur from a ``restore`` or a ``switch`` sub-command
  - As soon as stickiness is defined over a precise module version name (like *foo/1.0*) such module cannot be swapped by another version of *foo* module
  - Stickiness defined over module parent name (like *foo*) means *any version from module foo must be loaded*
  - When stickiness is defined for several module versions using advanced version specifiers like *foo@1:* or *foo@1.0,2.0*

    - it means stickiness applies to the module versions
    - thus they cannot be swapped by another version

  - In case stickiness is defined over module parent name and another ``module-tag`` defines stickiness over specific module version name

    - it means stickiness applies to the module version
    - thus these versions targeted specifically with ``module-tag`` cannot be swapped by another version from same module

- Starting Modules 5.7, ``purge`` preserves requirements of retained sticky
  and super-sticky modules

  - Direct and indirect requirements are preserved, even without a sticky tag
  - Only strong requirements are preserved: an alternative requirement may
    be unloaded while another loaded module still satisfies it
  - A forced ``purge`` unloads sticky modules and can unload their
    requirements, but preserves super-sticky modules and their requirements
  - Before version 5.7, a forced ``purge`` could unload a non-super-sticky
    requirement and leave a super-sticky module with a missing dependency

- Starting Modules 5.2, sticky modules are unloaded

  - On :subcmd:`restore` sub-command
  - On :subcmd:`reset` sub-command if :mconfig:`reset_target_state` is not equal to ``__purge__``
  - No specific error or warning message
  - This is allowed to fully restore the collection in its targeted state
  - No change for super-sticky modules

- An error is reported when trying to unload a sticky or super-sticky module

  - As the expected unload is not performed
  - So with the return code and message, user knows that what they asked for was not done
  - Same goes for the ``purge`` command: user expects no more module loaded

    - so an error is returned as after the command the sticky module is still loaded

  - When the unload is forced a warning message is reported

    - the sticky module is unloaded as expected but a warning message is done
    - as the module was tagged not to be unloaded by default
    - user should know they have done something specific

- Reporting an error during a ``purge`` may be considered inappropriate

  - as purge cannot unload the sticky, so it may be considered normal not to
    be able to unload the loaded sticky or super-sticky modules
  - a configuration option :mconfig:`sticky_purge` is introduced on Modules
    5.4 to define behavior when facing sticky/super-sticky modules during a
    ``purge``:

    - when set to ``error`` (default), and error is raised
    - when set to ``warning``, a warning message is reported, no error exit
      code
    - when set to ``silent``, no message reported, no error exit code

  - Starting Modules 5.7, this configuration also applies to skipped unload
    of requirements of retained sticky or super-sticky modules
  - Requirement unload is reported as ``Unload of sticky module requirement
    skipped`` or ``Unload of super-sticky module requirement skipped``
  - If both sticky and super-sticky modules require a module, the
    super-sticky tag takes precedence in this message

  - Even when ``sticky_purge`` is set to ``silent``, a warning message is
    reported when unload of sticky module is forced during a purge.

- Module specification on which stickiness is defined is recorded in
  environment when loading a sticky or super-sticky module

  - This is introduced on Modules 5.4
  - With :envvar:`__MODULES_LMSTICKYRULE` environment variable
  - This change is made to determine if a sticky module is reloading, based on
    the sticky rule definition
  - It was previously made with an evaluation of modulerc files toward the
    currently loaded sticky module. But this methodology was not able to
    handle virtual modules whose modulefile is defined outside of enabled
    modulepaths
  - If stickiness is defined over a specific module name and version, sticky
    rule definition is not exported in user environment when loading module.
    This way we know stickiness reloads if exact same module name and version
    reloads
  - If several generic sticky rules applies to the loading module, all of them
    are recorded in user environment
  - When stickiness is set with ``--tag`` option, it applies to the module
    name and version, thus no rule need to be recorded in loaded environment


Current limitations
-------------------

- When swapping a sticky module explicitly targeted by the ``module-tag`` command and which is the default version

  - For instance ``module-tag sticky foo/1.0`` and ``module-version foo/1.0 default``
  - If specified swapped-on module is the generic module name, for instance *foo*
  - ``switch`` sub-command raises an error even if the sticky module is the default version (either implicit or explicitly set) for this module

- When swapping a sticky module defined over a full path modulefile by another
  in different modulepath but with same module name and version

  - This switched-on module is currently considered as the sticky module
    reloading

- When swapping a sticky module by itself but specified as full path module
  swap command is not able to detect same module is reloading


.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
