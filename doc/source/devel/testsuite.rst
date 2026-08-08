.. _devel-testsuite:

Testsuite structure
===================

This document describes the non-regression testsuite of Modules: how it is
organized, how a test file and a test case are structured, how to run tests,
how to add new ones, and how to debug a failing test.

The testsuite is built on `DejaGnu <https://www.gnu.org/software/dejagnu/>`_,
a Tcl/Expect-based framework historically used to test compilers and command
line tools. DejaGnu groups test files (``.exp``, for *expect script*) under a
*tool*: a run of ``runtest --tool <name>`` sources every matching ``.exp``
file it finds for that tool and reports a ``PASS``/``FAIL``/``XFAIL``/
``UNRESOLVED`` line for each individual check performed. Modules defines
four tools, matched to four kinds of tests (see `Kinds of tests`_ below).

Kinds of tests
--------------

The testsuite exercises four different things, run as four separate
DejaGnu tools:

``modules``
    The main testsuite. Runs the built :file:`modulecmd.tcl` script (the
    Tcl-based engine behind the :command:`module` command) through every
    supported shell and checks the environment changes and messages it
    produces. This is by far the largest part of the testsuite (around
    25,000 test cases spread over the ``modules.*`` directories described
    below).

``install``
    Checks a real ``make install``-ed tree: that the :command:`module`
    function/command is correctly defined once shell init scripts are
    sourced, that the ``complete`` modulefile command emits the right
    shell-specific completion registration snippet, that ``modulecmd`` is
    invoked correctly from each shell's wrapper, etc. Driven by the
    :file:`install.00-init` directory.

``lint``
    Runs static analysis (Nagelfar for Tcl files, ShellCheck for sh/bash/ksh
    scripts) over the repository's own scripts and reports any warning as a
    test failure. Driven by the :file:`lint.00-init` directory.

``completion``
    Drives a real, interactive shell process (via Expect ``spawn``/``send``/
    ``expect``, not just a captured non-interactive run like the other three
    tools) to press Tab against the built shell completion script and check
    that the resulting candidate list holds the expected module names and
    option flags. Driven by the :file:`completion.00-init` directory;
    currently covers bash only, see `completion.00-init layout`_.

Each tool corresponds to one Makefile target (``test``, ``testinstall``,
``testlint``, ``testcompletion``, see `Running the testsuite`_) and to one
log file (:file:`modules.log`, :file:`install.log`, :file:`lint.log`,
:file:`completion.log`) produced in the top build directory.

Two additional run modes apply to the ``modules`` tool rather than adding a
new one:

- *Quick mode* (``QUICKTEST=y``) skips the slower/more exhaustive checks
  guarded by a call to ``skip_if_quick_mode`` (see `Base test procedures`_)
  to get a fast (~1,900 cases, ~1 min) smoke test.
- *Coverage mode* (``COVERAGE=y``) runs the exact same tests but through a
  Nagelfar-instrumented ``modulecmd.tcl``, then produces marked-up
  :file:`tcl/*.tcl_m` files where lines never hit during the run are flagged
  with ``;# Not covered``.

Directory layout
----------------

Everything lives under :file:`testsuite/`.

Test file directories
~~~~~~~~~~~~~~~~~~~~~

Test files are grouped in numbered directories named
``<tool>.<serienum>-<topic>``, e.g. :file:`modules.50-cmds`,
:file:`install.00-init`, :file:`lint.00-init`, :file:`completion.00-init`.
The ``<tool>`` prefix ties the directory to one of the four DejaGnu tools
above (DejaGnu only looks at directories whose prefix matches the ``--tool``
given to ``runtest``); the two-digit ``<serienum>`` number fixes run order
and is what you pass to :file:`script/mt` to select a whole directory (e.g.
``script/mt 50``); the ``<topic>`` suffix is just a human-readable label.

Current ``modules.*`` series, in run order:

``00-init``
    Testsuite bootstrap, plus a handful of standalone option/behavior
    checks. Two files in this series matter beyond their own file number
    because every other series relies on what they set up:

    - ``005-init_ts.exp`` defines the global variables and procedures
      shared by every test file for the whole run (paths, shell lists,
      common error/message strings, helper procs such as
      ``cmpversion``). It runs first, before anything else.
    - ``010-environ.exp`` defines the *initial user environment* every
      test starts from: it clears/resets ``MODULEPATH``,
      ``LOADEDMODULES``, and any quarantine/auto-handling/color/...
      configuration coming from the calling shell. The same file (by
      role, not by sharing code) also exists as
      :file:`install.00-init/010-environ.exp` and plays the identical
      part for the ``install`` tool.

    The rest of the series defines the ``_test_sub`` procedure that runs
    ``modulecmd.tcl`` (``006-procs.exp``, tool-specific -- see `Running
    the command and checking the result`_), builds further shared
    fixtures (module search path, module cache pre-build,
    ``save_test_env`` checkpoint), and tests standalone command-line
    switches and configuration behavior (pager, quarantine, siteconfig,
    auto handling, color, access rights, multilib, cwd, logger, Tcl
    extension library).
``10-use``
    ``module use``/``unuse``
``20-locate``
    Module lookup/resolution (exact version, default, wildcard,
    symbolic version, ...)
``30-cache``
    Module cache file handling
``50-cmds``
    Modulefile commands (``setenv``, ``prepend-path``, ``conflict``,
    ``variant``, ...) -- by far the biggest series
``51-scan``
    Modulefile scan / extra-match search
``60-initx``
    The ``init*`` sub-commands (``initadd``, ``initprepend``, ``initrm``,
    ``initswitch``, ``initlist``, ``initclear``) that edit a user's shell
    startup file
``61-coll``
    Module collections
``70-maint``
    Maintenance sub-commands (``load``, ``switch``, ``purge``, config,
    ...)
``80-deep``
    "Deep" modules, i.e. modules whose name has more than one directory
    level (``name/sub/version``): load/unload/switch, listing, ``whatis``,
    alias/symbolic-version resolution, access rights
``90-avail``
    ``avail`` sub-command
``91-sort``
    Module sorting order
``92-spider``
    ``spider`` sub-command
``95-version``
    Version comparison/parsing
``99-finish``
    Testsuite teardown (removes cache files created for the run)

``install.00-init``, ``lint.00-init`` and ``completion.00-init`` are each a
single series (those tools are much smaller and don't need topic splitting).

Every series directory ends with a ``999-cleanup.exp`` file (see `Test file
anatomy`_) and, for the ``modules`` tool, most series begin with a
``0NN-init_ts.exp`` file that sets up whatever fixtures that series' tests
need (e.g. :file:`modules.90-avail/010-init_ts.exp`).

``completion.00-init`` layout
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``completion`` tool follows the common ``005``/``006``/``010``/``011``
setup numbering (see `Test file anatomy`_ and `Base test procedures`_ below)
plus one extra layer, since driving real Tab-key completion is inherently
shell-specific in a way none of the other three tools are:

- ``005-init_ts.exp`` / ``006-procs.exp`` / ``010-environ.exp`` /
  ``011-save_test_env.exp`` set up paths (the ``bash`` binary, the built
  :file:`init/bash_completion` script, a clean fixture modulepath), the
  shell-agnostic assert procedures (``completion_assert_contains``,
  ``completion_assert_not_contains``, ``completion_assert_eq``), and the
  clean baseline environment/``save_test_env`` checkpoint, exactly as for
  the other tools.
- ``0NN-<shell>-procs.exp`` defines one ``completion_<shell>_start`` /
  ``completion_<shell>_raw`` / ``completion_<shell>_list`` /
  ``completion_<shell>_inline`` / ``completion_<shell>_close`` set per
  shell -- e.g. ``020-bash-procs.exp`` spawns a real ``bash`` pty, sources
  :file:`init/bash_completion`, and drives double-Tab listings
  (``completion_bash_list``, for an ambiguous prefix) or single-Tab inline
  completions (``completion_bash_inline``, for a prefix with exactly one
  match -- e.g. checking a directory-style entry completes with a
  trailing ``/`` and no trailing space) through Expect.
  ``completion_<shell>_list``/``_inline`` are responsible for recording the
  cmdline they were passed into the shared ``completion_last_cmdline``
  variable, which the generic assert procedures use to build their test
  label.
- ``0NN-<shell>.exp`` (e.g. ``021-bash.exp``) holds the actual test cases
  for that shell, calling only its own ``completion_<shell>_*`` procs plus
  the shared asserts.

Adding a new shell means adding its own ``completion_<shell>_*`` procs file
and test file; nothing in ``006-procs.exp`` needs to change.

Fixture and support directories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- :file:`modulefiles/`, :file:`modulefiles.2/`, :file:`modulefiles.3/`,
  :file:`modulefiles.4/`, and a number of single-purpose
  :file:`modulefiles.<name>/` directories (``.deep``, ``.deps``, ``.eb``,
  ``.spider1``/``.spider2``/``.spider3``, ``.rc``, ``.path1``/``.path2``/
  ``.path3``, ``.memcache``, ``.indepth``, ``.allin``) hold the modulefiles
  used as fixtures. See `Adding new test fixtures`_ below for which one to
  add to.
- :file:`config/` holds the DejaGnu/Expect configuration shared by every
  ``.exp`` file: :file:`base-config.exp` (all the test procedures, see
  `Base test procedures`_) and :file:`unix.exp` (the low-level plumbing
  that spawns ``modulecmd.tcl`` and captures its stdout/stderr/exit code).
- :file:`etc/`, :file:`home/`, :file:`home.2/`-:file:`home.4/` provide
  sandboxed ``$MODULESHOME``-like/``$HOME``-like trees (rc files,
  collections, ...) used as fixtures.
- :file:`bin/` contains small stand-in executables used by tests (fake
  tools invoked by modulefiles or by shell code under test).
- Miscellaneous single-purpose helper scripts at the top level:
  :file:`is_func_defined` / :file:`is_func_defined.fish` (check whether
  ``module``/``mogui`` is defined as a shell function before running the
  ``install`` tests), :file:`stdin_to_file`, :file:`stty`, :file:`mode`,
  :file:`not_installed`, :file:`systest`/:file:`systest0-2`, :file:`id`,
  :file:`cmd.exe`, :file:`manpath`, :file:`virttargets/`.
- :file:`mb/` holds fixtures for the :file:`script/mb` benchmark tool, not
  for DejaGnu tests.

Test file anatomy
-----------------

Every ``.exp`` file follows the same three-part shape: a header comment
block, the test content, and (for most files, though not the ``00-init``
setup files) a cleanup footer.

Header
~~~~~~

A fixed-format comment block, kept for historical (SCCS/CVS-style keyword
expansion) reasons and consistency rather than for tooling:

.. code-block:: tcl

    ##############################################################################
    #   Modules Revision 3.0
    #   Providing a flexible user environment
    #
    #   File:           modules.50-cmds/%M%
    #   Revision:        %I%
    #   First Edition:   2021/03/04
    #   Last Mod.:       %U%, %G%
    #
    #   Authors:         Your Name, your.email@example.com
    #
    #   Description:     Testuite testsequence
    #   Command:         load, display, help, test
    #   Modulefiles:     variant
    #   Sub-Command:
    #
    #   Comment:   %C{
    #           Test 'variant' modulefile command
    #       }C%
    #
    ##############################################################################

When adding a file, copy this header from a neighboring file in the same
directory, update ``First Edition`` to the current date, your name/email in
``Authors`` if you want authorship credit, and fill in ``Command:``/
``Modulefiles:``/``Sub-Command:`` and the free-text ``Comment:`` block to
describe what the file tests. The ``%M%``/``%I%``/``%U%``/``%G%`` tokens are
left as-is (they are not expanded by anything in this codebase but are kept
for consistency with the historical format).

Content
~~~~~~~

The body of the file is plain Tcl/Expect code, structured as:

1. Optional per-file setup: pick/point to a modulepath (e.g.
   ``set mp $modpath.3``), set environment variables relevant to the
   scenario (``setenv_var``/``setenv_path_var``), maybe call
   ``skip_if_quick_mode`` or ``skip_if_os_in`` right after the setup that
   only the skipped tests need.
2. One or more test cases: each is one call to a ``test*_cmd*`` procedure
   from :file:`config/base-config.exp` (see `Base test procedures`_),
   grouped under a short ``#\n# <description>\n#`` comment banner when the
   file covers more than one scenario.
3. A ``#\n#  Cleanup\n#`` banner followed by a call to ``reset_test_env``
   (see below), for any file that changed environment variables or Tcl
   globals the following files shouldn't see.

Footer
~~~~~~

Files that mutate shared state end with:

.. code-block:: tcl

    #
    #  Cleanup
    #

    reset_test_env

``reset_test_env`` restores every Tcl global variable and environment
variable to the value it had when ``save_test_env`` last ran (this checkpoint
is taken once per tool, early in the ``00-init`` series, right after the
common fixtures -- modulepath, cache, etc. -- are set up; see
:file:`modules.00-init/085-save_test_env.exp`). This is what makes test files
independent of run order within reasonable bounds: a file can freely
``setenv_var``, build a collection, flip a config option, etc., and the next
file starts clean.

A handful of files close with a Vim modeline instead (or in addition):

.. code-block:: tcl

    # vim:set tabstop=3 shiftwidth=3 expandtab autoindent:

How a test case is built
------------------------

A test case has two ingredients: the environment/fixtures it runs against
(set up with plain Tcl and the ``setenv_*``/``unsetenv_*`` helpers), and one
call to a ``test*_cmd*`` procedure that runs a :command:`module` command line
and checks its outcome.

Setting up environment
~~~~~~~~~~~~~~~~~~~~~~

- ``setenv_var var val`` / ``unsetenv_var var`` -- set/unset a plain
  environment variable for the *modulecmd.tcl* child process about to be
  spawned.
- ``setenv_path_var var elt1 elt2 ...`` / ``unsetenv_path_var var`` -- same,
  for a colon-delimited path-like variable; also transparently maintains the
  matching ``__MODULES_SHARE_<var>`` reference-count variable.
- ``setenv_loaded_module modlist modfilelist`` /
  ``unsetenv_loaded_module`` -- set up ``LOADEDMODULES``/``_LMFILES_`` (and
  ``__MODULES_LMTAG`` for auto-loaded modules) to simulate modules already
  loaded prior to the command under test.
- ``skip_if_quick_mode`` -- bail out of the rest of the *current file* when
  ``QUICKTEST=y``. Used to skip expensive/exhaustive variations while
  keeping at least one representative case running in quick mode.
- ``skip_if_os_in os1 os2 ...`` -- bail out of the rest of the current file
  on the given OS names (``$::os_name``, e.g. ``windows``, ``darwin``).
- ``change_file_perms``/``restore_file_perms`` -- temporarily lock down a
  file/directory's permissions to test permission-denied paths.

Running the command and checking the result
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Every ``test*_cmd*`` procedure runs ``modulecmd <shell> <cmd>`` through
``_test_sub`` and compares the captured stdout/stderr/exit code against
what was passed in, reporting ``pass``/``fail`` to DejaGnu. ``_test_sub``
itself is tool-specific: each tool defines its own version in its
``00-init`` series' ``006-procs.exp`` file (e.g.
:file:`modules.00-init/006-procs.exp`), which for the ``modules`` tool
calls down into ``modulecmd_xxx_`` (defined in :file:`config/unix.exp`) to
actually spawn ``modulecmd.tcl`` and capture its output.

See `Base test procedures`_ for the full family of these procedures and how
their ``answer``/``anserr`` arguments are interpreted (plain string, a
"shell out list", or the ``OK``/``ERR``/``ERR2`` shorthands).

Base test procedures
--------------------

All of the below live in :file:`testsuite/config/base-config.exp`
(``shell_*`` internal helpers, used by the procedures below to translate a
symbolic environment change into the actual syntax of each of the 15+
supported shells, are not covered here).

Environment/output description helpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

``shell_out test_shell out_list`` builds the shell-specific expected output
for a *list* of symbolic environment changes -- this is what most test cases
pass as their ``answer``/``anserr`` argument instead of a literal string.
Each element of ``out_list`` is itself a small list starting with one of:

``set``
    ``{set var val}`` -- variable assignment (pass ``noescval`` as a
    4th element to skip shell escaping)
``setpath``
    ``{setpath var val}`` -- like ``set``, but also auto-generates the
    matching ``__MODULES_SHARE_<var>`` reference-count assignment
``unset``
    ``{unset var}`` -- variable unset
``unsetpath``
    ``{unsetpath var}`` -- like ``unset``, plus reference count
``alias``
    ``{alias var val}`` -- shell alias definition
``unalias``
    ``{unalias var}`` -- shell alias removal
``chdir``
    ``{chdir dir}`` -- directory change
``xres``
    ``{xres var val}`` -- X11 resource set (``xrdb``)
``unxres``
    ``{unxres var}`` -- X11 resource removal
``text``
    ``{text str}`` -- arbitrary literal text (module messages,
    warnings, ...), inserted as-is
``OK``, ``ERR``, ``ERR2``
    shell-specific success / 1-error / 2-error status code
``out``, or anything else
    literal text joined as-is

``is_shell_out_list answer`` tells whether ``answer`` looks like one of
these lists (used internally by ``_test_out``/``_test_out_re`` to decide
whether to run it through ``shell_out`` or treat it as a literal string).

Test procedures (the ones test files actually call)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All of them share the same first two arguments, ``test_shell`` (a shell
name, or ``ALL`` to run the same check against every shell in
``$supported_shells``) and ``cmd`` (the :command:`module` command line,
without the leading ``module`` word), plus a trailing optional
``failcmd`` (defaults to ``fail``; some tests in the deep-reload/args series
pass ``untested`` or ``unresolved`` here) and ``launcher`` (to prefix the
call, e.g. with ``sudo``).

``testouterr_cmd`` is the preferred procedure for a new test case: it
checks both stdout and stderr, so a message unexpectedly landing on the
wrong stream does not go unnoticed, and it is by far the most used
procedure in the existing testsuite. Reach for one of the others only when
its extra check (exit code, regexp matching, file content, ...) or its
narrower scope (single-stream only) is actually needed.

``test_cmd test_shell cmd answer {exitval 0} {failcmd fail} {launcher {}}``
    Checks stdout (exact) and the exit code (default expected: ``0``).
``test_cmd_re test_shell cmd answer {failcmd fail} {launcher {}}``
    Checks stdout (regexp).
``testerr_cmd test_shell cmd answer {failcmd fail} {launcher {}}``
    Checks stderr (exact).
``testerr_cmd_re test_shell cmd answer {force_nl 0} {failcmd fail} {launcher {}}``
    Checks stderr (regexp). ``force_nl`` forces a trailing newline to be
    appended to ``answer`` before it is used as a regexp, for the cases
    where that can't be inferred automatically.
``testouterr_cmd test_shell cmd answer anserr {failcmd fail} {launcher {}}``
    Checks stdout (exact, ``answer``) and stderr (exact, ``anserr``).
    **Preferred procedure, see above.**
``testouterr_cmd_re test_shell cmd answer anserr {force_nl 0} {failcmd fail} {launcher {}}``
    Checks stdout (regexp, ``answer``) and stderr (regexp, ``anserr``).
``testouterr_cmd_re_sort test_shell cmd answer anserr {failcmd fail} {launcher {}}``
    Checks stdout (regexp) and stderr (regexp), both sides line-sorted
    first -- for output whose line order is not guaranteed.
``testall_cmd test_shell cmd answer anserr exitval {failcmd fail} {launcher {}}``
    Checks stdout (exact), stderr (exact) and the exit code.
``testall_cmd_re test_shell cmd answer anserr exitval {force_nl 0} {failcmd fail} {launcher {}}``
    Checks stdout (regexp), stderr (regexp) and the exit code.
``testinouterr_cmd test_shell cmd input answer anserr {failcmd fail} {launcher {}}``
    Like ``testouterr_cmd`` but also feeds ``input`` on stdin.
``testoutfile_cmd test_shell cmd answer filepath ansfile {failcmd fail} {launcher {}}``
    Checks stdout (exact, ``answer``) and the content of ``filepath`` on
    disk (exact, ``ansfile``).
``testouterrfile_cmd test_shell cmd answer anserr filepath ansfile {failcmd fail} {launcher {}}``
    Checks stdout (exact), stderr (exact) and the content of ``filepath``
    on disk (exact, ``ansfile``).
``testouterrfileglob_cmd test_shell cmd answer anserr fileglob ansfile {failcmd fail} {launcher {}}``
    Like ``testouterrfile_cmd``, but the file to check is resolved from
    the ``fileglob`` glob pattern (last match once sorted).
``testouterrgloblist_cmd test_shell cmd answer anserr fileglob ansglob {failcmd fail} {launcher {}}``
    Checks stdout (exact), stderr (exact) and the *sorted list* of files
    matching the ``fileglob`` glob pattern (against ``ansglob``).

For the ``ERR``/``ERR2``/``OK`` shorthands accepted as ``answer``/``anserr``:
``OK`` means "no output expected", ``ERR``/``ERR2`` expand to the
shell-specific representation of exit status 1/2 (via ``shell_err``).

Environment save/restore and mode helpers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- ``save_test_env`` / ``reset_test_env`` -- see `Footer`_ above.
- ``is_quick_mode`` / ``skip_if_quick_mode`` -- see `Setting up
  environment`_ above.
- ``skip_if_os_in`` -- see `Setting up environment`_ above.

A worked example
----------------

The following two examples put together everything from `How a test case is
built`_ and `Base test procedures`_ into concrete, runnable test cases: one
where the load is rejected, one where it succeeds.

Example 1: a rejected load (conflict)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a trimmed-down version of one of the checks in
:file:`modules.50-cmds/131-conflict-module.exp`: loading a module while a
conflicting one is already loaded, with automatic conflict-unload disabled
(the project's default), must fail with an explanatory error.

The scenario relies on two existing fixture modulefiles: ``trace/all_on``
and ``conflict/module`` (:file:`testsuite/modulefiles/conflict/module`),
whose ``.modulerc``-less content simply declares ``conflict trace``.

.. code-block:: tcl

    # environment setup
    #
    # MODULEPATH already points to $modpath (the default fixture directory,
    # testsuite/modulefiles) -- that is set up once for the whole run by
    # modules.00-init/050-modpath.exp, so there is nothing to do here unless
    # a test needs a different modulepath. Simulate that 'trace/all_on' is
    # already loaded, without actually running a 'load' command for it:
    setenv_loaded_module trace/all_on $modpath/trace/all_on

    # build the expected stdout ($ans)
    #
    # the conflict is detected before any environment change is made, so
    # the load is rejected outright: stdout only carries the shell's
    # failing exit status, i.e. the 'ERR' shorthand (see `Base test
    # procedures`_)
    set ans ERR

    # build the expected stderr ($tserr)
    #
    # 'module load' always echoes a "Loading <mod>" banner first; the
    # msg_load and err_conflict helpers (defined in
    # modules.00-init/005-init_ts.exp) build that banner and the
    # conflict/hint message actually printed by modulecmd.tcl
    set tserr [msg_load conflict/module [err_conflict trace/all_on]]

    # test launch
    #
    # run 'module load conflict/module' for every supported shell and check
    # its stdout against $ans and its stderr against $tserr
    testouterr_cmd ALL "load conflict/module" $ans $tserr

Running this (e.g. pasted at the end of an existing test file, or as its own
numbered ``.exp`` file, see `Test file anatomy`_) exercises the real
:command:`module load` code path for every supported shell and would report
one ``PASS``/``FAIL`` per shell. For reference, this is what
``modulecmd.tcl`` itself prints for the ``sh`` shell in this exact scenario::

    $ MODULEPATH=.../modulefiles LOADEDMODULES=trace/all_on \
      _LMFILES_=.../modulefiles/trace/all_on \
      modulecmd.tcl sh load conflict/module
    Loading conflict/module
      ERROR: Module cannot be loaded due to a conflict.
        HINT: Might try "module unload trace/all_on" first.
    test 0 = 1;

The last line (``test 0 = 1;``) is the ``sh``-specific encoding of a failing
exit status -- exactly what ``ERR`` expands to via ``shell_err`` (see
`Base test procedures`_) -- and everything above it on stderr is what
``$tserr`` was built to match.

Example 2: a successful load, from ``$modpath.4``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This second example contrasts with the first one: a plain, successful load,
with the environment changes it produces checked on stdout and nothing
expected on stderr. It also illustrates pointing the modulepath at
:file:`testsuite/modulefiles.4` (``$modpath.4`` in Tcl, see `Adding new test
fixtures`_) instead of using the default fixture directory, as a new test
case exercising a fixture added there would, and running the check against a
single named shell (``bash``) rather than ``ALL`` -- appropriate when a test
is not about shell-syntax differences and does not need to be repeated for
every supported shell.

The fixture used is :file:`testsuite/modulefiles.4/setenv/1.0`, whose
content is simply::

    #%Module
    setenv TS1 {}
    setenv TS2 $env(TS1)

.. code-block:: tcl

    # environment setup
    #
    # point the modulepath at modulefiles.4 instead of the default fixture
    # directory
    setenv_path_var MODULEPATH $modpath.4

    # build the expected stdout ($ans)
    #
    # 'setenv/1.0' sets TS1 to an empty string then TS2 to the (now empty)
    # value of TS1; 'load' also always sets _LMFILES_ and LOADEDMODULES --
    # each element uses the 'set' tag from the shell_out vocabulary (see
    # `Base test procedures`_) so the answer is rendered in bash syntax
    set ans [list]
    lappend ans [list set TS1 {}]
    lappend ans [list set TS2 {}]
    lappend ans [list set _LMFILES_ $modpath.4/setenv/1.0]
    lappend ans [list set LOADEDMODULES setenv/1.0]

    # test launch
    #
    # run against bash only; a plain successful load prints nothing on
    # stderr, hence the empty string passed as the expected anserr
    testouterr_cmd bash "load setenv/1.0" $ans {}

Running the testsuite
---------------------

With ``make``
~~~~~~~~~~~~~

.. code-block:: sh

    make test                  # full 'modules' suite via DejaGnu (~25,000 cases, ~12 min)
    make test QUICKTEST=y      # quick mode, most essential tests (~1,900 cases, ~1 min)
    make test COVERAGE=y       # coverage-instrumented run, produces tcl/*.tcl_m
    make testinstall           # 'install' suite against a tree already processed by 'make install'
    make testlint              # 'lint' suite (Nagelfar + ShellCheck)
    make testcompletion        # 'completion' suite (interactive Tab-completion tests)

Each target ends up calling ``runtest --tool <tool> $(RUNTESTFLAGS)
$(RUNTESTFILES)``: ``RUNTESTFILES``, if set, restricts the run to specific
``.exp`` file *names* (not paths -- DejaGnu matches by basename across every
directory of the active tool); ``RUNTESTFLAGS`` controls DejaGnu verbosity
(``-v`` can be repeated; at ``-v -v`` the test procedures in
:file:`base-config.exp` additionally dump the raw captured
``OUT[len]: '...'#>``/``ERR[len]: '...'#>``/``EXIT: '...'#>`` for every
check, matched vs expected).

With :file:`script/mt`
~~~~~~~~~~~~~~~~~~~~~~

:file:`script/mt` is a thin wrapper around the ``make`` targets above that
adds live progress reporting and a readable diff on failure. Prefer it over
calling ``make test`` directly when iterating on a specific area.

.. code-block:: sh

    script/mt                     # same as: make test
    script/mt quick               # same as: make test QUICKTEST=y
    script/mt cov                 # same as: make test COVERAGE=y
    script/mt install             # same as: make testinstall
    script/mt lint                # same as: make testlint
    script/mt comp                # same as: make testcompletion

    script/mt 50/470              # only testsuite/modules.50-cmds/470-*.exp
    script/mt 50                  # every file in testsuite/modules.50-cmds
    script/mt 61                  # collection series (always run whole, see below)
    script/mt lint 00/030         # only testsuite/lint.00-init/030-*.exp
    script/mt comp 00/021         # only testsuite/completion.00-init/021-*.exp
    script/mt 50/{280,290} 61     # several selections at once
    script/mt --help              # full usage

Whichever files are selected, :file:`script/mt` always also runs the
mandatory setup files for that tool (for ``modules``:
``00/005 00/006 00/010 00/050 00/060 00/080 00/085``; for ``install``:
``00/005 00/006 00/010 00/011``; for ``lint``: ``00/005 00/006 00/011``; for
``completion``: ``00/005 00/006 00/007 00/010 00/011 00/020``), plus the
``999-cleanup.exp`` of every selected series. Passing a bare series
number always expands to every file in that directory, because several of
those series are order-sensitive or enumerate a whole modulepath (see
`Adding new test fixtures`_). The collection series (``61``) is one such
case: its files create real collection files on disk that later files in
the same series depend on -- e.g. :file:`modules.61-coll/040-restore.exp`
restores collections that :file:`modules.61-coll/030-save.exp` produced --
so running only a subset of that series would fail for reasons unrelated to
the actual test.

While running, :file:`script/mt` tails the produced log and prints a running
``pass``/``fail``/``xfail``/``error`` tally, plus a per-testcase breakdown
whenever a case other than all-pass completes. When done, it invokes
:file:`script/mtreview` on the log, which pulls out every
``OUT[..]``/``ERR[..]`` vs ``EXP[..]`` pair recorded by the ``-v -v``-level
test procedures and renders them as a diff (using ``icdiff`` if available --
:file:`script/mt` auto-downloads it once and caches it as ``./icdiff`` --
falling back to ``diff -u``).

Coverage
~~~~~~~~

.. code-block:: sh

    make test COVERAGE=y             # instruments modulecmd.tcl with Nagelfar,
                                     # then runs the full suite and produces
                                     # tcl/*.tcl_m
    script/mt cov 70/{280,290}       # coverage run limited to specific test
                                     # files

Inspect the resulting :file:`tcl/*.tcl_m` files for lines flagged
``;# Not covered`` to see what a newly added feature/branch still needs test
coverage for.

Adding new tests
----------------

Adding a new test case to an existing area
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add a ``test*_cmd*`` call (or a whole new numbered ``.exp`` file, following
`Test file anatomy`_) to the relevant ``<tool>.<serienum>-<topic>`` directory.
Pick the file/series whose topic matches, or create a new file with the next
free number in that series if the scenario doesn't fit an existing file. Run
the file in isolation first (``script/mt <serienum>/<num>``) before running the
full suite.

Adding new test fixtures
~~~~~~~~~~~~~~~~~~~~~~~~

Add new fixture modulefiles under the *highest-numbered*
:file:`testsuite/modulefiles.N` directory (check whether a higher one than
:file:`modulefiles.4` already exists before assuming it's the latest), not
under the default :file:`modulefiles/` directory. Several existing tests
(``aliases``, ``avail``, ``spider``, ``scan_eval``, and others) enumerate a
modulepath's *entire* content and assert on the full listing; adding fixtures
to a directory shared that broadly changes their expected output. Even a
numbered directory like :file:`modulefiles.4` is referenced wholesale by
some tests and by filesystem-glob-order-dependent debug-trace assertions
elsewhere in the suite, so:

1. Add the new modulefile(s) under the latest :file:`modulefiles.N`.
2. Run the *full* testsuite (or at least the ``90-avail``/``92-spider``
   series plus anything else touching that modulepath), not just the new
   test file, to catch any global-enumeration test whose expected output
   now needs updating.
3. Update the expected output of any such test the new fixture broke.

If a fixture needs a filename ending in a space, it cannot be checked into
git as a real file (checkout fails on Windows); instead generate it on the
fly from Tcl, following the pattern in
``create_endspace_test_modulefiles``/``delete_endspace_test_modulefiles`` in
:file:`config/base-config.exp`.

Adding a new sub-command or config option
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Don't improvise which testsuite files need touching for these two specific
tasks -- :doc:`add-new-sub-command` and :doc:`add-new-config-option` each
enumerate the exact list, in the "Testsuite" section of each document.

Debugging a broken test
-----------------------

1. **Reproduce narrowly.** Re-run just the failing file with
   :file:`script/mt`, e.g. ``script/mt 50/470``. This also runs the tool's
   mandatory setup files, so the environment matches a full run.
2. **Read the diff.** :file:`script/mt` runs :file:`script/mtreview` on the
   resulting log automatically and prints an ``EXP``-vs-``OUT``/``ERR`` diff
   for every failing case -- start there instead of reading the raw log.
3. **Raise verbosity.** For more detail than the diff gives (e.g. to see
   *which* command line in a file produced a given failure, or to see
   ``send_user`` progress messages emitted by ``config/base-config.exp``
   helpers like ``setenv_var``/``change_file_perms``), set
   ``RUNTESTFLAGS='-v -v'`` and call ``make test``/``testinstall``/
   ``testlint``/``testcompletion`` directly, or invoke ``runtest`` yourself
   with the environment variables :file:`script/mt`/the Makefile targets set
   up (``TCLSH``, ``MODULECMD``, ``OBJDIR``, ``TESTSUITEDIR``) -- see the
   ``test``/``testinstall``/``testlint``/``testcompletion`` targets in
   :file:`Makefile` for the exact invocation.
4. **Check for order dependence.** If a test passes alone but fails in a
   full run (or vice-versa), suspect a missing/incomplete ``reset_test_env``
   footer in an earlier file, or a global-enumeration test (`Adding new test
   fixtures`_) whose expected output a fixture change invalidated.
5. **Suspect the module cache.** If ``TESTSUITE_ENABLE_MODULECACHE`` is set
   in the environment and a test's behavior seems to depend on whether the
   modulepath is cached, check whether the file calls
   ``ignore_modulecache_if_built``/``end_ignore_modulecache_if_built``
   around the section that shouldn't read a pre-built cache.
6. **Nagelfar/ShellCheck failures (``lint`` tool)** report the offending
   file and line directly in the diff; fix the flagged code or, if it's a
   deliberate/false-positive pattern, look at how neighboring
   :file:`lint.00-init/0NN-*.exp` files configure linter exclusions (e.g.
   the ``-e SC1090`` ShellCheck exclusion in
   :file:`lint.00-init/020-sh.exp`) before adding a new one.
7. **``completion`` tool hangs/timeouts.** A run that hangs (rather than
   fails) almost always means an ``expect`` pattern in a
   ``completion_<shell>_*`` proc never matched, so it burned the default
   timeout before falling through -- three recurring causes when scripting
   readline-based completion: sending only a double-Tab against a prefix
   that still has an unconsumed common-prefix extension (readline
   auto-inserts it on the first Tab, so the listing needs a *third* Tab --
   type the full common prefix yourself instead, see the ``module load ba``
   case in
   :file:`completion.00-init/021-bash.exp`); clearing an input line and then
   matching on the prompt text reappearing (readline redraws a cleared line
   with cursor-movement escapes, not by reprinting the prompt -- submit the
   now-empty line instead, see ``completion_bash_list`` in
   :file:`completion.00-init/020-bash-procs.exp`); and an interactive pager
   (``less``) kicking in on an unexpected warning and blocking for a
   keypress that never comes (set ``MODULES_PAGER=cat``, see
   :file:`completion.00-init/010-environ.exp`).
8. **Coverage regressions.** If a change is meant to add coverage for a new
   branch, confirm it with ``make test COVERAGE=y`` (or
   ``script/mt cov <serienum>/<num>``) and check the relevant :file:`tcl/*.tcl_m`
   file no longer flags that line ``;# Not covered``.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
