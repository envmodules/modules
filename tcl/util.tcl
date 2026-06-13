##########################################################################

# UTIL.TCL, utility procedures
# Copyright (C) 2002-2004 Mark Lakata
# Copyright (C) 2004-2017 Kent Mein
# Copyright (C) 2016-2026 Xavier Delaruelle
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

proc charEscaped {str {charlist " \\\\\t{}\\\[\\\]|<>!;#^\$&*?\"'`()"}} {
   return [regsub -all "\(\[$charlist\]\)" $str {\\\1}]
}

proc charUnescaped {str {charlist " \\\\\t{}\\\[\\\]|<>!;#^\$&*?\"'`()"}} {
   return [regsub -all "\\\\\(\[$charlist\]\)" $str {\1}]
}

proc escapeGlobChars {str} {
   return [charEscaped $str {*?[]\\}]
}

proc strTo {lang str {esc 1}} {
   switch -- $lang {
      tcl { set enco \{; set encc \}}
      shell { set enco '; set encc '}
   }
   # escape all special characters
   if {$esc} {
      set str [charEscaped $str]
   }
   # enclose if empty or if contain a space character unless already escaped
   if {$str eq {} || (!$esc && [regexp {\s} $str])} {
      set str "$enco$str$encc"
   }
   return $str
}

proc listTo {lang lst {esc 1}} {
   set lout [list]
   # transform each list element
   foreach str $lst {
      lappend lout [strTo $lang $str $esc]
   }
   return [join $lout { }]
}

proc runEnvCommand {env_list cmd args} {
   # set specific env
   set saved_env_list {}
   foreach {var val} $env_list {
      lappend saved_env_list $var [get-env $var <unset>]
      set ::env($var) $val
   }

   set res [runCommand $cmd {*}$args]

   # restore env
   foreach {var val} $saved_env_list {
      if {$val eq {<unset>}} {
         unset ::env($var)
      } else {
         set ::env($var) $val
      }
   }

   return $res
}

# find command path and remember it
proc getCommandPath {cmd} {
   return [lindex [auto_execok $cmd] 0]
}

# find then run command or raise error if command not found
proc runCommand {cmd args} {
   set cmdpath [getCommandPath $cmd]
   if {$cmdpath eq {}} {
      knerror "Command '$cmd' cannot be found" MODULES_ERR_GLOBAL
   } else {
      return [exec $cmdpath {*}$args]
   }
}

proc getAbsolutePath {path} {
   # currently executing a modulefile or rc, so get the directory of this file
   if {[currentState modulefile] ne {}} {
      set curdir [file dirname [currentState modulefile]]
   # elsewhere get module command current working directory
   } else {
      # register pwd at first call
      if {![isStateDefined cwd]} {
         # raise a global known error if cwd cannot be retrieved (especially
         # when this directory has been removed)
         if {[catch {setState cwd [pwd]} errorMsg]} {
            knerror $errorMsg
         }
      }
      set curdir [getState cwd]
   }

   # empty result if empty path
   if {$path eq {}} {
      set abspath {}
   # consider path absolute if it starts with a variable ref
   } elseif {[string index $path 0] eq {$}} {
      set abspath $path
   } else {
      set abslist {}
      # get a first version of the absolute path by joining the current
      # working directory to the given path. if given path is already absolute
      # 'file join' will not break it as $curdir will be ignored as soon a
      # beginning '/' character is found on $path. this first pass also clean
      # extra '/' character. then each element of the path is analyzed to
      # clear "." and ".." components.
      foreach elt [file split [file join $curdir $path]] {
         if {$elt eq {..}} {
            # skip ".." element if it comes after root element, remove last
            # element elsewhere
            if {[llength $abslist] > 1} {
               set abslist [lreplace $abslist end end]
            }
         # skip any "." element
         } elseif {$elt ne {.}} {
            lappend abslist $elt
         }
      }
      set abspath [file join {*}$abslist]
   }

   # return cleaned absolute path
   return $abspath
}

# if no exact match found but icase mode is enabled then search if an icase
# match exists among all array key elements, select dictionary highest version
# if multiple icase matches are returned
proc getArrayKey {arrname name icase} {
   if {$icase} {
      upvar $arrname arr
      if {![info exists arr($name)]} {
         foreach elt [lsort -dictionary -decreasing [array names arr]] {
            if {[string equal -nocase $name $elt]} {
               reportDebug "key '$elt' in array '$arrname' matches '$name'"
               set name $elt
               break
            }
         }
      }
   }
   return $name
}

# split string while ignore any separator character that is escaped
proc psplit {str sep} {
   # use standard split if no sep character found
   if {[string first \\$sep $str] == -1} {
      set res [split $str $sep]
   } else {
      set previdx -1
      set idx [string first $sep $str]
      while {$idx != -1} {
         # look ahead if found separator is escaped
         if {[string index $str $idx-1] ne "\\"} {
            # unescape any separator character when adding to list
            lappend res [charUnescaped [string range $str $previdx+1 $idx-1]\
               $sep]
            set previdx $idx
         }
         set idx [string first $sep $str $idx+1]
      }

      lappend res [charUnescaped [string range $str $previdx+1 end] $sep]
   }

   return $res
}

# join list while escape any character equal to separator
proc pjoin {lst sep} {
   # use standard join if no sep character found
   if {[string first $sep $lst] == -1} {
      set res [join $lst $sep]
   } else {
      set res {}
      foreach elt $lst {
         # preserve empty entries
         if {[info exists not_first]} {
            append res $sep
         } else {
            set not_first 1
         }
         # escape any separator character when adding to string
         append res [charEscaped $elt $sep]
      }
   }

   return $res
}

# Is provided string a version number: consider first element of string if
# '.' character used in it. [0-9af] on this first part is considered valid
# anything else could be used in latter elements
proc isVersion {str} {
   return [string is xdigit -strict [lindex [split $str .] 0]]
}

# Return number of occurrences of passed character in passed string
proc countChar {str char} {
   return [expr {[string length $str] - [string length [string map [list\
      $char {}] $str]]}]
}

proc lappendNoDup {lstname args} {
   set ret 0
   upvar $lstname lst
   foreach elt $args {
      if {![info exists lst] || $elt ni $lst} {
         lappend lst $elt
         set ret 1
      }
   }
   return $ret
}

proc replaceFromList {list1 item args} {
   set xi 0
   while {[set xi [lsearch -exact -start $xi $list1 $item]] != -1} {
      set list1 [lreplace $list1 $xi $xi {*}$args]
   }
   return $list1
}

proc lrem {lst_name item} {
   upvar $lst_name lst
   set lst [lsearch -inline -all -not -exact $lst $item]
}

# make lprepend rely on ledit if this command exists (Tcl 9+)
if {[string length [info commands ledit]]} {
   proc lprepend {lst_name args} {
      upvar $lst_name lst
      if {[info exists lst]} {
         ##nagelfar ignore
         ledit lst -1 -1 {*}$args
      } else {
         set lst $args
      }
   }
} else {
   proc lprepend {lst_name args} {
      upvar $lst_name lst
      if {[info exists lst]} {
         set lst [list {*}$args {*}$lst]
      } else {
         set lst $args
      }
   }
}

# provide a lpop proc if this command does not exist (Tcl <9)
# this proc only supports removing first or last item from list
if {![string length [info commands lpop]]} {
   ##nagelfar ignore Procedure
   proc lpop {lst_name {idx end}} {
      upvar $lst_name lst
      ##nagelfar ignore Badly formed if statement
      lassign [if {$idx eq {end}} {list 0 end-1} {list 1 end}] first last
      set lst [lrange $lst $first $last]
   }
}

# test if 2 lists have at least one element in common
proc isIntBetweenList {list1 list2} {
   foreach elt $list1 {
      if {$elt in $list2} {
         return 1
      }
   }
   return 0
}

# test if 2 lists have at least one element in diff
proc isDiffBetweenList {list1 list2} {
   foreach elt $list1 {
      if {$elt ni $list2} {
         return 1
      }
   }
   return 0
}

# returns elements from list1 not part of list2 and elements from list2 not
# part of list1
proc getDiffBetweenList {list1 list2} {
   set res1 [list]
   set res2 [list]

   foreach elt $list1 {
      if {$elt ni $list2} {
         lappend res1 $elt
      }
   }
   foreach elt $list2 {
      if {$elt ni $list1} {
         lappend res2 $elt
      }
   }

   return [list $res1 $res2]
}

# return intersection of all lists: elements present in every list
proc getIntersectBetweenList {args} {
   foreach lst $args {
      if {![info exists res]} {
         set cur_res $lst
      } else {
         set cur_res [list]
         foreach elt $res {
            if {$elt in $lst} {
               lappend cur_res $elt
            }
         }
      }
      set res $cur_res
      # stop when intersection result becomes empty
      if {![llength $res]} {
         break
      }
   }
   return $res
}

# return elements from arr1 not in arr2, elements from arr1 in arr2 but with a
# different value and elements from arr2 not in arr1.
# if notset_equals_empty is enabled, not-set element in array is equivalent to
# element set to an empty value.
# if unordered_lists_compared is enabled, value of array element is considered
# a list and difference between list entries is made (order insensitive)
proc getDiffBetweenArray {arrname1 arrname2 {notset_equals_empty 0}\
   {unordered_lists_compared 0}} {
   upvar $arrname1 arr1
   upvar $arrname2 arr2
   set notin2 [list]
   set diff [list]
   set notin1 [list]

   foreach name [array names arr1] {
      # element in arr1 not in arr2
      if {![info exists arr2($name)]} {
         if {!$notset_equals_empty} {
            lappend notin2 $name
         # if we consider a not-set entry equal to an empty value, there is a
         # difference only if entry in the other array is not empty
         } elseif {$arr1($name) ne {}} {
            lappend diff $name
         }
      # element present in both arrays but with a different value
      } elseif {!$unordered_lists_compared} {
         # but with a different value
         if {$arr1($name) ne $arr2($name)} {
            lappend diff $name
         }
      } else {
         # with a different value, not considering order
         lassign [getDiffBetweenList $arr1($name) $arr2($name)] notin2 notin1
         if {[llength $notin2] || [llength $notin1]} {
            lappend diff $name
         }
      }
   }

   foreach name [array names arr2] {
      # element in arr2 not in arr1
      if {![info exists arr1($name)]} {
         if {!$notset_equals_empty} {
            lappend notin1 $name
         } elseif {$arr2($name) ne {}} {
            lappend diff $name
         }
      }
   }

   return [list $notin2 $diff $notin1]
}

proc getCallingProcName {} {
   if {[info level] > 2} {
      return [lindex [info level -2] 0]
   }
}

proc replaceFirstInStr {str old new} {
   set start_idx [string first $old $str]
   if {$start_idx == -1} {
      return $str
   }
   set end_idx [expr {$start_idx + [string length $old] - 1}]
   return [string replace $str $start_idx $end_idx $new]
}

# ;;; Local Variables:
# ;;; Mode: tcl-mode
# ;;; tcl-indent-level: 3
# ;;; tcl-continued-indent-level: 3
# ;;; indent-tabs-mode: nil
# ;;; End:
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
