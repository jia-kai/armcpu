/*
 * $File: slideshow.c
 * $Date: Sun Dec 22 12:17:31 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include "system.h"

#define IMAGE_WIDTH 400
#define IMAGE_HEIGHT 300
#define IMAGE_FLASH_PER_SIZE	(IMAGE_WIDTH * IMAGE_HEIGHT / 2)
#define IMAGE_FLASH_START	(1024 * 1024 / 2)
#define ANIMATION_SPEED 50

static uint32_t saved_cp0_satus;

static void display_image(memio_ptr_t base) {
	int i, j;
	memio_ptr_t dest = vga_buffer;
	for (i = 0; i < IMAGE_HEIGHT; i ++) {
		for (j = 0; j < IMAGE_WIDTH; j += 2) {
			unsigned v = *base;
			*(dest ++) = v;
			*(dest ++) = v >> 8;
			base ++;
		}
		dest += VGA_ROW_SIZE - IMAGE_WIDTH;
	}
}

void _start() {
	disable_interrupt(&saved_cp0_satus);
	memio_ptr_t addr = flash + IMAGE_FLASH_START;
	int num = 0;
	for (; ;) {
		display_image(addr);
		char ch = 0;
		while (!ch)
			ch = get_key();
		if (ch == 'q') {
			enable_interrupt(saved_cp0_satus);
			sys_redraw_console();
			sys_exit(0);
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

