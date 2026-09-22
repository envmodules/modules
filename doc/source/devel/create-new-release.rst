.. _create-new-release:

Create new Modules release
==========================

This document is a guide to draft then publish a new release of Modules. It
provides all the information from building the distribution tarballs to
updating external resources providing Modules.

Versioning policy
-----------------

Modules project follows `Semantic Versioning 2.0.0`_. Version number has the
``MAJOR.MINOR.PATCH`` form. For a new release, increment the:

* ``MAJOR`` when you make incompatible changes
* ``MINOR`` when you add backward-compatible features
* ``PATCH`` when you add backward-compatible bug fixes

.. _Semantic Versioning 2.0.0: https://semver.org/

Release commit
--------------

At this point, all changes visible by user for this release should be
described in :file:`NEWS.rst` and :file:`doc/source/changes.rst`. Prominent
new features should be described with examples in :file:`MIGRATING.rst`.

Finalize release content:

* Update version number in :file:`version.inc.in` and
  :file:`doc/source/conf.py`
* Set release date in :file:`NEWS.rst` and remove the *not yet released*
  mention in :file:`MIGRATING.rst`
* Update version number and draft changelog message in
  :file:`share/rpm/environment-modules.spec.in`

  * Changelog should mention release author and date
  * Indicate that release version is updated
  * Describe any other changes made to the RPM spec file since last release

* Update release date in any documentation file that demonstrates
  ``module --version`` output.
* If Modules Tcl extension library has been changed since last release, update
  the version number of this library in :file:`lib/configure.ac`.
* Update table of supported versions in :file:`SECURITY.md`.
* Update the ``|modules_version|`` substitution in
  :file:`doc/source/other-implementations.rst` to remove the *not yet
  released* mention, and refresh ``|lmod_version|`` to the latest Lmod
  release the comparison was checked against.

Look at previous release commit, like :ghcommit:`9b1d0134`, to view the lines
that should be modified and what content to write.

Perform commit:

.. code-block:: console

  version=$(grep ^MODULES_RELEASE version.inc.in | cut -d ' ' -f 3)
  git commit -s -a -m "Release of version $version"

Tag version:

.. code-block:: console

  git tag v$version

Build and test release
----------------------

The build and test of the new release is handled by the :file:`script/mrel`
script. This utility creates the distribution archives, test these artifacts
and push to personal repository to run CI.

:file:`script/mrel` is made to be run on a Fedora system. It also build and
test install of RPM package and run remote build on Koji infrastructure.

:file:`script/mrel` asks when initializing for sudo rights (to remove local
``module`` installations prior running build and test), and for a personal
remote GitHub repository (to trigger online CI).

.. code-block:: console

  script/mrel

.. note:: As it tests the different artifacts through running the
   non-regression test suite, the execution of :file:`script/mrel` takes a lot
   of time (more than 1 hour).

If script fails, its full output can be analyzed in :file:`mrel.out` log file.
This log file may be removed if no error occurs:

.. code-block:: console

  rm mrel.out

Save a copy of the generated distribution files (adapt ``RELEASE_DIR`` to fit
your local setup):

.. code-block:: console

  RELEASE_DIR=~/devel/modules-releases
  cp modules-$version{.tar.bz2,.tar.gz,-win.zip} $RELEASE_DIR/
  ls -lh $RELEASE_DIR/modules-$version{.tar.bz2,.tar.gz,-win.zip}

Publish release
---------------

Publication of the new release is handled by the :file:`script/mpub` script.
This tool pushes to online repositories (GitHub and SourceForge) and update
website (also pushed to both platforms).

:file:`script/mpub` asks when initializing for upstream remote GitHub
repository and it expects that valid credential to connect to SourceForge via
SFTP is available.

.. code-block:: console

  script/mpub

If script fails, its full output can be analyzed in :file:`mpub.out` log file.
This log file may be removed if no error occurs:

.. code-block:: console

  rm mpub.out

Now the website should mention the new release on the *Download* link. Stable
target of online document should also point to the new release. It may be
verified at:

* https://envmodules.io
* https://modules.readthedocs.io/en/stable/NEWS.html

Change *Default Download* on `SourceForge Files`_ page. Set the ``.tar.gz``
dist ball of the new release as the new default.

.. _SourceForge Files: https://sourceforge.net/projects/modules/files/Modules/

Close milestone on GitHub at https://github.com/envmodules/modules/milestones

Create release on GitHub at https://github.com/envmodules/modules/releases/new:

* Release title is bare version number ``X.Y.Z``
* Attach ``.tar.gz``, ``.tar.bz2`` and ``-win.zip`` artifacts to the release
* Build release description based on :file:`NEWS.rst` content:

.. code-block:: console

   major_version=$(cut -d '.' -f 1 <<< "$version")
   minor_version=$(cut -d '.' -f 2 <<< "$version")
   previous_version="$major_version.$((minor_version - 1))"
   grep -B1000 ".. _$previous_version release notes:" NEWS.rst | grep -A1000 -- "--------------------------" >NEWS.new
   nb_lines=$(wc -l NEWS.new| cut -d ' ' -f 1)
   sed -i -e "1,2d;$((nb_lines-3)),\$d" NEWS.new
   sed -i -z -e "s/\n   / /g" -e "s/\n  / /g" -e 's/:option://g' -e 's/:mfcmd://g' -e 's/:subcmd://g' -e 's/:file://g' -e 's/:ref://g' -e 's/:mfcmd://g' -e 's/:mconfig://g' -e 's/:instopt://g' -e 's/:mfvar://g' -e 's/:envvar://g' -e 's/:command://g' -e 's/:sitevar://g' -e 's/:mhook://g' -e 's/``/`/g' NEWS.new

Check resulting :file:`NEWS.new` to adapt RST code for boxes, links, codes
(especially cleaning those containing ``\<`` or ``\>``) and make them valid
MarkDown code.

.. vim:set tabstop=2 shiftwidth=2 expandtab autoindent:
