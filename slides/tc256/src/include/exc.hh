/*
 * $File: exc.hh
 * $Date: Tue Dec 17 10:35:58 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#pragma once

#include <exception>
#include <string>

class FatalError: public std::exception {
	std::string m_msg;

	public:
		FatalError(const char *fmt, ...)
			__attribute__((format(printf, 2, 3)));

		~FatalError() throw () {}

		const char *what() const throw()
		{ return m_msg.c_str(); }
};

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

