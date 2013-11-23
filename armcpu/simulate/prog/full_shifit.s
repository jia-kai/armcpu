# totally noncense program just to verify all shift instructions
# simu: 100ns 
li $a0, 8
li $a1, 1
li $a2, -24
sll $a2, $a0, 2			#a2 = 4
sllv $a2, $a0, $a1		#a2 = 8
sra $a0, $a2, 1 		#a0 = 4
srav $a0, $a2, $a1      #a0 = 1
srl $a0, $a2, 2 		#a0 = 2 
srlv $a0, $a2, $a1		#a0 = 1
halt:
	j halt
