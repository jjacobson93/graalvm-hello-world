ARG ARCH=amd64

### DOWNLOAD
FROM --platform=${ARCH} alpine:3.13 AS download

ARG GRAAL_ARCH=amd64
ARG GRAAL_VERSION=21.1.0
ARG JAVA_VERSION=16

WORKDIR /download
RUN wget -q -O graalvm.tar.gz \
    "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-java${JAVA_VERSION}-linux-${GRAAL_ARCH}-${GRAAL_VERSION}.tar.gz"
RUN mkdir -p graalvm && \
    tar -xzf graalvm.tar.gz -C graalvm --strip-components 1 && \
    rm -rf graalvm.tar.gz

# clean up unnecessary garbage
WORKDIR /download/graalvm
RUN rm -rf GRAALVM-README.md LICENSE.txt THIRD_PART_LICENSE.txt legal

### BASE LAYER
FROM --platform=${ARCH} debian:stable-slim AS base
COPY --from=download /download/graalvm /opt/graalvm

ENV PATH="$PATH:/opt/graalvm/bin"

RUN apt-get update -yqq && \
    apt-get install -yqq build-essential zlib1g-dev && \
    gu install native-image

ENV GRAALVM_HOME=/opt/graalvm
ENV JAVA_HOME="$GRAALVM_HOME"

### BUILD LAYER
FROM base AS builder

WORKDIR /proj
COPY HelloWorld.java .

RUN javac HelloWorld.java

## for a static build
# RUN native-image --static -H:IncludeResources=resource-path HelloWorld

RUN native-image HelloWorld

### FINAL LAYER (from static build)
# FROM --platform=${ARCH} scratch
# COPY --from=builder /proj/helloworld /bin/helloworld

# CMD ["/bin/helloworld"]
