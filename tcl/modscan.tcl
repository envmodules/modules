##########################################################################

# MODSCAN.TCL, modulefile scan and extra match search procedures
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

# optimized variant command for scan mode: init entry in ModuleVariant array
# to avoid variable being undefined when accessed during modulefile evaluation
# record variant definition in structure for extra match search or report
proc variant-sc {itrp args} {
   # parse args
   lassign [parseVariantCommandArgs {*}$args] name values defdflvalue\
      dflvalue isboolean

   # remove duplicate possible values for boolean variant
   if {$isboolean} {
      set values {on off}
      if {$defdflvalue} {
         set dflvalue [expr {$dflvalue ? {on} : {off}}]
      }
   }

   recordScanModuleElt $name variant

   lappend ::g_scanModuleVariant([currentState modulename]) [list $name\
      $values $defdflvalue $dflvalue $isboolean]

   # instantiate variant in modulefile context to an empty value
   reportDebug "Set variant on $itrp: ModuleVariant($name) = ''"
   $itrp eval set "{::ModuleVariant($name)}" "{}"
}

proc setenv-sc {args} {
   lassign [parseSetenvCommandArgs load set {*}$args] bhv var val

   recordScanModuleElt $var setenv envvar

   setEnvVarIfUndefined $var {}
   return {}
}

proc edit-path-sc {cmd args} {
   lassign [parsePathCommandArgs $cmd load noop {*}$args] separator allow_dup\
      idx_val ign_refcount val_set_is_delim glob_match bhv var path_list

   recordScanModuleElt $var $cmd envvar

   # record MODULEPATH edition as "module use" command
   if {$var eq {MODULEPATH} && $cmd in {append-path prepend-path}} {
      recordScanModuleUsePathList $path_list
   }

   setEnvVarIfUndefined $var {}
   return {}
}

proc pushenv-sc {var val} {
   recordScanModuleElt $var pushenv envvar

   setEnvVarIfUndefined $var {}
   return {}
}

proc unsetenv-sc {args} {
   lassign [parseUnsetenvCommandArgs load noop {*}$args] bhv var val

   recordScanModuleElt $var unsetenv envvar

   setEnvVarIfUndefined $var {}
   return {}
}

proc complete-sc {shell name body} {
   if {![string length $name]} {
      knerror "Invalid command name '$name'"
   }

   recordScanModuleElt $name complete
}

proc uncomplete-sc {name} {
   if {![string length $name]} {
      knerror "Invalid command name '$name'"
   }

   recordScanModuleElt $name uncomplete
}

proc set-alias-sc {alias what} {
   recordScanModuleElt $alias set-alias
}

proc unset-alias-sc {alias} {
   recordScanModuleElt $alias unset-alias
}

proc set-function-sc {function what} {
   recordScanModuleElt $function set-function
}

proc unset-function-sc {function} {
   recordScanModuleElt $function unset-function
}

proc chdir-sc {dir} {
   recordScanModuleElt $dir chdir
}

proc family-sc {name} {
   if {![string length $name] || ![regexp {^[A-Za-z0-9_]*$} $name]} {
      knerror "Invalid family name '$name'"
   }
   recordScanModuleElt $name family provided-alias
}

proc extensions-sc {args} {
   if {![llength $args]} {
      knerror {No module specified in argument}
   }
   set elt_list [list provide]
   if {![getConf info_extension]} {
      lappend elt_list provided-alias
   }
   foreach alias $args {
      recordScanModuleElt $alias {*}$elt_list
   }
}

proc provide-sc {args} {
   if {![llength $args]} {
      knerror {No module specified in argument}
   }
   foreach alias $args {
      recordScanModuleElt $alias provide provided-alias
   }
}

proc prereq-sc {args} {
   lassign [parsePrereqCommandArgs prereq {*}$args] tag_list modulepath_list\
      optional opt_list modspec_list

   foreach modspec $modspec_list {
      recordScanModuleElt $modspec prereq prereq-any depends-on-any require
   }
}

proc prereq-all-sc {args} {
   lassign [parsePrereqCommandArgs prereq-all {*}$args] tag_list\
      modulepath_list optional opt_list modspec_list

   foreach modspec $modspec_list {
      recordScanModuleElt $modspec prereq-all depends-on require
   }
}

proc always-load-sc {args} {
   lassign [parsePrereqCommandArgs always-load {*}$args] tag_list\
      modulepath_list optional opt_list modspec_list

   foreach modspec $modspec_list {
      recordScanModuleElt $modspec always-load require
   }
}

proc conflict-sc {args} {
   foreach modspec [parseModuleSpecification 0 0 0 0 {*}$args] {
      recordScanModuleElt $modspec conflict incompat
   }
}

proc module-sc {command args} {
   lassign [parseModuleCommandName $command help] command cmdvalid cmdempty
   # ignore sub-commands that do not either load or unload
   if {$command in {load load-any switch try-load unload use}} {
      # parse options to distinguish them from module version spec
      lassign [parseModuleCommandArgs 0 $command 0 0 {*}$args]\
         show_oneperline show_mtime show_filter search_filter search_match\
         dump_state addpath_pos not_req tag_list args
      set modspeclist [parseModuleSpecification 0 0 0 0 {*}$args]

      # no require/incompat extra specifier alias if --not-req option is set
      if {$not_req} {
         set xtaliasinc {}
         set xtaliasreq {}
      } else {
         set xtaliasinc [list incompat]
         set xtaliasreq [list require]
      }

      if {$command eq {switch}} {
         # distinguish switched-off module spec from switched-on
         # ignore command without or with too much argument
         switch -- [llength $modspeclist] {
            {1} {
               # no switched-off module with one-arg form
               recordScanModuleElt $modspeclist switch switch-on\
                  {*}$xtaliasreq
            }
            {2} {
               lassign $modspeclist swoffarg swonarg
               recordScanModuleElt $swoffarg switch switch-off {*}$xtaliasinc
               recordScanModuleElt $swonarg switch switch-on {*}$xtaliasreq
            }
         }
      } elseif {$command eq {use}} {
         recordScanModuleUsePathList $modspeclist
      } else {
         set xtalias [expr {$command eq {unload} ? $xtaliasinc : $xtaliasreq}]
         # record each module spec
         foreach modspec $modspeclist {
            recordScanModuleElt $modspec $command {*}$xtalias
         }
      }
   }
}

proc recordScanModuleUsePathList {path_list} {
   foreach path $path_list {
      set resolved_abs_path [getAbsolutePath [resolvStringWithEnv $path]]
      recordScanModuleElt $resolved_abs_path use
   }
}

proc recordScanModuleElt {name args} {
   set mod [currentState modulename]
   set modpath [currentState modulepath]
   if {![info exists ::g_scanModuleElt]} {
      set ::g_scanModuleElt [dict create]
   }
   foreach elt $args {
      if {![dict exists $::g_scanModuleElt $modpath $elt $name]} {
         dict set ::g_scanModuleElt $modpath $elt $name [list $mod]
      } else {
         ##nagelfar ignore Suspicious variable name
         dict with ::g_scanModuleElt $modpath $elt {lappend $name $mod}
      }
      reportDebug "Module $mod defines $elt:$name"
   }
}

proc getScanModuleElt {modpath elt} {
   if {[info exists ::g_scanModuleElt]} {
      if {[dict exists $::g_scanModuleElt $modpath $elt]} {
         return [dict get $::g_scanModuleElt $modpath $elt]
      }
   }
}

# test given variant specification matches what scanned module defines
proc doesModVariantMatch {mod pvrlist} {
   set ret 1
   if {[info exists ::g_scanModuleVariant($mod)]} {
      foreach availvr $::g_scanModuleVariant($mod) {
         set availvrarr([lindex $availvr 0]) [lindex $availvr 1]
         set availvrisbool([lindex $availvr 0]) [lindex $availvr 4]
      }
   }
   # no match if a specified variant is not found among module variants or
   # if the value is not available
   foreach pvr $pvrlist {
      set pvrvallist [lassign $pvr vrname pvrnot pvrisbool]
      # check at least one variant value from specification matches defined
      # available variant values
      set one_vrval_match 0
      foreach pvrval $pvrvallist {
         # if variant is a boolean, specified value should be a boolean too
         # any value accepted for free-value variant
         if {[info exists availvrarr($vrname)] && (($pvrisbool &&\
            $availvrisbool($vrname)) || (!$availvrisbool($vrname) &&\
            (![llength $availvrarr($vrname)] || $pvrval in\
            $availvrarr($vrname))))} {
            set one_vrval_match 1
            break
         }
      }
      # toggle result if negation set for this pattern
      if {$pvrnot} {
         set one_vrval_match [expr {!$one_vrval_match}]
      }
      if {!$one_vrval_match} {
         set ret 0
         break
      }
   }
   return $ret
}

# test given tag specification matches tags defined over module
proc doesModTagMatch {mod modfile ptaglist} {
   set ret 1
   foreach ptag $ptaglist {
      set namelist [lassign $ptag elt pnot]
      # check if at least one tag name from specifier value is applied on mod
      set one_name_match 0
      foreach name $namelist {
         if {[isModuleTagged $mod $name 1 $modfile]} {
            set one_name_match 1
            break
         }
      }
      # toggle result if negation set for this pattern
      if {$pnot} {
         set one_name_match [expr {!$one_name_match}]
      }
      # no tag name from specifier match mod mean no match on extra query
      if {!$one_name_match} {
         set ret 0
         break
      }
   }
   return $ret
}

# collect list of modules matching all extra specifier criteria
proc getModMatchingExtraSpec {modpath pxtlist} {
   set res [list]
   if {[info exists ::g_scanModuleElt] && [dict exists $::g_scanModuleElt\
      $modpath]} {
      foreach pxt $pxtlist {
         set namelist [lassign $pxt elt pnot]
         set one_crit_res [list]
         foreach name $namelist {
            if {$elt in {require incompat load unload prereq conflict\
               prereq-all prereq-any depends-on depends-on-any always-load\
               load-any try-load switch switch-on switch-off}} {
               if {[dict exists $::g_scanModuleElt $modpath $elt]} {
                  foreach {modspec values} [dict get $::g_scanModuleElt\
                     $modpath $elt] {
                     # modEq proc has been initialized in getModules phase #2
                     if {[modEq $modspec $name eqstart 1 5 1]} {
                        # possible duplicate module entry in result list
                        lappend one_crit_res {*}[dict get $::g_scanModuleElt\
                           $modpath $elt $modspec]
                     }
                  }
               }
            } else {
               # get mods matching one value of one extra specifier criterion
               if {[dict exists $::g_scanModuleElt $modpath $elt $name]} {
                  lappend one_crit_res {*}[dict get $::g_scanModuleElt\
                     $modpath $elt $name]
               }
            }
         }
         # result is all other modules if negation set for this pattern
         if {$pnot} {
            set modpath_mod_list [dict get $::g_scanModuleElt $modpath all\
               modulename]
            lassign [getDiffBetweenList $modpath_mod_list $one_crit_res]\
               one_crit_res
         }
         lappend all_crit_res $one_crit_res
         # no match on one criterion means no match globally, no need to test
         # further criteria
         if {![llength $one_crit_res]} {
            break
         }
      }
      # matching modules are those found in every criteria result
      set res [getIntersectBetweenList {*}$all_crit_res]
   }
   return $res
}

# determine if current module search requires an extra match search
proc isExtraMatchSearchRequired {mod} {
   # an extra match search is required if not currently inhibited and:
   # * variant or provided-alias should be reported in output
   # * mod specification contains variant during avail/paths/whatis
   # * mod specification contains extra specifier during avail/paths/whatis
   return [expr {![getState inhibit_ems 0] && ([isEltInReport variant 0] ||\
      [isEltInReport provided-alias 0] || (([llength\
      [getVariantListFromVersSpec $mod]] || [llength\
      [getExtraListFromVersSpec $mod]]) && [currentState commandname] in\
      {avail paths whatis spider}))}]
}

proc insertProvidedAliases {modpath res_arrname} {
   upvar $res_arrname found_list
   foreach {alias target_mod} [getScanModuleElt $modpath provided-alias] {
      if {![info exists found_list($alias)]} {
         ##nagelfar ignore Found constant
         set found_list($alias) [list alias $target_mod]
      }
   }
}

# scan modulefiles from currently being built module search result if extra
# match search is needed
proc scanExtraMatchSearch {modpath mod res_arrname} {
   upvar $res_arrname found_list

   # disable error reporting to avoid modulefile errors (not coping with
   # scan evaluation for instance) to pollute result
   set alreadyinhibit [getState inhibit_errreport]
   if {!$alreadyinhibit} {
      inhibitErrorReport
   }
   # evaluate all modules found in scan mode to gather content information
   lappendState mode scan

   foreach elt [array names found_list] {
      switch -- [lindex $found_list($elt) 0] {
         modulefile - virtual {
            # skip evaluation of fully forbidden modulefile
            if {![isModuleTagged $elt forbidden 0 [lindex $found_list($elt)\
               2]]} {
               ##nagelfar ignore Suspicious variable name
               execute-modulefile [lindex $found_list($elt) 2] $elt $elt $elt\
                  0 0 0 $modpath
            }
         }
      }
   }

   lpopState mode
   # re-enable error report only is it was disabled from this procedure
   if {!$alreadyinhibit} {
      setState inhibit_errreport 0
   }
}

# perform extra match search on currently being built module search result
proc filterExtraMatchSearch {modpath mod res_arrname versmod_arrname} {
   # link to variables/arrays from upper context
   upvar $res_arrname found_list
   upvar $versmod_arrname versmod_list

   # get extra match query properties
   set spec_vr_list [getVariantListFromVersSpec $mod]
   set check_variant [llength $spec_vr_list]
   lassign [getSplitExtraListFromVersSpec $mod] spec_tag_list spec_xt_list
   set check_extra [llength $spec_xt_list]
   set check_tag [llength $spec_tag_list]
   set filter_res [expr {$check_variant || $check_extra || $check_tag}]

   set unset_list {}
   set keep_list {}
   foreach elt [array names found_list] {
      if {$check_tag} {
         collectModuleTags $elt
      }

      # unset elements that do not match extra query
      if {$filter_res} {
         switch -- [lindex $found_list($elt) 0] {
            alias {
               # module alias does not hold properties to match extra query
               lappend unset_list $elt
            }
            modulefile - virtual {
               if {$check_variant && ![doesModVariantMatch $elt\
                  $spec_vr_list]} {
                  lappend unset_list $elt
               } elseif {$check_tag && ![doesModTagMatch $elt [lindex\
                  $found_list($elt) 2] $spec_tag_list]} {
                  lappend unset_list $elt
               } elseif {$check_extra} {
                  # know currently retained modules to later compute those
                  # to withdrawn
                  lappend keep_list $elt
               }
            }
         }
      }
   }

   if {$check_tag} {
      # indicate tags have been collected for this modulepath
      lappendState tags_collected_in $modpath
   }

   # get list of modules matching extra specifiers to determine those to not
   # matching that need to be withdrawn from result
   if {$check_extra} {
      set extra_keep_list [getModMatchingExtraSpec $modpath $spec_xt_list]
      lassign [getDiffBetweenList $keep_list $extra_keep_list]\
         extra_unset_list
      lappend unset_list {*}$extra_unset_list
   }

   # unset marked elements
   foreach elt $unset_list {
      unset found_list($elt)
      # also unset any symbolic version pointing to unset elt
      if {[info exists versmod_list($elt)]} {
         set eltsym_list $versmod_list($elt)
         for {set i 0} {$i < [llength $eltsym_list]} {incr i} {
            set eltsym [lindex $eltsym_list $i]
            # getModules phase #2 may have already withdrawn symbol
            if {[info exists found_list($eltsym)]} {
               unset found_list($eltsym)
            }
            # also unset symbolic version applying to dir name if removing
            # default symbol
            if {[file tail $eltsym] eq {default}} {
               set eltdir [file dirname $eltsym]
               if {[info exists versmod_list($eltdir)]} {
                  lappend eltsym_list {*}$versmod_list($eltdir)
               }
            }
         }
      }
   }
}

# ;;; Local Variables:
# ;;; Mode: tcl-mode
# ;;; tcl-indent-level: 3
# ;;; tcl-continued-indent-level: 3
# ;;; indent-tabs-mode: nil
# ;;; End:
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
