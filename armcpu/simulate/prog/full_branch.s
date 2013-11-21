# totally noncense program just to verify all branch instructions 
li $a0, 0
li $a1, 1
li $a2, -1
beq $zero, $a0, label_beq
nop

label_beq:
	bgez $a1, label_bgez
	nop

label_bgez:
	bgtz $a1, label_bgtz
	nop

label_bgtz:
	blez $a0, label_blez
	nop

label_blez:
	bltz $a2, label_bltz
	nop

label_bltz:
	bne $zero, $a1, label_bne
	nop

label_bne:
	j halt

halt:
	j halt