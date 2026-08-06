#
# siteconfig.tcl - Site specific configuration script that copies, the first
#   time a module tagged 'remote' is loaded, its application directory from
#   a remote network share to local disk with rsync, so this and every later
#   load of the same module read from local disk instead of the network
#   share.
#
# Author: Xavier Delaruelle <xavier.delaruelle@cea.fr>
# Compatibility: Modules v5.7+
#
# Installation: put this file in the 'etc' directory of your Modules
#   installation. Refer to the "Modulecmd startup" section in the
#   module(1) man page to get this location.

# root of the mounted network share and of its local counterpart
set g_remoteAppDir /remote_apps
set g_localAppDir /local_apps

# return the application directory basename mapped to given bare module name
# and version, or an empty string if this module has no mapped directory
proc getAppDirBasename {modname} {
   set mapfile [file join $::g_remoteAppDir .module_appdir_map]
   if {![file readable $mapfile]} {
      return {}
   }
   set fid [open $mapfile r]
   set fdata [split [read $fid] "\n"]
   close $fid
   foreach fline $fdata {
      if {[llength $fline] == 2 && [lindex $fline 0] eq $modname} {
         return [lindex $fline 1]
      }
   }
   return {}
}

# copy application directory from the remote network share to local disk, on
# the first load of a module tagged 'remote' (see the modulepath root
# .modulerc file for how this tag gets applied)
proc syncRemoteAppDir {modfile modname modnamevr modspec mode requested} {
   if {$mode ne {load}} {
      return
   }
   set itrp [getCurrentModfileInterpName]
   if {![interp eval $itrp {module-info tags remote}]} {
      return
   }

   set appdir [getAppDirBasename $modname]
   if {$appdir eq {}} {
      return
   }

   set syncedfile [file join $::g_localAppDir ".$appdir.synced"]
   if {[file exists $syncedfile]} {
      return
   }

   report "Syncing '$appdir' application directory from remote share..."
   file mkdir $::g_localAppDir
   set srcdir [file join $::g_remoteAppDir $appdir]
   set destdir [file join $::g_localAppDir $appdir]
   if {[catch {exec rsync -a --delete $srcdir/ $destdir/} errMsg]} {
      reportError "Failed to sync '$appdir' from remote share\n$errMsg"
      return
   }

   # mark this application directory as synced so it does not get copied
   # again on a later load
   close [open $syncedfile w]
}
add-hook before-modulefile-eval syncRemoteAppDir

# vim:set tabstop=3 shiftwidth=3 expandtab autoindent:
