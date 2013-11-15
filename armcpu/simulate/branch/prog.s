.set noat
beq $1, $1, branch_out
addiu $1, $1, 1

branch_out:
addiu $2, $1, 2

# expect $1 = 1, $2 = 3
