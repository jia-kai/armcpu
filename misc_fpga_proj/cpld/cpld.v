/*
 * $File: cpld.v
 * $Date: Thu Oct 31 21:40:36 2013 +0800
 * $Author: jiakai <jia.kai66@gmail.com>
 */


module cpld(
	input com_TxD,
	output com_RxD,
	output TxD,
	input RxD);

	assign TxD = com_TxD;
	assign com_RxD = RxD;

endmodule

