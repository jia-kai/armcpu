/*
 * $File: slideshow.c
 * $Date: Sat Dec 14 00:22:11 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <stdio.h>
#include <file.h>
#include <syscall.h>

typedef volatile unsigned* mem_ptr_t;

#define IMAGE_WIDTH 400
#define IMAGE_HEIGHT 300
#define VGA_MEM_NRCOL 512
#define IMAGE_FLASH_PER_SIZE	(IMAGE_WIDTH * IMAGE_HEIGHT / 2)
#define IMAGE_FLASH_START	(1024 * 1024 / 2)

static mem_ptr_t const flash = (mem_ptr_t)0xBE000000;
static mem_ptr_t const vga = (mem_ptr_t)0xBA000000;

static void display_image(mem_ptr_t base) {
	int i, j;
	mem_ptr_t dest = vga;
	for (i = 0; i < IMAGE_HEIGHT; i ++) {
		for (j = 0; j < IMAGE_WIDTH; j += 2) {
			unsigned v = *base;
			*(dest ++) = v;
			*(dest ++) = v >> 8;
			base ++;
		}
		dest += VGA_MEM_NRCOL - IMAGE_WIDTH;
	}
}

int main() {
	sys_set_cons_sync_vga(0);
	mem_ptr_t addr = flash + IMAGE_FLASH_START;
	int num = 0;
	for (; ;) {
		cprintf("slide: %d addr=%p\n", num, addr);
		display_image(addr);
		char ch;
		int ret = read(0, &ch, sizeof(char));
		if (ret != 1 || ch == 'q') {
			sys_set_cons_sync_vga(1);
			sys_redraw_console();
			return 0;
		}
		if (ch == 'n') {
			addr += IMAGE_FLASH_PER_SIZE;
			num ++;
		}
		if (ch == 'N') {
			addr -= IMAGE_FLASH_PER_SIZE;
			num --;
		}
	}
}

