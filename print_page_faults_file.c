#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main(int argc, char** argv) {

    getchar();

    int number_pages = atoi(argv[1]);

    // allocate the specified size on kBytes
    size_t size = number_pages * 4*1024; // 1 page = 4*1024

    // note that the libs may already increased brk

    getchar();

    void *current_brk = sbrk(0);

    sbrk(size);
    void *new_brk = sbrk(0);

    printf("Increased brk by %li bytes, brk was %p and is now %p, start to write memory now\n", size, current_brk, new_brk);

    memset(current_brk, 0, size);

    getchar();

    void *ptr = malloc(size);

    if (ptr == NULL) {
        // printf("Memory allocation failed\n");
        return 1; // Return an error code
    }

    // Use the allocated memory, write zeros
    memset(ptr, 0, size);

    // read the number of minor page faults from file
    FILE* file = fopen("/proc/self/stat", "r");
    if (!file)
    {
        printf("File cannot be opened\n");
        return 1;
    }

    size_t len = 1024;
    char *line = malloc(len);
    getline(&line, &len, file);

    // find number of minor page faults (10th field)
    char *position = line;
    unsigned int space_count = 0;
    while (space_count < 9)
    {
        if (*position == ' ')
        {
            space_count ++;
        }
        position ++;
    }
    // now position points to the beginning of the value
    printf("Number of page faults: ");
    while (*position != ' ')
    {
        printf("%c", *position);
        position ++;
    }
    printf("\n");

    free(line);
    free(ptr);

    return 0;
}
