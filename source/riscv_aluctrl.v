`include "timescale.v"
`include "define.h"

module riscv_aluctrl
    (
       opcode_i,
	   funct3_i,
	   funct7_i,
	   AluCtl_o
	);

	input [6:0] opcode_i;
	input [2:0] funct3_i;
	input [6:0] funct7_i;
		
	output [3:0] AluCtl_o;
		
	reg [3:0] AluCtl_o;
		
	always @(opcode_i,funct3_i,funct7_i)
		casex ({funct3_i,opcode_i})
			{3'b000,7'b011_0011} : AluCtl_o = `aluop_add; //ADD
			{3'b010,7'b000_0011} : AluCtl_o = `aluop_add; //LOAD
			{3'b010,7'b010_0011} : AluCtl_o = `aluop_add; //STORE
			{3'bxxx,7'b110_1111} : AluCtl_o = `aluop_add; //JAL
			{3'b110,7'b001_0011} : AluCtl_o = `aluop_or;
			default	:	AluCtl_o = `aluop_nop;
		endcase

endmodule