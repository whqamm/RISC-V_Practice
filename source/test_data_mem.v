//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module test_data_mem
	(
		clk_i,
		rst_i,
		Addr_i,
		Read_en_i,
		Read_data_o,
		Write_en_i,
		Wr_data_i
	);
	
	input clk_i, rst_i, Read_en_i, Write_en_i;
	input [4:0] Addr_i;
	input [`dw-1:0] Wr_data_i;
	
	output [`dw-1:0] Read_data_o;
	
	reg [`dw-1:0] Read_data_o;
	
	reg [`dw-1:0] rf_reg [0:`dw-1];
	integer i;
	
	always@(negedge clk_i, `RESET_EDGE rst_i) // clk is negedge
	begin
		if (rst_i == `RESET_ON)
		  begin
		    rf_reg[0] <= 32'd2;
		    //rf_reg[1] <= 32'b10000000_00000000_00000000_00001110; //used for test SRA
		    rf_reg[1] <= 32'd12;
			for (i = 2; i < `dw; i = i + 1)
				rf_reg[i] <= `ZERO;
		  end
		else if(Write_en_i)
		    rf_reg[Addr_i] <= Wr_data_i;
		else if(Read_en_i)
			Read_data_o <= rf_reg[Addr_i];
		else
			Read_data_o <= `ZERO;
	end

endmodule