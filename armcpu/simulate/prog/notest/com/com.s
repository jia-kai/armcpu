# simu: 300ns
start:
li $k1, 0x00001001	# set IE and IM[com]
mtc0 $k1, $12

halt: j halt

.org start + 0x180
li $gp, 0xBFD003F8
lw $k0, 0($gp)
addiu $k0, 1
sw $k0, 0($gp)
eret
nop
nop

# vim: ft=mips
