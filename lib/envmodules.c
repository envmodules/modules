/*************************************************************************
 *
 * ENVMODULES.C, Modules Tcl extension library
 * Copyright (C) 2018-2026 Xavier Delaruelle
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

#define _ISOC99_SOURCE
#define _XOPEN_SOURCE 500

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "config.h"
#include "envmodules.h"

/* A specific function named getgrouplist_2 should be used on Darwin systems
 * to be able to fetch all user groups, especially if user is member of more
 * then 16 groups */
#if defined (__APPLE__)
int32_t getgrouplist_2(const char *, gid_t, gid_t **);
#endif

/*	Utility function to compare 2 integers for qsort function. */
int
__Envmodules_IntCmp(
   const void* i,
   const void* j)
{
   return (i > j) - (i < j);
}

/*----------------------------------------------------------------------
 *
 * Envmodules_GetFilesInDirectoryObjCmd --
 *
 *	 This function is invoked to read the content of a directory in a more
 *	 IO-optimized way than native Tcl commands perform by avoiding specific
 *	 additional queries to get hidden files like .modulerc and .version.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_GetFilesInDirectoryObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   int fetch_dotversion;
   const char *dir;
   Tcl_Size dirlen;
   DIR *did;
   Tcl_Obj *ltmp, *lres;
   struct dirent *direntry;
   int have_modulerc = 0;
   int have_version = 0;
   int is_hidden;
   int is_dir;
   char path[PATH_MAX];
   struct stat st;

   /* Parse arguments. */
   if (objc == 3) {
      /* fetch_dotversion */
      if (Tcl_GetBooleanFromObj(interp, objv[2], &fetch_dotversion)!=TCL_OK) {
         Tcl_SetErrorCode(interp, "TCL", "VALUE", "BOOLEAN", NULL);
         return TCL_ERROR;
      }
   } else {
      Tcl_WrongNumArgs(interp, 1, objv, "dir fetch_dotversion");
      return TCL_ERROR;
   }

   dir = Tcl_GetStringFromObj(objv[1], &dirlen);

   /* Open directory. */
   if ((did  = opendir(dir)) == NULL) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf(
         "couldn't open directory \"%s\": %s", dir, Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   /* Read directory. */
   ltmp = Tcl_NewListObj(0, NULL);
   Tcl_IncrRefCount(ltmp);
   errno = 0;
   while ((direntry = readdir(did)) != NULL) {
      snprintf(path, sizeof(path), "%s/%s", dir, direntry->d_name);
      /* ignore . and .. */
      if (!strcmp(direntry->d_name, ".") || !strcmp(direntry->d_name, "..")) {
         continue;
      } else if (!strcmp(direntry->d_name, ".modulerc")) {
         if (!access(path, R_OK)) {
            have_modulerc = 1;
         }
      } else if (!strcmp(direntry->d_name, ".version")) {
         if (fetch_dotversion && !access(path, R_OK)) {
            have_version = 1;
         }
      } else {
         Tcl_ListObjAppendElement(interp, ltmp, Tcl_NewStringObj(path, -1));
         is_hidden = (direntry->d_name[0] == '.') ? 1 : 0;
         Tcl_ListObjAppendElement(interp, ltmp, Tcl_NewIntObj(is_hidden));
         /* Determine if entry is a directory using d_type when available,
          * falling back to stat() for DT_UNKNOWN/DT_LNK (symlinks to
          * dirs and NFS v3 where d_type is always DT_UNKNOWN) */
#ifdef DT_DIR
         if (direntry->d_type == DT_DIR) {
            is_dir = 1;
         } else if (direntry->d_type != DT_UNKNOWN
               && direntry->d_type != DT_LNK) {
            is_dir = 0;
         } else
#endif
         {
            is_dir = (!stat(path, &st) && S_ISDIR(st.st_mode)) ? 1 : 0;
         }
         Tcl_ListObjAppendElement(interp, ltmp, Tcl_NewIntObj(is_dir));
      }
   }
   /* Do not treat error happening during read to send list of valid files. */

   /* Close directory. */
   if (closedir(did) == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf(
         "couldn't close directory \"%s\": %s", dir, Tcl_PosixError(interp)));
      Tcl_DecrRefCount(ltmp);
      return TCL_ERROR;
   }

   /* Build result list. */
   lres = Tcl_NewObj();
   Tcl_IncrRefCount(lres);
   /* Ensure .modulerc and .version are first entries in result list */
   if (have_modulerc) {
      snprintf(path, sizeof(path), "%s/%s", dir, ".modulerc");
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewStringObj(path, -1));
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewIntObj(0));
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewIntObj(0));
   }
   if (have_version) {
      snprintf(path, sizeof(path), "%s/%s", dir, ".version");
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewStringObj(path, -1));
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewIntObj(0));
      Tcl_ListObjAppendElement(interp, lres, Tcl_NewIntObj(0));
   }
   /* Then append regular elements. */
   Tcl_ListObjAppendList(interp, lres, ltmp);
   Tcl_DecrRefCount(ltmp);


   Tcl_SetObjResult(interp, lres);
   Tcl_DecrRefCount(lres);
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_ReadFileObjCmd --
 *
 *	 This function is invoked to open/read/close a regular file in a
 *	 more IO-optimized way than native Tcl commands perform by avoiding
 *	 useless lstat, fcntl and ioctl syscalls.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_ReadFileObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   int firstline;
   int must_have_cookie;
   const char *filename;
   Tcl_Size filenamelen;
   int fid;
   int firstread;
   ssize_t len;
   char buf[READ_BUFFER_SIZE];
   Tcl_Obj *res;

   /* Parse arguments. */
   if (objc < 2 || objc > 4) {
      Tcl_WrongNumArgs(interp, 1, objv,
         "filename ?firstline? ?must_have_cookie?");
      return TCL_ERROR;
   }
   if (objc > 2) {
      if (Tcl_GetBooleanFromObj(interp, objv[2], &firstline) != TCL_OK) {
         Tcl_SetErrorCode(interp, "TCL", "VALUE", "BOOLEAN", NULL);
         return TCL_ERROR;
      }
   } else {
      firstline = 0;
   }
   if (objc > 3) {
      if (Tcl_GetBooleanFromObj(interp, objv[3], &must_have_cookie) !=
         TCL_OK) {
         Tcl_SetErrorCode(interp, "TCL", "VALUE", "BOOLEAN", NULL);
         return TCL_ERROR;
      }
   } else {
      must_have_cookie = 0;
   }

   filename = Tcl_GetStringFromObj(objv[1], &filenamelen);

   /* Open file. */
   if ((fid  = open(filename, O_RDONLY)) == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf("couldn't open \"%s\": %s",
         filename, Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   /* Read file. */
   res = Tcl_NewObj();
   Tcl_IncrRefCount(res);
   /* Only read first characters to get magic cookie. */
   if (firstline == 1) {
      if ((len = read(fid, buf, FIRSTLINE_LENGTH)) > 0) {
         Tcl_AppendToObj(res, buf, len);
      }
   } else {
      firstread = 1;
      while ((len = read(fid, buf, READ_BUFFER_SIZE)) > 0) {
         Tcl_AppendToObj(res, buf, len);
         /* Stop reading if magic cookie is mandatory but not found at the
          * beginning of file. */
         if (firstread == 1) {
            firstread = 0;
            if (must_have_cookie == 1 && strncmp(buf, MODULES_MAGIC_COOKIE, 8)
               != 0) {
               break;
            }
         }
      }
   }
   /* Error during read. */
   if (len == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf("error reading \"%s\": %s",
         filename, Tcl_PosixError(interp)));
      Tcl_DecrRefCount(res);
      close(fid);
      return TCL_ERROR;
   }

   /* Close file. */
   close(fid);

   Tcl_SetObjResult(interp, res);
   Tcl_DecrRefCount(res);
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_InitStateUsernameObjCmd --
 *
 *	 This function is invoked to return the username of user running
 *	 current process.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_InitStateUsernameObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   uid_t uid;
   struct passwd *pwd;
   char uidstr[16];
   Tcl_Obj *res;

   /* Get current user id */
   uid = getuid();

   /* Fetch corresponding passwd entry */
   if ((pwd = getpwuid(uid)) == NULL) {
      Tcl_SetErrno(errno);
      sprintf (uidstr, "%d", uid);
      Tcl_SetObjResult(interp,
         Tcl_ObjPrintf("couldn't find name for user id \"%s\": %s", uidstr,
         Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   /* Set username as result */
   res = Tcl_NewObj();
   Tcl_IncrRefCount(res);
   Tcl_AppendToObj(res, pwd->pw_name, strlen(pwd->pw_name));

   Tcl_SetObjResult(interp, res);
   Tcl_DecrRefCount(res);
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_InitStateUsergroupsObjCmd --
 *
 *	 This function is invoked to return all the groups the user running
 *	 current process is member of.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_InitStateUsergroupsObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   GETGROUPS_T *groups;
   int ngroups = 0;
   int egid_in_groups = 0;
   GETGROUPS_T egid;
   int i, j;
   struct group *grp;
   char gidstr[16];
   Tcl_Obj *lres;
   Tcl_Obj *sgrp;

#if defined (__APPLE__)
   uid_t uid;
   struct passwd *pwd;
   char uidstr[16];

   /* Fetch user passwd entry */
   uid = getuid();
   if ((pwd = getpwuid(uid)) == NULL) {
      Tcl_SetErrno(errno);
      sprintf (uidstr, "%d", uid);
      Tcl_SetObjResult(interp,
         Tcl_ObjPrintf("couldn't find name for user id \"%s\": %s", uidstr,
         Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   groups = NULL;
   ngroups = getgrouplist_2(pwd->pw_name, pwd->pw_gid, &groups);
#else
#if defined (HAVE_GETGROUPS)
   ngroups = getgroups(0, (GETGROUPS_T *) NULL);
#endif

   /* Fetch supplementary group list unless getgroups not supported */
   groups = (GETGROUPS_T *) ckalloc((ngroups + 1) * sizeof(GETGROUPS_T));

#if defined (HAVE_GETGROUPS)
   if ((ngroups = getgroups(ngroups, groups)) == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp,
         Tcl_ObjPrintf("couldn't get supplementary groups: %s",
         Tcl_PosixError(interp)));
      ckfree((char *) groups);
      return TCL_ERROR;
   }
#endif
#endif

   /* Sort then remove duplicates from getgroups result */
   if (ngroups > 1) {
      qsort(groups, ngroups, sizeof(GETGROUPS_T), __Envmodules_IntCmp);
      j = 0;
      for (i = 1; i < ngroups; i++) {
         if (groups[i] != groups[j]) {
            j++;
            groups[j] = groups[i];
         }
      }
      ngroups = j + 1;
   }

   /* Add primary group if not part of getgroups result (or if getgroups
    * function is not available) */
   egid = getegid();
   for (i = 0; i < ngroups; i++) {
      if (egid == groups[i]) {
         egid_in_groups = 1;
         break;
      }
   }
   if (egid_in_groups == 0) {
      groups[ngroups] = egid;
      ngroups++;
   }

   /* Add group name of primary gid and each supplementatry gid to result
    * list */
   lres = Tcl_NewObj();
   Tcl_IncrRefCount(lres);
   for (i = 0; i < ngroups; i++) {
      /* If group name cannot be resolved, add use gid number as group name */
      if ((grp = getgrgid(groups[i])) == NULL) {
         sprintf(gidstr, "%d", groups[i]);
         sgrp = Tcl_NewStringObj(gidstr, -1);
      } else {
         sgrp = Tcl_NewStringObj(grp->gr_name, -1);
      }
      Tcl_ListObjAppendElement(interp, lres, sgrp);
   }

   Tcl_SetObjResult(interp, lres);
   Tcl_DecrRefCount(lres);
#if defined (__APPLE__)
   free((char *) groups);
#else
   ckfree((char *) groups);
#endif
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_InitStateClockSecondsObjCmd --
 *
 *	 This function is invoked to return current Epoch time.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_InitStateClockSecondsObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   time_t now;

   /* Fetch current Epoch time */
   if ((now = time(NULL)) == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf("couldn't get Epoch time: %s",
         Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   /* Set fetched time as result */
   Tcl_SetObjResult(interp, Tcl_NewWideIntObj((Tcl_WideInt) now));
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_ParseDateTimeArgObjCmd --
 *
 *	 This function is invoked to parse date time argument value and
 *	 translate it into Epoch time.
 *
 * Results:
 *	 A standard Tcl result.
 *
 * Side effects:
 *	 None.
 *
 *---------------------------------------------------------------------*/

int
Envmodules_ParseDateTimeArgObjCmd(
   ClientData dummy,       /* Not used. */
   Tcl_Interp *interp,     /* Current interpreter. */
   int objc,               /* Number of arguments. */
   Tcl_Obj *const objv[])  /* Argument objects. */
{
   const char *opt;
   const char *datetime;
   Tcl_Size optlen;
   Tcl_Size datetimelen;
   char dt[17];
   int valid_dt = 0;
   struct tm tm;
   time_t epoch;

   /* Parse arguments. */
   if (objc != 3) {
      Tcl_WrongNumArgs(interp, 1, objv, "opt datetime");
      return TCL_ERROR;
   }
   opt = Tcl_GetStringFromObj(objv[1], &optlen);
   datetime = Tcl_GetStringFromObj(objv[2], &datetimelen);

   /* Normalize transmitted datetime */
   switch (datetimelen) {
      case 16:
         strncpy(dt, datetime, 16);
         dt[16] = '\0';
         valid_dt = 1;
         break;
      case 10:
         strncpy(dt, datetime, 10);
         dt[10] = '\0';
         strcat(dt, "T00:00");
         valid_dt = 1;
         break;
   }

   /* Break down datetime into a time struct */
   memset(&tm, 0, sizeof(struct tm));
   tm.tm_isdst = -1;
   if (valid_dt && (strptime(dt, "%Y-%m-%dT%H:%M", &tm) == NULL)) {
      valid_dt = 0;
   }

   /* Raise error if datetime format is invalid */
   if (valid_dt == 0) {
      Tcl_SetObjResult(interp, Tcl_ObjPrintf(
         "Incorrect %s value '%s' (valid date time format is 'YYYY-MM-DD[THH:MM]')",
         opt, datetime));
      Tcl_SetErrorCode(interp, "MODULES_ERR_KNOWN", NULL);
      return TCL_ERROR;
   }

   /* Convert string date in Epoch time */
   if ((epoch = mktime(&tm)) == -1) {
      Tcl_SetErrno(errno);
      Tcl_SetObjResult(interp, Tcl_ObjPrintf(
         "couldn't convert to Epoch time: %s", Tcl_PosixError(interp)));
      return TCL_ERROR;
   }

   /* Set converted Epoch time as result */
   Tcl_SetObjResult(interp, Tcl_NewWideIntObj((Tcl_WideInt) epoch));
   return TCL_OK;
}

/*----------------------------------------------------------------------
 *
 * Envmodules_Init --
 *
 *  Initialize the Modules commands.
 *
 * Results:
 *  TCL_OK if the package was properly initialized.
 *
 * Side effects:
 *  Adds package commands to the current interp.
 *
 *---------------------------------------------------------------------*/

DLLEXPORT int
Envmodules_Init(
   Tcl_Interp* interp      /* Tcl interpreter */
) {
    /* Require at least Tcl 8.5 */
   if (Tcl_InitStubs(interp, "8.5-", 0) == NULL) {
      return TCL_ERROR;
   }

   /* Create the provided commands */
   Tcl_CreateObjCommand(interp, "readFile", Envmodules_ReadFileObjCmd,
      (ClientData) NULL, (Tcl_CmdDeleteProc*) NULL);
   Tcl_CreateObjCommand(interp, "getFilesInDirectory",
      Envmodules_GetFilesInDirectoryObjCmd, (ClientData) NULL,
      (Tcl_CmdDeleteProc*) NULL);
   Tcl_CreateObjCommand(interp, "initStateUsername",
      Envmodules_InitStateUsernameObjCmd, (ClientData) NULL,
      (Tcl_CmdDeleteProc*) NULL);
   Tcl_CreateObjCommand(interp, "initStateUsergroups",
      Envmodules_InitStateUsergroupsObjCmd, (ClientData) NULL,
      (Tcl_CmdDeleteProc*) NULL);
   Tcl_CreateObjCommand(interp, "initStateClockSeconds",
      Envmodules_InitStateClockSecondsObjCmd, (ClientData) NULL,
      (Tcl_CmdDeleteProc*) NULL);
   Tcl_CreateObjCommand(interp, "parseDateTimeArg",
      Envmodules_ParseDateTimeArgObjCmd, (ClientData) NULL,
      (Tcl_CmdDeleteProc*) NULL);

   /* Provide the Envmodules package */
   return Tcl_PkgProvide(interp, PACKAGE_NAME, PACKAGE_VERSION);
}

/* vim:set tabstop=3 shiftwidth=3 expandtab autoindent: */
