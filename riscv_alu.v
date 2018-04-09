//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module riscv_alu
	(
		AluCtl_i,
		A_i,
		B_i,
		AluOut_o
	);
	
	input [3:0] AluCtl_i;
	input [`dw-1:0] A_i;
	input [`dw-1:0] B_i;
	
	output [`dw-1:0] AluOut_o;
	
	reg [`dw-1:0] AluResult;
	
	wire [`dw-1:0] AluOut_o;
	
	always @(AluCtl_i, A_i, B_i)
	begin
		case (AluCtl_i)
			`aluop_add	:	AluResult = A_i + B_i;
			`aluop_or	:	AluResult = A_i | B_i;
			default		:	AluResult = `ZERO;
		endcase
	end
	
	assign AluOut_o = AluResult;
	
endmodule