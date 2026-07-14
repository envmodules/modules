/*************************************************************************
 *
 * TESTUTIL-TCL_LOADFILE.C, Superseded Tcl_LoadFile function for test purpose
 * Copyright (C) 2026 Xavier Delaruelle
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 ************************************************************************/

#include <tcl.h>

#if !defined (__APPLE__)

int Tcl_LoadFile(Tcl_Interp *interp, Tcl_Obj *pathPtr,
   const char *const symbols[], int flags, void *procVPtrs,
   Tcl_LoadHandle *handlePtr)
{
   Tcl_SetObjResult(interp, Tcl_ObjPrintf("error message"));
   return TCL_ERROR;
}

#endif

/* vim:set tabstop=3 shiftwidth=3 expandtab autoindent: */
