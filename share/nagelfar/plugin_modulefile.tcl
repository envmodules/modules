##Nagelfar Plugin : modulefile-specific notices
#
# PLUGIN_MODULEFILE.tcl, Nagelfar plugin to lint modulefiles
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

# report deprecated/not implemented/not recommended usages
proc statementWords {words info} {
   set res {}
   switch [lindex $words 0] {
      module-log - module-trace - module-user - module-verbosity {
         set res [list warning "Command \"[lindex $words 0]\" is deprecated\
            and not implemented"]
      }
      module-info {
         if {[lindex $words 1] in {flags trace tracepat user}} {
            set res [list warning "Command \"[lrange $words 0 1]\" is\
               deprecated and not implemented"]
         }
      }
      remove-property {
         set res [list warning "Command \"[lindex $words 0]\" is not\
            implemented"]
      }
      module {
         if {[lindex $words 1] in {aliases available avail show display\
            initload initadd initclear initlist initprepend initunload initrm\
            initswitch list purge reload restore save savelist saverm\
            saveshow search test whatis}} {
            set res [list warning "Command \"[lrange $words 0 1]\" should not\
               be used in modulefile"]
         }
      }
   }
   return $res
}

# adapt statements that Nagelfar cannot correctly check as is: translate
# known '--option=value' arguments into '--option value' and hide the leading
# dash of regular expression arguments
proc statementRaw {stmt info} {
   set res {}
   regexp {^(.+?)\s} $stmt match cmd
   if {$cmd in {append-path prepend-path remove-path always-load depends-on\
      module prereq prereq-all prereq-any}} {
      if {[regsub -all {(--(delim|tag))=} $stmt {\1 } newstmt]} {
         set res [list replace $newstmt]
      }
   } elseif {$cmd in {module-forbid module-hide module-tag module-warn}} {
      set res [stripRegexpLeadingDash $stmt]
   }
   return $res
}

# when --regexp option is set, module arguments are regular expressions that
# may start with a dash character. Nagelfar would report them as bad options,
# so this leading dash is removed unless argument looks like a long option
proc stripRegexpLeadingDash {stmt} {
   set res {}
   if {[regexp {\s--regexp(\s|$)} $stmt] && [regsub -all\
      {(\s[\{"]?)-(?!-[a-z])} $stmt {\1} newstmt]} {
      set res [list replace $newstmt]
   }
   return $res
}

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
