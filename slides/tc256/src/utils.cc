/*
 * $File: utils.cc
 * $Date: Tue Dec 17 10:55:58 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "utils.hh"
#include "exc.hh"

#include <unistd.h>
#include <libgen.h>
#include <pthread.h>
#include <sys/time.h>
#include <sys/resource.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cstdarg>
#include <ctime>

#include <vector>
using namespace std;


void __assert_failed__(const char *file, const char *func, int line,
		const char *expr) {

	throw FatalError("Assertion `%s' failed (%s@%s:%d)\n",
			expr, func, basename(strdupa(file)), line);
}

void __log_printf__(const char *file, const char *func, int line,
		const char *fmt, ...) {
	static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

	static const char *time_fmt = nullptr;
	if (!time_fmt) {
		if (isatty(fileno(stderr)))
			time_fmt = "\033[1;31m[%s %s@%s:%d]\033[0m ";
		else
			time_fmt = "[%s %s@%s:%d] ";
	}
	time_t cur_time;
	time(&cur_time);
	char timestr[64];
	strftime(timestr, sizeof(timestr), "%H:%M:%S",
			localtime(&cur_time));

	pthread_mutex_lock(&lock);
	fprintf(stderr, time_fmt, timestr, func, basename(strdupa(file)), line);

	va_list ap;
	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	fputc('\n', stderr);

	pthread_mutex_unlock(&lock);
}

double get_cputime() {
	struct timespec tp;
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &tp);
	return tp.tv_sec + tp.tv_nsec * 1e-9;
}

size_t get_peak_vm() {
	static size_t page_size = sysconf(_SC_PAGESIZE);
	struct rusage usage;
	getrusage(RUSAGE_SELF, &usage);
	return usage.ru_maxrss * page_size;
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

