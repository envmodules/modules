.. _module-cache:

Module cache
============

Objective is to consolidate available module information in a few number of
files in order to process these files when doing global module queries like
done by :subcmd:`avail`, :subcmd:`spider` or :subcmd:`whatis` sub-commands
instead of walking through the whole modulepath directories to compute this
information.

With cache files, it is expected to have lesser IO load and more efficiently
handle environments with thousands modulefiles stored in a parallel
filesystem.

How to store cache
------------------

Module cache will be a file aggregating available module information. Module
are organized into modulepaths that are enabled in user environment. Goal is
to have one module cache file per modulepath. This file will be stored under
the modulepath root with the ``.modulecache`` file name.

Depending on modulepath ownership, modulepath may or may not have a cache file
built. It seems more efficient to save cache on a per-modulepath basis as a
user may enable diverse modulepaths, some of them not maintained by the admins
of the machine they are running on.

Having a central system cache may miss some user-managed modulepaths.

Having a per-user cache file does not seem a good idea. If built for the user,
a lot more information may be pre-processed: dynamic information from the
modulerc files for instance may be processed at cache file creation, not when
using the cache file. But it cannot be expected from the user to build its
cache and keep it up to date. Having the cache on the user side can lead
to additional issue with users complaining to the support that they cannot
find a given module, but due to an outdated cache file.

In definitive, there will be one cache file per modulepath directory.

Cache content
-------------

As cache files should be used instead of walking through modulepath directory
to search for valid modulercs and modulefiles. Cache file should contain
everything to be autonomous to proceed ``avail``, ``spider`` or ``whatis``
queries.

Yet module search can be very dynamic as things set for instance in modulerc
files may dynamically produce new modulefiles or define properties specific to
some users or groups.

So the produced cache file cannot be the static view generated for the user
who has built the cache file. Thus dynamic shaping is preserved by storing
scripts and commands in the cache file.

Modulerc files may be highly dynamic so their full content is purely saved
into the cache file. An entry is set for each valid modulerc file. Same goes
for modulefiles as some conditional structure in their code can dynamically
change dependency, whatis or other definitions.

It is expected that modulefile will be evaluated on ``avail``, ``spider`` or
``whatis`` commands for complex queries. So for such use case it is important
to have modulefile content cached.

Thus by reading the cache file, in one IO the content of all the modulerc and
modulefiles of the modulepath will be fetched.

Goal is to record in cache file every information obtained as a result of
``findModules`` procedure. Thus cache file contains modulefile modification
times, which is reported on ``--long`` output. Modulefile validity check
result is also recorded if modulefile is not valid. Modulerc validity check
is not recorded as it is not an information produced by ``findModules``.

Note: modulercs and modulefiles are not tested when generating cache file to
see if they are valid, if their code is correctly executed. Their bare content
is recorded. Same result is obtained this way whether a cache file is used or
not.

Cache format
------------

Goal is to make the cache file a Tcl script, like modulefiles. It will not
be exactly a modulefile as specific commands will be setup to evaluate cache
file and cache file will not make use of modulefile commands. See `Cache
evaluation`_ section for details on how a cache file is evaluated.

Cache file starts with a ``#%Module`` string like modulefiles. A version
number is appended next to these first characters (for instance
``%Module5.3``). See `Cache validity`_ section for details on the cache file
*prefix* string.

Modulefile content in modulepath is defined in cache with the
``modulefile-content`` command. Which takes in this order:

* relative file path
* file last modification date (as a Unix epoch time)
* file module header
* file body content.

For instance:

* ``modulefile-content foo/1.0 1234567890 #%Module {body}``
* or ``modulefile-content {foo/w s} 1234567890 #%Module5.2 {body}``

Similar command for modulerc: ``modulerc-content`` which accepts following
syntax:

* relative file path
* file module header
* file body content.

For instance: ``modulerc-content foo/.modulerc #%Module {body}``. Modification
time is not needed for modulerc as this information is not reported on an
``avail``, ``spider`` sub-commands in long mode.

Every modulercs and modulefiles file contained in modulepath are recorded
in cache with ``modulerc-content`` or ``modulefile-content`` command.
Modulefiles whose name start with a dot character are also recorded in cache.

Invalid modulefiles are recorded in cache file through ``modulefile-invalid``
command rather ``modulefile-content``. It accepts following arguments:

* relative file path
* invalidity kind
* error message

For instance: ``modulefile-invalid foo/2.0 invalid {Magic cookie '#%Module'
missing}``

Files or directories that have limited access are recorded with specific
commands:

* ``limited-access-file foo/1.0``
* ``limited-access-directory foo``

Limited access means for a file that it cannot be read by user that builds
cache or other users. For a directory it means that it cannot be either read
or searched by user that builds cache or other users.

A modulefile or a modulerc is not recorded with ``modulefile-content`` or
``modulerc-content`` if file or one of its parent directory has limited
access. This way only content that can be read by everyone is recorded into
cache file. Sensitive information are excluded from cache file.

Note: a cache file generated by a privileged user (which has access to every
thing) and a cache file generated by a less privileged user will be the same
as limited-access information will not be included in cache file.

Files or directories recorded as limited access will need to be tested (and
walked down for directories) when cache file will be evaluated. It is
important to distinguish files from directories to save some file stat test
to determine if an element is a directory when limited access elements will be
tested. No need for files to distinguish modulefile from modulerc as this
difference is visible with file name.

Note: Limited access tests are skipped on Windows platform as Unix-style file
permission cannot be tested there.

Recording full modulefile content or subset of elements
-------------------------------------------------------

It was initially drafted that only a subset of element of modulefiles would be
recorded in cache file, to reduce size of this file and reduce its evaluation
time.

Recording full modulefile content is in the end preferred as:

* this solution is simpler to implement
* cache file size is not too big in the end (~ hundreds of KB for a thousand
  of modulefiles)
* evaluation time of large cache file is acceptable (time taken to evaluate
  cannot be noticed by user)
* simpler to understand and manage for sites

Producing a cache entry for a modulefile with only a subset of commands
recorded (like variant or requirement) is only feasible for modulefiles not
using conditionals or specific evaluation scheme. Recording full content will
work in any scenario whereas recording a subset limits cache usage. Moreover
it is hard to determine, depending of the modulefile set, where cache can be
used or not if only a subset of elements is recorded.

Cache validity
--------------

From Modules 5.3 to 5.5
^^^^^^^^^^^^^^^^^^^^^^^

Cache file header indicates a Modules version number. It corresponds to the
Modules version:

* the cache file has been built with
* the cache file is compatible with

It seems reasonable to ask for a cache file update every time Modules is
upgraded to a newer minor version (for instance from 5.3 to 5.4):

* it is simpler to understand for staff and user when the cache is taken into
  account, when it is ignored
* better to ensure cache file is accurate for the Modules version as modulerc
  and modulefile commands may evolve from one version to another

Starting Modules 5.6
^^^^^^^^^^^^^^^^^^^^

Approach to cache validity is changed on Modules 5.6 to cover use cases where
different Modules installation uses the same set of modulepaths. This is for
instance the case when a service provides modulepaths with cache files in them
and just requires a minimal version of Modules. Or on a computing center, when
the same modulepaths are used by different supercomputers which may use
different version of Modules at some point in time.

With this change the cache file header still indicates a Modules version
number. But this version number now corresponds to the minimal Modules version
able to use this cache file.

With such change, backward compatibility is expected on module cache Tcl
commands. Addition of new commands will lead to an increase of the minimal
version required. Argument change to existing command is not possible, only
the introduction of optional argument will be ok (with increase of minimal
version required).

When generating cache file, minimal version required is set back to ``5.3`` as
no change occurred on the cache file format since the introduction of the
cache feature.

As minimal Modules version check code is the same for cache file than for
modulefile since the introduction of the cache feature, cache file has always
been taken into account as soon as the Modules version matches the minimal
requirement.

Cache usage
-----------

Any time a modulepath directory is opened to get its content, the module cache
file will be used instead if available.

Modulepath content analysis is performed by ``findModules`` procedures. So
any sub-command calling it (directly or through ``getModules`` or
``getPathToModule``) will use the cache file. It corresponds to the following
sub-commands:

* lint
* paths
* search
* whatis
* aliases
* avail
* spider
* switch
* restore
* save
* display
* path
* source
* load
* test
* edit
* help

It may also occur during other sub-commands that evaluates modulefiles using
the ``is-avail`` command: like unload or refresh.

Cache files are ignored if :mconfig:`ignore_cache` configuration option is
enabled. This option can also be enabled just for one execution with the
:option:`--ignore-cache` command line option.

Cache files are also ignored if the currently running top-level sub-command
is part of the :mconfig:`ignore_cache_subcmds` configuration option. On
setup with a very large number of modulefiles, resulting in cache files of
several megabytes, evaluating the whole cache file may take longer for a
sub-command targeting specific modules (like :subcmd:`load`) than walking
through the modulepath directory to find these modules. This option helps
to skip cache use for such sub-commands while preserving cache benefit on
the others (like :subcmd:`avail`).

Sub-command name aliases resolve to their target sub-command prior the
comparison against the option value. The :command:`ml` command used without
a sub-command name translates to the :subcmd:`load` or :subcmd:`unload`
sub-command it is currently processing, so ``ml`` is not a value to set in
this option.

Cache files are ignored if cache expiry mechanism is enabled through the
:mconfig:`cache_expiry_secs` configuration option. When this option is set to
0, it means a cache file never expires. This is the default behavior. If set
to something else, cache file is expired if its last modification time is
older than the number of seconds defined in ``cache_expiry_secs``. Option
value is an integer between 1 and 31536000, which is the number of seconds
during 1 year.

Is there an impact at evaluating the full cache file rather making a directory
walk-through to find a module? Cache file is fully read, but not all the files
described in it are evaluated. Just those corresponding to the search, like it
is done when walking modulepath directory and evaluating only the modulerc
files corresponding to the query. So results between using cache file or not
should be the same: compared to a search without cache, no extra modulefile or
modulerc evaluation will be performed when a cache file is used.

As cache is recorded with both ``mcookie_check`` and ``mcookie_version_check``
options enabled, these two options are not honored (if disabled) when a cache
file is used. They are primarily useful to skip I/O tests when walking through
the content of a modulepath directory. As these I/O tests are done during the
cache build process, the options are useless when using cache files.

When cache file magic cookie defines a Modules version greater than the
current one, the cache file is silently ignored. Raisin error is not useful as
different version of Modules may be deployed in the same site environment.

When cache file is not in sync
------------------------------

Files or directories are freely available through cache when used even if
after cache being built:

* their access is limited
* they are deleted
* their content changes and is not anymore valid

When files or directories have their access limited prior building cache, but
afterward these access limitations are lifted. These elements will require
an access test to check if they are available. This test will always be
successful as element accesses are not anymore limited.

If files or directories do not exist when cache is built, they will not be
found when cache is used.

If modulefile is recorded in cache as invalid, it will stay invalid if cache
is used even the modulefile is fixed. Cache need to be regenerated.

Read/write performances
-----------------------

:mconfig:`cache_buffer_bytes` configuration option defines size of the buffer
when reading or writing cache files.

With a bigger buffer, fewer read or write system calls are needed to read or
write cache file. On busy storage systems it can improve I/O performances.

Cache evaluation
----------------

A Tcl sub-interpreter is created to analyze cache files. This sub-interp is
setup to evaluate cache file-specific commands, like ``modulefile-content``.

When evaluated, ``modulefile-content``, ``modulerc-content`` and
``modulefile-invalid`` commands populate the read cache structure of modulerc
and modulefiles. This way when the modulefile for instance need to be read,
its content is already found in memory cache structure. It corresponds to the
following global variables:

* ``::g_modfileContent``
* ``::g_fileMtime`` (only for valid modulefile)
* ``::g_modfileValid`` (only for modulefile, valid or not)

In addition a ``::g_cacheModpath`` array is filled with an entry dedicated for
each modulepath. The content of this entry mimics the result list returned by
``findModules`` procedures with information for the whole content of the
modulepath.

Limited access files and directories described in cache by
``limited-access-file`` and ``limited-access-directory`` commands populate
specific structures to indicate some entries in modulepath have to be tested
(and walked down for directories) to determine if they are available to
current user:

* ``g_cacheFLimitedModpath``
* ``g_cacheDLimitedModpath``

These two structures are arrays with one entry per cached modulepath. Limited
access entries are tested if they match search query. Test is done through
``findModulesFromDirsAndFiles`` procedure which corresponds to the walk down
code extracted from ``findModules``.

This specific interpreter is reused between different cache file evaluations.
As for modulefile interpreter, a consistency check is performed before each
reuse to test that the cache file-specific commands have not be rewritten
during previous cache file evaluation.

Cache file evaluation is tracked to avoid evaluating twice the same cache
file.

Cache evaluation stops if an erroneous command or syntax is encountered. Like
for erroneous modulerc, error is not reported during ``avail``, ``spider`` or
``whatis`` commands unless if ran in debug mode. Error is reporting during a
``load`` evaluation. Cache evaluation is considered failed if there is an
error in the cache file, thus a non-cache module search will occur instead of
relying on cache module listing. However descriptions of modulefile and
modulerc evaluated in cache prior the error occurs are retained.

cachebuild sub-command
----------------------

:subcmd:`cachebuild` sub-command creates a module cache file in modulepaths.
Without arguments, it attempts to create cache in every enabled modulepaths
where running user has the right to write. If arguments are provided, cache
is build in the directories pointed by these arguments.

General properties:

* Shortcut name: none
* Accepted option: none
* Expected number of argument: 0 to N
* Accept boolean variant specification: no
* Parse module version specification: no
* Fully read modulefile when checking validity: yes
* Sub-command only called from top level: yes
* Lead to modulefile evaluation: yes (``cachebuild``)

An error is returned for each specified directories where current user has no
write access.

An error is returned if a modulefile or a modulerc cannot be read. This error
ends cache content generation for current modulepath. Build continues with
next modulepath after this error.

Modulepaths where current user has no write rights are skipped and reported
with a warning notice.

Reports a ``Creating <modulepath>`` block header message for each cache file
created or updated. This report is made when verbosity is set to ``normal``
or higher mode.

:mconfig:`mcookie_check` and :mconfig:`mcookie_version_check` options are both
enabled when recording cache. This is produced with exact same content whether
these options are enabled or not.

cacheclear sub-command
----------------------

:subcmd:`cacheclear` sub-command deletes all module cache file in enabled
modulepaths.

General properties:

* Shortcut name: none
* Accepted option: none
* Expected number of argument: 0
* Accept boolean variant specification: no
* Parse module version specification: no
* Fully read modulefile when checking validity: no
* Sub-command only called from top level: yes
* Lead to modulefile evaluation: no

Modulepaths where current user has no write rights on the modulepath directory
are skipped and reported with a warning notice.

Reports a ``Deleting <modulepath>`` block header message for each cache file
created or updated. This report is made when verbosity is set to ``normal``
or higher mode.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
