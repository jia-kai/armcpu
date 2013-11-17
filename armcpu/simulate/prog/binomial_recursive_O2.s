# simu: 50000ns
# calc f(n, m) = f(n - 1, m - 1) + f(n - 1, m)
# compile with gcc, -O2
j main
nop

f:
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	slt	$2,$4,$5
	sw	$31,36($sp)
	sw	$19,32($sp)
	sw	$18,28($sp)
	sw	$17,24($sp)
	bne	$2,$0,.L5
	sw	$16,20($sp)

	beq	$4,$0,.L7
	nop

	beq	$5,$0,.L7
	move	$16,$4

	move	$18,$5
	addiu	$19,$5,-1
	b	.L3
	move	$17,$0

.L4:
	beq	$16,$0,.L11
	lw	$31,36($sp)

.L3:
	addiu	$16,$16,-1
	move	$4,$16
	jal	f
	move	$5,$19

	slt	$3,$16,$18
	beq	$3,$0,.L4
	addu	$17,$17,$2

.L2:
	lw	$31,36($sp)
	move	$2,$17
	lw	$19,32($sp)
	lw	$18,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	j	$31
	addiu	$sp,$sp,40

.L11:
	addiu	$17,$17,1
	move	$2,$17
	lw	$19,32($sp)
	lw	$18,28($sp)
	lw	$17,24($sp)
	lw	$16,20($sp)
	j	$31
	addiu	$sp,$sp,40

.L7:
	b	.L2
	li	$17,1			# 0x1

.L5:
	b	.L2
	move	$17,$0

	.set	macro
	.set	reorder


main:
	li $sp, 4 * 1024 * 1024 + 40
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
