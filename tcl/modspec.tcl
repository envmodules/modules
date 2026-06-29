##########################################################################

# MODSPEC.TCL, module specification procedures
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

# Define procedure to get how many parts between passed name and mod are equal
# Adapt procedure code whether icase is enabled or disabled
proc defineModStartNbProc {icase} {
   set procname modStartNbProc
   if {$icase} {
      append procname Icase
   }
   # define proc if not done yet or if it was defined for another context
   if {[info procs modStartNb] eq {} || $::g_modStartNb_proc ne $procname} {
      if {[info exists ::g_modStartNb_proc]} {
         # remove existing debug trace if any
         initProcReportTrace remove modStartNb
         rename ::modStartNb ::$::g_modStartNb_proc
      }
      ##nagelfar syntax modStartNb x x
      rename ::$procname ::modStartNb
      # set report traces if some debug mode enabled
      initProcReportTrace add modStartNb
      set ::g_modStartNb_proc $procname
   }
}

# alternative definitions of modStartNb proc
proc modStartNbProc {mod name} {
   # first compare against name's parent chunk by chunk
   set modname [getModuleNameFromVersSpec $name]
   if {$modname eq {.}} {
      set i 0
      set imax 0
   } else {
      set namesplit [split $modname /]
      set modsplit [split $mod /]
      set imax [tcl::mathfunc::min [llength $namesplit] [llength $modsplit]]
      for {set i 0} {$i < $imax} {incr i} {
         if {![string equal [lindex $modsplit $i] [lindex $namesplit $i]]} {
            break
         }
      }
   }
   # if name's parent matches check if full name also matches
   if {$i == $imax && [modEq $name $mod eqstart]} {
      incr i
   }
   return $i
}
proc modStartNbProcIcase {mod name} {
   set modname [getModuleNameFromVersSpec $name]
   if {$modname eq {.}} {
      set i 0
      set imax 0
   } else {
      set namesplit [split $modname /]
      set modsplit [split $mod /]
      ##nagelfar ignore #2 Badly formed if statement
      set imax [if {[llength $namesplit] < [llength $modsplit]} {llength\
         $namesplit} {llength $modsplit}]
      for {set i 0} {$i < $imax} {incr i} {
         if {![string equal -nocase [lindex $modsplit $i] [lindex $namesplit\
            $i]]} {
            break
         }
      }
   }
   if {$i == $imax && [modEq $name $mod eqstart]} {
      incr i
   }
   return $i
}

# Define procedure to compare module names set as array keys against pattern.
# Adapt procedure code whether implicit_default is enabled or disabled
proc defineGetEqArrayKeyProc {impdfl} {
   set procname getEqArrayKeyProc
   if {$impdfl} {
      append procname Impdfl
   }

   # define proc if not done yet or if it was defined for another context
   if {[info procs getEqArrayKey] eq {} || $::g_getEqArrayKey_proc ne\
      $procname} {
      if {[info exists ::g_getEqArrayKey_proc]} {
         # remove existing debug trace if any
         initProcReportTrace remove getEqArrayKey
         rename ::getEqArrayKey ::$::g_getEqArrayKey_proc
      }
      ##nagelfar syntax getEqArrayKey x x
      rename ::$procname ::getEqArrayKey
      # set report traces if some debug mode enabled
      initProcReportTrace add getEqArrayKey
      set ::g_getEqArrayKey_proc $procname
   }
}

# alternative definitions of getEqArrayKey proc
proc getEqArrayKeyProcImpdfl {arrname name} {
   set icase [isIcase]
   upvar $arrname arr

   # extract single module specified if any
   lassign [getModuleVersSpec $name] mod modname
   # check name eventual icase match
   set mod [getArrayKey arr [string trimright $mod /] $icase]

   if {$mod ne {} && [info exists arr($mod)]} {
      set match $mod
   } else {
      set mlist {}
      foreach elt [array names arr] {
         if {[modEq $name $elt]} {
            lappend mlist $elt
         }
      }
      if {[llength $mlist] == 1} {
         set match [lindex $mlist 0]
      # in case multiple modules match query, check directory default and
      # return it if it is part of match list, elsewhere return highest result
      } elseif {[llength $mlist] > 1} {
         # get corresponding icase parent directory
         set pname [getArrayKey arr $modname $icase]
         if {[info exists arr($pname)]} {
            set dfl $pname/[lindex $arr($pname) 1]
         }
         # resolve symbolic version entries
         foreach elt $mlist {
            if {[lindex $arr($elt) 0] eq {version}} {
               lappend mrlist [lindex $arr($elt) 1]
            } else {
               lappend mrlist $elt
            }
         }
         if {[info exists dfl] && $dfl in $mrlist} {
            set match $dfl
         } else {
            set match [lindex [lsort -dictionary $mrlist] end]
         }
      }
   }
   if {[info exists match]} {
      reportDebug "key '$match' in array '$arrname' matches '$name'"
      set name $match
   }
   return $name
}
proc getEqArrayKeyProc {arrname name} {
   set icase [isIcase]
   upvar $arrname arr

   lassign [getModuleVersSpec $name] mod modname cmpspec versspec modnamere\
      modescglob modroot variantlist modnvspec
   # check name eventual icase match
   set mod [getArrayKey arr [string trimright $mod /] $icase]

   if {$mod ne {} && [info exists arr($mod)]} {
      set match $mod
   } else {
      set mlist {}
      foreach elt [array names arr] {
         if {[modEq $name $elt]} {
            lappend mlist $elt
         }
      }
      # must have a default part of result even if only one result
      if {[llength $mlist] >= 1} {
         # get corresponding icase parent directory
         set pname [getArrayKey arr $modname $icase]
         if {[info exists arr($pname)]} {
            set dfl $pname/[lindex $arr($pname) 1]
         }
         # resolve symbolic version entries
         foreach elt $mlist {
            if {[lindex $arr($elt) 0] eq {version}} {
               lappend mrlist [lindex $arr($elt) 1]
            } else {
               lappend mrlist $elt
            }
         }
         if {[info exists dfl] && $dfl in $mrlist} {
            set match $dfl
         } else {
            # raise error as no default part of result
            upvar retlist retlist
            set retlist [list {} $modnvspec $name none "No default version\
               defined for '$name'"]
         }
      }
   }
   if {[info exists match]} {
      reportDebug "key '$match' in array '$arrname' matches '$name'"
      set name $match
   }
   return $name
}

# Check a module name does match query at the depth level expressed in query
# when search mode is not contains. Define procedure on the fly to adapt its
# code to search configuration option and querydepth and test mode params.
proc defineDoesModMatchAtDepthProc {contains querydepth test} {
   set procprops $contains:$querydepth:$test

   # define proc if not done yet or if it was defined for another context
   if {[info procs doesModMatchAtDepth] eq {} ||\
      $::g_doesModMatchAtDepth_procprops ne $procprops} {
      if {[info exists ::g_doesModMatchAtDepth_procprops]} {
         # remove existing debug trace if any
         initProcReportTrace remove doesModMatchAtDepth
         rename ::doesModMatchAtDepth {}
      }
      set ::g_doesModMatchAtDepth_procprops $procprops

      # define optimized procedure
      if {$contains} {
         set atdepth {$mod}
      } else {
         set atdepth "\[join \[lrange \[split \$mod /\] 0 $querydepth\] /\]"
      }
      ##nagelfar syntax doesModMatchAtDepth x
      ##nagelfar ignore Non constant argument to proc
      proc doesModMatchAtDepth {mod} "return \[modEqStatic $atdepth $test *\]"
      # set report traces if some debug mode enabled
      initProcReportTrace add doesModMatchAtDepth
   }
}

proc extendedDefaultCharGlobMatch {} {
   return {.*}
}

# Define procedure to check module version equals pattern. Adapt procedure
# code whether icase and extended_default are enabled or disabled
proc defineModVersCmpProc {icase extdfl} {
   set procname modVersCmpProc
   if {$icase} {
      append procname Icase
   }
   if {$extdfl} {
      append procname Extdfl
   }

   # define proc if not done yet or if it was defined for another context
   if {[info procs modVersCmp] eq {} || $::g_modVersCmp_proc ne $procname} {
      if {[info exists ::g_modVersCmp_proc]} {
         # remove existing debug trace if any
         initProcReportTrace remove modVersCmp
         rename ::modVersCmp ::$::g_modVersCmp_proc
      }
      ##nagelfar syntax modVersCmp x x x x x?
      rename ::$procname ::modVersCmp
      # set report traces if some debug mode enabled
      initProcReportTrace add modVersCmp
      set ::g_modVersCmp_proc $procname
   }
}

# alternative definitions of modVersCmp proc
proc modVersCmpProc {cmpspec versspec modvers test {psuf {}}} {
   set ret 0
   set echar [extendedDefaultCharGlobMatch]
   switch -- $cmpspec {
      in {
         # check each verspec in list until match
         foreach inspec $versspec {
            lassign $inspec incmp invers
            if {[set ret [modVersCmp $incmp $invers $modvers $test $psuf]]} {
               break
            }
         }
      }
      eq {
         append versspec $psuf
         if {$test eq {eqstart}} {
            set ret [string equal -length [string length $versspec/]\
               $versspec/ $modvers/]
         } else {
            ##nagelfar ignore Non static subcommand
            set ret [string $test $versspec $modvers]
         }
      }
      ge {
         # as we work here on a version range: psuf suffix is ignored, checks
         # are always extended_default-enabled (as 1.2 includes 1.2.12 for
         # instance) and equal, eqstart and match tests are equivalent
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $versspec] != -1 || [string match $versspec$echar $modvers])}]
      }
      le {
         # 'ge' comment also applies here
         set ret [expr {[isVersion $modvers] && ([versioncmp $versspec\
            $modvers] != -1 || [string match $versspec$echar $modvers])}]
      }
      be {
         # 'ge' comment also applies here
         lassign $versspec lovers hivers
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $lovers] != -1 || [string match $lovers$echar $modvers]) &&\
            ([versioncmp $hivers $modvers] != -1 || [string match\
            $hivers$echar $modvers])}]
      }
   }
   return $ret
}
proc modVersCmpProcIcase {cmpspec versspec modvers test {psuf {}}} {
   set ret 0
   set echar [extendedDefaultCharGlobMatch]
   switch -- $cmpspec {
      in {
         foreach inspec $versspec {
            lassign $inspec incmp invers
            if {[set ret [modVersCmp $incmp $invers $modvers $test $psuf]]} {
               break
            }
         }
      }
      eq {
         append versspec $psuf
         if {$test eq {eqstart}} {
            set ret [string equal -nocase -length [string length $versspec/]\
               $versspec/ $modvers/]
         } else {
            ##nagelfar ignore Non static subcommand
            set ret [string $test -nocase $versspec $modvers]
         }
      }
      ge {
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $versspec] != -1 || [string match -nocase $versspec$echar\
            $modvers])}]
      }
      le {
         set ret [expr {[isVersion $modvers] && ([versioncmp $versspec\
            $modvers] != -1 || [string match -nocase $versspec$echar\
            $modvers])}]
      }
      be {
         lassign $versspec lovers hivers
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $lovers] != -1 || [string match $lovers$echar $modvers]) &&\
            ([versioncmp $hivers $modvers] != -1 || [string match -nocase\
            $hivers$echar $modvers])}]
      }
   }
   return $ret
}
proc modVersCmpProcExtdfl {cmpspec versspec modvers test {psuf {}}} {
   set ret 0
   set echar [extendedDefaultCharGlobMatch]
   switch -- $cmpspec {
      in {
         foreach inspec $versspec {
            lassign $inspec incmp invers
            if {[set ret [modVersCmp $incmp $invers $modvers $test $psuf]]} {
               break
            }
         }
      }
      eq {
         append versspec $psuf
         if {$test eq {eqstart}} {
            set ret [string equal -length [string length $versspec/]\
               $versspec/ $modvers/]
         } else {
            ##nagelfar ignore Non static subcommand
            set ret [string $test $versspec $modvers]
         }
         if {!$ret && [string match $versspec$echar $modvers]} {
            set ret 1
         }
      }
      ge {
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $versspec] != -1 || [string match $versspec$echar $modvers])}]
      }
      le {
         set ret [expr {[isVersion $modvers] && ([versioncmp $versspec\
            $modvers] != -1 || [string match $versspec$echar $modvers])}]
      }
      be {
         lassign $versspec lovers hivers
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $lovers] != -1 || [string match $lovers$echar $modvers]) &&\
            ([versioncmp $hivers $modvers] != -1 || [string match\
            $hivers$echar $modvers])}]
      }
   }
   return $ret
}
proc modVersCmpProcIcaseExtdfl {cmpspec versspec modvers test {psuf {}}} {
   set ret 0
   set echar [extendedDefaultCharGlobMatch]
   switch -- $cmpspec {
      in {
         foreach inspec $versspec {
            lassign $inspec incmp invers
            if {[set ret [modVersCmp $incmp $invers $modvers $test $psuf]]} {
               break
            }
         }
      }
      eq {
         append versspec $psuf
         if {$test eq {eqstart}} {
            set ret [string equal -nocase -length [string length $versspec/]\
               $versspec/ $modvers/]
         } else {
            ##nagelfar ignore Non static subcommand
            set ret [string $test -nocase $versspec $modvers]
         }
         if {!$ret && [string match -nocase $versspec$echar $modvers]} {
            set ret 1
         }
      }
      ge {
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $versspec] != -1 || [string match -nocase $versspec$echar\
            $modvers])}]
      }
      le {
         set ret [expr {[isVersion $modvers] && ([versioncmp $versspec\
            $modvers] != -1 || [string match -nocase $versspec$echar\
            $modvers])}]
      }
      be {
         lassign $versspec lovers hivers
         set ret [expr {[isVersion $modvers] && ([versioncmp $modvers\
            $lovers] != -1 || [string match $lovers$echar $modvers]) &&\
            ([versioncmp $hivers $modvers] != -1 || [string match -nocase\
            $hivers$echar $modvers])}]
      }
   }
   return $ret
}

proc modVariantCmp {pvrlist modvrlist {missmean 0}} {
   set ret 1
   # missing variant in mod spec means default value
   if {$missmean == 1} {
      foreach {modvrname modvrval modvrisdfl} $modvrlist {
         set modvrarr($modvrname) $modvrval
         set modvrisdflarr($modvrname) $modvrisdfl
      }
   } else {
      array set modvrarr $modvrlist
      # if missmean == 2 pattern is mod, thus missing variant on mod is ok
      # it is used for extra specifier where pattern is definition inside
      # modulefile and mod is extra specifier defined on command line
   }
   foreach pvr $pvrlist {
      set pvrarr([lindex $pvr 0]) [lindex $pvr 3]
   }

   # no match if a specified variant is not found among module variants (and
   # if miss is not ok) or if the value differs
   foreach vrname [array names pvrarr] {
      if {(![info exists modvrarr($vrname)] && $missmean != 2) || ([info\
         exists modvrarr($vrname)] && $pvrarr($vrname) ne\
         $modvrarr($vrname))} {
         set ret 0
         break
      }
   }

   # if an unset variant on pattern means variant default value pattern and
   # mod are not equal if variant unset on pattern and non-default value is
   # set for variant on mod
   if {$missmean == 1} {
      foreach vrname [array names modvrisdflarr] {
         if {!$modvrisdflarr($vrname) && ![info exists pvrarr($vrname)]} {
            set ret 0
            break
         }
      }
   }

   return $ret
}

# Setup a hardwire version of modEq procedure called modEqStatic. This
# optimized procedure already knows the module pattern to compare to, whose
# specification has already been resolved at procedure definition time, which
# saves lot of processing time.
# modEqStatic does not compare against loaded modules so it has no need to
# compare variants set on module specification
proc defineModEqStaticProc {icase extdfl modspec} {
   set procprops $icase:$extdfl:$modspec

   # define proc if not done yet or if it was defined for another context
   if {[info procs modEqStatic] eq {} || $::g_modEqStatic_procprops ne\
      $procprops} {
      if {[info exists ::g_modEqStatic_procprops]} {
         # remove existing debug trace if any
         initProcReportTrace remove modEqStatic
         rename ::modEqStatic {}
      }
      set ::g_modEqStatic_procprops $procprops

      # define optimized procedure
      lassign [getModuleVersSpec $modspec] pmod pmodname cmpspec versspec\
         pmodnamere pmodescglob
      # trim dup trailing / char and adapt pmod suffix if it starts with /
      if {[string index $pmod end] eq {/}} {
         set pmod [string trimright $pmod /]/
         set endwslash 1
      } else {
         set endwslash 0
      }
      set nocasearg [expr {$icase ? {-nocase } : {}}]
      set pmodnameslen [string length $pmodname/]
      if {$pmod ne {} || $modspec eq {}} {
         set procbody "
            set pmod {$pmod}
            if {\$psuf ne {}} {
               if {$endwslash && \[string index \$psuf 0\] eq {/}} {
                  append pmod \[string range \$psuf 1 end\]
               } else {
                  append pmod \$psuf
               }
            }
            if {\$test eq {eqstart}} {
               set ret \[string equal $nocasearg-length \[string length\
                  \$pmod/\] \$pmod/ \$mod/\]
            } else {
               if {\$test eq {matchin}} {
                  set test match
                  set pmod *\$pmod
               }
               set ret \[string \$test $nocasearg\$pmod \$mod\]
            }"
         if {$extdfl} {
            append procbody "
               if {!\$ret && \[string first / \$pmod\] != -1} {
                  if {\$test eq {match}} {
                     set pmodextdfl \$pmod
                  } else {
                     set pmodextdfl {$pmodescglob}
                  }
                  append pmodextdfl \[extendedDefaultCharGlobMatch\]
                  set ret \[string match $nocasearg\$pmodextdfl \$mod\]
               }"
         }
      } else {
         set procbody "
            set pmodname {$pmodname}
            set pmodnamere {$pmodnamere}
            if {\$test eq {matchin}} {
               set test match
               if {\$pmodnamere ne {}} {
                  set pmodnamere .*\$pmodnamere
               } else {
                  set pmodnamere {.*$pmodname}
               }
            }
            if {(\$pmodnamere ne {} && \$test eq {match} && \[regexp\
               $nocasearg (^\$pmodnamere)/ \$mod/ rematch pmodname\]) ||\
               \[string equal $nocasearg -length $pmodnameslen {$pmodname/}\
               \$mod/\]} {
               set modvers \[string range \$mod \[string length \$pmodname/\]\
                  end\]
               set ret \[modVersCmp {$cmpspec} {$versspec} \$modvers \$test\
                  \$psuf\]
            } else {
               set ret 0
            }"
      }
      append procbody "
         return \$ret"
      ##nagelfar syntax modEqStatic x x? x?
      ##nagelfar ignore Non constant argument to proc
      proc modEqStatic {mod {test equal} {psuf {}}} $procbody
      # set report traces if some debug mode enabled
      initProcReportTrace add modEqStatic
   }
}

# Define procedure to check module name equals pattern. Adapt procedure
# code whether icase and extended_default are enabled or disabled
proc defineModEqProc {icase extdfl} {
   set procname modEqProc
   if {$icase} {
      append procname Icase
   }
   if {$extdfl} {
      append procname Extdfl
   }

   # define proc if not done yet or if it was defined for another context
   if {[info procs modEq] eq {} || $::g_modEq_proc ne $procname} {
      if {[info exists ::g_modEq_proc]} {
         # remove existing debug trace if any
         initProcReportTrace remove modEq
         rename ::modEq ::$::g_modEq_proc
         # drop existing mem cache
         array unset ::g_modEqMemCache
      }
      ##nagelfar syntax modEq x x x? x? x? x? x? x?
      rename ::$procname ::modEq
      # set report traces if some debug mode enabled
      initProcReportTrace add modEq
      set ::g_modEq_proc $procname
   }
}

# alternative definitions of modEq proc
proc modEqProc {pattern mod {test equal} {trspec 1} {ismodlo 0} {vrcmp 0}\
   {modvrlist 0} {psuf {}}} {
   # return cached result if any and not checking loaded mod
   set searchid $pattern:$mod:$test:$trspec:$vrcmp:$modvrlist:$psuf
   if {!$ismodlo && [info exists ::g_modEqMemCache($searchid)]} {
      return $::g_modEqMemCache($searchid)
   }

   # extract specified module name from name and version spec
   if {$trspec} {
      lassign [getModuleVersSpec $pattern] pmod pmodname cmpspec versspec\
         pmodnamere pmodescglob pmodroot pvrlist
   } else {
      set pmod $pattern
   }
   # trim dup trailing / char and adapt pmod suffix if it starts with /
   set endwslash 0
   if {[string index $pmod end] eq {/}} {
      #  trailing / will be automatically added in the eqstart tests
      if {$test eq {eqstart}} {
         set pmod [string trimright $pmod /]
      } else {
         set pmod [string trimright $pmod /]/
         set endwslash 1
      }
   }
   # get alternative names if mod is loading(1) or loaded(2)
   set altlist [switch -- $ismodlo {
      7 {getLoadedAltname $mod {alias}}
      6 {getLoadedAltname $mod {sym autosym}}
      5 {getAvailListFromVersSpec $mod}
      4 {getAllModuleResolvedName $mod 0 {} 1}
      3 {getLoadedAltAndSimplifiedName $mod}
      2 {getLoadedAltname $mod}
      1 {getAllModuleResolvedName $mod}
      0 {list}}]
   # fetch variant definition from spec if not loaded/loading
   if {$vrcmp && $ismodlo in {0 5}} {
      set modvrlist [getVariantList $mod 0 0 1]
      set mod [getModuleNameAndVersFromVersSpec $mod]
   }
   # specified module can be translated in a simple mod name/vers or is empty
   if {$pmod ne {} || $pattern eq {}} {
      if {$psuf ne {}} {
         if {$endwslash && [string index $psuf 0] eq {/}} {
            append pmod [string range $psuf 1 end]
         } else {
            append pmod $psuf
         }
      }
      if {$test eq {eqstart}} {
         set ret [string equal -length [string length $pmod/] $pmod/ $mod/]
         # apply comparison to alternative names if any and no match for mod
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string equal -length [string length $pmod/]\
                  $pmod/ $alt/]]} {
                  break
               }
            }
         }
      } else {
         # contains test
         if {$test eq {matchin}} {
            set test match
            set pmod *$pmod
         } elseif {$test eq {eqspec}} {
            set test equal
         }
         ##nagelfar ignore Non static subcommand
         set ret [string $test $pmod $mod]
         # apply comparison to alternative names if any and no match for mod
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               ##nagelfar ignore Non static subcommand
               if {[set ret [string $test $pmod $alt]]} {
                  break
               }
            }
         }
      }
   } elseif {$test eq {eqspec}} {
      # test equality against all version described in spec (list or range
      # boundaries), trspec is considered enabled and psuf empty
      foreach pmod [getAllModulesFromVersSpec $pattern] {
         if {[set ret [string equal $pmod $mod]]} {
            break
         }
      }
   } else {
      # contains test
      if {$test eq {matchin}} {
         set test match
         if {$pmodnamere ne {}} {
            set pmodnamere .*$pmodnamere
         } else {
            set pmodnamere .*$pmodname
         }
      }
      # for more complex specification, first check if module name matches
      # use a regexp test if module name contains wildcard characters
      if {($pmodnamere ne {} && $test eq {match} && [regexp (^$pmodnamere)/\
         $mod/ rematch pmodname]) || [string equal -length [string length\
         $pmodname/] $pmodname/ $mod/]} {
         # then compare versions
         set modvers [string range $mod [string length $pmodname/] end]
         set ret [modVersCmp $cmpspec $versspec $modvers $test $psuf]
      } else {
         set ret 0
      }
      # apply comparison to alternative names if any and no match for mod
      if {!$ret && [llength $altlist]} {
         foreach alt $altlist {
            if {($pmodnamere ne {} && $test eq {match} && [regexp\
               (^$pmodnamere)/ $alt/ rematch pmodname]) || [string equal\
               -length [string length $pmodname/] $pmodname/ $alt/]} {
               # then compare versions
               set modvers [string range $alt [string length $pmodname/] end]
               if {[set ret [modVersCmp $cmpspec $versspec $modvers $test\
                  $psuf]]} {
                  break
               }
            }
         }
      }
   }
   # check if variant specified matches those of selected loaded/ing module
   if {$ret && $vrcmp && $ismodlo ni {3 5} && [llength $pvrlist]} {
      if {$modvrlist eq {0}} {
         set modvrlist [getVariantList $mod]
      }
      set ret [modVariantCmp $pvrlist $modvrlist]
   # variant miss means variant default val when comparing collection content
   } elseif {$ret && $vrcmp && $ismodlo == 3} {
      set ret [modVariantCmp $pvrlist [getVariantList $mod 3] 1]
   # variant miss is ok when comparing an extra specifier passed as mod
   } elseif {$ret && $vrcmp && $ismodlo == 5} {
      set ret [modVariantCmp $pvrlist $modvrlist 2]
   }
   if {!$ismodlo} {
      set ::g_modEqMemCache($searchid) $ret
   }
   return $ret
}
proc modEqProcIcase {pattern mod {test equal} {trspec 1} {ismodlo 0} {vrcmp\
   0} {modvrlist 0} {psuf {}}} {
   set searchid $pattern:$mod:$test:$trspec:$vrcmp:$modvrlist:$psuf
   if {!$ismodlo && [info exists ::g_modEqMemCache($searchid)]} {
      return $::g_modEqMemCache($searchid)
   }

   if {$trspec} {
      lassign [getModuleVersSpec $pattern] pmod pmodname cmpspec versspec\
         pmodnamere pmodescglob pmodroot pvrlist
   } else {
      set pmod $pattern
   }
   set endwslash 0
   if {[string index $pmod end] eq {/}} {
      if {$test eq {eqstart}} {
         set pmod [string trimright $pmod /]
      } else {
         set pmod [string trimright $pmod /]/
         set endwslash 1
      }
   }
   set altlist [switch -- $ismodlo {
      7 {getLoadedAltname $mod {alias}}
      6 {getLoadedAltname $mod {sym autosym}}
      5 {getAvailListFromVersSpec $mod}
      4 {getAllModuleResolvedName $mod 0 {} 1}
      3 {getLoadedAltAndSimplifiedName $mod}
      2 {getLoadedAltname $mod}
      1 {getAllModuleResolvedName $mod}
      0 {list}}]
   if {$vrcmp && $ismodlo in {0 5}} {
      set modvrlist [getVariantList $mod 0 0 1]
      set mod [getModuleNameAndVersFromVersSpec $mod]
   }
   if {$pmod ne {} || $pattern eq {}} {
      if {$psuf ne {}} {
         if {$endwslash && [string index $psuf 0] eq {/}} {
            append pmod [string range $psuf 1 end]
         } else {
            append pmod $psuf
         }
      }
      if {$test eq {eqstart}} {
         set ret [string equal -nocase -length [string length $pmod/] $pmod/\
            $mod/]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string equal -nocase -length [string length\
                  $pmod/] $pmod/ $alt/]]} {
                  break
               }
            }
         }
      } else {
         # contains test
         if {$test eq {matchin}} {
            set test match
            set pmod *$pmod
         } elseif {$test eq {eqspec}} {
            set test equal
         }
         ##nagelfar ignore Non static subcommand
         set ret [string $test -nocase $pmod $mod]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               ##nagelfar ignore Non static subcommand
               if {[set ret [string $test -nocase $pmod $alt]]} {
                  break
               }
            }
         }
      }
   } elseif {$test eq {eqspec}} {
      # test equality against all version described in spec (list or range
      # boundaries), trspec is considered enabled and psuf empty
      foreach pmod [getAllModulesFromVersSpec $pattern] {
         if {[set ret [string equal -nocase $pmod $mod]]} {
            break
         }
      }
   } else {
      # contains test
      if {$test eq {matchin}} {
         set test match
         if {$pmodnamere ne {}} {
            set pmodnamere .*$pmodnamere
         } else {
            set pmodnamere .*$pmodname
         }
      }
      # for more complex specification, first check if module name matches
      # use a regexp test if module name contains wildcard characters
      if {($pmodnamere ne {} && $test eq {match} && [regexp -nocase\
         (^$pmodnamere)/ $mod/ rematch pmodname]) || [string equal -nocase\
         -length [string length $pmodname/] $pmodname/ $mod/]} {
         # then compare versions
         set modvers [string range $mod [string length $pmodname/] end]
         set ret [modVersCmp $cmpspec $versspec $modvers $test $psuf]
      } else {
         set ret 0
      }
      if {!$ret && [llength $altlist]} {
         foreach alt $altlist {
            if {($pmodnamere ne {} && $test eq {match} && [regexp -nocase\
               (^$pmodnamere)/ $alt/ rematch pmodname]) || [string equal\
               -nocase -length [string length $pmodname/] $pmodname/ $alt/]} {
               # then compare versions
               set modvers [string range $alt [string length $pmodname/] end]
               if {[set ret [modVersCmp $cmpspec $versspec $modvers $test\
                  $psuf]]} {
                  break
               }
            }
         }
      }
   }
   if {$ret && $vrcmp && $ismodlo ni {3 5} && [llength $pvrlist]} {
      if {$modvrlist eq {0}} {
         set modvrlist [getVariantList $mod]
      }
      set ret [modVariantCmp $pvrlist $modvrlist]
   } elseif {$ret && $vrcmp && $ismodlo == 3} {
      set ret [modVariantCmp $pvrlist [getVariantList $mod 3] 1]
   } elseif {$ret && $vrcmp && $ismodlo == 5} {
      set ret [modVariantCmp $pvrlist $modvrlist 2]
   }
   if {!$ismodlo} {
      set ::g_modEqMemCache($searchid) $ret
   }
   return $ret
}
proc modEqProcExtdfl {pattern mod {test equal} {trspec 1} {ismodlo 0} {vrcmp\
   0} {modvrlist 0} {psuf {}}} {
   set searchid $pattern:$mod:$test:$trspec:$vrcmp:$modvrlist:$psuf
   if {!$ismodlo && [info exists ::g_modEqMemCache($searchid)]} {
      return $::g_modEqMemCache($searchid)
   }

   if {$trspec} {
      lassign [getModuleVersSpec $pattern] pmod pmodname cmpspec versspec\
         pmodnamere pmodescglob pmodroot pvrlist
   } else {
      set pmod $pattern
   }
   set endwslash 0
   if {[string index $pmod end] eq {/}} {
      if {$test eq {eqstart}} {
         set pmod [string trimright $pmod /]
      } else {
         set pmod [string trimright $pmod /]/
         set endwslash 1
      }
   }
   set altlist [switch -- $ismodlo {
      7 {getLoadedAltname $mod {alias}}
      6 {getLoadedAltname $mod {sym autosym}}
      5 {getAvailListFromVersSpec $mod}
      4 {getAllModuleResolvedName $mod 0 {} 1}
      3 {getLoadedAltAndSimplifiedName $mod}
      2 {getLoadedAltname $mod}
      1 {getAllModuleResolvedName $mod}
      0 {list}}]
   if {$vrcmp && $ismodlo in {0 5}} {
      set modvrlist [getVariantList $mod 0 0 1]
      set mod [getModuleNameAndVersFromVersSpec $mod]
   }
   if {$pmod ne {} || $pattern eq {}} {
      if {$psuf ne {}} {
         if {$endwslash && [string index $psuf 0] eq {/}} {
            append pmod [string range $psuf 1 end]
         } else {
            append pmod $psuf
         }
      }
      if {$test eq {eqstart}} {
         set ret [string equal -length [string length $pmod/] $pmod/ $mod/]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string equal -length [string length $pmod/]\
                  $pmod/ $alt/]]} {
                  break
               }
            }
         }
      } else {
         # contains test
         if {$test eq {matchin}} {
            set test match
            set pmod *$pmod
         } elseif {$test eq {eqspec}} {
            set test equal
            set eqspec 1
         }
         ##nagelfar ignore Non static subcommand
         set ret [string $test $pmod $mod]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               ##nagelfar ignore Non static subcommand
               if {[set ret [string $test $pmod $alt]]} {
                  break
               }
            }
         }
      }
      # try the extended default match if not root module and not eqspec test
      if {![info exists eqspec] && !$ret && [string first / $pmod] != -1} {
         if {$test eq {match}} {
            set pmodextdfl $pmod
         } else {
            set pmodextdfl $pmodescglob
         }
         append pmodextdfl [extendedDefaultCharGlobMatch]
         set ret [string match $pmodextdfl $mod]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string match $pmodextdfl $alt]]} {
                  break
               }
            }
         }
      }
   } elseif {$test eq {eqspec}} {
      # test equality against all version described in spec (list or range
      # boundaries), trspec is considered enabled and psuf empty
      foreach pmod [getAllModulesFromVersSpec $pattern] {
         if {[set ret [string equal $pmod $mod]]} {
            break
         }
      }
   } else {
      # contains test
      if {$test eq {matchin}} {
         set test match
         if {$pmodnamere ne {}} {
            set pmodnamere .*$pmodnamere
         } else {
            set pmodnamere .*$pmodname
         }
      }
      # for more complex specification, first check if module name matches
      # use a regexp test if module name contains wildcard characters
      if {($pmodnamere ne {} && $test eq {match} && [regexp (^$pmodnamere)/\
         $mod/ rematch pmodname]) || [string equal -length [string length\
         $pmodname/] $pmodname/ $mod/]} {
         # then compare versions
         set modvers [string range $mod [string length $pmodname/] end]
         set ret [modVersCmp $cmpspec $versspec $modvers $test $psuf]
      } else {
         set ret 0
      }
      if {!$ret && [llength $altlist]} {
         foreach alt $altlist {
            if {($pmodnamere ne {} && $test eq {match} && [regexp\
               (^$pmodnamere)/ $alt/ rematch pmodname]) || [string equal\
               -length [string length $pmodname/] $pmodname/ $alt/]} {
               # then compare versions
               set modvers [string range $alt [string length $pmodname/] end]
               if {[set ret [modVersCmp $cmpspec $versspec $modvers $test\
                  $psuf]]} {
                  break
               }
            }
         }
      }
   }
   if {$ret && $vrcmp && $ismodlo ni {3 5} && [llength $pvrlist]} {
      if {$modvrlist eq {0}} {
         set modvrlist [getVariantList $mod]
      }
      set ret [modVariantCmp $pvrlist $modvrlist]
   } elseif {$ret && $vrcmp && $ismodlo == 3} {
      set ret [modVariantCmp $pvrlist [getVariantList $mod 3] 1]
   } elseif {$ret && $vrcmp && $ismodlo == 5} {
      set ret [modVariantCmp $pvrlist $modvrlist 2]
   }
   if {!$ismodlo} {
      set ::g_modEqMemCache($searchid) $ret
   }
   return $ret
}
proc modEqProcIcaseExtdfl {pattern mod {test equal} {trspec 1} {ismodlo 0}\
   {vrcmp 0} {modvrlist 0} {psuf {}}} {
   set searchid $pattern:$mod:$test:$trspec:$vrcmp:$modvrlist:$psuf
   if {!$ismodlo && [info exists ::g_modEqMemCache($searchid)]} {
      return $::g_modEqMemCache($searchid)
   }

   if {$trspec} {
      lassign [getModuleVersSpec $pattern] pmod pmodname cmpspec versspec\
         pmodnamere pmodescglob pmodroot pvrlist
   } else {
      set pmod $pattern
   }
   set endwslash 0
   if {[string index $pmod end] eq {/}} {
      if {$test eq {eqstart}} {
         set pmod [string trimright $pmod /]
      } else {
         set pmod [string trimright $pmod /]/
         set endwslash 1
      }
   }
   set altlist [switch -- $ismodlo {
      7 {getLoadedAltname $mod {alias}}
      6 {getLoadedAltname $mod {sym autosym}}
      5 {getAvailListFromVersSpec $mod}
      4 {getAllModuleResolvedName $mod 0 {} 1}
      3 {getLoadedAltAndSimplifiedName $mod}
      2 {getLoadedAltname $mod}
      1 {getAllModuleResolvedName $mod}
      0 {list}}]
   if {$vrcmp && $ismodlo in {0 5}} {
      set modvrlist [getVariantList $mod 0 0 1]
      set mod [getModuleNameAndVersFromVersSpec $mod]
   }
   if {$pmod ne {} || $pattern eq {}} {
      if {$psuf ne {}} {
         if {$endwslash && [string index $psuf 0] eq {/}} {
            append pmod [string range $psuf 1 end]
         } else {
            append pmod $psuf
         }
      }
      if {$test eq {eqstart}} {
         set ret [string equal -nocase -length [string length $pmod/] $pmod/\
            $mod/]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string equal -nocase -length [string length\
                  $pmod/] $pmod/ $alt/]]} {
                  break
               }
            }
         }
      } else {
         # contains test
         if {$test eq {matchin}} {
            set test match
            set pmod *$pmod
         } elseif {$test eq {eqspec}} {
            set test equal
            set eqspec 1
         }
         ##nagelfar ignore Non static subcommand
         set ret [string $test -nocase $pmod $mod]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               ##nagelfar ignore Non static subcommand
               if {[set ret [string $test -nocase $pmod $alt]]} {
                  break
               }
            }
         }
      }
      # try the extended default match if not root module and not eqspec test
      if {![info exists eqspec] && !$ret && [string first / $pmod] != -1} {
         if {$test eq {match}} {
            set pmodextdfl $pmod
         } else {
            set pmodextdfl $pmodescglob
         }
         append pmodextdfl [extendedDefaultCharGlobMatch]
         set ret [string match -nocase $pmodextdfl $mod]
         if {!$ret && [llength $altlist]} {
            foreach alt $altlist {
               if {[set ret [string match -nocase $pmodextdfl $alt]]} {
                  break
               }
            }
         }
      }
   } elseif {$test eq {eqspec}} {
      # test equality against all version described in spec (list or range
      # boundaries), trspec is considered enabled and psuf empty
      foreach pmod [getAllModulesFromVersSpec $pattern] {
         if {[set ret [string equal -nocase $pmod $mod]]} {
            break
         }
      }
   } else {
      # contains test
      if {$test eq {matchin}} {
         set test match
         if {$pmodnamere ne {}} {
            set pmodnamere .*$pmodnamere
         } else {
            set pmodnamere .*$pmodname
         }
      }
      # for more complex specification, first check if module name matches
      # use a regexp test if module name contains wildcard characters
      if {($pmodnamere ne {} && $test eq {match} && [regexp -nocase\
         (^$pmodnamere)/ $mod/ rematch pmodname]) || [string equal -nocase\
         -length [string length $pmodname/] $pmodname/ $mod/]} {
         # then compare versions
         set modvers [string range $mod [string length $pmodname/] end]
         set ret [modVersCmp $cmpspec $versspec $modvers $test $psuf]
      } else {
         set ret 0
      }
      if {!$ret && [llength $altlist]} {
         foreach alt $altlist {
            if {($pmodnamere ne {} && $test eq {match} && [regexp -nocase\
               (^$pmodnamere)/ $alt/ rematch pmodname]) || [string equal\
               -nocase -length [string length $pmodname/] $pmodname/ $alt/]} {
               # then compare versions
               set modvers [string range $alt [string length $pmodname/] end]
               if {[set ret [modVersCmp $cmpspec $versspec $modvers $test\
                  $psuf]]} {
                  break
               }
            }
         }
      }
   }
   if {$ret && $vrcmp && $ismodlo ni {3 5} && [llength $pvrlist]} {
      if {$modvrlist eq {0}} {
         set modvrlist [getVariantList $mod]
      }
      set ret [modVariantCmp $pvrlist $modvrlist]
   } elseif {$ret && $vrcmp && $ismodlo == 3} {
      set ret [modVariantCmp $pvrlist [getVariantList $mod 3] 1]
   } elseif {$ret && $vrcmp && $ismodlo == 5} {
      set ret [modVariantCmp $pvrlist $modvrlist 2]
   }
   if {!$ismodlo} {
      set ::g_modEqMemCache($searchid) $ret
   }
   return $ret
}

proc modEqAny {pattern_list mod {test equal} {trspec 1} {ismodlo 0} {vrcmp 0}\
   {modvrlist 0} {psuf {}}} {
   foreach pattern $pattern_list {
      if {[modEq $pattern $mod $test $trspec $ismodlo $vrcmp $modvrlist\
         $psuf]} {
         return 1
      }
   }
   return 0
}

# analyze module version specified within module specification
proc parseModuleVersionSpecifier {modspec} {
   set invalidversspec 0
   set invalidversrange 0
   set islist [expr {[string first , $modspec] != -1}]
   set isrange [expr {[string first : $modspec] != -1}]
   # no deep version specification allowed
   if {[string first / $modspec] != -1} {
      set invalidversspec 1
   # ',' separates multiple versions
   } elseif {$islist} {
      set cmpspec in
      set inspeclist [split $modspec ,]
      # empty element in list is erroneous
      set invalidversspec [expr {[lsearch -exact $inspeclist {}] != -1}]
      if {!$invalidversspec} {
         # recursive call to check each element in list (can be range, etc)
         foreach inspec $inspeclist {
            lappend versspec [parseModuleVersionSpecifier $inspec]
         }
      }
   # ':' separates range elements
   } elseif {$isrange} {
      set versspec [split $modspec :]
      set lovers [lindex $versspec 0]
      set hivers [lindex $versspec 1]
      if {[llength $versspec] != 2 || ($lovers eq {} && $hivers eq {})} {
         set invalidversspec 1
      } elseif {($lovers ne {} && ![isVersion $lovers]) || ($hivers ne {} &&\
         ![isVersion $hivers])} {
         set invalidversrange 1
      # greater or equal
      } elseif {$hivers eq {}} {
         set cmpspec ge
         set versspec $lovers
      # lower or equal
      } elseif {$lovers eq {}} {
         set cmpspec le
         set versspec $hivers
      # between or equal
      } elseif {[versioncmp $lovers $hivers] == 1} {
         set invalidversrange 1
      } else {
         set cmpspec be
      }
   } else {
      set cmpspec eq
      set versspec $modspec
   }
   if {$invalidversspec} {
      knerror "Invalid version specifier '$modspec'"
   }
   if {$invalidversrange} {
      knerror "Invalid version range '$modspec'"
   }
   return [list $cmpspec $versspec]
}

# Define procedure to parse modulefile specification passed as argument
# Adapt procedure code whether advanced_version_spec is enabled or disabled
proc defineParseModuleSpecificationProc {advverspec} {
   set procname parseModuleSpecificationProc
   if {$advverspec} {
      append procname AdvVersSpec
      # resolved configured variant shortcut
      getConf variant_shortcut
   }
   # define proc if not done yet or if it was defined for another context
   if {[info procs parseModuleSpecification] eq {} ||\
      $::g_parseModuleSpecification_proc ne $procname} {
      if {[info exists ::g_parseModuleSpecification_proc]} {
         # remove existing debug trace if any
         initProcReportTrace remove parseModuleSpecification
         rename ::parseModuleSpecification\
            ::$::g_parseModuleSpecification_proc
      }
      ##nagelfar syntax parseModuleSpecification x x x x x*
      rename ::$procname ::parseModuleSpecification
      # set report traces if some debug mode enabled
      initProcReportTrace add parseModuleSpecification
      set ::g_parseModuleSpecification_proc $procname
   }
}

# when advanced_version_spec option is enabled, parse argument list to set in
# a global context version specification of modules passed as argument.
# mlspec: specification may vary whether it comes from the ml or another
# command. nonamespec: sometimes specification may omit module name and
# version and just provides variant properties. xtspec: is extra specifier
# specification allowed. getavails: query available modules to get those
# matching module name and version
proc parseModuleSpecificationProc {mlspec nonamespec xtspec getavails args} {
   # skip arg parse if proc was already call with same arg set by an upper
   # proc. check all args to ensure current arglist does not deviate from
   # what was previously parsed
   foreach arg $args {
      if {![info exists ::g_moduleVersSpec($arg)]} {
         set need_parse 1
         break
      }
   }
   if {![info exists need_parse]} {
      return $args
   }

   set unarglist [list]
   set arglist [list]

   foreach arg $args {
      if {$mlspec && [string index $arg 0] eq {-}} {
         set modname [string range $arg 1 end]
         set mlunload 1
      } else {
         set modname $arg
         set mlunload 0
      }
      # keep arg enclosed if composed of several words
      if {[string first { } $modname] != -1} {
         set modarg "{$modname}"
      } else {
         set modarg $modname
      }
      # record spec, especially needed if arg is enclosed
      setModuleVersSpec $modarg $modname eq {} {} {} $arg {} $getavails
      # append to unload list if ml spec and - prefix used
      if {$mlunload} {
         lappend unarglist $modarg
      } else {
         lappend arglist $modarg
      }
   }

   if {$mlspec} {
      return [list $unarglist $arglist]
   } else {
      return $arglist
   }

}
proc parseModuleSpecificationProcAdvVersSpec {mlspec nonamespec xtspec\
   getavails args} {
   foreach arg $args {
      if {![info exists ::g_moduleVersSpec($arg)]} {
         set need_parse 1
         break
      }
   }
   if {![info exists need_parse]} {
      return $args
   }

   # define extra specifier known list, to raise error if argument does not
   # match
   set xtelt_valid_list [list always-load append-path chdir complete conflict\
      depends-on depends-on-any envvar family incompat load load-any\
      prepend-path prereq prereq-all prereq-any provide provided-alias\
      pushenv remove-path require set-alias set-function setenv switch\
      switch-on switch-off tag try-load uncomplete unload unset-alias\
      unset-function unsetenv use variant]
   set xtelt_modspec_list [list always-load conflict depends-on\
      depends-on-any incompat load load-any prereq prereq-all prereq-any\
      require switch switch-on switch-off try-load unload]

   set mlunload 0
   set nextmlunload 0
   set arglist [list]
   set unarglist [list]
   set vrlist [list]
   set vridx -1
   set xtlist [list]
   set rawarg [list]
   foreach arg $args {
      # set each specification element as separate word but preserve space
      # character in each arg
      set curarglist {}
      # skip argument split if extra specifier detected
      if {[regexp {^[a-z-]+:} $arg]} {
         lappend curarglist $arg
      } else {
         set split_chars {@ ~ +}
         lappend split_chars {*}[array names ::g_shortcutVariant]
         set split_arg_list {}
         set previ 0
         for {set i 1} {$i < [string length $arg]} {incr i} {
            if {[string index $arg $i] in $split_chars} {
               lappend split_arg_list [string range $arg $previ $i-1]
               set previ $i
            }
         }
         lappend split_arg_list [string range $arg $previ $i-1]

         # unsplit some arg parts: those starting with boolean variant prefix
         # (+ or ~) but not followed by a valid variant name
         set prev_arg [lindex $split_arg_list 0]
         for {set i 1} {$i < [llength $split_arg_list]} {incr i} {
            set split_arg [lindex $split_arg_list $i]
            if {[string index $split_arg 0] ni {+ ~} || [isVariantNameValid\
               [string range $split_arg 1 end]]} {
               lappend curarglist $prev_arg
               set prev_arg $split_arg
            } else {
               append prev_arg $split_arg
            }
         }
         lappend curarglist $prev_arg
      }

      # parse each specification element
      foreach curarg $curarglist {
         set vrisbool 0

         set xtnot 0
         if {[string equal -length 4 $curarg not:]} {
            if {!$xtspec} {
               knerror "No extra specification allowed on this command"
            }
            set xtnot 1
            set curarg [string range $curarg 4 end]
         }

         set c [string index $curarg 0]
         switch -- $c {
            @ {
               if {$xtnot} {
                  knerror "Invalid extra specification '$arg'"
               }
               set modspec [string range $curarg 1 end]
               lassign [parseModuleVersionSpecifier $modspec] cmpspec versspec
               continue
            }
            + {
               set curarg [string range $curarg 1 end]
               append curarg =1
               set vrisbool 1
            }
            - {
               set curarg [string range $curarg 1 end]
               if {$mlspec} {
                  set nextmlunload 1
               } else {
                  append curarg =0
                  set vrisbool 1
               }
            }
            ~ {
               set curarg [string range $curarg 1 end]
               append curarg =0
               set vrisbool 1
            }
            default {
               # translate shortcut in variant name in arg
               if {[info exists ::g_shortcutVariant($c)]} {
                  set curarg [string replace $curarg 0 0\
                     $::g_shortcutVariant($c)=]
               }
            }
         }

         switch -glob -- $curarg {
            *:* {
               # extra specification may not be accepted on current context
               if {!$xtspec} {
                  knerror "No extra specification allowed on this command"
               }
               # extract extra specifier spec
               set xtsepidx [string first : $curarg]
               set xtelt [string range $curarg 0 $xtsepidx-1]
               set xtnamelist [split [string range $curarg $xtsepidx+1 end] ,]

               # check no other : character is found in argument or element
               # and name are not an empty string
               if {![string length $xtelt] || ![llength $xtnamelist] || {} in\
                  $xtnamelist || ([string last : $curarg] != $xtsepidx &&\
                  $xtelt ni $xtelt_modspec_list)} {
                  knerror "Invalid extra specification '$arg'"
               }
               if {$xtelt ni $xtelt_valid_list} {
                  knerror "Invalid extra specifier '$xtelt'\nValid extra\
                     specifiers are: $xtelt_valid_list"
               }
               set spec_xt [list $xtelt $xtnot]
               # parse and resolve module spec set as extra specifier value
               if {$xtelt in $xtelt_modspec_list} {
                  foreach xtname $xtnamelist {
                     lassign [parseModuleSpecification 0 0 0 1 {*}$xtname]\
                        xtname
                     lappend spec_xt $xtname
                  }
               } else {
                  # For tag extra specifier, resolve each name to get
                  # corresponding tag name if tag abbreviation set as name
                  if {$xtelt eq {tag}} {
                     foreach xtname $xtnamelist {
                        lappend spec_xt $xtname
                        if {[set tag [getTagFromAbbrev $xtname]] ne {}} {
                           lappend spec_xt $tag
                        }
                     }
                  } else {
                     lappend spec_xt {*}$xtnamelist
                  }
               }
               # save extra specifier element and name value, multiple values
               # may be set (means OR operator), same element can appear
               # multiple time (means AND operator)
               lappend xtlist $spec_xt
            }
            *=* {
               # extract valued-variant spec
               set vrsepidx [string first = $curarg]
               set vrname [string range $curarg 0 $vrsepidx-1]
               set vrvaluelist [split [string range $curarg $vrsepidx+1 end]\
                  ,]
               # value is one empty string
               if {![llength $vrvaluelist]} {
                  lappend vrvaluelist {}
               }

               if {$vrname eq {}} {
                  knerror "No variant name defined in argument '$curarg'"
               }
               # check no other = character is found in argument and that only
               # one value is set unless if extra specifier search is enabled
               if {[string last = $curarg] != $vrsepidx || (!$xtspec &&\
                  [llength $vrvaluelist] > 1)} {
                  knerror "Invalid variant specification '$arg'"
               }
               # replace previous value for variant if already set unless if
               # extra specifier search enabled where all variant spec forms
               # an AND operation
               if {[info exists vrnamearr($vrname)] && !$xtspec} {
                  lreplace $vrlist $vrnamearr($vrname) $vrnamearr($vrname)
               } else {
                  incr vridx
               }
               # translate boolean vrvalue in canonical boolean
               if {!$vrisbool} {
                  set vrisbool 1
                  for {set i 0} {$i < [llength $vrvaluelist]} {incr i 1} {
                     set vrvalue [lindex $vrvaluelist $i]
                     if {[string is boolean -strict $vrvalue] && ![string is\
                        integer -strict $vrvalue]} {
                        lset vrvaluelist $i [string is true -strict $vrvalue]
                     } else {
                        # consider variant not a boolean as soon as one value
                        # set is not a boolean
                        set vrisbool 0
                     }
                  }
               }
               # save variant name and value
               set vrnamearr($vrname) $vridx
               lappend vrlist [list $vrname $xtnot $vrisbool {*}$vrvaluelist]
            }
            default {
               if {$xtnot} {
                  knerror "Invalid extra specification '$arg'"
               }
               # save previous mod version spec and transformed arg if any
               if {[info exists modarglist]} {
                  set modarg [join $modarglist]
                  if {![info exists cmpspec]} {
                     set cmpspec eq
                     set versspec {}
                  }
                  # wild search name if no module name allowed
                  if {$nonamespec && ![info exists modname]} {
                     set modname *
                     set modspec *
                  }
                  if {[info exists modname] && ($modname ne {} || $modspec\
                     eq {})} {
                     setModuleVersSpec $modarg $modname $cmpspec $versspec\
                        $modspec $vrlist $rawarg $xtlist $getavails
                     # rework args to have 1 str element for whole mod spec
                     # append to unload list if ml spec and - prefix used
                     if {$mlunload} {
                        lappend unarglist $modarg
                     } else {
                        lappend arglist $modarg
                     }
                  } else {
                     knerror "No module name defined in argument '$modarg'"
                  }
                  unset modarglist
                  set vrlist [list]
                  array unset vrnamearr
                  set vridx -1
                  set xtlist [list]
                  set rawarg [list]
                  unset cmpspec versspec
               }
               set mlunload $nextmlunload
               set nextmlunload 0
               set modname $curarg
               set modspec {}
            }
         }
      }
      lappend rawarg $arg

      # keep arg enclosed if composed of several words
      if {[string first { } $arg] != -1} {
         lappend modarglist "{$arg}"
      } else {
         lappend modarglist $arg
      }
   }
   # transform last args
   set modarg [join $modarglist]
   if {$nonamespec && ![info exists modname]} {
      set modname *
      set modspec *
   }
   if {[info exists modname] && ($modname ne {} || $modspec eq {})} {
      if {![info exists cmpspec]} {
         set cmpspec eq
         set versspec {}
      }
      setModuleVersSpec $modarg $modname $cmpspec $versspec $modspec $vrlist\
         $rawarg $xtlist $getavails
      # rework args to have 1 string element for whole module spec
      # append to unload list if ml spec and - prefix used
      if {$mlunload || $nextmlunload} {
         lappend unarglist $modarg
      } else {
         lappend arglist $modarg
      }
   } else {
      knerror "No module name defined in argument '$modarg'"
   }

   if {$mlspec} {
      return [list $unarglist $arglist]
   } else {
      return $arglist
   }
}

proc setModuleVersSpec {modarg modname cmpspec versspec rawversspec\
   variantlist rawarg extralist getavails} {
   # translate @loaded version into currently loaded mod matching modname
   if {$cmpspec eq {eq} && $versspec eq {loaded}} {
      if {[set lmmod [getLoadedMatchingName $modname]] ne {}} {
         set modname [file dirname $lmmod]
         set versspec [file tail $lmmod]
         set variantlist [getVariantList $lmmod 2]
      } else {
         knerror "No loaded version found for '$modname' module"
      }
   }
   # save module root name
   set modroot [lindex [file split $modname] 0]
   # save module single designation if any and module name
   if {$versspec eq {}} {
      set mod $modname
      set modname [file dirname $modname]
   } else {
      set modname [string trimright $modname /]
      if {$cmpspec ne {eq}} {
         set mod {}
      } else {
         set mod $modname/$versspec
      }
   }
   # save a regexp-ready version of modname (apply
   # non-greedy quantifier to '*', to avoid matching final
   # '/' in string comparison
   set modnamere [string map {. \\. + \\+ * .*? ? .} $modname]
   if {$modname eq $modnamere} {
      set modnamere {}
   }
   # save a glob-special-chars escaped version of mod
   set modescglob [string map {* \\* ? \\?} $mod]

   # save module name and version specification (without variant specs)
   if {$mod eq {} && $rawversspec ne {} && $modname ne {.}} {
      set modnvspec ${modname}@${rawversspec}
   } else {
      set modnvspec $mod
   }

   # record most of the spec now to be able to rely on this record to get
   # matching available modules
   set ::g_moduleVersSpec($modarg) [list $mod $modname $cmpspec $versspec\
      $modnamere $modescglob $modroot $variantlist $modnvspec $rawarg\
      $extralist]

   # get all available module name and version matching module name and
   # version spec (inhibit extra match search not to trigger an infinite loop)
   if {$getavails} {
      setState inhibit_ems 1
      set availlist [getAllAvailModule $modarg]
      setState inhibit_ems 0
   } else {
      set availlist {}
   }
   # finalize module version spec record
   lappend ::g_moduleVersSpec($modarg) $availlist

   reportDebug "Set module '$mod' (escglob '$modescglob'),  module name\
      '$modname' (re '$modnamere'), module root '$modroot', version cmp\
      '$cmpspec', version(s) '$versspec', variant(s) '$variantlist' and\
      module name version spec '$modnvspec' for argument '$modarg' (raw\
      '$rawarg'), extra specifier(s) '$extralist' and matching available\
      module(s) '$availlist'"
}

proc getModuleVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return $::g_moduleVersSpec($modarg)
   } else {
      return [list $modarg [file dirname $modarg] {} {} {} [string map {* \\*\
         ? \\?} $modarg] [lindex [file split $modarg] 0] {} $modarg $modarg\
         {} {}]
   }
}

proc unsetModuleVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      unset ::g_moduleVersSpec($modarg)
   }
}

# get module name from module name and version spec if parsed
proc getModuleNameFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 1]
   } else {
      return [file dirname $modarg]
   }
}

proc getCmpSpecFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 2]
   } else {
      return eq
   }
}
# get module root name from module name and version spec if parsed
proc getModuleRootFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 6]
   } else {
      return [lindex [file split $modarg] 0]
   }
}

proc getModuleRootFromVersSpecLowerIfIcase {modarg} {
   set mod_root [getModuleRootFromVersSpec $modarg]
   if {[isIcase]} {
      set mod_root [string tolower $mod_root]
   }
   return $mod_root
}

# translate module name version spec to return all modules mentioned
proc getAllModulesFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      lassign $::g_moduleVersSpec($modarg) mod modname cmpspec versspec
      if {$mod eq {} && $cmpspec eq {in}} {
         # loop around each spec in list
         foreach inspec $versspec {
            lassign $inspec incmp invers
            foreach vers $invers {
               lappend modlist $modname/$vers
            }
         }
      } elseif {$mod eq {} && $cmpspec ne {eq}} {
         foreach vers $versspec {
            lappend modlist $modname/$vers
         }
      } else {
         # add empty mod specification if cmpspec is 'eq'
         lappend modlist $mod
      }
   } else {
      lappend modlist $modarg
   }

   return $modlist
}

# translate module name version spec to return one module mentioned
proc getOneModuleFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      lassign $::g_moduleVersSpec($modarg) mod modname cmpspec versspec
      if {$mod eq {} && $cmpspec eq {in}} {
         set inspec [lindex $versspec 0]
         lassign $inspec incmp invers
         set mod $modname/[lindex $invers 0]
      } elseif {$mod eq {} && $cmpspec ne {eq}} {
         set mod $modname/[lindex $versspec 0]
      }
   } else {
      set mod $modarg
   }

   return $mod
}

# translate module name version spec to return the list of variant mentioned
proc getVariantListFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 7]
   }
}

# get module name and version from version spec if parsed
proc getModuleNameAndVersFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 8]
   } else {
      return $modarg
   }
}

# get raw argument specified from parsed version spec
proc getRawArgumentFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 9]
   } else {
      return $modarg
   }
}

# translate module name version spec to return the list of extra specifier
# mentioned
proc getExtraListFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 10]
   }
}

# translate module name version spec to return list of tag specifier and list
# of other extra specifier
proc getSplitExtraListFromVersSpec {modarg} {
   set taglist {}
   set otherlist {}
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      foreach spec_xt [lindex $::g_moduleVersSpec($modarg) 10] {
         if {[lindex $spec_xt 0] eq {tag}} {
            lappend taglist $spec_xt
         } else {
            lappend otherlist $spec_xt
         }
      }
   }
   return [list $taglist $otherlist]
}

# get available modules matching module specification
proc getAvailListFromVersSpec {modarg} {
   if {[info exists ::g_moduleVersSpec($modarg)]} {
      return [lindex $::g_moduleVersSpec($modarg) 11]
   }
}

# is mod spec containing variant but no module name and version
proc isSpecWildWithVariant {mod} {
   return [expr {[getModuleNameAndVersFromVersSpec $mod] eq {*} && [llength\
      [getVariantListFromVersSpec $mod]]}]
}

# ;;; Local Variables:
# ;;; Mode: tcl-mode
# ;;; tcl-indent-level: 3
# ;;; tcl-continued-indent-level: 3
# ;;; indent-tabs-mode: nil
# ;;; End:
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
