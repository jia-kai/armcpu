# simu: 350ns
# kbd: 50
li $k0, 0xBFD00400	# segdisp
li $gp, 0xAF000000	# keyboard

li $v0, 1
syscall	# v0 = 1 to swith from kernel mode to user mode
li $v0, 0
halt:
li $v1, 0x23
sw $v1, 0($k0)
b halt

.org 0x180

beq $v0, 1, setup_usermode

# interrupt handler
lw $v0, 0($gp)
sw $v0, 0($k0)
eret

setup_usermode:
li $k1, 0x00007F13	# enable interrupt except timer, set IE, set KSU
mtc0 $k1, $12	# status
mfc0 $k1, $14	# epc
addiu $k1, 4
mtc0 $k1, $14
eret

# vim: ft=mips
