# simu: 500ns
start:
li $v1, 1
syscall
syscall	# should be skipped by syscall handler
li $v1, 0
move $k0, $v0
b start

.org start + 0x180
addu $v0, $v1
mfc0 $k1, $14
addu $k1, 8	# skip the next instruction; test for precise exception
mtc0 $k1, $14
eret		# eret immediately after updating epc
nop
nop
nop
nop

# vim: ft=mips
