.. _CONTRIBUTING:

Contributing
============

Thank you for considering contributing to Modules! Modules is an open source
project. Questions, discussion, and contributions are welcome.

By contributing to this project, you agree to follow our `Code of conduct`_,
which ensures a respectful and inclusive environment for all contributors.
Please review it before participating in discussions or submitting
contributions.

.. _Code of conduct: https://github.com/envmodules/modules?tab=coc-ov-file#readme

This project also adheres to a :ref:`Technical charter<CHARTER>`, which
defines its governance model, decision-making process, and long-term vision.

Support questions
-----------------

Please use the `modules-interest mailing list`_
(``modules-interest@lists.sourceforge.net``) or the `Modules chat room`_
(``#modules:matrix.org``) for questions. Do not use the
issue tracker for this.

.. _modules-interest mailing list: https://sourceforge.net/projects/modules/lists/modules-interest
.. _Modules chat room: https://matrix.to/#/#modules:matrix.org

Asking for new features
-----------------------

Please submit your new feature wishes first to the `modules-interest mailing
list`_ or `Modules chat room`_. Discussion will help to clarify your needs and
sometimes the wanted feature may already be available.

Reporting issues
----------------

* Describe what you expected to happen.
* If possible, include a `minimal, complete, and verifiable example`_ to help
  us identify the issue.
* Describe what actually happened. Run the ``module`` command in ``--debug``
  mode and include all the debug output obtained in your report.
* Provide the current configuration and state of your Modules installation by
  running the ``module config --dump-state`` command.
* Provide the name and content of the modulefiles you try to manipulate.

.. _minimal, complete, and verifiable example: https://stackoverflow.com/help/mcve

If you find a security vulnerability, please refer to our `security policy`_
for guidelines on how to report such issues responsibly.

.. _security policy: https://github.com/envmodules/modules/security

.. _submitting-patches:

Submitting patches
------------------

* Whether your patch is supposed to solve a bug or add a new feature, please
  include tests. In case of a bug, explain clearly under which circumstances
  it happens and make sure the test fails without your patch.
* If you are not yet familiar with the ``git`` command and `GitHub`_, please
  read the `don't be afraid to commit`_ tutorial.

.. _GitHub: https://github.com/
.. _don't be afraid to commit: https://afraid-to-commit.readthedocs.io/en/latest/index.html

Start coding
~~~~~~~~~~~~

* Create a branch to identify the issue or feature you would like to work on
* Using your favorite editor, make your changes, `committing as you go`_.
* Comply to the `coding conventions of this project <coding-conventions_>`_.
* Your Tcl code has to be compatible with Tcl version 8.5 and above (see
  `Tcl 8.5 commands reference`_)
* Include tests that cover any code changes you make. Make sure the test fails
  without your patch.
* `Run the tests <running-the-tests_>`_ and `verify coverage <running-test-coverage_>`_.
* `Sign-off your commits <developer-certificate-of-origin_>`_.
* Push your commits to GitHub and `create a pull request`_.

.. _committing as you go: https://afraid-to-commit.readthedocs.io/en/latest/git/commandlinegit.html#commit-your-changes
.. _create a pull request: https://help.github.com/articles/creating-a-pull-request/
.. _Tcl 8.5 commands reference: https://www.tcl-lang.org/man/tcl8.5/TclCmd/contents.htm

Developer notes
~~~~~~~~~~~~~~~

See the :ref:`design` for recent feature specifications. Some development
howtos are also available:

* :ref:`add-new-sub-command`
* :ref:`add-new-config-option`

.. _running-the-tests:

Running the tests
~~~~~~~~~~~~~~~~~

Run the basic test suite with::

   make test

This only runs the tests for the current environment. `GitHub Actions`_ and
`Cirrus CI`_ will run the full suite when you submit your pull request.

There are more than 17 000 test cases thus it generally takes around 12
minutes to run the full test suite. It can be executed in *quick* mode to just
run the most essential tests in about 1 minute::

   make test QUICKTEST=y

The :command:`script/mt` utility is also available to just execute one or
several testfiles. If a test fails, :command:`script/mt` reports the *diff*
comparison between expected and actual results. For instance, to only
execute :file:`testsuite/modules.50-cmds/470-variant.exp` testfile, run::

   script/mt 50/470

Run :command:`script/mt` with ``--help`` option to get usage details and
syntax to select several testfiles.

.. _GitHub Actions: https://github.com/envmodules/modules/actions
.. _Cirrus CI: https://cirrus-ci.com/github/envmodules/modules

.. _running-test-coverage:

Running test coverage
~~~~~~~~~~~~~~~~~~~~~

Generating a report of lines that do not have test coverage can indicate where
to start contributing or what your tests should cover for the code changes you
submit.

Run ``make test COVERAGE=y`` which will automatically setup the `Nagelfar`_
Tcl code coverage tool in your ``modules`` development directory and
instrument the source Tcl scripts. Then the full testsuite will be run in
coverage mode and an annotated script will be produced for each Tcl script in
``tcl`` source directory (``tcl/*.tcl_m``)::

   make test COVERAGE=y
   # then open tcl/*.tcl_m files and look for ';# Not covered' lines

The :command:`script/mt` utility may also be used to run the test suite in
coverage mode on full testsuite or on a few testfiles::

   script/mt cov 70/{280,290}

.. _Nagelfar: http://nagelfar.sourceforge.net/

Running linter tests
~~~~~~~~~~~~~~~~~~~~

Linter tools check code syntax and report issues and good practices to follow.
Modules uses `Nagelfar`_ to check syntax of Tcl scripts and `ShellCheck`_ to
lint sh, bash and ksh scripts.

Run ``make testlint`` to lint all sh, bash, ksh and Tcl scripts in your local
Modules repository.

The :command:`script/mt` utility may also be used to run the full *lint* test
suite or just specific testfiles. For instance to only lint Tcl scripts::

   script/mt lint 00/030

.. _ShellCheck: https://www.shellcheck.net/

Check performances
~~~~~~~~~~~~~~~~~~

The :command:`script/mb` utility checks from your local repository the
performances of major releases of Modules and current branch. Current ongoing
modifications are first stashed, then :command:`modulecmd.tcl` of the
releases and current branch are built. Different tests are run against each
version and the execution time of each test is reported in millisecond::

   $ script/mb
             |   v4.1.4 |   v4.3.1 |   v4.5.3 |   v4.7.1 |   v5.1.1 |     main |
   ----------+----------+----------+----------+----------+----------+----------+
        help |        9 |       12 |       12 |       15 |       16 |       16 |
       avail |       61 |       67 |       76 |       82 |       91 |       86 |
      avail2 |       11 |       16 |       19 |       21 |       23 |       23 |
      avail3 |        - |        - |        - |      120 |      128 |      130 |
      whatis |      208 |      155 |      233 |      216 |      221 |      224 |
     whatis2 |       10 |       15 |       17 |       20 |       21 |       22 |
     whatis3 |        - |        - |        - |      287 |      307 |      314 |
     apropos |      208 |      153 |      222 |      210 |      220 |      223 |
        load |       66 |       87 |      134 |      162 |      120 |      126 |
        list |       24 |       23 |       33 |       22 |       25 |       25 |
      unload |       46 |       24 |       25 |       29 |       31 |       31 |

It helps to verify that current work committed in local repository does not
impact performances on simple test scenarios. Run :command:`script/mb` with
``--help`` option to get its usage details.

The ``profile`` mode may also be interesting to learn what are the internal
procedures of :command:`modulecmd.tcl` taking most of the execution time for
each test::

   script/mb profile

Building the docs
~~~~~~~~~~~~~~~~~

Build the docs in the ``doc`` directory using Sphinx::

   cd doc
   make html

Open ``_build/html/index.html`` in your browser to view the docs.

Read more about `Sphinx`_.

.. _Sphinx: https://www.sphinx-doc.org

.. _coding-conventions:

Coding conventions
~~~~~~~~~~~~~~~~~~

* Maximum line length is 78 characters
* Use 3 spaces to indent code (do not use tab character)
* Adopt `Tcl minimal escaping style`_
* Procedure names: ``lowerCameCase``
* Variable names: ``no_case_at_all``
* Curly brace and square bracket placement::

   if {![isStateDefined already_report]} {
      setState already_report 1
   }

* `No trailing space nor misspelling <commit-hooks_>`_

.. _Tcl minimal escaping style: https://wiki.tcl-lang.org/page/Tcl+Minimal+Escaping+Style

.. _developer-certificate-of-origin:

Developer Certificate of Origin (DCO)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In order to ensure that all contributions are properly authorized and in
compliance with licensing requirements, Modules project follows the `Developer
Certificate of Origin (DCO)`_ process. The DCO is a lightweight mechanism to
certify that you, as a contributor, have the right to submit your code and
agree to the project’s licensing terms.

How to sign off your commits
""""""""""""""""""""""""""""

Every commit must include a ``Signed-off-by`` line, which certifies that the
contribution adheres to the DCO. You can do this by adding the following line
at the end of your commit message::

    Signed-off-by: Your Name <your.email@example.com>

The name and email must match your Git configuration (``git config user.name``
and ``git config user.email``).

To simplify the process, you can use the ``-s`` flag of ``git`` command when
committing::

    git commit -s -m "Your commit message"

Verifying DCO Compliance
""""""""""""""""""""""""

Modules repository automates checks to enforce the DCO. If your contribution
does not include the proper ``Signed-off-by`` line, the pull request check
will fail. You will need to amend your commit::

    git commit --amend -s

.. _Developer Certificate of Origin (DCO): https://developercertificate.org/

.. _commit-hooks:

Commit hooks
~~~~~~~~~~~~

A :command:`pre-commit` hook script is provided in the :file:`script`
directory of the project to help you check that the contribution made is free
of misspellings and trailing spaces. It requires the `codespell`_ utility that
checks for typos in any kind of files and the `Hunspell`_ utility that spell
checks documentation files. The :command:`pre-commit` could be enabled in your
local repository with following command::

   ln -s ../../script/pre-commit .git/hooks/pre-commit

A :command:`commit-msg` hook script is also provided in the :file:`script`
directory of the project to help you check that your commit messages are free
of misspellings. It requires the `Hunspell`_ utility and could be enabled in
your local repository with following command::

   ln -s ../../script/commit-msg .git/hooks/commit-msg

.. _codespell: https://github.com/codespell-project/codespell
.. _Hunspell: https://hunspell.github.io/

Emacs settings for coding conventions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is an example Emacs configuration that adheres to the first two
coding conventions.  You may wish to add this to your ``.emacs`` or
``.emacs.d/`` to modify your tcl-mode::

   (add-hook 'tcl-mode-hook
      (lambda ()
        (setq indent-tabs-mode nil)
        (setq tcl-indent-level 3)
        (setq tcl-continued-indent-level 3)
        (font-lock-add-keywords nil '(("^[^\n]\\{79\\}\\(.*\\)$" 1
                                       font-lock-warning-face prepend)))))

Submitting installation recipes
-------------------------------

* If you want to share your installation tips and tricks, efficient ways you
  have to write or organize your modulefiles or some extension you made to the
  ``module`` command please add a recipe to the cookbook section of the
  documentation.
* Create a directory under ``doc/example`` and put there the extension code
  or example modulefiles your recipe is about.
* Describe this recipe through a `reStructuredText`_ document in
  ``doc/source/cookbook``. It is suggested to have an *Implementation*,
  an *Installation* and an *Usage example* sections in that document to get
  as much as possible the same document layout across recipes.
* `Submit a patch <submitting-patches_>`_ with all the above content.

.. _reStructuredText: http://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html

