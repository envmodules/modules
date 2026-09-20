.. _sticky-modules-rcp:

Sticky modules
==============

When providing a configurable environment to users, site's staff may require
that some part of this environment remain loaded whatever the user does.

Such feature is for instance useful when every details of the user environment
are configured through the use of modulefiles. Even the core setup that is
usually configured through the :file:`/etc/profile.d` initialization scripts.
But by using modulefiles for core initialization, end users can fully see how
things are setup on their environment by using
:subcmd:`module display<display>`. When the environment core setup is achieved
by loading a specific modulefile, it is important that such module remains
loaded to keep this initial setup on whatever the module actions the user
performs over its environment.

This recipe describes how to keep modulefiles loaded by forbidding their
unload. Such unloadable modules are called *sticky modules*.

Implementation
--------------

:ref:`Sticky modules` are simply modules that cannot be unloaded once loaded.
Such behavior could be achieved by basically breaking the modulefile
evaluation when attempting to unload the sticky module:

.. code-block:: tcl

    if {[module-info mode unload]} {
        break
    }

Using the ``break`` Tcl command to stop the modulefile evaluation does not
require to install a recent version of Modules to get a basic sticky
mechanism.

To get a smoother sticky mechanism with two different level of stickiness,
allowing to reload environment or to swap a sticky module by another
version of the same module name, the *sticky* and *super-sticky* module tags
have been introduced in Modules v4.7.

A modulefile is declared *sticky* by applying it the ``sticky`` tag with the
:mfcmd:`module-tag` modulefile command. Such sticky module cannot be unloaded,
unless if the unload action is forced or if the module reloads after being
unloaded.

Modulefile can also be defined ``super-sticky`` by applying the corresponding
module tag. *Super-sticky* module cannot be unloaded even if the unload action
is forced. It can only be unloaded if the module reloads afterward.

In case the stickiness applies to the generic module name (and does not target
a specific module version or version-set), one version of the sticky or
super-sticky module can be swapped by another version of this same module.

**Compatible with Modules v4.7+**

Usage examples
--------------

For this recipe, a *core* module acts as the initial setup of user's
environment. This module must not be unloaded otherwise user's environment may
be considered broken.

So this *core* module is tagged *super-sticky* with the :mfcmd:`module-tag`
modulefile command in :file:`core/.modulerc` file:

.. code-block:: tcl

    module-tag super-sticky core

Once module got loaded, it cannot be unloaded even if these unload actions are
forced.

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/1.0`  

    Key:
    :sgrss:`super-sticky`  
    :ps:`$` module unload core
    Unloading :sgrhi:`core/1.0`
      :sgrer:`ERROR`: Unload of super-sticky module 'core/1.0' skipped
    :ps:`$` module purge -f
    Unloading :sgrhi:`core/1.0`
      :sgrer:`ERROR`: Unload of super-sticky module 'core/1.0' skipped
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/1.0`  

    Key:
    :sgrss:`super-sticky`  

However it is still possible to change version of this *super-sticky* module.

.. parsed-literal::

    :ps:`$` module switch core/2.0
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/2.0`  

    Key:
    :sgrss:`super-sticky`  

In this recipe environment, the *compiler* module provides several flavors:
*compA* and *compB*. Site's staff have decided that user's environment should
always have a compiler module loaded by default.

So the *compiler* module is set *sticky* with the :mfcmd:`module-tag`
modulefile command in :file:`compiler/.modulerc` file:

.. code-block:: tcl

    module-tag sticky compiler

As stickiness is defined over the generic *compiler* name, users can switch
between available compiler flavors:

.. parsed-literal::

    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/2.0`   2) :sgrs:`compiler/compB/2.1`  

    Key:
    :sgrss:`super-sticky`  :sgrs:`sticky`  
    :ps:`$` module switch compiler/compA
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/2.0`   2) :sgrs:`compiler/compA/1.2`  

    Key:
    :sgrss:`super-sticky`  :sgrs:`sticky`  

Unload attempt fails by default:

.. parsed-literal::

    :ps:`$` module unload compiler
    Unloading :sgrhi:`compiler/compA/1.2`
      :sgrer:`ERROR`: Unload of sticky module 'compiler/compA/1.2' skipped

However if a user really wants to get rid of the *compiler* module, the unload
action can be forced:

.. parsed-literal::

    :ps:`$` module unload -f compiler
    Unloading :sgrhi:`compiler/compA/1.2`
      :sgrwa:`WARNING`: Unload of sticky module 'compiler/compA/1.2' forced
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgrss:`core/2.0`  

    Key:
    :sgrss:`super-sticky`  

Last but not least, the sticky modules should get loaded when the user's shell
session initializes. So the *core* and *compiler* modules should be defined
for load in the initialization RC file |file etcdir_initrc|:

.. code-block:: tcl

    #%Module
    module use --append .../example/sticky-modules/modulefiles
    module load core
    module load compiler/compB

Preserving requirements during purge
------------------------------------

Starting with Modules v5.7, :subcmd:`purge` also preserves the requirements
of retained sticky or super-sticky modules.

A base environment can group *core* and *compiler* under a single *env/base*
module. In this example, *core* and *compiler* have no sticky tag. The
:file:`env/base` modulefile declares both as requirements:

.. code-block:: tcl

    #%Module
    prereq core
    prereq compiler

Only *env/base* is tagged *super-sticky*, in :file:`env/.modulerc`:

.. code-block:: tcl

    #%Module
    module-tag super-sticky env/base

With :mconfig:`sticky_purge` set to ``warning``, a purge explains why each
module remains loaded:

.. parsed-literal::

    :ps:`$` module config sticky_purge warning
    :ps:`$` module load env/base
    Loading :sgrhi:`env/base`
      :sgrin:`Loading requirement`: core compiler
    :ps:`$` module purge
    Unloading :sgrhi:`env/base`
      :sgrwa:`WARNING`: Unload of super-sticky module skipped

    Unloading :sgrhi:`compiler`
      :sgrwa:`WARNING`: Unload of super-sticky module requirement skipped

    Unloading :sgrhi:`core`
      :sgrwa:`WARNING`: Unload of super-sticky module requirement skipped
    :ps:`$` module list
    Currently Loaded Modulefiles:
     1) :sgral:`core`   2) :sgral:`compiler`   3) :sgrss:`env/base`

    Key:
    :sgral:`auto-loaded`  :sgrss:`super-sticky`

Both requirements remain loaded even though they are not sticky themselves.
The same protection applies to indirect requirements and to a forced purge
because *env/base* is super-sticky. Setting ``sticky_purge`` to ``silent``
suppresses these warnings; its default value, ``error``, reports errors for
the skipped unloads.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
