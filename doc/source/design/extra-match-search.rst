.. _extra-match-search:

Extra match search
==================

Traditional module lookup only performs modulefile search, module version
resolution, module alias and symbolic version resolution. This is based on
file lookup and evaluation of modulerc files.

Searching modules with a query exceeding traditional lookup is called *extra
match search*. It mainly looks at modulefile content to retain those matching
specified query. This content lookup requires a specific modulefile evaluation
(see `Modulefile evaluation mode for extra match search`_).

Requirements
------------

An extra match search query requires :ref:`advanced-module-version-specifiers`
configuration to be enabled. Otherwise query specifiers will be understood as
module name and version.

When extra match search applies
-------------------------------

On :ref:`module_version_specification_to_return_all_matching_modules` context.
On such context, variant specification in search query was previously ignored.
Extra match search adds here a feature to filter returned results.

On :ref:`module_version_specification_to_select_one_module` context, extra
match search is not enabled at the moment. As it changes obtained result. For
instance when loading a module with a given variant value, *extra match
search* will remove from available modules those not declaring this variant
and its specified value. It is considered to add an option to apply *extra
match search* to the *select one module* context. This option will be disabled
by default on Modules v5 and enabled by default on v6.

What triggers an extra match search?
------------------------------------

* module variants or provided module aliases should be reported
* variant is specified in query on :subcmd:`avail`, :subcmd:`paths`,
  :subcmd:`spider` or :subcmd:`whatis`
* an extra specifier is specified in query

Extra match search process
--------------------------

Extra match search is performed from ``getModules`` procedure. All subsequent
procedures relying on ``getModules`` will then benefit from this extra process
without a change.

Modulefile scan for Extra match search is done after *phase 2: early filtering
of non-matching elements*. Right after this scan, collected provided
aliases will be included into the search result list, if enabled, to apply
them phase 4 and phase 5 filtering stages.

Module filtering for Extra match search is done right after *phase 5:
elaborate directory content with default element selection*. At this stage:

* symbolic versions, aliases and virtual modules are known
* dynamically hidden or expired elements have been filtered
* automatically defined symbols are set
* initial directory content and their default version are set

This way the subsequent phases that filters result based on name and version
search query, adjusts directory content and no-indepth mode does not need to be
updated and will apply on the extra match search result.

In case no-indepth mode is asked and extra match search should be performed,
traditional file lookup (by ``findModules``) is made to return all existing
files. Not only those matching depth level. As extra match filtering process
may eliminate some entries, all of them should be tested to obtain accurate
result.

If provided aliases should be reported, all modulefiles should be scanned to
fetch all aliases they defined. Thus ``findModules`` is asked to get all
modulefiles and *phase 2* early filtering is skipped.

Extra match search will only be performed if search query requires it. It will
be determined by ``isExtraMatchSearchRequired`` procedure. See `What triggers
an extra match search?`_ for applying conditions. Current search module
specification is passed as argument. This string helps to find if:

* variant has been specified in *ModuleVersSpec* structure
* extra specifier has been specified in *ModuleVersSpec* structure

If search query is a traditional one, no extra match search is performed. It
saves this way substantial processing time as no evaluation of modulefile is
performed.

``getModules`` will call dedicated procedures:

* ``scanExtraMatchSearch`` evaluates all entries in obtained result array that
  are of modulefile or virtual types. See `Modulefile evaluation mode for
  extra match search`_ section.
* ``insertProvidedAliases`` adds provided aliases found during scan to the
  result array.
* ``filterExtraMatchSearch`` filters entries from result array with the
  consolidated information gathered from scan evaluations. Entries that do not
  match the extra match query are withdrawn.

These 3 procedures obtains the name of result array as argument and will bind
to this array variable (to change it without copy). Search module
specification is also set as argument to help to know the extra match query to
filter modules on.

Symbolic versions
^^^^^^^^^^^^^^^^^

From ``filterExtraMatchSearch``, symbolic version elements are retained unless
if they target an element that is withdrawn by the filter process.

They need to be filtered if their target is filtered as it may confuse some
sub-commands like ``paths`` if they are part of ``getModules`` result.

During wild search (no module name specified) with variant specified, auto
symbolic versions (*latest* and *default*) are disabled. This is done
especially for sub-commands like ``paths`` that take getModules result and try
to resolve each entry. In this situation it is important not to have any auto
symbol that indirectly targets an element withdrawn from extra match filter.

Module aliases
^^^^^^^^^^^^^^

From ``filterExtraMatchSearch``, module alias elements are purely withdrawn by
the filter process as they are not resolved on *return all matching modules*
context. They are also withdrawn even if searched module name matches alias
name.

They need to be filtered when search query mentions a specific variant and
value as alias does not define variant in itself.

When variants have to be reported but are not part of the search query, then
no filtering process occurs, aliases are not withdrawn.

Directories overridden by aliases take precedence over these aliases when
*extra match search* is performed.

FUTURE: it may be revised to implement extra match search on *select one
module* context.

Module tags
^^^^^^^^^^^

Modulefiles tagged *forbidden* are excluded from evaluation mechanism. If
forbidden tag only applies to some specific variant values, modulefile is
evaluated.

Note that in a *select one module* context, if forbidden tag applies
specifically to searched variant, this module is excluded from result.

If module hidden tag only applies to some specific variant values, modulefile
is evaluated in scan mode.

Error entries
^^^^^^^^^^^^^

Files in error (e.g., without a module header string, not readable) are
ignored by ``filterExtraMatchSearch`` and kept in result array. These error
entries are useful to report the message they contain if erroneous file was
specifically selected.

Extra specifier
---------------

Extra specifier enables to query whose modules defines a given element. With
them it is possible to get all the modules defining a given environment
variable or requiring a given module.

Most of the modulefile Tcl commands are associated to an extra specifier. Some
aliases are also provided, to gather several command elements into the general
same concept they are about. Following table list the available extra
specifiers and their associated modulefile command.

+--------------------+-----------------------------------------+
| Modulefile command | Extra specifier(s)                      |
+====================+=========================================+
| variant            | variant                                 |
+--------------------+-----------------------------------------+
| setenv             | setenv, envvar                          |
+--------------------+-----------------------------------------+
| unsetenv           | unsetenv, envvar                        |
+--------------------+-----------------------------------------+
| pushenv            | pushenv, envvar                         |
+--------------------+-----------------------------------------+
| append-path        | append-path, envvar,                    |
|                    | use (if envvar is MODULEPATH)           |
+--------------------+-----------------------------------------+
| prepend-path       | prepend-path, envvar,                   |
|                    | use (if envvar is MODULEPATH)           |
+--------------------+-----------------------------------------+
| remove-path        | remove-path, envvar                     |
+--------------------+-----------------------------------------+
| complete           | complete                                |
+--------------------+-----------------------------------------+
| uncomplete         | uncomplete                              |
+--------------------+-----------------------------------------+
| set-alias          | set-alias                               |
+--------------------+-----------------------------------------+
| unset-alias        | unset-alias                             |
+--------------------+-----------------------------------------+
| set-function       | set-function                            |
+--------------------+-----------------------------------------+
| unset-function     | unset-function                          |
+--------------------+-----------------------------------------+
| chdir              | chdir                                   |
+--------------------+-----------------------------------------+
| umask              | umask                                   |
+--------------------+-----------------------------------------+
| family             | family, provided-alias                  |
+--------------------+-----------------------------------------+
| provide            | provide, provided-alias                 |
+--------------------+-----------------------------------------+
| prereq             | prereq, prereq-any, require             |
+--------------------+-----------------------------------------+
| prereq-any         | prereq-any, depends-on-any, prereq,     |
|                    | require                                 |
+--------------------+-----------------------------------------+
| prereq-all         | prereq-all, depends-on, require         |
+--------------------+-----------------------------------------+
| depends-on         | depends-on, prereq-all, require         |
+--------------------+-----------------------------------------+
| depends-on-any     | depends-on-any, prereq-any, prereq,     |
|                    | require                                 |
+--------------------+-----------------------------------------+
| always-load        | always-load, require                    |
+--------------------+-----------------------------------------+
| conflict           | conflict, incompat                      |
+--------------------+-----------------------------------------+
| module load        | load, require                           |
+--------------------+-----------------------------------------+
| module load-any    | load-any, require                       |
+--------------------+-----------------------------------------+
| module try-load    | try-load, require                       |
+--------------------+-----------------------------------------+
| module unload      | unload, incompat                        |
+--------------------+-----------------------------------------+
| module switch      | switch, switch-on, require, switch-off, |
|                    | incompat                                |
+--------------------+-----------------------------------------+
| module use         | use                                     |
+--------------------+-----------------------------------------+

+--------------------+-----------------------------------------+
| Modulerc command   | Extra specifier(s)                      |
+====================+=========================================+
| module-tag         | tag                                     |
+--------------------+-----------------------------------------+
| module-hide        | tag                                     |
+--------------------+-----------------------------------------+
| module-forbid      | tag                                     |
+--------------------+-----------------------------------------+
| module-warn        | tag                                     |
+--------------------+-----------------------------------------+

Extra specifier are only valid on *return all matching modules* context. An
error is returned when used in query on other contexts.

Using an unknown extra specifier (not part of the above table) produces an
error. Helps to distinguish between a bad specification and no modulefile
declaring the associated modulefile command.

Extra specifier are not made to resolve module alias or symbolic version, as
such resolution is part of the regular match search.

The ``module switch`` command produces content in different extra specifiers.
Switched-on module can be queried via ``switch``, ``switch-on`` and
``require`` specifiers. Switched-off module can be queried via ``switch``,
``switch-off`` and ``incompat`` specifiers. On its one-arg form, no
switched-off module is added to relative specifiers.

Change on the ``MODULEPATH`` environment variable either through
``module use``, ``append-path`` or ``prepend-path`` may be queried with
``use`` extra specifier. Modulepath are translated to their absolute path form
to be recorded. Variable reference are resolved at record time. Symbolic links
are recorded as is (they are not translated into their target)

Recording extra specifier specification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Extra specifiers defined in a search query are processed and saved in
*ModuleVersSpec* structure along other query elements. As the search query
string is passed along the procedures, it is possible to retrieved the
extra specifier properties from this query string (with
``getExtraListFromVersSpec`` procedure).

Extra specifiers are saved as a list of list. Every extra specifier defined in
query is set as a list whose first element is extra specifier name, then the
other element corresponds to the list of values provided to this argument.

For example, search query ``mod/1.0 setenv:FOO variant:bar setenv:BAR``
produces internal representation ``{setenv FOO} {variant bar} {setenv BAR}``.

Another example with multiple values, search query ``mod/1.0 setenv:FOO,BAR``
produces internal representation ``{setenv FOO BAR}``.

Value specified may contain a space character if it is escaped on command line
either by quotes (``"prereq:mod@1.0 foo=bar"``) or backslash
(``prereq:mod@1.0\ foo=bar``). This is especially useful for complex module
specification.

Filtering extra specifier results
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Every *-sc* variant of modulefile Tcl command, record their properties in the
``g_scanModuleElt`` global dictionary. It is a nested structure that contains
at the top level the list of defined extra specifier names. Each of these
names is in turn a structure that contains all defined extra specifier values
associated to the module name and version defining this extra specifier name
and value pair.

For example, when module *mod/1.0* defines *setenv FOO value* in its file,
then the global dictionary is updated to add *mod/1.0* to the *setenv > FOO*
nested key.

When extra specifier has alias name(s), each of these aliases have their own
entry in the global directory. Reusing the previous example, *envvar* is an
alias on *setenv* extra specifier. When module *mod/1.0* defines *setenv FOO
value*, the global dictionary is also updated to add *mod/1.0* to the *envvar
> FOO* nested key (in addition to the *setenv > FOO* nested key.

Such data structure optimizes filtering work: it is done once for all
modulefiles after finishing the scan evaluation of all of them. For each
extra specifier criteria, goal is to match the corresponding nested key in
``g_scanModuleElt`` global directory. Modulefiles to keep in result of those
listed as value in every matched nested keys.

When there are several extra specifiers in search query, result are the
modules present in the value list of every matched keys (intersection of value
list obtained for every extra specifier criterion).

Module tags, queried with *tag* extra specifier, are not recorded in the
same structure than other extra specifier. Regular tag mechanism and recording
structure is used.

Specific filtering work is achieved for extra specifiers accepting a module
specification. See next section.

Filtering module specification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some extra specifiers accept a module specification as value. It corresponds
to all extra specifiers relative to requirements and incompatibilities
expressed by modulefiles (*prereq*, *conflict*, etc).

Module specification passed as extra specifier value has to be compared to the
module specification set in the modulefile definition for corresponding
command.

When parsing such extra specifier value, when evaluating command line
arguments, module specification is parsed with a specific available module
resolution: all matching available modules are recorded into module
specification (``g_moduleVersSpec``). It enables to fetch:

* every module name and version matching a version list or range specification
* every generic or fully qualified names

Match against modulefile definitions of such extra specifiers is performed in
the same location than for other extra specifiers. It relies on a ``modEq``
comparison that has been adapted to also compare alternative names fetched and
stored into module specification structure. Relying on ``modEq`` procedure,
comparison leverages *icase* and *extended_default* features.

**LIMITATIONS**: Current module specification match does not support:

* Comparison of module alias or symbolic names when used in either extra
  specifier value or in modulefile definition
* Version range or list specified in extra specifier value is converted into
  a list of existing modulefiles, thus a version in such specification that
  does not correspond to an existing module will not be matched

Variant value comparison is enabled on ``modEq`` test. ``modVariantCmp``
internal test has been adapted to let a missing variant definition be
considered as a match.

Query grammar
-------------

In extra match search query, variants are expressed like in *select one
module* context:

* multiple variants mentioned act as an *AND* operation

  * ``module avail mod/1.0 foo=val1 bar=val2``
  * means module defines *foo* variant with *val1* as an available value and
    *bar* variant with *val2* as an available value

* same variant mentioned multiple times: all mentions retained and act as an
  *AND* operation

  * ``module avail mod/1.0 foo=val1 foo=val2``
  * means module defines *foo* variant with *val1* and *val2* as available
    values

Behavior for a single variant specified multiple times is adapted on *return
all matching modules* context to be the same as a single extra specifier set
multiple times.

In extra match search query, extra specifiers are expressed with *name:value*
syntax. Using *:* as separator helps to distinguish from variant
specification. As a consequence, such character is not recommended to be part
of a module name or version (which was already the case, as *:* character is
also a separator used in environment variables like *LOADEDMODULES*). As extra
specifiers only applies to *return all matching modules* context, the use of
*name:value* specific syntax may help user to distinguish from the *select one
module* context.

NOTE: use of a *--where* or *--with* options was also considered to be able
to use a *name=value* syntax like variant specification. It was preferred to
use a different syntax (*name:value*) to avoid having to type an extra option.

NOTE: if *name=value* syntax where used for extra specifier, all extra
specifier names would have been forbidden to use as variant names.

* multiple extra specifiers mentioned act as an *AND* operation

  * ``module avail mod/1.0 setenv:FOO pushenv:BAR``
  * means module defines *setenv* command to set *FOO* environment variable
    and defines *pushenv* command to set BAR*

* same extra specifier mentioned multiple times: all mentions retained and act
  as an *AND* operation

  * ``module avail mod/1.0 variant:foo variant:bar``
  * means defines variant *foo* and variant *bar*

Value of either variant or extra specifier are full name. No wildcard
characters are taken into account (they are treated literally).

An error is raised when an empty extra specifier name or value is specified.

Expressing an *OR* operation

* for instance by mentioning multiple values separated by ``,`` character
* ``module avail mod/1.0 foo=val1,val2 bar=val2``
* means *foo* equals *val1* or *val2* and *bar* equals *val2*
* such syntax is equivalent to version list specification
* does not seem useful to allow ranges like for version
* Such syntax is only allowed for *return all matching  modules* context

Expressing a *NOT* operation

* by adding a prefix string ``not:`` prior value
* ``module avail mod/1.0 not:foo=val1 bar=val2``
* means *bar* equals *val2* and either *foo* variant is not defined or it
  equals any value expect *val1*
* such syntax is only allowed for *return all matching modules* context
* ``not:`` syntax is chosen over prefix character like ``!``, which is
  interpreted as an event on shells like Tcsh or Bash, and ``~``, which is
  resolved a HOME directory path if following string matches an existing user
* NOTE: *NOT* operator is not specified currently on Spack's side.
* FUTURE: If a *not* keyword appear on Spack later on, it may also be
  supported here as an alias over the ``not:`` prefix.

What triggers ``scan`` evaluation?
----------------------------------

* everything that triggers an extra match search
* except *tag* extra specifier, as tags are defined outside of modulefiles

Modulefile evaluation mode for extra match search
-------------------------------------------------

A specific evaluation mode is created for looking at modulefile content in
order to solve an extra match search. This mode is named ``scan``.

Modulefile Tcl interpreter is configured to run a specific variant of
modulefile Tcl commands. These variants will gather content of modulefile in
global structures that will be searched after all *scan* evaluations to
determine what modules match the extra query. Names of scan variant of
modulefile Tcl command scan variant procedures are internally suffixed with
*-sc*.

If modulefile content queries the current evaluation mode, it will obtain the
``scan`` string during a *scan* evaluation. We expect modulefile code to cope
with this behavior, especially to still be able to get all *load* information
of modulefile, even if mode is not ``load``. A ``load`` string cannot be
returned during a *scan* evaluation as modulefile may have some code to
produce log message when a *load* attempt is detected.

Even if extra match search only concern a specific element, like querying
module variants, all modulefile commands are setup to gather all content
information about modulefile. This way, it is evaluated the same way whatever
the query. Scan evaluation code will also be simpler.

Environment variable definition through modulefile commands like ``setenv``,
``append-path``, etc are handled like in ``whatis`` evaluation mode. Variables
are set to an empty value. Some processing time is saved this way. It may have
an impact on some complex modulefiles: content scan may not be accurate. If
this is an issue on some setup, an option could be added in the future to set
variable to their expected value also on ``whatis`` and ``scan`` evaluation
modes.

When an error is raised from a modulefile evaluation. No error message is
reported as such message is silenced during the whole ``avail`` process.
Rendered result is ok for all kind of errors even for ``break`` or ``exit``.
No error result is rendered for these two, unlike for a ``whatis`` evaluation,
not to disturb the whole search result for one modulefile not coping with scan
evaluation.

``puts`` commands in modulefile are rendered like on a ``whatis`` evaluation
mode: output is effectively produced toward the designated channel. It is up
to modulefile writer to handle the ``scan`` evaluation, like done for
``whatis``.

``source-sh`` commands in modulefile are rendered like on a ``load``
evaluation. They will produce ``setenv``, ``set-alias``, ``set-function`` and
so on commands that will be in turn evaluated in *scan* mode.

Specific impact
---------------

* With a ``contains`` search match every modulefiles in modulepath are
  evaluated in scan mode.

  - FUTURE: there may have room for optimization here

* As environment variable defined by modulefile commands like ``setenv`` are
  set to an empty value during scan evaluation, if a modulepath entry contains
  a reference to such environment variable, it will not match its expecting
  value.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
