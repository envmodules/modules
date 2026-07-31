.. _module-find-and-resolution:

Module find and resolution process
==================================

Description of the procedures involved in turning a module specification
string into either the full list of modulefiles it matches or the single
modulefile it designates, and of how these procedures cooperate with the
other mechanisms (module cache, extra match search, hiding, variants,
tags, aliases and symbolic versions) that can alter their result.

This document complements :ref:`module-selection-contexts`, which describes
*when* each context (return all matching modules / select one module) is
used by which sub-command. This document describes *how* these two contexts
are actually implemented.

Overview
--------

Locating modules on a modulepath directory is split across three layers,
from the lowest (raw filesystem/cache walk) to the highest (single module
selection):

* ``findModules`` (and the ``findModulesFromDirsAndFiles`` walk-down helper
  it relies on) lists every filesystem or cache entry relevant to a search,
  with no knowledge of aliases, symbolic versions, hiding, variants or
  defaults.
* ``getModules`` consolidates this raw listing with alias, symbolic version,
  virtual module, hiding and extra match search information, and computes
  the default (and, if enabled, the *latest*) element of each directory. It
  implements the :ref:`module_version_specification_to_return_all_matching_modules`
  context.
* ``getPathToModule`` calls ``getModules`` for each modulepath directory (in
  precedence order) and walks its result down to exactly one modulefile,
  resolving aliases, symbolic versions and directory defaults as needed. It
  implements the :ref:`module_version_specification_to_select_one_module`
  context.

A module specification string, as typed by the user or passed by a
modulefile command, is parsed once beforehand by ``parseModuleSpecification``
(``modspec.tcl``, see :ref:`advanced-module-version-specifiers`) which stores
the parsed structure in the ``g_moduleVersSpec`` global array keyed by the
raw argument string itself. Downstream procedures keep passing around this
raw string as their ``mod`` argument and pull back the structured fields
(name, version comparator, variant list, extra specifiers, ...) through
accessor procedures (``getModuleNameFromVersSpec``,
``getCmpSpecFromVersSpec``, ``getModuleRootFromVersSpec``, ``...``) whenever
needed. Passing a string never registered in ``g_moduleVersSpec`` still
works: accessors fall back to plain ``file dirname``/``file tail`` style
parsing, which is how ``getPathToModule`` and ``getModules`` can also be
called internally with a bare resolved module name.

::

   module load foo/1.2
      -> parseModuleSpecification            (modspec.tcl)
      -> getPathToModule "foo/1.2"           (one match, per modulepath dir)
           -> getModules $dir "foo/1.2" ...  (all matches in this dir)
                -> findModules $dir foo ...  (raw filesystem/cache listing)
           -> resolve alias/version/directory entries until a modulefile,
              virtual module or error is reached

Finding every matching entry: ``findModules``
---------------------------------------------

``findModules`` returns, for one modulepath directory, every element
(modulefile, ``.modulerc``/``.version`` file, or sub-directory) whose name
may be relevant to a search, without evaluating any of it beyond the module
header validity check (``checkValidModule``). Its result is an array
(flattened as a list) keyed by module-relative path, one of:

* ``{modulefile <mtime> <full-path>}``
* ``{modulerc}`` (a ``.modulerc`` or ``.version`` file, further processed by
  ``getModules``)
* ``{invalid <msg> <full-path>}`` / ``{accesserr <msg> <full-path>}``

Sub-directories are walked down recursively by
``findModulesFromDirsAndFiles``, honoring the ``ignored_dirs`` configuration
option and skipping backup/lock file name patterns (``*~``, ``*,v``,
``#*#``, ``.modulecache``). When not in *in-depth* mode (``depthlvl`` set to
the query depth plus one rather than ``0``), a directory stops being
expanded further once a valid modulefile has already been found for it at
the target depth, and ``.version`` files from other depths are skipped, both
of which save filesystem access on directories not relevant to the query.

If a module cache file (``.modulecache``) is available and fresh for the
directory, ``findModulesInCacheFile`` (see :ref:`module-cache`) is used
instead of walking the directory, transparently to every caller of
``findModules``/``getModules``/``getPathToModule``.

Results are memoized in ``g_foundModulesMemCache``, keyed by
``dir:mod:depthlvl:fetch_mtime:stop_mod`` (see `Skipping sibling validation
on exact version resolution`_ for ``stop_mod``). A later, narrower search can
reuse a previously cached broader result: cache keys are matched with
``string match`` so a cache entry gathered with a wildcard pattern (for
instance a prior full ``*`` listing of the directory) is recognized as a
superset covering the new, more specific query.

Consolidating and filtering: ``getModules``
-------------------------------------------

``getModules`` takes a modulepath directory and a module specification and
returns every entry it contains that is relevant to that specification:
modulefiles, directories (with their computed default element), symbolic
versions, aliases and virtual modules, plus any hidden or erroneous element
that specifically matches the query. Its signature is:

.. code-block:: text

   getModules dir ?mod? ?fetch_mtime? ?search? ?filter?

``search`` is a list of flags altering search semantics:

* ``noindepth`` — restrict the search to the query's own depth level rather
  than recursing into every matching sub-directory (used by ``avail`` and
  ``whatis`` unless ``avail_indepth``/``spider_indepth`` is enabled).
* ``contains`` — substring match instead of prefix/exact match (``-C``,
  ``--contains``).
* ``wild`` — the specification should be treated as a wildcard pattern.
* ``resolve`` — the result is gathered for a *select one module* context;
  the only caller passing this flag is ``getPathToModule``. It enables the
  fast path described in `Skipping sibling validation on exact version
  resolution`_, and makes a bare directory name additionally match its
  ``default`` symbolic version when checking whether a hidden element should
  stay visible.
* ``rc_defs_included`` — also include alias and symbolic version
  definitions coming from the global or user modulerc files.
* ``rc_alias_only`` — return only global/user rc aliases; no directory
  lookup is performed at all.

``filter`` keeps or drops entries after the search itself: ``noplaindir``
drops directories without any resolvable symbol (used by ``paths``),
``onlydefaults``/``onlylatest`` keep only each directory's default or latest
element (``-d``/``-L`` options).

``getModules`` proceeds through a fixed sequence of phases (numbered as such
in the source code comments):

#. **Consolidate** every kind of entry found by ``findModules`` in the
   result array: ``.modulerc``/``.version`` files are evaluated right away
   (unless already sourced, tracked through ``g_rcfilesSourced``, which
   populates the ``g_moduleAlias``/``g_moduleVersion``/``g_moduleVirtual``
   global tables), then alias, symbolic version and virtual module
   definitions applying to this directory (or, if ``rc_defs_included`` is
   set, to the global/user rc files) are merged in.
#. **Early filtering**: when the query's root name has no wildcard
   character, entries whose root does not match it are dropped immediately,
   before the more expensive phases below run.
#. **Extra match search scan**: if required by the query (see
   :ref:`extra-match-search`), every modulefile/virtual module entry still
   in the result is evaluated in ``scan`` mode to gather its variant, tag and
   extra specifier content; provided aliases are inserted into the result if
   requested.
#. **Filter out dynamically hidden or expired elements**: entries hidden by
   :ref:`hide-or-forbid-modulefile` rules are dropped, unless the query
   specifically targets them (or one of their symbols); a *forbidden* entry
   that is specifically targeted is turned into an ``accesserr`` entry
   instead of being silently dropped.
#. **Elaborate directory content and select each directory's default
   element**: an explicit default (an entry named ``default`` resolving
   through a symbolic version) takes precedence; otherwise, if
   :mconfig:`implicit_default` is enabled, the dictionary-highest remaining
   sibling is used (see :ref:`default-latest-version-specifiers` and
   :ref:`extended-default`). If :mconfig:`advanced_version_spec` and
   :mconfig:`implicit_default` are both enabled and the query is not a
   variant-only wildcard, this is also where the ``default``/``latest``
   *auto symbols* are synthesized for every directory the query's root name
   applies to, through ``setModuleResolution``.
#. **Extra match search filtering**: entries not matching the variant, tag
   or extra specifier criteria collected in phase 3 are withdrawn, cascading
   to any symbolic version (including an auto symbol) pointing at a
   withdrawn entry.
#. **Filter results down to the search query**: entries not matching the
   query's name/version/depth are dropped, directories are re-elaborated
   against the filtered set (so a directory's default may change if its
   previous default got filtered out), *no-indepth* mode trims anything
   deeper than the query, and the ``filter`` argument's ``onlydefaults``/
   ``onlylatest``/``noplaindir`` keep-list is applied.
#. **Consolidate tags**: for ``avail``/``spider`` only, and once per
   modulepath directory, every retained modulefile/alias/virtual module has
   its applicable tags collected (see :ref:`module-tags`) ahead of listing.

The result (an array, flattened as a list, of the same entry-kind shapes as
``findModules``, plus ``version``/``alias``/``virtual`` kinds) is memoized in
``g_gotModulesMemCache``, keyed by ``dir:mod:fetch_mtime:search:filter``.

Selecting one module: ``getPathToModule``
-----------------------------------------

``getPathToModule`` resolves a specification down to a single modulefile.
Its signature is:

.. code-block:: text

   getPathToModule mod ?indir? ?report_issue? ?look_loaded? ?excdir?

* ``indir`` restricts the search to a given list of directories instead of
  the full enabled modulepath list.
* ``report_issue`` controls whether a resolution failure is reported through
  ``reportIssue`` directly by this procedure, or left for the caller to
  handle (several sub-commands pass ``0`` and produce their own message).
* ``look_loaded`` (``no``/``exact``/``match``/``close``), when not ``no``,
  resolves against already-*loaded* modules instead of the filesystem
  (``getLoadedExactName``/``getLoadedEqstartName``/``getLoadedWithClosestName``
  respectively), used to resolve a single-name argument to ``unload`` or
  ``switch``. A non-match in this mode is a ``notloaded`` result and is
  never reported as an issue, even when ``report_issue`` is set.
* ``excdir`` lists directories to skip, used by ``switch`` to continue a
  search in the directories not already covered by a prior call.

Three cases are handled before any modulepath search happens: an empty
``mod`` is an immediate error; a ``look_loaded`` request is resolved as
above; and a full pathname (matching ``^(|\.|\.\.)/``, i.e. starting with
``/``, ``./`` or ``../``) bypasses modulepath search entirely — only
``checkValidModule`` is applied to the literal file, and the module name
*is* the path. No modulerc-based hiding or forbidding applies in this case
except through a *global* rc file (see :ref:`hide-or-forbid-modulefile`).

Otherwise, for each candidate directory in modulepath precedence order
(minus ``excdir``):

#. ``getModules`` is called with the ``resolve`` search flag (the only call
   site using it in the whole codebase), returning every entry in this
   directory relevant to the query.
#. The looked-up key is resolved against the result array
   (``getEqArrayKey``, case-insensitive- and implicit-default-aware), then
   handled according to its entry kind:

   * ``alias``/``version`` — resolved through ``resolveModuleVersionOrAlias``.
     If the target is present in the same directory's result, the walk
     continues in place; otherwise a full new call to ``getPathToModule`` is
     made on the resolved name (any variant collected so far is folded into
     it first). This recursive call only forwards ``indir`` and
     ``report_issue``; it does not carry over ``excdir`` or ``look_loaded``.
   * ``directory`` — the walk moves to the directory's computed default
     element; with no default available (:mconfig:`implicit_default`
     disabled and no explicit default set), resolution fails with *"No
     default version defined for '...'"*. If the default element turns out
     to be a hidden sub-directory not present in the current result, a new
     ``getPathToModule`` call is made on it (same recursion rules as above).
   * ``modulefile`` — resolution is complete; the modulefile's path is
     returned.
   * ``virtual`` — resolution is complete; the virtual module's target file
     is returned, with the virtual module's own name kept as the reported
     module name.
   * ``invalid``/``accesserr`` — resolution ends in error.

   The per-directory loop stops as soon as **anything** is found for the
   query in the current directory — including an error — so a later
   modulepath directory holding a valid module of the same name is never
   reached if an earlier directory already produced an invalid or
   inaccessible match.

Once a candidate (successful or not) is found, or every directory has been
tried without any match, the specified variant (if any) is attached to the
resolved module name, and the *forbidden* tag is checked one final time
against the fully resolved target — catching a target reached indirectly
through an alias or a directory default, since resolving through those does
not itself carry forbidden status (see :ref:`hide-or-forbid-modulefile`).

Skipping sibling validation on exact version resolution
-------------------------------------------------------

Resolving an exact ``name/version`` specification (as done for instance by
``load``) still requires computing the queried directory's default/latest
element, in order to determine whether the resolved module should carry the
``default``/``latest`` alternate names (see
:ref:`default-latest-version-specifiers`). Naively, this means validating
(``checkValidModule``) and hidden-testing every sibling in that directory,
even though only the queried version and, at most, the true highest sibling
are actually needed to answer both questions at once. On directories with
hundreds or thousands of versions of the same module, this dominates
resolution time on an otherwise uncached modulepath.

``getModules`` computes a ``stop_mod`` value — set to the query's
``name/version`` — whenever all of the following hold, i.e. the query is
resolved in a single-module context and cannot itself be satisfied by
several different directory elements:

* the ``resolve`` search flag is set (so, only when called from
  ``getPathToModule``);
* the query's root name has no wildcard character;
* no ``filter`` (``onlydefaults``/``onlylatest``/``noplaindir``) applies;
* the query's version comparator is a plain equality (not a range or list);
* the query is a flat, single-depth ``name/version`` (not e.g.
  ``name/sub/version``).

In any other case ``stop_mod`` is left empty and every procedure below
behaves exactly as if the optimization did not exist — it never changes
what is returned, only how much sibling validation is performed to get
there. Listing sub-commands (``avail``, ``whatis``, ``search``, ...) and
bare module name resolution are always unaffected.

``stop_mod`` is threaded through ``findModules`` into
``findModulesFromDirsAndFiles``, which hands it, together with the directory
currently being walked, to ``trimElemListForStopmod`` right before that
directory's raw element list is folded into the overall search. This helper
only ever activates for the one directory that is ``stop_mod``'s own parent,
and only if ``stop_mod`` itself exists there and is a valid modulefile —
in any other case it leaves the element list untouched. When it does
activate, it:

* keeps ``.modulerc``/``.version`` files untouched, letting ``getModules``'s
  normal consolidation phase process them as usual;
* proactively sources the modulepath-root ``.modulerc`` and then this
  directory's own ``.modulerc``/``.version`` right away (guarded by the same
  ``g_rcfilesSourced`` tracking used later on, to avoid sourcing them
  twice), since a hiding rule set by either of them may affect which sibling
  actually qualifies as the true default/latest;
* dictionary-sorts the directory's plain elements and walks down from the
  highest one to ``stop_mod``'s own position, stopping at the first sibling
  that is itself a valid, non-hidden modulefile — that sibling (or
  ``stop_mod`` itself, if nothing higher qualifies) is this directory's true
  implicit default/latest;
* if any element visited along that walk is itself a sub-directory (a
  deeper version layout), the optimization gives up for this directory and
  the full, unmodified element list is used instead;
* keeps only ``stop_mod``'s own element and, if one was found above it, that
  one qualifying higher element — every other sibling is dropped from what
  gets validated and returned.

A module cache file (``.modulecache``) is read as a single, whole-file I/O
operation regardless of query shape (see :ref:`module-cache`), so
``findModulesInCacheFile`` has no ``stop_mod`` awareness: this optimization
only benefits directories walked live on the filesystem, which is precisely
the case a cache file is meant to avoid in the first place.

Result caching
--------------

Both ``findModules`` and ``getModules`` memoize their results for the
lifetime of the current ``module`` invocation, in ``g_foundModulesMemCache``
and ``g_gotModulesMemCache`` respectively, each keyed by a string compacting
every argument that affects the result (directory, specification, depth
level, and the relevant flags — including ``stop_mod`` for the former).
Repeated resolution of the same or a related specification against the same
directory — for instance while ``getPathToModule`` walks through an alias or
a directory default — reuses these cached results instead of re-walking the
filesystem or re-evaluating modulerc files.

See also
--------

The following existing design documents cover behaviors that interact with
module find and resolution but are not restated here:

* :ref:`module-selection-contexts` — the four contexts a module
  specification can be resolved in, and which sub-command uses which.
* :ref:`advanced-module-version-specifiers` — the ``@``-based specification
  grammar (ranges, lists, variants) parsed ahead of ``getModules``/
  ``getPathToModule``.
* :ref:`default-latest-version-specifiers` — explicit vs. implicit default,
  the ``latest`` specifier, and the auto symbol mechanism computed in
  ``getModules``' fifth phase.
* :ref:`extended-default` — partial version matching against a directory's
  siblings.
* :ref:`insensitive-case` — case-insensitive matching and its tie-break
  rules.
* :ref:`extra-match-search` — variant, tag and extra specifier filtering
  performed as part of ``getModules``' third and sixth phases.
* :ref:`hide-or-forbid-modulefile` — hiding levels and forbidding, applied
  in ``getModules``' fourth phase and re-checked by ``getPathToModule``.
* :ref:`module-cache` — the ``.modulecache`` file format and how it
  transparently replaces the directory walk performed by ``findModules``.
* :ref:`variants` — variant specification grammar and comparison rules.
* :ref:`module-tags` — the tag mechanism used by hiding, forbidding and
  extra match search alike.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
