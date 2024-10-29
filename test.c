#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char** argv) {

    // read first argument and convert it to an int
    int number_pages = atoi(argv[1]);

    // calculate size in bytes
    size_t size = number_pages * 4*1024; // 1 page = 4*1024

    // get the current brk pointer
    void *current_brk = sbrk(0);

    // increase brk by size
    sbrk(size);

    // write heap to force page allocation
    memset(current_brk, 0, size);

    return 0;
}
