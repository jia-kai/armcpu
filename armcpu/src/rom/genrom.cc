/*
 * $File: genrom.cc
 * $Date: Sat Nov 23 22:38:39 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <cstdio>
#include <cassert>
#include <stdint.h>

int main(int argc, char **argv) {
	if (argc != 3) {
		fprintf(stderr, "usage: %s <bin file> <.v file>\n", argv[0]);
		return -1;
	}
	FILE *fin = fopen(argv[1], "rb");
	FILE *fout = fopen(argv[2], "w");
	assert(fin && fout);
	fprintf(fout, "case (rom_addr)\n");
	for (int addr = 0; ; addr += 4) {
		uint32_t v;
		if (fread(&v, 4, 1, fin) != 1)
			break;
		fprintf(fout, "%d: rom_data = 32'h%.8x;\n", addr, v);
	}
	fprintf(fout, "default: rom_data = 0;\n");
	fprintf(fout, "endcase\n");
	fclose(fin);
	fclose(fout);
}

// vim: syntax=cpp11.doxygen foldmethod=marker foldmarker=f{{{,f}}}

