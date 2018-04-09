//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module test_inst_mem
	(
		clk_i,
		rst_i,
		Addr_i,
		Read_en_i,
		Read_data_o
	);
	
	input clk_i, rst_i, Read_en_i;
	input [4:0] Addr_i;
	
	output [`dw-1:0] Read_data_o;
	
	reg [`dw-1:0] Read_data_o;
	
	reg [`dw-1:0] rf_reg [0:`dw-1];
	integer i;
	
	always@(negedge clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)
		  begin
		    //rf_reg[0] = 32'b0000000_00000_00001_000_00010_0110011; //ADD reg2 reg0 reg1
		    rf_reg[0] = 32'b00000000000_00000_010_00001_0000011; //LAOD reg1 reg0 0
		    rf_reg[1] = 32'b00000000001_00000_010_00010_0000011; //LAOD reg1 reg0 1
		    rf_reg[2] = 32'b0000000_00001_00010_000_00011_0110011; //ADD reg3 reg1 reg2
			for (i = 3; i < `dw; i = i + 1)
				rf_reg[i] = `ZERO;
		  end
		else if(Read_en_i)
			Read_data_o <= rf_reg[Addr_i];
		else
			Read_data_o = `ZERO;
	end

endmodule