# simu: 200ns
li $a0, 0x80000100	# $a0 = 0x80000100
li $a1, 0x19931102	# $a1 = 0x19930000, 0x19931102
sw $a1, 0($a0)		# store after alu
lw $a2, 0($a0)		# $a2 = 0x19931102 read mem after write
move $v1, $a0		# $v1 = 0x80000100
lw $a0, 0($v1)		# $a0 = 0x19931102 load from addr from forwarded alu
move $a2, $v1		# $a2 = 0x80000100
lw $a2, 0($a2)		# $a2 = 0x19931102
j label				# assembler should reorder, cuasing load in delay slot
li $a2, 0
label:
lw $a3, 0($v1)		# $a3 = 0x19931102
lw $v1, 0($v1)		# $v1 = 0x19931102
addu $a2, $v1, $a3	# $a2 = 0x33262204 forward load result to alu
li $a0, 0x80000100	# $a0 = 0x80000100
li $a1, 0x80000200	# $a1 = 0x80000200
sw $a0, 0($a1)
lw $a1, 0($a1)		# $a1 = 0x80000100
lw $a1, 0($a1)		# $a1 = 0x19931102
move $v0, $a1		# $v0 = 0x19931102 load from load result
halt:
j halt
