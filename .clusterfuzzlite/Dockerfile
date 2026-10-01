FROM gcr.io/oss-fuzz-base/base-builder:v1@sha256:e67da2b0f6156b29b62734305a8c74db61aaf3158c7ab96386a07974fb33cdc8
RUN apt-get update && apt-get install -y autoconf tcl8.6-dev
COPY . $SRC/modules
WORKDIR $SRC/modules
COPY ./.clusterfuzzlite/build.sh $SRC/
