/*
 * ClusterFuzzLite target for Envmodules_GetFilesInDirectoryObjCmd, which
 * lists a directory while special-casing .modulerc/.version and hidden
 * entries. Module directories can live on shared, multi-tenant
 * filesystems, so this exercises the entry-name handling with
 * fuzzer-controlled file names rather than only fuzzer-controlled paths.
 */

#define _GNU_SOURCE
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <dirent.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include "envmodules.h"

#define MAX_ENTRIES 32
#define MAX_NAME_LEN 200

static void
cleanupDir(
   const char *dir)
{
   DIR *d;
   struct dirent *de;
   char fpath[PATH_MAX];

   d = opendir(dir);
   if (d == NULL) {
      return;
   }
   while ((de = readdir(d)) != NULL) {
      if (strcmp(de->d_name, ".") != 0 && strcmp(de->d_name, "..") != 0) {
         snprintf(fpath, sizeof(fpath), "%s/%s", dir, de->d_name);
         unlink(fpath);
      }
   }
   closedir(d);
}

int
LLVMFuzzerTestOneInput(
   const uint8_t *data,
   size_t size)
{
   char dirtemplate[] = "/tmp/cflite_gfid.XXXXXX";
   char *dir;
   size_t start, i;
   int created = 0;
   Tcl_Interp *interp;
   Tcl_Obj *objv[3];

   if (size < 1) {
      return 0;
   }

   dir = mkdtemp(dirtemplate);
   if (dir == NULL) {
      return 0;
   }

   /* Split the input (past the leading flag byte) on newlines into
    * candidate file names. */
   start = 1;
   for (i = 1; i <= size && created < MAX_ENTRIES; i++) {
      if (i == size || data[i] == '\n') {
         size_t len = i - start;
         if (len > 0 && len < MAX_NAME_LEN) {
            char name[MAX_NAME_LEN + 1];
            char fpath[PATH_MAX];
            int fd;

            memcpy(name, data + start, len);
            name[len] = '\0';
            if (strchr(name, '/') == NULL && strcmp(name, ".") != 0 &&
               strcmp(name, "..") != 0) {
               snprintf(fpath, sizeof(fpath), "%s/%s", dir, name);
               fd = open(fpath, O_CREAT | O_WRONLY, 0600);
               if (fd != -1) {
                  close(fd);
                  created++;
               }
            }
         }
         start = i + 1;
      }
   }

   interp = Tcl_CreateInterp();

   objv[0] = Tcl_NewStringObj("getFilesInDirectory", -1);
   objv[1] = Tcl_NewStringObj(dir, -1);
   objv[2] = Tcl_NewBooleanObj(data[0] & 1);
   Tcl_IncrRefCount(objv[0]);
   Tcl_IncrRefCount(objv[1]);
   Tcl_IncrRefCount(objv[2]);

   Envmodules_GetFilesInDirectoryObjCmd(NULL, interp, 3, objv);

   Tcl_DecrRefCount(objv[0]);
   Tcl_DecrRefCount(objv[1]);
   Tcl_DecrRefCount(objv[2]);
   Tcl_DeleteInterp(interp);

   cleanupDir(dir);
   rmdir(dir);

   return 0;
}
