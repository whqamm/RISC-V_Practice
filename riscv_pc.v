//Author WangHuiquan
`include "timescale.v"
`include "define.h"

/* ================= */
/* module definition */
/* ================= */
module	riscv_pc
	(
		/* Input */
		clk_i			,
		rst_i			,

		mux_pc_i		,
		stall_i			,
		/* Output */
		PC_o			,
		PC4_o						
	);
	                         	
	input				clk_i	;
	input				rst_i	;
	input				stall_i	;
	input [`dw-1:0]		mux_pc_i;  	
                             	
	output [`dw-1:0]	PC_o	;
	output [`dw-1:0]	PC4_o	;
	
/* -------------------------------------------------------------- */
/* registers, wires declaration */
/* ---------------------------- */
	reg [`dw-1:0]		rPC		;

//* -------------------------------------------------------------- */
/* instances, statements */
/* --------------------- */

	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)begin					// RESET	: clear the pc
			rPC			= `ZERO;
		end	else if (stall_i)begin						// STALL	: do not update
			rPC			= rPC;
		end else begin									// ELSE		: get the value from the mux_pc
			rPC			= mux_pc_i;
		end
	end

	assign PC_o		=	rPC;
	assign PC4_o	=	rPC + `dw'd4;

endmodule