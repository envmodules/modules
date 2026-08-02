/*
 * ClusterFuzzLite target for Envmodules_ReadFileObjCmd, which opens,
 * reads and closes a file while looking for the "#%Module" magic cookie
 * on its first line.
 *
 * The fuzzer input is written to a memfd instead of a real filesystem
 * path so each run stays off disk; the readFile command still receives
 * an ordinary path, via /proc/self/fd/<n>.
 */

#define _GNU_SOURCE
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include "envmodules.h"

int
LLVMFuzzerTestOneInput(
   const uint8_t *data,
   size_t size)
{
   int fd;
   char path[64];
   Tcl_Interp *interp;
   Tcl_Obj *objv[4];

   if (size < 1) {
      return 0;
   }

   /* First input byte selects the firstline/must_have_cookie flags; the
    * remaining bytes become the file content read back by readFile. */
   fd = memfd_create("cflite_readfile", 0);
   if (fd == -1) {
      return 0;
   }
   if (write(fd, data + 1, size - 1) != (ssize_t) (size - 1)) {
      close(fd);
      return 0;
   }
   snprintf(path, sizeof(path), "/proc/self/fd/%d", fd);

   interp = Tcl_CreateInterp();

   objv[0] = Tcl_NewStringObj("readFile", -1);
   objv[1] = Tcl_NewStringObj(path, -1);
   objv[2] = Tcl_NewBooleanObj(data[0] & 1);
   objv[3] = Tcl_NewBooleanObj((data[0] >> 1) & 1);
   Tcl_IncrRefCount(objv[0]);
   Tcl_IncrRefCount(objv[1]);
   Tcl_IncrRefCount(objv[2]);
   Tcl_IncrRefCount(objv[3]);

   Envmodules_ReadFileObjCmd(NULL, interp, 4, objv);

   Tcl_DecrRefCount(objv[0]);
   Tcl_DecrRefCount(objv[1]);
   Tcl_DecrRefCount(objv[2]);
   Tcl_DecrRefCount(objv[3]);
   Tcl_DeleteInterp(interp);
   close(fd);

   return 0;
}
