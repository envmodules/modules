#
# SYNTAXDB_MODULEFILE.tcl, Nagelfar syntax database to lint modulefiles
# Copyright (C) 2022-2026 Xavier Delaruelle
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

##########################################################################

lappend ::knownGlobals {*}{
ModulesCurrentModulefile
ModuleTool
ModuleToolVersion
ModuleVariant
}

lappend ::knownCommands {*}{
add-property
always-load
append-path
chdir
complete
conflict
depends-on
depends-on-any
extensions
family
getenv
getvariant
haveDynamicMPATH
is-avail
is-loaded
is-saved
is-used
lsb-release
module
module-alias
module-forbid
module-help
module-hide
module-info
module-tag
module-version
module-virtual
module-warn
module-whatis
modulepath-label
prepend-path
prereq
prereq-all
prereq-any
provide
pushenv
remove-path
reportError
reportWarning
require-fullname
set-alias
set-function
setenv
source-sh
system
uname
uncomplete
unset-alias
unset-function
unsetenv
variant
versioncmp
x-resource
remove-property
module-log
module-trace
module-user
module-verbosity
}

# syntax
set ::syntax(add-property) 2
set ::syntax(always-load) {o* x x*}
set ::syntax(append-path) {o* x x x*}
set ::syntax(chdir) 1
set ::syntax(complete) 3
set ::syntax(conflict) {x x*}
set ::syntax(depends-on) {o* x x*}
set ::syntax(depends-on-any) {o* x x*}
set ::syntax(extensions) {x x*}
set ::syntax(family) 1
set ::syntax(getenv) {o? x x?}
set ::syntax(getvariant) {o? x x?}
set ::syntax(haveDynamicMPATH) 0
set ::syntax(is-avail) {x x*}
set ::syntax(is-loaded) x*
set ::syntax(is-saved) x*
set ::syntax(is-used) x*
set ::syntax(lsb-release) s
set {::syntax(lsb-release id)} 0
set {::syntax(lsb-release codename)} 0
set {::syntax(lsb-release release)} 0
# module accepts option at any position
set ::syntax(module) {s x*}
set {::syntax(module add)} {o* x* o*}
set {::syntax(module load)} {o* x* o*}
set {::syntax(module try-add)} {o* x* o*}
set {::syntax(module try-load)} {o* x* o*}
set {::syntax(module add-any)} {o* x* o*}
set {::syntax(module load-any)} {o* x* o*}
set {::syntax(module remove)} {o* x* o*}
set {::syntax(module rm)} {o* x* o*}
set {::syntax(module delete)} {o* x* o*}
set {::syntax(module unload)} {o* x* o*}
set {::syntax(module swap)} {o* x* o*}
set {::syntax(module switch)} {o* x* o*}
set {::syntax(module unuse)} {o* x* o*}
set {::syntax(module aliases)} 0
set {::syntax(module initclear)} 0
set {::syntax(module initlist)} 0
set {::syntax(module purge)} 0
set {::syntax(module reload)} 0
set {::syntax(module update)} 0
set {::syntax(module use)} x*
set {::syntax(module available)} x*
set {::syntax(module avail)} x*
set {::syntax(module show)} x*
set {::syntax(module display)} x*
set {::syntax(module initload)} x*
set {::syntax(module initadd)} x*
set {::syntax(module initprepend)} x*
set {::syntax(module initunload)} x*
set {::syntax(module initrm)} x*
set {::syntax(module initswap)} x*
set {::syntax(module initswitch)} x*
set {::syntax(module list)} x*
set {::syntax(module restore)} x*
set {::syntax(module save)} x*
set {::syntax(module savelist)} x*
set {::syntax(module saverm)} x*
set {::syntax(module disable)} x*
set {::syntax(module saveshow)} x*
set {::syntax(module describe)} x*
set {::syntax(module apropos)} x*
set {::syntax(module keyword)} x*
set {::syntax(module search)} x*
set {::syntax(module test)} x*
set {::syntax(module whatis)} x*
set ::syntax(module-alias) 2
# module-forbid accepts option at any position
set ::syntax(module-forbid) {p* x p* x* p*}
set ::syntax(module-help) 1
# module-hide accepts option at any position
set ::syntax(module-hide) {o* x o* x* o*}
set ::syntax(module-info) {s x?}
set {::syntax(module-info alias)} 1
set {::syntax(module-info command)} x?
set {::syntax(module-info loaded)} 1
set {::syntax(module-info mode)} x?
set {::syntax(module-info modulename)} 0
set {::syntax(module-info moduleversion)} 0
set {::syntax(module-info name)} 0
set {::syntax(module-info shell)} x?
set {::syntax(module-info shelltype)} x?
set {::syntax(module-info specified)} 0
set {::syntax(module-info symbols)} 1
set {::syntax(module-info tags)} x?
set {::syntax(module-info type)} 0
set {::syntax(module-info usergroups)} x?
set {::syntax(module-info username)} x?
set {::syntax(module-info version)} 1
# module-tag accepts option at any position
set ::syntax(module-tag) {p* x p* x p* x* p*}
set ::syntax(module-version) {x x x*}
set ::syntax(module-virtual) 2
# module-warn accepts option at any position
set ::syntax(module-warn) {p* x p* x* p*}
set ::syntax(module-whatis) 1
set ::syntax(modulepath-label) 2
set ::syntax(prepend-path) {o* x x x*}
set ::syntax(prereq) {o* x x*}
set ::syntax(prereq-all) {o* x x*}
set ::syntax(prereq-any) {o* x x*}
set ::syntax(provide) {x x*}
set ::syntax(pushenv) 2
set ::syntax(remove-path) {o* x x x* p? x*}
set ::syntax(reportError) 1
set ::syntax(reportWarning) 1
set ::syntax(require-fullname) 0
set ::syntax(set-alias) 2
set ::syntax(set-function) 2
# setenv accepts option at any position
set ::syntax(setenv) {o? x o? x o?}
set ::syntax(source-sh) {o* x x x*}
set ::syntax(system) {x x*}
set ::syntax(uname) s
set {::syntax(uname sysname)} 0
set {::syntax(uname nodename)} 0
set {::syntax(uname domain)} 0
set {::syntax(uname release)} 0
set {::syntax(uname version)} 0
set {::syntax(uname machine)} 0
set ::syntax(uncomplete) 1
set ::syntax(unset-alias) 1
set ::syntax(unset-function) 1
# unsetenv accepts option at any position
set ::syntax(unsetenv) {o* x o* x? o*}
set ::syntax(variant) {o* x x*}
set ::syntax(versioncmp) 2
set ::syntax(x-resource) 1
# not implemented commands
set ::syntax(remove-property) 2
set {::syntax(module-info flags)} 0
set {::syntax(module-info trace)} 0
set {::syntax(module-info tracepat)} 0
set {::syntax(module-info user)} x?
set ::syntax(module-log) 2
set ::syntax(module-trace) {x x*}
set ::syntax(module-user) 1
set ::syntax(module-verbosity) 1

# return
set ::return(is-avail) int
set ::return(is-loaded) int
set ::return(is-saved) int
set ::return(is-used) int
set ::return(system) int
set ::return(versioncmp) int
set {::return(module-info flags)} int

# subCmd
set ::subCmd(lsb-release) {id release codename}
set ::subCmd(module) {add load add-any load-any swap switch try-add try-load\
   remove rm delete unload unuse use aliases available avail show display\
   initadd initload initclear initlist initprepend initunload initrm\
   initswap initswitch list purge reload restore save savelist saverm disable\
   saveshow describe apropos keyword search test update whatis}
set ::subCmd(module-info) {alias command loaded mode modulename moduleversion\
   name shell shelltype specified symbols tags type usergroups username\
   version user trace tracepat flags}
set ::subCmd(uname) {sysname nodename domain release version machine}

# option
set ::option(always-load) {--optional --tag}
set {::option(always-load --tag)} 1
set ::option(append-path) {-d --delim --duplicates --ignore-refcount}
set {::option(append-path -d)} 1
set {::option(append-path --delim)} 1
set ::option(depends-on) {--optional --tag}
set {::option(depends-on --tag)} 1
set ::option(depends-on-any) {--optional --tag}
set {::option(depends-on-any --tag)} 1
set ::option(getenv) --return-value
set ::option(getvariant) --return-value
set {::option(module add)} {--tag --not-req}
set {::option(module add --tag)} 1
set {::option(module load)} {--tag --not-req}
set {::option(module load --tag)} 1
set {::option(module try-add)} {--tag --not-req}
set {::option(module try-add --tag)} 1
set {::option(module try-load)} {--tag --not-req}
set {::option(module try-load --tag)} 1
set {::option(module add-any)} {--tag --not-req}
set {::option(module add-any --tag)} 1
set {::option(module load-any)} {--tag --not-req}
set {::option(module load-any --tag)} 1
set {::option(module remove)} {--tag --not-req}
set {::option(module remove --tag)} 1
set {::option(module rm)} {--tag --not-req}
set {::option(module rm --tag)} 1
set {::option(module delete)} {--tag --not-req}
set {::option(module delete --tag)} 1
set {::option(module unload)} {--tag --not-req}
set {::option(module unload --tag)} 1
set {::option(module swap)} {--tag --not-req}
set {::option(module swap --tag)} 1
set {::option(module switch)} {--tag --not-req}
set {::option(module switch --tag)} 1
set {::option(module unuse)} {--remove-on-unload --noop-on-unload\
   --append-on-unload --prepend-on-unload}
set ::option(module-forbid) {--user --group --not-user --not-group --after\
   --before --message --nearly-message}
set {::option(module-forbid --user)} 1
set {::option(module-forbid --group)} 1
set {::option(module-forbid --not-user)} 1
set {::option(module-forbid --not-group)} 1
set {::option(module-forbid --after)} 1
set {::option(module-forbid --before)} 1
set ::option(module-hide) {--user --group --not-user --not-group --after\
   --before --soft --hard --hidden-loaded}
set {::option(module-hide --user)} 1
set {::option(module-hide --group)} 1
set {::option(module-hide --not-user)} 1
set {::option(module-hide --not-group)} 1
set {::option(module-hide --after)} 1
set {::option(module-hide --before)} 1
set ::option(module-tag) {--user --group --not-user --not-group}
set {::option(module-tag --user)} 1
set {::option(module-tag --group)} 1
set {::option(module-tag --not-user)} 1
set {::option(module-tag --not-group)} 1
set ::option(module-warn) {--user --group --not-user --not-group --after\
   --before --message}
set {::option(module-warn --user)} 1
set {::option(module-warn --group)} 1
set {::option(module-warn --not-user)} 1
set {::option(module-warn --not-group)} 1
set {::option(module-warn --after)} 1
set {::option(module-warn --before)} 1
set ::option(prepend-path) {-d --delim --duplicates --ignore-refcount}
set {::option(prepend-path -d)} 1
set {::option(prepend-path --delim)} 1
set ::option(prereq) {--optional --tag}
set {::option(prereq --tag)} 1
set ::option(prereq-all) {--optional --tag}
set {::option(prereq-all --tag)} 1
set ::option(prereq-any) {--optional --tag}
set {::option(prereq-any --tag)} 1
set ::option(remove-path) {-d --delim --glob --index --ignore-refcount\
   --remove-on-unload --noop-on-unload --append-on-unload\
   --prepend-on-unload}
set {::option(remove-path -d)} 1
set {::option(remove-path --delim)} 1
set ::option(setenv) --set-if-undef
set ::option(source-sh) --ignore
set {::option(source-sh --ignore)} 1
set ::option(unsetenv) {--noop-on-unload --unset-on-unload}
set ::option(variant) {--boolean --default}
set {::option(variant --default)} 1

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
