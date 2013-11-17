# simu: 50000ns
# calc f(n, m) = f(n - 1, m - 1) + f(n - 1, m)
# compile with gcc, -O0
j main
nop

f:
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	sw	$16,20($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	sw	$5,36($fp)
	lw	$3,32($fp)
	lw	$2,36($fp)
	slt	$2,$3,$2
	beq	$2,$0,.L2
	nop

	move	$2,$0
	b	.L3
	nop

.L2:
	lw	$2,32($fp)
	beq	$2,$0,.L4
	nop

	lw	$2,36($fp)
	bne	$2,$0,.L5
	nop

.L4:
	li	$2,1			# 0x1
	b	.L3
	nop

.L5:
	lw	$2,32($fp)
	addiu	$3,$2,-1
	lw	$2,36($fp)
	addiu	$2,$2,-1
	move	$4,$3
	move	$5,$2
	jal	f
	nop

	move	$16,$2
	lw	$2,32($fp)
	addiu	$2,$2,-1
	move	$4,$2
	lw	$5,36($fp)
	jal	f
	nop

	addu	$2,$16,$2
.L3:
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	lw	$16,20($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.set	macro
	.set	reorder

main:
	li $sp, 512 * 1024
	move $fp, $sp

	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	li	$4,5			# n
	li	$5,2			# m
	jal	f

	addu $k0, $k0, $v0
	j main
