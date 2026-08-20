.. _modulepath-ignore:

Ignore files in modulepath
==========================

When walking down the content of a modulepath directory to search for
modulefiles, every file found is checked to determine if it is a modulefile
and every sub-directory is walked down. Some modulepath directories contain
files that are not modulefiles: helper scripts sourced by modulefiles or
software installation files when modulefiles are mixed with the software
trees they describe.

Currently the only way to make the module command skip such files is to
give them a name starting with a dot character. This is not always possible
or desirable and it does not avoid these files to be tested or read. When
the amount of non-modulefiles is very large (millions of files), the
:subcmd:`cachebuild` sub-command takes a huge amount of time and memory as
an entry is recorded in the cache file for every invalid modulefile found
(see issue #562 and the discussion on the modules-interest mailing-list
linked there).

Objective is to let modulepath maintainers describe the content of their
modulepath directory that should be ignored when searching for modulefiles.
Ignored files and directories are treated as if they do not exist: they are
not tested, not walked down, not reported and not recorded in cache files.

``modulepath-ignore`` modulerc command
--------------------------------------

A new modulefile command is created: ``modulepath-ignore``. It takes one or
more file path patterns as arguments::

    modulepath-ignore pattern1 [pattern2 ...]

An error is raised if no argument is provided.

This command is registered as a command alias in the modulerc Tcl
interpreter (``g_modrcAliases`` in ``execute-modulerc``). It is also
registered in the modulefile interpreter per-mode alias table (like
``module-hide``), as global and user rc files are evaluated as modulefiles
through the ``source`` sub-command mechanism. The command itself raises an
error when evaluated from a file which is neither a rc file nor evaluated
in the global/user rc context (tracked by the ``rc_running`` state), so a
regular modulefile using it gets a *not allowed in modulefile* error. It is
set no-operation on *refresh* and *scan* evaluation modes.

The command may be called several times: patterns accumulate in their
definition order into a single ordered list.

The initial specification (issues #561 and #562) also proposed a
``modulepath-only`` command to switch from an *accept all, ignore some*
logic to an *ignore all, accept some* logic. This second command is
dropped: as pattern syntax follows the gitignore syntax (see below), its
negated patterns already cover this need. For instance to only take ``.mod``
files into account::

    modulepath-ignore * !*/ !*.mod

``*`` ignores everything, ``!*/`` re-includes directories so the walk down
continues, ``!*.mod`` re-includes files with the ``.mod`` extension.

The use case reported on the mailing-list (helper Tcl scripts stored next
to modulefiles) is solved with::

    modulepath-ignore *.tcl

Pattern syntax
--------------

Patterns follow the exact same syntax and behavior as git with
``.gitignore`` files:

* A pattern without slash (except an optional trailing one) matches files
  or directories at any depth below the directory of the rc file defining
  it. For instance ``*.tcl`` matches ``lib.tcl`` and ``mod/1.0/lib.tcl``.
* A pattern with a slash at its start or in its middle is anchored to the
  directory of the defining rc file. For instance ``mod/1*`` matches
  ``mod/1.0`` but not ``other/mod/1.0``.
* A pattern ending with a slash only matches directories.
* ``*`` matches anything except a slash. ``?`` matches any single character
  except a slash. ``[...]`` matches one character from a range or class.
* A leading ``**/`` means match in any directory (``**/foo`` equals
  ``foo``). A trailing ``/**`` matches everything inside the designated
  directory. ``a/**/b`` matches with zero or more intermediate directories.
* A pattern starting with ``!`` negates a previous match: the element is
  re-included. To match a file name starting with a literal ``!``, escape
  it with a backslash (``\!``).
* When several patterns match an element, the last matching pattern
  decides.
* It is not possible to re-include a file if one of its parent directories
  is ignored, as ignored directories are not walked down (same behavior as
  git).

As patterns are passed as Tcl command arguments and not read from a
dedicated file, the ``.gitignore`` file-format rules (comment lines, blank
lines, trailing space stripping) do not apply here.

Pattern anchoring and definition scope
--------------------------------------

``modulepath-ignore`` is honored in ``.modulerc`` files located within a
modulepath directory. Preferred location is the ``.modulerc`` file at the
root of the modulepath, as this file determines how to walk through the
modulepath content.

No specific restriction is set when the command is used in a ``.version``
file: it proceeds like it does in a ``.modulerc`` file, consistently with
the other modulerc commands which are all accepted in ``.version`` files.
The purpose of ``.version`` files is however to set the default version of
a directory, so module documentation will designate ``.modulerc`` as the
place where ``modulepath-ignore`` should be defined.

Each pattern is recorded along with its anchor directory, which is the
directory of the rc file defining it. For instance ``modulepath-ignore 1*``
in ``/path/to/modpath/foo/.modulerc`` produces a pattern equivalent to
``/path/to/modpath/foo/1*``. An element is matched against a pattern by
first checking the pattern anchor directory is one of its parent
directories, then matching its path relative to this anchor against the
pattern.

Recording the anchor directory along the pattern means the modulepath root
directory does not need to be known when the command is evaluated, and
patterns naturally apply only to the sub-tree of the rc file defining them.

As rc files of parent directories are evaluated before those of deeper
directories (see next section), patterns from deeper rc files are appended
after those of parent directories. Combined with the *last matching pattern
decides* rule, deeper rc files take precedence over parent ones, like git
does with nested ``.gitignore`` files.

When ``modulepath-ignore`` is evaluated from a rc file not located within a
modulepath directory (global rc, user rc), it registers global patterns.
Such patterns have no anchor directory: they apply to every modulepath,
matched against element paths relative to the root of the walked
modulepath, as if they were defined in the ``.modulerc`` file at this root.
As global and user rc files are evaluated at startup, before any modulepath
walk, global patterns come first in the pattern list: patterns defined
within a modulepath take precedence over them through the *last matching
pattern decides* rule.

Evaluation of rc files during modulepath walk
---------------------------------------------

Currently ``findModules`` collects the ``.modulerc`` and ``.version``
files found during the modulepath walk as ``modulerc`` entries in its
result list, and ``getModules`` evaluates them afterward, in sorted order,
during its consolidation phase.

This is too late for ``modulepath-ignore``: patterns must be known when the
walk occurs. Modulerc evaluation is thus moved to an earlier stage, in the
``findModulesFromDirsAndFiles`` procedure:

* No ordering requirement is set on the element list returned by
  ``getFilesInDirectory``: the rc files of a fetched directory are directly
  looked up by name in the element array built from this list, and the
  remaining elements are sorted in lexical order when inserted in the
  walked list.
* ``findModulesFromDirsAndFiles`` evaluates the rc files of a directory as
  soon as its content is fetched, prior trimming the element list for the
  *stop_mod* optimization: their ignore patterns and hiding rules are in
  place before any sibling element of this directory is analyzed or
  processed. Once evaluated and recorded in the result list, these rc
  files are withdrawn from the element list: only the rc files that are
  not part of a fetched directory content flow through the walked list and
  get evaluated and recorded by the walk loop (modulepath root rc file
  from the initial listing, limited access rc files walked directly from a
  cache file listing).
* The walk becomes depth-first: the content of a directory is inserted
  right after it in the walked list instead of being appended at its end.
  Module resolution and symbol definition results depend on the rc file
  evaluation order: a breadth-first walk would evaluate the rc files of
  all first-level directories before any deeper rc file, changing the
  resolution result when a rc file of one sub-tree sets a symbol like
  ``default`` on modules of another sub-tree. Root elements are walked in
  lexical order (sorted by ``findModules``) to keep a deterministic
  evaluation order for the rc files of first-level directories. Deeper
  sibling directories are walked in lexical order too, as element paths
  are sorted when inserted in the walked list.
* At the start of the walk, the ``.modulerc`` file at the root of the
  walked directory is evaluated if it exists and is readable, then every rc
  file already recorded in the result list transmitted to the walk
  procedure is evaluated in lexical order. This transmitted list is empty
  on a regular walk, but on cache use it holds the entries of the evaluated
  cache file: these rc files are not walked through, as they were readable
  when cache was built, but the patterns they may define apply to the walk
  down of the limited access elements. Containing this evaluation in
  ``findModulesFromDirsAndFiles`` keeps ``findModulesInCacheFile`` free of
  any rc evaluation logic.
* On a no-indepth search, ``.version`` files at a different depth level
  than the search target are currently neither recorded nor evaluated
  (unlike ``.modulerc`` files, which have no such restriction). This
  behavior is kept when evaluation moves to walk time, so no extra
  ``.version`` evaluation occurs. As a consequence, patterns defined in a
  ``.version`` file lying at a different depth level than a no-indepth
  search target are not applied on such a search: one more reason to prefer
  defining patterns in ``.modulerc`` files.

The ``g_rcfilesSourced`` tracking array still guards against evaluating the
same rc file twice. ``modulerc`` entries are still recorded in the result
list of ``findModules``: they are needed by the cache build process and to
transmit cache file entries to the walk procedure. As every rc file is now
evaluated by ``findModulesFromDirsAndFiles`` whether it comes from a
directory walk or from a cache file, the consolidation phase of
``getModules`` does not evaluate rc files anymore: it just withdraws the
``modulerc`` entries from the result list.

Side benefits of this change:

* rc files are now evaluated in walk order, which guarantees parent
  directory rc files are evaluated before deeper ones.
* ``trimElemListForStopmod`` does not need to source rc files anymore for
  the *stop_mod* search optimization: the hiding and ignore rules it needs
  are in place as rc files are evaluated prior its call.

Impact on module search
-----------------------

Every element found during the walk (file or directory) is matched against
the recorded pattern list. When an element is ignored:

* if it is a file, it is not tested for modulefile validity (no I/O on it)
  and not recorded in the search results
* if it is a directory, it is not walked down and not recorded

Ignored elements are therefore not reported by :subcmd:`avail`,
:subcmd:`spider`, :subcmd:`whatis` or any other listing sub-command. A
direct access to an ignored element (e.g., ``module load`` of it) leads to
the same *Unable to locate a modulefile* error as a nonexistent file. Same
result is obtained through the ``is-avail`` modulefile command.

As rc files located within an ignored directory are never reached, the
aliases, symbolic versions or virtual modules they may define do not exist
either.

The ``.modulerc`` and ``.version`` files of walked-through directories are
exempt from ignore matching: they are always evaluated, as they control the
walk itself (this also makes the ``modulepath-ignore * ...`` idiom work).
The rc files of ignored directories are naturally never evaluated.

Impact on module cache
----------------------

The cache build process (``formatModuleCacheContent``) relies on
``findModules`` to collect modulepath content: ignored elements are
excluded from its results, so no ``modulefile-content``,
``modulefile-invalid`` or directory-related entry is recorded for them in
the generated ``.modulecache`` file. This solves the initial problem of
issue #562: non-modulefiles matched by ignore patterns are neither read nor
recorded, whatever their number, and cache size stays proportional to the
number of actual modulefiles.

``getLimitedAccessesInDirectory`` performs its own walk of the modulepath
directory: it must also apply the ignore patterns so that ignored files or
directories with limited access rights are not recorded as
``limited-access-file`` or ``limited-access-directory`` entries. Patterns
are already known at this stage as this procedure is called after
``findModules`` in the cache build process.

The rc file exemption from pattern matching also applies to this walk: a
limited access rc file matching an ignore pattern (which happens with the
*ignore all, accept some* idiom, as ``*`` matches ``.modulerc`` itself) is
still recorded as a limited access entry. Without this exemption, such a
file would be skipped by this walk but still collected by the module
search walk, where rc files are exempt: its content would then get plainly
recorded in the cache file despite its restricted access.

No new cache file command is introduced and no existing command signature
changes: the minimal Modules version advertised in the cache file header is
unchanged.

When a cache file is used:

* ignored elements are simply absent from it, so search and direct access
  behaviors are consistent with the no-cache case
* limited access entries recorded in cache are re-walked through
  ``findModulesFromDirsAndFiles``: ignore patterns are applied on this walk
  too. The rc files recorded in cache are evaluated at the start of this
  walk (their content is obtained from the evaluated cache file), so the
  patterns they may define apply to the walked down limited access
  elements.

As ignored elements are excluded from the cache file at build time, the
ignore pattern definitions have to be static. If patterns are defined
dynamically (e.g., depending on user, group or environment), elements
ignored for the user building the cache are definitively absent from the
cache file, whatever the dynamic conditions evaluate to for the user of the
cache. This limitation must be clearly stated in the module documentation:
``modulepath-ignore`` definitions should not be conditional.

The same caution applies to global patterns defined in the user rc file:
they are honored when this user builds a cache file, so elements they match
are excluded from a cache file potentially shared with other users.

Disabling ignore patterns
-------------------------

A new boolean configuration option controls whether ``modulepath-ignore``
definitions are applied: ``modulepath_ignore``. It is enabled by default
and can be disabled through the ``MODULES_MODULEPATH_IGNORE`` environment
variable, the :subcmd:`config` sub-command or the ``--no-modulepath-ignore``
command-line switch for one execution.

A ``show_ignored`` option name associated with a ``--ignored`` switch (git
wording, as in ``git status --ignored``) was first considered then
rejected: disabling the mechanism does not *show* the ignored elements, it
just stops ignoring them, and they may still not appear anywhere if they
are not valid modulefiles in the end. The option is thus named after the
mechanism it enables or disables.

When this option is disabled, ``modulepath-ignore`` commands still evaluate
without error but the patterns they register are not applied: every element
of the modulepath directories is walked through and tested as if no pattern
were defined.

Disabling this option helps troubleshooting, for instance to determine
whether a modulefile is not found because it is ignored. Note that a cache
file built with patterns applied does not contain the ignored elements:
combining with the :option:`--ignore-cache` option is required to also
search elements excluded from cache file. Similarly, running
:subcmd:`cachebuild` with ``modulepath_ignore`` disabled records every
element in the cache file, as if the feature was not used.

Interaction with existing mechanisms
------------------------------------

* :mconfig:`ignored_dirs` configuration option: this option globally lists
  directory names to ignore (version control directories by default).
  ``modulepath-ignore`` complements it on a per-modulepath basis with a
  much finer pattern syntax. The ``ignored_dirs`` check is integrated in
  the matcher procedure, as an early test made prior applying patterns:
  the behavior of this option is preserved, as negated patterns cannot
  re-include a matching directory and directories keep being ignored when
  the ``modulepath_ignore`` option is disabled.
* Backup or version control files (``*~``, ``*,v``, ``#*#``): the walk
  procedures historically skipped these file names. This check is also
  integrated in the matcher procedure, with the same properties as the
  ``ignored_dirs`` one: negated patterns cannot re-include such files and
  they keep being ignored when the ``modulepath_ignore`` option is
  disabled.
* Dot files: files whose name starts with a dot are hidden but still tested
  and recorded in cache. Ignore patterns match dot files like any other
  file and provide a stronger exclusion (no test, no record).
* ``module-hide --hard``: hard-hidden modules also behave as nonexistent
  for users, but their modulefiles are still tested for validity and
  recorded in cache files, and hiding is applied at query filtering time.
  ``modulepath-ignore`` acts earlier, at walk time, with no I/O on ignored
  elements. ``modulepath-ignore`` is meant for content that is not
  modulefiles, ``module-hide`` for actual modulefiles to withhold.
* Virtual modules: a virtual module whose target file matches an ignore
  pattern is still resolved, as its target is directly read, not found
  through the modulepath walk.

Implementation notes
--------------------

* Patterns are compiled once, at definition time, into an ordered list of
  entries stored in a global structure (e.g.,
  ``::g_modulepathIgnorePatterns``), each entry holding: anchor directory
  (empty for global patterns, meaning the root of the walked modulepath),
  compiled regular expression, negation flag, directory-only flag.
* Translating a gitignore pattern into a Tcl regular expression handles the
  ``*``, ``?``, ``[...]``, ``**`` and anchoring rules. Tcl ``string match``
  is not sufficient (``*`` would match slashes, no ``**`` support).
* A matcher procedure (e.g., ``isPathIgnored modpath fpelt isdir``) applies
  the *last matching pattern decides* rule and is called from the element
  loop of ``findModulesFromDirsAndFiles`` and from the walk loop of
  ``getLimitedAccessesInDirectory``. The walked modulepath is passed to
  resolve the anchor of global patterns. The rc file exemption is
  implemented within this procedure and the procedure returns false
  straight away when the :mconfig:`modulepath_ignore` option is disabled.
* Matching is pure string processing: for modulepaths with a large amount
  of non-modulefiles it replaces one file read per element (magic cookie
  check) by one in-memory pattern match, which is where the performance
  gain of this feature comes from.
* Code must stay compatible with Tcl 8.5.

Impacted files
--------------

* ``tcl/mfcmd.tcl``: ``modulepath-ignore`` procedure and pattern
  compilation helper
* ``tcl/interp.tcl.in``: command alias registration in modulerc interpreter
* ``tcl/init.tcl.in`` and every file listed in
  ``doc/source/devel/add-new-config-option.rst`` (shell completion scripts,
  man pages, config testsuite): ``modulepath_ignore`` configuration option
  and its ``--no-modulepath-ignore`` command-line switch
* ``tcl/modfind.tcl.in``: ``isPathIgnored`` matcher procedure, rc file
  evaluation moved into ``findModulesFromDirsAndFiles``, ignore matching
  in walk loop, ``trimElemListForStopmod`` simplification
* ``tcl/cache.tcl.in``: ignore matching in ``getLimitedAccessesInDirectory``
  walk
* ``share/nagelfar/syntaxdb_modulerc.tcl``: new command for
  :subcmd:`lint` sub-command
* ``share/vim/syntax/modulefile.vim`` and
  ``share/emacs/lisp/modulefile-mode.el``: syntax highlighting
* ``doc/source/modulefile.rst``: command reference (including the static
  definition recommendation), ``doc/source/changes.rst`` and ``NEWS.rst``
* testsuite: dedicated testfiles for search and direct access behaviors
  (``modules.20-locate``), listing sub-commands (``modules.90-avail``,
  ``modules.92-spider``), cache build content and cache use
  (``modules.30-cache``), plus lint coverage of the new command

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
