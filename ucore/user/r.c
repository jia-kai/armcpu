/*
 * $File: r.c
 * $Date: Thu Nov 28 05:53:27 2013 +0800
 * $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>
 */

#include <syscall.h>
#include <error.h>
#include <file.h>
#include <unistd.h>
#include <ulib.h>
#include <stdio.h>

#define PROG_FILE_NAME	"p"


#define BUFSIZE			4096

int testfile(const char *name) {
    int ret;
    if ((ret = open(name, O_RDONLY)) < 0) {
		dprintf("testfile: %s, ret = %d\n", name, ret);
        return ret;
    }
	dprintf("testfile: %s, ret = %d\n", name, ret);
    close(ret);
    return ret;
}

int run_prog(const char *fname, int argc, char *_argv[]) {
	static char argv0[BUFSIZE];
	const char *argv[EXEC_MAX_ARG_NUM + 1];
	int ret;
	dprintf("fname: %s\n", fname);
	if ((ret = testfile(fname)) != 0) {
		if (ret < 0) {
			return ret;
		}
		snprintf(argv0, sizeof(argv0), "/%s", fname);
		dprintf("argv0: %s\n", argv0);
		argv[0] = argv0;
		dprintf("argv[0]: %s\n", argv[0]);
	}
	int i;
	for (i = 1; i < argc; i ++)
		argv[i] = _argv[i];
	argv[argc] = NULL;
	for (i = 0; i < argc; i ++)
		dprintf("%d: %s\n", i, argv[i]);

	return __exec(NULL, argv);
}

int main(int argc, char *argv[]) {
	int fd;
	dprintf("opening file `%s' ...\n", PROG_FILE_NAME);
	fd = open(PROG_FILE_NAME, O_WRONLY);
	dprintf("invoking sys_fetchrun(%d)", fd);
	sys_fetchrun(fd);
	dprintf("closing file ...\n");
	close(fd);
	dprintf("executing program ...\n");
	int pid, ret, i;
	for (i = 0; i < argc; i ++)
		dprintf("%d: %s\n", i, argv[i]);
	if ((pid = fork()) == 0) {
		dprintf("forked program here ...\n");
		ret = run_prog(PROG_FILE_NAME, argc, argv);
		exit(ret);
	}
	dprintf("master program here ...\n");
	if (waitpid(pid, &ret) == 0) {
		if (ret != 0) {
			dprintf("error: %d - %e\n", ret, ret);
		}
	}
	return ret;
}

/**
 * vim: foldmethod=marker
 */

