# totally noncense program just to verify all arithmetic instructions
li $a0, 1 
li $a1, 1
addu $a3, $a0, $a1      #a3 = 2
li $a2, 4
subu $a3, $a2, $a1      #a3 = 3 
addiu $a1, $a1, 1       #a1 = 2
#mult $a2, $a3           #4 * 3 = 12
#mflo $a0                #a0 = 12
#mfhi $a1				#a1 = 0
slt $a2, $a0, $a3       #a2 = 0
slti $a1, $a0, 14       #a1 = 1
subu $a2, $a1, $a3    	#a2 = -3
sltiu $a1, $a0, -1  	#a1 = 1
sltu $a2, $a0, $a3		#a2 = 1
li $a0, 6				
#mtlo $a0				#lo = 6
li $a1, 7
#mthi $a1				#hi = 7

halt:
	j halt