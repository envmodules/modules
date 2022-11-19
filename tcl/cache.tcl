##########################################################################

# CACHE.TCL, cache management procedures
# Copyright (C) 2022 Xavier Delaruelle
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

# Get full path name of module cache file for given modulepath
proc getModuleCacheFilename {modpath} {
   return $modpath/.modulecache
}

# Build cache file content for given modulepath
proc formatModuleCacheContent {modpath} {
   set content {}
   # collect files from modulepath directory
   array set found_list [findModules $modpath * 0 1]

   # build cache entry for every file found
   foreach elt [lsort [array names found_list]] {
      set entry_list [list]
      set fetch_content 0
      switch -- [lindex $found_list($elt) 0] {
         modulerc {
            lappend entry_list modulerc-content $elt
            set fetch_content 1
         }
         modulefile {
            lappend entry_list modulefile-content $elt [lindex\
               $found_list($elt) 1]
            set fetch_content 1
         }
         default {
            # also record obtained error to get all the information to cover
            # everything fetched by findModules. only modulefile validity is
            # checked in findModules
            lappend entry_list modulefile-invalid $elt {*}[lrange\
               $found_list($elt) 0 1]
         }
      }
      # fetch file content
      if {$fetch_content} {
         if {[catch {
            set fcontent [readFile $modpath/$elt]
            # extract module header from the start of the file
            if {![regexp {^#%Module[0-9\.]*} [string range $fcontent 0 32]\
               fheader]} {
               set fheader {}
            }
            lappend entry_list $fheader $fcontent
         } errMsg]} {
            # rethrow read error after parsing message
            knerror [parseAccessIssue $modpath/$elt]
         }
      }
      # format cache entry
      append content "\n$entry_list"
   }

   # prepend header if some content has been generated
   if {[string length $content] != 0} {
      set content "#%Module$content"
   }

   return $content
}

# ;;; Local Variables: ***
# ;;; mode:tcl ***
# ;;; End: ***
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
