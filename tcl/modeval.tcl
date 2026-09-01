##########################################################################

# MODEVAL.TCL, module evaluation procedures
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

# gather for the current top evaluation the information on all evaluations
# happening under its umbrella
proc registerModuleEval {context msgrecid {failedmod {}} {failedcontext {}}} {
   set evalid [topState evalid]
   set unset [expr {$failedmod eq {} ? 0 : 1}]
   set contextset 0
   # unload dependent reload evaluations are mixed with dependent unload ones
   if {$context eq {depre_un}} {
      set context depun
   }

   # add msgrecid to existing evaluation context list
   if {[info exists ::g_moduleEval($evalid)]} {
      for {set i 0} {$i < [llength $::g_moduleEval($evalid)]} {incr i 1} {
         set contextevallist [lindex $::g_moduleEval($evalid) $i]
         if {[lindex $contextevallist 0] eq $context} {
            if {$unset} {
               lrem contextevallist $msgrecid
            } else {
               lappend contextevallist $msgrecid
            }
            set ::g_moduleEval($evalid) [expr {[llength $contextevallist] > 1\
               ? [lreplace $::g_moduleEval($evalid) $i $i $contextevallist]\
               : [lreplace $::g_moduleEval($evalid) $i $i]}]
            set contextset 1
            break
         }
      }
   }

   # add msgrecid to new evaluation context list
   if {!$unset && !$contextset} {
      lappend ::g_moduleEval($evalid) [list $context $msgrecid]
   }

   # add mod to failed evaluation list
   if {$unset} {
      lappend ::g_moduleFailedEval($evalid) $failedcontext $failedmod
      if {[depthState reportholdid]} {
         lappend ::g_holdModuleFailedEval([currentState reportholdid])\
            $evalid $failedcontext $failedmod
      }
   }
}

# record that module evaluation is set hidden
proc registerModuleEvalHidden {context msgrecid} {
   set evalid [topState evalid]
   # unload dependent reload evaluations are mixed with dependent unload ones
   if {$context eq {depre_un}} {
      set context depun
   }
   lappend ::g_moduleHiddenEval($evalid:$context) $msgrecid
}

proc changeContextOfModuleEval {mod old_context new_context} {
   set evalid [topState evalid]
   # find old and new context evaluations
   for {set i 0} {$i < [llength $::g_moduleEval($evalid)]} {incr i 1} {
      set context_eval_list [lindex $::g_moduleEval($evalid) $i]
      if {[lindex $context_eval_list 0] eq $old_context} {
         set old_context_idx $i
         set old_context_eval_list $context_eval_list
      } elseif {[lindex $context_eval_list 0] eq $new_context} {
         set new_context_idx $i
         set new_context_eval_list $context_eval_list
      }
      if {[info exists old_context_idx] && [info exists new_context_idx]} {
         break
      }
   }

   # module evaluation not found
   if {![info exists old_context_idx]} {
      return
   }

   # new context has no evaluation yet
   if {![info exists new_context_idx]} {
      set new_context_idx end+1
      set new_context_eval_list [list $new_context]
   }

   # find evaluation id of module
   foreach msgrecid [lrange $old_context_eval_list 1 end] {
      if {$mod eq [getModuleFromEvalId $msgrecid]} {
         set mod_evalid $msgrecid
         break
      }
   }
   if {![info exists mod_evalid]} {
      return
   }

   # remove evaluation from old context
   lrem old_context_eval_list $mod_evalid
   lset ::g_moduleEval($evalid) $old_context_idx $old_context_eval_list

   # insert evaluation at start of new context
   set new_context_eval_list [linsert $new_context_eval_list 1 $mod_evalid]
   # on Tcl 8.5, lset command cannot append a list
   if {$new_context_idx eq {end+1}} {
      lappend ::g_moduleEval($evalid) $new_context_eval_list
   } else {
      lset ::g_moduleEval($evalid) $new_context_idx $new_context_eval_list
   }

   # change context of hidden evaluation
   set old_hidden_evalid $evalid:$old_context
   if {[info exists ::g_moduleHiddenEval($old_hidden_evalid)]} {
      if {$mod_evalid in $::g_moduleHiddenEval($old_hidden_evalid)} {
         lrem ::g_moduleHiddenEval($old_hidden_evalid) $mod_evalid
         set new_hidden_evalid $evalid:$new_context
         lappend ::g_moduleHiddenEval($new_hidden_evalid) $mod_evalid
      }
   }
}

# get context of currently evaluated module
proc currentModuleEvalContext {} {
   return [lindex $::g_moduleEvalAttempt([currentState modulenamevr]) end]
}

# record module evaluation attempt and corresponding context
proc registerModuleEvalAttempt {context mod mod_file} {
   lappendNoDup ::g_moduleEvalAttempt($mod) $context
   lappendNoDup ::g_moduleFileEvalAttempt($mod) $mod_file
}

proc unregisterModuleEvalAttempt {context mod mod_file} {
   lrem ::g_moduleEvalAttempt($mod) $context
   lrem ::g_moduleFileEvalAttempt($mod) $mod_file
}

# is at least one module passed as argument evaluated in passed context
proc isModuleEvaluated {context exclmod modulepath_list args} {
   set ret 0
   # look at all evaluated mod except excluded one (currently evaluated mod)
   foreach evalmod [lsearch -all -inline -not [array names\
      ::g_moduleEvalAttempt] $exclmod] {
      # test evaluated module matches specified modulepaths
      if {[llength $modulepath_list]} {
         set eval_mod_file_match 0
         foreach eval_mod_file $::g_moduleFileEvalAttempt($evalmod) {
            if {[isModulefileInModulepathList $eval_mod_file\
               $modulepath_list]} {
               set eval_mod_file_match 1
               break
            }
         }
         if {!$eval_mod_file_match} {
            continue
         }
      }
      set evalmatch 0
      # test arguments against all names of evaluated module (translate
      # eventual modspec in evalmod into module names, in case module
      # evaluation stopped prior module name setup)
      # retrieve variants to pass them directly to modEq
      set modvrlist [getVariantList $evalmod 0 0 1]
      foreach mod [getAllModulesFromVersSpec $evalmod] {
         foreach name $args {
            # indicate module is loading to also compare against all alt names
            if {[modEq $name $mod eqstart 1 1 1 $modvrlist]} {
               set evalmatch 1
               if {$context eq {any} || $context in\
                  $::g_moduleEvalAttempt($evalmod)} {
                  set ret 1
               }
               break
            }
         }
         if {$evalmatch} {
            break
         }
      }
      if {$ret} {
         break
      }
   }
   return $ret
}

# was passed mod already evaluated for context and failed
proc isModuleEvalFailed {context mod} {
   set ret 0
   set evalid [topState evalid]
   if {[info exists ::g_moduleFailedEval($evalid)]} {
      foreach {curcon curmod} $::g_moduleFailedEval($evalid) {
         if {$context eq $curcon && $mod eq $curmod} {
            set ret 1
            break
         }
      }
   }
   return $ret
}

# return list of currently loading modules in stack
proc getLoadingModuleList {} {
   set modlist [list]
   for {set i 0} {$i < [depthState modulename]} {incr i 1} {
      if {[lindex [getState mode] $i] eq {load}} {
         lappend modlist [lindex [getState modulename] $i]
      }
   }
   return $modlist
}

# return list of currently loading modulefiles in stack
proc getLoadingModuleFileList {} {
   set modlist [list]
   for {set i 0} {$i < [depthState modulefile]} {incr i 1} {
      if {[lindex [getState mode] $i] eq {load}} {
         lappend modlist [lindex [getState modulefile] $i]
      }
   }
   return $modlist
}

# return list of currently unloading modules in stack
proc getUnloadingModuleList {} {
   set modlist [list]
   for {set i 0} {$i < [depthState modulename]} {incr i 1} {
      if {[lindex [getState mode] $i] eq {unload}} {
         lappend modlist [lindex [getState modulename] $i]
      }
   }
   return $modlist
}

# sort passed module list following both loaded and dependency orders
proc sortModulePerLoadedAndDepOrder {modlist {nporeq 0} {loading 0}} {
   # sort per loaded order
   set sortlist {}
   if {[llength $modlist]} {
      foreach lmmod [getEnvLoadedModulePropertyParsedList name] {
         if {$lmmod in $modlist} {
            lappend sortlist $lmmod
         }
      }
      # also sort eventual loading modules if asked
      if {$loading} {
         foreach loadingmod [lreverse [getLoadingModuleList]] {
            if {$loadingmod in $modlist} {
               lappend sortlist $loadingmod
            }
         }
      }
   }

   # then refine sort with dependencies between loaded modules: a dependent
   # module should be placed prior the loaded module requiring it
   set reqListVar [expr {$nporeq ? {::g_moduleNPODepend} :\
      {::g_moduleDepend}}]
   set i 0
   set imax [llength $sortlist]
   while {$i < $imax} {
      set mod [lindex $sortlist $i]
      set jmin $imax

      ##nagelfar ignore #4 Suspicious variable name
      if {[info exists ${reqListVar}($mod)]} {
         # goes over all dependent modules to find the first one in the loaded
         # order list located after requiring mod
         foreach lmmodlist [set ${reqListVar}($mod)] {
            foreach lmmod $lmmodlist {
               set j [lsearch -exact $sortlist $lmmod]
               if {$j > $i && $j < $jmin} {
                  set jmin $j
                  set jminmod $lmmod
               }
            }
         }
      }

      # move first dependent module found after currently inspected mod right
      # before it
      if {$jmin != $imax} {
         set sortlist [linsert [lreplace $sortlist $jmin $jmin] $i $jminmod]
      # or go to next element in list if current element has not been changed
      } else {
         incr i
      }
   }

   return $sortlist
}

# return list of loaded modules having an unmet requirement on passed mod
# and their recursive dependent
proc getUnmetDependentLoadedModuleList {modnamevr mod_file} {
   set unmetdeplist {}
   set depmodlist {}
   set mod [getModuleNameAndVersFromVersSpec $modnamevr]
   set vrlist [getVariantList $modnamevr 0 0 1]

   # skip dependent analysis if mod has a conflict with a loaded module
   set modconlist [getModuleLoadedConflict $mod]
   if {![llength $modconlist]} {
      foreach ummod [array names ::g_unmetDepHash] {
         if {[modEq $ummod $mod eqstart 1 2 1 $vrlist]} {
            foreach {depmod prereq_path_list} $::g_unmetDepHash($ummod) {
               if {![isModulefileMatchSpecificPath $mod_file\
                  $prereq_path_list]} {
                  continue
               }

               lappend depmodlist $depmod
               # temporarily remove prereq violation of depmod if mod
               # load solves it (no other prereq is missing)
               if {[info exists ::g_prereqViolation($depmod)]} {
                  foreach prereq $::g_prereqViolation($depmod) {
                     foreach modpre $prereq {
                        # also temporarily remove prereq violation for
                        # requirements loaded after dependent module
                        if {[modEq $modpre $mod eqstart 1 2 1 $vrlist] ||\
                           [is-loaded $modpre]} {
                           # backup original violation to restore it later
                           if {![info exists preunvioarr($depmod)]} {
                              set preunvioarr($depmod)\
                                 $::g_prereqViolation($depmod)
                           }
                           # temporarily remove matching violation
                           lrem ::g_prereqViolation($depmod) $prereq
                           if {![llength $::g_prereqViolation($depmod)]} {
                              unset ::g_prereqViolation($depmod)
                           }
                           break
                        }
                     }
                  }
               }
            }
         }
      }
   }

   # select dependent if all its constraint are now satisfied (after removing
   # eventual prereq violation toward mod)
   foreach depmod $depmodlist {
      if {[areModuleConstraintsSatisfied $depmod]} {
         lappendNoDup unmetdeplist $depmod
      }
   }

   # get dependent of dependent
   set deplist [getDependentLoadedModuleList $unmetdeplist 0 0 0 0 1]

   # restore temporarily lift prereq violation
   if {[array exists preunvioarr]} {
      foreach depmod [array names preunvioarr] {
         set ::g_prereqViolation($depmod) $preunvioarr($depmod)
      }
   }

   set sortlist [sortModulePerLoadedAndDepOrder [list {*}$unmetdeplist\
      {*}$deplist]]
   reportDebug "got '$sortlist'"
   return $sortlist
}

# return list of loaded modules declaring a prereq on passed mod with
# distinction made with strong prereqs (no alternative loaded) or weak and
# also with prereq loaded after their dependent module
proc getDirectDependentList {mod {strong 0} {nporeq 0} {loading 0}\
   {othmodlist {}}} {
   set deplist {}

   # include or not requirements loaded after their dependent
   if {$nporeq} {
      set depListVar ::g_dependNPOHash
      set reqListVar ::g_moduleNPODepend
   } else {
      set depListVar ::g_dependHash
      set reqListVar ::g_moduleDepend
   }

   ##nagelfar ignore #2 Suspicious variable name
   if {[info exists ${depListVar}($mod)]} {
      foreach depmod [set ${depListVar}($mod)] {
         set add 1
         # skip optional dependency if only looking for strong ones
         # look at an additionally processed mod list to determine if all
         # mods from a dependent list (composed of optional parts) are part
         # of the search, which means mod is not optional but strong dependent
         if {$strong && [llength $depmod] > 1} {
            ##nagelfar ignore Suspicious variable name
            foreach lmmodlist [set ${reqListVar}([lindex $depmod 0])] {
               if {$mod in $lmmodlist} {
                  foreach lmmod $lmmodlist {
                     # other mod part of the opt list is not there so mod
                     # is considered optional
                     if {$lmmod ni $othmodlist} {
                        set add 0
                        break
                     }
                  }
                  break
               }
            }
         }

         if {$add} {
            lappend deplist [lindex $depmod 0]
         }
      }
   }

   # take currently loading modules into account if asked
   if {$loading} {
      foreach loading_mod [getLoadingModuleList] {
         foreach prereq_match [getLoadedModulePrereqListAndLoadedMatch\
            $loading_mod] {
            set lmprelist {}
            set item_match_list [lassign $prereq_match prereq\
               prereq_path_list]
            foreach {prereq_mod_item loaded_mod_match ign} $item_match_list {
               if {[string length $loaded_mod_match]} {
                  lappend lmprelist $loaded_mod_match
               }
            }
            if {$mod in $lmprelist && (!$strong || [llength $lmprelist]\
               == 1)} {
               lappend deplist $loading_mod
               break
            }
         }
      }
   }

   return $deplist
}

# gets the list of all loaded modules which are dependent of passed modlist
# ordered by load position. strong argument controls whether only the active
# dependent modules should be returned or also those that are optional. direct
# argument controls if only dependent module directly requiring passed mods
# should be returned or its full dependent tree. nporeq argument tells if
# requirement loaded after their dependent should be returned. sat_constraint
# argument controls whether only the loaded module satisfying their constraint
# should be part or not of the resulting list. being_unload argument controls
# whether loaded modules in conflict with one or multiple modules from modlist
# should be added to the dependent list as these modules are currently being
# unloaded and these conflicting loaded modules should be refreshed.
proc getDependentLoadedModuleList {modlist {strong 1} {direct 1} {nporeq 0}\
   {loading 1} {sat_constraint 0} {being_unload 0}} {
   reportDebug "get loaded mod dependent of '$modlist' (strong=$strong,\
      direct=$direct, nporeq=$nporeq, loading=$loading,\
      sat_constraint=$sat_constraint, being_unload=$being_unload)"

   set deplist {}
   set fulllist $modlist
   # look at consistent requirements for unloading modules
   set unlonporeq [expr {$being_unload ? 0 : $nporeq}]
   foreach mod $modlist {
      # no duplicates or modules from query list
      lappendNoDup fulllist {*}[getDirectDependentList $mod $strong\
         $unlonporeq $loading $fulllist]
   }

   if {$being_unload} {
      # invite modules in violation with mods to be part of the dependent list
      # with their own dependent modules as mod is being unloaded. Achieve so
      # by faking that conflict violation is gone
      foreach mod $modlist {
         set modconlist [getModuleLoadedConflict $mod]
         if {[llength $modconlist]} {
            unsetModuleConflictViolation $mod
            set conunvioarr($mod) $modconlist
            lappendNoDup fulllist {*}$modconlist
         }
      }
   }
   set unloadingmodlist [getUnloadingModuleList]
   for {set i [llength $modlist]} {$i < [llength $fulllist]} {incr i 1} {
      set depmod [lindex $fulllist $i]

      # skip already added mod or mod violating constraints if asked
      if {!$sat_constraint || [areModuleConstraintsSatisfied $depmod\
         $nporeq]} {
         # get dependent mod of dep mod when looking at full dep tree
         if {!$direct} {
            lappendNoDup fulllist {*}[getDirectDependentList $depmod $strong\
               $nporeq 0 $fulllist]
         }
         # avoid module currently unloading from result list
         if {$depmod ni $unloadingmodlist} {
            lappend deplist $depmod
         }
      }
   }

   # restore conflict violation if any
   if {[array exists conunvioarr]} {
      foreach conunvio [array names conunvioarr] {
         setModuleConflictViolation $conunvio $conunvioarr($conunvio)
      }
   }

   # sort complete result list to match both loaded and dependency orders
   set sortlist [sortModulePerLoadedAndDepOrder $deplist $nporeq $loading]
   reportDebug "got '$sortlist'"
   return $sortlist
}

# may given module be automatically unloaded
# unmodlist: pass a list of modules that are going to be unloaded
proc isModuleUnloadable {mod {unmodlist {}}} {
   set ret 1

   # module may be unloaded if it has been automatically loaded, it is not
   # tagged keep-loaded and it is not sticky.
   if {[isModuleTagged $mod loaded 1] || [isModuleTagged $mod keep-loaded\
      1] || [isModuleSticky $mod]} {
      set ret 0
   # there should no one requiring module or these dependent should be part of
   # the unloaded/unloading list
   } else {
      foreach depmod [getDirectDependentList $mod] {
         if {$depmod ni $unmodlist} {
            set ret 0
            break
         }
      }
   }

   return $ret
}

# gets the list of all loaded modules which are required by passed mod_list
# ordered by load position. a list of modules to exclude may be provided
# (usually to skip requirements that will be unloaded)
proc getRequiredLoadedModuleList {mod_list {excluded_mod_list {}}} {
   # search over all list of loaded modules, starting with passed module
   # list, then adding in turns their requirements
   set full_list $mod_list
   for {set i 0} {$i < [llength $full_list]} {incr i 1} {
      # gets the list of loaded modules which are required by depmod
      foreach req_mod_list $::g_moduleDepend([lindex $full_list $i]) {
         foreach req_mod $req_mod_list {
            if {$req_mod ni $excluded_mod_list} {
               lappendNoDup full_list $req_mod
            }
         }
      }
   }

   # sort complete result list to match both loaded and dependency orders
   set sort_list [sortModulePerLoadedAndDepOrder [lrange $full_list [llength\
      $mod_list] end]]
   reportDebug "got '$sort_list'"
   return $sort_list
}

# how many settings bundle are currently saved
proc getSavedSettingsStackDepth {} {
   return [llength $::g_SAVE_var]
}

# manage settings to save as a stack to have a separate set of settings
# for each module loaded or unloaded in order to be able to restore the
# correct set in case of failure
proc pushSettings {} {
   foreach var {g_clearedEnvVars g_Aliases g_stateEnvVars g_stateAliases\
      g_stateFunctions g_Functions g_stateCompletes g_Completes\
      g_newXResources g_delXResources g_loadedModules g_loadedModuleFiles\
      g_loadedModuleVariant g_loadedModuleConflict g_loadedModulePrereq\
      g_loadedModulesRefresh g_loadedModuleAltname g_loadedModuleAutoAltname\
      g_loadedModuleAliasAltname g_moduleDepend g_dependHash\
      g_moduleNPODepend g_dependNPOHash g_prereqViolation\
      g_prereqNPOViolation g_conflictViolation g_moduleUnmetDep\
      g_unmetDepHash g_moduleEval g_moduleHiddenEval g_scanModuleVariant\
      g_savedLoReqOfReloadMod g_savedLoReqOfUnloadMod\
      g_loadedModulePrereqPath g_tagHash g_loadedByModroot g_modrootByLoaded\
      g_loadedModulePosition g_modrootByLoadedConflict\
      g_loadedConflictByModroot} {
      ##nagelfar ignore Suspicious variable name
      lappend save_array $var [array get ::$var]
   }
   lappend ::g_SAVE_array $save_array
   lappend ::g_SAVE_env [array get ::env]

   # save non-array variable and indication if it was set
   foreach var {g_changeDir g_stdoutPuts g_prestdoutPuts g_return_text\
      g_uReqUnFromDepReList} {
      ##nagelfar ignore #2 Badly formed if statement
      lappend save_var $var {*}[if {[info exists ::$var]} {list 1 [set\
         ::$var]} {list 0 {}}]
   }
   lappend ::g_SAVE_var $save_var
   reportDebug "settings saved (#[getSavedSettingsStackDepth])"
}

proc popSettings {} {
   foreach var {::g_SAVE_array ::g_SAVE_env ::g_SAVE_var} {
      ##nagelfar vartype var varName
      lpop $var
   }
   reportDebug "previously saved settings flushed\
      (#[getSavedSettingsStackDepth])"
}

proc restoreSettings {} {
   foreach {var val} [lindex $::g_SAVE_array end] {
      ##nagelfar ignore #2 Suspicious variable name
      array unset ::$var
      array set ::$var $val
   }
   # specific restore mechanism for ::env as unsetting this array will make
   # Tcl stop monitoring env accesses and not update env variables anymore
   array set saved_env [lindex $::g_SAVE_env end]
   array set ::env [array get saved_env]
   set saved_env_var_list [array names saved_env]
   foreach var [array names ::env] {
      if {$var ni $saved_env_var_list} {
         unset ::env($var)
      }
   }
   # restore non-array variable if it was set
   foreach {var is_defined val} [lindex $::g_SAVE_var end] {
      ##nagelfar ignore #4 Suspicious variable name
      if {$is_defined} {
         set ::$var $val
      } else {
         unset -nocomplain ::$var
      }
   }
   reportDebug "previously saved settings restored\
      (#[getSavedSettingsStackDepth])"
}

# clear environment change related variables to undo modifications produced by
# evaluated modulefile(s)
proc flushEnvSettings {} {
   foreach var {g_Aliases g_stateEnvVars g_stateAliases g_stateFunctions\
      g_Functions g_stateCompletes g_Completes g_newXResources\
      g_delXResources g_changeDir g_stdoutPuts g_prestdoutPuts\
      g_return_text} {
      ##nagelfar ignore #2 Suspicious variable name
      if {[info exists ::$var]} {
         unset ::$var
      }
   }
}

# load modules passed as args designated as requirement
proc loadRequirementModuleList {tryload optional tag_list modulepath_list\
   args} {
   set ret 0
   set prereqloaded 0

   # return cached result if any
   set searchid $tryload:$optional:$tag_list:$modulepath_list:$args
   if {[info exists ::g_loadRequirementModuleListMemCache($searchid)]} {
      return $::g_loadRequirementModuleListMemCache($searchid)
   }

   # calling procedure must have already parsed module specification in args
   set loadedmod_list {}
   foreach mod $args {
      # get all loaded or loading mod in args list
      if {[set loadedmod [getLoadedMatchingName $mod returnfirst 0 {}\
         $modulepath_list]] ne {} || [set loadedmod [getLoadedMatchingName\
         $mod returnfirst 1 {} $modulepath_list]] ne {}} {
         lappend loadedmod_list $loadedmod
      }
   }

   if {![llength $loadedmod_list]} {
      set imax [llength $args]
      # if prereq list specified, try to load first then
      # try next if load of first module not successful
      for {set i 0} {$i<$imax && !$prereqloaded} {incr i 1} {
         set arg [lindex $args $i]

         # hold output from current evaluation to catch 'module not found'
         # message that occurs outside of sub evaluation
         lappendState reportholdrecid [currentState msgrecordid]
         # hold output of each sub evaluation until they are all done to drop
         # those that failed if one succeed or if optional
         set curholdid load-$i-$arg
         lappendState reportholdid $curholdid
         if {[catch {set retlo [cmdModuleLoad reqlo 0 $tryload 0 $tag_list\
            $modulepath_list $arg]} errorMsg]} {
            # if an error is raised, release output and rethrow the error
            # (could be raised if no modulepath defined for instance)
            lpopState reportholdid
            lpopState reportholdrecid
            lappend holdidlist $curholdid report
            releaseHeldReport {*}$holdidlist
            knerror $errorMsg
         }
         # update return value if an issue occurred in cmdModuleLoad
         if {$retlo != 0} {
            set ret $retlo
         }
         lpopState reportholdid
         lpopState reportholdrecid

         if {[string length [getLoadedMatchingName $arg returnfirst 0 {}\
            $modulepath_list]]} {
            set prereqloaded 1
            # set previous reports to be dropped as this one succeed
            if {[info exists holdidlist]} {
               foreach {holdid action} $holdidlist {
                  lappend newholdidlist $holdid drop
               }
               set holdidlist $newholdidlist
            }
         }
         # drop report if not loaded and optional
         set action [expr {$prereqloaded || !$optional ? {report} : {drop}}]
         lappend holdidlist $curholdid $action
      }
      # output held messages
      releaseHeldReport {*}$holdidlist
   } else {
      set prereqloaded 1
      # apply missing tag to all loaded module found
      cmdModuleTag 0 0 $tag_list {*}$loadedmod_list
   }

   set ::g_loadRequirementModuleListMemCache($searchid) [list $ret\
      $prereqloaded]
}

# save reloading module properties before they vanish with unload phase
proc savePropsOfReloadingModule {mod} {
   set is_user_asked [isModuleTagged $mod loaded 1]
   set vr_list [getVariantList $mod 1 2]
   set tag_list [getTagList $mod]
   set extra_tag_list [getExtraTagList $mod]
   set conflict_list [getLoadedConflict $mod]
   set altname_list [getLoadedAltname $mod]
   set prereq_list [getLoadedPrereq $mod]
   set prereq_path_list [getLoadedPrereqPath $mod]
   set modpath [getModulepathFromLoadedOrLoadingModule $mod]
   set ::g_savedPropsOfReloadMod($mod) [list $is_user_asked $vr_list\
      $tag_list $extra_tag_list $conflict_list $altname_list $prereq_list\
      $prereq_path_list $modpath]
}

proc getSavedPropsOfReloadingModule {mod} {
   return $::g_savedPropsOfReloadMod($mod)
}

# unload phase of a list of modules reload process
proc reloadModuleListUnloadPhase {mod_list {err_msg_tpl {}} {context\
   unload}} {
   # unload one by one to ensure same behavior whatever auto_handling state
   foreach mod [lreverse $mod_list] {
      if {[reloadModuleUnloadPhase $mod $err_msg_tpl $context]} {
         lrem mod_list $mod
      }
   }
   return $mod_list
}

proc reloadModuleUnloadPhase {mod {err_msg_tpl {}} {context unload}} {
   # record hint that mod will be reloaded (useful in case mod is sticky)
   lappendState reloading_sticky $mod
   lappendState reloading_supersticky $mod
   savePropsOfReloadingModule $mod
   # avoid failing module on unload phase
   # if force state is enabled, cmdModuleUnload returns 0
   if {[set ret [cmdModuleUnload $context match 0 s 0 $mod]]} {
      # no process stop if ongoing reload command in continue behavior
      if {![isStateEqual commandname reload] || [commandAbortOnError]} {
         set err_msg [string map [list _MOD_ [getModuleDesignation loaded\
            $mod]] $err_msg_tpl]
         lpopState reloading_sticky
         lpopState reloading_supersticky
         knerror $err_msg
      }
   }
   lpopState reloading_sticky
   lpopState reloading_supersticky
   return $ret
}

# load phase of a list of modules reload process
proc reloadModuleListLoadPhase {mod_list {errmsgtpl {}} {context load}} {
   if {![llength $mod_list]} {
      return
   }
   # loads are made with auto handling mode disabled to avoid disturbances
   # from a missing prereq automatically reloaded, so these module loads may
   # fail as prereq may not be satisfied anymore
   setConf auto_handling 0
   foreach mod $mod_list {
      lassign [getSavedPropsOfReloadingModule $mod] is_user_asked vr_list\
         tag_list extra_tag_list conflict_list altname_list prereq_list\
         prereq_path_list modpath
      # if an auto set default was excluded, module spec need parsing
      lassign [parseModuleSpecification 0 0 0 0 $mod {*}$vr_list] modnamevr

      set is_sticky [isModuleStickyFromTagList {*}$tag_list\
         {*}$extra_tag_list]

      # do not try to reload DepRe module if requirements are not satisfied
      # unless if sticky
      if {$context eq {depre} && ![isModuleLoadable $mod $modnamevr\
         $conflict_list $altname_list $prereq_list $prereq_path_list\
         $modpath] && !$is_sticky} {
         continue
      }

      # reload module with user asked property and extra tags preserved
      if {[cmdModuleLoad $context $is_user_asked 0 0 $extra_tag_list {}\
         $modnamevr]} {
         set errMsg [string map [list _MOD_ [getModuleDesignation spec\
            $modnamevr]] $errmsgtpl]
         if {$is_sticky} {
            set errMsg [string map {dependent {sticky dependent}} $errMsg]
         }
         # unless sticky no process stop if forced, or ongoing reload or
         # switch cmd in continue behavior
         if {!$is_sticky && ([getState force] || (([isStateEqual commandname\
            reload] || [isStateEqual commandname switch]) &&\
            ![commandAbortOnError]))} {
            # no msg for reload sub-cmd which provides an empty msg template
            reportWarning $errMsg
         # stop if one load fails unless force mode enabled
         } else {
            knerror $errMsg
         }
      }
   }
   setConf auto_handling 1
}

proc isModuleLoadable {mod mod_vr conflict_list altname_list prereq_list\
   prereq_path_list modpath} {
   # must set mod alternative names to correctly fetch its conflicts
   setLoadedAltname $mod {*}$altname_list
   setLoadedConflict $mod {*}$conflict_list
   set is_conflicting [llength [getModuleLoadedConflict $mod]]
   unsetLoadedConflict $mod
   unsetLoadedAltname $mod

   if {$is_conflicting} {
      return 0
   }

   array set prereq_path_arr $prereq_path_list
   foreach prereq_arg $prereq_list {
      if {[info exists prereq_path_arr($prereq_arg)]} {
         set prereq_arg_path $prereq_path_arr($prereq_arg)
      } else {
         set prereq_arg_path {}
      }
      set is_requirement_loaded 0
      foreach req_mod $prereq_arg {
         # is requirement loaded, loading or optional
         if {[string length [getLoadedMatchingName $req_mod returnfirst 0 {}\
            $prereq_arg_path]] || [string length [getLoadedMatchingName\
            $req_mod returnfirst 1 {} $prereq_arg_path]] || $req_mod eq\
            $mod} {
            set is_requirement_loaded 1
            break
         }
      }
      if {!$is_requirement_loaded} {
         return 0
      }
   }

   # module is loadable if its modulepath is still enabled or if it can be
   # found in another modulepath (variant availability is currently not
   # checked by is-avail procedure)
   if {![is-used $modpath] && ![is-avail $mod_vr]} {
      return 0
   }

   return 1
}

proc isModuleStickyFromTagList {args} {
   return [expr {{super-sticky} in $args || ({sticky} in $args && ![getState\
      force])}]
}

# test if loaded module 'mod' is sticky and if stickiness definition applies
# to one of the reloading module
proc isStickinessReloading {mod reloading_mod_list {tag sticky}} {
   set res 0
   set mod_name_vers [getModuleNameAndVersFromVersSpec $mod]
   if {[isModuleTagged $mod_name_vers $tag 1]} {
      # sticky rules (module-tag definitions) applying to loaded module have
      # been evaluated when charging loaded environment
      set full_path_mod [getModulefileFromLoadedModule $mod_name_vers]
      set tag_rule_list [getModuleTagRuleList $mod $full_path_mod $tag]

      # no rule found (in env), means sticky applies to exact same module
      if {![llength $tag_rule_list]} {
         set mod_should_reload 1
      } else {
         set mod_should_reload 0
         # if tag specifically applies to fully qualified module or module
         # name and version, exact same module should be found in reload list
         foreach tag_rule $tag_rule_list {
            if {[modEq $tag_rule $mod equal 1 0 1] || [modEq $tag_rule\
               $full_path_mod equal 1 0 1]} {
               set mod_should_reload 1
               break
            }
         }
      }

      if {$mod_should_reload} {
         set res [expr {$mod in $reloading_mod_list}]
      } else {
         # check if a reloading module satisfies each sticky rules
         foreach tag_rule $tag_rule_list {
            set res 0
            foreach reloading_mod $reloading_mod_list {
               if {[modEq $tag_rule $reloading_mod eqstart 1 0 1]} {
                  set res 1
                  break
               }
            }
            if {!$res} {
               break
            }
         }
      }
      reportDebug "stickiness ($tag), applying to $tag_rule_list, is\
         reloading=$res"
   }

   return $res
}

proc isModuleSticky {mod} {
   return [expr {[isModuleTagged $mod super-sticky 1] || ([isModuleTagged\
      $mod sticky 1] && ![getState force])}]
}

proc getModuleStickyDependentTag {mod} {
   set sticky_tag {}
   foreach dep_mod [getDependentLoadedModuleList [list $mod] 1 0 0 0] {
      if {[isModuleTagged $dep_mod super-sticky 1]} {
         set sticky_tag super-sticky
         break
      } elseif {![getState force] && [isModuleTagged $dep_mod sticky 1]} {
         set sticky_tag sticky
      }
   }
   return $sticky_tag
}

proc saveLoadedReqOfUnloadingModule {unload_mod} {
   # fetch requirements of unloading module
   set ::g_savedLoReqOfUnloadMod($unload_mod)\
      [getRequiredLoadedModuleList [list $unload_mod]]
}

proc getLoadedReqOfUnloadingModuleList {} {
   set unloading_req_mod_list {}
   foreach unloading_mod [array names ::g_savedLoReqOfUnloadMod] {
      lappendNoDup unloading_req_mod_list\
         {*}$::g_savedLoReqOfUnloadMod($unloading_mod)
   }
   return [sortModulePerLoadedAndDepOrder $unloading_req_mod_list]
}

proc clearLoadedReqOfUnloadingModuleList {} {
   array unset ::g_savedLoReqOfUnloadMod
}

proc saveLoadedReqOfReloadingModuleList {reload_mod_list unload_mod_list} {
   # fetch requirements of reloading modules skipping unloading ones
   foreach reload_mod $reload_mod_list {
      set ::g_savedLoReqOfReloadMod($reload_mod) [getRequiredLoadedModuleList\
         [list $reload_mod] $unload_mod_list]
   }
}

proc getLoadedReqOfReloadingModuleList {} {
   set reloading_req_mod_list {}
   foreach reloading_mod [array names ::g_savedLoReqOfReloadMod] {
      lappendNoDup reloading_req_mod_list\
         {*}$::g_savedLoReqOfReloadMod($reloading_mod)
   }
   return [sortModulePerLoadedAndDepOrder $reloading_req_mod_list]
}

proc unsetLoadedReqOfReloadingModule {mod} {
   unset -nocomplain ::g_savedLoReqOfReloadMod($mod)
}

proc clearLoadedReqOfReloadingModuleList {} {
   array unset ::g_savedLoReqOfReloadMod
}

proc identityUReqUnFromDepRe {depre_list unload_mod_list} {
   foreach depre [lreverse $depre_list] {
      if {[isModuleUnloadable $depre $unload_mod_list]} {
         lappend unload_mod_list $depre
         lappend ::g_uReqUnFromDepReList $depre
      }
   }
}

proc clearUReqUnFromDepReList {} {
   unset -nocomplain ::g_uReqUnFromDepReList
}

proc getIdentifiedUReqUnFromDepRe {} {
   if {[info exists ::g_uReqUnFromDepReList]} {
      return $::g_uReqUnFromDepReList
   }
}

proc removeUReqUnFromDepReAndConvertEval {} {
   set depre_list [getDepReList]
   set urequn_from_depre_list [getIdentifiedUReqUnFromDepRe]
   lassign [getDiffBetweenList $depre_list $urequn_from_depre_list] depre_list
   setDepReList $depre_list
   foreach urequn_from_depre [lreverse $urequn_from_depre_list] {
      changeContextOfModuleEval $urequn_from_depre depun urequn
   }
}

proc getUReqUnModuleList {} {
   set unloadable_mod_list {}

   # add DepRe modules that are UReqUn modules and unset their requirements
   # from reloading list (to check them for potential UReqUn modules)
   foreach urequn_from_depre [getIdentifiedUReqUnFromDepRe] {
      lappend unloadable_mod_list $urequn_from_depre
      unsetLoadedReqOfReloadingModule $urequn_from_depre
   }

   set reloading_req_mod_list [getLoadedReqOfReloadingModuleList]
   # useless requirement unload modules are unloadable req of unloaded mods
   # treat lastly loaded module first to build unloadable module list
   foreach unloading_req_mod [lreverse [getLoadedReqOfUnloadingModuleList]] {
      if {$unloading_req_mod ni $reloading_req_mod_list &&\
         [isModuleUnloadable $unloading_req_mod $unloadable_mod_list]} {
         lappend unloadable_mod_list $unloading_req_mod
      }
   }
   # return result in loaded order
   return [lreverse $unloadable_mod_list]
}

proc unloadUReqUnModules {} {
   set urequn_list [getUReqUnModuleList]
   reportDebug "urequn mod list is '$urequn_list'"

   if {[llength $urequn_list]} {
      # DepRe: Dependent to Reload (modules optionally dependent or in
      # conflict with modname, DepUn or UReqUn modules + modules dependent of
      # a module part of this DepRe batch)
      set urequn_depre_list [getDependentLoadedModuleList $urequn_list 0 0 1\
         0 1 1]
      set urequn_depre_list [reloadModuleListUnloadPhase $urequn_depre_list\
         {Unload of dependent _MOD_ failed} depre_un]
      lprependDepReList $urequn_depre_list

      set urequn_list [lreverse $urequn_list]
      for {set i 0} {$i < [llength $urequn_list]} {incr i 1} {
         set unmod [lindex $urequn_list $i]
         if {[cmdModuleUnload urequn match 0 s 0 $unmod]} {
            # main unload process continues, but the UReqUn modules that are
            # required by unmod (whose unload failed) are withdrawn from
            # UReqUn module list
            lassign [getDiffBetweenList $urequn_list\
               [getRequiredLoadedModuleList [list $unmod]]] urequn_list
         }
      }
   }
}

proc getDepUnModuleList {mod} {
   set depun_npo_list [getDependentLoadedModuleList [list $mod] 1 0 1 0]
   set depun_list [getDependentLoadedModuleList [list $mod] 1 0 0 0]
   # look at both regular dependencies or No Particular Order dependencies:
   # use NPO result if situation can be healed with NPO dependencies, which
   # will be part of DepRe list to restore the correct loading order for them
   if {[llength $depun_npo_list] <= [llength $depun_list]} {
      set depun_list $depun_npo_list
   }
   return $depun_list
}

proc clearDepReList {} {
   unset -nocomplain ::g_depReList
}

proc getDepReList {} {
   if {[info exists ::g_depReList]} {
      return $::g_depReList
   }
}

proc setDepReList {mod_list} {
   set ::g_depReList $mod_list
}

proc lprependDepReList {mod_list} {
   lprepend ::g_depReList {*}$mod_list
}

proc unloadDepUnDepReModules {unload_mod_list reload_mod_list} {
   set err_msg_tpl {Unload of dependent _MOD_ failed}
   set unload_mod_list [sortModulePerLoadedAndDepOrder [list\
      {*}$unload_mod_list {*}$reload_mod_list]]
   lprependDepReList $reload_mod_list

   foreach unload_mod [lreverse $unload_mod_list] {
      if {$unload_mod in $reload_mod_list} {
         # an error is raised if an unload eval fails
         reloadModuleUnloadPhase $unload_mod $err_msg_tpl depre_un
      } else {
         if {[cmdModuleUnload depun match 0 s 0 $unload_mod]} {
            # stop if one unload fails unless force mode enabled
            set err_msg [string map [list _MOD_ [getModuleDesignation loaded\
               $unload_mod]] $err_msg_tpl]
            knerrorOrWarningIfForced $err_msg
         }
      }
   }
}

proc reloadDepReModules {} {
   set err_msg_tpl {Reload of dependent _MOD_ failed}
   set depre_list [getDepReList]
   reloadModuleListLoadPhase $depre_list $err_msg_tpl depre
}

# Fail unload attempt if module is sticky, unless if forced or reloading
# Also fail unload if mod is super-sticky even if forced, unless reloading
proc failOrSkipUnloadIfSticky {modname modfile} {
   # when loaded, tags applies to mod name and version (not with variant)
   set is_supersticky_not_reloading [expr {[isModuleTagged $modname\
      super-sticky 1 $modfile] && [currentState reloading_supersticky] ne\
      $modname}]
   set is_sticky_not_reloading [expr {[isModuleTagged $modname sticky 1\
      $modfile] && [currentState reloading_sticky] ne $modname &&\
      [currentState unloading_sticky] ne $modname}]
   set sticky_purge [expr {[getState commandname] eq {purge} ? [getConf\
      sticky_purge] : {}}]

   if {!$is_supersticky_not_reloading && $is_sticky_not_reloading &&\
      [getState force]} {
      reportWarning [getStickyForcedUnloadMsg]
   } elseif {$is_supersticky_not_reloading || $is_sticky_not_reloading} {
      set msg [getStickyUnloadMsg [expr {$is_supersticky_not_reloading ?\
         {super-sticky} : {sticky}}]]
      # no message if sticky_purge is set to silent
      switch -- $sticky_purge {
         error - {} {knerror $msg}
         warning {reportWarning $msg}
      }

      # skip unload without raising error
      return 1
   }

   return 0
}

proc failOrSkipUnloadIfRequiredBySticky {mod} {
   set sticky_tag [getModuleStickyDependentTag $mod]
   if {$sticky_tag eq {}} {
      return 0
   }

   set msg [getStickyReqUnloadMsg $sticky_tag]
   switch -- [getConf sticky_purge] {
      error {knerror $msg}
      warning {reportWarning $msg}
   }

   return 1
}

# ;;; Local Variables:
# ;;; Mode: tcl-mode
# ;;; tcl-indent-level: 3
# ;;; tcl-continued-indent-level: 3
# ;;; indent-tabs-mode: nil
# ;;; End:
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
