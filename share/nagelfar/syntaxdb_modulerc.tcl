#
# SYNTAXDB_MODULERC.tcl, Nagelfar syntax database to lint modulercs
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
ModulesVersion
ModuleTool
ModuleToolVersion
}
lappend ::knownCommands {*}{
hide-modulefile
hide-version
is-loaded
is-used
lsb-release
module-alias
module-forbid
module-hide
module-info
module-tag
module-version
module-virtual
module-warn
modulepath-ignore
modulepath-label
system
uname
versioncmp
}

# syntax
set ::syntax(hide-modulefile) 1
set ::syntax(hide-version) 1
set ::syntax(is-loaded) x*
set ::syntax(is-used) x*
set ::syntax(lsb-release) s
set ::syntax(module-alias) 2
# module-forbid accepts option at any position
set ::syntax(module-forbid) {p* x p* x* p*}
# module-hide accepts option at any position
set ::syntax(module-hide) {o* x o* x* o*}
set ::syntax(module-info) {s x?}
set {::syntax(module-info alias)} 1
set {::syntax(module-info command)} x?
set {::syntax(module-info loaded)} 1
set {::syntax(module-info mode)} x?
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
set ::syntax(modulepath-ignore) {x x*}
set ::syntax(modulepath-label) 2
set ::syntax(system) {x x*}
set ::syntax(uname) s
set ::syntax(versioncmp) 2
# not implemented commands
set {::syntax(module-info flags)} 0
set {::syntax(module-info trace)} 0
set {::syntax(module-info tracepat)} 0
set {::syntax(module-info user)} x?

# return
set ::return(is-loaded) int
set ::return(is-used) int
set ::return(system) int
set ::return(versioncmp) int
set {::return(module-info flags)} int

# subCmd
set ::subCmd(lsb-release) {id release codename}
set ::subCmd(module-info) {alias command loaded mode name shell shelltype\
   specified symbols tags type usergroups username version user trace\
   tracepat flags}
set ::subCmd(uname) {sysname nodename domain release version machine}

# option
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

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
