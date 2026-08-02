#!/bin/bash -eu
# shellcheck disable=SC2086,SC2016
#
# Flag variables below ($CFLAGS, $TCL_INCLUDE_SPEC, $TCL_LIB_SPEC,
# $LIB_FUZZING_ENGINE, ...) are deliberately left unquoted so each word
# splits into its own argument, per the standard OSS-Fuzz build.sh
# convention; quoting would collapse a multi-flag string into one
# argument and break the build.
#
# ClusterFuzzLite build script for lib/envmodules.c, the C extension
# backing the "libtclenvmodules" Tcl package. Fuzz targets call the
# extension's ObjCmd entry points directly against a real Tcl interpreter
# (Tcl_CreateInterp), bypassing Envmodules_Init, so this links against
# libtcl itself rather than the Tcl stub library the shipped module uses.

MODROOT="$SRC/modules"
FUZZDIR="$MODROOT/.clusterfuzzlite"

# lib/configure is generated (gitignored, not checked into the repo);
# the top-level ./configure normally creates it on demand via the same
# 'autoreconf -i' before running it, which we replicate here since we
# only need the C library, not a full top-level configure run.
cd "$MODROOT/lib"
autoreconf -i

# Generate lib/config.h (PACKAGE_NAME, GETGROUPS_T, ...) through the
# project's own TEA-based configure script. --disable-shared
# --disable-stubs turns off USE_TCL_STUBS: the shipped module is a
# stub-linked loadable extension whose Tcl_* calls only resolve once
# Envmodules_Init() runs Tcl_InitStubs(), but these fuzz targets call the
# ObjCmd entry points directly and link against libtcl itself, which
# doesn't export tclStubsPtr/Tcl_InitStubs.
TCLCONFDIR=$(dirname "$(find /usr -name tclConfig.sh | head -n1)")
./configure --with-tcl="$TCLCONFDIR" --disable-shared --disable-stubs

# shellcheck disable=SC1091
. "$TCLCONFDIR/tclConfig.sh"

$CC $CFLAGS $TCL_INCLUDE_SPEC -I"$MODROOT/lib" \
   -c "$MODROOT/lib/envmodules.c" -o "$WORK/envmodules.o"

for fuzzer in fuzz_parsedatetimearg fuzz_readfile fuzz_getfilesindirectory; do
   $CC $CFLAGS $TCL_INCLUDE_SPEC -I"$MODROOT/lib" \
      -c "$FUZZDIR/$fuzzer.c" -o "$WORK/$fuzzer.o"
   $CXX $CXXFLAGS -Wl,-rpath,'$ORIGIN/lib' \
      "$WORK/$fuzzer.o" "$WORK/envmodules.o" \
      $TCL_LIB_SPEC $LIB_FUZZING_ENGINE -o "$OUT/$fuzzer"
done

# Bundle libtcl next to the fuzz targets: $OUT ships without the
# container's system packages.
mkdir -p "$OUT/lib"
TCL_LIBDIR=$(echo "$TCL_LIB_SPEC" | grep -oE -- '-L[^ ]+' | head -n1 | cut -c3-)
cp -L "$TCL_LIBDIR"/libtcl8*.so* "$OUT/lib/"
