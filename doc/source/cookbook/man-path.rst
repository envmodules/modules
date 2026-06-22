.. _man-path:

Handle man pages search path
============================

Man pages (manual pages), read with :command:`man` command, are stored in a
structured directory hierarchy under predefined locations. They are typically
stored within ``/usr/share/man`` and software-specific *man* directories.

:command:`man` searches for man pages the following way:

* if :envvar:`MANPATH` environment variable is set, man pages are only
  searched in the directories specified in it
* if :envvar:`MANPATH` is not set, :command:`man` determines the hierarchy
  search path using information gained from the ``man-db`` configuration

See `SEARCH PATH section`_ of ``manpath(5)`` man page to learn how ``man-db``
computes the default search path.

.. _SEARCH PATH section: https://man7.org/linux/man-pages/man5/manpath.5.html#SEARCH_PATH

The :command:`manpath` command can be used to observe the currently active
search path:

.. parsed-literal::

    :ps:`$` manpath
    /usr/local/share/man:/usr/share/man
    :ps:`$` export MANPATH=/usr/share/man
    :ps:`$` manpath
    manpath: warning: $MANPATH set, ignoring /etc/man_db.conf
    /usr/share/man

Systems usually do not define :envvar:`MANPATH` by default and rely on
``man-db`` configuration. On such systems, if a modulefile adds a specific
man page directory to :envvar:`MANPATH`, :command:`man` will not be able to
find system regular man pages anymore.

.. parsed-literal::

    :ps:`$` man --where ls
    /usr/share/man/man1/ls.1.gz
    :ps:`$` module show foo/1.0
    -------------------------------------------------------------------
    :sgrhi:`/path/to/modulefiles/foo/1.0`:

    :sgrcm:`append-path`     PATH /path/to/foo-1.0/bin
    :sgrcm:`append-path`     MANPATH /path/to/foo-1.0/man
    -------------------------------------------------------------------
    :ps:`$` module load foo/1.0
    :ps:`$` man --where ls
    No manual entry for ls

To retain access to the system man pages when modulefiles modify the
:envvar:`MANPATH`, the default search paths must be added into
:envvar:`MANPATH`. This can be done by appending a colon (``:``) to the end of
the :envvar:`MANPATH` value, which instructs the system to include its default
man page directories.

.. parsed-literal::

    :ps:`$` manpath
    manpath: warning: $MANPATH set, ignoring /etc/man_db.conf
    /path/to/foo-1.0/man
    :ps:`$` man --where ls
    No manual entry for ls
    :ps:`$` module append-path MANPATH :
    :ps:`$` man --where ls
    /usr/share/man/man1/ls.1.gz

If your modulefiles modify :envvar:`MANPATH`, it is recommended to initialize
this environment variable with a single colon (``:``) during Modules startup.

To do this on Modules 5.7 or any newer version, add the following line to the
``initrc`` configuration file (typically located in
``/etc/environment-modules``):

.. code-block:: tcl

   module config init_envvars MANPATH=

With this configuration, the ``MANPATH`` environment variable will be
initialized to an empty string right before its first modification. As a
result a leading or finishing colon character will be set the first time a
path entry is added to ``MANPATH``.

With older versions of Modules, add the following line to the ``initrc``
configuration file:

.. code-block:: tcl

   append-path MANPATH :

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
