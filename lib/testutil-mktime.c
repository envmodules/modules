/*************************************************************************
 *
 * TESTUTIL-MKTIME.C, Superseded mktime function for test purpose
 * Copyright (C) 2020-2026 Xavier Delaruelle
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

#include <time.h>

#if defined (__APPLE__)

time_t my_mktime(struct tm *tm)
{
   return -1;
}

/* Code injection with DYLD interposing */
__attribute__((used))
static struct {
   const void *replacement;
   const void *replacee;
} interposers[]
__attribute__((section("__DATA,__interpose"))) = {
   { (const void *)my_mktime, (const void *)mktime }
};

#else

time_t mktime(struct tm *tm)
{
   return -1;
}

#endif

/* vim:set tabstop=3 shiftwidth=3 expandtab autoindent: */
