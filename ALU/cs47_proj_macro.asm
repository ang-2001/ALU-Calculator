# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#
	
	# Macro: extract_nth_bit
	# Usage: $regD = bit value taken from bit pattern regS at regT position
	.macro extract_nth_bit($regD, $regS, $regT)
	srlv 	$regD, $regS, $regT
	and 	$regD, $regD, 0x1
	.end_macro
	
	# Macro: insert_to_nth_bit
	# Usage: inserts bit value $regT into bit sequence $regD at position $regS
	.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)
	addi 	$maskReg, $zero, 0x1
	sllv 	$maskReg, $maskReg, $regS
	not 	$maskReg, $maskReg
	and 	$regD, $regD, $maskReg
	sllv 	$regT, $regT, $regS
	or 	$regD, $regD, $regT
	.end_macro
