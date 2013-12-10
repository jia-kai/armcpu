#include <stdio.h>
#include <file.h>
#include <unistd.h>
#include <string.h>
#include <ulib.h>

#define VERBOSE			0

#define printf(...)		fprintf(1, __VA_ARGS__)
#define putc(c)			printf("%c", c)

#define PROG_FILE_NAME	"prog"
#define BUFSIZE			1
#define FILE_SIZE_MAX	1000000
#define ARGV0_SIZE_MAX	256

int read_wrapper(int fin, void *ptr, int size) {
	int ret = read(fin, ptr, size);
	if (VERBOSE) {
		char *str = (char *)ptr;
		int i;
		for (i = 0; i < size; i ++)
			printf("0x%x\n", str[i]);
	}
	return ret;
}

int
copy(int fin, int fout) {
	int size = 0;
    static char buffer[BUFSIZE];
    int ret1, ret2;
	int filesize = FILE_SIZE_MAX;

	if (fin == 0)
		read_wrapper(fin, &filesize, sizeof(filesize));
	int p = 0;
    while ((ret1 = read_wrapper(fin, buffer, sizeof(buffer))) > 0) {
		size += ret1;
		p += 1;
		if (p == 100) {
			printf("size: %d\n", size);
			p = 0;
		}
        if ((ret2 = write(fout, buffer, ret1)) != ret1) {
            return ret2;
        }
		if (size == filesize)
			break;
    }
    return size;
}

/**
 * 4 byte: size
 * size byte: data
 */
const char *argv[EXEC_MAX_ARG_NUM + 1] = {0};
int main(int argc, char **argv) {
	int fin = 0;
	fin = open("test.txt", O_RDONLY);
	int fout = open(PROG_FILE_NAME, O_WRONLY);
	int size = copy(fin, fout);
	if (fout> 2)
		close(fout);
	if (fin > 2)
		close(fin);
	printf("size: %d\n", size);

	static char argv0[ARGV0_SIZE_MAX];
	memcpy(argv0, PROG_FILE_NAME, sizeof(PROG_FILE_NAME));
	argv[0] = argv0;

	// run program
	int pid, ret;
	if ((pid = fork()) == 0) {
		ret = __exec(NULL, argv);
		exit(ret);
	}
	assert(pid >= 0);
	if (waitpid(pid, &ret) == 0) {
		if (ret != 0) {
			printf("error: %d\n", ret);
		}
	}
	return 0;
}
