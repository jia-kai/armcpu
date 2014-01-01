/*
 * $File: utils.hh
 * $Date: Tue Dec 17 11:52:50 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include <functional>
#include <memory>
#include <cstring>
#include <limits>

#define dassert(expr) \
	do { \
		if (!(expr)) \
			__assert_failed__(__FILE__, __func__, \
					__LINE__, # expr); \
	} while (0)


#define log_printf(fmt, ...) \
	__log_printf__(__FILE__, __func__, __LINE__, fmt, ## __VA_ARGS__)


double get_cputime();

template <typename T>
std::shared_ptr<T> create_auto_buf(size_t len, bool init_zero = false) {
	std::shared_ptr<T> ret(new T[len], [](T *ptr){delete []ptr;});
	if (init_zero)
		memset(ret.get(), 0, sizeof(T) * len);
	return ret;
}

/*!
 * \brief peak virtual memory usage
 */
size_t get_peak_vm();


// internal implementations, ignore
void __assert_failed__(const char *file, const char *func, int line,
		const char *expr);

void __log_printf__(const char *file, const char *func, int line,
		const char *fmt, ...) __attribute__((format(printf, 4, 5)));

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

