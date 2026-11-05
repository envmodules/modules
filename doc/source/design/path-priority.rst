.. _path-priority:

Priority of path-like variable elements
=======================================

The position of an element in a path-like variable (like :envvar:`PATH`)
determines its precedence: the first directory providing a given command
wins. When several modulefiles prepend their directory to :envvar:`PATH`,
the resulting order only depends on the order these modulefiles have been
loaded. The last loaded module gets the first position.

Some sites need a given directory to persist at the first (or at the last)
position of a path-like variable whatever the modules loaded afterward: a
wrapper directory that must take precedence over every software, or a
fallback directory that must stay the last resort.

Priority weights are a common answer to this kind of problem, for instance
to rank the package repositories of a system. Applied to the elements of a
path-like variable, a priority weight determines which element stands ahead
of the others, whatever the order these elements have been added.

Objective is to let a modulefile assign a priority to the elements it adds
to a path-like variable. The module command remembers this priority across
modulefile evaluations and keeps the elements of the variable ordered
according to it.

Priority as defined on Lmod
---------------------------

Lmod already provides such a priority mechanism for path-like variables.
The interpretation given to the priority values on Modules is the same as
the one used on Lmod, so that people already knowing Lmod directly
understand these values. On Lmod:

* Priority is a number set for a given path element. The default priority
  of an element is ``0``, which means *no priority*.
* Elements are grouped by priority. The group holding the highest priority
  prepended elements is placed at the beginning of the variable. The group
  holding the highest priority appended elements is placed at the end of
  the variable. Elements with no priority are in between.
* Lmod remembers the priority of path elements between invocations in a
  ``__LMOD_Priority_<VAR>`` environment variable, so the same ordering is
  obtained whether the elements are added from one or several modulefiles.

Example from Lmod documentation, assuming :envvar:`PATH` is initially
empty::

    prepend_path{"PATH","/foo",priority=100}  --> PATH = /foo
    prepend_path("PATH","/A")                 --> PATH = /foo:/A
    prepend_path("PATH","/B")                 --> PATH = /foo:/B:/A

``--priority`` option
---------------------

A ``--priority`` option is added to the :mfcmd:`prepend-path` and
:mfcmd:`append-path` modulefile commands. It takes a priority value as
argument and applies it to all the path elements added by the command::

    prepend-path --priority 100 PATH /path/to/foo
    append-path --priority=100 PATH /path/to/bar /path/to/baz

Both ``--priority N`` and ``--priority=N`` forms are accepted, like the
``--delim`` option.

The option is also accepted by the :subcmd:`prepend-path` and
:subcmd:`append-path` module sub-commands, as these sub-commands pass their
options through to the corresponding modulefile commands::

    module prepend-path --priority 100 PATH /path/to/foo

The :mfcmd:`remove-path` modulefile command and the :subcmd:`remove-path`
sub-command do not take any priority into account to select the elements to
remove. The ``--priority`` option is accepted by :mfcmd:`remove-path` but a
warning is raised to tell this option has no effect, like what is done for
the ``--duplicates`` option.

A different syntax than Lmod
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The syntax adopted here differs from the syntax of the ``prepend-path``
and ``append-path`` commands in the Tcl modulefiles evaluated by Lmod. On
Lmod the priority is a third positional argument placed after the path
value::

    prepend-path PATH /path/to/foo 100

Such positional argument is possible on Lmod as its ``prepend-path`` and
``append-path`` Tcl commands accept a single path value. On Modules these
commands accept multiple path values at once since version 4.1::

    prepend-path PATH /path/to/foo /path/to/bar

A trailing number cannot be distinguished from a path element on Modules
(``100`` is a valid directory name), so the priority has to be set through
an option rather than through a positional argument. The
:ref:`lmod-tcl-modulefile-compat` design notes already state this
difference: the third positional argument of ``prepend-path`` and
``append-path`` corresponds to a priority specification on Lmod whereas it
is an additional path element on Modules. A Tcl modulefile written for Lmod
with a priority has to be adapted to use the ``--priority`` option on
Modules.

Priority value
--------------

Priority value is an integer between ``0`` and ``1000000``. ``0`` is the
default value and means *no priority*: ``--priority 0`` is equivalent to not
setting the option. The greater the priority value is, the closer to the
variable edge the path element is placed. An error is raised when the value
is not an integer, when it is negative or when it is greater than
``1000000``. An upper bound is needed as the weights found in the priority
record are checked with the ``string is integer`` Tcl command, which only
accepts 32-bit values on Tcl 8: without it a larger value would be accepted
when set but dropped as erroneous when read back. ``1000000`` is a round
number far beyond the needs of a priority scheme and well within the range
accepted on every Tcl version.

Lmod accepts negative priority values. Internally, Lmod negates the
priority of prepended elements and sorts all elements on their signed
priority. A negative priority given to ``prepend_path`` thus places the
element at the end of the variable, as if it were appended with the
opposite positive priority. This behavior is not reproduced: a negative
value is rejected to keep the meaning of ``prepend-path`` and
``append-path`` explicit.

Ordering rule
-------------

Each element of a path-like variable gets a *weight*, which is its priority
value negated for prepended elements and kept as is for appended elements.
Elements without priority have a ``0`` weight. The elements of the variable
are sorted by increasing weight. For instance a variable mixing elements
prepended with priority ``100`` and ``10``, elements without priority and
elements appended with priority ``10`` and ``100`` is ordered as follows::

    [prepend 100]:[prepend 10]:[no priority]:[append 10]:[append 100]

Elements with the same weight form a group. The sort never decides the
order of the elements within a group: this order comes from the position
they were inserted at, which the usual ordering determines. A prepended
element is inserted at the beginning of the variable, so it is placed at
the beginning of its group once the variable is sorted, and an appended
element at the end of its group. Elements of equal priority thus keep the
natural order resulting from the module load sequence, the last loaded
module getting the first position among the prepended elements and the last
position among the appended elements. The group of the elements without
priority behaves exactly like the whole variable prior to the introduction
of this feature: existing modulefiles are not affected as long as no
priority is set on an element of the variable.

For instance, two modules prepending their directory with the same
priority::

    module load A    # prepend-path --priority 100 PATH /dirA  --> /dirA:/bin
    module load B    # prepend-path --priority 100 PATH /dirB  --> /dirB:/dirA:/bin

For instance, with prepended elements::

    setenv PATH /bin
    prepend-path --priority 100 PATH /path/to/foo   --> /path/to/foo:/bin
    prepend-path PATH /path/to/bar                  --> /path/to/foo:/path/to/bar:/bin

Appended elements behave symmetrically::

    setenv PATH /bin
    append-path --priority 100 PATH /path/to/foo    --> /bin:/path/to/foo
    append-path PATH /path/to/bar                   --> /bin:/path/to/bar:/path/to/foo
    append-path --priority 10 PATH /path/to/baz     --> /bin:/path/to/bar:/path/to/baz:/path/to/foo

Ordering is applied each time an element is added to the variable through
:mfcmd:`prepend-path` or :mfcmd:`append-path`, as long as at least one
element of the variable has a priority. The whole variable is sorted, not
only the elements added by the command: an element that has been inserted
in the variable outside of the module command (with a shell ``export`` for
instance) gets a ``0`` weight and is placed after the prepended elements
with priority at the next modification of the variable through
:mfcmd:`prepend-path` or :mfcmd:`append-path`. The element with the top
priority thus persists at the first position.

Removing an element from the variable does not change the order of the
remaining elements, so no reordering is made by :mfcmd:`remove-path`.

Element added several times
^^^^^^^^^^^^^^^^^^^^^^^^^^^

A priority is attached to a path element, not to each of its occurrence in
the variable. Each priority set on an element is a *demand*, recorded along
with the name of the module making it (see `Priority record`_). What
happens to a demand made on an element already in the variable follows the
:mconfig:`path_entry_reorder` configuration option, like the position of an
element added several times does:

* When :mconfig:`path_entry_reorder` is disabled, an element added again is
  not moved. The demand made on it is not recorded, so the element keeps
  the priority given by the module that first added it, or keeps having no
  priority if this module set none. The element thus never moves because of
  a module added it again, whether this module sets a priority or not. This
  is also what Lmod does with its ``LMOD_TMOD_PATH_RULE=yes`` setting, which
  is its equivalent of this configuration: the priority given on an already
  present element is silently ignored.
* When :mconfig:`path_entry_reorder` is enabled, an element added again is
  moved to the beginning or the end of the variable. The demand made on it
  is recorded and the last demand recorded applies: the element is moved to
  its new group. A module making a new demand on an element it already
  prioritized withdraws its previous demand, so its new demand is the most
  recent one whatever the rank of the previous one. Lmod in its default
  configuration also applies the last demand, with a twist: a prepend demand
  following an append demand (or the reverse) always wins, whereas two
  demands on the same side keep the strongest one.

A demand without priority (element added again without the ``--priority``
option) is not recorded and does not alter the existing demands. Lmod in
its default configuration resets the priority of the element in this case.

When the module that made the applying demand is unloaded, its demand is
withdrawn and the next demand in the record, if any, applies, like the
:mfcmd:`pushenv` command restores the previous value of a variable when the
module that set the current one is unloaded. When
:mconfig:`path_entry_reorder` is enabled, the element is moved to the group
of its restored demand as soon as the module is unloaded, as this
configuration states that the applying demand decides the position of the
element. When it is disabled, removing an element never reorders the
variable and the restored demand takes effect at the next modification of
the variable through :mfcmd:`prepend-path` or :mfcmd:`append-path`. Several
demands are only recorded on an element when :mconfig:`path_entry_reorder`
is enabled, but the option may be disabled afterward: the first demand
recorded then applies, as it is the demand of the module that first added
the element.

When the ``--duplicates`` option is set, the element is added again to the
variable. All the occurrences of an element share the same priority, so
they end up contiguous in the same group once the variable is sorted. The
occurrences of an element are identical strings that nothing distinguishes
in the variable: the reference counter counts them globally and the
priority record is keyed by element. The module name recorded with a demand
tells which module made it, not which occurrence belongs to this module, as
demands and occurrences do not map one to one:

* two modules may demand on a single occurrence, when the element is added
  again without ``--duplicates`` and :mconfig:`path_entry_reorder` is
  enabled;
* one module may add two occurrences with a single demand, when it adds the
  element twice with ``--duplicates``, its second demand replacing the
  first or being ignored depending on :mconfig:`path_entry_reorder`;
* an occurrence added without priority may stand next to a demanded one.

Giving each occurrence its own priority would require to record a per-module
occurrence count with each demand and to assign the weights to the
occurrences by position, which is only reliable as long as the variable is
kept sorted. This is not done: an element gets one weight whatever its
number of occurrences, like on Lmod.

Priority record
---------------

To remember the priority of path elements across modulefile evaluations, a
new environment variable is defined next to the reference counter variable
:envvar:`__MODULES_SHARE_\<VAR\>`: ``__MODULES_PRIORITY_<VAR>``. For
instance ``__MODULES_PRIORITY_PATH`` records the priority of the elements of
:envvar:`PATH`.

This variable is a colon separated list of records, one per path element
with a priority, sorted by path element. A record is formed by the path
element followed by the demands made on it, in the order they were made.
An ampersand character separates the element and each demand, like the
module name and the value are separated in the :mfcmd:`pushenv` stack
variable. A demand is formed by the name of the module making it followed
by a pipe character and the *weight* of the element: a negative number for
a prepended element, a positive number for an appended element. The module
name is empty for a demand made from the command line. Colon and ampersand
characters found in path elements are escaped with a backslash. For
instance::

    __MODULES_PRIORITY_PATH=/path/to/bar&|10:/path/to/foo&site/1.0|-100&other/2.0|-10

Here ``/path/to/bar`` was appended with priority 10 from the command line,
``/path/to/foo`` was prepended with priority 100 by ``site/1.0`` then with
priority 10 by ``other/2.0``.

Only the elements with a demand are recorded. The variable is unset when no
element with a priority remains in the path-like variable. A recorded
element that is not found anymore in the path-like variable is ignored when
the record is read and dropped when the record is rewritten, so the record
heals itself after an external modification of the variable. A malformed
record is ignored and reported in debug output, like a malformed reference
counter.

Lmod only records the weight of each element in ``__LMOD_Priority_<VAR>``,
without the name of the module setting it. The module name is recorded here
to withdraw the demand of a module when it is unloaded and let the demand
of another module apply again.

Priority record is managed like the reference counter record:

* It is only defined for the variables that have a reference counter
  variable: no record for the Modules-specific variables
  (:envvar:`LOADEDMODULES`, :envvar:`_LMFILES_`, ``__MODULES_*`` and
  ``MODULES_*`` variables). :envvar:`MODULEPATH` gets a record.
* It is cleared by the :mfcmd:`setenv`, :mfcmd:`unsetenv` and
  :mfcmd:`pushenv` modulefile commands, which take the control of the whole
  variable value.
* It is a Modules-private variable (``__MODULES_*`` prefix), so it is
  ignored by the :mfcmd:`source-sh` modulefile command and by the
  :subcmd:`sh-to-mod` sub-command. A collection records the enabled
  modulepaths in their order, not their priority: :subcmd:`restore` enables
  the modulepaths in the collection order without priority. The demand
  made from the command line on a modulepath that :subcmd:`restore`
  disables and enables again to reach this order is lost. A demand made
  with :mfcmd:`module use<module>` in a modulefile is made again when
  :subcmd:`restore` loads this modulefile back, so the priority of the
  modulepaths enabled by modulefiles is preserved (see `Future work`_).

Interaction with other features
-------------------------------

* The :subcmd:`use` sub-command also accepts the ``--priority`` option,
  like Lmod does (``module use --priority N dir``), as it relies on
  ``prepend-path`` or ``append-path`` to modify :envvar:`MODULEPATH`. The
  option is validated and forwarded by ``runModuleUse``. A priority set on
  a modulepath is honored whenever :envvar:`MODULEPATH` is modified
  afterward, from a modulefile or from the command line: the prioritized
  modulepath keeps the first position. Like for any path element, the
  priority set on an already enabled modulepath is ignored unless
  :mconfig:`path_entry_reorder` is enabled. The value of the option is
  checked with the same rules and reported with the same error messages as
  on the :mfcmd:`prepend-path` and :mfcmd:`append-path` modulefile
  commands. The :subcmd:`unuse` sub-command rejects the option as an
  invalid one: it relies on :mfcmd:`remove-path`, which does not need a
  priority to select the modulepath to remove.
* Priority on :envvar:`MODULEPATH` changes the order modulepaths are
  searched, so it changes which modulefile is found first when several
  modulepaths provide the same module name. It does not change the
  mechanisms that react to the modulepaths being enabled or disabled, which
  depend on :envvar:`MODULEPATH` content, not on its order. This is also
  what happens on Lmod, whose hierarchy mechanism only reacts to
  :envvar:`MODULEPATH` content changes.
* Initial values defined with the :mconfig:`init_envvars` configuration
  option get no priority. Elements set by :mfcmd:`setenv` get no priority.
* Elements added back by :mfcmd:`remove-path` with the
  ``--append-on-unload`` or ``--prepend-on-unload`` options get no priority.
* When a modulefile is unloaded, :mfcmd:`prepend-path` and
  :mfcmd:`append-path` become :mfcmd:`remove-path`. The ``--priority``
  option is parsed and ignored in this context. The demands of the unloaded
  modulefile on the removed elements are withdrawn from the priority record,
  whether these elements stay in the variable (reference counter greater
  than 1) or not. Elements not in the variable anymore are dropped from the
  record.
* The :mconfig:`linked_envvars` configuration option replays the exact same
  command on the linked variables, so the priority also applies to them.
* The :mfcmd:`prepend-path` and :mfcmd:`append-path` commands are
  evaluated in *scan* and *whatis* modes through a stripped-down procedure
  that only parses the command arguments. The ``--priority`` option is
  accepted there and has no effect.
* The modulefile syntax database used by the :subcmd:`lint` sub-command is
  updated to know the ``--priority`` option and its argument.

Future work
-----------

The priority set from the command line on modulepaths could be recorded in
collections, so :subcmd:`restore` sets it again. The ``module use`` lines
of a collection would carry the ``--priority`` option, in the ``--prepend``
or ``--append`` form depending on the demand side, with consecutive
modulepaths sharing the same priority set on a single line to preserve
their relative order. Reading a collection would then sort the modulepaths
by weight to reflect the :envvar:`MODULEPATH` value these lines produce,
and :subcmd:`restore` would compare the current and recorded priorities to
enable again the modulepaths whose priority differs. Such collection needs
a header stating the minimum Modules version able to read it, as former
versions would take the ``--priority`` option for a modulepath. This is not
done yet, as priority on modulepaths is expected to be mainly set from
modulefiles, which collections already handle.

Implementation
--------------

* ``parsePathCommandArgs`` parses the ``--priority`` option and returns the
  priority value in addition to the other parsed elements. The value is
  checked to be a non-negative integer, except for :mfcmd:`remove-path`
  where it is ignored with a warning.
* ``getPriorityVarName``, ``getPriorityArray`` and
  ``setPriorityRecordValue`` procedures manage the priority record, mirroring
  ``getModshareVarName``, ``getReferenceCountArray`` and
  ``setReferenceCountRecordValue``. ``getPathElementWeight`` returns the
  weight of an element from its demand list, depending on the
  :mconfig:`path_entry_reorder` configuration option.
* ``add-path`` records the demand of the current module on each added
  element, unless the element is already in the variable and
  :mconfig:`path_entry_reorder` is disabled, and, once the new variable
  value is built with the elements
  inserted at the beginning or the end of the variable as usual, sorts its
  elements by weight when at least one element has a demand. The ``lsort``
  Tcl command implements a stable merge sort: elements with the same weight
  keep the relative order they have in the built value, so the sort only
  moves elements across groups and the insertion position decides the order
  within a group.
* ``unload-path`` rewrites the priority record once the elements have been
  removed, to withdraw the demands of the current module on these elements
  (``withdrawPriorityDemands``) and to drop the entries of the elements that
  are not in the variable anymore. It then sorts the variable by weight when
  :mconfig:`path_entry_reorder` is enabled, to move the elements whose
  applying demand has changed.
* ``setenv``, ``unsetenv`` and ``pushenv`` clear the priority record when
  they clear the reference counter record.
* The ``--priority`` and ``--priority=*`` switches are added to the list of
  command-specific switches recognized by the ``module`` procedure, so they
  reach the :subcmd:`prepend-path`, :subcmd:`append-path` and :subcmd:`use`
  sub-commands.
