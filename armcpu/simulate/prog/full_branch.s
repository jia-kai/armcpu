# simu: 250ns
li $a0, 0
li $a1, 1
li $a2, -1
li $k0, 0

beq $a0, $k0, l1
addiu $k0, -1
l1:
addiu $k0, 1

beq $a1, $a0, l2
addiu $k0, 1
b l3
l2:
addiu $k0, -1
l3:

bgez $a0, l4
addiu $k0, -1
l4:
addiu $k0, 1

bgez $a1, l5
addiu $k0, -1
l5:
addiu $k0, 1

bgez $a2, l7
addiu $k0, 1
b l6
l7:
addiu $k0, -1
l6:

bgtz $a0, l8
addiu $k0, 1
b l9
l8:
addiu $k0, -1
l9:

bgtz $a1, lx0
addiu $k0, -1
lx0:
addiu $k0, 1

blez $a0, l10
addiu $k0,  -1
l10:
addiu $k0, 1

blez $a1, l11
addiu $k0, 1
l11:

blez $a2, l11x
addiu $k0, -1
l11x:
addiu $k0, 1

bltz $a0, l12
addiu $k0, 1
l12:

bltz $a2, l13
addiu $k0, -1
l13:
addiu $k0, 1

bne $a0, $zero, l14
addiu $k0, 1
l14:

bne $a1, $a2, l15
addiu $k0,  -1
l15:
addiu $k0, 1

b .
nop

# vim: ft=mips
