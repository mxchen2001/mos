FROM ubuntu

RUN apt-get update 
RUN apt-get upgrade -y

# gcc compiler
RUN apt install -y build-essential

# compile assembly code
RUN apt-get install -y nasm

# build final iso file
RUN apt-get install -y xorriso
RUN apt-get install -y grub-pc-bin
RUN apt-get install -y grub-common


VOLUME /root/env
WORKDIR /root/env