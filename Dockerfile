FROM ubuntu:22.10
RUN echo "deb http://apt.llvm.org/kinetic/ llvm-toolchain-kinetic-15 main" | tee /etc/apt/sources.list.d/docker.list
RUN echo "deb-src http://apt.llvm.org/kinetic/ llvm-toolchain-kinetic-15 main" | tee /etc/apt/sources.list.d/docker.list
RUN apt update
RUN apt install wget gnupg zlib1g-dev git --yes
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt install clang-15 clang-tools-15 lldb-15 lld-15 --yes
RUN apt install libllvm15 llvm-15 llvm-15-dev llvm-15-runtime --yes
RUN apt install libmlir-15-dev mlir-15-tools --yes
RUN apt install antlr4 --yes
RUN apt install libantlr4-runtime4.9 libantlr4-runtime-dev --yes
RUN apt install cmake cmake-extras --yes
RUN ln -s /usr/bin/clang-15 /usr/bin/clang
RUN ln -s /usr/bin/clang++-15 /usr/bin/clang++
RUN apt clean
