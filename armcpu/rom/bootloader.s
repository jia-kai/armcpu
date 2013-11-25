/* 
  Bootloader for MIPS32S
  Chen Yuheng
  2012/07/16

  edited by jiakai
 */

#define DISPVAL_DONE 0x0023
#define DISPVAL_BAD 0x00EE
#define DISPVAL_KRNRET 0x00EF

#define FLASH_START s0
#define FLASH_START_ADDR 0xBE000000
#define SEGDISP		a0
#define SEGDISP_ADDR 0xBFD00400
#define ELF_MAGIC 0x464C457F

/* off = offset from FLASH_START */
/* load a 32bit word from Flash, 
 * off is byte-addressed */
#define LOAD_WORD_I(dst, off) \
  li $t7, (off) << 1; \
  addu $t7, $FLASH_START, $t7; \
  lw dst, 0($t7); \
  lw $t7, 4($t7); \
  sll $t7, $t7, 16; \
  or dst, dst, $t7

#define LOAD_WORD_R(dst, off, base) \
  addiu $t7, base, off;\
  sll  $t7, $t7, 1; \
  addu $t7, $FLASH_START, $t7; \
  lw dst, 0($t7); \
  lw $t7, 4($t7); \
  sll $t7, $t7, 16; \
  or dst, dst, $t7;
   
# assume elf file base == FLASH_START

#addr of elfheader, FLASH_START
li $FLASH_START, FLASH_START_ADDR
li $SEGDISP, SEGDISP_ADDR
li $v0, 0x00FF
sw $v0, 0($FLASH_START)
#e_magic
LOAD_WORD_I($t1, 0)
li $t0, ELF_MAGIC
beq $t0, $t1, 1f
b bad
1:
	LOAD_WORD_I($s1, 28) # e_phoff
	LOAD_WORD_I($s2, 44) # e_phnum
	andi $s2, $s2, 0xFFFF
	LOAD_WORD_I($s3, 24) # e_entry

next_sec:
	#s1, addr proghdr
	#s4, p_va
	LOAD_WORD_R($s4, 8, $s1)
	#s5, p_filesz
	LOAD_WORD_R($s5, 16, $s1)
	#s6, p_offset
	LOAD_WORD_R($s6, 4, $s1)

	beq  $s4, $zero, 3f
	beq  $s5, $zero, 3f

#copy from file_base+p_offset to p_va
copy_sec:
	sw $s6, 0($SEGDISP)
	LOAD_WORD_R($t0, 0, $s6)
	sw $t0, 0($s4)
	addiu $s6, $s6, 4
	addiu $s4, $s4, 4
	addiu $s5, $s5, -4
	bgtz  $s5, copy_sec

3:
	addiu $s1, $s1, 32
	addiu $s2, $s2, -1
	bgtz  $s2, next_sec

done:
	li $v0, DISPVAL_DONE
	sw $v0, 0($SEGDISP)
#jump to kernel
	jr $s3

kernel_ret:
	li $SEGDISP, SEGDISP_ADDR
	li $v0, DISPVAL_KRNRET
	sw $v0, 0($SEGDISP)
	b kernel_ret

bad:
	li $SEGDISP, SEGDISP_ADDR
	li $v0, DISPVAL_BAD
	sw $v0, 0($SEGDISP)
	b bad 

# vim: ft=mips
