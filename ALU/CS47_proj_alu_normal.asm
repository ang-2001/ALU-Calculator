.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	# Caller RTE store
	# save fp, ra
	addi	$sp, $sp, -12
	sw	$fp, 12($sp)
	sw	$ra, 8($sp)
	addi	$fp, $sp, 12
	
	# check for operations
	beq	$a2, '+', add_normal	# addition
	beq	$a2, '-', sub_normal 	# subtraction
	beq	$a2, '*', mul_normal	# multiplication
	beq	$a2, '/', div_normal	# division 
	j	exit			# invalid operation in $a2
	
add_normal:
	add 	$v0, $a0, $a1		# Addition, $v0 = $a0 + $a1
	j	exit 
sub_normal:
	sub	$v0, $a0, $a1		# Subtraction, $v0 = $a0 - $a1
	j	exit
mul_normal:
	mul	$v0, $a0, $a1		# mul pseudo instruction, (a0 * a1) and move lower bit pattern (lo) to $v0
	mfhi	$v1			# move upper bit pattern (hi) to $v1
	j	exit
div_normal:
	div	$a0, $a1		# $a0 / $a1, quotient stored in lo, remainder stored in hi
	mflo	$v0			# move quotient to $v0
	mfhi	$v1			# move remainder to $v1
exit: 
	# Caller RTE restore
	lw	$fp, 12($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	
	# return to caller 
	jr	$ra
