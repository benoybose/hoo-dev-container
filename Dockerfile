ARG PKGS_DIR_ANTLR_RUNTIME=/packages/antlr4-runtime
ARG ANTLR_VERSION=4.9.2
ARG ANTLR_INSTALL_DIR=/root/.m2/repository/org/antlr/antlr4/${ANTLR_VERSION}
ARG ANTLR_JAR_LOCATION=${ANTLR_INSTALL_DIR}/antlr4-${ANTLR_VERSION}-complete.jar
ARG LLVM=llvmorg-12.0.1

FROM ghcr.io/benoybose/llvm-dev-container:master as builder
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install --yes curl\
 pkg-config\
 uuid-dev\
 git\ 
 openjdk-11-jre-headless\
 maven

ARG ANTLR_VERSION
ARG ANTLR_JAR_LOCATION
ARG DOWNLOAD_DIR=/downloads
ARG DOWNLOAD_DIR_ANTLR=/downloads/antlr4
ARG BUILD_DIR=/builds
ARG BUILD_DIR_ANTLR_RUNTIME=/builds/antlr4-runtime
ARG PKGS_DIR=/packages
ARG PKGS_DIR_ANTLR_RUNTIME
ARG SOURCE_DIR_ANTLR_RUNTIME=${DOWNLOAD_DIR_ANTLR}/antlr4-${ANTLR_VERSION}/runtime/Cpp
ARG SOURCE_DIR_ANTLR=${DOWNLOAD_DIR_ANTLR}/antlr4-${ANTLR_VERSION}
ENV CXXFLAGS="-stdlib=libc++"

RUN mkdir -p ${DOWNLOAD_DIR_ANTLR}
RUN mkdir -p ${PKGS_DIR_ANTLR_RUNTIME}
RUN mkdir -p ${BUILD_DIR_ANTLR_RUNTIME}

WORKDIR ${DOWNLOAD_DIR_ANTLR}
RUN curl https://github.com/antlr/antlr4/archive/refs/tags/${ANTLR_VERSION}.tar.gz --location --output antlr.tar.gz
RUN tar -xf antlr.tar.gz
RUN rm antlr.tar.gz

WORKDIR ${SOURCE_DIR_ANTLR}
ENV MAVEN_OPTS="-Xmx1G"
RUN mvn clean
RUN mvn -DskipTests install

WORKDIR ${BUILD_DIR_ANTLR_RUNTIME}
RUN cmake -G "Unix Makefiles"\
 -S ${SOURCE_DIR_ANTLR_RUNTIME}\
 -DANTLR4_INSTALL=1 -DCMAKE_BUILD_TYPE=Release\
 -DCMAKE_C_COMPILER=/usr/local/bin/clang\
 -DCMAKE_CXX_COMPILER=/usr/local/bin/clang\
 -DCMAKE_INSTALL_PREFIX=${PKGS_DIR_ANTLR_RUNTIME}\
 -DANTLR_JAR_LOCATION=${ANTLR_JAR_LOCATION}\
 -DCMAKE_CXX_STANDARD=14

RUN make
RUN make install

FROM ghcr.io/benoybose/llvm-dev-container:master as dist
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install --yes gdb\
 openjdk-11-jre-headless\
 uuid-dev

ARG PKGS_DIR_ANTLR_RUNTIME
ARG ANTLR_VERSION
ARG ANTLR_INSTALL_DIR
ARG ANTLR_JAR_LOCATION

ENV ANTLR4_JAR_LOCATION=${ANTLR_JAR_LOCATION}
ENV CC=/usr/local/bin/clang
ENV CXX=/usr/local/bin/clang++
ENV CMAKE_GENERATOR="Unix Makefiles"
ENV CXXFLAGS="-stdlib=libc++ -i/usr/local/include/c++/v1"

COPY --from=builder ${PKGS_DIR_ANTLR_RUNTIME} /usr/local
COPY --from=builder ${ANTLR_INSTALL_DIR} ${ANTLR_INSTALL_DIR}
