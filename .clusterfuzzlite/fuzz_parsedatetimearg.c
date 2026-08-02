/*
 * ClusterFuzzLite target for Envmodules_ParseDateTimeArgObjCmd, which
 * parses a "YYYY-MM-DD[THH:MM]" argument value into Epoch time.
 */

#include <stdint.h>
#include <stddef.h>
#include "envmodules.h"

int
LLVMFuzzerTestOneInput(
   const uint8_t *data,
   size_t size)
{
   Tcl_Interp *interp;
   Tcl_Obj *objv[3];

   interp = Tcl_CreateInterp();

   objv[0] = Tcl_NewStringObj("parseDateTimeArg", -1);
   objv[1] = Tcl_NewStringObj("opt", -1);
   objv[2] = Tcl_NewStringObj((const char *) data, (int) size);
   Tcl_IncrRefCount(objv[0]);
   Tcl_IncrRefCount(objv[1]);
   Tcl_IncrRefCount(objv[2]);

   Envmodules_ParseDateTimeArgObjCmd(NULL, interp, 3, objv);

   Tcl_DecrRefCount(objv[0]);
   Tcl_DecrRefCount(objv[1]);
   Tcl_DecrRefCount(objv[2]);
   Tcl_DeleteInterp(interp);

   return 0;
}
