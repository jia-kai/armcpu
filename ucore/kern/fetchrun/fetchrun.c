/*
 * $File: fetchrun.c
 * $Date: Thu Nov 28 04:28:59 2013 +0800
 * $Author: Xinyu Zhou <zxytim[at]gmail[dot]com>
 */

#include <defs.h>
#include <thumips.h>
#include <intr.h>
#include <fetchrun.h>
#include <file.h>
#include <stdio.h>
#include <kmalloc.h>

static const uint32_t COM_DATA = COM1;
static const uint32_t COM_STAT = COM1 + 4;
static const uint32_t CHECKSUM_INIT = 0x23;
static const uint32_t FETCH_MAGIC = 'r';

static uint32_t checksum;

static void reset_checksum() {
	checksum = CHECKSUM_INIT;
}

static void wait_until_read_ready() {
	for (; ;) {
		int flag = inw(COM_STAT) & 0x2;
		if (flag != 0)
			break;
	}
}

static void wait_until_write_ready() {
	for (; ;) {
		int flag = inw(COM_STAT) & 0x1;
		if (flag != 0)
			break;
	}
}

static uint32_t write_byte(uint32_t data) {
	wait_until_write_ready();
	data &= 0xFF;
	outw(COM_DATA, data);
}

static uint32_t write_word(uint32_t data) {
	int i;
	for (i = 0; i < 4; i ++)
		write_byte((data >> (i * 8)) & 0xFF);
}


static uint32_t read_byte() {
	wait_until_read_ready();
	uint32_t data = inw(COM_DATA);
	checksum ^= data;
	return data;
}

static uint32_t read_word() {
	uint32_t ret = 0;
	int i;
	for (i = 0; i < 4; i ++) {
		ret += read_byte() * (1 << (i * 8));
	}
	return ret;
}


/**
 * fetch a program from serial buf and write to file fd
 * protocol:
 *	c -> s 2 byte: FETCH_MAGIC + 0
 *	s -> c 4 byte:	size
 *	c -> s 1 byte: checksum
 *	s -> c size byte: data
 *	c -> s 1 byte: checksum
 *	c -> s 4 byte: retval of file_write
 *
 * return: size
 *
 * WARNING: DO NOT use something like printf here because the string printed
 *		to stdout will be redirect to serial bus
 */
int fetchrun(int fd) {

	bool intr_flag;
	local_intr_save(intr_flag);
	{
		write_byte(FETCH_MAGIC);
		write_byte(0);
		// read size
		reset_checksum();
		uint32_t size = read_word();
		char *buf = kmalloc(size);
		write_byte(checksum); // act as synchronizer(barrier) to make time for kmalloc
		reset_checksum();
		uint32_t i;
		for (i = 0; i < size; i ++) {
			uint32_t byte = read_byte();
			buf[i] = byte;
		}
		write_byte(checksum);
		int ret = file_write(fd, buf, size, &size);
		write_word(ret);

		kfree(buf);
	}
	local_intr_restore(intr_flag);
}


/**
 * vim: foldmethod=marker
 */

