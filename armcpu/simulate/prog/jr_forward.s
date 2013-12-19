# simu: 180ns
li $gp, 0x80010000
jal f0
addiu $k0, 1
jal f1
addiu $k0, 1
jal f2
addiu $k0, 1
jal f3
addiu $k0, 1
b .

f0:
sw $ra, 0($gp)
li $ra, 0
lw $ra, 0($gp)
jr $ra

f1:
mtc0 $ra, $0
li $ra, 0
mfc0 $ra, $0
jr $ra

f2:
mtlo $ra
li $ra, 0
mflo $ra
jr $ra

f3:
move $a0, $ra
li $ra, 0
move $ra, $a0
jr $ra

# vim: ft=mips
