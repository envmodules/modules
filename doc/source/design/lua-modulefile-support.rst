.. _lua-modulefile-support:

Lua modulefile support
======================

The objective is to be able to evaluate Lua modulefiles as Lmod does. Same
syntax should be supported. Also the same precedence mechanisms than Lmod
should be supported regarding mixing Lua and Tcl modulefiles in same
modulepath.

Evaluating Lua modulefile should have similar performances than Tcl modulefile
evaluation. Of course, it will cost a bit more as a Lua interpreter has to be
run in addition to the Tcl interpreter. But user must not notice the extra
processing time.

Enabling Lua modulefile support
-------------------------------

Lua modulefile support is always enabled. There is no option to turn it on or
off: sites control it by adding or not Lua modulefiles and modulercs in their
modulepaths.

Such option has been considered to protect existing modulepaths, as Lua
modulefile support changes the modulefiles found in modulepaths that contain
files with a ``.lua`` extension. It is not retained:

* Without Lua modulefile support, ``.lua`` files are Tcl modulefiles that are
  invalid as they do not start with the Modules magic cookie. No existing
  setup relies on them.
* Behavior only changes in a directory containing both a Tcl modulefile and a
  Lua modulefile of the same name, where the Lua modulefile is now selected.
  This is what Lmod does on the same directory, thus what is expected by a
  site that shares modulepaths between the two tools.
* No cost is added for sites that do not use Lua modulefiles, as Lua
  interpreter is only started when a Lua file has to be evaluated.
* An option means a second code path wherever ``.lua`` files are located,
  including in module cache, and a testsuite to run in both states.

A configuration option designates the Lua interpreter program to run. Its
default value is set at installation time. When this program cannot be run,
Lua modulefiles and modulercs are still located and take precedence as
described below. An error is raised when one of them has to be evaluated.

Locating Lua modulefiles
------------------------

Lua modulefiles and modulercs are located as follows:

* Any file with a ``.lua`` extension found in a modulepath is a Lua
  modulefile. Modules magic cookie is not checked on these files.
* Module name of a Lua modulefile is its file path relative to the modulepath
  without the ``.lua`` extension. Directories whose name ends with ``.lua``
  keep their full name.
* A file named :file:`.lua` is ignored, as it has no module name.
* A Lua modulefile whose module name is also the name of a directory located
  beside it (:file:`foo/1.0.lua` and :file:`foo/1.0/`) is ignored: this name
  designates the directory and the modulefiles it contains. Such clash cannot
  occur between Tcl modulefiles.
* Tcl modulercs designate Lua modulefiles with their module name (without
  ``.lua`` extension).
* Path ignore patterns (:mfcmd:`modulepath-ignore`) are matched against file
  names, thus with the ``.lua`` extension for Lua modulefiles. These patterns
  describe the content of directories, not module names: a pattern that ends
  with the name of a Tcl modulefile does not match the Lua modulefile of the
  same module name.
* A ``default`` symbolic link that targets a Lua modulefile is a Lua
  modulefile.
* A :file:`.modulerc.lua` file is a Lua modulerc, as well as any global rc
  file whose name ends with ``.lua``.

Precedence between Lua and Tcl files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When a Lua file and a Tcl file compete for the same role, the same file is
selected than on Lmod. The general rule on Lmod is that Lua files always take
priority over non-Lua files. The behavior described below corresponds to
Lmod 9.4.

Modulefiles:

* A Lua modulefile takes precedence over a Tcl modulefile of the same name in
  the same directory (:file:`foo/1.0.lua` over :file:`foo/1.0`), whatever the
  order these files are found when reading the directory.
* Content of the Lua modulefile is not looked at to apply this precedence: it
  applies even if the Lua modulefile is erroneous. The Tcl modulefile is never
  silently evaluated in place of a broken Lua modulefile.
* Only a Lua modulefile that cannot be read by the current user leaves its
  place to the Tcl modulefile.
* Across modulepaths, language of modulefiles plays no role: the modulepath
  order applies the same way than between Tcl modulefiles.

Modulercs located in modulepath directories:

* Lmod evaluates one single file per directory, the first one found in the
  following order: :file:`.modulerc.lua`, :file:`.modulerc` then
  :file:`.version`. A :file:`.modulerc.lua` thus supersedes the
  :file:`.modulerc` and :file:`.version` files of the same directory, which
  are not evaluated. This is the behavior adopted, including for the modulerc
  located at the root of a modulepath.
* Like for modulefiles, :file:`.modulerc.lua` supersedes the Tcl files even if
  it is erroneous. An evaluation error is reported and the Tcl files stay
  ignored.
* When no :file:`.modulerc.lua` exists, both :file:`.modulerc` and
  :file:`.version` are evaluated as currently done by Modules, whereas Lmod
  only evaluates :file:`.modulerc`. Precedence between Tcl files is not
  changed by Lua modulefile support.
* On Lmod a ``default`` symbolic link comes first in the above order: when
  such link exists, none of the rc files of the directory is evaluated. This
  is not adopted: an rc file may define more than the default version
  (aliases, hidden modules, etc) and Modules currently evaluates the Tcl rc
  files of a directory that contains a ``default`` symbolic link.

Global rc files:

* User rc file: :file:`$HOME/.modulerc.lua` supersedes :file:`$HOME/.modulerc`
  which is not evaluated.
* Rc file of the installation: :file:`rc.lua` in the configuration directory
  supersedes the :file:`rc` file of this directory.
* Rc files designated by configuration (:envvar:`MODULERCFILE`) are all
  evaluated. Each one is a Lua modulerc if its name ends with ``.lua``, a Tcl
  modulerc otherwise. When a directory is designated, Modules looks for a
  :file:`modulerc` file in it: by analogy a :file:`modulerc.lua` file found
  there supersedes it. This last rule has no Lmod equivalent, as Lmod
  evaluates all the files of such directory.
* Evaluation order between these three kinds of global rc file is unchanged.

These rules have several consequences on the code that locates modulefiles:

* As the file name of a Lua modulefile differs from its module name, the path
  of a modulefile cannot be computed from its modulepath and module name
  anymore. It is always fetched from the search result structure.
* Module cache records the file name of Lua modulefiles rather than their
  module name. Module name is computed when cache file is evaluated. The same
  precedence rules apply whether modulepath content is fetched from a
  directory walk or from a cache file (see `Module cache`_).
* The reverse deductions also take the extension into account: getting the
  modulepath from the path and the name of a modulefile, and telling that a
  module is virtual because its name is not the end of the path of its
  modulefile.
* Code that rebuilds the path of a modulefile from the modulepath and an entry
  of the search result (to evaluate modulefiles in ``whatis`` mode or to match
  a module against a rule set on a full path name) is changed to use the path
  recorded in this entry.
* The optimization applied when an exact module name and version is searched,
  which only keeps the entries of the directory needed to tell if this version
  is the implicit default, stays applied on directories containing ``.lua``
  files. Entries are sorted and compared there on their module name, thus
  without extension, as the extension changes how file names sort. It is worth
  keeping: on the load of a module with more than a hundred dependencies,
  walking the full directories adds as much time as half of the whole bridge.
* A ``.lua`` entry is known to be a Lua modulefile once the existing test
  that tells whether an entry is a directory is done. No system call is added
  to recognize Lua modulefiles.

Module cache
------------

Lua modulefiles and modulercs are recorded in module cache files, like their
Tcl counterparts (see :ref:`module-cache`). Same result should be obtained
whether a cache file is used or not.

Cache commands for Lua files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Two cache commands are added to record Lua files:

* ``lua-modulefile-content`` records a Lua modulefile
* ``lua-modulerc-content`` records a Lua modulerc

``lua-modulefile-content`` accepts the following arguments, in this order:

* relative file path, including the ``.lua`` extension
* file last modification date (as a Unix epoch time)
* file body content

``lua-modulerc-content`` accepts the following arguments, in this order:

* relative file path
* file body content

For instance:

* ``lua-modulefile-content foo/1.0.lua 1234567890 {body}``
* ``lua-modulerc-content foo/.modulerc.lua {body}``

These commands mirror their Tcl counterpart without the file module header
argument, as there is no magic cookie in Lua files. Like for
``modulerc-content``, modification time is not needed for modulercs.

Existing ``modulefile-content`` and ``modulerc-content`` commands are not
reused for Lua files. A Modules version that knows nothing about Lua
modulefiles would otherwise take these entries for valid Tcl modulefiles and
evaluate their Lua code as Tcl code.

There is no Lua counterpart to the ``modulefile-invalid`` command: validity of
a Lua modulefile is not checked when it is located, as there is no magic
cookie to look for.

Lua files or directories with limited access are recorded with the existing
``limited-access-file`` and ``limited-access-directory`` commands. These
commands only record a name. When such entry is tested, the file is handled
according to its name like during a directory walk.

All Lua and Tcl files found in a modulepath are recorded, including the Tcl
files that are superseded by a Lua file (like :file:`foo/1.0` when
:file:`foo/1.0.lua` exists). Precedence is applied when cache file is used,
not when it is built.

Cache evaluation
^^^^^^^^^^^^^^^^

``lua-modulefile-content`` populates the same memory structures than
``modulefile-content``:

* file content, modification time and validity are recorded with the full
  path of the file (with ``.lua`` extension) as key
* the entry added to the content list of the modulepath is named after the
  module (without ``.lua`` extension) and designates the full path of the
  file

``lua-modulerc-content`` records the file content and adds a modulerc entry to
the content list of the modulepath.

Content of a Lua file obtained from cache is transmitted to the Lua
interpreter in the evaluation request. Lua interpreter does not read the file
itself.

Precedence between Lua and Tcl files is applied on the content list of the
modulepath:

* A Lua modulefile entry replaces the Tcl modulefile entry of the same name,
  whatever the order these entries appear in cache file.
* When a :file:`.modulerc.lua` entry exists for a directory, the
  :file:`.modulerc` and :file:`.version` entries of this directory are not
  evaluated.
* Entries with limited access are tested first, as a Lua modulefile that
  cannot be read leaves its place to the Tcl modulefile of the same name.

Cache validity
^^^^^^^^^^^^^^

Version number set in cache file header is the minimal Modules version able to
use this cache file. As adding cache commands increases this minimal version:

* A cache file that contains at least one Lua cache command gets the version
  that introduces Lua modulefile support as minimal version. Older Modules
  versions silently ignore such cache file and walk the modulepath directory
  instead, where they do not consider Lua files.
* A cache file that contains no Lua cache command keeps its current minimal
  version. Modulepaths without Lua files are this way not impacted.

Cache files built by an older version
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A cache file built by a Modules version that does not support Lua modulefiles
describes the ``.lua`` files as invalid modulefiles (``modulefile-invalid``
command), without their content. As Lua files are never recorded this way
when Lua cache commands exist, such entry indicates an outdated cache file.

A ``modulefile-invalid`` entry whose name ends with ``.lua`` is handled like a
file with limited access: file is read from the modulepath directory when it
matches the search. Lua
modulefiles are this way found even if cache file has not been rebuilt.
Rebuilding the cache file is only needed to benefit from cache for these
files.

Modulefile evaluation
---------------------

For the sake of efficiency as less processes as possible should be involved to
evaluate Lua modulefiles and Lua modulercs.

The idea is to start a persistent Lua script and interact with it to make it
evaluate the successive modulefiles without restart. A single Lua script, thus
a single Lua process, evaluates both Lua modulefiles and Lua modulercs: each
kind of file is evaluated against its own set of reachable functions.

The general architecture is that :file:`modulecmd.tcl` starts the persistent
Lua script and interacts with it. The Lua script is started when the first Lua
modulefile or modulerc has to be evaluated, not to penalize situations where
only Tcl modulefiles are involved.

The Lua script will support all Lua Module functions supported by Lmod. It
will translate these functions into Tcl modulefile commands that will be
sent back to the Tcl interpreter for evaluation. This way there is only one
implementation of the modulefile commands. These Tcl commands are evaluated
in the regular modulefile Tcl interpreter that corresponds to the current
evaluation mode and depth level.

Lua evaluation is triggered from inside the modulefile Tcl interpreter: where
the content of a Tcl modulefile is evaluated, a dedicated command is called
instead to evaluate the Lua modulefile through the bridge. This way the whole
evaluation process that surrounds the evaluation of the modulefile content is
shared between Tcl and Lua modulefiles (variant checks, mode-specific
procedures, error rendering, etc).

Everything that could be achieved locally by the Lua script is performed
there without involving the Tcl interpreter (see `Work split between Lua and
Tcl`_).

Lua script also has to update its local environment to get the correct
value for environment variable if these value are accessed later-on by
modulefile or by a command it executes.

Environment variables changed by executed Tcl modulefile commands are notified
to the Lua script, which fetches their value when it is needed.

If executed Tcl modulefile command ends evaluation, this information is
sent to Lua interpreter to end evaluation on its side.

Error or other kind of messages are sent to the Tcl interpreter as command to
evaluate.

Between two modulefile or modulerc evaluations, Lua script resets to an
initial state (variable and function reset as done for Tcl interpreter).

Tcl-Lua interpreter bridge implementation
-----------------------------------------

Goal is to have a persistent Lua interpreter connected to a Tcl interpreter:

* Tcl interpreter starts the Lua interpreter as a piped command
* It sends it information on its *stdin* channel

  * Evaluation request: evaluation properties and Lua code to evaluate
  * Command reply: status and result obtained from the evaluation of a Tcl
    command sent by the Lua interpreter and name of the environment variables
    it has changed

* Lua interpreter sends back information via its *stdout* channel

  * Tcl command to evaluate (including error or other messages to raise)
  * End of evaluation signal

* Tcl interpreter close pipe to mean end of work
* When *stdin* is not working anymore, Lua interpreter exits

Exchanges are synchronous. Once an evaluation request is sent, Tcl interpreter
reads the pipe with blocking calls in a loop: it evaluates each command
received and sends its reply, until the end of evaluation signal is received.
No event loop (``fileevent``, ``vwait``) is involved on Tcl side. On Lua side,
a blocking read is performed after each command sent. No coroutine is needed
as the Lua interpreter has nothing else to do while waiting for the reply.

Starting the Lua interpreter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lua script is named :file:`mfinterp.lua`. This name follows the vocabulary
used for the Tcl code: ``mf`` stands for modulefile and ``interp`` designates
the interpreters that evaluate modulefiles and modulercs. A name made of the
full ``modulefile`` word is avoided as the script also evaluates modulercs and
as it could be taken for an actual modulefile.

Source code of the script is stored in a :file:`lua` directory at the root of
the source repository, like the :file:`tcl` directory holds the Tcl code. If
the script grows, its code can be split there in several files (bridge,
sandbox, modulefile functions, modulerc functions) that are concatenated at
build time, as done for :file:`modulecmd.tcl`.

:file:`mfinterp.lua` is generated by ``make`` at the root of the source
repository and is installed in the same directory than :file:`modulecmd.tcl`
(``libexecdir``). :file:`modulecmd.tcl` this way locates the script next to
itself, whether it is run from the source repository (by the testsuite for
instance) or from an installation. The script is installed as a data file, not
as a program: it is never executed directly but always passed as argument to
the Lua interpreter program set in configuration. It thus needs no shebang.

Embedding the code of the script in :file:`modulecmd.tcl` to send it to the
Lua interpreter is not retained: this code would be parsed by the Tcl
interpreter at each :file:`modulecmd.tcl` run, even when no Lua modulefile is
evaluated.

``LUA_INIT`` environment variable and its version-specific variants (like
``LUA_INIT_5_4``) designate code that Lua interpreter executes when it starts.
Such code may write on *stdout* before the bridge is ready. These variables
are thus withdrawn from the environment the Lua interpreter is started with
and restored afterward.

Lua interpreter is started in the environment of the user, which loaded
modules may have changed. ``LUA_PATH`` and ``LUA_CPATH`` variables set by a
module providing another Lua version would make Lua script load libraries
that do not match its interpreter. To be independent of these variables:

* ``configure`` script records the library search paths of the designated
  Lua interpreter (``package.path`` and ``package.cpath`` values). A site
  whose Lua libraries are installed in a specific location sets ``LUA_PATH``
  and ``LUA_CPATH`` when running ``configure`` to get this location recorded.
* :file:`mfinterp.lua` sets ``package.path`` and ``package.cpath`` to the
  recorded values when it starts, before loading any library. These values
  are set in the script when it is generated by ``make``.
* These search paths also apply to the ``require`` calls made by modulefiles,
  as on Lmod.

The ``-E`` option of the Lua interpreter, which ignores all these variables,
is not used: the Lua interpreter program set in configuration may be a wrapper
that relies on them to load a tool before the Lua script (see `Coverage`_).

Variables put in quarantine (:mconfig:`quarantine_support`), like
``LD_LIBRARY_PATH``, get the same treatment as when a Tcl interpreter is
created: Lua interpreter is started with the value defined for the run of
:file:`modulecmd.tcl`. Their actual value is then restored on Tcl side and
recorded as an environment change, so Lua process environment gets it before
a modulefile reads it or runs a command. Commands executed by modulefiles
this way run
with the environment of the user, whereas the Lua interpreter and its
libraries have been loaded with the protected one.

Lua script relies on the ``posix`` Lua library to update its process
environment and to set up its file descriptors. This library is a requirement
of Lmod, thus it is expected to be available on sites using Lua modulefiles.
Functions of the ``posix`` and ``lfs`` libraries are also made available to
modulefiles, as done by Lmod. They are loaded only when a modulefile accesses
them (see `Sandboxing evaluation in Lua interpreter`_).

Supported Lua versions
^^^^^^^^^^^^^^^^^^^^^^

Lua modulefile support is expected to work on Enterprise Linux 8 and newer
systems with the Lua interpreter they provide. The oldest of these systems
sets the minimal versions to support:

* Lua 5.3 (Enterprise Linux 8 provides Lua 5.3.4, newer releases provide
  Lua 5.4)
* ``posix`` library 33.3 (version 33.3.1 on Enterprise Linux 8)
* ``lfs`` library 1.6 (version 1.6.3 on Enterprise Linux 8)

:file:`mfinterp.lua` is thus written to run the same way on Lua 5.3 and
Lua 5.4:

* It only uses the syntax and the standard library functions that exist in
  both versions. Features introduced by Lua 5.4 are not used (variable
  attributes like ``<const>`` or ``<close>``, ``warn`` function, etc).
* It only uses the functions and constants of the ``posix`` library that
  exist in its minimal supported version, through the sub-modules of this
  library. For instance the ``FD_CLOEXEC`` constant is not defined by version
  33.3.1, so its value is used instead when the constant is missing.
* Every new Lua version is added to the versions tested when it gets
  available.
* Version check made by :file:`configure` script and by :file:`mfinterp.lua`
  accepts any version equal to or newer than Lua 5.3. It is computed from the
  version number rather than compared to a list of known versions.

Lua 5.5 is not provided yet by the systems to support, but sites may build it
themselves. :file:`mfinterp.lua` runs on it as long as the following points
are respected:

* Control variable of a ``for`` loop is not assigned in the loop body. It is
  read-only on Lua 5.5 and such assignment is a syntax error.
* Error object caught from evaluated code may be ``nil`` on Lua 5.3 and Lua
  5.4 (``error`` function called without argument), whereas Lua 5.5 replaces
  it by a message string. Both cases are handled.
* ``setpause`` and ``setstepmul`` options of ``collectgarbage`` function are
  not used, as they are removed from Lua 5.5.
* ``global`` word is not used as a variable name. It is the keyword of the
  global declarations introduced by Lua 5.5. It is still accepted as a name
  by default but Lua may be built with this word reserved.

luacheck does not know Lua 5.5, so it does not catch these points: they are
covered by running the integration tests with this version. ``lfs`` library
1.9 and ``posix`` library 39 build and work on Lua 5.5.

Global declarations of Lua 5.5 do not change how evaluation is sandboxed. They
are checked when code is compiled, and the global variables they declare are
still stored in the environment table of the evaluation.

Lua 5.1, Lua 5.2 and LuaJIT are not supported, whereas Lmod runs on them.
Supporting them requires a limited amount of alternative code (``setfenv``
function instead of the environment argument of ``load`` to set the evaluation
environment of modulefiles, standard functions that were renamed). But it
restricts the Lua code to the features of Lua 5.1 and requires to run the
tests with this version, for which the systems to support do not provide the
``posix`` and ``lfs`` libraries. It is not retained as these systems all
provide Lua 5.3 or newer.

As a consequence, a site whose Lmod runs on Lua 5.1 or LuaJIT has to use a
newer Lua interpreter with Modules. Its modulefiles may behave differently
there, whatever the module tool: number to string conversion has changed with
the integer type introduced by Lua 5.3 and some standard functions have been
removed. The ``unpack`` and ``loadstring`` functions of Lua 5.1 stay
available to modulefiles, as on Lmod (see `Sandboxing evaluation in Lua
interpreter`_).

Lua 5.5 brings similar changes for modulefiles: assigning the control
variable of a ``for`` loop does not compile anymore, and float numbers are
converted to string with more digits (``0.1 + 0.2`` gives
``0.30000000000000004`` instead of ``0.3``). A modulefile relying on the
global declarations of Lua 5.5 is reported as erroneous by :command:`module
lint`, as luacheck does not know this syntax.

``configure`` script checks that the designated Lua interpreter is of a
supported version. :file:`mfinterp.lua` also checks it when it starts, as the
Lua interpreter may be changed afterward through configuration: an error is
reported if the version is too old.

This constraint applies to the Lua code of Modules. Lua modulefiles and
modulercs can use any feature of the Lua interpreter that evaluates them.

Message format
^^^^^^^^^^^^^^

Every message is made of one single line. Each interpreter writes its
messages in the native syntax of the interpreter that receives them. This way
messages are parsed by the native parser of each language, which is faster and
safer than a parser written in script.

* Message sent by Lua interpreter is a valid Tcl list. First element is the
  message kind: a modulefile command to evaluate, a helper procedure to call
  or the end of evaluation signal. For the two first kinds, next elements are
  the Tcl command name and its arguments. Tcl interpreter evaluates the
  command and its arguments as a list, without any additional substitution.
* Message sent by Tcl interpreter is a Lua ``return`` statement, that Lua
  interpreter evaluates with ``load``. First returned value is the message
  kind, either an evaluation request or a command reply. Evaluation
  properties are expressed as a Lua table and the names of the environment
  variables changed as a Lua list.

Modulefile commands are evaluated in the modulefile Tcl interpreter. Helper
procedures answer the queries that do not correspond to a modulefile command
(like getting the loaded modules with their modulefile). They are called in
the main Tcl interpreter and are restricted to a fixed list of procedures.

Result of a modulefile command is a Tcl value, which has no type. It is sent
as a Lua string, or omitted when empty, and the Lua function that has sent the
command converts it into what it has to return (a boolean for ``isloaded`` for
instance). Helper procedures are written for the bridge: they express their
result in Lua syntax, so its type is preserved. Lua script distinguishes this
way a boolean from a string, and an undefined value (``nil``) from an empty
string.

Evaluation properties that only depend on the evaluation mode (list of the
commands that are no-operation, shell name and kind) are sent with the first
evaluation request made for this mode. Lua script keeps them for the next
evaluations in the same mode, whose request only carries what is specific to
the modulefile.

Lua script has a dedicated function to quote a string as a Tcl list element:
special characters are escaped with a backslash and newline characters are
translated into their ``\n`` escape sequence. Enclosing strings in braces is
not enough: it fails on strings containing unbalanced braces or ending with a
backslash and it would let a value inject Tcl code.

Tcl side has the equivalent procedure to quote a string as a Lua string
literal: backslash, double quote, newline, carriage return and null
characters are escaped.

As newline characters are always escaped, a message never spans over multiple
lines. No multi-line marker or length prefix is needed. Modulefile content is
transmitted this way, as a quoted Lua string in the evaluation request. It is
preferred over sending the path of the modulefile to let the Lua interpreter
read it: one single read is needed to get the content and the evaluation
benefits from module cache.

Both ends of the pipe are fully buffered and explicitly flushed once a message
is written, to get one write system call per message. Pipe channel is
configured with ``lf`` translation on Tcl side and keeps the system encoding,
to transmit environment variable values unaltered.

Protecting the communication channel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

*stdin* and *stdout* of the Lua process are the two ends of the bridge. If
left in place, a ``print`` call in a modulefile corrupts the message flow and
a command executed by the modulefile may consume the messages sent by the Tcl
interpreter.

When it starts, Lua script duplicates these two file descriptors onto other
descriptor numbers, flagged *close-on-exec*, and uses them for the bridge.
Then *stdout* is redirected onto *stderr* and *stdin* onto :file:`/dev/null`.
Output produced by the commands that modulefiles execute is this way sent to
*stderr*.

Output written by the modulefile code itself does not reach these file
descriptors. Messages written by a Tcl modulefile with ``puts stderr`` go
through the report code of Modules: they are placed in the message block of
the module being evaluated and follow verbosity and pager settings. For Lua
modulefiles to behave the same, the output functions of the evaluation
environment send their text to Tcl side as a ``puts stderr`` command:

* ``print`` function
* ``io.write`` function
* ``write`` method of ``io.stdout`` and ``io.stderr``, which are replaced in
  the evaluation environment by objects that only provide the methods of an
  output file

Text written on *stdout* is reported on *stderr* like the rest. It is not
sent to the shell for evaluation: output of a modulefile that is not shell
code would break the evaluation of the whole :command:`module` command
result.

Environment variable changes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Environment variable changes are tracked where they are made on Tcl side:
procedures that update the ``env`` array when evaluating modulefile commands
(``set-env``, ``unset-env`` and ``reset-to-unset-env``) record the name of
the variable they change as soon as a Lua interpreter is running. Names of
the variables changed since the previous message are added to the command
reply or to the evaluation request, then record is cleared.

Only names are sent, not values. Lua script flags the variables it is notified
of as outdated in its process environment and fetches their value from Tcl
side, through a helper procedure, when this value is needed:

* When the modulefile reads an outdated variable with ``os.getenv``: this
  variable is fetched.
* Before the modulefile runs an external command (``capture``, ``subprocess``,
  ``os.execute`` and ``io.popen`` functions): all outdated variables are
  fetched in one exchange, for the command to run in an accurate environment.

Helper procedure returns a Lua table that associates each requested variable
to its value, or to ``false`` if the variable is not defined. Lua script
applies it to its own process environment (``setenv`` from the ``posix``
library) and clears the outdated flag of these variables.

``os.getenv``, ``os.execute`` and ``io.popen`` functions of the evaluation
environment are thus wrappers of the standard ones. The same wrappers replace
these functions in the global environment of the Lua script, for the code
loaded with ``require`` or ``loadfile`` to behave the same.

Sending the values with each message, which is simpler, has been implemented
first in a prototype and discarded. Variables that get a new element at each
module load make the size of messages grow with the number of loaded modules:

* Variables holding the state of Modules (``LOADEDMODULES``, ``_LMFILES_``,
  ``__MODULES_LMPREREQ``, etc) are changed by every module load. Loading a
  module with 136 dependencies whose modulefiles only declare their
  requirements transmits 2.5 megabytes of such values to Lua interpreter and
  takes more than 20% longer than with Tcl modulefiles.
* Path-like variables (``PATH``, ``LD_LIBRARY_PATH``, etc) are changed by most
  modulefiles. With 10 path commands per modulefile on the same load, 3
  megabytes are transmitted and time spent on the bridge is more than doubled.

Modulefiles seldom read the variables they or their dependencies set, and even
less the state of Modules. Fetching values on request makes the size of the
messages independent of the size of the environment: on the above loads, 0.1
and 0.2 megabyte are sent to Lua interpreter instead.

These procedures are used whatever the language of the modulefile that
changes the environment. Changes made by a Tcl modulefile are thus
transmitted the same way:

* A Lua modulefile loads a module whose modulefile is written in Tcl: the
  variables set by this Tcl modulefile are recorded during its evaluation and
  their names are sent with the reply to the ``load`` function. The Lua
  modulefile gets their value with ``os.getenv`` right after this call.
* A Tcl modulefile is evaluated between two Lua modulefiles that do not
  depend on each other: names of the variables it sets are sent with the
  evaluation request of the second Lua modulefile. This is why changes are
  recorded even when no Lua evaluation is ongoing.

A Tcl modulefile that directly writes to the ``env`` array instead of using
modulefile commands bypasses these procedures. Such change is not transmitted
to the Lua interpreter.

An environment variable that is unset by a modulefile is kept defined on
Tcl side, set to an empty value and flagged as cleared, not to break its later
reference by a Tcl modulefile. Lua language distinguishes an undefined value
from an empty string, thus such variable is reported as not defined to the
Lua script.

Value of a variable is read from the ``env`` array when Lua script asks for
it. A variable changed several times before being read is this way transmitted
once, with its last value.

Environment is also changed on Tcl side when a module evaluation fails: the
whole evaluation context saved before this evaluation is restored
(``restoreSettings`` procedure), including the content of the ``env`` array.
This restoration does not go through the procedures mentioned above. It
records itself the variables it sets back to their previous value or unsets,
so Lua interpreter is notified of them with the next message. For instance,
when the load of a module requested by a Lua modulefile fails, the environment
changes made by this module before its failure are undone on Tcl side, and the
reply to the ``load`` function carries the names of the restored variables in
addition to the error. The requesting modulefile, if it continues or catches
the error, this way reads the same values as the ones known on Tcl side. This
applies whether the failed modulefile is written in Lua or in Tcl.

Any other code that changes the ``env`` array while a Lua interpreter is
running has to record the variables it changes the same way.

Saving the whole environment before each command evaluation to compare it
afterward is not an option: fetching the full content of the ``env`` array is
by far the most expensive operation of an exchange (see `Performance
considerations`_).

Nested evaluations
^^^^^^^^^^^^^^^^^^

Evaluating a Tcl command sent by Lua interpreter may trigger the evaluation
of another Lua modulefile or modulerc: a ``load`` Lua function for instance
that leads to the load of a module whose modulefile is written in Lua, which
may itself load its own dependencies and so on. When this happens, Lua
interpreter is waiting for the reply to its command and receives an evaluation
request instead.

After sending a command, Lua interpreter thus reads messages in a loop: an
evaluation request received is evaluated right away, then loop continues
until getting the command reply. On Tcl side, the nested evaluation runs its
own read loop until it gets its end of evaluation signal.

Evaluation levels on Tcl side
"""""""""""""""""""""""""""""

On Tcl side, each level of evaluation has its own interpreter. Modulefile
interpreter is named after the evaluation mode and the depth of the
evaluation (number of modulefiles currently evaluating), and modulerc
interpreter after this depth. A modulefile evaluated while another one is
evaluating thus never shares the interpreter of this other modulefile. These
interpreters are kept to be reused by the next evaluation occurring at the
same level, after their state has been reset.

This organization is unchanged for Lua modulefiles. The Tcl commands a Lua
modulefile is translated into are evaluated in the modulefile interpreter of
its level, like the commands of a Tcl modulefile evaluated at this level would
be. Tcl side remains the reference for the evaluation depth, which counts Tcl
and Lua modulefiles alike: a Lua modulefile that loads a Tcl modulefile that
loads a Lua modulefile leads to evaluations at depth 1, 2 and 3, whereas Lua
interpreter only sees the first and the last one.

Evaluation levels on Lua side
"""""""""""""""""""""""""""""

There is one single Lua interpreter, thus one single Lua state, whatever the
number of nested evaluations. A nested evaluation is a nested function call:
the outer evaluation is suspended in the function that waits for the reply to
its command, and the inner evaluation runs from this function, deeper in the
call stack of the Lua interpreter. When the inner evaluation ends, the wait
loop of the outer one resumes.

No Lua counterpart of the per-level Tcl interpreters is needed to isolate
evaluations from each other. Everything that belongs to an evaluation is held
in an evaluation context, created when the evaluation request is received and
dropped when the evaluation ends. These contexts are stacked: the context at
the top of the stack is the one of the evaluation currently running. An
evaluation context holds:

* The evaluation properties received in the request: modulefile path, module
  name, evaluation mode, list of Tcl commands that are no-operation in this
  mode, etc. Nested evaluations may use different modes: a module loading in
  ``load`` mode may trigger the unload of another one, evaluated in ``unload``
  mode.
* The evaluation environment: table holding the variables and functions the
  modulefile defines (see `Sandboxing evaluation in Lua interpreter`_). A
  nested modulefile does not see what the modulefile that triggers its
  evaluation has defined, and cannot change it.
* The evaluation status: whether a stop of this evaluation has been requested.

Lmod functions find the context they apply to at the top of the stack. They
are shared by all evaluations and hold no evaluation-specific information.

As an evaluation context is cheap to create, contexts are not kept to be
reused like Tcl interpreters are. Each evaluation starts from a new one, so
there is no state to reset.

Pairing messages with evaluations
"""""""""""""""""""""""""""""""""

Evaluations are strictly nested on both sides: an evaluation always ends
before the one that has triggered it resumes. As a consequence:

* A command sent by Lua interpreter always belongs to the innermost Lua
  evaluation. On Tcl side, the read loop that receives it is the one of this
  evaluation, which knows the Tcl interpreter to evaluate the command in.
* A command reply sent by Tcl interpreter always answers the last command sent
  by the innermost Lua evaluation.
* An evaluation request received by Lua interpreter always starts a new
  evaluation, nested in the current one if any.

Messages thus do not carry any evaluation identifier.

What is shared between evaluation levels
""""""""""""""""""""""""""""""""""""""""

* Process environment of the Lua interpreter and the record of its outdated
  variables. An environment variable changed by a nested evaluation is seen by
  the outer evaluation once it resumes, as the changes are notified with the
  command reply. It is the same on Tcl side, where all interpreters share the
  same environment.
* Lua modules loaded with ``require``. A module loaded by a modulefile stays
  loaded for the evaluations that follow, as on Lmod. Global variables defined
  by code loaded with ``require`` or ``loadfile`` are shared the same way.

Errors and evaluation stop
""""""""""""""""""""""""""

Each evaluation runs in its own protected call. An error raised in a nested
evaluation, or a request to stop it, ends this evaluation only: Lua
interpreter signals its end to Tcl, which determines the result of the command
that has triggered it. The outer evaluation then receives the reply to this
command like for any other command: a successful result, an error it may
catch, or a request to stop in turn.

A stop request is recorded in the evaluation context, not globally: stopping a
nested evaluation does not stop the outer ones.

Nothing has to be undone on Lua side when a nested evaluation fails. Global
variables and functions it has defined are dropped with its environment
table. Changes it has made through modulefile commands are held on Tcl side,
which restores its state and transmits the environment variables to set back
(see `Environment variable changes`_).

If the Lua interpreter ends unexpectedly, every evaluation in progress in
this interpreter is lost. Tcl side reports an error for each of them, as each
of their read loops gets the end of the pipe, and starts a new Lua interpreter
at the next Lua evaluation.

Nesting limit
"""""""""""""

Lua interpreter limits the depth of nested calls made through its C functions,
and each nested evaluation consumes a part of it. About 190 Lua evaluations
can be nested, on Lua 5.3, Lua 5.4 and Lua 5.5 alike. This is far above the
depth of actual module dependency chains. If this limit is reached, the
innermost evaluation fails with an error, reported like any other Lua
evaluation error.

Evaluation end from Tcl or Lua
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Evaluation may end on the Lua side:

* Everything goes well: end of evaluation is signaled by Lua interp to Tcl
* Code does not compile or its evaluation fails: end of evaluation is
  signaled with the error message and an error code

The error is not reported by a command sent from Lua side. It is carried by
the end of evaluation signal, and the command of the modulefile Tcl
interpreter that has requested the Lua evaluation raises it there, with its
error code. A failed Lua evaluation this way goes through the code that
handles a failed Tcl evaluation: same error counting and return code, same
downgrade into a warning when a module is unloaded in force mode. A dedicated
error code designates the errors coming from Lua, for their message to be
reported with the path of the modulefile instead of a Tcl stack trace.

Evaluation may end on the Tcl side, when the evaluation of a Tcl command
requests to stop the evaluation (like ``exit`` or ``break``). In this case,
the status of the command reply indicates that evaluation should stop. Lua
interpreter then raises an error whose value is an internal object rather than
a message. Once this specific error is caught, Lua interpreter knows that
there is nothing to report and just signals the end of evaluation. Tcl side
has kept the return code of the command that has requested the stop: once the
end of evaluation signal is received, this code is returned in the modulefile
Tcl interpreter, as if the command was called by a Tcl modulefile.

A modulefile may call a function through ``pcall`` and catch this way the
error raised to stop the evaluation. Stop request is thus recorded in the
context of the evaluation on Lua side: any function translated into a Tcl
command that is called afterward raises the stop error again without any
exchange, and the end of evaluation signal is sent whatever the way the
modulefile code ends.

Errors raised by Tcl commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When the evaluation of a Tcl command raises an error, the command reply
conveys the error message and the Tcl error code. A regular Lua error is then
raised from the place where the Lua function is called in the modulefile. Lua
modulefile may catch it with ``pcall``, like a Tcl modulefile catches the
errors of modulefile commands with ``catch``.

If this error is not caught, the Tcl error code is transmitted back with the
end of evaluation signal. Errors that have already been reported (like the
load failure of a requirement) or that should be reported as-is are this way
rendered like they are for Tcl modulefiles. To achieve this, Lua script
records in the evaluation context the last error received from Tcl side: the
error that ends the evaluation gets the Tcl error code if it is this recorded
error.

Message of an error that carries an error code of Modules is raised unchanged
on Lua side. Other errors of Tcl commands, like a wrong number of arguments,
are internal to the translation: their message is prefixed by the location of
the function call in the modulefile and they are reported as Lua errors.

Location of errors
^^^^^^^^^^^^^^^^^^

Modulefile content is loaded with its file path as chunk name. Lua error
messages this way designate the modulefile and the line number. Lua shortens
long chunk names in its error messages: the full modulefile path, known from
the evaluation properties, is restored in the message before reporting it.

For errors raised by Tcl commands, the location in the Lua modulefile is
computed only when the error occurs (with ``debug.getinfo``), by walking up
the call stack until reaching a function that belongs to the modulefile.
Nothing has to be computed or transmitted for the commands that succeed.

Lua error messages are reported as-is. Lua script does not interpret them nor
complement them with a guess of what the modulefile intended. For instance a
modulefile calling a function that is not provided gets the regular Lua error
raised for the call of an undefined variable. Like every Lua evaluation
error, it is transmitted to Tcl side which reports it the way an evaluation
error of a Tcl modulefile is reported.

Lua interpreter ignores the first line of a file it loads if this line starts
with a ``#`` character. This is not the case when code is loaded from a
string, like done here. This first line is thus blanked before loading the
modulefile content, which preserves the line numbering.

Debugging the bridge
^^^^^^^^^^^^^^^^^^^^

Exchanges are traced on Tcl side, where every message goes through, with the
existing debugging verbosity levels:

* Start and end of the Lua interpreter, with its command line, and start and
  end of each Lua evaluation are reported at the ``debug`` level.
* Every message sent to or received from the Lua interpreter is reported at
  the ``debug2`` level.

Lua script writes no debugging message by itself.

Sandboxing evaluation in Lua interpreter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lua provides a convenient ``load`` function to evaluate Lua code. A restricted
environment can be defined for this evaluation. With that feature, the list of
functions reachable by evaluated code can be controlled.

``load`` command first evaluate code to produce a function. During this step
it catches any syntax error. Then this function can be evaluated.

A base environment table is built once when Lua script starts. It contains
the Lua functions and libraries made available and the Lmod functions. Library
tables (``os``, ``io``, ``string``, etc) set in this base environment are
copies of the original ones: changing a function in the sandbox, like
``os.exit``, has this way no effect on the function used by the Lua script
itself.

A modulefile may also change a function of a library table. For such change
not to be seen by the other evaluations, whether nested or following, an
evaluation does not use the library tables of the base environment directly:
it gets its own copy of a library table the first time it accesses it.

Two functions of this base environment are defined as done by Lmod, whatever
the version of the Lua interpreter:

* ``loadstring`` compiles a string of Lua code. It is the ``load`` function of
  the Lua standard library, which is not reachable under its own name as
  ``load`` designates the Lmod function that loads modules. ``loadstring`` is
  the name of this function on Lua 5.1 and the one Lmod documents for
  modulefiles.
* ``unpack`` is the ``table.unpack`` function, which was a global function on
  Lua 5.1.

These two functions are part of what modulefiles can rely on. They are
described in the documentation of the Lua modulefile functions.

Functions called on a string with the method syntax (``s:upper()``) are not
looked up in the ``string`` table of the evaluation environment but in the
original ``string`` table, through the metatable shared by all strings. Two
consequences follow:

* A modulefile that changes a function in its ``string`` table does not
  change what the method syntax calls, for itself and for the others.
* String functions added by Lmod (``split``, ``escape``, ``trim``, etc) are
  used by modulefiles with the method syntax (``s:split(":")``). They are
  thus defined in the original ``string`` table when Lua script starts, in
  addition to the ``string`` table of the base environment.

Lmod exposes to modulefiles a subset of the standard library tables and a
few functions of the ``lfs`` and ``posix`` libraries (``posix.uname``,
``posix.setenv``, ``posix.stat``, ``posix.open``, ``posix.hostid`` and the
syslog functions). The base environment provides at least this set. As the
Lua script only loads the sub-modules of the ``posix`` library it requires,
the ``posix`` table of the base environment is built from these functions,
each one loaded from its sub-module the first time it is accessed.
``posix.setenv`` called by a modulefile only changes the environment of the
Lua process, like on Lmod: the change is not known by Tcl side and is not
applied to the shell.

``dofile`` function raises an error stating it is not supported, as on Lmod.

Code loaded by a modulefile with ``require`` or ``loadfile`` is not evaluated
in the evaluation environment of this modulefile but in the global environment
of the Lua script. Sites use this to share helper functions between
modulefiles, and such code calls Lmod functions like ``pathJoin`` or
``prepend_path``. For this to work:

* Lmod functions are also defined as global variables of the Lua script,
  under the name Lmod gives them. ``load`` is the exception: it stays there
  the function of the Lua standard library, and the function that loads
  modules is named ``load_module``, as on Lmod.
* These functions apply to the evaluation in progress, whose context is at
  the top of the stack, wherever they are called from.
* Lua script keeps its own local references to the standard functions it
  uses, so code loaded this way cannot break the bridge by redefining a
  global function.

Global variables defined by such code belong to the Lua script and last as
long as the Lua process. They are not reset between evaluations.

Each evaluation gets a new empty table as environment, whose metatable
redirects unknown names to the base environment. Variables and functions
defined by a modulefile are stored in this table that is discarded once
evaluation is over. State is this way reset between evaluations, and nested
evaluations are isolated from each other, at almost no cost.

``os.exit`` command is changed into a call to the Tcl ``exit`` modulefile
command. ``os.exit`` would otherwise ends current modulefile evaluation but
also the whole Lua interpreter script.

Work split between Lua and Tcl
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lua functions fall in three categories:

* Functions that are fully handled by the Lua script, without any exchange.
  It concerns functions relying on evaluation properties (``myFileName``,
  ``myModuleName``, ``myShellName``, ``mode``, etc), on file system
  (``pathJoin``, ``isFile``, ``isDir``, etc), on environment (``os.getenv``)
  or on external commands (``capture``, ``subprocess``, etc).
* Functions that change the state handled by Tcl interpreter (``setenv``,
  ``prepend_path``, ``load``, ``whatis``, etc). They are translated into a Tcl
  modulefile command and wait for its reply.
* Functions that query the state handled by Tcl interpreter (``isloaded``,
  ``isAvail``, etc). They are translated into a Tcl modulefile command and
  return the result obtained in reply.

Depending on the evaluation mode, some Tcl modulefile commands are
no-operation (most commands on ``whatis`` mode for instance). The list of
these commands is known by Tcl interpreter and is sent to the Lua script among
the evaluation properties of the mode (see `Message format`_). Lua script does
not send the commands that are part of this list.

Commands that set environment variables are not part of this list, whatever
the mode. On ``whatis`` mode for instance, ``setenv``, ``pushenv``,
``unsetenv`` and the path commands still update the environment on Tcl side,
for the rest of the modulefile to read the variables they set. They are sent
to Tcl interpreter like on ``load`` mode.

Performance considerations
^^^^^^^^^^^^^^^^^^^^^^^^^^

The following orders of magnitude have been measured with Tcl 9.0 and Lua 5.4
on a process environment made of about 100 variables:

* An exchange over the pipe alone (message sent then reply received) costs 5
  to 10 microseconds, depending on the load of the machine. Within an actual
  evaluation, 15 to 25 microseconds elapse on Tcl side between a message sent
  and the next message received, which covers the Lua code run in between.
  Building and parsing messages cost about 5 more microseconds on Tcl side. A
  Lua function translated into a Tcl command thus costs 20 to 30 microseconds
  more than the Tcl command evaluated alone.
* Fetching the full content of the ``env`` array on Tcl side costs about 400
  microseconds. This is why environment changes are tracked rather than
  computed.
* Starting the Lua interpreter costs a bit more than 1 millisecond. Loading
  the whole ``posix`` library adds 3 milliseconds, whereas loading one of its
  sub-modules (like ``posix.stdlib``) adds a fraction of millisecond. Lua
  script thus only loads the sub-modules it requires.

The cost of one exchange per command is small compared to the evaluation of
the command itself. Gathering several commands in one message has been
considered: it saves the exchange, about 20 microseconds per command, which
represents a fraction of millisecond for a typical modulefile. In return,
errors raised by Tcl commands are detected after the Lua code has moved on,
and pending commands have to be flushed before anything that may observe
their effect. Commands are thus sent one by one. As a message from Lua
interpreter is a Tcl list, batching could be introduced later by sending a
list of commands without changing the message format.

Starting a new Lua process for each evaluation has also been considered. It
is the simplest architecture: nested evaluations and state reset between
evaluations come for free. Two prototypes built this way have been measured:
both add about 3 milliseconds per Lua modulefile compared to the equivalent
Tcl modulefile (30 modulefiles of 15 commands loaded in about 300 milliseconds
instead of 200). With a persistent Lua process, the start cost is paid once
and each modulefile then costs a few exchanges, 0.2 to 0.4 millisecond for
such modulefiles.

The overhead of Lua modulefiles on a large load has been measured with a
prototype of the bridge, on the 137 modulefiles loaded by the ``load2`` test
of :file:`script/mb` and on their translation in Lua. These modulefiles mostly
declare requirements. Path and variable commands have been added to them to
get larger modulefiles. Time spent on the bridge is measured on Tcl side: it
covers the messages built and parsed and the wait for Lua interpreter, start
of the Lua process included.

+--------------+------------+------------------+---------------+----------+
| Commands per | Messages   | Load time of Tcl | Time spent on | Overhead |
| modulefile   | sent       | modulefiles      | the bridge    |          |
+==============+============+==================+===============+==========+
| 5            | 755        | 0.45 s           | 20 ms         | 4.4 %    |
+--------------+------------+------------------+---------------+----------+
| 15           | 2125       | 1.4 s            | 70 ms         | 5.0 %    |
+--------------+------------+------------------+---------------+----------+
| 35           | 4865       | 4.7 s            | 115 ms        | 2.4 %    |
+--------------+------------+------------------+---------------+----------+

Run time of the whole command confirms these values: :file:`script/mb` reports
about 475 milliseconds for the ``load2`` test and 500 milliseconds for its
``load2_lua`` counterpart. This difference is of the same order as the
variation observed between two runs of the same test on a machine that is not
idle.

The cost of a command on the bridge is constant, whereas the cost of running
this command on Tcl side grows with the number of loaded modules: from 0.4
millisecond when a couple of modules are loaded to about 1 millisecond with a
hundred of modules. The larger the modulefiles, the smaller the relative
overhead of Lua modulefiles. The same applies when unloading or purging these
modules. Listing loaded modules evaluates no modulefile, thus no Lua
interpreter is started.

This prototype has shown that two points weigh more than the bridge itself if
they are overlooked:

* Sending the value of the changed environment variables with each message
  multiplies the time spent on the bridge by about 4 on the first of these
  loads and by more than 6 on the last one (see `Environment variable
  changes`_).
* Walking the full content of the directories containing ``.lua`` files when
  an exact module version is searched adds 10 milliseconds on the first load
  (see `Precedence between Lua and Tcl files`_).

Global rc files are evaluated at every run of the :command:`module` command,
whatever the sub-command. When one of them is written in Lua, the Lua
interpreter is started at every run, including for the sub-commands that
evaluate no modulefile like :subcmd:`list`. The start cost, less than 2
milliseconds, is then paid by every command. A site that wants to avoid it
writes its global rc files in Tcl. Lua rc files located in modulepath
directories only start the Lua interpreter when these directories are
searched.

The overhead is the most visible on a command evaluating a single small Lua
file: starting the Lua process then represents a few percent of the run time
of the :command:`module` command.

For this overhead to stay constant per command, the following points have to
be respected by the implementation:

* No work proportional to the size of the environment or to the number of
  loaded modules is done per command on the bridge: only the names of the
  variables changed by the command are sent back to Lua interpreter.
* Reply to a command that changes nothing in environment carries no
  environment change structure.
* Evaluation properties that do not depend on the modulefile are not sent
  with each evaluation request.
* Commands that are no-op in the current evaluation mode are handled on Lua
  side, without any exchange. A ``whatis`` evaluation over a whole modulepath
  this way only exchanges for the ``whatis`` function calls and for the
  functions that set environment variables.
* Lua interpreter is started only when a Lua file has to be evaluated.

Linking Lua interpreter into the Tcl process through a C extension would
save the pipe exchanges and the process start. It is not retained as it
requires Lua development files at build time and makes Lua modulefile support
dependent of the Modules Tcl extension library, which is optional.

Handling evaluation modes
^^^^^^^^^^^^^^^^^^^^^^^^^

The various evaluation modes (``load``, ``unload``, etc) are handled by the
Tcl interpreter which is initialized to perform a mode-specific evaluation of
the modulefile commands. As the Lua interpreter sends to the Tcl interpreter
a conversion of the Lua commands in Tcl commands, it does not need to handle
the mode particularities.

The ``help`` Lua function is translated into the ``module-help`` Tcl
command. Its arguments are concatenated into a single string.

There is no equivalent of ``ModulesDisplay`` and ``ModulesTest`` in Lmod. Also
Lmod has no ``test`` evaluation mode. Running ``module spider`` evaluates
modules with ``spider`` mode on Lmod whereas ``scan`` mode is used on Modules.

The ``mode`` Lua function returns the name Lmod gives to the current
evaluation mode, as modulefiles written for Lmod compare its result to these
names:

* ``load``, ``unload``, ``help`` and ``whatis`` modes have the same name on
  both tools
* ``show`` is returned for ``display`` mode
* ``spider`` is returned for ``scan`` mode
* ``load`` is returned for ``refresh`` mode, as Lmod does when it refreshes
  the loaded modules
* ``test`` is returned for ``test`` mode, which has no Lmod equivalent

Name of the Modules evaluation mode is still part of the evaluation
properties, for the needs of the Lua script.

A few Lmod behaviors depend on the evaluation mode and cannot be obtained
from the sole translation into a Tcl command. They are handled by the Lua
script, which knows the evaluation mode from the evaluation properties:

* ``modeA`` table option of Lmod functions: the function is skipped if the
  current evaluation mode is not part of the listed modes. When unloading, a
  function enabled for the ``unload`` mode is applied as-is instead of being
  reversed. To achieve this, the load mode variant of the Tcl command is
  called through a helper procedure. As on Lmod, the function is always
  applied on ``display`` mode, where it is reported, and it is applied on
  ``scan`` mode if ``load`` is part of the listed modes.
* ``modeA`` only accepts the ``load``, ``unload`` and ``normal`` values.
  ``normal`` designates the regular behavior of the function, the same as
  when no ``modeA`` option is set. Another value is an error, like any
  unknown option name in the table passed to a function.
* ``LmodError`` is reported as a warning when unloading. It does nothing on
  ``whatis``, ``help`` and ``scan`` modes, where the evaluation continues, so
  information of a module can be queried even if it cannot be loaded.
  ``LmodSystemError`` raises an error whatever the mode.
* ``LmodMessage`` and ``LmodMsgRaw`` do nothing on ``whatis``, ``help``,
  ``scan`` and ``refresh`` modes.
* ``LmodBreak`` only stops the evaluation when loading.
* ``unload`` unloads the designated modules when loading and when unloading
  on Lmod. Tcl :mfcmd:`module unload<module>` command does nothing when
  unloading, which is kept.

Mapping Lmod functions to Tcl commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most Lmod functions have a direct Tcl modulefile command equivalent. Some
mappings require attention:

* ``prereq`` and ``prereq_any`` only check that the requirement is loaded,
  whereas ``depends_on`` and ``depends_on_any`` load it automatically. They
  respectively map to the ``prereq-all``, ``prereq-any``, ``depends-on`` and
  ``depends-on-any`` commands. Whether the requirement is automatically
  loaded depends on Modules side on the automated module handling mode rather
  than on the command used.
* ``isloaded`` returns true for a module that is loaded or currently loading.
  ``is-loaded`` Tcl command only returns true for a loaded module: its result
  is combined with the query of the modules currently loading that
  ``isPending`` relies on.
* Version modifier functions (``between``, ``latest``, etc) return an object
  that is translated into an advanced version specifier when passed to a
  function that expects a module specification (``between("foo", "1.2",
  "2.0")`` gives ``foo@1.2:2.0``). Advanced version specifiers have to be
  enabled.
* An exclusive upper bound (``<`` character before version) is translated
  into an abbreviated upper bound, which includes all versions that extend
  it. Trailing elements of the version equal to ``0`` are dropped, then its
  last element is decreased by one: ``between("foo", "2.7", "<3.0")`` gives
  ``foo@2.7:2`` and ``between("foo", "2.7", "<3.2")`` gives ``foo@2.7:3.1``.
  An error is raised if the last element is not a number or if no element
  remains.
* An exclusive lower bound (``<`` character after version) cannot be
  expressed with advanced version specifiers. An error is raised when such
  bound is used.
* ``priority`` option of ``prepend_path`` and ``append_path`` maps to the
  ``--priority`` option of the corresponding Tcl commands.
* Third argument of ``prepend_path``, ``append_path`` and ``remove_path``, or
  their ``delim`` option, maps to the ``--delim`` option of the corresponding
  Tcl commands.
* ``remove_path`` maps to ``remove-path`` with ``--remove-on-unload`` option.
* ``setenv`` called with a true third argument only sets the variable if it
  is not defined yet. It maps to ``setenv`` with ``--set-if-undef`` option.
* ``set_shell_function`` receives the function body for *sh* shells and the
  one for *csh* shells. The body that corresponds to the current shell is
  passed to ``set-function``. As *csh* shells have no function, the second
  body is defined there as an alias with ``set-alias``, as done by Lmod.
  ``unset_shell_function`` follows the same rule.
* ``complete`` and ``uncomplete`` receive a shell name as first argument.
  ``uncomplete`` Tcl command does not have this argument: Lua script skips
  the call if the shell name does not match the current shell.
* ``source_sh`` receives the script and its arguments as a single string,
  which is split into words to call ``source-sh``.
* ``extensions`` receives a single string of comma-separated names, which is
  split to call the ``extensions`` Tcl command with one argument per name.
* ``add_property`` maps to ``add-property``, which sets its value argument as
  a tag. ``remove_property`` is a no-operation. Properties are not described
  in a properties file like on Lmod (see `Properties file`_).
* ``family``, ``requireFullName``, ``always_load``, ``try_load``,
  ``load_any``, ``purge`` and ``unsetenv`` map to the Tcl command or
  :mfcmd:`module` sub-command of the same name. ``try_add`` and
  ``always_unload`` are other names of ``try_load`` and ``unload``.
* ``LmodMessage`` and ``LmodMsgRaw`` map to ``puts stderr``, the latter with
  ``-nonewline`` option. ``LmodWarning`` maps to ``reportWarning`` and
  ``LmodError`` to the Tcl ``error`` command. Their arguments are
  concatenated into a single string.
* ``isPending`` and ``moduleStackTraceBack`` query the modules currently
  loading through a helper procedure.
* ``export_shell_function`` marks on Lmod a shell function as exported to
  the sub-shells. ``set-function`` Tcl command always exports the function
  it defines on the shells that support it. ``export_shell_function`` is
  thus a no-operation.
* ``pushenv`` with a ``false`` value maps to a ``pushenv`` of an empty value.
  The variable is then set to an empty string, whereas it is unset on Lmod.
* ``execute`` maps to a ``puts stdout`` of the command when current mode is
  part of its ``modeA`` option.
* ``inherit`` looks for the modulefile of the same name in the modulepaths
  that come after the one of the current modulefile. A Lua modulefile found is
  evaluated in the current Lua evaluation environment. The content of a Tcl
  modulefile found is evaluated in the current modulefile Tcl interpreter.
* ``capture``, ``subprocess`` and commands run with ``os.execute`` or
  ``io.popen`` get the environment as currently changed by the modulefile,
  since Lua process environment is updated before running them.

Functions handled by the Lua script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Functions that need no exchange with Tcl side are written in Lua. Their
result has to be the same as on Lmod for the same arguments, which is checked
by tests whose expected results are obtained from Lmod. The following ones
require attention:

* ``LmodVersion`` returns the version of Lmod whose modulefile functions are
  implemented by Lua script, not the version of Modules. Modulefiles compare
  this value with ``convertToCanonical`` to know if a function is available.
  Returning the Modules version would make them disable features that are
  supported. This reference version is currently Lmod 9.4. It is raised when
  all the modulefile functions of a newer Lmod version are handled. Functions
  added by new Lmod versions are reviewed for each feature release of
  Modules.
* ``convertToCanonical`` returns a string built so that the comparison of two
  such strings orders the versions they come from. Version ordering has to be
  the one of Lmod.
* File functions (``pathJoin``, ``dirname``, ``extname``, ``removeExt``,
  ``barefilename``, ``splitFileName``, ``abspath``, ``realpath``,
  ``path_regularize``, ``mkdir_recursive``, ``isDir``, ``isFile``) follow the
  rules of Lmod. For instance ``pathJoin`` removes the trailing slash and
  ``isFile`` is true for anything that exists and is not a directory.
* ``myShellType`` returns ``sh`` for the *sh*, *bash*, *ksh* and *zsh*
  shells, ``csh`` for the *csh* and *tcsh* shells and the name of the shell
  otherwise. ``myShellName`` returns the shell name as known by Modules.
* ``myModuleName`` and ``myModuleVersion`` split the full name of the module
  at its last ``/`` character: what precedes is the name and what follows is
  the version. A module whose full name contains no ``/`` character has an
  empty version. Lmod determines this split from the layout of the modulepath
  directory. Results only differ for modules with a version spanning over
  several directory levels (for :file:`foo/1/2.lua` Lmod may return ``foo``
  and ``1/2`` where ``foo/1`` and ``2`` are returned here).
* ``myModuleUsrAndAliasName`` and ``myModuleFullNameAndAlias`` return two
  values on Lmod, which differ when a module in a dot-hidden directory is
  designated without the dot. Modules does not have this mechanism: the same
  value is returned twice.
* ``userInGroups`` is true if current user is *root* or is member of one of
  the groups passed. User and groups are obtained with the ``posix`` library.
* ``myConfig`` returns a configuration value of Lmod. ``username`` and
  ``usergroups`` keys are supported. Other keys designate configuration that
  has no counterpart: ``nil`` is returned.
* ``protected_getenv``, ``isDefined``, ``isNotDefined``, ``UUIDString``,
  ``hierarchyA`` and ``is_spider`` only rely on the evaluation properties and
  on the evaluation environment.
* ``colorize`` returns its text argument with color codes only if Modules is
  configured to output colors. ``color_banner`` outputs a separator line on
  *stderr*.
* ``dbg`` functions and ``haveDynamicMPATH`` are no-operation.
* ``capture`` runs on Lmod its command with the ``LD_LIBRARY_PATH`` and
  ``LD_PRELOAD`` values recorded at installation, unlike ``subprocess``. Both
  functions use the current environment on Modules.

Lmod checks the type of the arguments passed to its functions: most functions
only accept strings. The same checks are applied by the Lua script, so an
erroneous call is reported with the name of the function and the location of
the call in the modulefile rather than as an error of a Tcl command.

Identifying the module tool
^^^^^^^^^^^^^^^^^^^^^^^^^^^

A Lua modulefile shared between Lmod and Modules needs to know which tool
evaluates it, and which version, to adapt to their differences or to use a
function that only one of them provides. Two distinct pieces of information
are available for this, on both tools:

* ``LmodVersion`` function tells the level of the Lmod modulefile functions
  that is supported. On Modules it returns the reference Lmod version, as
  described above. It never tells anything about Modules itself: its result
  does not change when functions specific to Modules are added. Lmod also
  provides this version through environment variables of its process, that
  some modulefiles read instead of calling the function: ``LMOD_VERSION``,
  and ``LMOD_VERSION_MAJOR``, ``LMOD_VERSION_MINOR`` and
  ``LMOD_VERSION_SUBMINOR`` for each of its elements. Lua script defines
  these four variables in the environment of the Lua process when it starts,
  from the reference Lmod version. An element this version does not have is
  set to ``0``, as on Lmod.
* ``ModuleTool`` and ``ModuleToolVersion`` environment variables tell the
  tool and its own version. Lmod defines them in the environment of its
  process, set to ``Lmod`` and to its version, so modulefiles read them with
  ``os.getenv``. Lua script defines them the same way in the environment of
  the Lua process when it starts, set to ``Modules`` and to the version of
  Modules. These are the values of the :mfvar:`ModuleTool` and
  :mfvar:`ModuleToolVersion` variables of Tcl modulefiles. Like on Lmod,
  these variables are not exported to the shell of the user.

These two variables are not defined as Lua global variables, as Lmod does
not define such variables: a test written this way would not work on Lmod.

All these variables only exist in the environment of the Lua process. They
are not known by Tcl side and not applied to the shell of the user.

A modulefile then adapts to the tool as follows:

.. code-block:: lua

    local tool = os.getenv("ModuleTool")
    local version = convertToCanonical(os.getenv("ModuleToolVersion"))

    if tool == "Modules" and version >= convertToCanonical("5.9") then
        -- use a function specific to Modules
    elseif tool == "Lmod" then
        -- Lmod way to achieve the same
    end

    if convertToCanonical(LmodVersion()) >= convertToCanonical("8.6") then
        -- use an Lmod function supported by both tools from this level
    end

Functions specific to Modules that are added at the last implementation
stage are thus tested with ``ModuleTool`` and ``ModuleToolVersion``, never
with ``LmodVersion``.

Modulerc functions
^^^^^^^^^^^^^^^^^^

Lua rc files are evaluated in a more restricted environment than modulefiles.
Like on Lmod, it only contains the modulerc functions, ``myConfig``,
``pathJoin``, ``isDir``, ``isFile``, ``require``, ``loadfile`` and a subset of
the ``os`` and ``io`` tables. Modulefile functions are not available.

Modulerc functions map to Tcl modulerc commands:

* ``module_version`` and ``module_alias`` map to ``module-version`` and
  ``module-alias``.
* ``hide_version`` and ``hide_modulefile`` map to the Tcl commands of the same
  name.
* ``hide`` maps to ``module-hide`` and ``forbid`` to ``module-forbid``. Each
  key of the table they receive has an option counterpart:

  +---------------------------+-------------------------------------------+
  | Key                       | Option                                    |
  +===========================+===========================================+
  | ``name``                  | Modulefile arguments (one per name)       |
  +---------------------------+-------------------------------------------+
  | ``kind`` (``hide``)       | ``--soft`` for ``soft``, ``--hard`` for   |
  |                           | ``hard``, no option for ``hidden``        |
  +---------------------------+-------------------------------------------+
  | ``hidden_loaded``         | ``--hidden-loaded``                       |
  | (``hide``)                |                                           |
  +---------------------------+-------------------------------------------+
  | ``before``, ``after``     | ``--before``, ``--after``                 |
  +---------------------------+-------------------------------------------+
  | ``userA``, ``groupA``     | ``--user``, ``--group``                   |
  +---------------------------+-------------------------------------------+
  | ``notUserA``,             | ``--not-user``, ``--not-group``           |
  | ``notGroupA``             |                                           |
  +---------------------------+-------------------------------------------+
  | ``message``,              | ``--message``, ``--nearly-message``       |
  | ``nearly_message``        |                                           |
  | (``forbid``)              |                                           |
  +---------------------------+-------------------------------------------+

  A name may be a module name, a module name and version or the path of a
  modulefile. All three are accepted by the Tcl commands. An unknown key or a
  value of the wrong type is an error.
* ``module_virtual`` maps to ``module-virtual``. Its second argument
  designates on Lmod the module that implements the virtual name, by its
  name and version, whereas the Tcl command expects the path of a modulefile.
  Lua script converts this name into a file path: the name is appended to the
  modulepath directory the rc file belongs to, with the ``.lua`` extension if
  such file exists. For a global rc file, each enabled modulepath is tried in
  turn. This lookup is made by the Lua script on the file system, as querying
  the module search on Tcl side during the evaluation of an rc file would
  start this search again. Lmod also hides the implementing module, which
  is not done on Modules: this module stays visible unless a hiding rule is
  defined for it.
* ``hideRegex`` and ``forbidRegex`` map to ``module-hide-regex`` and
  ``module-forbid-regex``. They receive the same table than ``hide`` and
  ``forbid``, whose keys are converted into the same options, except that
  each name is a pattern rather than a module designation. Like on Lmod, a
  pattern is searched in the name and version of modules and is not anchored.

  Patterns are Lua patterns in a Lua rc file, whereas rules are matched on
  Tcl side with Tcl regular expressions. Evaluating the Lua patterns in the
  Lua process is not an option: rules are tested against every module looked
  at, long after the evaluation of the rc file, and each test would require
  an exchange between the two processes. Lua script converts instead each
  pattern into a Tcl regular expression when the function is called, so rc
  files written for Lmod are used as is:

  +---------------------------+-------------------------------------------+
  | Lua pattern item          | Tcl regular expression                    |
  +===========================+===========================================+
  | ``%`` followed by a       | ``\`` followed by this character          |
  | non-alphanumeric          |                                           |
  | character                 |                                           |
  +---------------------------+-------------------------------------------+
  | ``%a``, ``%c``, ``%d``,   | Corresponding bracket expression          |
  | ``%g``, ``%l``, ``%p``,   | (``[[:alpha:]]``, ``[[:digit:]]``,        |
  | ``%s``, ``%u``, ``%w``,   | ``[[:space:]]``, etc)                     |
  | ``%x``                    |                                           |
  +---------------------------+-------------------------------------------+
  | Upper case version of     | Negated bracket expression                |
  | these classes             | (``[^[:alpha:]]``, etc)                   |
  +---------------------------+-------------------------------------------+
  | ``.``, ``*``, ``+``,      | Kept as is                                |
  | ``?``, sets, captures     |                                           |
  +---------------------------+-------------------------------------------+
  | ``-`` quantifier          | ``*``                                     |
  +---------------------------+-------------------------------------------+
  | ``%1`` to ``%9``          | ``\1`` to ``\9``                          |
  +---------------------------+-------------------------------------------+
  | Characters that are       | Escaped with ``\``                        |
  | literal in Lua and        |                                           |
  | special in Tcl (``\``,    |                                           |
  | ``|``, ``{``, ``}``)      |                                           |
  +---------------------------+-------------------------------------------+

  The following points are specific to Lua patterns and are respected by the
  conversion:

  * ``-`` is the non-greedy version of ``*``. Only the fact that a pattern
    matches is used, not the extent of the match, so both quantifiers are
    equivalent here.
  * A quantifier applies to a single character, class or set. Elsewhere (at
    the beginning of the pattern, after a capture) these characters are
    literal and are escaped. A pattern like ``-debug$`` thus designates the
    names ending with ``-debug``.
  * ``^`` is an anchor only at the beginning of the pattern and ``$`` only at
    its end. They are escaped elsewhere.
  * Within a set, ``%`` escapes and character classes are converted the same
    way (``[%d_]`` gives ``[[:digit:]_]``).

  Some items have no counterpart in Tcl regular expressions: ``%b``
  (balanced match), ``%f`` (frontier), position captures and upper case
  classes within a set. A pattern using one of them raises an error that
  names the unsupported item. As on Tcl side, the resulting regular
  expression is matched without case sensitivity when the ``icase``
  configuration option enables it, whereas Lmod match is always case
  sensitive.

Modulerc commands that are specific to Modules (``module-tag``,
``module-warn``, ``modulepath-label``, etc) have no Lua function in the
initial implementation (see `Implementation stages`_). As a Lua rc file
supersedes the Tcl rc file of the same directory, a site that needs these
commands for a directory writes its rc file in Tcl.

Loading a module that is already loaded
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lmod and Modules behave differently when a modulefile asks to load a module
that is already loaded.

On Lmod, ``load`` unloads the loaded module that has the same name than the
module to load, then loads the requested one. Requested module is thus
reloaded if it is already loaded, and replaces another version of this module
if such version is loaded. As they rely on the same code, this also applies
to ``try_load``, ``load_any`` and ``always_load``. For ``load_any`` it applies
to the first module of its list that can be loaded. It does not apply to
``depends_on`` and ``depends_on_any``, which leave an already loaded module
untouched and count one more reference to it.

On Modules, :subcmd:`load` sub-command does nothing for a module that is
already loaded. Another version of the same module is loaded in addition to
the one already loaded, unless the configuration requires that a single
module of a given name is loaded.

Lmod functions are translated into the corresponding Modules sub-command or
modulefile command without trying to reproduce the reload:

* An already loaded module is not reloaded by ``load``, ``try_load``,
  ``load_any`` and ``always_load``.
* A loaded module of the same name but of a different version is handled the
  way Modules is configured to.

Reproducing Lmod behavior would make Lua modulefiles behave differently than
Tcl modulefiles on the same installation, for a mechanism that Modules handles
with its own dependency tracking and conflict resolution.

``mgrload`` function
""""""""""""""""""""

On Lmod, ``mgrload`` loads one module described by an object obtained from
``loaded_modules``. It is designed for a modulefile that unloads all loaded
modules, changes something then loads them again. Unlike ``load``, the
modulefile loaded this way gets its own module load requests ignored, and the
module keeps the properties recorded in the object: how many modules depend
on it and whether it was loaded by the user or by another module.

On Modules, ``mgrload`` is translated like ``load``: the module named in the
object is loaded if it is not already loaded, and nothing is reported if it
cannot be loaded when the first argument of the function is false. Function
returns whether the module is loaded. As ``load`` does not reload modules on
Modules, both functions are nearly equivalent there. Two differences remain
with Lmod:

* Module load requests of the modulefile loaded this way are evaluated. When
  modules are loaded again in their initial order, as done in the above use
  case, these requests find their target already loaded.
* A module loaded this way is recorded as loaded by the modulefile that calls
  ``mgrload``, even if it was initially loaded by the user.

``loaded_modules`` function
"""""""""""""""""""""""""""

On Lmod, ``loaded_modules`` returns an array with one table per loaded
module, in load order. On Modules, list of loaded modules is obtained from Tcl
side through a helper procedure and the tables are built by the Lua script.
Only the simple properties are set to an actual value:

* ``fullName``, ``name`` and ``displayName``: name and version of the module
* ``sn``: name of the module without its version
* ``userName``: same value than ``fullName``, as the name initially used to
  designate a loaded module is not recorded by Modules
* ``fn``: path of the modulefile
* ``loadOrder``: position of the module among the loaded modules

The other properties that Lmod sets describe information that Modules does not
track or tracks differently. They are defined with an empty value so
modulefile code that reads them does not fail:

* ``stackDepth`` and ``ref_count``: set to 0
* ``origUserName``: set to ``false``
* ``depends_on_anyA``, ``moduleKindT`` and ``forbiddenT``: empty table

Such table can be passed to ``mgrload``, which only uses its ``userName``
property.

Software hierarchy
^^^^^^^^^^^^^^^^^^

Lmod sites often organize their modules as a hierarchy: a compiler module
adds to :envvar:`MODULEPATH` the directory of the modules built with this
compiler, an MPI module does the same for the modules built with this MPI
library. Lua modulefiles written for such setup work on Modules, as changing
:envvar:`MODULEPATH` with ``prepend_path`` enables the corresponding
modulepath. But the two tools handle differently the modules loaded from a
modulepath once this modulepath is removed:

* On Lmod, unloading the compiler module makes the modules loaded from its
  directory inactive, and switching to another compiler reloads them from the
  directory of the new compiler.
* On Modules, a module only depends on the modules it declares as
  requirement. Modules loaded from the directory of the compiler stay loaded,
  as they were, when this compiler is unloaded or switched. If they declare
  the compiler as a requirement (``depends_on`` or ``prereq``), the automated
  module handling mode unloads them with the compiler and reloads them from
  the new directory on a switch.

This difference does not come from the language of modulefiles and is not
changed by Lua modulefile support.

Hierarchical modulefiles also read environment variables that Lmod defines:

* ``family`` Tcl command sets the ``LMOD_FAMILY_<NAME>`` variable and the
  ``LMOD_FAMILY_<NAME>_VERSION`` variable, the latter holding the version of
  the module, which is commonly used to build the path of the directory to
  enable. These variables are set by the Tcl command, so they are defined
  whatever the language of the modulefile. For a module without version,
  ``LMOD_FAMILY_<NAME>_VERSION`` is set to an empty string whereas Lmod sets
  it to the ``false`` string.
* Other variables (``MODULEPATH_ROOT``, ``LMOD_SYSTEM_NAME``, etc) are set by
  the initialization of Lmod or by the site. They are not defined by Modules:
  a site whose modulefiles rely on them defines them in its initialization
  setup.

Site customization
------------------

Lmod sites adapt its behavior with a :file:`SitePackage.lua` file. This file
has two distinct roles: it registers hook functions called by Lmod at given
points of its execution, and it defines site-specific functions made
available to modulefiles. Sites also describe the properties modulefiles may
set in a properties file.

Hooks
^^^^^

Lmod hook functions are Lua code running within Lmod itself. They rely on the
internal objects of Lmod to query the loaded modules or the evaluation stack,
and some hooks receive such objects as argument. These hooks are not
modulefile code: evaluating them would require to emulate the internals of
Lmod.

Hook functions registered in a :file:`SitePackage.lua` file are not run by
Modules. Sites migrate their hook code as Tcl procedures defined in
:file:`siteconfig.tcl` and registered with the ``add-hook`` command (see
:ref:`hook-api`). This way hooks have a single implementation, written in
Tcl, that applies to both Tcl and Lua modulefiles. No Lua interpreter has to
be started for hooks when no Lua file is evaluated.

Following table describes how the hooks of Lmod map to hook events of
Modules.

+--------------------------+------------------------------------------------+
| Lmod hook                | Modules counterpart                            |
+==========================+================================================+
| ``load``                 | ``after-modulefile-eval`` event, with ``load`` |
|                          | evaluation mode                                |
+--------------------------+------------------------------------------------+
| ``unload``               | ``after-modulefile-eval`` event, with          |
|                          | ``unload`` evaluation mode                     |
+--------------------------+------------------------------------------------+
| ``load_spider``          | ``after-modulefile-eval`` event, with ``scan`` |
|                          | evaluation mode                                |
+--------------------------+------------------------------------------------+
| ``isVisibleHook``,       | No hook event. Rules are expressed with        |
| ``isForbiddenHook``      | ``module-hide`` and ``module-forbid`` commands |
+--------------------------+------------------------------------------------+
| ``avail``                | No hook event. Labels are set with             |
|                          | ``modulepath-label`` command                   |
+--------------------------+------------------------------------------------+
| ``startup``,             | No hook event currently                        |
| ``finalize``,            |                                                |
| ``restore``,             |                                                |
| ``decorate_module``,     |                                                |
| ``msgHook``,             |                                                |
| ``errWarnMsgHook``,      |                                                |
| ``listHook``,            |                                                |
| ``colorize_fullName``,   |                                                |
| ``SiteName``             |                                                |
+--------------------------+------------------------------------------------+
| ``parse_updateFn``,      | Not applicable. These hooks relate to features |
| ``writeCache``,          | specific to Lmod: spider cache, reverse map    |
| ``groupName``,           | and category                                   |
| ``packagebasename``,     |                                                |
| ``reverseMapPathFilter``,|                                                |
| ``spider_decoration``,   |                                                |
| ``category``             |                                                |
+--------------------------+------------------------------------------------+

Hook events of Modules are added when a need is expressed. Sites whose hook
has no counterpart are invited to request the corresponding hook event to the
Modules project. Several of the missing hooks return a value used by Lmod
(text to output, content to add to a modulefile). Hook procedures of Modules
currently have their return value ignored, so the hook API has to be extended
for such events.

Site-specific functions
^^^^^^^^^^^^^^^^^^^^^^^

:file:`SitePackage.lua` also defines functions and makes them callable from
modulefiles with ``sandbox_registration``. A modulefile calling such function
fails to evaluate on Modules as the function is unknown.

Support for these site-specific functions is not part of this initial work.
It may be added later: a site Lua file loaded once when the Lua interpreter
starts, with the functions it registers through ``sandbox_registration``
added to the base environment table of the sandbox.

Properties file
^^^^^^^^^^^^^^^

On Lmod, the properties a modulefile may set with ``add_property`` are
described in a properties file: :file:`lmodrc.lua` in the installation
directory of Lmod, completed by the files of the same name found in system
locations, by :file:`$HOME/.lmodrc.lua` and by the file designated by
``LMOD_RC``. For each property name, this file defines the valid values and
how each value is displayed (short string, color and description).

These files are not read by Modules. ``add_property`` sets its value
argument as a tag on the module, and tags are configured with the options of
Modules. Sites port the content of their properties file as follows:

+----------------------------+--------------------------------------------+
| Properties file            | Modules counterpart                        |
+============================+============================================+
| Valid names and values     | None. Any value is accepted and set as     |
| (``validT``)               | tag, property name is ignored              |
+----------------------------+--------------------------------------------+
| Short string of a value    | Abbreviation of the tag                    |
| (``short``)                | (:mconfig:`tag_abbrev`)                    |
+----------------------------+--------------------------------------------+
| Color of a value           | Color of the tag (:mconfig:`colors`)       |
| (``color``)                |                                            |
+----------------------------+--------------------------------------------+
| Color applied on module    | Tag whose name is colored rather than the  |
| name or on short string    | module name (:mconfig:`tag_color_name`)    |
| (``full_color``)           |                                            |
+----------------------------+--------------------------------------------+
| Description of a value     | None. Tag name is the description reported |
| (``doc``)                  | in the output key                          |
+----------------------------+--------------------------------------------+

Some behaviors differ from Lmod as a consequence:

* A property has a single value on Lmod: setting it again replaces the
  previous value. Tags add up on Modules: a modulefile that sets the same
  property twice gets both values as tags.
* A value made of several elements separated by a colon character
  (``gpu:mic``) sets one tag per element. Lmod may define a specific display
  for such combination, whereas each tag is reported on its own.
* An unknown property name or value is not an error.
* ``sticky`` value of the ``lmod`` property corresponds to the ``sticky`` tag
  of Modules, which has the same effect.

The properties file also designates the spider cache directories of Lmod.
This has no counterpart: module cache files of Modules are stored in the
modulepath directories.

Implementation stages
---------------------

Lua modulefile support is introduced in stages:

1. The initial implementation provides the Lua functions that Lmod supports,
   for modulefiles and for modulercs, and nothing more. It is released in
   Modules 5.8.
2. Feedback from sites using it on their existing Lua modulefiles is expected
   to reveal cases that were not identified during the initial
   implementation. The feature is stabilized against them.
3. Once stabilized, new Lua functions are added to cover the Tcl modulefile
   and modulerc commands that have no Lmod equivalent (``variant``,
   ``module-tag``, ``module-warn``, ``modulepath-label``, etc).

Until the last stage, a feature of Modules that has no Lmod function is not
reachable from a Lua file: a modulefile or an rc file that needs it is
written in Tcl. Functions added at the last stage are not known by Lmod, so
a file that uses them cannot be shared with it anymore.

Installation
------------

Options
^^^^^^^

The following options are added. Their name follows the options that exist
for the Tcl linter:

+------------------------+-------------------------------+----------------+
| Purpose                | Installation option           | Configuration  |
|                        |                               | option         |
+========================+===============================+================+
| Lua interpreter        | ``--with-lua``                | ``lua_interp`` |
| program                |                               |                |
+------------------------+-------------------------------+----------------+
| Lua linter program     | ``--with-lua-linter``         | ``lua_linter`` |
+------------------------+-------------------------------+----------------+
| Lua linter options     | ``--with-lua-linter-opts``    | ``lua_linter`` |
+------------------------+-------------------------------+----------------+
| Installation of the    | ``--enable-luacheck-addons``  |                |
| luacheck configuration |                               |                |
| files                  |                               |                |
+------------------------+-------------------------------+----------------+
| Location of the        | ``--luacheckdatadir``         |                |
| luacheck configuration |                               |                |
| files                  |                               |                |
+------------------------+-------------------------------+----------------+

Each configuration option is also set through its environment variable
(``MODULES_LUA_INTERP`` and ``MODULES_LUA_LINTER``).

``configure`` script looks for a ``lua`` program by default. If none is found
or if its version is not supported, a warning is printed and installation
continues: Lua interpreter can be installed or designated afterward. The
``posix`` library is checked the same way.

Packaging
^^^^^^^^^

Lua interpreter and the ``posix`` and ``lfs`` libraries are not required to
install or run Modules. In the RPM package they are declared as weak
dependencies, to get them installed by default without forcing them on sites
that only use Tcl modulefiles. luacheck is not a dependency, like Nagelfar.

Supported platforms
^^^^^^^^^^^^^^^^^^^

Lua modulefile support relies on the ``posix`` library, thus on a Unix-like
system. It is not available on a native Windows installation
(``--enable-windows-support``), where the Lua interpreter is considered as a
program that cannot be run: Lua files are located but an error is raised when
one of them has to be evaluated.

Documentation
^^^^^^^^^^^^^

Lua modulefile functions are documented in a dedicated manual page named
:manpage:`modulefile-lua(5)`, beside the :manpage:`modulefile(5)` page that
describes the Tcl commands. Its name starts with ``modulefile`` to be listed
next to this existing page. It contains:

* The supported modulefile and modulerc functions, with the Tcl command each
  of them corresponds to
* The differences with the Lmod implementation, in two separate lists: what
  is not supported and what is done differently
* How to port the site customization of Lmod: hook functions and properties
  file
* How to write a Lua modulefile that copes with both implementations: how to
  identify the tool and its version, and how to test the level of Lmod
  functions supported (see `Identifying the module tool`_)

The `Differences with Lmod`_ section of this document is the source of these
two lists.

Linting Lua modulefiles and modulercs
-------------------------------------

:subcmd:`lint` sub-command checks Lua modulefiles and modulercs like it checks
the Tcl ones (see :ref:`lint-sub-command`). Selection of the files to lint is
unchanged: Lua files are found among the modulefiles and modulercs that the
sub-command already collects, whether it is called with or without arguments.

Kind of file
^^^^^^^^^^^^

Language and kind of each selected file determine how it is linted:

* A file is a Lua file if its name ends with ``.lua`` or if it is a
  ``default`` symbolic link that targets such file. It is a Tcl file
  otherwise.
* A Lua file is a global rc file if its path corresponds to a global or user
  rc file location.
* It is a modulerc if its name is :file:`.modulerc.lua`.
* It is a modulefile otherwise.

Module cache files are Tcl files whatever the language of the files they
record. They are still linted with the Tcl linter, whose syntax database for
cache files is extended with the ``lua-modulefile-content`` and
``lua-modulerc-content`` commands. Lua code recorded in a cache file is not
linted through the cache file but through the Lua file it comes from.

Configuration
^^^^^^^^^^^^^

Lua files are checked by an external linter program that performs a static
analysis of their code, as done for Tcl files. Lua files are not evaluated nor
transmitted to the Lua interpreter that evaluates modulefiles.

A configuration option defines the Lua linter program to use and its options,
like :mconfig:`tcl_linter` does for Tcl files:

* `luacheck`_ is the default
* Installation options help to change the linter program and its options at
  installation time
* ``configure`` script checks that the program exists. A warning is printed
  if it is not found, not an error, as the linter can be installed later-on

Tcl linter and Lua linter are independent. :subcmd:`lint` sub-command
currently raises an error if no Tcl linter is configured. This error is now
only raised when a Tcl file has to be linted. The same way, an error is raised
when a Lua file has to be linted and no Lua linter is configured.

luacheck linting
^^^^^^^^^^^^^^^^

luacheck needs to know the functions that are available to modulefiles and
modulercs. It would otherwise report every Lmod function as an undefined
variable. This is the counterpart of the Nagelfar syntax databases installed
to lint Tcl modulefiles.

luacheck configuration files are installed for this purpose, one per kind of
Lua file. Each of them defines a set of standard globals describing the
functions and variables the corresponding evaluation environment provides,
and selects it in addition to the standard globals of Lua:

* Modulefile: Lmod modulefile functions and helper functions
* Modulerc and global rc: Lmod modulerc functions and helper functions

An installation option controls whether these files are installed, and another
one where they are installed, like for the Nagelfar addons.

When the configured linter is luacheck, the following is added to its command
line:

* The configuration file that corresponds to the kind of the linted file.
  Designating a configuration file also prevents luacheck from looking for
  such file in the current directory, which makes the result independent of
  where the :command:`module` command is run.
* Options to get a plain output with warning codes and without colors, to
  parse it reliably.

These configuration files accept the globals of every Lua version, as
modulefiles are written for the Lua version of the site. They do not check
line length, which is a matter of style.

The list of functions described in these configuration files has to match the
functions that :file:`mfinterp.lua` actually provides. Fixtures of the
testsuite call every Lua modulefile and modulerc function: they are evaluated
without error and linted without any undefined variable reported.

luacheck only accepts a first line starting with a ``#`` character if it is a
shebang line (``#!``), whereas Lua interpreter ignores any first line starting
with ``#``. For a file starting with such line that is not a shebang, content
is passed to luacheck on its standard input with this first line blanked, and
file name is given with the ``--filename`` option. luacheck would otherwise
report a syntax error on a file that the Lua interpreter accepts.

Exit code of luacheck tells if warnings (1) or errors (2) have been found.
These exit codes are not an execution failure of the linter, unlike the higher
exit codes it returns on a fatal error (unreadable file, wrong option).

Report output
^^^^^^^^^^^^^

Messages are reported like for Tcl files, under a ``Linting <modulefile>``
message block and with the ``<SEVERITY> line <line_number>: message``
structure.

* luacheck messages are parsed to extract line number, code and message.
  Messages whose code starts with ``E`` (syntax errors) are reported as
  ``ERROR`` and those whose code starts with ``W`` as ``WARNING``.
* Output of another Lua linter is reported as-is.

Verbosity levels and exit code of the sub-command follow the same rules than
for Tcl files.

.. _luacheck: https://github.com/lunarmodules/luacheck

Testsuite
---------

Lua modulefile support is tested at two levels: Lua code is linted and the
whole feature is tested through :file:`modulecmd.tcl`. Coverage of the Lua
code is measured over these integration tests.

Like for Tcl code, there is no test of individual Lua functions. Everything is
tested through :file:`modulecmd.tcl`, which is how the Lua code is used. No
constraint is this way put on :file:`mfinterp.lua` to make its internal
functions reachable by a test tool.

Tests that need a Lua interpreter or a Lua test tool are skipped when this
program or tool is not available. The testsuite can this way still be run on
systems where Lua is not installed.

Integration tests
^^^^^^^^^^^^^^^^^

Evaluation of Lua modulefiles and modulercs by :file:`modulecmd.tcl` is tested
in the ``modules`` testsuite, like any other feature. These tests are the
only ones that exercise both ends of the bridge together.

A :file:`testsuite/modules.55-lua` directory is added to this testsuite. It
holds the tests dedicated to the Lua modulefile and modulerc functions, with
test files organized per kind of function:

* Environment functions (``setenv``, ``prepend_path``, ``pushenv``, etc)
* Shell functions (``set_alias``, ``set_shell_function``, ``complete``,
  ``source_sh``, ``execute``)
* Module dependency functions (``load``, ``depends_on``, ``prereq``,
  ``conflict``, ``family``, ``inherit``, etc)
* Module information functions (``whatis``, ``help``, ``add_property``,
  ``extensions``)
* Query and introspection functions (``isloaded``, ``mode``,
  ``myModuleName``, ``hierarchyA``, etc)
* Message and evaluation control functions (``LmodMessage``, ``LmodError``,
  ``LmodBreak``, ``os.exit``)
* File and miscellaneous helper functions (``pathJoin``, ``isFile``,
  ``capture``, etc)
* Modulerc functions (``module_version``, ``module_alias``, ``hide``,
  ``forbid``, etc), including the conversion of each kind of Lua pattern
  item by ``hideRegex`` and ``forbidRegex``
* Bridge behaviors that are not tied to a specific function

Each function is tested in the evaluation modes where its behavior differs
(load, unload, display, help, whatis, scan, refresh) and with the ``modeA``
option when it supports it.

Functions handled by the Lua script alone have to return the same result as
on Lmod. Lmod is not required to run the testsuite: results expected by the
tests are fixed values. A maintainer script evaluates the same fixtures with
an Lmod installation and compares the results with these values. It is run
when such function is added or changed and when the reference Lmod version
is raised.

Existing sections of the ``modules`` testsuite are also extended, to cover the
existing features when Lua modulefiles or modulercs are found in modulepaths:

* Module location and name resolution (:file:`modules.20-locate`): precedence
  between Lua and Tcl files, default version, symbolic versions and aliases
  defined by Lua or Tcl modulercs on Lua modulefiles, modulepath and global
  rc files written in Lua, hide and forbid mechanisms applied to Lua
  modulefiles, Lua files with limited access
* Module cache (:file:`modules.30-cache`): build and use of cache files
  containing Lua files, same result obtained with and without cache, cache
  file built by an older version
* Modulefile commands and module handling (:file:`modules.50-cmds`):
  dependency handling, tags, variants and other mechanisms involving several
  modules when some of them are Lua modulefiles
* Scan evaluation and extra match search (:file:`modules.51-scan`)
* Collections (:file:`modules.61-coll`): save and restore of collections
  containing Lua modulefiles
* Sub-commands and configuration (:file:`modules.70-maint`): sub-commands
  that locate or evaluate modulefiles applied to Lua modulefiles
  (``display``, ``help``, ``test``, ``whatis``, ``apropos``, ``source``,
  ``path``, ``paths``, ``is-avail``, ``aliases``, etc), ``lint`` sub-command
  applied to Lua modulefiles and modulercs, and
  configuration options that designate the Lua interpreter and the Lua linter
* Deep modulefile directories (:file:`modules.80-deep`)
* Listing sub-commands (:file:`modules.90-avail`, :file:`modules.91-sort` and
  :file:`modules.92-spider`): Lua modulefiles reported under their module
  name by ``avail`` and ``spider`` in every output format

Lua fixtures are stored in dedicated modulepath directories of the testsuite.
They are not added to the existing fixture directories, as many existing tests
enumerate the whole content of these directories.

The following situations require specific attention in these tests:

* Precedence between Lua and Tcl files, for modulefiles and for each kind of
  modulerc (in modulepath directory, at modulepath root and global ones)
* Values that challenge message quoting in both directions: empty string,
  braces, backslash, newline, double quote, dollar and bracket characters,
  multi-byte characters
* Output produced by a modulefile or by a command it executes (``print``,
  ``io.write``, ``os.execute``), which must not disturb the bridge. Output of
  the modulefile code is reported in the message block of its module and
  follows the verbosity level.
* Lua library loaded with ``require`` that calls Lmod functions
* ``LUA_PATH`` and ``LUA_CPATH`` set to locations holding libraries that
  cannot be loaded, and variables put in quarantine
* Commands executed by a modulefile that rely on environment changes made
  earlier in this modulefile
* Nested evaluations mixing languages: Lua modulefile loading a Lua
  modulefile, loading a Tcl modulefile, and the other way round
* Errors: Lua syntax error, Lua runtime error, error raised by a Tcl command,
  whether caught or not with ``pcall``, error located in a modulefile with a
  long path
* Evaluation stop (``LmodBreak``, ``os.exit``) including when called through
  ``pcall``
* State isolation: a variable or a function defined by a modulefile is not
  visible from the next one evaluated
* Lua interpreter that cannot be run, that ends during an evaluation, that
  sends an unexpected message or that is started with ``LUA_INIT`` set. Fake
  Lua interpreter programs are used to produce the situations a regular Lua
  interpreter does not lead to.
* File starting with a ``#`` line

A basic evaluation of a Lua modulefile is also added to the ``install``
testsuite to check that the installed :file:`mfinterp.lua` is found.

Coverage
^^^^^^^^

Coverage of the Lua code is measured with `luacov`_ when the testsuite is run
in coverage mode (``COVERAGE=y``), over the integration tests.

luacov is enabled by loading it when the Lua interpreter starts (``-l`` option
of the Lua interpreter). Nothing is added in :file:`mfinterp.lua` for this:
the configuration option that designates the Lua interpreter is set to a
wrapper script of the testsuite. This wrapper runs the Lua interpreter with
luacov loaded. ``LUA_INIT`` variable cannot be used for this purpose as it is
withdrawn when the Lua interpreter is started.

luacov saves the statistics it has collected when the Lua interpreter exits.
Lua script thus ends normally when its *stdin* is closed. Statistics are lost
if the Lua process is ended by a signal.

A luacov configuration file restricts the collection to the Lua code of
Modules and sets where statistics are saved. As the Lua interpreter is started
by many :file:`modulecmd.tcl` runs, possibly at the same time when the
testsuite is run in parallel, each Lua process saves its statistics in a file
of its own, named after its process identifier. These files are merged at the
end of the testsuite run, like done for the Tcl coverage logs. luacov does not
provide a command for this, so a small script based on its statistics module
sums the hit counts of all files.

luacov measures line coverage: a line is covered as soon as one statement of
this line is executed. Lua code is thus written with one statement per line
for the coverage result to be meaningful.

Once statistics are merged, luacov report is generated. It shows the Lua code
with the hit count of each line, which is the counterpart of the
:file:`tcl/*.tcl_m` files to spot the lines that are not covered. Statistics
are also converted into a format accepted by the coverage service used by the
continuous integration, as done for Tcl coverage results. Reporters bundled
with luacov do not produce such format, so a conversion script or an
additional reporter is needed.

.. _luacov: https://github.com/lunarmodules/luacov

Lint
^^^^

The ``lint`` testsuite is extended to check the files of the :file:`lua`
directory with `luacheck`_, like shell scripts are checked with ShellCheck.
No warning is expected.

A luacheck configuration file is added at the root of the repository:

* Standard globals are limited to those of the oldest supported Lua version
  (``lua53`` standard). Use of a function that only exists in a newer version
  is this way reported.
* Maximal line length is set to 78 characters, like for Tcl code.
* Global variables or functions set on purpose are declared.

luacheck has its own parser, which accepts the syntax of every Lua version. A
syntax introduced after Lua 5.3 (variable attributes for instance) is thus not
reported. Running the integration tests with the oldest supported Lua version
covers this.

The :file:`lua` directory is added to the directories the ``lint`` testsuite
scans to verify that every script file is either linted or explicitly
skipped.

Spell checks run by the git hooks of the repository apply to the Lua code.
Names of some Lmod functions it defines, like the version modifier functions,
are taken for misspellings by codespell: they are added to the words this tool
ignores.

Continuous integration
^^^^^^^^^^^^^^^^^^^^^^

Lua interpreter, ``posix`` and ``lfs`` libraries, luacov and luacheck are
installed in the continuous integration jobs. Integration tests are run with
the Lua interpreter of the system, which is Lua 5.4 on recent systems. They
are also run with the oldest supported versions of Lua and of its libraries,
in a job based on an Enterprise Linux 8 system.

Performance benchmark
^^^^^^^^^^^^^^^^^^^^^

:file:`script/mb` benchmark tool is extended to measure the evaluation of Lua
modulefiles and compare it against the evaluation of Tcl modulefiles. New
tests are added, each of them mimicking an existing test with the same
modulefiles written in Lua:

* ``load2_lua``: like ``load2``, load a module with more than a hundred
  dependencies
* ``list2_lua``: like ``list2``, list these modules once loaded
* ``purge_lua``: like ``purge``, unload all these modules
* ``unload_lua``: like ``unload``, unload a module and its dependencies

Lua modulefiles used by these tests are the counterpart of the Tcl
modulefiles of the existing tests. They are stored in dedicated modulepath
directories: if stored along the Tcl modulefiles they would take precedence
over them and change what the existing tests measure. Loaded environment of
``list2_lua``, ``purge_lua`` and ``unload_lua`` tests is recorded in
:file:`testsuite/mb` directory like for the other tests.

:file:`script/mb` builds the :file:`modulecmd.tcl` of each version it
compares. It also builds :file:`mfinterp.lua` for the versions that provide
it, as this script is located next to the :file:`modulecmd.tcl` that is run.

These tests are skipped for the versions of Modules that do not support Lua
modulefiles. ``load2_lua``, ``list2_lua`` and ``purge_lua`` are part of the
tests that can be compared with Lmod: it evaluates there Lua modulefiles
natively, whereas it has to translate the Tcl modulefiles of the ``load2``,
``list2`` and ``purge`` tests.

Comparing the result of each Lua test with the test it mimics gives the
overhead of Lua modulefiles. This comparison is checked when the bridge is
changed, to catch a cost that grows with the number of loaded modules.

Modulefiles of these tests mostly declare requirements and set few
environment variables. A cost that grows with the size of the environment is
not visible on them. It is caught by the integration tests instead: one of
them checks, from the messages reported at the ``debug2`` level, that a reply
never carries the value of an environment variable.

Differences with Lmod
---------------------

This section lists the differences spotted between a Lua modulefile evaluated
with Lmod and Modules. Most differences comes from the translation of the Lua
modulefile commands into Tcl modulefile commands: the former may have
different behavior than the latter.

* ``os.exit`` is evaluated as the Tcl ``exit`` command that does not return
  an exit code value equal to its argument.
* When unloading, the value set by ``setenv`` stays visible through
  ``os.getenv`` in the rest of the modulefile, as done for Tcl modulefiles.
  Lmod unsets the variable right away.
* Displaying a Lua modulefile reports the Tcl modulefile commands it has been
  translated into, not its Lua function calls.
* Exclusive lower bound of version modifier functions (``<`` character after
  version) is not supported. Exclusive upper bound (``<`` character before
  version) is supported when the last element of the version is a number.
* Inclusive upper bound of version modifier functions includes the versions
  that extend it: ``between("foo", "2.7", "3.0")`` matches ``foo/3.0.1``
  whereas Lmod stops at ``foo/3.0``.
* Automatic load of requirements depends on the automated module handling
  mode, not on the use of ``depends_on`` rather than ``prereq``.
* ``mode`` function returns ``spider`` in ``scan`` evaluation mode. This mode
  is close to the ``spider`` mode of Lmod but not identical: Lmod uses it to
  build its spider cache, whereas Modules uses it when a search needs
  information defined in modulefiles. ``mode`` function returns ``test`` in
  ``test`` evaluation mode, that does not exist on Lmod.
* ``load``, ``try_load``, ``load_any`` and ``always_load`` do not reload a
  module that is already loaded, and do not replace a loaded module of the
  same name unless Modules is configured to (see `Loading a module that is
  already loaded`_).
* ``mgrload`` evaluates the module load requests of the modulefile it loads
  and does not preserve how the module was initially loaded.
* Tables returned by ``loaded_modules`` only hold the name, version,
  modulefile and load order of loaded modules. Other properties are empty.
* ``prepend_path`` and ``append_path`` do not move a path entry that is
  already part of the variable, they count one more reference to it. Lmod
  moves such entry at the beginning or at the end of the variable, unless
  configured to follow this rule.
* Loading a module that is member of the same ``family`` than a loaded module
  is an error, unless Modules is configured to unload conflicting modules.
  Lmod swaps the two modules by default.
* ``unload`` does nothing when the modulefile is unloaded.
* Modules loaded from a modulepath enabled by another module stay loaded when
  this other module is unloaded or switched, unless they declare it as a
  requirement (see `Software hierarchy`_).
* Variables set by the initialization of Lmod (``MODULEPATH_ROOT``,
  ``LMOD_SYSTEM_NAME``, etc) are not defined.
* ``LmodVersion`` function and ``LMOD_VERSION`` variables give the version of
  Lmod whose modulefile functions are supported, not the version of a
  running Lmod. ``ModuleTool`` variable is set to ``Modules``.
* ``pushenv`` called with a ``false`` value sets the variable to an empty
  string. Lmod unsets it.
* On ``whatis`` and ``help`` modes, path functions update the environment
  variables for the rest of the modulefile, like ``setenv`` does. Lmod only
  applies ``setenv`` and ``pushenv`` on these modes.
* ``print`` and ``io.stdout`` output is reported on *stderr* with the other
  messages of the module. It is not evaluated by the shell. ``execute``
  function is the way to run a command in the shell.
* Global variables and functions defined by a modulefile are not visible from
  the modulefiles evaluated afterward. On Lmod all modulefiles share the same
  environment, so a global variable set by one modulefile can be read by the
  following ones. Code shared between modulefiles has to be placed in a Lua
  library loaded with ``require``.
* ``help`` and ``whatis`` text is output as is, without the markdown
  rendering made by Lmod.
* Shell functions defined with ``set_shell_function`` are always exported to
  the sub-shells. On Lmod they are exported only if ``export_shell_function``
  is called.
* ``hideRegex`` and ``forbidRegex`` do not support the ``%b`` and ``%f``
  pattern items, position captures and upper case classes within a set.
* ``module_virtual`` does not hide the module that implements the virtual
  name. ``hide_version`` has to be called on this module to get it hidden as
  on Lmod.
* ``myConfig`` only knows the ``username`` and ``usergroups`` keys.
* When no :file:`.modulerc.lua` file exists in a directory, :file:`.version`
  file is evaluated in addition to :file:`.modulerc` file. Lmod only
  evaluates the latter.
* Rc files of a directory are evaluated even if this directory contains a
  ``default`` symbolic link. Lmod ignores them in this case.
* Hook functions registered in :file:`SitePackage.lua` are not run. Hooks
  are defined in :file:`siteconfig.tcl` (see `Hooks`_).
* Site-specific functions registered with ``sandbox_registration`` in
  :file:`SitePackage.lua` are not available to modulefiles.
* Properties file (:file:`lmodrc.lua`) is not read. Values set with
  ``add_property`` are tags, configured with the tag options of Modules (see
  `Properties file`_). They are not validated, and several values set for
  the same property add up instead of replacing each other.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
