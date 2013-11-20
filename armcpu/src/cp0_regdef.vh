/*
 * $File: cp0_regdef.vh
 * $Date: Wed Nov 20 14:28:14 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */

// definition of internal register numbers
`define	CP0_INDEX		0
`define CP0_ENTRY_LO0	1
`define CP0_ENTRY_LO1	2
`define CP0_BADVADDR	3
`define CP0_COUNT		4
`define CP0_COMPARE		5
`define CP0_STATUS		6
`define CP0_CAUSE		7
`define CP0_EPC			8
`define CP0_EBASE		9

// dummy entry for unimplemented registeres
// (or better to cause exception when accessing?)
`define CP0_UNIMPLEMENTED	10	

// dummy entry to disable writing to a register
`define CP0_REG_NONE	10

`define CP0_NR_REG		10

`define CP0_REG_TOT_WIDTH	(32 * `CP0_NR_REG)

`define CP0_VISIT_REG(array, num) array[(num)*32+31:(num)*32]

`define CP0_REG_ADDR_WIDTH 4

`define EXC_CODE_WIDTH	5

`define INT_MASK_WIDTH	8	// width of interrupt mask

// exc code definitions
`define EC_INT		5'h00	// interrupt
`define EC_TLB_MOD	5'h01	// modification exception
`define EC_TLBL		5'h02	// TLBL TLB invalid exception (load or instruction fetch)
`define EC_TLBS		5'h03	// TLBS TLB invalid exception (store)
`define EC_ADEL		5'h04	// AdEL Address error exception (load or instruction fetch)
`define EC_ADES		5'h05	// AdES Address error exception (store)
`define EC_SYS		5'h08	// Syscall exception
`define EC_RI		5'h0a	// reserved instruction
`define EC_CP_U		5'h0b	// Coprocessor Unusable exception

`define EC_NONE		5'h10	// dummy value for no exception
`define EC_ERET		5'h11	// dummy value to implement ERET

`define EC_IS_TLB_REFILL(ec) ((ec) == `EC_TLBL || (ec) == `EC_TLBS)
`define EC_IS_INTERRUPT(ec) ((ec) == `EC_INT)

// vim: ft=verilog


