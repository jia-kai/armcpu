# simu: 400ns
li $gp, 5 * 1024 * 1024 + 0x80000000
li $v0, 0x19931102
sw $v0, 0($gp)

lb $a0, 0($gp)	# 0x02
lb $a0, 1($gp)	# 0x11
lb $a0, 2($gp)	# 0xffffff93
lb $a0, 3($gp)	# 0x19

lbu $a0, 0($gp)
lbu $a0, 1($gp)
lbu $a0, 2($gp)
lbu $a0, 3($gp)

lhu $a0, 0($gp)
lhu $a0, 2($gp)

li $v1, 0xffffff01
sb $v1, 2($gp)
sb $v1, 0($gp)
sb $v1, 1($gp)
sb $v1, 3($gp)

li $v0, 0
sb $v0, 0($gp)
li $v0, 1
sb $v0, 1($gp)
li $v0, 2
sb $v0, 2($gp)
li $v0, 3
sb $v0, 3($gp)
li $v0, 4
sb $v0, 4($gp)
li $v0, 5
sb $v0, 5($gp)

lhu $a0, 1($gp)	# exception

halt: b halt

# vim: ft=mips
