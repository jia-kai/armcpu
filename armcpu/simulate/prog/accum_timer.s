# simu: 350ns
start:
li $a0, 10	# number of cycles to sleep
li $v0, 1
syscall	# v0 = 1 to swith from kernel mode to user mode
li $v0, 0
halt: j halt

.org start + 0x180

beq $v0, 1, setup_usermode

# timer interrupt
mfc0 $v0, $12	# monitor status
addiu $k0, 1
jal setup_timer
eret

setup_usermode:
li $k1, 0x0000FF13	# enable all interrupt and set IE, set KSU
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
