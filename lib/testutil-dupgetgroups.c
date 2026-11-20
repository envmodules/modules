/*************************************************************************
 *
 * TESTUTIL-DUPGETGROUPS.C, Superseded getgroups function for test purpose
 * Copyright (C) Modules Contributors
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

#include <unistd.h>
#include <sys/types.h>
#include "config.h"

int getgroups(int size, gid_t list[])
{
   GETGROUPS_T egid;

   egid = getegid();
   if (list != NULL) {
      list[0] = egid;
      list[1] = egid;
      list[2] = egid;
   }

   return 3;
}

/* vim:set tabstop=3 shiftwidth=3 expandtab autoindent: */
