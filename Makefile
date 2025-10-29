.PHONY: doc pkgdoc initdir install install-testsiteconfig \
	install-testsiteconfig-1 install-testmodulerc install-testinitrc-1 \
	install-testinitrc install-testetcrc install-testmodspath \
	install-testmodspath-empty install-testmodspath-wild \
	install-testmoguicmd uninstall-testconfig uninstall dist dist-tar \
	dist-gzip dist-bzip2 dist-win srpm rpm clean distclean test-deps test \
	testinstall testlint

# commands to install files
INSTALL = install
INSTALL_DIR = $(INSTALL) -d -m 755
INSTALL_DATA = $(INSTALL) -m 644
INSTALL_PROGRAM = $(INSTALL) -m 755

# download command and its options
CURL := curl --location --remote-name --retry 3 --retry-connrefused \
	--retry-delay 20 --max-time 20

# definitions for code coverage
NAGELFAR_DLSRC1 := http://downloads.sourceforge.net/nagelfar/
NAGELFAR_RELEASE := nagelfar135
NAGELFAR_DIST := $(NAGELFAR_RELEASE).tar.gz
NAGELFAR_DISTSUM := 0305ae1617a365626f45fc08909c6f58
NAGELFAR := $(NAGELFAR_RELEASE)/nagelfar.tcl

# definition for old Tcl interpreter for coverage testing
TCL_DLSRC := http://downloads.sourceforge.net/tcl/
TCL_RELEASE83 := tcl8.3.5
TCL_DIST83 := $(TCL_RELEASE83)-src.tar.gz
TCL_DISTSUM83 := 5cb79f8b90cf1322cb1286b9fe67f7a2
TCLSH83 := $(TCL_RELEASE83)/unix/tclsh

# third-party definitions for source-sh testing
SPACK_REPOURL := https://github.com/spack/spack.git
MINICONDA_DLSRC := https://repo.anaconda.com/miniconda/
MINICONDA_DIST := Miniconda3-py38_4.11.0-Linux-x86_64.sh
MINICONDA_DISTSUM := 252d3b0c863333639f99fbc465ee1d61
OPENFOAM_REPOURL := https://github.com/OpenFOAM/OpenFOAM-dev.git

# specific modulecmd script for test
MODULECMDTEST := modulecmd-test.tcl
# if coverage enabled, run tests on instrumented file to create coverage log
ifeq ($(COVERAGE),y)
MODULECMD := $(MODULECMDTEST)_i
else
MODULECMD := $(MODULECMDTEST)
endif

# definitions for enhanced diff tool (to review test results)
ICDIFF_DLSRC := https://raw.githubusercontent.com/jeffkaufman/icdiff/release-2.0.4/
ICDIFF_CHECKSUM := 597bd4cda393803e5991c43b78cab3b3

# source definitions shared across the Makefiles of this project
ifneq ($(wildcard Makefile.inc),Makefile.inc)
  $(error Makefile.inc is missing, please run './configure')
endif
include Makefile.inc

INSTALL_PREREQ := modulecmd.tcl ChangeLog.gz README script/add.modules \
	script/modulecmd
TEST_PREREQ := $(MODULECMD)
ifeq ($(COVERAGE),y)
TEST_PREREQ += $(NAGELFAR)
endif

ifeq ($(libtclenvmodules),y)
INSTALL_PREREQ += lib/libtclenvmodules$(SHLIB_SUFFIX)
TEST_PREREQ += lib/libtclenvmodules$(SHLIB_SUFFIX)
ifeq ($(COVERAGE),y)
TEST_PREREQ += lib/libtestutil-closedir$(SHLIB_SUFFIX) \
	lib/libtestutil-getpwuid$(SHLIB_SUFFIX) \
	lib/libtestutil-getgroups$(SHLIB_SUFFIX) \
	lib/libtestutil-0getgroups$(SHLIB_SUFFIX) \
	lib/libtestutil-dupgetgroups$(SHLIB_SUFFIX) \
	lib/libtestutil-time$(SHLIB_SUFFIX) \
	lib/libtestutil-mktime$(SHLIB_SUFFIX)
endif
endif

# install old Tcl interpreters to test coverage
ifeq ($(COVERAGE_OLDTCL),y)
TEST_PREREQ += tclsh83
endif

# install extra software to test source-sh against their scripts
ifeq ($(EXTRATEST_SOURCESH),y)
TEST_PREREQ += spack miniconda3 OpenFOAM-dev
endif

# define rule prereq when target need to be rebuilt when git repository change
ifeq ($(wildcard .git),.git)
GIT_REFRESH_PREREQ := .git/objects

# determine if version.inc needs to get updated as git repository has changed
ifeq ($(wildcard version.inc), version.inc)
MTIME_VERSION := $(shell date -r version.inc +%s)
MTIME_GIT_REPO := $(shell date -r $(GIT_REFRESH_PREREQ) +%s)
REFRESH_VERSION_INC := $(shell if [ $(MTIME_GIT_REPO) -gt $(MTIME_VERSION) ]; \
	then echo y; else echo n; fi)
else
REFRESH_VERSION_INC := y
endif

else
GIT_REFRESH_PREREQ :=
REFRESH_VERSION_INC := n
endif

# setup summary echo rules unless silent mode set
ifneq ($(findstring s,$(MAKEFLAGS)),s)
ECHO_GEN = @echo ' ' GEN $@;
ECHO_GEN2 = @echo ' ' GEN
else
# disable echo rules followed by a string
ECHO_GEN2 = \#
endif

all: initdir $(INSTALL_PREREQ)

# skip doc build if no sphinx-build
ifneq ($(builddoc),n)
all: pkgdoc
endif

initdir:
	$(MAKE) --no-print-directory -C init all

pkgdoc: version.inc
	$(MAKE) --no-print-directory -C doc man txt

doc: version.inc
	$(MAKE) --no-print-directory -C doc all

# source version definitions if built and no need to get refreshed
# skip calls to git command if this file is available
ifeq ($(wildcard version.inc) $(REFRESH_VERSION_INC), version.inc n)
-include version.inc
else
# build version.inc shared definitions from git repository info
ifeq ($(wildcard .git) $(wildcard version.inc.in),.git version.inc.in)
GIT_CURRENT_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null)
GIT_CURRENT_DESC := $(shell git describe --tags 2>/dev/null)
GIT_CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

MODULES_RELEASE := $(subst v,,$(GIT_CURRENT_TAG))
ifeq ($(MODULES_RELEASE),)
# load raw version information to get MODULES_RELEASE as git repository does
# not contain enough info (checked out repository depth too short)
include version.inc.in
GIT_CURRENT_COMMIT := $(shell git rev-parse --short=8 HEAD)
ifeq ($(GIT_CURRENT_BRANCH),main)
MODULES_BUILD := +XX-g$(GIT_CURRENT_COMMIT)
else
MODULES_BUILD := +$(GIT_CURRENT_BRANCH)-XX-g$(GIT_CURRENT_COMMIT)
endif
else ifeq ($(GIT_CURRENT_TAG),$(GIT_CURRENT_DESC))
MODULES_BUILD :=
else ifeq ($(GIT_CURRENT_BRANCH),main)
MODULES_BUILD := +$(subst $(GIT_CURRENT_TAG)-,,$(GIT_CURRENT_DESC))
else
MODULES_BUILD := +$(GIT_CURRENT_BRANCH)$(subst $(GIT_CURRENT_TAG),,$(GIT_CURRENT_DESC))
endif
MODULES_BUILD_DATE := $(shell git log -1 --format=%cd --date=short)

else
# load raw version information
include version.inc.in

# build short date from full date found in raw data
ifeq ($(MODULES_BUILD_FDATE),$$Format:%ci$$)
MODULES_BUILD_DATE := $(shell date '+%Y-%m-%d')
else
MODULES_BUILD_DATE := $(firstword $(MODULES_BUILD_FDATE))
endif

# set a recognizable build number if one found in version.inc.in is raw data
ifeq ($(MODULES_BUILD_HASH),$$Format:%h$$)
MODULES_BUILD := +XX-gffffffff
# or compute it from these information as if working from git repository
else
comma := ,
MODULES_BUILD_REFS := $(subst $(comma),,$(MODULES_BUILD_REFS))

ifeq ($(filter v$(MODULES_RELEASE),$(MODULES_BUILD_REFS)),v$(MODULES_RELEASE))
MODULES_BUILD :=
else ifeq ($(filter main,$(MODULES_BUILD_REFS)),main)
MODULES_BUILD := +XX-g$(MODULES_BUILD_HASH)
else ifeq ($(MODULES_BUILD_REFS),%D)
MODULES_BUILD := +XX-g$(MODULES_BUILD_HASH)
else
MODULES_BUILD := +$(notdir $(lastword $(MODULES_BUILD_REFS)))-XX-g$(MODULES_BUILD_HASH)
endif
endif
endif
# no need to include generated version.inc file as the MODULES_* variables
# have just been computed
endif

# determine RPM release
# use last release if we currently sat on tag, append build number to it elsewhere
MODULES_LAST_RPM_VERSREL := $(shell sed -n '/^%changelog/ {n;s/^\*.* - //p;q;}' \
	share/rpm/environment-modules.spec.in)
MODULES_LAST_RPM_RELEASE := $(lastword $(subst -, ,$(MODULES_LAST_RPM_VERSREL)))
MODULES_RPM_RELEASE := $(MODULES_LAST_RPM_RELEASE)$(subst +,.,$(subst -,.,$(MODULES_BUILD)))

# define init configs location
ifeq ($(initconfin),etcdir)
  modulespath := $(etcdir)/modulespath
  initrc := $(etcdir)/initrc
else
  modulespath := $(initdir)/.modulespath
  initrc := $(initdir)/modulerc
endif

# comment entries if feature not enabled
ifeq ($(versioning),y)
  setversioning :=
  setnotversioning := \#
else
  setversioning := \#
  setnotversioning :=
endif
ifeq ($(setbinpath),y)
  setsetbinpath :=
else
  setsetbinpath := \#
endif
ifeq ($(appendbinpath),y)
  setappendbinpath := append
else
  setappendbinpath := prepend
endif
ifeq ($(setmanpath),y)
  setsetmanpath :=
else
  setsetmanpath := \#
endif
ifeq ($(appendmanpath),y)
  setappendmanpath := append
else
  setappendmanpath := prepend
endif
ifeq ($(usemanpath),y)
  setusemanpath :=
  setnotusemanpath := \#
else
  setusemanpath := \#
  setnotusemanpath :=
endif

# build list of shell whose completion script has to be sourced during
# autoinit initialization
shellcompsource := tcsh
ifeq ($(bashcompletiondir),)
  shellcompsource += bash
endif
ifeq ($(fishcompletiondir),)
  shellcompsource += fish
endif

ifeq ($(silentshdbgsupport),y)
  setsilentshdbgsupport := 1
else
  setsilentshdbgsupport := 0
endif

ifeq ($(quarantinesupport),y)
  setquarantinesupport := 1
else
  setquarantinesupport := 0
endif

ifeq ($(libtclenvmodules),y)
  setlibtclenvmodules :=
else
  setlibtclenvmodules := \#
endif

ifeq ($(multilibsupport),y)
  setmultilibsupport :=
  setnotmultilibsupport := \#
  sedexprlibdir := -e 's|@libdir64@|$(libdir64)|g' -e 's|@libdir32@|$(libdir32)|g'
else
  setmultilibsupport := \#
  setnotmultilibsupport :=
  sedexprlibdir := -e 's|@libdir@|$(libdir)|g'
endif

ifneq ($(pageropts),)
  pagercmd := $(pager) $(pageropts)
else
  pagercmd := $(pager)
endif

ifneq ($(loggeropts),)
  loggercmd := $(logger) $(loggeropts)
else
  loggercmd := $(logger)
endif

ifeq ($(color),y)
  setcolor := auto
else
  setcolor := never
endif

ifeq ($(autohandling),y)
  setautohandling := 1
else
  setautohandling := 0
endif

ifeq ($(conflictunload),y)
  setconflictunload := 1
else
  setconflictunload := 0
endif

ifeq ($(requirevia),y)
  setrequirevia := 1
else
  setrequirevia := 0
endif

ifeq ($(implicitrequirement),y)
  setimplicitrequirement := 1
else
  setimplicitrequirement := 0
endif

ifeq ($(availindepth),y)
  setavailindepth := 1
else
  setavailindepth := 0
endif

ifeq ($(spiderindepth),y)
  setspiderindepth := 1
else
  setspiderindepth := 0
endif

ifeq ($(implicitdefault),y)
  setimplicitdefault := 1
else
  setimplicitdefault := 0
endif

ifeq ($(extendeddefault),y)
  setextendeddefault := 1
else
  setextendeddefault := 0
endif

ifeq ($(advversspec),y)
  setadvversspec := 1
else
  setadvversspec := 0
endif

ifeq ($(uniquenameloaded),y)
  setuniquenameloaded := 1
else
  setuniquenameloaded := 0
endif

ifeq ($(sourcecache),y)
  setsourcecache := 1
else
  setsourcecache := 0
endif

ifeq ($(ml),y)
  setml := 1
else
  setml := 0
endif

ifeq ($(setshellstartup),y)
  setsetshellstartup := 1
else
  setsetshellstartup := 0
endif

ifeq ($(mcookieversioncheck),y)
  setmcookieversioncheck := 1
else
  setmcookieversioncheck := 0
endif

ifeq ($(wa277),y)
  setwa277 := 1
else
  setwa277 := 0
endif

ifeq ($(pathentryreorder),y)
  setpathentryreorder := 1
else
  setpathentryreorder := 0
endif

ifneq ($(tcllinteropts),)
  tcllintercmd := $(tcllinter) $(tcllinteropts)
else
  tcllintercmd := $(tcllinter)
endif

ifeq ($(nagelfaraddons),y)
  setnagelfaraddons :=
else
  setnagelfaraddons := \#
endif

define translate-in-script
$(ECHO_GEN)
sed -e 's|@prefix@|$(prefix)|g' \
	-e 's|@baseprefix@|$(baseprefix)|g' \
	$(sedexprlibdir) \
	-e 's|@libexecdir@|$(libexecdir)|g' \
	-e 's|@initdir@|$(initdir)|g' \
	-e 's|@etcdir@|$(etcdir)|g' \
	-e 's|@modulefilesdir@|$(modulefilesdir)|g' \
	-e 's|@bindir@|$(bindir)|g' \
	-e 's|@mandir@|$(mandir)|g' \
	-e 's|@nagelfardatadir@|$(nagelfardatadir)|g' \
	-e 's|@moduleshome@|$(moduleshome)|g' \
	-e 's|@initrc@|$(initrc)|g' \
	-e 's|@modulespath@|$(modulespath)|g' \
	-e 's|@VERSION@|$(VERSION)|g' \
	-e 's|@TCLSHDIR@/tclsh|$(TCLSH)|g' \
	-e 's|@TCLSH@|$(TCLSH)|g' \
	-e 's|@PYTHON@|$(PYTHON)|g' \
	-e 's|@loggedevents@|$(loggedevents)|g' \
	-e 's|@loggercmd@|$(loggercmd)|g' \
	-e 's|@pagercmd@|$(pagercmd)|g' \
	-e 's|@verbosity@|$(verbosity)|g' \
	-e 's|@color@|$(setcolor)|g' \
	-e 's|@darkbgcolors@|$(darkbgcolors)|g' \
	-e 's|@lightbgcolors@|$(lightbgcolors)|g' \
	-e 's|@termbg@|$(termbg)|g' \
	-e 's|@lockedconfigs@|$(lockedconfigs)|g' \
	-e 's|@unloadmatchorder@|$(unloadmatchorder)|g' \
	-e 's|@implicitdefault@|$(setimplicitdefault)|g' \
	-e 's|@extendeddefault@|$(setextendeddefault)|g' \
	-e 's|@advversspec@|$(setadvversspec)|g' \
	-e 's|@uniquenameloaded@|$(setuniquenameloaded)|g' \
	-e 's|@sourcecache@|$(setsourcecache)|g' \
	-e 's|@searchmatch@|$(searchmatch)|g' \
	-e 's|@wa277@|$(setwa277)|g' \
	-e 's|@pathentryreorder@|$(setpathentryreorder)|g' \
	-e 's|@icase@|$(icase)|g' \
	-e 's|@nearlyforbiddendays@|$(nearlyforbiddendays)|g' \
	-e 's|@tagabbrev@|$(tagabbrev)|g' \
	-e 's|@tagcolorname@|$(tagcolorname)|g' \
	-e 's|@stickypurge@|$(stickypurge)|g' \
	-e 's|@abortonerror@|$(abortonerror)|g' \
	-e 's|@availoutput@|$(availoutput)|g' \
	-e 's|@availterseoutput@|$(availterseoutput)|g' \
	-e 's|@listoutput@|$(listoutput)|g' \
	-e 's|@listterseoutput@|$(listterseoutput)|g' \
	-e 's|@spideroutput@|$(spideroutput)|g' \
	-e 's|@spiderterseoutput@|$(spiderterseoutput)|g' \
	-e 's|@variantshortcut@|$(variantshortcut)|g' \
	-e 's|@editor@|$(editor)|g' \
	-e 's|@autohandling@|$(setautohandling)|g' \
	-e 's|@conflictunload@|$(setconflictunload)|g' \
	-e 's|@requirevia@|$(setrequirevia)|g' \
	-e 's|@implicitrequirement@|$(setimplicitrequirement)|g' \
	-e 's|@availindepth@|$(setavailindepth)|g' \
	-e 's|@spiderindepth@|$(setspiderindepth)|g' \
	-e 's|@silentshdbgsupport@|$(setsilentshdbgsupport)|g' \
	-e 's|@ml@|$(setml)|g' \
	-e 's|@setshellstartup@|$(setsetshellstartup)|g' \
	-e 's|@mcookieversioncheck@|$(setmcookieversioncheck)|g' \
	-e 's|@quarantinesupport@|$(setquarantinesupport)|g' \
	-e 's|@libtclenvmodules@|$(setlibtclenvmodules)|g' \
	-e 's|@SHLIB_SUFFIX@|$(SHLIB_SUFFIX)|g' \
	-e 's|@multilibsupport@|$(setmultilibsupport)|g' \
	-e 's|@notmultilibsupport@|$(setnotmultilibsupport)|g' \
	-e 's|@VERSIONING@|$(setversioning)|g' \
	-e 's|@NOTVERSIONING@|$(setnotversioning)|g' \
	-e 's|@setbinpath@|$(setsetbinpath)|g' \
	-e 's|@appendbinpath@|$(setappendbinpath)|g' \
	-e 's|@setmanpath@|$(setsetmanpath)|g' \
	-e 's|@appendmanpath@|$(setappendmanpath)|g' \
	-e 's|@usemanpath@|$(setusemanpath)|g' \
	-e 's|@notusemanpath@|$(setnotusemanpath)|g' \
	-e 's|@shellcompsource@|$(shellcompsource)|g' \
	-e 's|@tcllintercmd@|$(tcllintercmd)|g' \
	-e 's|@nagelfaraddons@|$(setnagelfaraddons)|g' \
	-e 's|@MODULES_RELEASE@|$(MODULES_RELEASE)|g' \
	-e 's|@MODULES_BUILD@|$(MODULES_BUILD)|g' \
	-e 's|@MODULES_RPM_RELEASE@|$(MODULES_RPM_RELEASE)|g' \
	-e 's|@MODULES_BUILD_DATE@|$(MODULES_BUILD_DATE)|g' $< > $@
endef

DIST_PREFIX := modules-$(MODULES_RELEASE)$(MODULES_BUILD)
DIST_WIN_PREFIX := $(DIST_PREFIX)-win

# avoid shared definitions to be rebuilt by make
Makefile.inc: ;

version.inc: version.inc.in $(GIT_REFRESH_PREREQ)
	$(translate-in-script)

share/rpm/environment-modules.spec: share/rpm/environment-modules.spec.in $(GIT_REFRESH_PREREQ)
	$(translate-in-script)

tcl/cache.tcl: tcl/cache.tcl.in version.inc
	$(translate-in-script)

tcl/coll.tcl: tcl/coll.tcl.in version.inc
	$(translate-in-script)

tcl/envmngt.tcl: tcl/envmngt.tcl.in version.inc
	$(translate-in-script)

tcl/init.tcl: tcl/init.tcl.in version.inc
	$(translate-in-script)

tcl/main.tcl: tcl/main.tcl.in version.inc
	$(translate-in-script)

tcl/interp.tcl: tcl/interp.tcl.in version.inc
	$(translate-in-script)

tcl/modfind.tcl: tcl/modfind.tcl.in version.inc
	$(translate-in-script)

tcl/report.tcl: tcl/report.tcl.in version.inc
	$(translate-in-script)

tcl/subcmd.tcl: tcl/subcmd.tcl.in version.inc
	$(translate-in-script)

tcl/init.tcl_i: tcl/init.tcl $(NAGELFAR)
	$(ECHO_GEN)
	rm -f $<_log
	$(NAGELFAR) -instrument $<
ifeq ($(multilibsupport),y)
ifeq ($(COVERAGE_MULTILIB),y)
	sed -i -e 's|$(libdir64)|lib64|' -e 's|$(libdir32)|lib|' $@
else
	sed -i -e 's|$(libdir64)|lib|' -e 's|$(libdir32)|lib|' $@
endif
else
	sed -i -e 's|$(libdir)|lib|' $@
endif

tcl/subcmd.tcl_i: tcl/subcmd.tcl $(NAGELFAR)
	$(ECHO_GEN)
	rm -f $<_log
	$(NAGELFAR) -instrument $<
	sed -i -e 's|$(nagelfardatadir)|share/nagelfar|g' $@

# join all tcl/*.tcl files to build modulecmd.tcl
modulecmd.tcl: tcl/cache.tcl tcl/coll.tcl tcl/envmngt.tcl tcl/init.tcl \
	tcl/interp.tcl tcl/main.tcl tcl/mfcmd.tcl tcl/modeval.tcl \
	tcl/modfind.tcl tcl/modscan.tcl tcl/modspec.tcl tcl/report.tcl \
	tcl/subcmd.tcl tcl/util.tcl version.inc
	$(ECHO_GEN)
	echo "#!$(TCLSH)" > $@
	sed -e '3s/.*/# MODULECMD.TCL, a pure TCL implementation of the module command/' \
		-e '1d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/init.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/util.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/envmngt.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/report.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/interp.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/mfcmd.tcl >> $@
	sed -e '1,20d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/modscan.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/modfind.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/modeval.tcl >> $@
	sed -e '1,20d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/modspec.tcl >> $@
	sed -e '1,20d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/cache.tcl >> $@
	sed -e '1,20d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/coll.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/subcmd.tcl >> $@
	sed -e '1,22d' -e '/^# vim:/d' -e '/^# ;;;/d' tcl/main.tcl >> $@
	chmod +x $@

# generate an empty changelog file if not working from git repository
ifeq ($(wildcard .git),.git)
ChangeLog.gz: script/gitlog2changelog.py
	$(ECHO_GEN)
	script/gitlog2changelog.py
	gzip -f -9 ChangeLog
else
ChangeLog.gz:
	$(ECHO_GEN)
	echo "Please refer to the NEWS document to learn about main changes" >ChangeLog
	gzip -f -9 ChangeLog
endif

README:
	$(ECHO_GEN)
	sed -e '181,187d' -e '1,10d' -e 's|\[\(.*\?\)\]\[[0-9]\]|\1|' $@.md > $@

script/add.modules: script/add.modules.in
	$(translate-in-script)
	chmod +x $@

script/gitlog2changelog.py: script/gitlog2changelog.py.in
	$(translate-in-script)
	chmod +x $@

script/modulecmd: script/modulecmd.in
	$(translate-in-script)
	chmod +x $@

# Tcl extension library-related rules
lib/libtclenvmodules$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-closedir$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-getpwuid$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-getgroups$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-0getgroups$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-dupgetgroups$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-time$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

lib/libtestutil-mktime$(SHLIB_SUFFIX):
	$(MAKE) --no-print-directory -C lib $(@F)

# example configs for test rules
testsuite/example/.modulespath: testsuite/example/.modulespath.in
	$(translate-in-script)

testsuite/example/modulespath-wild: testsuite/example/modulespath-wild.in
	$(translate-in-script)

testsuite/example/modulerc: testsuite/example/modulerc.in
	$(translate-in-script)

testsuite/example/initrc-1: testsuite/example/initrc-1.in
	$(translate-in-script)

testsuite/example/initrc: testsuite/example/initrc.in
	$(translate-in-script)

install-testsiteconfig: testsuite/example/siteconfig.tcl
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(etcdir)/'

install-testsiteconfig-1: testsuite/example/siteconfig.tcl-1
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(etcdir)/siteconfig.tcl'

install-testmodulerc: testsuite/example/modulerc
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(initrc)'

install-testinitrc-1: testsuite/example/initrc-1
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(initrc)'

install-testinitrc: testsuite/example/initrc
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(initrc)'

install-testetcrc: testsuite/etc/empty
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(etcdir)/rc'

install-testmodspath: testsuite/example/.modulespath
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(modulespath)'

install-testmodspath-empty: testsuite/example/modulespath-empty
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(modulespath)'

install-testmodspath-wild: testsuite/example/modulespath-wild
	$(MAKE) -C init install-testconfig DESTDIR='$(DESTDIR)'
	$(INSTALL_DATA) $^ '$(DESTDIR)$(modulespath)'

install-testmoguicmd:
	$(INSTALL_DIR) '$(HOME)/.local/bin'
	$(INSTALL_PROGRAM) script/envml '$(HOME)/.local/bin/mogui-cmd'

uninstall-testconfig:
	rm -f '$(DESTDIR)$(etcdir)/rc'
	rm -f '$(DESTDIR)$(etcdir)/siteconfig.tcl'
	rm -f '$(DESTDIR)$(initrc)'
	rm -f '$(DESTDIR)$(modulespath)'
	rm -f '$(HOME)/.local/bin/mogui-cmd'
	$(MAKE) -C init uninstall-testconfig DESTDIR='$(DESTDIR)'

# define space character as a variable to reference it in functions
space := $(subst ,, )

install: $(INSTALL_PREREQ)
	$(INSTALL_DIR) '$(DESTDIR)$(libexecdir)'
	$(INSTALL_DIR) '$(DESTDIR)$(bindir)'
	$(INSTALL_DIR) '$(DESTDIR)$(etcdir)'
	$(INSTALL_PROGRAM) modulecmd.tcl '$(DESTDIR)$(libexecdir)/'
ifeq ($(libtclenvmodules),y)
	$(INSTALL_DIR) '$(DESTDIR)$(libdir)'
	$(INSTALL_PROGRAM) lib/libtclenvmodules$(SHLIB_SUFFIX) '$(DESTDIR)$(libdir)/'
endif
	$(INSTALL_PROGRAM) script/envml '$(DESTDIR)$(bindir)/'
	$(INSTALL_PROGRAM) script/add.modules '$(DESTDIR)$(bindir)/'
	$(INSTALL_PROGRAM) script/modulecmd '$(DESTDIR)$(bindir)/'
	$(INSTALL_PROGRAM) script/mkroot '$(DESTDIR)$(bindir)/'
ifeq ($(windowssupport),y)
	$(INSTALL_PROGRAM) script/module.cmd '$(DESTDIR)$(bindir)/'
	$(INSTALL_PROGRAM) script/ml.cmd '$(DESTDIR)$(bindir)/'
	$(INSTALL_PROGRAM) script/envml.cmd '$(DESTDIR)$(bindir)/'
endif
ifneq ($(wildcard $(subst $(space),\$(space),$(DESTDIR)$(etcdir)/siteconfig.tcl)),$(DESTDIR)$(etcdir)/siteconfig.tcl)
	$(INSTALL_DATA) siteconfig.tcl '$(DESTDIR)$(etcdir)/'
endif
ifeq ($(docinstall),y)
	$(INSTALL_DIR) '$(DESTDIR)$(docdir)'
	$(INSTALL_DATA) COPYING.GPLv2 '$(DESTDIR)$(docdir)/'
	$(INSTALL_DATA) ChangeLog.gz '$(DESTDIR)$(docdir)/'
	$(INSTALL_DATA) README '$(DESTDIR)$(docdir)/'
endif
ifeq ($(vimaddons),y)
	$(INSTALL_DIR) '$(DESTDIR)$(vimdatadir)/ftdetect'
	$(INSTALL_DIR) '$(DESTDIR)$(vimdatadir)/ftplugin'
	$(INSTALL_DIR) '$(DESTDIR)$(vimdatadir)/syntax'
	$(INSTALL_DATA) share/vim/ftdetect/modulefile.vim '$(DESTDIR)$(vimdatadir)/ftdetect'
	$(INSTALL_DATA) share/vim/ftplugin/modulefile.vim '$(DESTDIR)$(vimdatadir)/ftplugin'
	$(INSTALL_DATA) share/vim/syntax/modulefile.vim '$(DESTDIR)$(vimdatadir)/syntax'
endif
ifeq ($(emacsaddons),y)
	$(INSTALL_DIR) '$(DESTDIR)$(emacsdatadir)'
	$(INSTALL_DATA) share/emacs/lisp/modulefile-mode.el* '$(DESTDIR)$(emacsdatadir)'
endif
ifeq ($(nagelfaraddons),y)
	$(INSTALL_DIR) '$(DESTDIR)$(nagelfardatadir)'
	$(INSTALL_DATA) share/nagelfar/plugin_modulecache.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/plugin_modulefile.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/plugin_modulerc.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/plugin_globalrc.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/syntaxdb_modulecache.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/syntaxdb_modulefile.tcl  '$(DESTDIR)$(nagelfardatadir)/'
	$(INSTALL_DATA) share/nagelfar/syntaxdb_modulerc.tcl  '$(DESTDIR)$(nagelfardatadir)/'
endif
	$(MAKE) -C init install DESTDIR='$(DESTDIR)'
ifneq ($(builddoc),n)
	$(MAKE) -C doc install DESTDIR='$(DESTDIR)'
else
	@echo
	@echo "WARNING: Documentation not built nor installed" >&2
endif
	@echo
	@echo "NOTICE: Modules installation is complete." >&2
	@echo "        Please read the 'Configuration' section in INSTALL guide to learn" >&2
	@echo "        how to adapt your installation and make it fit your needs." >&2
	@echo

uninstall:
	rm -f '$(DESTDIR)$(libexecdir)/modulecmd.tcl'
ifeq ($(libtclenvmodules),y)
	rm -f '$(DESTDIR)$(libdir)/libtclenvmodules$(SHLIB_SUFFIX)'
endif
	rm -f '$(DESTDIR)$(bindir)/envml'
	rm -f '$(DESTDIR)$(bindir)/add.modules'
	rm -f '$(DESTDIR)$(bindir)/modulecmd'
	rm -f '$(DESTDIR)$(bindir)/mkroot'
ifeq ($(windowssupport),y)
	rm -f '$(DESTDIR)$(bindir)/module.cmd'
	rm -f '$(DESTDIR)$(bindir)/ml.cmd'
	rm -f '$(DESTDIR)$(bindir)/envml.cmd'
endif
ifeq ($(vimaddons),y)
	rm -f '$(DESTDIR)$(vimdatadir)/ftdetect/modulefile.vim'
	rm -f '$(DESTDIR)$(vimdatadir)/ftplugin/modulefile.vim'
	rm -f '$(DESTDIR)$(vimdatadir)/syntax/modulefile.vim'
	-rmdir '$(DESTDIR)$(vimdatadir)/ftdetect'
	-rmdir '$(DESTDIR)$(vimdatadir)/ftplugin'
	-rmdir '$(DESTDIR)$(vimdatadir)/syntax'
	-rmdir -p '$(DESTDIR)$(vimdatadir)'
endif
ifeq ($(emacsaddons),y)
	rm -f '$(DESTDIR)$(emacsdatadir)/modulefile-mode.el'
	rm -f '$(DESTDIR)$(emacsdatadir)/modulefile-mode.elc'
	-rmdir -p '$(DESTDIR)$(emacsdatadir)'
endif
ifeq ($(nagelfaraddons),y)
	rm -f '$(DESTDIR)$(nagelfardatadir)/plugin_modulecache.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/plugin_modulefile.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/plugin_modulerc.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/plugin_globalrc.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/syntaxdb_modulecache.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/syntaxdb_modulefile.tcl'
	rm -f '$(DESTDIR)$(nagelfardatadir)/syntaxdb_modulerc.tcl'
	-rmdir -p '$(DESTDIR)$(nagelfardatadir)'
endif
ifeq ($(docinstall),y)
	rm -f $(foreach docfile,ChangeLog.gz README COPYING.GPLv2,'$(DESTDIR)$(docdir)/$(docfile)')
ifeq ($(builddoc),n)
	rmdir '$(DESTDIR)$(docdir)'
endif
endif
	$(MAKE) -C init uninstall DESTDIR='$(DESTDIR)'
ifneq ($(builddoc),n)
	$(MAKE) -C doc uninstall DESTDIR='$(DESTDIR)'
endif
	rmdir '$(DESTDIR)$(libexecdir)'
ifeq ($(libtclenvmodules),y)
	rmdir '$(DESTDIR)$(libdir)'
endif
	rmdir '$(DESTDIR)$(bindir)'
	rmdir '$(DESTDIR)$(datarootdir)'
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(prefix)' || true

# include config.{guess,sub} scripts in dist if generated by autoreconf
ifeq ($(wildcard lib/config.guess),lib/config.guess)
DIST_AUTORECONF_EXTRA += lib/config.guess
endif
ifeq ($(wildcard lib/config.sub),lib/config.sub)
DIST_AUTORECONF_EXTRA += lib/config.sub
endif

# include pre-generated documents not to require documentation build
# tools when installing from dist tarball
dist-tar: ChangeLog.gz share/rpm/environment-modules.spec pkgdoc
	$(ECHO_GEN2) $(DIST_PREFIX).tar
	git archive --prefix=$(DIST_PREFIX)/ --worktree-attributes \
		-o $(DIST_PREFIX).tar HEAD
	tar -rf $(DIST_PREFIX).tar --transform 's,^,$(DIST_PREFIX)/,' \
		lib/configure lib/config.h.in $(DIST_AUTORECONF_EXTRA) ChangeLog.gz \
		doc/build/MIGRATING.txt doc/build/changes.txt doc/build/INSTALL.txt \
		doc/build/INSTALL-win.txt doc/build/NEWS.txt doc/build/CONTRIBUTING.txt \
		doc/build/module.1.in doc/build/ml.1 doc/build/envml.1 \
		doc/build/modulefile.5 share/rpm/environment-modules.spec

dist-gzip: dist-tar
	$(ECHO_GEN2) $(DIST_PREFIX).tar.gz
	gzip -f -9 $(DIST_PREFIX).tar

dist-bzip2: dist-tar
	$(ECHO_GEN2) $(DIST_PREFIX).tar.bz2
	bzip2 -f $(DIST_PREFIX).tar

dist: dist-gzip

# dist zip ball for Windows platform with all pre-generated relevant files
dist-win: modulecmd.tcl ChangeLog.gz README pkgdoc
	$(ECHO_GEN2) $(DIST_WIN_PREFIX).zip
	$(INSTALL_DIR) $(DIST_WIN_PREFIX)
	$(INSTALL_DIR) $(DIST_WIN_PREFIX)/libexec
	$(INSTALL_PROGRAM) modulecmd.tcl $(DIST_WIN_PREFIX)/libexec/
	$(INSTALL_DIR) $(DIST_WIN_PREFIX)/bin
	$(INSTALL_PROGRAM) script/module.cmd $(DIST_WIN_PREFIX)/bin/
	$(INSTALL_PROGRAM) script/ml.cmd $(DIST_WIN_PREFIX)/bin/
	$(INSTALL_PROGRAM) script/envml.cmd $(DIST_WIN_PREFIX)/bin/
	$(INSTALL_DIR) $(DIST_WIN_PREFIX)/doc
	$(INSTALL_DATA) COPYING.GPLv2 $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) ChangeLog.gz $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) README $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/MIGRATING.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/INSTALL-win.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/NEWS.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/CONTRIBUTING.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/module.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/ml.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/envml.txt $(DIST_WIN_PREFIX)/doc/
	$(INSTALL_DATA) doc/build/modulefile.txt $(DIST_WIN_PREFIX)/doc/
	$(MAKE) --no-print-directory -C init dist-win DIST_WIN_PREFIX=../$(DIST_WIN_PREFIX)
	$(INSTALL_PROGRAM) script/INSTALL.bat $(DIST_WIN_PREFIX)/
	$(INSTALL_PROGRAM) script/UNINSTALL.bat $(DIST_WIN_PREFIX)/
	$(INSTALL_PROGRAM) script/TESTINSTALL.bat $(DIST_WIN_PREFIX)/
	$(INSTALL_PROGRAM) script/INSTALL_PWSH.bat $(DIST_WIN_PREFIX)/
	$(INSTALL_PROGRAM) script/TESTINSTALL_PWSH.ps1 $(DIST_WIN_PREFIX)/
	zip -r $(DIST_WIN_PREFIX).zip $(DIST_WIN_PREFIX)
	rm -rf $(DIST_WIN_PREFIX)

srpm: dist-bzip2
	rpmbuild -ts $(DIST_PREFIX).tar.bz2

rpm: dist-bzip2
	rpmbuild -tb $(DIST_PREFIX).tar.bz2

clean:
	rm -f *.log *.sum
	rm -f tcl/*.tcl_i tcl/*.tcl_log tcl/*.tcl_m
	rm -rf coverage
# do not clean generated docs if not in git repository
ifeq ($(wildcard .git),.git)
	rm -f ChangeLog.gz
endif
	rm -f README
	rm -f modulecmd.tcl
	rm -f $(MODULECMDTEST) $(MODULECMDTEST)_i
	rm -f tcl/cache.tcl
	rm -f tcl/coll.tcl
	rm -f tcl/envmngt.tcl
	rm -f tcl/init.tcl
	rm -f tcl/interp.tcl
	rm -f tcl/main.tcl
	rm -f tcl/modfind.tcl
	rm -f tcl/report.tcl
	rm -f tcl/subcmd.tcl
	rm -f script/add.modules
	rm -f script/gitlog2changelog.py
	rm -f script/modulecmd
	rm -f testsuite/example/.modulespath testsuite/example/modulespath-wild testsuite/example/modulerc testsuite/example/initrc-1 testsuite/example/initrc
	rm -f modules-*.tar modules-*.tar.gz modules-*.tar.bz2
	rm -rf modules-*-win/
	rm -f modules-*-win.zip
	rm -f environment-modules-*.srpm environment-modules-*.rpm
	$(MAKE) -C init clean
ifneq ($(builddoc),n)
	$(MAKE) -C doc clean
endif
	rm -f version.inc
	rm -f share/rpm/environment-modules.spec
ifneq ($(wildcard lib/Makefile),)
	$(MAKE) -C lib clean
endif

distclean: clean
	rm -f Makefile.inc
	rm -f site.exp
	rm -f icdiff .noicdiff
	rm -rf $(NAGELFAR_RELEASE)
	rm -rf $(TCL_RELEASE83)
	rm -f tclsh83
	rm -rf spack
	rm -rf miniconda3
	rm -rf OpenFOAM-dev
	rm -f tcl/tags
	rm -f tcl/GTAGS tcl/GRTAGS tcl/GPATH tcl/gtags.file
	rm -f tcl/syntaxdb_modulecmd.tcl
ifneq ($(wildcard lib/Makefile),)
	$(MAKE) -C lib distclean
endif

# make specific modulecmd script for test to check built extension lib
# if coverage asked, instrument script and clear previous coverage log
$(MODULECMDTEST): modulecmd.tcl
	$(ECHO_GEN)
ifeq ($(multilibsupport),y)
	sed -e 's|$(libdir64)|lib|' -e 's|$(libdir32)|lib|' $< > $@
else
	sed -e 's|$(libdir)|lib|' $< > $@
endif
	sed -i -e 's|$(nagelfardatadir)|share/nagelfar|g' $@

tcl/%.tcl_i: tcl/%.tcl $(NAGELFAR)
	$(ECHO_GEN)
	rm -f $<_log
	$(NAGELFAR) -instrument $<

# for coverage check, run tests on instrumented file to create coverage log
# over split tcl source files
$(MODULECMDTEST)_i: tcl/cache.tcl_i tcl/coll.tcl_i tcl/envmngt.tcl_i \
	tcl/init.tcl_i tcl/interp.tcl_i tcl/main.tcl_i tcl/mfcmd.tcl_i \
	tcl/modeval.tcl_i tcl/modfind.tcl_i tcl/modscan.tcl_i tcl/modspec.tcl_i \
	tcl/report.tcl_i tcl/subcmd.tcl_i tcl/util.tcl_i version.inc
	$(ECHO_GEN)
	echo "#!$(TCLSH)" > $@
	echo 'source tcl/init.tcl_i' >> $@
	echo 'source tcl/util.tcl_i' >> $@
	echo 'source tcl/envmngt.tcl_i' >> $@
	echo 'source tcl/report.tcl_i' >> $@
	echo 'source tcl/interp.tcl_i' >> $@
	echo 'source tcl/mfcmd.tcl_i' >> $@
	echo 'source tcl/modscan.tcl_i' >> $@
	echo 'source tcl/modfind.tcl_i' >> $@
	echo 'source tcl/modeval.tcl_i' >> $@
	echo 'source tcl/modspec.tcl_i' >> $@
	echo 'source tcl/cache.tcl_i' >> $@
	echo 'source tcl/coll.tcl_i' >> $@
	echo 'source tcl/subcmd.tcl_i' >> $@
	echo 'source tcl/main.tcl_i' >> $@
	chmod +x $@

# specific target to build test dependencies
test-deps: $(TEST_PREREQ)

# if coverage enabled create markup file for better read coverage result
test: $(TEST_PREREQ)
	TCLSH=$(TCLSH); export TCLSH; \
	MODULECMD=$(MODULECMD); export MODULECMD; \
	OBJDIR=`pwd -P`; export OBJDIR; \
	TESTSUITEDIR=`cd testsuite;pwd -P`; export TESTSUITEDIR; \
	runtest --srcdir $$TESTSUITEDIR --objdir $$OBJDIR $(RUNTESTFLAGS) --tool modules $(RUNTESTFILES)
ifeq ($(COVERAGE),y)
	$(NAGELFAR) -markup tcl/cache.tcl
	$(NAGELFAR) -markup tcl/coll.tcl
	$(NAGELFAR) -markup tcl/envmngt.tcl
	$(NAGELFAR) -markup tcl/init.tcl
	$(NAGELFAR) -markup tcl/interp.tcl
	$(NAGELFAR) -markup tcl/main.tcl
	$(NAGELFAR) -markup tcl/mfcmd.tcl
	$(NAGELFAR) -markup tcl/modeval.tcl
	$(NAGELFAR) -markup tcl/modscan.tcl
	$(NAGELFAR) -markup tcl/modfind.tcl
	$(NAGELFAR) -markup tcl/modspec.tcl
	$(NAGELFAR) -markup tcl/report.tcl
	$(NAGELFAR) -markup tcl/subcmd.tcl
	$(NAGELFAR) -markup tcl/util.tcl
endif

testinstall:
	OBJDIR=`pwd -P`; export OBJDIR; \
	TESTSUITEDIR=`cd testsuite;pwd -P`; export TESTSUITEDIR; \
	runtest --srcdir $$TESTSUITEDIR --objdir $$OBJDIR $(RUNTESTFLAGS) --tool install $(RUNTESTFILES)

testlint: initdir modulecmd.tcl $(NAGELFAR) script/add.modules script/modulecmd
	NAGELFAR=$(NAGELFAR); export NAGELFAR; \
	OBJDIR=`pwd -P`; export OBJDIR; \
	TESTSUITEDIR=`cd testsuite;pwd -P`; export TESTSUITEDIR; \
	runtest --srcdir $$TESTSUITEDIR --objdir $$OBJDIR $(RUNTESTFLAGS) --tool lint $(RUNTESTFILES)


# install enhanced diff tool (to review test results)
icdiff:
	$(CURL) $(ICDIFF_DLSRC)$@
	echo "$(ICDIFF_CHECKSUM)  $@" | md5sum --status -c - || \
		md5 -c $(ICDIFF_CHECKSUM) $@
	chmod +x $@

# install old Tcl interpreter (for code coverage purpose)
tclsh83:
	$(CURL) $(TCL_DLSRC)$(TCL_DIST83)
	echo "$(TCL_DISTSUM83)  $(TCL_DIST83)" | md5sum --status -c - || \
		md5 -c $(TCL_DISTSUM83) $@ || (rm -f $(TCL_DIST83) && false)
	tar xzf $(TCL_DIST83)
	cd $(TCL_RELEASE83)/unix && bash configure --disable-shared && make
	echo '#!/bin/bash' >$@
	echo 'exec $(TCLSH83) $${@}' >>$@
	chmod +x $@
	rm $(TCL_DIST83)

# fetch spack repository and initialize it (for source-sh test purpose)
spack:
	git clone --depth 1 $(SPACK_REPOURL)
	cd spack && ./bin/spack bootstrap now

# install Conda (for source-sh test purpose)
miniconda3:
	$(CURL) $(MINICONDA_DLSRC)$(MINICONDA_DIST)
	echo "$(MINICONDA_DISTSUM)  $(MINICONDA_DIST)" | md5sum --status -c - || \
		md5 -c $(MINICONDA_DISTSUM) $@ || (rm -f $(MINICONDA_DIST) && false)
	bash $(MINICONDA_DIST) -b -s -p ./miniconda3
	rm $(MINICONDA_DIST)

# fetch OpenFOAM repository (for source-sh test purpose)
OpenFOAM-dev:
	git clone --branch 20240520 --depth 1 $(OPENFOAM_REPOURL)

# install code coverage tool
# download from alt. source if correct tarball not retrieved from primary location
$(NAGELFAR):
	$(CURL) $(NAGELFAR_DLSRC1)$(NAGELFAR_DIST)
	echo "$(NAGELFAR_DISTSUM)  $(NAGELFAR_DIST)" | md5sum --status -c - || \
		(rm -f $(NAGELFAR_DIST) && false)
	tar xzf $(NAGELFAR_DIST)
	rm $(NAGELFAR_DIST)

# build Ctags index
tcl/tags: tcl/cache.tcl.in tcl/coll.tcl.in tcl/envmngt.tcl.in tcl/init.tcl.in \
	tcl/interp.tcl.in tcl/main.tcl.in tcl/mfcmd.tcl tcl/modeval.tcl \
	tcl/modfind.tcl.in tcl/modscan.tcl tcl/modspec.tcl tcl/report.tcl.in \
	tcl/subcmd.tcl.in tcl/util.tcl
	ctags --tag-relative -f $@ --langmap=tcl:.tcl.in tcl/cache.tcl.in \
		tcl/coll.tcl.in tcl/envmngt.tcl.in tcl/init.tcl.in tcl/interp.tcl.in \
		tcl/main.tcl.in tcl/mfcmd.tcl tcl/modeval.tcl tcl/modfind.tcl.in \
		tcl/modscan.tcl tcl/modspec.tcl tcl/report.tcl.in tcl/subcmd.tcl.in \
		tcl/util.tcl

# build Gtags target files
tcl/gtags.file:
	echo cache.tcl.in > $@
	echo coll.tcl.in >> $@
	echo envmngt.tcl.in >> $@
	echo init.tcl.in >> $@
	echo interp.tcl.in >> $@
	echo main.tcl.in >> $@
	echo mfcmd.tcl >> $@
	echo modeval.tcl >> $@
	echo modscan.tcl >> $@
	echo modfind.tcl.in >> $@
	echo modspec.tcl >> $@
	echo report.tcl.in >> $@
	echo subcmd.tcl.in >> $@
	echo util.tcl >> $@

# build Gtags tag file
tcl/GTAGS: tcl/cache.tcl.in tcl/coll.tcl.in tcl/envmngt.tcl.in tcl/init.tcl.in \
	tcl/interp.tcl.in tcl/main.tcl.in tcl/mfcmd.tcl tcl/modeval.tcl \
	tcl/modfind.tcl.in tcl/modscan.tcl tcl/modspec.tcl tcl/report.tcl.in \
	tcl/subcmd.tcl.in tcl/util.tcl tcl/gtags.file
	gtags -C tcl --gtagsconf ../.globalrc

tcl/syntaxdb.tcl: modulecmd.tcl $(NAGELFAR)
	echo "set argv {sh -V};\
		rename exit __exit;\
		proc exit {args} {};\
		source modulecmd.tcl;\
		defineModStartNbProc 1;\
		defineGetEqArrayKeyProc 1;\
		defineDoesModMatchAtDepthProc 1 1 equal;\
		defineModVersCmpProc 1 1;\
		defineModEqStaticProc 1 1 mod;\
		defineModEqProc 1 1;\
		defineParseModuleSpecificationProc 1;\
		set tcl_interactive 1;\
		source $(NAGELFAR_RELEASE)/syntaxbuild.tcl;\
		set ::syntax(lappendNoDup) {n x*};\
		set ::syntax(lrem) {n x};\
		set ::syntax(lprepend) {n x*};\
		set ::syntax(execute-modulefile) {x x n x x x? x? x?};\
		set ::syntax(scanExtraMatchSearch) {x x n};\
		set ::syntax(insertProvidedAliases) {x n};\
		set ::syntax(filterExtraMatchSearch) {x x n n};\
		set ::syntax(findModulesFromDirsAndFiles) {x x x x n n? n? n? n?};\
		set ::syntax(getArrayKey) {n x x};\
		set ::syntax(getDiffBetweenArray) {n n x? x?};\
		buildFile $@;" | $(TCLSH)


# quiet build targets unless verbose mode set
ifeq ($(VERBOSE),1)
V = 1
endif
# let verbose by default the install/clean/test and other specific non-build targets
$(V).SILENT: initdir pkgdoc doc version.inc share/rpm/environment-modules.spec \
	modulecmd.tcl tcl/cache.tcl tcl/coll.tcl tcl/envmngt.tcl tcl/init.tcl \
	tcl/interp.tcl tcl/main.tcl tcl/modfind.tcl tcl/report.tcl tcl/subcmd.tcl \
	tcl/cache.tcl_i tcl/coll.tcl_i tcl/envmngt.tcl_i tcl/init.tcl_i tcl/interp.tcl_i \
	tcl/main.tcl_i tcl/mfcmd.tcl_i tcl/modfind.tcl_i tcl/modeval.tcl_i \
	tcl/modscan.tcl_i tcl/modspec.tcl_i tcl/report.tcl_i tcl/subcmd.tcl_i \
	tcl/util.tcl_i ChangeLog.gz README script/add.modules \
	script/gitlog2changelog.py script/modulecmd \
	lib/libtclenvmodules$(SHLIB_SUFFIX) lib/libtestutil-closedir$(SHLIB_SUFFIX) \
	lib/libtestutil-getpwuid$(SHLIB_SUFFIX) lib/libtestutil-getgroups$(SHLIB_SUFFIX) \
	lib/libtestutil-0getgroups$(SHLIB_SUFFIX) lib/libtestutil-mktime$(SHLIB_SUFFIX) \
	lib/libtestutil-dupgetgroups$(SHLIB_SUFFIX) lib/libtestutil-time$(SHLIB_SUFFIX) \
	testsuite/example/.modulespath testsuite/example/modulespath-wild \
	testsuite/example/modulerc testsuite/example/initrc-1 testsuite/example/initrc \
	dist-tar dist-gzip dist-bzip2 dist-win $(MODULECMDTEST) $(MODULECMDTEST)_i
