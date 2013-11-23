/*
 * $File: memtrans.cc
 * $Date: Sat Nov 23 22:04:34 2013 +0800
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

	uint8_t m_checksum;

	void reset_checksum() {
		m_checksum = 0x23;
	}
	
	uint8_t read_com_byte() {
		while (!(*m_com_stat & COM_STAT_READ));
		uint8_t rst = *m_com_data;
		m_checksum ^= rst;
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
		m_checksum ^= data;
	}

	uint32_t read_addr() {
		return read_com_word(3);
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

	int flash_check_finished() {
		m_flash_start[0] = 0x0070;
		return (m_flash_start[0] >> 7) & 1;
	}

	public:
		void main() {
			asm volatile ("li $sp, 0x80010000");
			asm volatile ("li $a0, 0x80020000");	// this

			init();

			uint8_t cmd;
			for (; ; ) {
				write_segdisp(0);
				cmd = read_com_byte();
				write_segdisp(cmd);
				reset_checksum();
				uint32_t start = read_addr(),
						 end = read_addr();
				write_com_byte(m_checksum);
				reset_checksum();
				switch (cmd) {
					case CMD_RAM_WRITE:
						for (uint32_t i = start; i < end; i ++) {
							uint32_t data = read_com_word(4);
							m_ram_start[i] = data;
						}
						break;
					case CMD_RAM_READ:
						for (uint32_t i = start; i < end; i ++) {
							uint32_t data = m_ram_start[i];
							write_com_byte(data);
							write_com_byte(data >> 8);
							write_com_byte(data >> 16);
							write_com_byte(data >> 24);
						}
						break;
					case CMD_FLASH_READ:
						m_flash_start[0] = 0x00FF;
						for (uint32_t i = start; i < end; i ++) {
							uint32_t data = m_flash_start[i];
							write_com_byte(data);
							write_com_byte(data >> 8);
						}
						break;
					case CMD_FLASH_WRITE:
						for (uint32_t i = start; i < end; i ++) {
							uint32_t data = read_com_word(2);
							m_flash_start[0] = 0x0020;
							m_flash_start[i] = data;
							while (!flash_check_finished());
						}
						break;
					case CMD_FLASH_ERASE:
						m_flash_start[0] = 0x0020;
						m_flash_start[start] = 0x00D0;
						while (!flash_check_finished())
							write_com_byte(CMD_ERASE_IN_PROGRESS);
						write_com_byte(CMD_ERASE_FINISHED);
						break;
				}
				write_com_byte(m_checksum);
			}
		}
};

void run() {
	Main m;
	m.main();
}

