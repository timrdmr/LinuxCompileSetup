# Build and Debug Linux Kernel inside Docker - Attach with VSCode

## Setup
- create file public_key.txt and paste ssh key used on the VSCode host
- docker build `docker build -t compile-linux .`
- `docker run -it -p 22:22 -p 1234:1234 --mount source=linux-build-vol,target=/build/linux compile-linux`
- use the setup_build.sh script, that has already been copied to the container to prepare the Linux build
    - this is only required if a new volume was created
- connect with VSCode to root@localhost
- install C++ microsoft extension + extension pack on "remote host"
- if not already started, run `qemu-system-x86_64 -append "console=ttyS0 nokaslr" -nographic -kernel /build/linux-6.10-rc2/arch/x86/boot/bzImage -initrd /install/busybox/initramfs.cpio.gz -s -S` to start linux kernel in qemu
    - or in a tmux session: `tmux new-session -d -s qemu 'qemu-system-x86_64 -append "console=ttyS0 nokaslr" -nographic -kernel /build/linux-6.10-rc2/arch/x86/boot/bzImage -initrd /install/busybox/initramfs.cpio.gz -s -S'`
    - quit qemu with ctrl+a => x
- in VSCode in the debugger view, click "Attach to QEMU"

## Limitations
- it seems to be not possible to disable compiler optimization (https://stackoverflow.com/questions/29151235/how-to-de-optimize-the-linux-kernel-to-and-compile-it-with-o0), however, this works for single functions:
    ```
    void __attribute__((optimize("O0"))) foo(unsigned char data) {
    // unmodifiable compiler code
    }
    ```
