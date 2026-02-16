.PHONY: dist-win install install-testconfig uninstall-testconfig uninstall \
	clean

# use bash shell to correctly expand the $'' syntax used in translate-in-script
SHELL = /usr/bin/env bash

# commands to install files
INSTALL = install
INSTALL_DIR = $(INSTALL) -d -m 755
INSTALL_DATA = $(INSTALL) -m 644

SH_LIKE  = sh ksh bash zsh profile.sh
CSH_LIKE = csh tcsh tcsh_completion profile.csh
OTHER    = perl.pm python.py ruby.rb lisp tcl fish cmake r.R pwsh.ps1

# example modulefiles to install
EXAMPLE_MODFILES_SRCDIR := ../share/modulefiles
EXAMPLE_MODFILES = dot module-git module-info modules null use.own
EXAMPLE_WIN_MODFILES = module-git module-info null
EXAMPLE_TESTCONFIG_MODFILES = null

# source definitions shared across the Makefiles of this project
ifneq ($(wildcard ../Makefile.inc),../Makefile.inc)
  $(error ../Makefile.inc is missing, please run '../configure')
endif
include ../Makefile.inc

# generate 'module use' commands to put in initrc from modulepath unless
# if the modulespath config file should be deployed
ifeq ($(setmodulespath),n)
# need to escape eventual space character in each modulepath/loadedmodule
# entry to correctly produce the module use/module load rules
space := $(subst ,, )
modulerc := \\\n\# enable default modulepaths
modulerc := $(modulerc)$(subst |,$(space),$(addprefix \\\nmodule use --append {,\
  $(subst :,} ,$(subst $(space),|,$(modulepath)))}))
endif
# generate 'module load' commands to put in initrc from loadedmodules
ifneq ($(loadedmodules),)
  modulerc := $(modulerc)$(subst |,$(space),$(addprefix \\\nmodule load {,\
    $(subst :,} ,$(subst $(space),|,$(loadedmodules)))}))
endif
ifneq ($(modulerc),)
  modulerc := $(modulerc)\\\n
endif

# setup summary echo rules unless silent mode set
ECHO_DIR_PREFIX = init/
ifneq ($(findstring s,$(MAKEFLAGS)),s)
ECHO_GEN = @echo ' ' GEN $(ECHO_DIR_PREFIX)$@;
endif

ALL_SHELLS = $(SH_LIKE) $(CSH_LIKE) $(OTHER)

all: $(ALL_SHELLS) initrc bash_completion zsh-functions/_module $(EXAMPLE_MODFILES_SRCDIR)/modules
ifeq ($(versioning),y)
all: $(EXAMPLE_MODFILES_SRCDIR)/version
endif
ifeq ($(setmodulespath),y)
  # both configuration files will be installed and in this case default init
  # scripts will use both files, modulespath evaluated prior initrc. In this
  # case the modulespaths sets are only generated in modulespath config file.
all: modulespath
endif

# define init configs location
ifeq ($(initconfin),etcdir)
  modulespath := $(etcdir)/modulespath
  initrc := $(etcdir)/initrc
else
  modulespath := $(initdir)/.modulespath
  initrc := $(initdir)/modulerc
endif

# define shell completion location
ifeq ($(bashcompletiondir),)
  bashcompletiondir := $(initdir)
  makebashcompdir := n
else
  makebashcompdir := y
endif
ifeq ($(fishcompletiondir),)
  fishcompletiondir := $(initdir)
  makefishcompdir := n
else
  makefishcompdir := y
endif
ifeq ($(zshcompletiondir),)
  zshcompletiondir := $(initdir)/zsh-functions
  setzshfpathre := s|@setzshfpath@||g
else
  setzshfpathre := /@setzshfpath@/d
endif

# comment entries if feature not enabled
ifeq ($(versioning),y)
  versdir := $(baseprefix)/versions
  setversioning :=
else
  setversioning := \#
endif

# define translation rules for quarantine mechanism
ifeq ($(quarantinevars),)
setquarvarsre := /@setquarvars@/d
notsetquarvarsre := s|@notsetquarvars@||g
else
setquarvarsre := s|@setquarvars@||g
notsetquarvarsre := /@notsetquarvars@/d
define runenvvarre
$(if $(filter-out ${1},${2}),s|\(@\(.*\)RUNENV_VAR\(.*\)RUNENV_VAL\(.*\)@\)|\2MODULES_RUNENV_${1}\3${2}\4\n\1|g;)
endef
quarvarsre = -e 's|@RUN_QUARANTINE@|$(foreach vv,$(quarantinevars),$(firstword\
	$(subst =, ,$(vv))))|g;
quarvarsre += $(foreach vv,$(quarantinevars),$(call runenvvarre,$(firstword\
	$(subst =, ,$(vv))),$(subst $(firstword $(subst =, ,$(vv)))=,,$(vv))))
quarvarsre += s/@.*RUNENV_VAR.*@//;'
endif

# define variables for shell completion
comp_cmds := add add-any apropos aliases avail append-path cachebuild cacheclear clear config del describe disable display edit help initadd initclear initlist initprepend initrm is-loaded is-saved is-used is-avail info-loaded keyword lint list load load-any mod-to-sh path paths purge prepend-path refresh reload reset restore rm remove remove-path save savelist saveshow saverm search show sh-to-mod source spider stash stashclear stashlist stashpop stashrm stashshow state swap switch test try-add try-load unload unuse update use whatis
comp_long_opts := --debug --dumpname --help --silent --trace --verbose --version --paginate --no-pager --color --color= --width --width= --ignore-cache --ignore-user-rc
comp_opts := -D -h -s -T -v -V -p -P -w $(comp_long_opts)
comp_load_opts := --auto --no-auto --force -f --icase -i --tag --tag=
comp_unload_opts := --auto --no-auto --force -f --icase -i
comp_list_opts := -a -j -l -o -t --all --json --long --output --output= --terse
comp_stashlist_opts := -j -l -t --json --long --terse
comp_clear_opts := --force -f
comp_avail_opts := -a -C -d -i -j -L -l -o -S -t --all --contains --default --icase --json --latest --long --output --output= --starts-with --terse --indepth --no-indepth
comp_mfile_opts := -i --icase
comp_whatis_opts := -a -i -j --all --icase --json
comp_search_opts := -a -j --all --json
comp_aliases_opts := -a --all
comp_isavail_opts := -a -i --all --icase
comp_lint_opts := -a -i --all --icase
comp_modtosh_opts := --auto --no-auto --force -f --icase -i
comp_path_opts := -d --delim --duplicates
comp_rm_path_opts := -d --delim --index
comp_config_opts := --dump-state --reset abort_on_error advanced_version_spec auto_handling avail_indepth avail_output avail_terse_output cache_buffer_bytes cache_expiry_secs collection_pin_version collection_pin_tag collection_target color colors conflict_unload contact editor extended_default extra_siteconfig hide_auto_loaded home icase ignore_cache ignore_user_rc implicit_default implicit_requirement list_output list_terse_output locked_configs logged_events logger mcookie_check mcookie_version_check ml nearly_forbidden_days non_exportable_tags pager paginate path_entry_reorder protected_envvars quarantine_support rcfile redirect_output require_via reset_target_state run_quarantine search_match set_shell_startup shells_with_ksh_fpath silent_shell_debug source_cache spider_indepth spider_output spider_terse_output sticky_purge tag_abbrev tag_color_name tcl_linter term_background term_width unique_name_loaded unload_match_order variant_shortcut verbosity wa_277

define translate-in-script
$(ECHO_GEN)
sed -e 's|@prefix@|$(prefix)|g' \
	-e 's|@baseprefix@|$(baseprefix)|g' \
	-e 's|@libexecdir@|$(libexecdir)|g' \
	-e 's|@initdir@|$(initdir)|g' \
	-e 's|@etcdir@|$(etcdir)|g' \
	-e 's|@modulefilesdir@|$(modulefilesdir)|g' \
	-e 's|@bindir@|$(bindir)|g' \
	-e 's|@mandir@|$(mandir)|g' \
	-e 's|@comp_cmds@|$(comp_cmds)|g' \
	-e 's|@comp_long_opts@|$(comp_long_opts)|g' \
	-e 's|@comp_opts@|$(comp_opts)|g' \
	-e 's|@comp_load_opts@|$(comp_load_opts)|g' \
	-e 's|@comp_unload_opts@|$(comp_unload_opts)|g' \
	-e 's|@comp_list_opts@|$(comp_list_opts)|g' \
	-e 's|@comp_stashlist_opts@|$(comp_stashlist_opts)|g' \
	-e 's|@comp_clear_opts@|$(comp_clear_opts)|g' \
	-e 's|@comp_avail_opts@|$(comp_avail_opts)|g' \
	-e 's|@comp_mfile_opts@|$(comp_mfile_opts)|g' \
	-e 's|@comp_whatis_opts@|$(comp_whatis_opts)|g' \
	-e 's|@comp_search_opts@|$(comp_search_opts)|g' \
	-e 's|@comp_aliases_opts@|$(comp_aliases_opts)|g' \
	-e 's|@comp_isavail_opts@|$(comp_isavail_opts)|g' \
	-e 's|@comp_lint_opts@|$(comp_lint_opts)|g' \
	-e 's|@comp_modtosh_opts@|$(comp_modtosh_opts)|g' \
	-e 's|@comp_path_opts@|$(comp_path_opts)|g' \
	-e 's|@comp_rm_path_opts@|$(comp_rm_path_opts)|g' \
	-e 's|@comp_config_opts@|$(comp_config_opts)|g' \
	-e 's|@comp_path_entry_reorder@|$(comp_path_entry_reorder)|g' \
	-e '$(setzshfpathre)' \
	-e $$'s|@modulerc@|$(modulerc)|g' \
	-e 's|@modulepath@|$(modulepath)|g' \
	-e '$(setquarvarsre)' $(quarvarsre) \
	-e '$(notsetquarvarsre)' \
	-e 's|@SHELLNAME@|$@|g' \
	-e 's|@VERSIONING@|$(setversioning)|g' \
	-e 's|@VERSION@|$(VERSION)|g' \
	-e 's|@SED_ERE@|$(SED_ERE)|g' \
	-e 's|@PS@|$(PS)|g' \
	-e 's|@BASENAME@|$(BASENAME)|g' \
	-e 's|@TCLSH@|$(TCLSH)|g' $< > $@
endef

# avoid shared definitions to be rebuilt by make
../Makefile.inc: ;

%: %.in
	$(translate-in-script)

# workaround '\\\n' issue on Linux with Make 3.81
initrc: initrc.in
	$(translate-in-script)
	mv $@ ${@}.tmp
	sed -e 's|\\$$||' ${@}.tmp > $@
	rm -f ${@}.tmp

# tcsh is derivated from csh init script
tcsh: csh.in
	$(translate-in-script)

# this rule is needed for profile.sh to get matched
profile.sh: profile.sh.in
	$(translate-in-script)

$(EXAMPLE_MODFILES_SRCDIR)/modules: $(EXAMPLE_MODFILES_SRCDIR)/modules.in
	$(translate-in-script)

$(EXAMPLE_MODFILES_SRCDIR)/version: $(EXAMPLE_MODFILES_SRCDIR)/version.in
	$(translate-in-script)

dist-win: pwsh.ps1
	$(INSTALL_DIR) '$(DIST_WIN_PREFIX)/init'
	$(INSTALL_DATA) cmd.cmd '$(DIST_WIN_PREFIX)/init/'
	$(INSTALL_DATA) pwsh.ps1 '$(DIST_WIN_PREFIX)/init/'
	$(INSTALL_DIR) '$(DIST_WIN_PREFIX)/modulefiles'
	$(INSTALL_DATA) $(addprefix $(EXAMPLE_MODFILES_SRCDIR)/,$(EXAMPLE_WIN_MODFILES)) '$(DIST_WIN_PREFIX)/modulefiles/'

# example configs for test rules
install-testconfig:
	$(INSTALL_DIR) '$(DESTDIR)$(initdir)'
	$(INSTALL_DIR) '$(DESTDIR)$(etcdir)'
	$(INSTALL_DIR) '$(DESTDIR)$(prefix)/etc'
	$(INSTALL_DIR) '$(DESTDIR)$(modulefilesdir)'
	$(INSTALL_DIR) '$(DESTDIR)$(prefix)/test/modulefiles' '$(DESTDIR)$(prefix)/test/etc'
	$(INSTALL_DATA) $(addprefix $(EXAMPLE_MODFILES_SRCDIR)/,$(EXAMPLE_TESTCONFIG_MODFILES)) '$(DESTDIR)$(modulefilesdir)/'

uninstall-testconfig:
	rmdir '$(DESTDIR)$(prefix)/test/modulefiles' '$(DESTDIR)$(prefix)/test/etc' '$(DESTDIR)$(prefix)/test'
	rm -f $(foreach modfile,$(EXAMPLE_TESTCONFIG_MODFILES),'$(DESTDIR)$(modulefilesdir)/$(modfile)')
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(modulefilesdir)' || true
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(etcdir)' || true
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(initdir)' || true

install: all
	$(INSTALL_DIR) '$(DESTDIR)$(initdir)'
	$(INSTALL_DIR) '$(DESTDIR)$(initdir)/ksh-functions'
ifeq ($(initconfin),etcdir)
	$(INSTALL_DIR) '$(DESTDIR)$(etcdir)'
endif
ifeq ($(makebashcompdir),y)
	$(INSTALL_DIR) '$(DESTDIR)$(bashcompletiondir)'
endif
ifeq ($(makefishcompdir),y)
	$(INSTALL_DIR) '$(DESTDIR)$(fishcompletiondir)'
endif
	$(INSTALL_DIR) '$(DESTDIR)$(zshcompletiondir)'
	$(INSTALL_DIR) '$(DESTDIR)$(modulefilesdir)'
	$(INSTALL_DATA) $(ALL_SHELLS) '$(DESTDIR)$(initdir)/'
ifeq ($(windowssupport),y)
	$(INSTALL_DATA) cmd.cmd '$(DESTDIR)$(initdir)/'
endif
ifeq ($(makefishcompdir),y)
	$(INSTALL_DATA) fish_completion '$(DESTDIR)$(fishcompletiondir)/module.fish'
else
	$(INSTALL_DATA) fish_completion '$(DESTDIR)$(fishcompletiondir)/'
endif
ifeq ($(makebashcompdir),y)
	$(INSTALL_DATA) bash_completion '$(DESTDIR)$(bashcompletiondir)/module'
	ln -s module '$(DESTDIR)$(bashcompletiondir)/ml'
else
	$(INSTALL_DATA) bash_completion '$(DESTDIR)$(bashcompletiondir)/'
endif
	$(INSTALL_DATA) zsh-functions/_module '$(DESTDIR)$(zshcompletiondir)/'
	$(INSTALL_DATA) ksh '$(DESTDIR)$(initdir)/ksh-functions/module'
	$(INSTALL_DATA) ksh '$(DESTDIR)$(initdir)/ksh-functions/ml'
	$(INSTALL_DATA) initrc '$(DESTDIR)$(initrc)'
ifeq ($(setmodulespath),y)
	$(INSTALL_DATA) modulespath $(DESTDIR)$(modulespath)
endif
ifeq ($(examplemodulefiles),y)
	$(INSTALL_DATA) $(addprefix $(EXAMPLE_MODFILES_SRCDIR)/,$(EXAMPLE_MODFILES)) '$(DESTDIR)$(modulefilesdir)/'
endif
ifeq ($(versioning),y)
	$(INSTALL_DIR) '$(DESTDIR)$(versdir)'
	$(INSTALL_DATA) $(EXAMPLE_MODFILES_SRCDIR)/version '$(DESTDIR)$(versdir)/$(VERSION)'
endif

uninstall:
	rm -f $(foreach initscript,$(ALL_SHELLS),'$(DESTDIR)$(initdir)/$(initscript)')
ifeq ($(windowssupport),y)
	rm -f '$(DESTDIR)$(initdir)/cmd.cmd'
endif
	rm -f '$(DESTDIR)$(initdir)/ksh-functions/module'
	rm -f '$(DESTDIR)$(initdir)/ksh-functions/ml'
ifeq ($(makebashcompdir),y)
	rm -f '$(DESTDIR)$(bashcompletiondir)/ml'
	rm -f '$(DESTDIR)$(bashcompletiondir)/module'
else
	rm -f '$(DESTDIR)$(bashcompletiondir)/bash_completion'
endif
ifeq ($(makefishcompdir),y)
	rm -f '$(DESTDIR)$(fishcompletiondir)/module.fish'
else
	rm -f '$(DESTDIR)$(fishcompletiondir)/fish_completion'
endif
	rm -f '$(DESTDIR)$(zshcompletiondir)/_module'
	rm -f '$(DESTDIR)$(modulespath)' '$(DESTDIR)$(initrc)'
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(modulefilesdir)' || true
	@if [ -d '$(DESTDIR)$(modulefilesdir)' ]; then echo; echo "WARNING: '$(DESTDIR)$(modulefilesdir)' is not empty so skip removal" >&2; echo; fi
	rmdir '$(DESTDIR)$(initdir)/ksh-functions'
ifeq ($(makebashcompdir),y)
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(bashcompletiondir)' || true
endif
ifeq ($(makefishcompdir),y)
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(fishcompletiondir)' || true
endif
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(zshcompletiondir)' || true
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(initdir)' || true
	@if [ -d '$(DESTDIR)$(initdir)' ]; then echo; echo "WARNING: '$(DESTDIR)$(initdir)' is not empty so skip removal" >&2; echo; fi
ifeq ($(versioning),y)
	rm -f '$(DESTDIR)$(versdir)/$(VERSION)'
	$(RMDIR_IGN_NON_EMPTY) '$(DESTDIR)$(versdir)' || true
	@if [ -d '$(DESTDIR)$(versdir)' ]; then echo; echo "WARNING: '$(DESTDIR)$(versdir)' is not empty so skip removal" >&2; echo; fi
endif

clean:
	rm -f $(ALL_SHELLS) initrc bash_completion zsh-functions/_module modulespath $(EXAMPLE_MODFILES_SRCDIR)/modules
ifeq ($(versioning),y)
	rm -f $(EXAMPLE_MODFILES_SRCDIR)/version
endif

# quiet all commands unless verbose mode set
ifeq ($(VERBOSE),1)
V = 1
endif
# let verbose by default the install/clean/test and other specific non-build targets
$(V).SILENT: sh ksh bash zsh csh tcsh fish perl.pm python.py ruby.rb lisp tcl \
	cmake r.R bash_completion tcsh_completion zsh-functions/_module profile.sh \
	profile.csh modulespath initrc $(EXAMPLE_MODFILES_SRCDIR)/modules \
	$(EXAMPLE_MODFILES_SRCDIR)/version pwsh.ps1
