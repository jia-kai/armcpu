//
// $File: memtrans.s
// $Date: Mon Nov 25 09:23:43 2013 +0800
// $Author: Xinyu Zhou <zxytim@gmail.com>
//

// Assembly implementation of memtrans.cc

// t0: m_com_data = (hw_ptr_t)0x9FD003F8;
// t1: m_com_stat = (hw_ptr_t)0x9FD003FC;
// t2: m_segdisp = (hw_ptr_t)0x9FD00400;
// t3: m_flash_start = (hw_ptr_t)0x9E000000;
// t4: m_ram_start = (hw_ptr_t)0x80000000;
// t9: m_checksum

// subroutine calling convention:
//	param: $a0 or none, param may be modified
//	retval: $v0
// $a1~$a3 would not be modified
// $t5~8 may be modified

#define COM_DATA	t0
#define COM_STAT	t1
#define CHECKSUM	t9
#define SEGDISP		t2
#define RAM_START	t4

#define CMD_FLASH_WRITE	0b01110000
#define CMD_FLASH_READ	0b00001111
#define CMD_FLASH_ERASE	0b00111000
#define CMD_RAM_WRITE	0b11110011
#define CMD_RAM_READ	0b10010011
#define CMD_ERASE_IN_PROGRESS	0b11001100
#define CMD_ERASE_FINISHED		0b00110011
#define RESET_CHECKSUM()	li $CHECKSUM, 0x23



main:
	jal init

	main_loop:
		sw $zero, 0($SEGDISP)
		jal read_com_byte
		move $a1, $v0 // a1: cmd
		sw $a1, 0($SEGDISP)
		RESET_CHECKSUM()

		li $a0, 3
		jal read_com_word
		li $a0, 3
		move $a2, $v0 // a2: start
		jal read_com_word
		move $a3, $v0 // a3: end

		// write_com_byte(m_checksum)
		move $a0, $CHECKSUM
		jal write_com_byte

		RESET_CHECKSUM()

		sll $a2, 2
		sll $a3, 2
		addu $a2, $RAM_START
		addu $a3, $RAM_START

		// v0 is cases switches
		li $v0, CMD_RAM_WRITE
		beq $a1, $v0, ram_write
		li $v0, CMD_RAM_READ
		beq $a1, $v0, ram_read
		b cmd_end

		// a0, a1 are reusable from now on
		// a2: m_ram_start + start
		// a3: m_ram_start + end

		ram_write:
			beq $a2, $a3, cmd_end
			li $a0, 4
			jal read_com_word
			sw $v0, 0($a2)
			addiu $a2, $a2, 4
			b ram_write

		ram_read:
			beq $a2, $a3, cmd_end
			lw $a1, 0($a2) // a0 grabs the data
			move $a0, $a1
			jal write_com_byte
			srl $a0, $a1, 8
			jal write_com_byte
			srl $a0, $a1, 16
			jal write_com_byte
			srl $a0, $a1, 24
			jal write_com_byte
			addiu $a2, $a2, 4

			b ram_read

		cmd_end:
			// write checksum
			move $a0, $CHECKSUM
			jal write_com_byte

		b main_loop


init:
	li $COM_DATA, 0x9FD003F8
	li $COM_STAT, 0x9FD003FC 
	li $SEGDISP, 0x9FD00400
	li $t3, 0x9E000000
	li $RAM_START, 0x80000000 // m_ram_start

	jr $ra

read_com_byte:
	// XXX: DIRTY HACK
	// use v1 and sp for register backup
	move $v1, $a0
	move $sp, $a1

	// while (!(*m_com_stat & COM_STAT_READ));
	read_com_byte_wait_loop:
		lw $a0, 0($COM_STAT)
		andi $a0, 0x2
		beqz $a0, read_com_byte_wait_loop

	// uint8_t rst = *m_com_data;
	lw $v0, 0($COM_DATA)
	// m_checksum ^= rst;
	xor $CHECKSUM, $CHECKSUM, $v0
	// return rst;

	move $a0, $v1
	move $a1, $sp
	jr $ra


// param: $a0: size
read_com_word:
	move $t8, $ra

	li $t7, 0 // temporal retval
	li $t6, 0 // i * 8
	sll $a0, 3
	read_com_word_read_byte_loop:
		//for (int i = 0; i < size; i ++)
		//	rst |= ((uint32_t)read_com_byte()) << (i * 8);
		//return rst;
		jal read_com_byte
		sllv $v0, $v0, $t6 
		or $t7, $v0  
		addiu $t6, 8
		bne $t6, $a0, read_com_word_read_byte_loop

	move $ra, $t8
	move $v0, $t7
	jr $ra


// param: $a0, byte to write, only lowest 8 bit is effective
write_com_byte:
	// while (!(*m_com_stat & COM_STAT_WRITE));
	write_com_byte_wait_loop:
		lw $t5, 0($COM_STAT)
		andi $t5, 0x1
		beqz $t5, write_com_byte_wait_loop

	sw $a0, 0($COM_DATA)
	xor $CHECKSUM, $CHECKSUM, $a0

	jr $ra

// vim: ft=mips
