# simu: 200ns
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

li $v1, 0xffffff01
sb $v1, 2($gp)
sb $v1, 0($gp)
sb $v1, 1($gp)
sb $v1, 3($gp)

halt: b halt

# vim: ft=mips
