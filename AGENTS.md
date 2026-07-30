# AGENTS.md

This file provides guidance to AI coding assistants when working with code
in this repository. Codex and Mistral Vibe read it directly. Claude Code and
Gemini CLI only look for their own `CLAUDE.md`/`GEMINI.md` filename, so both
are generated as stubs that just import this file (see the `CLAUDE.md:` and
`GEMINI.md:` rules in `Makefile`).

## What this is

Modules (`envmodules/modules`) is the `module` command: a Tcl-based tool for
dynamic modification of a user's shell environment via modulefiles. The
runtime engine (`modulecmd.tcl`) is written in Tcl and must stay compatible
with Tcl 8.5+.

## Build

```sh
./configure
make            # builds modulecmd.tcl and other install artifacts
make install
```

`configure`/`Makefile` are hand-written (no autoconf/automake despite
`lib/aclocal.m4`, `lib/configure.ac` existing for the optional C helper
library in `lib/`).

### The core script is generated, not hand-edited directly for the final artifact

`modulecmd.tcl` (the actual interpreter installed to `libexecdir`) is built by
`make` by concatenating the files in `tcl/` in a fixed order (see the
`modulecmd.tcl:` rule in `Makefile`):

```
init -> util -> envmngt -> report -> interp -> mfcmd -> modscan ->
modfind -> modeval -> modspec -> cache -> coll -> main -> subcmd
```

Always edit the individual source file in `tcl/` (e.g. `tcl/main.tcl.in`,
`tcl/subcmd.tcl.in`); never edit a built `modulecmd.tcl` output directly.
Files with a `.in` suffix contain `@markname@` substitutions filled in by
`configure`/`Makefile`; files without `.in` (`mfcmd.tcl`, `modeval.tcl`,
`modscan.tcl`, `modspec.tcl`, `syntaxdb.tcl`, `util.tcl`) have no
substitutions.

## Tests

See `doc/source/devel/testsuite.rst` for the full description of how the
testsuite (DejaGnu-based) is organized, how to add tests, and how to debug
a failing one.

```sh
make test                  # full suite via DejaGnu (~25,000 cases, ~12 min)
make test QUICKTEST=y      # quick mode, most essential tests (~1,900 cases, ~1 min)
make testinstall           # test an already-`make install`ed tree
```

Run a subset of tests directly with `script/mt` (reports an expected/actual
diff on failure):

```sh
script/mt 50/470           # runs testsuite/modules.50-cmds/470-*.exp
script/mt --help           # full usage/selection syntax
```

Coverage (uses Nagelfar):

```sh
make test COVERAGE=y       # then inspect tcl/*.tcl_m for ';# Not covered' lines
script/mt cov 70/{280,290} # coverage run on selected testfiles
```

Lint (Nagelfar for Tcl, ShellCheck for sh/bash/ksh):

```sh
make testlint
script/mt lint 00/030
```

Performance comparison across released versions and current branch
(`script/mb`, stashes local changes, builds `modulecmd.tcl` for each
version):

```sh
script/mb
script/mb profile
```

## Docs

```sh
cd doc && make html   # requires Sphinx >= 1.0; output in doc/_build/html
```

## Repository layout

- `tcl/` — Tcl source, split by concern; concatenated into `modulecmd.tcl`
  (see Build section). Key files:
  - `init.tcl.in` — configuration option definitions (`g_config_defs`) and
    state handling
  - `main.tcl.in` — top-level `module` procedure, sub-command dispatch/parsing
  - `subcmd.tcl.in` — one `cmdModule<Subcmdname>` procedure per sub-command
  - `mfcmd.tcl` — modulefile commands (procedures usable *inside* a
    modulefile, e.g. `setenv`, `prepend-path`)
  - `modeval.tcl` — modulefile evaluation engine
  - `modfind.tcl.in` — locating available/loaded modules
  - `modscan.tcl` — modulefile scan / extra-match search
  - `modspec.tcl` — module specification (name/version/variant) parsing
  - `cache.tcl.in`, `coll.tcl.in` — module cache and collection management
  - `envmngt.tcl.in` — environment variable manipulation
  - `interp.tcl.in` — sub-interpreter management (modulefile sandboxing)
  - `report.tcl.in` — all output/error/debug rendering
  - `util.tcl` — generic helpers
  - `syntaxdb.tcl` — generated Nagelfar syntax DB for linting (do not hand-edit)
- `init/` — per-shell init/wrapper scripts (`bash.in`, `csh.in`, `fish.in`,
  `tcsh.in`, `zsh.in`, `pwsh.ps1.in`, `perl.pm.in`, `r.R.in`, `ruby.rb.in`,
  `cmake.in`, ...) and shell completion scripts
  (`bash_completion.in`, `fish_completion`, `tcsh_completion.in`,
  `zsh-functions/_module.in`)
- `script/` — developer/maintainer tooling: `mt` (test runner), `mb`
  (benchmark), `mlprof` (profiling), `mrel`/`mpub` (release), `pre-commit`/
  `commit-msg` git hooks, `add.modules.in`, `modulecmd.in` wrapper
- `lib/` — optional C helper library (`envmodules.c`) used for things Tcl
  can't do portably (e.g. group lookups); has its own `configure.ac`
- `testsuite/` — DejaGnu test suite; `.exp` files grouped by numbered
  directory reflecting test category, e.g. `modules.00-init`,
  `modules.50-cmds`, `modules.70-maint`, `modules.90-avail`,
  `modules.92-spider`, `lint.00-init`, `install.00-init`. Each `.exp` file is
  numbered/prefixed (e.g. `470-variant.exp`); `script/mt 50/470` targets it.
  `modulefiles*/` subdirectories hold fixture modulefiles used by the tests.
  Add fixture modulefiles for a *new* test under the highest-numbered
  `modulefiles.N` directory (e.g. `modulefiles.4`; check for a higher one
  first) rather than the default `modulefiles/` directory — many existing
  tests (`aliases`, `avail`, `spider`, `scan_eval`, ...) enumerate a
  modulepath's *entire* content, so adding to the heavily shared default dir
  changes their expected output. Even a numbered dir gets referenced
  wholesale by some tests and by filesystem-glob-order-dependent debug-trace
  assertions elsewhere in the suite, so run the full test suite after adding
  fixtures there and update any expected output it exposes — don't assume
  isolation is complete just from picking the newest numbered directory.
- `share/` — Nagelfar syntax databases, RPM spec, logo assets
- `doc/source/` — Sphinx documentation source
  - `design/` — design notes for individual features (one `.rst` per feature)
  - `devel/` — maintainer/developer howtos, notably
    `add-new-sub-command.rst` and `add-new-config-option.rst`, which give
    the exact list of files to touch (core code, init/completion scripts,
    Nagelfar syntax db, man pages, testsuite) when adding a sub-command or
    config option — follow these when doing either task
  - `changes.rst` — in-depth behavior/feature changes per major version
  - `*.rst` at top level — man page sources (`module.rst`, `modulefile.rst`,
    `modulecmd.rst`, `ml.rst`, `envml.rst`)

## Coding conventions (Tcl)

- Max line length: 78 characters
- Indent with 3 spaces, no tabs
- Tcl minimal escaping style
- Procedure names: `lowerCamelCase`; variable names: `no_case_at_all`
- Brace/bracket placement:
  ```tcl
  if {![isStateDefined already_report]} {
     setState already_report 1
  }
  ```
- No trailing whitespace, no misspellings (enforced by the `pre-commit`/
  `commit-msg` hooks in `script/`, backed by `codespell` and `hunspell`)
- Code must remain compatible with Tcl 8.5+
- Comments must convey information the code cannot — see "Code comments" in
  `CONTRIBUTING.rst` for the full guidelines (based on Ousterhout's
  *A Philosophy of Software Design*)

## Commit conventions

- Follow the "Commit message conventions" section in `CONTRIBUTING.rst` for
  subject-line prefix/verb/length, body wrapping, and trailer order.
- Every commit needs a DCO `Signed-off-by:` trailer matching the committer's
  git `user.name`/`user.email` — use `git commit -s`.
- Patches (bug fix or feature) should include tests, and the test should be
  shown to fail without the patch.
- The project follows the Linux kernel's policy on AI coding assistants (see
  "AI coding assistants" in `CONTRIBUTING.rst`): never add a
  `Signed-off-by:` trailer on behalf of the AI — only the human committer
  signs off — and disclose AI involvement with an `Assisted-by:` trailer,
  e.g. `Assisted-by: Claude:claude-sonnet-5`.

## Updating NEWS.rst

Add a new entry at the *end* of the current in-development version's bullet
list (immediately before the next `.. _X.Y release notes:` section marker),
not inserted by topic or alphabetically — entries are in the order changes
landed.

## Adding a new `module` sub-command or config option

Don't improvise the file list — `doc/source/devel/add-new-sub-command.rst`
and `doc/source/devel/add-new-config-option.rst` enumerate, in order, every
file that needs a change: core Tcl (`main.tcl.in`/`subcmd.tcl.in` or
`init.tcl.in`), shell completion scripts, Nagelfar syntax db, man pages
(`doc/source/module.rst`, `modulefile.rst`), `doc/source/changes.rst`, and
the specific testsuite files/directories to extend. Read the relevant one
before starting either task.
