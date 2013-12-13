#ifndef __KERN_DRIVER_CONSOLE_H__
#define __KERN_DRIVER_CONSOLE_H__

void cons_init(void);
void cons_putc(int c);
int cons_getc(void);
void serial_intr(void);

void set_cons_sync_vga(int flag);

#endif /* !__KERN_DRIVER_CONSOLE_H__ */

