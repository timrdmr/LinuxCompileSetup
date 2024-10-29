# commands from https://medium.com/@ThyCrow/compiling-the-linux-kernel-and-creating-a-bootable-iso-from-it-6afb8d23ba22
FROM ubuntu:24.04

# Install necessary packages
RUN apt-get update 
# kernel build
RUN apt-get install -y build-essential libncurses5-dev bc bison flex libelf-dev git openssl libssl-dev 
# kernel tools build (perf)
RUN apt-get install -y libtraceevent-dev pkg-config libdw-dev apt-utils systemtap-sdt-devel libunwind-dev clang libslang2-dev libperl-dev python3-dev
# debugging / tooling
RUN apt-get install -y qemu-system-x86 screen tmux gdb cpio vim openssh-server wget curl

# download busybox source
WORKDIR /install
ARG busybox_version=busybox-snapshot
RUN wget https://www.busybox.net/downloads/snapshots/$busybox_version.tar.bz2
RUN tar -xf $busybox_version.tar.bz2

# install busybox from source
WORKDIR /install/busybox
RUN make defconfig
# enable in configuration: Build static binary (no shared libs) like make menuconfig would do
RUN sed -i 's/^# CONFIG_STATIC is not set$/CONFIG_STATIC=y/' .config
# this issue blocks the build of busybox on latest ubuntu: https://github.com/docker-library/busybox/issues/198
# apply patch like this: https://github.com/docker-library/busybox/pull/199/files
RUN curl -fL -o busybox-no-cbq.patch 'https://bugs.busybox.net/attachment.cgi?id=9751'
RUN patch -p1 --input=busybox-no-cbq.patch

RUN make -j $(nproc)

# create the file system
RUN make install
WORKDIR _install
RUN mkdir dev proc sys
# copy init program into file sytsem
COPY init .
RUN chmod +x init
# copy abritrary files into the virtual file system
COPY test.c .
RUN gcc --static -o test test.c
RUN chmod +x test
RUN find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
WORKDIR ..

# install ssh server to remotly access the container
# RUN mkdir ~/.ssh # already exists on ubuntu 24
COPY public_key.txt .
RUN cat public_key.txt >> ~/.ssh/authorized_keys
RUN rm public_key.txt

# copy setup script and config files
COPY gdbinit ~/.gdbinit
WORKDIR /build
COPY kernel_config .
# vscode setup
COPY launch.json .
COPY setup_build.sh .
RUN chmod +x setup_build.sh

# RUN service ssh start not working, need to trigger this manually
# specify -s -S to wait for debugging
# also not working: RUN tmux new-session -d -s qemu 'qemu-system-x86_64 -append "console=ttyS0 nokaslr" -nographic -kernel /build/linux/arch/x86/boot/bzImage -initrd initramfs.cpio.gz -s -S'
WORKDIR /build
ENTRYPOINT service ssh restart && \
    # tmux new-session -d -s qemu 'qemu-system-x86_64 -append "console=ttyS0 nokaslr" -nographic -kernel /build/linux/arch/x86/boot/bzImage -initrd /install/busybox/initramfs.cpio.gz -s -S' && \
    bash
