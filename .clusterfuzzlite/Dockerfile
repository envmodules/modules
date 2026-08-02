FROM gcr.io/oss-fuzz-base/base-builder:v1
RUN apt-get update && apt-get install -y autoconf tcl8.6-dev
COPY . $SRC/modules
WORKDIR $SRC/modules
COPY ./.clusterfuzzlite/build.sh $SRC/
