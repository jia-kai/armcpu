# simu: 550ns
# accumulator based on timer, syscall and memory access
start:
li $gp, 0x80010000
li $sp, 0x9FD00400	# segdisp
sw $zero, 0($gp)
li $a0, 10	# number of cycles to sleep
li $v0, 1
syscall	# v0 = 1 to swith from kernel mode to user mode
li $v0, 0
halt: j halt

.org start + 0x180

beq $v0, 1, setup_usermode

# timer interrupt
lw $k1, 0($gp)
addiu $k1, 1
sw $k1, 0($gp)
sw $k1, 0($sp)
li $k1, 0
jal setup_timer
eret

setup_usermode:
li $k1, 0x00008013	# enable timer interrupt and set IE, set KSU
mtc0 $k1, $12	# status
mfc0 $k1, $14	# epc
addiu $k1, 4
mtc0 $k1, $14
jal setup_timer
eret

setup_timer:
mfc0 $k1, $9	# count
addu $k1, $a0
mtc0 $k1, $11	# compare
jr $ra

# vim: ft=mips
