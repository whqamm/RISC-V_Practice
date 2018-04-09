//Author: WangHuiquan
`include "timescale.v"
`include "define.h"

module riscv_pipe
	(
		clk_i,
		rst_i,
		stall_i,
		flush_i,
		D_i,
		Q_o
	);
	
	parameter WIDHTH=1'b1;
	
	input clk_i;
	input rst_i;
	input stall_i;
	input flush_i;
	input [WIDHTH-1:0] D_i;
	
	output [WIDHTH-1:0]	Q_o;
	
	reg [WIDHTH-1:0]	rQ;
	
	always @(`CLOCK_EDGE clk_i)
	begin
		if (rst_i == `RESET_ON)
			rQ = `LOW;		// reset synchronously
		else if(stall_i == `HIGH)
			rQ = rQ;		// don't update
		else if(flush_i == `HIGH)//(suppress glith from the combinatorial calculeted flush signal)
            rQ = `LOW;        // clear
		else
			rQ = D_i;		// else update
	end
	
	assign Q_o = rQ;
	
endmodule