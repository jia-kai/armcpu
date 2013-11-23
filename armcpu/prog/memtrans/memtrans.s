#
# $File: memtrans.s
# $Date: Sun Nov 24 01:22:12 2013 +0800
# $Author: Xinyu Zhou <zxytim@gmail.com>
#

# Assembly implementation of memtrans.cc

# t0: m_com_data = (hw_ptr_t)0x9FD003F8;
# t1: m_com_stat = (hw_ptr_t)0x9FD003FC;
# t2: m_segdisp = (hw_ptr_t)0x9FD00400;
# t3: m_flash_start = (hw_ptr_t)0x9E000000;
# t4: m_ram_start = (hw_ptr_t)0x80000000;
# t9: m_checksum

# subroutine calling convention:
#	param: $a0 or none, param given not preserve
#	retval: $v0
# and save all used registers using $t5~8

main:
	jal init

	main_loop:
		jal read_com_byte
		move $a1, $v0 # a1: cmd
		li $t9, 0x23  # reset checksum

		li $a0, 3
		jal read_com_word
		move $a2, $v0 # a2: start
		jal read_com_word
		move $a3, $v0 # a3: end

		# write_com_byte(m_checksum)
		move $a0, $t9
		jal write_com_byte

		li $t9, 0x23 # reset checksum

		# v0 is cases switches
		li $v0, 243
		beq $a1, $v0, ram_write
		li $v0, 147
		beq $a1, $v0, ram_read
		j cmd_end

		addu $a2, $a2, $t4
		addu $a3, $a3, $t4
		# a0, a1 are available here
		# a2: m_ram_start + start
		# a3: m_ram_start + end

		ram_write:
			beq $a2, $a3, cmd_end
			li $a0, 4
			jal read_com_word
			sw $v0, 0($a2)
			addiu $a2, $a2, 4
			j ram_write

		ram_read:
			beq $a2, $a3, cmd_end
			lw $a0, 0($a2) # a0 grabs the data
			jal write_com_byte
			srl $a0, $a0, 8
			jal write_com_byte
			srl $a0, $a0, 8
			jal write_com_byte
			srl $a0, $a0, 8
			jal write_com_byte
			addiu $a2, $a2, 4

			j ram_read

		cmd_end:
			# write checksum
			move $a0, $t9
			jal write_com_byte

		j main_loop


init:
	li $sp, 0x80001000

	li $t0, 0x9FD003F8 # m_com_data
	li $t1, 0x9FD003FC # m_com_stat
	li $t2, 0x9FD00400 # m_segdisp
	li $t3, 0x9E000000 # m_flash_start
	li $t4, 0x80000000 # m_ram_start

	jr $ra

write_segdisp:
	sw $a0, 0($t2)
	jr $ra

read_com_byte:
	# XXX: DIRTY HACK
	# use v1 and sp for register backup
	move $v1, $a0
	move $sp, $a1

	# while (!(*m_com_stat & COM_STAT_READ));
	read_com_byte_wait_loop:
		lw $a0, 0($t1)
		li $a1, 0x2
		and $a0, $a0, $a1
		bne $a0, $a1, read_com_byte_wait_loop

	# uint8_t rst = *m_com_data;
	lbu $v0, 0($t0)
	# m_checksum ^= rst;
	xor $t9, $t9, $v0
	# return rst;

	move $a0, $v1
	move $a1, $sp
	jr $ra


# param: $a0: size
read_com_word:
	move $t5, $a1
	move $t6, $a2
	move $t7, $a3
	move $t8, $ra

	li $a3, 0 # temporal retval
	li $a1, 0 # loop variable
	li $a2, 0 # $a1 * 8
	read_com_word_read_byte_loop:
		#for (int i = 0; i < size; i ++)
		#	rst |= ((uint32_t)read_com_byte()) << (i * 8);
		#return rst;
		jal read_com_byte # v0 grabs the byte
		sllv $v0, $v0, $a2 # v0 = v0 << a2
		or $a0, $a0, $v0   # a0 |= v0
		addi $a2, $a2, 8   # a2 += 8
		addi $a1, $a1, 1   # a1 += 1
		bne $a1, $a0, read_com_word_read_byte_loop

	move $a1, $t5
	move $a2, $t6
	move $a3, $t7
	move $ra, $t8

	move $v0, $a0

	jr $ra


# param: $a0, byte to write, only lowest 8 bit is effective
write_com_byte:
	move $t0, $a1
	move $t1, $a2

	# while (!(*m_com_stat & COM_STAT_WRITE));
	write_com_byte_wait_loop:
		lw $a2, 0($t1)
		li $a1, 0x1
		and $a2, $a2, $a1
		bne $a2, $a1, write_com_byte_wait_loop

	sb $a0, 0($t0)
	xor $t9, $t9, $a0

	move $a1, $t0
	move $a2, $t1

	jr $ra

# vim: ft=mips
