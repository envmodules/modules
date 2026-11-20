##Nagelfar Plugin : modulecache-specific notices
#
# PLUGIN_MODULECACHE.tcl, Nagelfar plugin to lint modulecaches
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

# ignore indentation of modulefile/modulerc content argument
proc statementWords {words info} {
   set res {}
   switch [lindex $words 0] {
      modulefile-content - modulerc-content {
         lappend res comment {##nagelfar ignore #4096 Found non indented\
            close brace that did not end statement}
         lappend res comment {##nagelfar ignore #4096 Suspicious # char.\
            Possibly a bad comment.}
      }
   }
   return $res
}

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
