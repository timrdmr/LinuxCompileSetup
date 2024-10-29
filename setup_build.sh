#!/bin/bash
# only required to run if the volume was recreated
#   e.g.  docker volume create linux-build-vol
#   and in docker run use --mount source=linux-build-vol,target=/build/linux

# Download the Linux kernel source code, do it as a first step to benefit from Docker cache
# wget https://github.com/torvalds/linux/archive/refs/tags/v6.10-rc2.tar.gz
# tar -xf v6.10-rc2.tar.gz
git clone https://github.com/timrdmr/linux.git
cd linux
# Checkout stable version Linux 6.10-rc3
git checkout 83a7eefedc9b56fe7bfeff13b6c7356688ffa670
cd ..

# configure linux
# kernel config created using make menuconfig
# see https://www.sobyte.net/post/2022-02/debug-linux-kernel-with-qemu-and-gdb/
# or offical documentation: https://www.kernel.org/doc/html/latest/dev-tools/gdb-kernel-debugging.html
# TODO: there are additional debug options available
cp kernel_config linux/.config
cd linux
make scripts_gdb

# specificy gdb debug options
echo "add-auto-load-safe-path /build/linux/" >> ~/.gdbinit

# vscode debugging
mkdir -p .vscode
cp ../launch.json .vscode/launch.json

python3 scripts/clang-tools/gen_compile_commands.py

echo "Ready to build with make -j \$(nproc)"
