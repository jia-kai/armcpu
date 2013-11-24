li $gp, 0xBE000000	# flash
li $k0, 0xBFD00400	# segdisp

li $v0, 0x00FF
sw $v0, 0($gp)
run:
lbu $v0, 0($gp)
sw $v0, 0($k0)
addiu $gp, 1

b run

# vim: ft=mips
