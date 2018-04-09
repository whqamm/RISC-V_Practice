//Author: Wang Tao
module riscv_shifter
	(	
		/* Input */
		A_i,  //Operand A
		SH_i, //Shift amount
		LR_i, //Left--0/Right--1
		LA_i, //Logic--0/Arithmetic--1
		/* Output */
		Out_o // Out shifted
	);
	
	input [31:0] A_i;
	input [4:0] SH_i;
	input LR_i, LA_i;
	
	output [31:0] Out_o;

	
endmodule