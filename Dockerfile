FROM ubuntu:22.10
RUN apt update
RUN apt install clang --yes
RUN apt install llvm-dev lldb --yes
RUN apt install antlr4 --yes
RUN apt install libantlr4-runtime4.9 libantlr4-runtime-dev --yes
RUN apt install cmake cmake-extras --yes
RUN apt clean
