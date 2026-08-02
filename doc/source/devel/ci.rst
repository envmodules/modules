.. _devel-ci:

Continuous integration
=======================

This document describes the continuous integration (CI) set up for Modules:
what each workflow tests, when it runs, and how to work with the coverage
and dependency-update tooling that goes along with it.

All CI is implemented as `GitHub Actions
<https://docs.github.com/en/actions>`_ workflows, defined under
:file:`.github/workflows/`. Every workflow that builds and tests Modules
follows the same overall shape: install system packages for the target
platform, ``./configure`` with a job-specific option combination, ``make``,
run the testsuite (see :doc:`testsuite`), ``make install``, re-run the
testsuite against the installed tree, then ``make uninstall``.

Overview
--------

``linux_tests.yaml``
    Build/testsuite across Tcl versions, ``configure`` option
    combinations and Linux distributions. Runs on push, pull request.
``macos_tests.yaml``
    Build/testsuite on macOS. Runs on push, pull request.
``windows_tests.yaml``
    Build/testsuite on native Windows, Cygwin and MSYS2. Runs on push,
    pull request.
``lint_tests.yaml``
    Static analysis (Nagelfar, ShellCheck). Runs on push, pull request.
``differential_shellcheck.yml``
    ShellCheck diff annotations on the changed lines only. Runs on pull
    request (to ``main``).
``easybuild_tests.yaml``
    Downstream integration: EasyBuild framework test suite against
    Modules. Runs on push, pull request.
``scorecard.yml``
    `OSSF Scorecard`_ supply-chain security analysis. Runs on push (to
    ``main``), weekly, manual.
``cflite.yml``
    `ClusterFuzzLite`_ fuzzing of the optional C helper library
    (:file:`lib/`): a short pass on pull requests touching :file:`lib/`
    or :file:`.clusterfuzzlite/`, and a longer batch pass bi-weekly/manual.

All of the above live under :file:`.github/workflows/`.

.. _OSSF Scorecard: https://github.com/ossf/scorecard
.. _ClusterFuzzLite: https://google.github.io/clusterfuzzlite/

Every build/test workflow (all except :file:`differential_shellcheck.yml`,
:file:`scorecard.yml` and :file:`cflite.yml`) triggers on ``push`` to any
branch except ``c-main`` and ``c-3.2`` (legacy imported-history branches
that are not active development targets) and on every ``pull_request``.

Build/test workflows
---------------------

Linux (:file:`linux_tests.yaml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The largest and most detailed workflow, made of one job per Tcl
version/environment combination:

``tcl86-nolibtclenvmodules``, ``tcl85-nolibtclenvmodules``
    Tcl 8.6 and Tcl 8.5 (the latter built from source) with the optional C
    helper library (see ``lib/`` in the repository layout) disabled via
    ``--disable-libtclenvmodules``.
``tcl85-2``, ``tcl86``, ``tcl85``, ``tcl91``, ``tcl90``
    Further Tcl 8.5/8.6/9.0/9.1 combinations (Tcl 9.0/9.1 built from
    source), each passing a different, deliberately varied set of
    ``./configure`` options (pager, color, versioning, quarantine,
    icase, domain name detection, multilib, siteconfig, locked configs,
    ...). Spreading option coverage across jobs this way, rather than
    repeating the same ``configure`` line everywhere, is what exercises
    the option surface described in :doc:`add-new-config-option`; when
    adding a new option, consider whether an existing job's option set is
    the natural place to add it. ``tcl91`` additionally checks out the
    repository into a working directory whose name contains ``+`` and
    other shell-special characters, to catch path-quoting regressions.
``el8``, ``el9``
    Full build, test, install and RPM/SRPM packaging inside
    ``rockylinux:8``/``almalinux:9`` containers, exercising the RPM
    packaging path (``make srpm rpm``) that the other jobs don't cover.

Most jobs also set ``COVERAGE: y`` (see `Coverage`_ below) and run under
``xvfb-run`` where the testsuite needs an X11 display (X resource
handling tests, see :doc:`testsuite`).

macOS (:file:`macos_tests.yaml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A single ``macos`` job on ``macos-15`` (Apple Silicon), using Tcl/Tk
installed via Homebrew. It additionally compiles the ``testutil-*.c``
helper libraries used by the testsuite as ``dylib``\ s
(``clang -dynamiclib``, universal ``arm64``/``arm64e``) to exercise
``DYLD``-based library insertion, the macOS equivalent of the
``LD_PRELOAD`` quarantine tests run elsewhere.

Windows (:file:`windows_tests.yaml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Four jobs on ``windows-2022``, covering the different ways Modules can run
on Windows:

``native-cmd``
    Native Windows Tcl (installed from the `BAWT Tcl distribution
    <https://www.bawt.tcl3d.org/>`_), built via ``make dist-win`` and
    installed/tested/uninstalled through the generated
    :file:`INSTALL.bat`/:file:`TESTINSTALL.bat`/:file:`UNINSTALL.bat`
    scripts, driven from a ``cmd`` shell.
``native-pwsh``
    Same native Windows install, but through the PowerShell variant
    (:file:`INSTALL_PWSH.bat`/:file:`TESTINSTALL_PWSH.ps1`).
``cygwin``
    Build and test inside a `Cygwin <https://www.cygwin.com/>`_
    environment, using the regular ``./configure``/``make``/
    :file:`script/mt` flow like the Unix workflows.
``msys``
    Same, inside an `MSYS2 <https://www.msys2.org/>`_ ``MSYS`` environment.

Lint (:file:`lint_tests.yaml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Runs the ``lint`` DejaGnu tool (Nagelfar for Tcl files, ShellCheck for
sh/bash/ksh scripts) via ``script/mt lint``, i.e. the same static analysis
described as the ``lint`` tool in :doc:`testsuite`. On failure it uploads
:file:`lint.log` as a build artifact.

Differential ShellCheck (:file:`differential_shellcheck.yml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Runs only on pull requests targeting ``main`` (not on ``push``). Unlike the
full-repository ShellCheck run in the ``lint`` tool, this uses the
`redhat-plumbers-in-action/differential-shellcheck
<https://github.com/redhat-plumbers-in-action/differential-shellcheck>`_
action to lint only the lines actually changed by the pull request and post
results as inline PR review annotations and GitHub code-scanning alerts
(requires the extra ``security-events: write`` and ``pull-requests: write``
permissions granted to this job only).

EasyBuild integration (:file:`easybuild_tests.yaml`)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Builds and installs Modules, then clones the latest tagged release of the
`EasyBuild framework <https://github.com/easybuilders/easybuild-framework>`_
(a major downstream consumer of Modules) and runs *its* own test suite
(``python -m test.framework.suite``) configured to use the
just-built Modules as its modules tool. This is the one workflow that
verifies Modules against a real downstream project rather than against its
own testsuite, catching regressions the in-repo testsuite wouldn't see.

Scorecard analysis (:file:`scorecard.yml`)
-------------------------------------------

Runs `OSSF Scorecard`_, a supply-chain security posture checker, on every
push to ``main``, weekly (Saturdays at 02:30 UTC), and on manual dispatch.
Results are published to the public OSSF API and uploaded as a SARIF file
to GitHub's Code scanning. This is unrelated to build/test coverage; it
checks repository practices (branch protection, pinned dependencies, ...).
See ``.github/security-insights.yml`` for how this feeds into the project's
OpenSSF Best Practices self-assessment.

Fuzzing (:file:`cflite.yml`)
----------------------------

Runs `ClusterFuzzLite`_, a lightweight continuous-fuzzing setup built on
OSS-Fuzz's libFuzzer/sanitizer tooling, against the optional C helper
library in :file:`lib/` (see ``lib/envmodules.c`` in the repository
layout). This is what satisfies the `OSSF Scorecard`_ "Fuzzing" check
above: for C/C++ projects Scorecard only recognizes OSS-Fuzz registration
or the presence of a :file:`.clusterfuzzlite/Dockerfile`, not arbitrary
libFuzzer harnesses on their own.

:file:`.clusterfuzzlite/` at the repository root holds the fuzzing setup:

``project.yaml``, ``Dockerfile``, ``build.sh``
    Standard ClusterFuzzLite build integration files. ``build.sh``
    regenerates :file:`lib/config.h` through ``lib/configure`` (with
    ``--disable-shared --disable-stubs``, since the fuzz targets link
    against libtcl directly rather than through the Tcl stub mechanism
    the shipped extension uses) and compiles ``envmodules.c`` together
    with each fuzz target.
``fuzz_parsedatetimearg.c``, ``fuzz_readfile.c``, ``fuzz_getfilesindirectory.c``
    One target per :file:`lib/envmodules.c` entry point that parses
    externally-influenced input: date/time argument strings, file
    content (including the ``#%Module`` magic-cookie check), and
    directory-entry names, respectively. ``Envmodules_InitStateUsernameObjCmd``,
    ``Envmodules_InitStateUsergroupsObjCmd`` and
    ``Envmodules_InitStateClockSecondsObjCmd`` take no Tcl-level
    arguments and only query process/OS state (uid, group list, current
    time), so there is no fuzzer-mutable input for them and no fuzz
    target is provided.

:file:`cflite.yml` has two jobs, gated on the triggering event: ``PR`` runs
a short AddressSanitizer/UndefinedBehaviorSanitizer fuzzing pass, in
``code-change`` mode (reporting only issues newly introduced by the pull
request's diff), on pull requests touching :file:`lib/` or
:file:`.clusterfuzzlite/`. ``BatchFuzzing`` runs the same targets for a
full hour, bi-weekly and on manual dispatch, to catch issues that need a
deeper corpus to reach.

Coverage
--------

Most build/test jobs set ``COVERAGE: y``, which (as described in
:doc:`testsuite`) runs the testsuite against a Nagelfar-instrumented
:file:`modulecmd.tcl` and produces marked-up :file:`tcl/*.tcl_m` files.
After the testsuite runs, each job converts that coverage data
(``script/nglfar2ccov`` per Tcl file, plus ``gcov`` for the optional C
helper library in :file:`lib/`) and uploads it via the
``codecov/codecov-action``. :file:`codecov.yml` at the repository root
configures Codecov to wait for 7 builds before notifying (so the PR check
reflects combined coverage from all the Linux/macOS jobs that report it,
not just the first one to finish) and to fail the ``project`` coverage
status if the CI run itself failed.

Dependency updates
-------------------

:file:`.github/dependabot.yml` configures `Dependabot
<https://docs.github.com/en/code-security/dependabot>`_ to check the
``github-actions`` ecosystem (i.e. the ``uses:`` action references in
:file:`.github/workflows/`) weekly and open pull requests to bump pinned
versions, keeping the actions used by all of the above workflows current.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
