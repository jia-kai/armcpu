/*
 * $File: mult.cc
 * $Date: Sat Nov 23 21:08:33 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

#include <stdint.h>

const char COM_STAT_READ = 2, COM_STAT_WRITE = 1;
typedef uint32_t * volatile hw_ptr_t;

// use class to git rid of global variables

class Main {
	static const uint8_t 
		CMD_FLASH_WRITE	= 0b01110000,
		CMD_FLASH_READ	= 0b00001111,
		CMD_FLASH_ERASE	= 0b00111000,
		CMD_RAM_WRITE	= 0b11110011,
		CMD_RAM_READ	= 0b10010011,
		CMD_ERASE_IN_PROGRESS	= 0b11001100,
		CMD_ERASE_FINISHED		= 0b00110011;

	hw_ptr_t m_com_data, m_com_stat, m_segdisp, m_flash_start, m_ram_start;

	uint8_t read_com_byte() {
		while (!(*m_com_stat & COM_STAT_READ));
		uint8_t rst = *m_com_data;
		return rst;
	}

	uint32_t read_com_word(int size) {
		uint32_t rst = 0;
		for (int i = 0; i < size; i ++)
			rst |= ((uint32_t)read_com_byte()) << (i * 8);
		return rst;
	}

	void write_com_byte(uint8_t data) {
		while (!(*m_com_stat & COM_STAT_WRITE));
		*m_com_data = data;
	}

	void write_com_uint32(uint32_t data) {
		write_com_byte(data);
		write_com_byte(data >> 8);
		write_com_byte(data >> 16);
		write_com_byte(data >> 24);
	}

	void init() {
		m_com_data = (hw_ptr_t)0x9FD003F8;
		m_com_stat = (hw_ptr_t)0x9FD003FC;
		m_segdisp = (hw_ptr_t)0x9FD00400;
		m_flash_start = (hw_ptr_t)0x9E000000;
		m_ram_start = (hw_ptr_t)0x80000000;
	}

	void write_segdisp(uint32_t data) {
		*m_segdisp = data;
	}

	public:
		void main() {
			asm volatile ("li $sp, 0x80001000");
			asm volatile ("li $a0, 0x80004000");	// this

			init();

			for (; ;) {
				int32_t a, b;
				a = read_com_word(4);
				write_segdisp(a);
				b = read_com_word(4);
				write_segdisp(b);
				int64_t r = (int64_t)a * b;
				write_com_uint32(r);
				write_com_uint32(r >> 32);
				write_segdisp(r);
			}
		}
};

void run() {
	Main m;
	m.main();
}

