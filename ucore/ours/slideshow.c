/*
 * $File: slideshow.c
 * $Date: Fri Dec 20 20:19:10 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <file.h>
#include <syscall.h>

typedef volatile unsigned* mem_ptr_t;

#define IMAGE_WIDTH 400
#define IMAGE_HEIGHT 300
#define VGA_MEM_NRCOL 512
#define IMAGE_FLASH_PER_SIZE	(IMAGE_WIDTH * IMAGE_HEIGHT / 2)
#define IMAGE_FLASH_START	(1024 * 1024 / 2)
#define ANIMATION_SPEED 50

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
	mem_ptr_t addr = flash + IMAGE_FLASH_START;
	int num = 0;
	for (; ;) {
		display_image(addr);
		char ch;
		int ret = read(0, &ch, sizeof(char));
		if (ret != 1 || ch == 'q') {
			sys_redraw_console();
			return 0;
		}
		int i;
		if (ch == 'n') {
			for (i = 0; i < IMAGE_HEIGHT / ANIMATION_SPEED; i ++) {
				addr += IMAGE_WIDTH / 2 * ANIMATION_SPEED;
				display_image(addr);
			}
			num ++;
		}
		if (ch == 'N') {
			for (i = 0; i < IMAGE_HEIGHT / ANIMATION_SPEED; i ++) {
				addr -= IMAGE_WIDTH / 2 * ANIMATION_SPEED;
				display_image(addr);
			}
			num --;
		}
	}
}

