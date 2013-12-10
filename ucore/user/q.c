#include <ulib.h>
#include <file.h>
#include <stat.h>
#include <stdio.h>
#include <unistd.h>

#include "progdef.h"

#define BUFSIZE                         4096

#define printf(...) fprintf(1, __VA_ARGS__)


int
cat(int fd) {
    static char buffer[BUFSIZE];
    int ret1, ret2;
    while ((ret1 = read(fd, buffer, sizeof(buffer))) > 0) {
        if ((ret2 = write(1, buffer, ret1)) != ret1) {
            return ret2;
        }
		return 0;
    }
    return ret1;
}

int
main(int argc, char **argv) {
	int fd, ret;
	fd = open(PROG_FILE_NAME, O_RDONLY);
	if (fd < 0)
		return fd;
	if ((ret = cat(fd)) != 0) {
		return ret;
	}
	return 0;
}

