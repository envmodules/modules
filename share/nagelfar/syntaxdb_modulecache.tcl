#
# SYNTAXDB_MODULECACHE.tcl, Nagelfar syntax database to lint modulecaches
# Copyright (C) Modules Contributors
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

lappend ::knownCommands {*}{
modulefile-content
modulerc-content
modulefile-invalid
limited-access-file
limited-access-directory
}

# syntax
set ::syntax(modulefile-content) 4
set ::syntax(modulerc-content) 3
set ::syntax(modulefile-invalid) 3
set ::syntax(limited-access-file) 1
set ::syntax(limited-access-directory) 1

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
