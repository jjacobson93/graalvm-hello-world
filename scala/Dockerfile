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

ENV GRAALVM_HOME=/opt/graalvm
ENV JAVA_HOME="$GRAALVM_HOME"

ENV PATH="$PATH:$GRAALVM_HOME/bin"

RUN apt-get update -yqq && \
  apt-get install -yqq wget build-essential zlib1g-dev && \
  gu install native-image

### Scala
FROM base AS scala

ENV SCALA_HOME=/opt/scala

ENV PATH="$PATH:$SCALA_HOME/bin:/opt/sbt/bin"

RUN wget -O scala.tar.gz https://github.com/lampepfl/dotty/releases/download/3.0.0/scala3-3.0.0.tar.gz && \
  wget -O sbt.tar.gz https://github.com/sbt/sbt/releases/download/v1.5.3/sbt-1.5.3.tgz && \
  mkdir -p /opt/scala && \
  mkdir -p /opt/sbt && \
  tar -xzf scala.tar.gz -C /opt/scala --strip-components 1 && \
  tar -xzf sbt.tar.gz -C /opt/sbt --strip-components 1 && \
  rm -rf scala.tar.gz sbt.tar.gz

### BUILD LAYER
FROM scala AS builder

WORKDIR /proj
COPY build.sbt .

RUN sbt exit
COPY src ./src

RUN sbt compile && \
    native-image \
      -cp "$(cat /dev/null | sbt 'export runtime:fullClasspath' | tail -n 1)" \
      -H:IncludeResources=resource-path \
      --static -O1 \
      --no-fallback \
      hello

### FINAL LAYER (from static build)
FROM --platform=${ARCH} scratch
COPY --from=builder /proj/hello /bin/hello

CMD ["/bin/hello"]
