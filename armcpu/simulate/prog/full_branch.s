# totally noncense program just to verify all branch instructions 
li $a0, 0
li $a1, 1
li $a2, -1
#beq $zero, $a0, label_beq

#label_beq:
#	bgez $a1, label_bgez
	
#label_bgez:
#	bgtz $a1, label_bgtz
	
blez $a2, correct
	
#bltz $a2, correct
	
#label_bltz:
#	bne $zero, $a1, label_bne
	
#label_bne:
#	j halt

halt:
	j halt

nop
nop
nop
nop
correct:
	li $a3, 1