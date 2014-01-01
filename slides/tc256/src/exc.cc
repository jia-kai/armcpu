/*
 * $File: exc.cc
 * $Date: Tue Dec 17 10:36:36 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "exc.hh"

#include <cstdlib>
#include <cstdio>
#include <cstdarg>

FatalError::FatalError(const char *fmt, ...): m_msg("FatalError: ")
{
	int size = 128;
	char *p, *np;

	if ((p = (char*)malloc(size)) == NULL)
	{
		m_msg = "error while malloc";
		return;
	}

	for (; ;)
	{
		va_list ap;
		va_start(ap, fmt);
		int n = vsnprintf(p, size, fmt, ap);
		va_end(ap);

		if (n > -1 && n < size)
		{
			m_msg.append(p);
			break;
		}
		if (n > -1)		/* glibc 2.1 */
			size = n+1;	/* precisely what is needed */
		else			/* glibc 2.0 */
			size *= 2;	/* twice the old size */

		if ((np = (char*)realloc(p, size)) == NULL)
		{
			m_msg = "error while malloc";
			break;
		} else
			p = np;
	}
	free(p);
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}
