##Nagelfar Plugin : global rc-specific notices
#
# PLUGIN_GLOBALRC.tcl, Nagelfar plugin to lint global rc files
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

# report deprecated/not implemented/not recommended usages
proc statementWords {words info} {
   set res {}
   switch [lindex $words 0] {
      always-load - append-path - chdir - complete - conflict - depends-on -\
      extensions - family - getenv - getvariant - is-avail - is-saved -\
      module - module-whatis - prepend-path - prereq - prereq-all -\
      prereq-any - pushenv - remove-path - reportError - reportWarning -\
      require-fullname - set-alias - set-function - setenv - source-sh -\
      umask - uncomplete - unset-alias - unset-function - unsetenv - variant\
      - x-resource - add-property - remove-property - module-log -\
      module-trace - module-user - module-verbosity {
         set res [list warning "Command \"[lindex $words 0]\" should not be\
            be used in global rc file"]
      }
      module-info {
         if {[lindex $words 1] in {flags trace tracepat user}} {
            set res [list warning "Command \"[lrange $words 0 1]\" is\
               deprecated and not implemented"]
         }
      }
   }
   return $res
}

# translate known '--option=value' arguments into '--option value' to
# correctly check them with Nagelfar
proc statementRaw {stmt info} {
   set res {}
   regexp {^(.+?)\s} $stmt match cmd
   if {$cmd in {append-path prepend-path remove-path always-load depends-on\
      module prereq prereq-all prereq-any}} {
      if {[regsub -all {(--(delim|tag))=} $stmt {\1 } newstmt]} {
         set res [list replace $newstmt]
      }
   }
   return $res
}

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
