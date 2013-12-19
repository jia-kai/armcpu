/*
 * $File: userlib.c
 * $Date: Thu Dec 19 11:38:22 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <stdio.h>
#include <ulib.h>
#include <readline.h>

#define MEM_BUF_SIZE	1024
void* Alloc(int size) {
	static char buf[MEM_BUF_SIZE];
	static int cur_size;
	char *ret = buf + cur_size;
	size += (4 - (size & 3)) & 3;
	cur_size += size;
	if (cur_size > MEM_BUF_SIZE) {
		cprintf("full of memory\n");
		exit(0);
	}
	return ret;
}

void PrintInt(int val) {
	fprintf(1, "%d", val);
}

void PrintString(const char *str) {
	fprintf(1, "%s", str);
}

int _ReadInteger() {
	char *str = readline(NULL);
	int rst = 0;
	while (*str) {
		rst = (rst << 3) + (rst << 1) + (*str - '0');
		str ++;
	}
	return rst;
}

