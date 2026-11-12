#!/usr/bin/env tclsh

set ::MODULEFILES_DIR "modulefiles"

array set ::g_OlInfo {}
set ::g_OlInfo(none:layout) {none}
set ::g_OlInfo(none:type) {n}
set ::g_OlInfo(none:modulefiles_root) {/zzzzzzzzzzzz}
set ::g_OlInfo(none:len_modroot) {1}
set ::g_OlInfo(:layout) {}
set ::g_UsedOverlays [list]
set ::g_UsedGroups [list]
set ::g_Overlays [list]
set ::g_Groups [list]
set ::g_HideTags [list]

proc overlay-define {name type layout install_root {modulefiles_root {}}\
                        {def_groups {}} } {
   if { $modulefiles_root eq {} } {
      set modulefiles_root $install_root
   }
   if { ![file isdirectory $install_root] } {
      reportErrorAndExit\
         "Install root '$install_root' for overlay '$name' does not exist!"
   }
   if { ![file isdirectory $modulefiles_root] } {
      reportErrorAndExit\
         "Modulefiles root '$modulefiles_root' for overlay '$name' does not exist!"
   }
   set ::g_OlInfo($name:type) $type
   set ::g_OlInfo($name:layout) $layout
   set ::g_OlInfo($name:install_root) $install_root
   set ::g_OlInfo($name:modulefiles_root) [file split $modulefiles_root]
   set ::g_OlInfo($name:len_modroot) [llength $::g_OlInfo($name:modulefiles_root)]
   set ::g_OlInfo($name:def_groups) $def_groups
   lappend ::g_Overlays $name
   # we need a mapping group/label -> directory with modulefiles
   # in Pmodules this is defined via group names
   # directories with the same label are merged
   set dirs [list]

   set patterns [list\
                    [file join * modulefiles]\
                    [file join Compiler modulefiles * *]\
                    [file join HDF5_serial modulefiles * *]\
                    [file join MPI modulefiles * * * *]\
                    [file join HDF5 modulefiles * * * * * *]]

   foreach pattern $patterns {
      foreach dir [glob -nocomplain -types {d}\
			  [file join {*}$::g_OlInfo($name:modulefiles_root)\
			      $pattern]] {
         if {[info exists ::g_Dir2Overlay($dir)]} {
            reportErrorAndExit\
               "Overlay '$name' cannot use the same modulefiles root as '$::g_Dir2Overlay($dir)'!"
         }
         set ::g_Dir2Overlay($dir) $name
         set group [lindex [file split $dir] end-1]
         if {$group ni $::g_Groups} {
            lappend ::g_Groups $group
         }
         modulepath-label $dir "$group ($name)"
      }
   }
}

proc overlay-info { name } {
   puts stderr "$::g_OlInfo($name:type) $::g_OlInfo($name:layout) $::g_OlInfo($name:install_root) $::g_OlInfo($name:modulefiles_root)"
}

proc overlay-get-moddirs { pos ol_name } {
   if {![info exists ::g_OlInfo($ol_name:type)]} {
      reportErrorAndExit "Overlay '$ol_name' does not exist!"
   }
   set moddirs [list]
   set modulepath [split $::env(MODULEPATH) $::tcl_platform(pathSeparator)]
   if { $pos eq {remove} } {
      # remove all directories belonging to overlay
      foreach dir $modulepath {
	 if {[info exists ::g_Dir2Overlay($dir)]} {
	    if {$::g_Dir2Overlay($dir) eq $ol_name} {
	       lappend moddirs $dir
	    }
	 }
      }
   } else {
      # if no overlay is loaded, add default groups of overlay to MODULEPATH,
      # otherwise only groups which are used (and also in the overlay)
      if {![info exists ::g_UsedOverlays] ||\
             [info exists ::env(__MODULES_AUTOINIT_INPROGRESS)]} {
	 set groups $::g_OlInfo($ol_name:def_groups)
      } else {
	 set groups $::g_UsedGroups
      }
      foreach group $groups {
	 set dir [file join {*}$::g_OlInfo($ol_name:modulefiles_root)\
		     $group modulefiles]
	 if { [file isdirectory $dir] && $dir ni $modulepath } {
	    lappend moddirs $dir
	 }
      }
   }
   return $moddirs
}

proc module-addgroup { group } {
   set itrp [getCurrentModfileInterpName]

   set fpmod [interp eval $itrp {set ::ModulesCurrentModulefile}]
   set fp_mod [file split $fpmod]
   set ol [_find_overlay $fp_mod]
   if {$ol eq {none}} { 
      return
   } elseif { $::g_OlInfo(${ol}:layout) ne "Pmodules" } {
      return
   }
   if {[info exists ::g_moduleHideFullPath($fpmod)]} {
      return
   }

   set mod [file join [lindex $fp_mod end-1] [lindex $fp_mod end]]
   set	GROUP [string toupper $group]
   # replace '-' with '_' in group name
   # ('-' is invalid in variable names in most prog. languages)
   regsub -- "-" ${GROUP} "_" GROUP
   setenv	${GROUP}		[lindex $fp_mod end-1]
   setenv	${GROUP}_VERSION	[lindex $fp_mod end]

   set rel_modulefile [lrange $fp_mod $::g_OlInfo($ol:len_modroot) end]
   set variant [lrange $rel_modulefile 2 end]

   set idx [lsearch $::g_UsedOverlays $ol]
   set overlays [lrange $::g_UsedOverlays 0 $idx]
   foreach overlay [lreverse $overlays] {
      if {$overlay eq {none}} {
	 continue
      }
      set dir [file join \
                  {*}$::g_OlInfo($overlay:modulefiles_root) \
                  $group \
                    $::MODULEFILES_DIR \
                  {*}$variant]
      if { ![file isdirectory $dir] } {
         continue
      }
      set l [list]
      foreach {name version} $variant {
         lappend l $name/$version
      }
      modulepath-label $dir "$group ($overlay:$l)"
      interp eval $itrp prepend-path MODULEPATH $dir
   }
}

proc lreverse_n { list n } {
   set res {}
   set i [expr [llength $list] - $n]
   while {$i >= 0} {
      lappend res {*}[lrange $list $i [expr $i+$n-1]]
      incr i -$n
   }
   set res
}

proc _find_overlay { fp_mod } {
   foreach ol_name $::g_UsedOverlays {
      set len $::g_OlInfo($ol_name:len_modroot)
      if {$::g_OlInfo($ol_name:modulefiles_root) eq [lrange $fp_mod 0 $len-1]} {
         return $ol_name
      }
   }
   return {none}
}

proc _pmodules_setenv { PREFIX name version } {
   if { ![file isdirectory "$PREFIX"] } {
      return
   }
   if { ! [info exist ::dont-setenv] } {
      set dont-setenv {}
   }
   set NAME [string toupper $name]
   regsub -all -- "-" ${NAME} "_" NAME
   set defaults [dict create\
                    "${NAME}_VERSION"	  [list setenv 0 $version]\
                    "${NAME}_PREFIX"	  [list setenv 1 $PREFIX]\
                    "${NAME}_DIR"	  [list setenv 1 $PREFIX]\
                    "${NAME}_HOME"	  [list setenv 1 $PREFIX]\
                    "${NAME}_INCLUDE_DIR" [list setenv 1 $PREFIX/include]\
                    "${NAME}_LIBRARY_DIR" [list setenv 1 $PREFIX/lib]\
                    "${NAME}_LIBRARY_DIR" [list setenv 1 $PREFIX/lib64]\
                    "PATH"		  [list prepend-path 1 $PREFIX/bin\
                                              $PREFIX/sbin]\
                    "MANPATH"		  [list prepend-path 1 $PREFIX/share/man]\
                    "C_INCLUDE_PATH"	  [list prepend-path 1 $PREFIX/include]\
                    "CPLUS_INCLUDE_PATH"  [list prepend-path 1 $PREFIX/include]\
                    "LIBRARY_PATH"	  [list prepend-path 1 $PREFIX/lib\
                                              $PREFIX/lib64]\
                    "LD_LIBRARY_PATH"	  [list prepend-path 1 $PREFIX/lib\
                                              $PREFIX/lib64]\
                    "PKG_CONFIG_PATH"	  [list prepend-path 1 $PREFIX/lib/pkgconfig\
                                              $PREFIX/share/pkgconfig]\
                    "CMAKE_MODULE_PATH"   [list prepend-path 1 $PREFIX/lib/cmake\
                                              $PREFIX/share/cmake\
                                              $PREFIX/share/${name}/cmake]\
                   ]
   set itrp [getCurrentModfileInterpName]
   dict for {key value} $defaults {
      if { $key in ${dont-setenv} } {
	 continue
      }
      set items [lassign $value procedure is_dir]
      foreach item $items {
         if { $is_dir && ![file isdirectory "$item"] } {
            continue
         }
         interp eval $itrp $procedure $key $item
      }
   }
}

rename evaluateModulefile __evaluateModulefile
proc evaluateModulefile {itrp mod_file vr_spec_list} {
   set fp_mod [file split $mod_file]

   # name and version of module
   array set vars {}
   set vars(P) [lindex $fp_mod end-1] 
   set vars(V) [lindex $fp_mod end]

   set vars(V_RELEASE) {}
   lassign [split $vars(V) _] v suffix
   lassign [split $v -]	vars(V_PKG) vars(V_RELEASE)
   lassign [split $vars(V_PKG) .] vars(V_MAJOR) vars(V_MINOR) vars(V_PATCHLVL)

   set ol [_find_overlay $fp_mod]
   if {$::g_OlInfo(${ol}:layout) eq {Pmodules} } {
      set itrp [getCurrentModfileInterpName]
      interp eval $itrp conflict $vars(P)
      set rel_modulefile [lrange $fp_mod $::g_OlInfo($ol:len_modroot) end]
      set vars(GROUP) [lindex $rel_modulefile 0]
      set variant [lrange $rel_modulefile 2 end]
      set prefix "[file split $::g_OlInfo(${ol}:install_root)] $vars(GROUP) [lreverse_n $variant 2]"
      set vars(PREFIX) [file join {*}$prefix]
      _pmodules_setenv $vars(PREFIX) $vars(P) $vars(V)
      set dir [file dirname $mod_file]
      set depinfo [file join $dir ".deps-$vars(V)"]
      if {[file exists $depinfo]} {
	 set fp [open $depinfo r]
	 set mods [list]
	 while { [gets $fp line] >= 0 } {
	    lappend mods $line
	 }
	 close $fp
	 if {[llength $mods] > 0} {
	    interp eval $itrp prereq-all $mods
	 }
      }
   }
   foreach key [array names vars] {
      if {$vars($key) ne {}} {
         interp eval $itrp set ::$key $vars($key)
      }
   }
   __evaluateModulefile $itrp $mod_file $vr_spec_list
}

rename runModuleUse _runModuleUse
proc runModuleUse {cmd mode pos args} {
   if {[llength $args] == 0} {
      puts stderr {Used overlays:}
      foreach ol $::g_UsedOverlays {
	 if {$ol ne {none}} {
	    puts stderr "  $ol:"
            puts stderr "    type: $::g_OlInfo($ol:type)"
            puts stderr "    layout: $::g_OlInfo($ol:layout)"
            puts stderr "    install_root: $::g_OlInfo($ol:install_root)"
            puts stderr "    modulefiles_root: [file join {*}$::g_OlInfo($ol:modulefiles_root)]"
	 }
      }
      puts stderr {Unused overlays:}
      foreach ol $::g_Overlays {
	 if {$ol ne {none} && $ol ni $::g_UsedOverlays} {
	    puts stderr "  $ol:"
            puts stderr "    type: $::g_OlInfo($ol:type)"
            puts stderr "    layout: $::g_OlInfo($ol:layout)"
            puts stderr "    install_root: $::g_OlInfo($ol:install_root)"
            puts stderr "    modulefiles_root: [file join {*}$::g_OlInfo($ol:modulefiles_root)]"
	 }
      }
      puts stderr {Used release stages:}
      puts stderr {  stable}
      if {{unstable} ni $::g_HideTags} {
	 puts stderr {  unstable}
      }
      if {{deprecated} ni $::g_HideTags} {
	 puts stderr {  deprecated}
      }
      _runModuleUse $cmd $mode $pos {*}$args
      return
   }
   set optlist [list]
   set pathlist [list]
   set call_ModuleUse 0
   foreach arg $args {
      switch -glob -- $arg {
	 -* {
	    lappend optlist $arg
	 }
	 deprecated -
	 unstable -
	 stable {
	    set hideList [getConfList hide_tags]
	    set hideList [lsearch -all -inline -not -exact $hideList $arg]
	    if {$cmd eq {unuse}} {
	       lappend hideList $arg
	    }
	    cmdModuleConfig 1 hide_tags [join $hideList {:}]
	 }
	 default {
	    if { [info exists ::g_OlInfo($arg:type)] } {
               if {[info exists ::env(LOADEDMODULES)] && $::env(LOADEDMODULES) ne ""} {
                  reportErrorAndExit "Overlays can only be added or removed if no modules are loaded"
               }
               lappend pathlist {*}[overlay-get-moddirs $pos $arg]
               if {$arg ni $::g_UsedOverlays && $arg ne {base}} {
                  if {[info procs cmdModuleResurface] ne {}} {
                     cmdModuleResurface prepend-path __MODULES_OVERLAYS $arg
                  } else {
                     # for when running on envmodules pre 5.7.*
                     module prepend-path __MODULES_OVERLAYS $arg
                  }
                }
               if {[llength $pathlist] > 0} {
                  set call_ModuleUse 1
               }
	    } elseif {$arg in $::g_Groups} {
               set ignore_list {Compiler MPI HDF5 HDF5_serial}
               if {$arg in $ignore_list} {
                  reportErrorAndExit\
                     "Cannot use hierachical group $arg!"
               }
	       foreach ol $::g_UsedOverlays {
		  set dir [file join {*}$::g_OlInfo($ol:modulefiles_root)\
			      $arg modulefiles]
		  if {[file isdirectory $dir]} {
                     set call_ModuleUse 1
		     lappend pathlist $dir
		  }
	       }
	    } elseif {[file isdirectory $arg]} {
               set call_ModuleUse 1
               lappend pathlist $arg
            } else { # arg is a label or invalid
	       set is_label 1
               foreach {dir label} [array get ::g_modulepathLabel] {
                  if {$arg eq $label} {
	             set is_label 0
                     set call_ModuleUse 1
		     lappend pathlist $arg
                  }
               }
               if {! $is_label} {
                  reportErrorAndExit\
                     "Argument '$arg' is neither a directory, label, release stage or overlay!"
               }
	    }
         }
      }
   }
   if { $call_ModuleUse } {
      _runModuleUse $cmd $mode $pos {*}$optlist {*}$pathlist
   }
   return
}

rename getModuleHidingLevel _getModuleHidingLevel
proc getModuleHidingLevel {mod fpmod {update 1}} {
   if {[string match {*/.config-*} $mod]} {return 2}
   if {[string match {*/.deps-*} $mod]} {return 2}
   if {[string match {*/.release-*} $mod]} {return 2}

   # if full path module has been hidden, this hidden level is the base level
   # value we will return
   set baselvl -1
   set modroot [lindex [file split $mod] 0]
   if {$fpmod ne {}} {
      if {[info exists ::g_moduleHideFullPath($fpmod)]} {
         set baselvl $::g_moduleHideFullPath($fpmod)
      } else {
         set fp_mod [file split $fpmod]
         set ol_mod [_find_overlay $fp_mod]
         if {$::g_OlInfo($ol_mod:layout) eq {Pmodules}} {
            set grp_mod [lindex $fp_mod $::g_OlInfo($ol_mod:len_modroot)]
            if {[info exists ::g_moduleHideOverlay($modroot)]} {
               # maybe hidden
               lassign $::g_moduleHideOverlay($modroot) ol_hid grp
               if {$::g_OlInfo($ol_hid:type) eq {h}} {
                  if {$grp eq $grp_mod} {
                     set i [lsearch -exact $::g_UsedOverlays $ol_mod]
                     set j [lsearch -exact $::g_UsedOverlays $ol_hid]
                     if { $i > $j} {
                        return 2
                     }
                  }
               }
            } else {
               set ::g_moduleHideOverlay($modroot) "$ol_mod $grp_mod"
            }
         }
      }
   }
   set hideList [getConfList hide_tags]
   foreach tag [getMatchingTagList $mod $fpmod] {
      if {$tag in $hideList} {
	 return 1
      }
   }

   # look if mod matches one of the hidden module specs applying to mod root
   if {[info exists ::g_moduleHideRoot($modroot)]} {
      for {set lvl 2} {$lvl > -1} {incr lvl -1} {
         # no need to search anymore if we have reached same hiding level as
         # one defined on full path module designation
         if {$lvl == $baselvl} {
            break
         }
         foreach hmodspec [lindex $::g_moduleHideRoot($modroot) $lvl] {
            if {[modEq $hmodspec $mod eqstart 1 0 1 {}]} {
	       return $lvl
            }
         }
      }
   }
   return $baselvl
}

proc module-maintainer {args} {
   lset args 0 "Maintainer: [lindex $args 0]"
   lappend ::g_help_lines [join $args]
}

proc module-license {args} {
   lset args 0 "License:    [lindex $args 0]"
   lappend ::g_help_lines [join $args]
}

proc module-url {args} {
   lset args 0 "Url:        [lindex $args 0]"
   lappend ::g_help_lines [join $args] 
}

set modulerc_extra_vars {\
   P {} V {}\
   V_MAJOR {} V_MINOR {} V_PATCHLVL {} V_RELEASE {} V_PKG {}\
   PREFIX {}\
   GROUP {}\
			 }
set modulefile_extra_cmds {\
   module-addgroup module-addgroup\
   module-maintainer module-maintainer\
   module-license module-license\
   module-url module-url\
   overlay-define overlay-define\
}

# initialize

set ::g_config_defs(hide_tags) [list MODULE_HIDE_TAGS {} 0 l {} {}]

if {[info exists ::env(MODULES_HOSTCONFIG)]} {
   source $::env(MODULES_HOSTCONFIG)
} elseif {[file exists [file join [file separator] {etc} {environment-modules} {config.tcl}] ]} {
   source [file join [file separator] {etc} {environment-modules} {config.tcl}]
} else {
   overlay-define base n Pmodules /opt/psi {} {Tools Programming}
}
if {[info exists ::env(__MODULES_OVERLAYS)]} {
   set ::g_UsedOverlays [split $::env(__MODULES_OVERLAYS) $::tcl_platform(pathSeparator)] 
}

set usr_overlayrc [file join $::env(HOME) {.overlayrc}]
if {[file exists $usr_overlayrc]} {
   source $usr_overlayrc
}
# get used overlays and groups from MODULEPATH
if {[info exists ::env(MODULEPATH)]} {
   foreach dir [split $::env(MODULEPATH) $::tcl_platform(pathSeparator)] {
      if { [info exists ::g_Dir2Overlay($dir)] } {
         set ol_name $::g_Dir2Overlay($dir)
         set group [lindex [file split $dir] end-1]
      } else {
         set ol_name none
         set group none
      }
      if { $ol_name ni $::g_UsedOverlays } {
         lappend ::g_UsedOverlays $ol_name
      }
      if { $group ni $::g_UsedGroups } {
         lappend ::g_UsedGroups $group
      }
   }
}

# Local Variables:
# tcl-indent-level: 3
# End:
