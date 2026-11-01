FROM gcr.io/oss-fuzz-base/base-builder:v1@sha256:1f9cf74bc3d7029b528494542f9d9851b256dceed38d3f420989434dc5ae0760
RUN apt-get update && apt-get install -y autoconf tcl8.6-dev
COPY . $SRC/modules
WORKDIR $SRC/modules
COPY ./.clusterfuzzlite/build.sh $SRC/
