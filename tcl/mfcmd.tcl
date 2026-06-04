##########################################################################

# MFCMD.TCL, modulefile command procedures
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

# Dictionary-style string comparison
# Use dictionary sort of lsort proc to compare two strings in the "string
# compare" fashion (returning -1, 0 or 1). Tcl dictionary-style comparison
# enables to compare software versions (ex: "1.10" is greater than "1.8")
proc versioncmp {str1 str2} {
   if {$str1 eq $str2} {
      return 0
   # put both strings in a list, then lsort it and get first element
   } elseif {[lindex [lsort -dictionary [list $str1 $str2]] 0] eq $str1} {
      return -1
   } else {
      return 1
   }
}

proc module-info {what {more {}}} {
   set mode [currentState mode]

   switch -- $what {
      mode {
         if {$more ne {}} {
            set command [currentState commandname]
            return [expr {$mode eq $more || ($more eq {remove} && $mode eq \
               {unload}) || ($more eq {switch} && $command eq {switch}) ||\
               ($more eq {nonpersist} && $mode eq {refresh})}]
         } else {
            return $mode
         }
      }
      command {
         set command [currentState commandname]
         if {$more eq {}} {
            return $command
         } else {
            return [expr {$command eq $more}]
         }
      }
      name {
         return [currentState modulename]
      }
      specified {
         return [currentState specifiedname]
      }
      shell {
         if {$more ne {}} {
            return [expr {[getState shell] eq $more}]
         } else {
            return [getState shell]
         }
      }
      flags {
         # C-version specific option, not relevant for Tcl-version but return
         # a zero integer value to avoid breaking modulefiles using it
         return 0
      }
      shelltype {
         if {$more ne {}} {
            return [expr {[getState shelltype] eq $more}]
         } else {
            return [getState shelltype]
         }
      }
      user {
         # C-version specific option, not relevant for Tcl-version but return
         # an empty value or false to avoid breaking modulefiles using it
         if {$more ne {}} {
            return 0
         } else {
            return {}
         }
      }
      alias {
         set ret [resolveModuleVersionOrAlias $more [isIcase]]
         if {$ret ne $more} {
            return $ret
         } else {
            return {}
         }
      }
      trace {
         return {}
      }
      tracepat {
         return {}
      }
      type {
         return Tcl
      }
      symbols {
         lassign [getModuleNameVersion $more 1] mod modname modversion
         set sym_list [getVersAliasList $mod]
         # if querying special symbol "default" but nothing found registered
         # on it, look at symbol registered on bare module name in case there
         # are symbols registered on it but no default symbol set yet to link
         # to them
         if {![llength $sym_list] && $modversion eq {default}} {
            set sym_list [getVersAliasList $modname]
         }
         return [join $sym_list :]
      }
      tags {
         # refresh mod name version and variant to correctly get all matching
         # tags (in case tags apply to specific module variant)
         set modname [currentState modulename]
         set modnamevr [getAndParseLoadedModuleWithVariant $modname]
         collectModuleTags $modnamevr

         if {$more ne {}} {
            return [expr {$more in [getTagList $modnamevr [currentState\
               modulefile]]}]
         } else {
            return [getTagList $modnamevr [currentState modulefile]]
         }
      }
      version {
         lassign [getModuleNameVersion $more 1] mod
         return [resolveModuleVersionOrAlias $mod [isIcase]]
      }
      loaded {
         lassign [getModuleNameVersion $more 1] mod
         return [getLoadedMatchingName $mod returnall]
      }
      usergroups {
         if {[getState is_win]} {
            knerror "module-info usergroups not supported on Windows platform"
         } else {
            if {$more ne {}} {
               return [expr {$more in [getState usergroups]}]
            } else {
               return [getState usergroups]
            }
         }
      }
      username {
         if {[getState is_win]} {
            knerror "module-info username not supported on Windows platform"
         } else {
            if {$more ne {}} {
               return [expr {[getState username] eq $more}]
            } else {
               return [getState username]
            }
         }
      }
      default {
         knerror "module-info $what not supported"
         return {}
      }
   }
}

proc module-whatis {args} {
   lappend ::g_whatis [join $args]

   return {}
}

# Specifies a default or alias version for a module that points to an
# existing module version Note that aliases defaults are stored by the
# short module name (not the full path) so aliases and defaults from one
# directory will apply to modules of the same name found in other
# directories.
proc module-version {args} {
   lassign [getModuleNameVersion [lindex $args 0] 1] mod modname modversion

   # go for registration only if valid modulename
   if {$mod ne {}} {
      foreach version [lrange $args 1 end] {
         set aliasversion $modname/$version
         # do not alter a previously defined alias version
         if {![info exists ::g_moduleVersion($aliasversion)]} {
            setModuleResolution $aliasversion $mod $version
         } else {
            reportWarning "Symbolic version '$aliasversion' already defined"
         }
      }
   }

   return {}
}

proc module-alias {args} {
   lassign [getModuleNameVersion [lindex $args 0]] alias
   lassign [getModuleNameVersion [lindex $args 1] 1] mod

   reportDebug "$alias = $mod"

   if {[setModuleResolution $alias $mod]} {
      set ::g_moduleAlias($alias) $mod
      set ::g_sourceAlias($alias) [currentState modulefile]
   }

   return {}
}

proc module-virtual {args} {
   lassign [getModuleNameVersion [lindex $args 0]] mod
   set modfile [getAbsolutePath [lindex $args 1]]

   reportDebug "$mod = $modfile"

   set ::g_moduleVirtual($mod) $modfile
   set ::g_sourceVirtual($mod) [currentState modulefile]

   return {}
}

# Parse date time argument value and translate it into epoch time
proc __parseDateTimeArg {opt datetime} {
   if {[regexp {^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2})?$} $datetime match\
      timespec]} {
      # time specification is optional
      if {$timespec eq {}} {
         append datetime T00:00
      }
      # return corresponding epoch time
      return [clock scan $datetime -format %Y-%m-%dT%H:%M]
   } else {
      knerror "Incorrect $opt value '$datetime' (valid date time format is\
         'YYYY-MM-DD\[THH:MM\]')"
   }
}

# parse application criteria arguments and determine if command applies
proc parseApplicationCriteriaArgs {aftbef nearsec args} {
   set otherargs {}

   # parse argument list
   foreach arg $args {
      if {[info exists nextargisval]} {
         ##nagelfar vartype nextargisval varName
         set $nextargisval $arg
         unset nextargisval
      } elseif {[info exists nextargisdatetime]} {
         ##nagelfar ignore Suspicious variable name
         set ${nextargisdatetime}raw $arg
         # get epoch time from date time argument value
         ##nagelfar vartype nextargisdatetime varName
         ##nagelfar ignore Unknown variable
         set $nextargisdatetime [parseDateTimeArg $prevarg $arg]
         unset nextargisdatetime
      } else {
         switch -- $arg {
            --after - --before {
               # treat --after/--before as regular content if disabled
               if {!$aftbef} {
                  lappend otherargs $arg
               } else {
                  set nextargisdatetime [string trimleft $arg -]
               }
            }
            --not-group - --not-user - --group - --user {
               if {[getState is_win]} {
                  knerror "Option '$arg' not supported on Windows platform"
               } else {
                  set nextargisval [string map {- {}} $arg]list
               }
            }
            default {
               lappend otherargs $arg
            }
         }
         set prevarg $arg
      }
   }

   if {[info exists nextargisval] || [info exists nextargisdatetime]} {
      knerror "Missing value for '$prevarg' option"
   }

   set user [expr {[info exists userlist] && [getState username] in\
      $userlist}]
   set group [expr {[info exists grouplist] && [isIntBetweenList\
      $grouplist [getState usergroups]]}]

   # does it apply to current user?
   set notuser [expr {[info exists notuserlist] && [getState username] in\
      $notuserlist}]
   set notgroup [expr {[info exists notgrouplist] && [isIntBetweenList\
      $notgrouplist [getState usergroups]]}]

   # does it apply currently?
   set isbefore [expr {[info exists before] && [getState clock_seconds] <\
      $before}]
   set isafter [expr {[info exists after] && [getState clock_seconds] >=\
      $after}]


   set user_or_group_target_defined [expr {[info exists userlist] || [info\
      exists grouplist]}]
   set user_or_group_targeted [expr {$user || $group}]
   set user_or_group_excluded [expr {$notuser || $notgroup}]
   set time_frame_defined [expr {[info exists before] || [info exists after]}]
   set in_time_frame [expr {!$time_frame_defined || $isbefore || $isafter}]
   set in_near_time_frame [expr {[info exists after] && !$isafter &&\
      [getState clock_seconds] >= ($after - $nearsec)}]

   set apply [expr {$in_time_frame && ($user_or_group_targeted ||\
      (!$user_or_group_target_defined && !$user_or_group_excluded))}]

   # is end limit near ?
   set isnearly [expr {!$apply && ($user_or_group_targeted ||\
      (!$user_or_group_target_defined && !$user_or_group_excluded)) &&\
      $in_near_time_frame}]
   if {![info exists afterraw]} {
      set afterraw {}
   }

   return [list $apply $isnearly $afterraw $otherargs]
}

proc setModspecTag {modspec tag {props {}}} {
   reportDebug "Set tag '$tag' with properties '$props' on module\
      specification '$modspec'"

   if {[isModuleFullPath $modspec]} {
      # use dedicated structure for full path module specifications
      if {![info exists ::g_moduleTagFullPath($modspec)] || $tag ni\
         $::g_moduleTagFullPath($modspec)} {
            lappend ::g_moduleTagFullPath($modspec) $tag
      } else {
         set idx [lsearch -exact $::g_moduleTagFullPath($modspec) $tag]
      }
      # record props associated to tag
      if {[info exists idx]} {
         lset ::g_moduleTagFullPathSpec($modspec) $idx $props
      } else {
         lappend ::g_moduleTagFullPathSpec($modspec) $props
      }
   } else {
      # record tag list for mod root to optimize search
      set modroot [getModuleRootFromVersSpec $modspec]
      if {![info exists ::g_moduleTagRoot($modroot)]} {
         lappend ::g_moduleTagRoot($modroot) $tag
         set idx 0
         set new 1
      } else {
         set idx [lsearch -exact $::g_moduleTagRoot($modroot) $tag]
         if {$idx == -1} {
            set idx [llength $::g_moduleTagRoot($modroot)]
            lappend ::g_moduleTagRoot($modroot) $tag
            set new 1
         }
      }

      # then record mod spec and props at idx defined for tag. new spec are
      # appended and firstly matching spec is returned with its props on
      # search
      if {[info exists new]} {
         lappend ::g_moduleTagRootSpec($modroot) [list $modspec $props]
      } else {
         set tagrootlist [lindex $::g_moduleTagRootSpec($modroot) $idx]
         lappend tagrootlist $modspec $props
         lset ::g_moduleTagRootSpec($modroot) $idx $tagrootlist
      }
   }
}

proc module-forbid {args} {
   # parse application criteria arguments to determine if command apply
   lassign [parseApplicationCriteriaArgs 1 [expr {[getConf\
      nearly_forbidden_days] * 86400}] {*}$args] apply isnearly after\
      otherargs

   # parse remaining argument list, do it even if command does not apply to
   # raise any command specification error
   foreach arg $otherargs {
      if {[info exists nextargisval]} {
         ##nagelfar vartype nextargisval varName
         set $nextargisval $arg
         unset nextargisval
      } else {
         switch -glob -- $arg {
            --nearly-message {
               set nextargisval nearlymessage
            }
            --message {
               set nextargisval message
            }
            -* {
               knerror "Invalid option '$arg'"
            }
            default {
               lappend modarglist $arg
            }
         }
         set prevarg $arg
      }
   }

   if {[info exists nextargisval]} {
      knerror "Missing value for '$prevarg' option"
   }

   if {![info exists modarglist]} {
      knerror {No module specified in argument}
   }

   # skip record if application criteria are not met
   if {$apply} {
      set proplist {}
      if {[info exists message]} {
         ##nagelfar ignore Found constant
         lappend proplist message $message
      }

      # record each forbid spec after parsing them
      foreach modarg [parseModuleSpecification 0 0 0 0 {*}$modarglist] {
         setModspecTag $modarg forbidden $proplist
      }
   } elseif {$isnearly} {
      ##nagelfar ignore Found constant
      lappend proplist after $after
      if {[info exists nearlymessage]} {
         ##nagelfar ignore Found constant
         lappend proplist message $nearlymessage
      }
      # record each nearly forbid spec after parsing them
      foreach modarg [parseModuleSpecification 0 0 0 0 {*}$modarglist] {
         setModspecTag $modarg nearly-forbidden $proplist
      }
   }
}

proc module-hide {args} {
   set hidinglvl 1
   set hiddenloaded 0

   # parse application criteria arguments to determine if command apply
   lassign [parseApplicationCriteriaArgs 1 0 {*}$args] apply isnearly after\
      otherargs

   # parse remaining argument list, do it even if command does not apply to
   # raise any command specification error
   foreach arg $otherargs {
      switch -glob -- $arg {
         --hard {
            # hardened stealth
            set hidinglvl 2
         }
         --soft {
            # soften level of camouflage
            set hidinglvl 0
         }
         --hidden-loaded {
            # module should stay hidden once being loaded
            set hiddenloaded 1
         }
         -* {
            knerror "Invalid option '$arg'"
         }
         default {
            lappend modarglist $arg
         }
      }
   }

   if {![info exists modarglist]} {
      knerror {No module specified in argument}
   }

   # skip hide spec record if application criteria are not met
   if {$apply} {
      # record each hide spec after parsing them
      foreach modarg [parseModuleSpecification 0 0 0 0 {*}$modarglist] {
         setModspecHidingLevel $modarg $hidinglvl
         if {$hiddenloaded} {
            setModspecTag $modarg hidden-loaded
         }
      }
   }
}

proc hide-modulefile {modfile} {
   module-hide $modfile
}

proc module-tag {args} {
   # parse application criteria arguments to determine if command apply
   lassign [parseApplicationCriteriaArgs 0 0 {*}$args] apply isnearly after\
      otherargs

   # parse remaining argument list, do it even if command does not apply to
   # raise any command specification error
   foreach arg $otherargs {
      switch -glob -- $arg {
         -* {
            knerror "Invalid option '$arg'"
         }
         default {
            if {![info exists tag]} {
               set tag $arg
            } else {
               lappend modarglist $arg
            }
         }
      }
   }

   if {![info exists tag]} {
      knerror {No tag specified in argument}
   }
   if {![info exists modarglist]} {
      knerror {No module specified in argument}
   }
   if {$tag in [list loaded auto-loaded forbidden nearly-forbidden hidden\
      hidden-loaded warning]} {
      knerror "'$tag' is a reserved tag name and cannot be set"
   }

   # skip tag record if application criteria are not met
   if {$apply} {
      # record each hide spec after parsing them
      foreach modarg [parseModuleSpecification 0 0 0 0 {*}$modarglist] {
         setModspecTag $modarg $tag
      }
   }
}

# parse arguments sent to the unsetenv modulefile command
proc parseSetenvCommandArgs {mode dflbhv args} {
   set bhv $dflbhv
   foreach arg $args {
      switch -- $arg {
         --set-if-undef {
            if {$mode eq {load}} {
               set setifundef 1
            }
         }
         default {
            if {![info exists var]} {
               set var $arg
            } elseif {![info exists val]} {
               set val $arg
            } else {
               # too much argument
               set wrongargnum 1
            }
         }
      }
   }

   if {[info exists wrongargnum] || ![info exists var] || ![info exists\
      val]} {
      knerror {wrong # args: should be "setenv ?--set-if-undef? var val"}
   }

   if {[info exists setifundef] && [isEnvVarDefined $var]} {
      set bhv noop
   }

   reportDebug "bhv=$bhv, var=$var, val=$val"
   return [list $bhv $var $val]
}

proc setenv {args} {
   lassign [parseSetenvCommandArgs load set {*}$args] bhv var val

   if {$bhv eq {set}} {
      # clean any previously defined reference counter array
      unset-env [getModshareVarName $var] 1

      # clean any previously defined pushenv stack
      unset-env [getPushenvVarName $var] 1

      # Set the variable for later use during the modulefile evaluation
      set-env $var $val
   }

   return {}
}

# undo setenv in unload mode
proc setenv-un {args} {
   lassign [parseSetenvCommandArgs unload unset {*}$args] bhv var val

   # clean any existing reference counter array
   unset-env [getModshareVarName $var] 1

   # clean any previously defined pushenv stack
   unset-env [getPushenvVarName $var] 1

   # Add variable to the list of variable to unset in shell output code but
   # set it in interp context as done on load mode for later use during the
   # modulefile evaluation
   unset-env $var 0 $val

   return {}
}

# optimized setenv for whatis mode: init env variable with an empty
# value if undefined. do not care about value, just avoid variable to be
# undefined for later use during the modulefile evaluation
proc setenv-wh {args} {
   lassign [parseSetenvCommandArgs load set {*}$args] bhv var val

   setEnvVarIfUndefined $var {}
   return {}
}

# parse arguments sent to the getenv modulefile command
proc parseGetenvCommandArgs {cmd args} {
   set returnval 0
   set valifundef {}
   switch -- [llength $args] {
      1 {
         set var [lindex $args 0]
      }
      2 {
         switch -- [lindex $args 0] {
            --return-value {
               set returnval 1
               set var [lindex $args 1]
            }
            default {
               set var [lindex $args 0]
               set valifundef [lindex $args 1]
            }
         }
      }
      3 {
         if {[lindex $args 0] ne {--return-value}} {
            set wrongargs 1
         } else {
            set returnval 1
            set var [lindex $args 1]
            set valifundef [lindex $args 2]
         }
      }
      default {
         set wrongargs 1
      }
   }

   set argname [expr {$cmd eq {getenv} ? {variable} : {name}}]
   if {[info exists wrongargs]} {
      knerror "wrong # args: should be \"$cmd ?--return-value? $argname\
         ?valifundef?\""
   }

   reportDebug "$argname='$var', valifundef='$valifundef',\
      returnval='$returnval'"
   return [list $var $valifundef $returnval]
}

proc getenv {args} {
   # parse args
   lassign [parseGetenvCommandArgs getenv {*}$args] var valifundef returnval

   if {[currentState mode] ne {display} || $returnval} {
      return [get-env $var $valifundef]
   } else {
      return "\$$var"
   }
}

# parse arguments sent to the unsetenv modulefile command
proc parseUnsetenvCommandArgs {mode dflbhv args} {
   foreach arg $args {
      switch -- $arg {
         --unset-on-unload {
            if {$mode eq {unload}} {
               set bhv unset
            }
         }
         --noop-on-unload {
            if {$mode eq {unload}} {
               set bhv noop
            }
         }
         default {
            if {![info exists var]} {
               set var $arg
            } elseif {![info exists val]} {
               set val $arg
               if {$mode eq {unload} && ![info exists bhv]} {
                  set bhv set
               }
            } else {
               # too much argument
               set wrongargnum 1
            }
         }
      }
   }

   if {[info exists wrongargnum] || ![info exists var]} {
      knerror {wrong # args: should be "unsetenv ?--noop-on-unload?\
         ?--unset-on-unload? var ?val?"}
   }

   if {![info exists bhv]} {
      set bhv $dflbhv
   }

   # initialize val to always return same structure, val is only used if bhv
   # equals 'set'
   if {![info exists val]} {
      set val {}
   }

   reportDebug "bhv=$bhv, var=$var, val=$val"
   return [list $bhv $var $val]
}

proc unsetenv {args} {
   lassign [parseUnsetenvCommandArgs load unset {*}$args] bhv var val

   # clean any existing reference counter array
   unset-env [getModshareVarName $var] 1

   # clean any previously defined pushenv stack
   unset-env [getPushenvVarName $var] 1

   # Set the variable for later use during the modulefile evaluation
   unset-env $var

   return {}
}

# undo unsetenv in unload mode
proc unsetenv-un {args} {
   lassign [parseUnsetenvCommandArgs unload noop {*}$args] bhv var val

   switch -- $bhv {
      set {
         # apply value specified for set on unload
         return [setenv $var $val]
      }
      unset {
         return [unsetenv $var]
      }
      noop {
         # otherwise just clear variable if it does not exist on unload mode
         # for later use during the modulefile evaluation
         if {![isEnvVarDefined $var]} {
            reset-to-unset-env $var
         }
      }
   }
   return {}
}

# optimized unsetenv for whatis mode: init env variable with an empty
# value if undefined. do not care about value, just avoid variable to be
# undefined for later use during the modulefile evaluation
proc unsetenv-wh {args} {
   lassign [parseUnsetenvCommandArgs load noop {*}$args] bhv var val

   setEnvVarIfUndefined $var {}
   return {}
}

proc chdir {dir} {
   if {[file exists $dir] && [file isdirectory $dir]} {
      set ::g_changeDir $dir
   } else {
      # report issue but does not treat it as an error to have the
      # same behavior as C-version
      reportWarning "Cannot chdir to '$dir' for '[currentState modulename]'"
   }

   return {}
}

# supersede exit command to handle it if called within a modulefile
# rather than exiting the whole process
proc exitModfileCmd {{code 0}} {
   if {[currentState mode] in {load refresh}} {
      setState inhibit_interp 1
   }

   # break to gently end interpretation of current modulefile
   return -code break
}

# enables sub interp to return ModulesVersion value to the main interp
proc setModulesVersion {val} {
   set ::ModulesVersion $val
}

# supersede puts command to catch content sent to stdout/stderr within
# modulefile in order to correctly send stderr content (if a pager has been
# enabled) or postpone content channel send after rendering on stdout the
# relative environment changes required by the modulefile
proc putsModfileCmd {itrp args} {
   # determine if puts call targets the stdout or stderr channel
   switch -- [llength $args] {
      1 {
         # create struct with newline status and message to output
         set deferPuts [list 1 [lindex $args 0]]
      }
      2 {
         switch -- [lindex $args 0] {
            -nonewline {
               set deferPuts [list 0 [lindex $args 1]]
            }
            stdout {
               set deferPuts [list 1 [lindex $args 1]]
            }
            prestdout {
               set deferPrePuts [list 1 [lindex $args 1]]
            }
            stderr {
               set reportArgs [list [lindex $args 1]]
            }
            log {
               set logPuts [lindex $args 1]
            }
         }
      }
      3 {
         if {[lindex $args 0] eq {-nonewline}} {
            switch -- [lindex $args 1] {
               stdout {
                  set deferPuts [list 0 [lindex $args 2]]
               }
               prestdout {
                  set deferPrePuts [list 0 [lindex $args 2]]
               }
               stderr {
                  set reportArgs [list [lindex $args 2] 1]
               }
               log {
                  set logPuts [lindex $args 2]
               }
            }
         } else {
            set wrongNumArgs 1
         }
      }
      default {
         set wrongNumArgs 1
      }
   }

   # raise error if bad argument number detected, do this here rather in _puts
   # not to confuse people with an error reported by an internal name (_puts)
   if {[info exists wrongNumArgs]} {
      knerror {wrong # args: should be "puts ?-nonewline? ?channelId? string"}
   # send content to log system
   } elseif {[info exists logPuts]} {
      log $logPuts
   # defer puts if it targets stdout (see renderSettings)
   } elseif {[info exists deferPuts]} {
      # current module is qualified for refresh evaluation
      lappendState -nodup refresh_qualified [currentState modulename]
      lappend ::g_stdoutPuts {*}$deferPuts
   } elseif {[info exists deferPrePuts]} {
      lappendState -nodup refresh_qualified [currentState modulename]
      lappend ::g_prestdoutPuts {*}$deferPrePuts
   # if it targets stderr call report, which knows what channel to use
   } elseif {[info exists reportArgs]} {
      # report message only if not silent
      if {[isVerbosityLevel concise]} {
         report {*}$reportArgs
      }
   # pass to real puts command if not related to stdout and do that in modfile
   # interpreter context to get access to eventual specific channel
   } else {
      # re-throw error as a known error for accurate stack trace print
      if {[catch {$itrp eval _puts $args} errMsg]} {
         knerror $errMsg MODULES_ERR_CUSTOM
      }
   }
}

proc prepend-path {args} {
   # Set the variable for later use during the modulefile evaluation
   add-path prepend-path load prepend {*}$args

   return {}
}

proc prepend-path-un {args} {
   # Set the variable for later use during the modulefile evaluation
   unload-path prepend-path unload remove {*}$args

   return {}
}

proc append-path {args} {
   # Set the variable for later use during the modulefile evaluation
   add-path append-path load append {*}$args

   return {}
}

proc append-path-un {args} {
   # Set the variable for later use during the modulefile evaluation
   unload-path append-path unload remove {*}$args

   return {}
}

proc remove-path {args} {
   # Set the variable for later use during the modulefile evaluation
   unload-path remove-path load remove {*}$args

   return {}
}

# undo remove-path in unload mode
proc remove-path-un {args} {
   lassign [unload-path remove-path unload noop {*}$args] bhv var

   # clean any previously defined pushenv stack
   unset-env [getPushenvVarName $var] 1

   # clear variable if it does not exist on unload mode for later use
   # during the modulefile evaluation
   if {![isEnvVarDefined $var]} {
      reset-to-unset-env $var
   }
}

# optimized *-path for whatis mode: init env variable with an empty value if
# undefined. do not care about value, just avoid variable to be undefined for
# later use during the modulefile evaluation
proc edit-path-wh {cmd args} {
   # get variable name
   lassign [parsePathCommandArgs $cmd load noop {*}$args] separator allow_dup\
      idx_val ign_refcount val_set_is_delim glob_match bhv var path_list

   setEnvVarIfUndefined $var {}

   return {}
}

proc set-alias {alias what} {
   set ::g_Aliases($alias) $what
   set ::g_stateAliases($alias) new

   # current module is qualified for refresh evaluation
   lappendState -nodup refresh_qualified [currentState modulename]

   return {}
}

# undo set-alias in unload mode
proc set-alias-un {alias what} {
   return [unset-alias $alias]
}

proc unset-alias {alias} {
   set ::g_Aliases($alias) {}
   set ::g_stateAliases($alias) del

   return {}
}

proc set-function {function what} {
   set ::g_Functions($function) $what
   set ::g_stateFunctions($function) new

   # current module is qualified for refresh evaluation
   lappendState -nodup refresh_qualified [currentState modulename]

   return {}
}

# undo set-function in unload mode
proc set-function-un {function what} {
   return [unset-function $function]
}

proc unset-function {function} {
   set ::g_Functions($function) {}
   set ::g_stateFunctions($function) del

   return {}
}


proc is-loaded {args} {
   # parse module version specification
   set args [parseModuleSpecification 0 0 0 0 {*}$args]

   foreach mod $args {
      if {[getLoadedMatchingName $mod returnfirst] ne {}} {
         return 1
      }
   }
   # is something loaded whatever it is?
   return [expr {![llength $args] && [llength\
      [getEnvLoadedModulePropertyParsedList name]]}]
}

proc is-loading {args} {
   foreach mod $args {
      if {[getLoadedMatchingName $mod returnfirst 1] ne {}} {
         return 1
      }
   }
   # is something else loading whatever it is?
   return [expr {![llength $args] && [llength [getLoadingModuleList]] > 1}]
}

proc conflict {args} {
   set currentModule [currentState modulename]
   set curmodnamevr [currentState modulenamevr]
   # get module short name if loaded by its full pathname
   if {[set isfullpath [isModuleFullPath $currentModule]]} {
      set currentSModule [findModuleNameFromModulefile $currentModule]
   }

   set conflict_unload [expr {[getConf conflict_unload] && [getConf\
      auto_handling]}]

   # parse module version specification
   set args [parseModuleSpecification 0 0 0 0 {*}$args]

   registerCurrentModuleConflict {*}$args

   foreach mod $args {
      set is_conflict_loading 0
      set unload_attempt 0
      set loaded_conflict_mod_list [getLoadedMatchingName $mod returnall]

      if {![llength $loaded_conflict_mod_list]} {
         set eq_current_mod [expr {[modEq $mod $currentModule eqstart 1 2 1]\
            || ($isfullpath && [modEq $mod $currentSModule eqstart 1 2 1])}]
         # currently evaluating module should not be mistaken for loading
         # conflicting module
         if {!$eq_current_mod} {
            set loaded_conflict_mod_list [getLoadedMatchingName $mod\
               returnall 1]
            if {[llength $loaded_conflict_mod_list]} {
               # no conflict unload attempt on loading module
               set is_conflict_loading 1
            }
         }
      } elseif {$conflict_unload} {
         set still_loaded_conflict_mod_list {}
         # unload attempt in reverse load order
         foreach loaded_conflict_mod [lreverse $loaded_conflict_mod_list] {
            if {[cmdModuleUnload conun match 1 s 0 $loaded_conflict_mod]} {
               lappend still_loaded_conflict_mod_list $loaded_conflict_mod
            }
         }
         set loaded_conflict_mod_list $still_loaded_conflict_mod_list
         set unload_attempt 1
      }

      if {[llength $loaded_conflict_mod_list]} {
         setConflictErrorAsReported {*}$loaded_conflict_mod_list

         # error msg has already been sent if a conflict unload was attempted
         set msg [expr {$unload_attempt ? {} : [getPresentConflictErrorMsg\
            $curmodnamevr $loaded_conflict_mod_list $is_conflict_loading]}]
         knerrorOrWarningIfForced $msg MODULES_ERR_GLOBAL
      }
   }

   return {}
}

proc registerCurrentModuleConflict {args} {
   # register conflict list unless record inhibited for current iterp context
   if {[currentState inhibit_req_record] != [currentState evalid]} {
      setLoadedConflict [currentState modulename] {*}$args
   }
}

proc parsePrereqCommandArgs {cmd args} {
   set tag_list {}
   set modulepath_list {}
   set optional 0
   set opt_list {}
   set prereq_list {}

   # parse options defined
   set i 0
   foreach arg $args {
      if {[info exists nextargistaglist]} {
         set tag_list [split $arg :]
         lappend opt_list $arg
         unset nextargistaglist
      } elseif {[info exists nextargismodulepathlist]} {
         set modulepath_list {}
         # record list of absolute paths
         foreach modulepath [split $arg :] {
            lappend modulepath_list [getAbsolutePath $modulepath]
         }
         lappend opt_list $arg
         unset nextargismodulepathlist
      } else {
         switch -glob -- $arg {
            --optional {
               set optional 1
               lappend opt_list $arg
            }
            --tag=* {
               set tag_list [split [string range $arg 6 end] :]
               lappend opt_list $arg
               if {![llength $tag_list]} {
                  knerror "Missing value for '--tag' option"
               }
            }
            --tag {
               set nextargistaglist 1
               lappend opt_list $arg
            }
            --modulepath {
               set nextargismodulepathlist 1
               lappend opt_list $arg
            }
            -* {
               knerror "Invalid option '$arg'"
            }
            default {
               set prereq_list [lrange $args $i end]
               # end option parsing: remaining elts are list of prereqs
               break
            }
         }
      }
      incr i
   }

   foreach tag $tag_list {
      if {$tag in [list loaded auto-loaded forbidden nearly-forbidden\
         hidden warning]} {
         knerror "Tag '$tag' cannot be manually set"
      }
   }
   if {![llength $prereq_list]} {
      knerror "wrong # args: should be \"$cmd ?--optional? ?--tag? ?taglist?\
         ?--modulepath? ?modulepathlist? modulefile ?...?\""
   } elseif {[set mispopt [lsearch -inline -glob $prereq_list --*]] ne {}} {
      knerror "Misplaced option '$mispopt'"
   }

   # parse module version specification
   set prereq_list [parseModuleSpecification 0 0 0 0 {*}$prereq_list]

   return [list $tag_list $modulepath_list $optional $opt_list $prereq_list]
}

proc prereqAnyModfileCmd {tryload auto args} {
   lassign [parsePrereqCommandArgs prereq {*}$args] tag_list modulepath_list\
      optional opt_list args

   set currentModule [currentState modulename]
   set curmodnamevr [currentState modulenamevr]

   # register prereq list (sets of optional prereq are registered as list)
   # unless record inhibited for current iterp context
   if {[currentState inhibit_req_record] != [currentState evalid]} {
      # if requirement is optional, add current module to the recorded prereq
      # list to make the requirement rule satisfied even if none loaded, as
      # current module will be loaded
      if {$optional} {
         lappend record_list $currentModule
      }
      lappend record_list {*}$args
      setLoadedPrereq $currentModule $record_list

      if {[llength $modulepath_list]} {
         setLoadedPrereqPath $currentModule $record_list $modulepath_list
      }
   }

   if {$auto} {
      # convert modulepath list to keep entries not matching any enabled
      # modulepaths and transform entries into all matching enabled modulepath
      set converted_list {}
      foreach modulepath $modulepath_list {
         set matching_list [getMatchingModulepathList $modulepath]
         if {[llength $matching_list]} {
            lappendNoDup converted_list {*}$matching_list
         } else {
            lappendNoDup converted_list $modulepath
         }
      }
      set modulepath_list $converted_list

      # try to load prereq as dependency resolving is enabled
      lassign [loadRequirementModuleList $tryload $optional $tag_list\
         $modulepath_list {*}$args] retlo prereqloaded
   } else {
      set loadedmod_list {}
      foreach mod $args {
         # get all loaded or loading mod in args list
         if {[set loadedmod [getLoadedMatchingName $mod returnfirst 0 {}\
            $modulepath_list]] ne {} || [set loadedmod [getLoadedMatchingName\
            $mod returnfirst 1 {} $modulepath_list]] ne {}} {
            lappend loadedmod_list $loadedmod
         }
      }
      set prereqloaded [llength $loadedmod_list]
   }

   if {!$prereqloaded} {
      if {!$optional} {
         # error if requirement is not satisfied unless if optional
         reportMissingPrereqError $curmodnamevr $modulepath_list {*}$args
      }
   } elseif {!$auto} {
      # apply missing tag to all loaded module found (already done when
      # dependency resolving is enabled)
      cmdModuleTag 0 0 $tag_list {*}$loadedmod_list
   }

   return {}
}

proc x-resource {resource {value {}}} {
   # sometimes x-resource value may be provided within resource name
   # as the "x-resource {Ileaf.popup.saveUnder: True}" example provided
   # in manpage. so here is an attempt to extract real resource name and
   # value from resource argument
   if {![string length $value] && ![file exists $resource]} {
      # look first for a space character as delimiter, then for a colon
      set sepapos [string first { } $resource]
      if { $sepapos == -1 } {
         set sepapos [string first : $resource]
      }

      if { $sepapos > -1 } {
         set value [string range $resource $sepapos+1 end]
         set resource [string range $resource 0 $sepapos-1]
         reportDebug "corrected ($resource, $value)"
      } else {
         # if not a file and no value provided x-resource cannot be
         # recorded as it will produce an error when passed to xrdb
         reportWarning "x-resource $resource is not a valid string or file"
         return {}
      }
   }

   # check current environment can handle X11 resource edition elsewhere exit
   if {[catch {runCommand xrdb -query} errMsg]} {
      knerror "X11 resources cannot be edited, issue spotted\n[sgr er\
         ERROR]: $errMsg" MODULES_ERR_GLOBAL
   }

   # if a resource does hold an empty value in g_newXResources or
   # g_delXResources arrays, it means this is a resource file to parse
   if {[currentState mode] eq {load}} {
      set ::g_newXResources($resource) $value
   } else {
      set ::g_delXResources($resource) $value
   }

   return {}
}

proc uname {what} {
   return [switch -- $what {
      sysname {getState os}
      machine {getState machine}
      nodename - node {getState nodename}
      release {getState osversion}
      domain {getState domainname}
      version {getState kernelversion}
      default {knerror "uname $what not supported"}
   }]
}

# run shell command
proc system {args} {
   # run through the appropriate shell
   if {[getState is_win]} {
      set shell cmd.exe
      set shellarg /c
   } else {
      set shell /bin/sh
      set shellarg -c
   }

   if {[catch {exec >&@stderr $shell $shellarg [join $args]}]} {
      # non-zero exit status, get it:
      return [lindex $::errorCode 2]
   } else {
      # exit status was 0
      return 0
   }
}

# test at least one of the collections passed as argument exists
proc is-saved {args} {
   foreach coll $args {
      lassign [findCollections $coll exact] collfile colldesc
      if {[string length $collfile]} {
         return 1
      }
   }
   # is something saved whatever it is?
   return [expr {![llength $args] && [llength [findCollections]]}]
}

# test at least one of the directories passed as argument is set in MODULEPATH
proc is-used {args} {
   set modpathlist [getModulePathList]
   foreach path $args {
      # transform given path in an absolute path to compare with dirs
      # registered in the MODULEPATH env var which are returned absolute.
      set abspath [getAbsolutePath $path]
      if {$abspath in $modpathlist} {
         return 1
      }
   }
   # is something used whatever it is?
   return [expr {![llength $args] && [llength $modpathlist]}]
}

# test at least one of the modulefiles passed as argument exists
proc is-avail {args} {
   # parse module version specification
   # a module name is mandatory
   set args [parseModuleSpecification 0 0 0 0 {*}$args]
   set ret 0

   # disable error reporting to avoid modulefile errors
   # to pollute result. Only if not already inhibited
   set alreadyinhibit [getState inhibit_errreport]
   if {!$alreadyinhibit} {
      inhibitErrorReport
   }

   foreach mod $args {
      lassign [getPathToModule $mod] modfile modname modnamevr
      if {$modfile ne {}} {
         set ret 1
         break
      }
   }

   # re-enable only is it was disabled from this procedure
   if {!$alreadyinhibit} {
      setState inhibit_errreport 0
   }
   return $ret
}

proc execShAndGetEnv {elt_ignored_list shell script args} {
   set sep {%ModulesShToMod%}
   set subsep {%ModulesSubShToMod%}
   set shdesc [list $script {*}$args]
   set sherr 0
   set shellopts [list]

   upvar ignvarlist ignvarlist
   set ignvarlist [list OLDPWD PWD _ _AST_FEATURES PS1 _LMFILES_\
      LOADEDMODULES]

   # define shell command to run to source script and analyze the environment
   # changes it performs
   switch -- [file tail $shell] {
      dash - sh {
         # declare is not supported by dash but functions cannot be retrieved
         # anyway, so keep using declare and throw errors out to avoid overall
         # execution error. dash does not pass arguments to sourced script but
         # it does not raise error if arguments are set
         ##nagelfar ignore +3 Found constant
         set command "export -p; echo $sep; declare -f 2>/dev/null; echo\
            $sep; alias; echo $sep; echo $sep; pwd; echo $sep; . [listTo\
            shell $shdesc] 2>&1; echo $sep; export -p; echo $sep; declare -f\
            2>/dev/null; echo $sep; alias; echo $sep; echo $sep; pwd"
         set varre {export (\S+?)=["']?(.*?)["']?$}
         set funcre {(\S+?) \(\)\s?\n?{\s?\n(.+?)\n}$}
         set aliasre {([^='\s]+?)='?(.*?)'$}
         set varvalmap [list {\"} \" \\\\ \\]
         set alvalmap [list {'\''} ' {'"'"'} ']
      }
      bash {
         ##nagelfar ignore +2 Found constant
         set command "export -p; echo $sep; declare -f; echo $sep; alias;\
            echo $sep; complete; echo $sep; pwd; echo $sep; . [listTo shell\
            $shdesc] 2>&1; echo $sep; export -p; echo $sep; declare -f; echo\
            $sep; alias; echo $sep; complete; echo $sep; pwd"
         set varre {declare -x (\S+?)="(.*?)"$}
         set funcre {(\S+?) \(\)\s?\n{\s?\n(.+?)\n}$}
         set aliasre {alias (\S+?)='(.*?)'$}
         set compre {complete (.+?) (\S+?)$}
         set comprevar [list match value name]
         set varvalmap [list {\"} \" \\\\ \\]
         set alvalmap [list {'\''} ']
         lappend shellopts --noprofile --norc
      }
      bash-eval {
         ##nagelfar ignore +3 Found constant
         set command "export -p; echo $sep; declare -f; echo $sep; alias;\
            echo $sep; complete; echo $sep; pwd; echo $sep; eval \"\$([listTo\
            shell $shdesc] 2>/dev/null)\"; echo $sep; export -p; echo $sep;\
            declare -f; echo $sep; alias; echo $sep; complete; echo $sep; pwd"
         set varre {declare -x (\S+?)="(.*?)"$}
         set funcre {(\S+?) \(\)\s?\n{\s?\n(.+?)\n}$}
         set aliasre {alias (\S+?)='(.*?)'$}
         set compre {complete (.+?) (\S+?)$}
         set comprevar [list match value name]
         set varvalmap [list {\"} \" \\\\ \\]
         set alvalmap [list {'\''} ']
         lappend shellopts --noprofile --norc
      }
      ksh - ksh93 {
         ##nagelfar ignore +3 Found constant
         set command "typeset -x; echo $sep; typeset +f | while read f; do\
            typeset -f \${f%\\(\\)}; echo; done; echo $sep; alias; echo $sep;\
            echo $sep; pwd; echo $sep; . [listTo shell $shdesc] 2>&1; echo\
            $sep; typeset -x; echo $sep; typeset +f | while read f; do\
            typeset -f \${f%\\(\\)}; echo; done; echo $sep; alias; echo $sep;\
            echo $sep; pwd"
         set varre {(\S+?)=\$?'?(.*?)'?$}
         set funcre {(\S+?)\(\) {\n?(.+?)}[;\n]?$}
         set aliasre {(\S+?)=\$?'?(.*?)'?$}
         set varvalmap [list {\'} ']
         set alvalmap [list {\"} \" {\\'} ' {\'} ' {\\\\} {\\}]
      }
      zsh {
         ##nagelfar ignore +2 Found constant
         set command "typeset -x; echo $sep; declare -f; echo $sep; alias;\
            echo $sep; echo $sep; pwd; echo $sep; . [listTo shell $shdesc]\
            2>&1; echo $sep; typeset -x; echo $sep; declare -f; echo $sep;\
            alias; echo $sep; echo $sep; pwd"
         set varre {(\S+?)=\$?'?(.*?)'?$}
         set funcre {(\S+?) \(\) {\n(.+?)\n}$}
         set aliasre {(\S+?)=\$?'?(.*?)'?$}
         set varvalmap [list {'\''} ']
         set alvalmap [list {'\''} ']
      }
      csh {
         ##nagelfar ignore +2 Found constant
         set command "setenv; echo $sep; echo $sep; alias; echo $sep; echo\
            $sep; pwd; echo $sep; source [listTo shell $shdesc] >&\
            /dev/stdout; echo $sep; setenv; echo $sep; echo $sep; alias; echo\
            $sep; echo $sep; pwd"
         set varre {(\S+?)=(.*?)$}
         set aliasre {(\S+?)\t(.*?)$}
         set varvalmap [list]
         set alvalmap [list]
         lappend shellopts -f
      }
      tcsh {
         ##nagelfar ignore +2 Found constant
         set command "setenv; echo $sep; echo $sep; alias; echo $sep;\
            complete; echo $sep; pwd; echo $sep; source [listTo shell\
            $shdesc] >& /dev/stdout; echo $sep; setenv; echo $sep; echo $sep;\
            alias; echo $sep; complete; echo $sep; pwd"
         set varre {(\S+?)=(.*?)$}
         set aliasre {(\S+?)\t\(?(.*?)\)?$}
         set compre {(\S+?)\t(.*?)$}
         set comprevar [list match name value]
         set varvalmap [list]
         set alvalmap [list]
         lappend shellopts -f
      }
      fish {
         # exclude from search builtins, fish-specific functions and private
         # functions defined prior script evaluation: reduce this way the
         # the number of functions to parse.
         set getfunc "set funcout (string match -r -v \$funcfilter (functions\
            -a -n) | while read f; functions \$f; echo '$subsep'; end)"
         ##nagelfar ignore +9 Found constant
         set command "set -xgL; echo '$sep'; status test-feature\
            regex-easyesc 2>/dev/null; and set escrepl '\\\\\\\\\$1'; or set\
            escrepl '\\\\\\\\\\\\\\\$1'; set funcfilter \\^\\((string\
            join '|' (string replace -r '(\\\[|\\.)' \$escrepl\
            (builtin -n; functions -a -n | string split ', ' | string match\
            -e -r '^_')))\\|fish\\.\\*\\)\\\$; $getfunc; $getfunc; string\
            split \$funcout; echo '$sep'; string split \$funcout; echo\
            '$sep'; complete; echo '$sep'; pwd; echo '$sep'; source [listTo\
            shell $shdesc] 2>&1; or exit \$status; echo '$sep'; set -xgL;\
            echo '$sep'; $getfunc; string split \$funcout; echo '$sep';\
            string split \$funcout; echo '$sep'; complete; echo '$sep'; pwd"
         set varre {^(\S+?\M) ?['"]?(.*?)['"]?$}
         # exclude alias from function list
         set funcre "^function (\\S+?)(?: \[^\\n\]*?--description\
            (?!'?alias)\[^\\n\]+)?\\n(.+?)?\\s*\\nend\\n$subsep\$"
         # fetch aliases from available functions
         set aliasre "^function (\\S+?) \[^\\n\]*?--description\
            '?alias\[^\\n\]+\\n\\s*(.+?)(?: \\\$argv)?\\s*\\nend\\n$subsep\$"
         set compre {complete ((?:-\S+? )*?)(?:(?:-c|--command)\
            )?([^-]\S+)(.*?)$}
         set comprevar [list match valpart1 name valpart2]
         # translate back fish-specific code
         set varvalmap [list {'  '} : {' '} : {\'} ' {\"} \" \\\\ \\]
         set alvalmap [list { $argv;} {}]

         # fish builtins change LS_COLORS variable
         lappend ignvarlist LS_COLORS
      }
      default {
         knerror "Shell '$shell' not supported"
      }
   }

   if {![file exists $script]} {
      knerror "Script '$script' cannot be found"
   }

   set real_shell [expr {$shell eq {bash-eval} ? {bash} : $shell}]
   set shellpath [getCommandPath $real_shell]
   if {$shellpath eq {}} {
      knerror "Shell '$shell' cannot be found"
   }
   set shellexec [list $shellpath {*}$shellopts -c $command]

   reportDebug "running '$shellexec'"
   if {[catch {set output [exec {*}$shellexec]} output]} {
      set sherr 1
   }

   # link result variables to calling context
   upvar cwdbefout cwdbefout cwdaftout cwdaftout

   # extract each output sections
   set idx 0
   foreach varout {varbefout funcbefout aliasbefout compbefout cwdbefout\
      scriptout varaftout funcaftout aliasaftout compaftout cwdaftout} {
      ##nagelfar vartype varout varName
      if {[set sepidx [string first $sep $output $idx]] == -1} {
         set $varout [string trimright [string range $output $idx end] \n]
         if {$varout ne {cwdaftout} && !$sherr} {
            knerror "Unexpected output when sourcing '$shdesc' in shell\
               '$shell'"
         }
      } else {
         set $varout [string trimright [string range $output $idx $sepidx-1]\
            \n]
         set idx [expr {$sepidx + [string length $sep] + 1}]
      }
      # remove expected Tcl error message
      if {$sherr && $varout eq {scriptout} && [set erridx [string\
         last {child process exited abnormally} [set $varout]]] != -1} {
         set $varout [string range [set $varout] 0 $erridx-2]
      }
   }
   if {$sepidx != -1 && !$sherr} {
      knerror "Unexpected output when sourcing '$shdesc' in shell '$shell'"
   }

   reportDebug "script output is '$scriptout'"
   if {$sherr} {
      # throw error if script had an issue, send script output along if any
      set errmsg "Script '$script' exited abnormally"
      if {$scriptout ne {}} {
         append errmsg "\n  with following output\n$scriptout"
      }
      knerror $errmsg
   }

   # link result variables to calling context
   upvar varbef varbef varaft varaft
   upvar funcbef funcbef funcaft funcaft
   upvar aliasbef aliasbef aliasaft aliasaft
   upvar compbef compbef compaft compaft

   # clear current directory change if ignored
   if {{chdir} in $elt_ignored_list} {
      set cwdaftout $cwdbefout
   }

   # extract environment variable information
   if {{envvar} ni $elt_ignored_list} {
      ##nagelfar ignore Found constant
      foreach {out arr} [list varbefout varbef varaftout varaft] {
         ##nagelfar vartype out varName
         foreach {match name value} [regexp -all -inline -lineanchor $varre\
            [set $out]] {
            # convert shell-specific escaping
            ##nagelfar ignore Suspicious variable name
            set ${arr}($name) [string map $varvalmap $value]
         }
      }
   }
   # extract function information if function supported by shell
   if {{function} ni $elt_ignored_list && [info exists funcre]} {
      ##nagelfar ignore Found constant
      foreach {out arr} [list funcbefout funcbef funcaftout funcaft] {
         foreach {match name value} [regexp -all -inline -lineanchor $funcre\
            [set $out]] {
            # no specific escaping to convert for functions
            ##nagelfar ignore Suspicious variable name
            set ${arr}($name) $value
         }
      }
   }
   # extract alias information
   if {{alias} ni $elt_ignored_list} {
      ##nagelfar ignore Found constant
      foreach {out arr} [list aliasbefout aliasbef aliasaftout aliasaft] {
         foreach {match name value} [regexp -all -inline -lineanchor $aliasre\
            [set $out]] {
            ##nagelfar ignore Suspicious variable name
            set ${arr}($name) [string map $alvalmap $value]
         }
      }
   }
   # extract complete information if supported by shell
   if {{complete} ni $elt_ignored_list && [info exists compre]} {
      ##nagelfar ignore Found constant
      foreach {out arr} [list compbefout compbef compaftout compaft] {
         ##nagelfar ignore Non constant variable list to foreach statement
         foreach $comprevar [regexp -all -inline -lineanchor $compre [set\
            $out]] {
            if {[info exists valpart1]} {
               ##nagelfar ignore Unknown variable
               set value [concat $valpart1 $valpart2]
            }
            # no specific escaping to convert for completes
            ##nagelfar ignore Suspicious variable name
            lappend ${arr}($name) $value
         }
      }
   }
}

# execute script with args through shell and convert environment changes into
# corresponding modulefile commands
proc sh-to-mod {elt_ignored_list args} {
   set modcontent [list]
   set pathsep [getState path_separator]
   set shell [lindex $args 0]

   # evaluate script and retrieve environment before and after evaluation
   # procedure will set result variables in current context
   ##nagelfar implicitvarcmd {execShAndGetEnv *} ignvarlist cwdbefout\
      cwdaftout varbef varaft funcbef funcaft aliasbef aliasaft compbef\
      compaft
   execShAndGetEnv $elt_ignored_list {*}$args

   # check environment variable change
   lassign [getDiffBetweenArray varbef varaft] notaft diff notbef
   foreach name $notaft {
      # also ignore Modules variables intended for internal use
      if {$name ni $ignvarlist && ![string equal -length 10 $name\
         __MODULES_]} {
         lappend modcontent [list unsetenv $name]
      }
   }
   foreach name $diff {
      if {$name ni $ignvarlist && ![string equal -length 10 $name\
         __MODULES_]} {
         # new value is totally different (also consider a bare ':' as a
         # totally different value to avoid erroneous matches)
         if {$varbef($name) eq $pathsep || [set idx [string first\
            $varbef($name) $varaft($name)]] == -1} {
            lappend modcontent [list setenv $name $varaft($name)]
         } else {
            # content should be prepended
            if {$idx > 0} {
               set modcmd [list prepend-path]
               # check from the end to get the largest chunk to prepend
               set idx [string last $varbef($name) $varaft($name)]
               # get delimiter from char found between new and existing value
               set delim [string index $varaft($name) $idx-1]
               if {$delim ne $pathsep} {
                  lappend modcmd -d $delim
               }
               lappend modcmd $name
               # split value and remove duplicate entries
               set vallist [list]
               lappendNoDup vallist {*}[split [string range $varaft($name) 0\
                  $idx-2] $delim]
               # an empty element is added
               if {![llength $vallist]} {
                  lappend vallist {}
               }
               lappend modcontent [list {*}$modcmd {*}$vallist]
            }
            # content should be appended
            if {($idx + [string length $varbef($name)]) < [string length\
               $varaft($name)]} {
               set modcmd [list append-path]
               set delim [string index $varaft($name) $idx+[string length\
                  $varbef($name)]]
               if {$delim ne $pathsep} {
                  lappend modcmd -d $delim
               }
               lappend modcmd $name
               set vallist [list]
               lappendNoDup vallist {*}[split [string range $varaft($name)\
                  [expr {$idx + [string length $varbef($name)] + 1}] end]\
                  $delim]
               if {![llength $vallist]} {
                  lappend vallist {}
               }
               lappend modcontent [list {*}$modcmd {*}$vallist]
            }
         }
      }
   }
   foreach name $notbef {
      if {$name ni $ignvarlist && ![string equal -length 10 $name\
         __MODULES_]} {
         if {[string first $pathsep $varaft($name)] == -1} {
            lappend modcontent [list setenv $name $varaft($name)]
         } else {
            # define a path-like variable if path separator found in it
            # split value and remove duplicate entries
            set vallist [list]
            lappendNoDup vallist {*}[split $varaft($name) $pathsep]
            lappend modcontent [list prepend-path $name {*}$vallist]
         }
      }
   }
   # check function change
   lassign [getDiffBetweenArray funcbef funcaft] notaft diff notbef
   foreach name $notaft {
      lappend modcontent [list unset-function $name]
   }
   foreach name [list {*}$diff {*}$notbef] {
      lappend modcontent [list set-function $name \n$funcaft($name)]
   }
   # check alias change
   lassign [getDiffBetweenArray aliasbef aliasaft] notaft diff notbef
   foreach name $notaft {
      lappend modcontent [list unset-alias $name]
   }
   foreach name [list {*}$diff {*}$notbef] {
      lappend modcontent [list set-alias $name $aliasaft($name)]
   }
   # check complete change
   set real_shell [expr {$shell eq {bash-eval} ? {bash} : $shell}]
   lassign [getDiffBetweenArray compbef compaft] notaft diff notbef
   foreach name $notaft {
      lappend modcontent [list uncomplete $name]
   }
   foreach name [list {*}$diff {*}$notbef] {
      foreach body $compaft($name) {
         lappend modcontent [list complete $real_shell $name $body]
      }
   }
   # check current working directory change
   if {$cwdbefout ne $cwdaftout} {
      lappend modcontent [list chdir $cwdaftout]
   }

   # sort result to ensure consistent output whatever the evaluation shell
   set modcontent [lsort -dictionary $modcontent]

   reportDebug "resulting env changes '$modcontent'"
   return $modcontent
}

proc parseSourceShArgs {args} {
   set elt_ignored_list {}

   set i 0
   foreach arg $args {
      incr i
      if {[info exists nextargisval]} {
         ##nagelfar vartype nextargisval varName
         set $nextargisval $arg
         unset nextargisval
      } else {
         switch -glob -- $arg {
            --ignore {
               set nextargisval ignore_opt_raw
            }
            -* {
               knerror "Invalid option '$arg'"
            }
            default {
               set shell $arg
               # end option parsing: remaining elts are allowed values
               break
            }
         }
         set prevarg $arg
      }
   }

   if {[info exists nextargisval]} {
      knerror "Missing value for '$prevarg' option"
   }

   if {![info exists shell] || $i == [llength $args]} {
      knerror "wrong # args: should be \"source-sh ?--ignore? ?eltlist? shell\
         script ?arg ...?\""
   }

   set script_args [lassign [lrange $args $i end] script]

   if {[info exists ignore_opt_raw]} {
      set elt_ignored_list [split $ignore_opt_raw :]
      set allowed_elt_ignored_list {envvar function alias chdir complete}
      foreach elt_ignored $elt_ignored_list {
         if {$elt_ignored ni $allowed_elt_ignored_list} {
            knerror "Invalid ignored element '$elt_ignored'"
         }
      }
   }

   return [list $elt_ignored_list $shell $script $script_args]
}

proc source-sh {args} {
   lassign [parseSourceShArgs {*}$args] elt_ignored_list shell script\
      script_args
   # evaluate script and get the environment changes it performs translated
   # into modulefile commands
   set shtomodargs [list $shell $script {*}$script_args]
   set modcontent [sh-to-mod $elt_ignored_list {*}$shtomodargs]

   # register resulting modulefile commands
   setLoadedSourceSh [currentState modulename] [list $shtomodargs\
      {*}$modcontent]

   # get name of current module Tcl interp
   set itrp [getCurrentModfileInterpName]

   # evaluate resulting modulefile commands through current Tcl interp
   foreach modcmd $modcontent {
      interp eval $itrp $modcmd
   }
}

# undo source-sh in unload mode
proc source-sh-un {args} {
   lassign [parseSourceShArgs {*}$args] elt_ignored_list shell script\
      script_args
   set shtomodargs [list $shell $script {*}$script_args]
   # find commands resulting from source-sh evaluation recorded in env
   set modcontent [getLoadedSourceShScriptContent [currentState modulename]\
      $shtomodargs]

   # get name of current module unload Tcl interp
   set itrp [getCurrentModfileInterpName]

   # evaluate each recorded command in unload Tcl interp to get them reversed
   foreach modcmd $modcontent {
      interp eval $itrp $modcmd
   }
}

# report underlying modulefile cmds in display mode
proc source-sh-di {args} {
   lassign [parseSourceShArgs {*}$args] elt_ignored_list shell script\
      script_args
   set shtomodargs [list $shell $script {*}$script_args]

   # if module loaded, get as much content from environment as possible
   if {[is-loaded [currentState modulename]]} {
      # find commands resulting from source-sh evaluation recorded in env
      set reccontent [getLoadedSourceShScriptContent [currentState\
         modulename] $shtomodargs]

      # need to evaluate script to get alias/function/complete definition
      execShAndGetEnv $elt_ignored_list {*}$shtomodargs

      set modcontent {}
      foreach cmd $reccontent {
         # build modulefile content to show with recorded elements in env and
         # alias/function/complete definition obtained by reevaluating script
         switch -- [lindex $cmd 0] {
            complete {
               set cpname [lindex $cmd 2]
               if {[info exists compaft($cpname)]} {
                  set cpbodylist $compaft($cpname)
               } else {
                  set cpbodylist [list {}]
               }
               foreach cpbody $cpbodylist {
                  lappend modcontent [list complete $shell $cpname $cpbody]
               }
            }
            set-alias {
               set alname [lindex $cmd 1]
               if {[info exists aliasaft($alname)]} {
                  set albody $aliasaft($alname)
               } else {
                  set albody {}
               }
               lappend modcontent [list set-alias $alname $albody]
            }
            set-function {
               set fnname [lindex $cmd 1]
               if {[info exists funcaft($fnname)]} {
                  set fnbody \n$funcaft($fnname)
               } else {
                  set fnbody {}
               }
               lappend modcontent [list set-function $fnname $fnbody]
            }
            default {
               lappend modcontent $cmd
            }
         }
      }
   # not loaded, so get full content from script evaluation
   } else {
      set modcontent [sh-to-mod $elt_ignored_list {*}$shtomodargs]
   }

   # get name of current module unload Tcl interp
   set itrp [getCurrentModfileInterpName]

   # evaluate each recorded command in display Tcl interp to get them printed
   foreach modcmd $modcontent {
      interp eval $itrp $modcmd
   }
}

proc isVariantNameValid {name} {
   return [expr {![string is digit -strict $name] && [regexp\
      {^[A-Za-z0-9_][A-Za-z0-9_-]*$} $name]}]
}

# parse arguments set on a variant modulefile command
proc parseVariantCommandArgs {args} {
   set dflvalue {}
   set defdflvalue 0
   set isboolean 0
   set i 0
   foreach arg $args {
      incr i
      if {[info exists nextargisval]} {
         ##nagelfar vartype nextargisval varName
         set $nextargisval $arg
         unset nextargisval
      } else {
         switch -glob -- $arg {
            --default {
               ##nagelfar ignore Found constant
               set nextargisval dflvalue
               set defdflvalue 1
            }
            --boolean {
               set isboolean 1
            }
            -* {
               knerror "Invalid option '$arg'"
            }
            default {
               set name $arg
               # end option parsing: remaining elts are allowed values
               break
            }
         }
         set prevarg $arg
      }
   }

   if {[info exists nextargisval]} {
      knerror "Missing value for '$prevarg' option"
   }

   # check variant name and allowed values
   if {![info exists name]} {
      knerror {No variant name specified}
   }
   if {![isVariantNameValid $name]} {
      knerror "Invalid variant name '$name'"
   }
   set values [lrange $args $i end]
   if {$isboolean} {
      if {[llength $values]} {
         knerror "No value should be defined for boolean variant '$name'"
      } else {
         set values {1 0 yes no true false on off}
      }
   } else {
      foreach val $values {
         if {[string is boolean -strict $val] && ![string is integer\
            -strict $val]} {
            knerror "Boolean value defined on non-boolean variant '$name'"
         }
      }
   }
   if {$defdflvalue && $isboolean} {
      # default value should be bool if variant is boolean
      if {![string is boolean -strict $dflvalue]} {
         knerror "Boolean value is expected as default value for variant\
            '$name'"
      # translate default value in boolean canonical form (0 or 1)
      } else {
         set dflvalue [string is true -strict $dflvalue]
      }
   }

   return [list $name $values $defdflvalue $dflvalue $isboolean]
}

proc variant {itrp args} {
   # parse args
   lassign [parseVariantCommandArgs {*}$args] name values defdflvalue\
      dflvalue isboolean

   # version variant is forbidden until specific implementation
   if {$name eq {version}} {
      knerror "'version' is a restricted variant name" MODULES_ERR_GLOBAL
   }

   # get variant list defined on command line
   set vrlist [getVariantListFromVersSpec [currentState modulenamevr]]

   # search for variant specification (most right-positionned value wins)
   for {set i [expr {[llength $vrlist]-1}]} {$i >= 0} {incr i -1} {
      lassign [lindex $vrlist $i] vrname vrnot vrisbool vrvalue
      if {$vrname eq $name} {
         # translate value in boolean canonical form (0/1) if variant is bool
         if {$isboolean && [string is boolean -strict $vrvalue]} {
            set value [string is true -strict $vrvalue]
         } else {
            set value $vrvalue
         }
         set isdflval [expr {$defdflvalue && $dflvalue eq $value}]
         break
      }
   }

   # error if variant has not been specified unless a default is defined
   if {![info exists isdflval]} {
      if {$defdflvalue} {
         set value $dflvalue
         # 2 means default value automatically set
         set isdflval 2
      # no error if variant is undefined on display mode, return here not to
      # set any variant-specific variable
      } elseif {[currentState mode] eq {display}} {
         return
      } else {
         set allowedmsg [expr {![llength $values] ? {} : "\nAllowed values\
            are: $values"}]
         knerror "No value specified for variant '$name'$allowedmsg"\
            MODULES_ERR_GLOBAL
      }
   }

   # check defined value
   if {($isboolean && ![string is boolean -strict $value]) || (!$isboolean &&\
      [llength $values] && $value ni $values)} {
      # invalid value error is not a modulefile error
      knerror "Invalid value '$value' for variant '$name'\nAllowed values\
         are: $values" MODULES_ERR_GLOBAL
   } else {
      # instantiate variant in modulefile context
      reportDebug "Set variant on $itrp: ModuleVariant($name) = '$value'"
      $itrp eval set "{::ModuleVariant($name)}" "{$value}"
      # after modfile interp ModuleVariant is unset by resetInterpState

      # record variant for persistency (name value is-boolean is-default)
      # unless module is currently unloading
      if {[currentState mode] ne {unload}} {
         setLoadedVariant [currentState modulename] [list $name $value\
            $isboolean $isdflval]
      }
   }
}

# optimized variant command for whatis mode: init entry in ModuleVariant array
# to avoid variable being undefined when accessed during modulefile evaluation
proc variant-wh {itrp args} {
   # parse args
   lassign [parseVariantCommandArgs {*}$args] name values defdflvalue\
      dflvalue isboolean

   # instantiate variant in modulefile context to an empty value
   reportDebug "Set variant on $itrp: ModuleVariant($name) = ''"
   $itrp eval set "{::ModuleVariant($name)}" "{}"
}

proc getvariant {itrp args} {
   # parse args
   lassign [parseGetenvCommandArgs getvariant {*}$args] name valifundef\
      returnval

   if {[currentState mode] ne {display} || $returnval} {
      if {[$itrp eval info exists "{::ModuleVariant($name)}"]} {
         return [$itrp eval set "{::ModuleVariant($name)}"]
      } else {
         return $valifundef
      }
   } else {
      return [sgr va "{$name}"]
   }
}

proc require-fullname {} {
   # test specified name is any alternative name of currently evaluating mod
   # expect the default and parent dir name (which are considered unqualified)
   if {![modEq [currentState specifiedname] [currentState modulename] eqspec\
      1 4]} {
      knerror {Module version must be specified to load module}\
         MODULES_ERR_GLOBAL
   }
}

proc prereqAllModfileCmd {tryload auto args} {
   lassign [parsePrereqCommandArgs prereq-all {*}$args] tag_list\
      modulepath_list optional opt_list args
   # call prereq over each arg independently to emulate a prereq-all
   foreach arg $args {
      prereqAnyModfileCmd $tryload $auto {*}$opt_list $arg
   }
}

proc always-load {args} {
   lassign [parsePrereqCommandArgs always-load {*}$args] tag_list\
      modulepath_list optional opt_list args
   # append keep-loaded tag to the list, second tag list in opt_list will take
   # over the initial list defined
   lappend tag_list keep-loaded
   lappend opt_list --tag [join $tag_list :]

   # auto load is inhibited if currently in DepRe context
   set auto [expr {[currentModuleEvalContext] eq {depre} ? {0} : {1}}]

   # load all module specified
   prereqAllModfileCmd 0 $auto {*}$opt_list {*}$args
}

proc family {name} {
   # ensure name is valid to be part of the name of an environment variable
   if {![string length $name] || ![regexp {^[A-Za-z0-9_]*$} $name]} {
      knerror "Invalid family name '$name'"
   }

   # only one loaded module could provide a given family
   conflict $name
   # set name as an alias for currently loading module
   setLoadedAltname [currentState modulename] [list al $name]

   # set variable in environment to know what module name provides family
   set upname [string toupper $name]
   lassign [getModuleNameVersion] mod modname modversion
   if {$modname eq {.}} {
      set modname [currentState modulename]
   }
   setenv MODULES_FAMILY_$upname $modname
   # also set Lmod-specific variable for compatibility
   setenv LMOD_FAMILY_$upname $modname
}

proc family-un {name} {
   # ensure name is valid to be part of the name of an environment variable
   if {![string length $name] || ![regexp {^[A-Za-z0-9_]*$} $name]} {
      knerror "Invalid family name '$name'"
   }

   # unset family-related environment variable
   set upname [string toupper $name]
   unsetenv MODULES_FAMILY_$upname
   unsetenv LMOD_FAMILY_$upname
}

proc complete {shell name body} {
   if {![string length $name]} {
      knerror "Invalid command name '$name'"
   }
   # append definition retaining for which shell they are made
   # also some shells may set multiple definitions for a single name
   lappend ::g_Completes($name) $shell $body
   set ::g_stateCompletes($name) new

   # current module is qualified for refresh evaluation
   lappendState -nodup refresh_qualified [currentState modulename]
}

# undo complete in unload mode
proc complete-un {shell name body} {
   return [uncomplete $name]
}

proc uncomplete {name} {
   if {![string length $name]} {
      knerror "Invalid command name '$name'"
   }
   set ::g_Completes($name) {}
   set ::g_stateCompletes($name) del
}

proc pushenv {var val} {
   # save initial value in pushenv value stack
   set pushvar [getPushenvVarName $var]
   if {![isEnvVarDefined $pushvar] && [isEnvVarDefined $var]} {
      prepend-path $pushvar &$::env($var)
   }

   # clean any previously defined reference counter array
   unset-env [getModshareVarName $var] 1

   # Set the variable for later use during the modulefile evaluation
   set-env $var $val

   # add this value to the stack associated to current module name in order to
   # know what element to remove from stack when unloading
   prepend-path $pushvar [currentState modulename]&$val

   return {}
}

# undo pushenv in unload mode
proc pushenv-un {var val} {
   # clean any existing reference counter array
   unset-env [getModshareVarName $var] 1

   # update value stack
   set pushvar [getPushenvVarName $var]
   if {[isEnvVarDefined $pushvar]} {
      set pushlist [split $::env($pushvar) :]
      # find value pushed by currently evaluated module and remove it
      set popidx [lsearch -exact $pushlist [currentState modulename]&$val]
      if {$popidx != -1} {
         set pushlist [lreplace $pushlist $popidx $popidx]
         remove-path --index $pushvar $popidx
      }

      if {[llength $pushlist]} {
         # fetch value on top of the stack
         set validx [expr {[string first & [lindex $pushlist 0]] + 1}]
         set popval [string range [lindex $pushlist 0] $validx end]

         # restore top value if different from current one
         if {![envVarEquals $var $popval]} {
            set-env $var $popval
         }

         # if last element remaining in stack is the initial value prior first
         # pushenv, then clear the stack totally
         if {$validx == 1} {
            remove-path --index $pushvar 0
         }
      } else {
         unset-env $var 0 $val
      }
   } else {
      # Add variable to the list of variable to unset in shell output code but
      # set it in interp context as done on load mode for later use during the
      # modulefile evaluation
      unset-env $var 0 $val
   }

   return {}
}

# optimized pushenv for whatis mode (same approach than setenv-wh)
proc pushenv-wh {var val} {
   setEnvVarIfUndefined $var {}
   return {}
}

proc modulepath-label {modpath label} {
   set modpath [getAbsolutePath $modpath]
   set ::g_modulepathLabel($modpath) $label
   reportDebug "modpath=$modpath, label='$label'"
}

proc unique-name-conflict {} {
   # skip if unique_name_loaded configuration is disabled
   if {![getConf unique_name_loaded]} {
      return
   }

   # get root name of all names (actual and alternatives) of currently
   # evaluating module
   set root_name_list [list]
   set mod [currentState modulename]
   foreach name [list $mod {*}[getAllModuleResolvedName $mod]] {
      lappendNoDup root_name_list [lindex [file split $name] 0]
   }

   # declare conflict over all these names
   conflict {*}$root_name_list
}

proc sourceModfileCmd {itrp args} {
   # argument parsing: catch encoding arg but ignore it
   switch -- [llength $args] {
      1 {}
      3 {
         set option [lindex $args 0]
         if {$option ne {-encoding}} {
            knerror "Invalid option '$option'"
         }
      }
      default {
         knerror {wrong # args: should be "source ?-encoding? ?encodingName?\
            fileName"}
      }
   }
   set filename [lindex $args end]

   if {![info exists ::source_cache($filename)]} {
      set ::source_cache($filename) [readFile $filename]
   }

   interp eval $itrp info script $filename
   interp eval $itrp $::source_cache($filename)
   interp eval $itrp info script [currentState modulefile]
}

proc lsb-release {what} {
   return [switch -- $what {
      id {getState lsb_id}
      release {getState lsb_release}
      codename {getState lsb_codename}
      default {knerror "lsb-release $what not supported"}
   }]
}

proc registerCurrentModuleUse {args} {
   if {[string length [currentState modulename]]} {
      setLoadedUse [currentState modulename] {*}$args
   }
}

proc module-help {args} {
   lappend ::g_help_lines [join $args]
}

proc getModuleHelpLines {} {
   if {[info exists ::g_help_lines]} {
      return $::g_help_lines
   }
}

# convert property value as module tag (property name is ignored)
proc add-property {name value} {
   set tag_list [split $value :]
   set mod [currentState modulename]
   foreach tag $tag_list {
      module-tag $tag $mod
   }
}

proc module-warn {args} {
   # parse application criteria arguments to determine if command apply
   lassign [parseApplicationCriteriaArgs 1 0 {*}$args] apply isnearly after\
      otherargs

   # parse remaining argument list, do it even if command does not apply to
   # raise any command specification error
   foreach arg $otherargs {
      if {[info exists nextargisval]} {
         ##nagelfar vartype nextargisval varName
         set $nextargisval $arg
         unset nextargisval
      } else {
         switch -glob -- $arg {
            --message {
               set nextargisval message
            }
            -* {
               knerror "Invalid option '$arg'"
            }
            default {
               lappend modarglist $arg
            }
         }
         set prevarg $arg
      }
   }

   if {[info exists nextargisval]} {
      knerror "Missing value for '$prevarg' option"
   }
   if {![info exists message]} {
      knerror {No message specified in argument}
   }
   if {![info exists modarglist]} {
      knerror {No module specified in argument}
   }

   # skip tag record if application criteria are not met
   if {$apply} {
      ##nagelfar ignore Found constant
      set proplist [list message $message]
      # record each hide spec after parsing them
      foreach modarg [parseModuleSpecification 0 0 0 0 {*}$modarglist] {
         setModspecTag $modarg warning $proplist
      }
   }
}

proc extensions {args} {
   if {![llength $args]} {
      knerror {No module specified in argument}
   }
   # skip alias definition for extensions cmd if info_extension is enabled
   if {[getConf info_extension]} {
      return
   }
   provide {*}$args
}

proc provide {args} {
   if {![llength $args]} {
      knerror {No module specified in argument}
   }
   set current_mod [currentState modulename]
   foreach alias $args {
      setLoadedAltname $current_mod [list al $alias]
   }
}

proc module {command args} {
   # resolve and check command name
   lassign [parseModuleCommandName $command help] command cmdvalid cmdempty
   # clear other args if no command name supplied
   if {$cmdempty} {
      set args {}
   }
   # raise error if supplied command is not known
   if {!$cmdvalid} {
      knerrorModule 0 "Invalid command '$command'"
   }

   # define states needed by module spec parsing and sub-command processing
   # define if modfile should always be fully read even for validity check
   lappendState always_read_full_file [expr {$command ni [list path paths\
      list avail aliases edit spider]}]
   lappendState commandname $command

   # parse options, do that globally to ignore options not related to a given
   # module sub-command (exclude them from arg list)
   lassign [parseModuleCommandArgs 0 $command 0 0 {*}$args] show_oneperline\
      show_mtime show_filter search_filter search_match dump_state\
      addpath_pos not_req tag_list parsed_args

   # some commands can only be called from top level, not within modulefile
   switch -- $command {
      path - paths - autoinit - help - prepend-path - append-path -\
      remove-path - is-loaded - is-saved - is-used - is-avail -\
      info-loaded - clear - sh-to-mod - edit - refresh - source - state -\
      lint - mod-to-sh - reset - stash - stashpop - stashrm - stashshow -\
      stashclear - stashlist - cachebuild - cacheclear - spider {
         knerrorModule 0 "Command '$command' not supported"
      }
   }
   # other commands can only be called from modulefile evaluated from
   # command acting as top-level context (source and autoinit)
   if {([depthState modulename] > 1 || [aboveCommandName] ni [list source\
      autoinit]) && $command eq {config}} {
      knerrorModule 0 "Command '$command' not supported"
   }
   # no requirement should be recorded this module load/unload/switch cmd
   if {$not_req || ![getConf implicit_requirement]} {
      lappendState inhibit_req_record [currentState evalid]
   }

   checkModuleCommandNbArgs 0 $command [llength $parsed_args]

   {*}[formatModuleCommand 0 $command [currentState mode] $tag_list\
      $addpath_pos $show_oneperline $show_mtime $show_filter $search_filter\
      $search_match $dump_state $parsed_args]

   lpopState commandname
   lpopState always_read_full_file

   if {$not_req || ![getConf implicit_requirement]} {
      lpopState inhibit_req_record
   }

   return {}
}

# supersede append command to sync environment variable in modulefile eval
# sub-interpreter. use "set" Tcl command to use the Tcl-internal sync trigger.
proc appendModfileCmd {itrp var_name args} {
   # set a variable if passed var_name is an env variable
   if {[string range $var_name 0 3] eq {env(}} {
      set env_var_name ::$var_name
   } elseif {[string range $var_name 0 5] eq {::env(}} {
      set env_var_name $var_name
   }
   ##nagelfar vartype env_var_name varName
   if {[info exists env_var_name] && [info exists $env_var_name]} {
      set value [set $env_var_name][join $args {}]
      set cmd_op_list [list set $var_name $value]
   } else {
      set cmd_op_list [list _append $var_name {*}$args]
   }
   interp eval $itrp $cmd_op_list
}

# ;;; Local Variables:
# ;;; Mode: tcl-mode
# ;;; tcl-indent-level: 3
# ;;; tcl-continued-indent-level: 3
# ;;; indent-tabs-mode: nil
# ;;; End:
# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
