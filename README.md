# graalvm-hello-world
GraalVM Hello World with Docker

## Multi-stage build
This utilizes a multi-stage build to: (1) download GraalVM, (2) build the source, and (3) copy into a final minimal image. The resulting image for HelloWorld.java is 7MB.

In the build stage, the `native-image` is used which compiles a class into a native executable which contains a embedded JVM called Substrate VM.

More information on ahead-of-time compilation in GraalVM can be found in the [reference manual](https://www.graalvm.org/docs/reference-manual/aot-compilation/).
