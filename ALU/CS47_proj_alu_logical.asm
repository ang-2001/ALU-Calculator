.include "./cs47_proj_macro.asm"
.text
.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_logical:
# Caller RTE store
	addi	$sp, $sp, -12
	sw	$fp, 12($sp)
	sw	$ra, 8($sp)
	addi	$fp, $sp, 12

	# check for operations
	
	beq	$a2, '+', call_add	# addition
	beq	$a2, '-', call_sub	# subtraction
	beq	$a2, '*', call_mul	# multiplication
	beq	$a2, '/', call_div	# division
	
call_add:	
	jal	add_logical
	j	exit
call_sub:
	jal	sub_logical
	j	exit			
call_mul:	
	jal	mul_signed
	j	exit	
call_div:
	jal	div_signed
	j	exit

# common addition/subtraction logical implementation #
add_sub_logical:
# Caller RTE store
	# save $s0, $ra, $fp
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$s0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 20
# procedure implementation
	add	$t0, $zero, $zero		# I : index from [0,31]
	add	$s0, $zero, $zero		# S : sum/result of operation
	extract_nth_bit($t1, $a2, $zero)	# C0 : initial Carry bit
	
	bne	$a2, 0xFFFFFFFF, add_sub_loop
	not	$a1, $a1			
add_sub_loop:
	beq	$t0, 0x20, add_loop_exit
	
	extract_nth_bit($t2, $a0, $t0)		# A = $a0[I]
	extract_nth_bit($t3, $a1, $t0)		# B = $a1[I]
	xor	$t4, $t2, $t3			# A xor B
	and	$t5, $t2, $t3			# A.B
	
	xor	$t6, $t1, $t4			# Y = C xor (a xor b)
	and	$t1, $t1, $t4			# C = C.(a xor b)
	or	$t1, $t1, $t5			# C = [C.(a xor b)] + [a.b]
	insert_to_nth_bit($s0, $t0, $t6, $t7)	# S[i] = Y
	
	addi 	$t0, $t0, 0x1			# I++
	j	add_sub_loop			# jump to loop start
add_loop_exit: 
	add	$v0, $s0, $zero
# Caller RTE restore
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$s0, 12($sp)
	lw	$a1,  8($sp)
	addi	$sp, $sp, 20
	jr 	$ra
add_logical:
# Caller RTE store
	addi	$sp, $sp, -12
	sw	$fp, 12($sp)
	sw	$ra, 8($sp)
	addi	$fp, $sp, 12
# procedure implementation
	addi	$a2, $zero, 0x00000000
	jal	add_sub_logical
	add	$v1, $zero, $t1		# store the final carry bit in $v1
# Caller RTE restore
	lw	$fp, 12($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr 	$ra
sub_logical:
# Caller RTE store
	addi	$sp, $sp, -12
	sw	$fp, 12($sp)
	sw	$ra, 8($sp)
	addi	$fp, $sp, 12
# Procedure Implementation
	addi	$a2, $zero, 0xFFFFFFFF
	jal	add_sub_logical
# Caller RTE restore
	lw	$fp, 12($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr 	$ra

# Multiplication Logical Implementation #
twos_complement:
# Caller RTE store
	# store $a0, $a1, $ra, $fp
	addi	$sp, $sp, -20
	sw	$fp, 20($sp)
	sw	$ra, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 20
# Procedure Implementation
	not	$a0, $a0		# $a0 = ~$a0
	or	$a1, $zero, 0x1		# $a1 = 1
	jal 	add_logical		# $v0 = ~$a0 + 1
# Caller RTE restore
	lw	$fp, 20($sp)
	lw	$ra, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1,  8($sp)
	addi	$sp, $sp, 20
	jr	$ra
	
twos_complement_if_negative: 
# Caller RTE store
	#  store $s0, $ra, $fp
	addi	$sp, $sp, -16
	sw	$fp, 16($sp)
	sw	$ra, 12($sp)
	sw	$s0,  8($sp)
	addi	$fp, $sp, 16
# Procedure Implementation
	or	$t0, $zero, 0x1F	# i = 31
	extract_nth_bit($s0, $a0, $t0)	# $s0 = $a0[i]
	beqz	$s0, is_positive	# if $s0 is 0, then it's positive
	jal	twos_complement		# else $s0 is negative, call the twos_complement procedure
	j	exit_twos
is_positive:
	or	$v0, $a0, $zero		# result = original value
exit_twos:
# Caller RTE restore
	lw	$fp, 16($sp)
	lw	$ra, 12($sp)
	lw	$s0,  8($sp)
	addi	$sp, $sp, 16
	jr	$ra

twos_complement_64bit:
# Caller RTE store
	# store $a0, $a1, $s0, $ra, $fp
	addi	$sp, $sp, -24
	sw	$fp, 24($sp)
	sw	$ra, 20($sp)
	sw	$a0, 16($sp)
	sw	$a1, 12($sp)
	sw	$s0,  8($sp)
	addi	$fp, $sp, 24
# Procedure Implementation
	not 	$a0, $a0		# $a0 = ~LO
	not 	$s0, $a1		# $s0 = ~HI
	or	$a1, $zero, 0x1		# move 0x1 to $a1
	jal	add_logical		# $v0 = ~LO + 1
	or	$a0, $s0, $zero		# move ~HI to $a0
	or	$a1, $v1, $zero		# move carry bit to $a1
	or	$s0, $v0, $zero		# save new LO ($s0 = LO)
	jal	add_logical		# $v0 = ~HI + carry bit
	or	$v1, $v0, $zero		# return new HI and LO
	or	$v0, $s0, $zero		
# Caller RTE restore
	lw	$fp, 24($sp)
	lw	$ra, 20($sp)
	lw	$a0, 16($sp)
	lw	$a1, 12($sp)
	lw	$s0,  8($sp)
	addi	$sp, $sp, 24
	jr	$ra
	
bit_replicator:
# Caller RTE store
	# store $ra, $fp, 
	addi	$sp, $sp, -12
	sw	$fp, 12($sp)
	sw	$ra,  8($sp)
	addi	$fp, $sp, 12
# Procedure Implementation
	or 	$v0, $zero, 0x0		# $v0 = 0x00000000
	beqz	$a0, exit_replicator	# if $a0 = 0, replicate 0
	not	$v0, $v0		# inv(0x00000000) = 0xFFFFFFFF
exit_replicator:
# Caller RTE restore
	lw	$fp, 12($sp)
	lw	$ra,  8($sp)
	addi	$sp, $sp, 12
	jr	$ra
mul_unsigned:
# Caller RTE store
	# store $ra, $fp, $s0, $s1, $s2, $s3, $a0, $a1
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 36
# Procedure Implementation
	add	$s0, $zero, $zero		# I = 0
	add	$s1, $zero, $zero		# HI(H) = 0
	add	$s2, $a0, $zero			# Multiplicand(M) = Multiplicand
	add	$s3, $a1, $zero			# LO(L) = Multiplier

mul_loop: 
	beq	$s0, 0x20, mul_loop_exit
	extract_nth_bit($a0, $s3, $zero)	# $a0 = L[0]
	jal	bit_replicator			# R = {32{L[0]}}
	and	$t0, $s2, $v0			# X = M.R
	
	or	$a0, $s1, $zero			# A = H
	or	$a1, $t0, $zero 		# B = X
	jal	add_logical			# H + X
	or	$s1, $v0, $zero			# H = H + X
	srl	$s3, $s3, 0x1			# L >> 1
	extract_nth_bit($t0, $s1, $zero)	
	or	$t1, $zero, 0x1F
	insert_to_nth_bit($s3, $t1, $t0, $t2)	# L[31] = H[0]
	srl	$s1, $s1, 0x1			# H >> 1
	
	addi	$s0, $s0, 0x1			# I++
	j 	mul_loop
mul_loop_exit:
	add	$v0, $s3, $zero			# return HI and LO values
	add	$v1, $s1, $zero 	
# Caller RTE restore
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1,  8($sp)
	addi	$sp, $sp, 36
	jr	$ra
	
mul_signed: 
# Caller RTE store
	# store $ra, $fp, $a0, $a1, $s0, $s1, $s2
	addi	$sp, $sp, -32
	sw	$fp, 32($sp)
	sw	$ra, 28($sp)
	sw	$s0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s2, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 32	
# Procedure Implementation
	addi	$t0, $zero, 0x1F
	extract_nth_bit($s1, $a0, $t0)		# multiplicand[31]
	extract_nth_bit($s2, $a1, $t0)		# multiplier[31]
	
	jal 	twos_complement_if_negative	# two's complement multiplicand if negative
	or 	$s0, $v0, $zero			# save resulting multiplicand value
	or	$a0, $a1, $zero			# set $a0 to $a1(multiplier)
	jal 	twos_complement_if_negative	# two's complement multiplier if negative
	or	$a0, $s0, $zero			# move multiplicand to $a0
	or	$a1, $v0, $zero			# move resulting multiplier to $a1
	jal	mul_unsigned			# product = multiplicand * multiplier
	
	xor	$t0, $s1, $s2			# product_sign = multiplicand[31] XOR multiplier[31]
	beqz	$t0, is_posi			# if product_sign = 0, exit to RTE restore
	or	$a0, $v0, $zero			# move HI and LO of prodcut into $a0, $a1
	or	$a1, $v1, $zero
	jal	twos_complement_64bit		# else { two's complement product }
is_posi: 
# Caller RTE restore
	lw	$fp, 32($sp)
	lw	$ra, 28($sp)
	lw	$s0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s2, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1,  8($sp)
	addi	$sp, $sp, 32
	jr	$ra

# Division Logical Implementation #
div_unsigned: 
# Caller RTE store
	# store $ra, $fp, $s0, $s1, $s2, $s3, $s4, $a0, $a1
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 36
# Procedure Implementation
	add 	$s0, $zero, $zero		# I = 0
	add	$s1, $a0, $zero			# Quotient(Q) = Dividend
	add	$s2, $zero, $zero		# Remainder(R) = 0
	addi	$s3, $zero, 0x1F 		# index 31 
		
div_loop: 
	beq	$s0, 0x20, div_loop_exit	# loop check
	sll	$s2, $s2, 1			# R << 1	
	extract_nth_bit($t0, $s1, $s3)		# Q[31]
	insert_to_nth_bit($s2, $zero, $t0, $t1)	# R[0] = Q[31]
	sll	$s1, $s1, 1			# Q << 1
	or	$a0, $s2, $zero			# move remainder to $a0 for subtraction
	jal	sub_logical			# S = R - D
	extract_nth_bit($t0, $v0, $s3)		# S[31] 
	
	bnez	$t0, div_increment		# S[31] < 0 ? 
 	or 	$s2, $v0, $zero			# R = S
 	or	$t0, $zero, 0x1			# set $t0 to 1
 	insert_to_nth_bit($s1, $zero, $t0, $t1) # Q[0] = 1
div_increment: 
	addi 	$s0, $s0, 0x1			# I++
	j	div_loop			

div_loop_exit:
	add	$v0, $s1, $zero			# return results	
	add	$v1, $s2, $zero
# Caller RTE restore
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$a0, 12($sp)
	lw	$a1,  8($sp)
	addi	$sp, $sp, 36
	jr	$ra

div_signed:
	# Caller RTE store
	addi	$sp, $sp, -36
	sw	$fp, 36($sp)
	sw	$ra, 32($sp)
	sw	$s0, 28($sp)
	sw	$s1, 24($sp)
	sw	$s2, 20($sp)
	sw	$s3, 16($sp)
	sw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$fp, $sp, 36
	# Procedure Implementation
	addi	$t0, $zero, 0x1F		# 31
	extract_nth_bit($s1, $a0, $t0)		# dividend[31]
	extract_nth_bit($s2, $a1, $t0)		# divisor[31]
	
	jal 	twos_complement_if_negative	# two's complement dividend if negative
	or 	$s0, $v0, $zero			# save resulting dividend value in saved register
	or	$a0, $a1, $zero			# move $a1(divisor) to $a0
	jal 	twos_complement_if_negative	# two's complement divisor if negative
	or	$a0, $s0, $zero			# move dividend to $a0
	or	$a1, $v0, $zero			# move resulting divisor to $a1
	jal	div_unsigned			# dividend/divisor 
	
	or	$s3, $v1, $zero			# save remainder in $s3
	xor	$t0, $s1, $s2			# quotient_sign = dividend[31] XOR divisor[31]
	beqz	$t0, quotient_is_positive	# if quotient_sign = 0, leave quotient unsigned
	or	$a0, $v0, $zero			# else { move quotient to $a0
	jal	twos_complement			# two's complement of the quotient }
quotient_is_positive:
	or	$s0, $v0, $zero			# save quotient 
	beqz	$s1, remainder_is_positive	# check dividend[31] to determine remainder sign
	or	$a0, $s3, $zero			# move remainder to $a0
	jal	twos_complement			# twos complement of remainder
	or 	$s3, $v0, $zero			# move remainder back to saved register
remainder_is_positive:
	or	$v0, $s0, $zero			# return values
	or	$v1, $s3, $zero
	# Caller RTE restore
	lw	$fp, 36($sp)
	lw	$ra, 32($sp)
	lw	$s0, 28($sp)
	lw	$s1, 24($sp)
	lw	$s2, 20($sp)
	lw	$s3, 16($sp)
	lw	$a0, 12($sp)
	sw	$a1,  8($sp)
	addi	$sp, $sp, 36
	jr	$ra

exit:
# TBD: Complete it
	lw	$fp, 12($sp)
	lw	$ra, 8($sp)
	addi	$sp, $sp, 12
	jr 	$ra
