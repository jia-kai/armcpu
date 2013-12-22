/*
 * $File: system.h
 * $Date: Sun Dec 22 12:11:05 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#ifndef __HEADER_SYSTEM__
#define __HEADER_SYSTEM__

#include "ps2_code.h"
#define CPU_FREQUENCY	12500000

typedef unsigned uint32_t;

typedef volatile unsigned* memio_ptr_t;
typedef const unsigned char* img_ptr_t;
static memio_ptr_t const
	vga_buffer = (memio_ptr_t)0xBA000000,
	com_data = (memio_ptr_t)0xBFD003F8,
	com_stat = (memio_ptr_t)0xBFD003FC,
	keyboard_data = (memio_ptr_t)0xAF000000,
	flash = (memio_ptr_t)0xBE000000;

#define VGA_ROW_SIZE	512

// some functions copy from ucore

/* compiler provides size of save area */
typedef __builtin_va_list va_list;

#define va_start(ap, last)              (__builtin_va_start(ap, last))
#define va_arg(ap, type)                (__builtin_va_arg(ap, type))
#define va_end(ap)                      /*nothing*/

#define read_c0_status()	__read_32bit_c0_register($12, 0)
#define read_c0_cause()		__read_32bit_c0_register($13, 0)
#define write_c0_status(val)	__write_32bit_c0_register($12, 0, val)

#define __read_32bit_c0_register(reg, sel)				\
({ uint32_t __res;								\
	if (sel == 0)							\
		__asm__ __volatile__(					\
			"mfc0\t%0, " #reg "\n\t"			\
			: "=r" (__res));				\
	else								\
		__asm__ __volatile__(					\
			".set\tmips32\n\t"				\
			"mfc0\t%0, " #reg ", " #sel "\n\t"		\
			".set\tmips0\n\t"				\
			: "=r" (__res));				\
	__res;								\
})

#define __write_32bit_c0_register(reg, sel, value)			\
do {									\
	if (sel == 0)							\
		__asm__ __volatile__(					\
			"mtc0\t%z0, " #reg "\n\t"			\
			: : "Jr" ((unsigned int)(value)));		\
	else								\
		__asm__ __volatile__(					\
			".set\tmips32\n\t"				\
			"mtc0\t%z0, " #reg ", " #sel "\n\t"	\
			".set\tmips0"					\
			: : "Jr" ((unsigned int)(value)));		\
} while (0)

#define read_c0_count()		__read_32bit_c0_register($9, 0)

// disable com and keyboard interrupt
static inline void disable_interrupt(uint32_t *saved_value) {
	uint32_t status = read_c0_status();
	*saved_value = status;
	status &= ~0x00005000u;
	write_c0_status(status);
}

static inline void enable_interrupt(uint32_t saved_value) {
	write_c0_status(saved_value);
}

/*
 * get cp0 count register value after specified microseconds (1e-3 s)
 */
static inline uint32_t get_count_after_msec(int micro_sec) {
	return read_c0_count() + micro_sec * (CPU_FREQUENCY / 1000);
}

#define SYSCALL_BASE            0x80
static inline int syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t arg[4];
    int i, ret;
    for (i = 0; i < 4; i ++) {
        arg[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    num += SYSCALL_BASE;

    asm volatile(
      ".set noreorder;\n"
      "move $v0, %1;\n" /* syscall no. */
      "move $a0, %2;\n"
      "move $a1, %3;\n"
      "move $a2, %4;\n"
      "move $a3, %5;\n"
      "syscall;\n"
      "nop;\n"
      "move %0, $v0;\n"
      : "=r"(ret)
      : "r"(num), "r"(arg[0]), "r"(arg[1]), "r"(arg[2]), "r"(arg[3])
      : "a0", "a1", "a2", "a3", "v0"
    );
    return ret;
}

#define SYS_exit            1
#define SYS_redraw_console		242

static inline void sys_exit(int error_code) __attribute__((noreturn));

void sys_exit(int error_code) {
    syscall(SYS_exit, error_code);
	for (; ;);	// should never get here
}

static inline void sys_redraw_console() {
	syscall(SYS_redraw_console);
}

static inline int get_key() {
	if (*com_stat & 2)
		return *com_data;
	if (!(read_c0_cause() & 0x00004000)) // ps2 int
		return 0;
	int c = *keyboard_data;
	if (c >= 0 && c < 256)
		c = KEYCODE_MAP[c];
	else
		c = 0;
	return c;
}

#endif // __HEADER_SYSTEM__
