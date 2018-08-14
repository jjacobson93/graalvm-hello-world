FROM alpine:3.8 AS download

ARG GRAAL_VERSION=1.0.0-rc5
WORKDIR /download
RUN wget -q -O graalvm.tar.gz "https://github.com/oracle/graal/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-${GRAAL_VERSION}-linux-amd64.tar.gz"
RUN mkdir -p graalvm && \
    tar -xzf graalvm.tar.gz -C graalvm --strip-components 1 && \
    rm -rf graalvm.tar.gz

# clean up unnecessary garbage
WORKDIR /download/graalvm
RUN rm -rf src.zip man sample THIRD_PARTY_README GRAALVM-README.md ASSEMBLY_EXCEPTION

FROM debian:stable-slim AS builder
COPY --from=download /download/graalvm /opt/graalvm

ENV PATH="$PATH:/opt/graalvm/bin"

RUN apt-get update -yqq && \
    apt-get install -yqq build-essential zlib1g-dev

WORKDIR /proj
COPY HelloWorld.java .

RUN javac HelloWorld.java
RUN native-image --static HelloWorld

FROM scratch
COPY --from=builder /proj/helloworld /bin/helloworld

CMD ["/bin/helloworld"]
