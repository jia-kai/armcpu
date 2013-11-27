/*
 * $File: r.c
 * $Date: Thu Nov 28 04:40:39 2013 +0800
 * $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>
 */

#include <syscall.h>
#include <file.h>
#include <unistd.h>
#include <ulib.h>
#include <stdio.h>

/*
 * WARNING: DO NOT use something like printf here because the string printed
 *		to stdout will be redirect to serial bus
 */
#define PROG_FILE_NAME	"p"
int main() {
	int fd;
/*    dprintf("opening file `%s' ...\n", PROG_FILE_NAME);*/
	fd = open(PROG_FILE_NAME, O_WRONLY);
/*    dprintf("invoke sys_fetchrun(%d)", fd);*/
	sys_fetchrun(fd);
/*    dprintf("closing file ...\n");*/
	close(fd);
/*    dprintf("done\n");*/
}

/**
 * vim: foldmethod=marker
 */

