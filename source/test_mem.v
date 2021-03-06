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
		    rf_reg[0] = 32'b00000000000_00000_001_00001_0000011; //LAOD reg1 reg0 0
		    rf_reg[1] = 32'b00000000001_00000_010_00010_0000011; //LAOD reg2 reg0 1
		    rf_reg[2] = 32'b0000000_00001_00010_000_00011_0110011; //ADD reg3 reg1 reg2
		    rf_reg[3] = 32'b0_0000000010_0_00000000_00101_1101111; //JAL 1 reg5
		    //rf_reg[3] = 32'b0000000_00001_00001_000_0010_0_1100011; //BEQ 1 reg1 reg1
		    //rf_reg[3] = 32'd0; //NOP
		    rf_reg[4] = 32'b0000000_00000_00001_000_00100_0110011; //ADD reg4 reg0 reg1
		    rf_reg[5] = 32'b0000000_00011_00001_010_00001_0100011; //SW 1 reg1 reg3
		    rf_reg[6] = 32'b111111111111_00001_110_00110_0010011; //ORI reg6 reg1 FFFFFFFF
		    rf_reg[7] = 32'b000000000000_00001_110_00111_0010011; //ORI reg7 reg1 00000000
		    rf_reg[8] = 32'b0100000_00001_00010_101_01000_0110011; //SRA reg8 reg2 reg1
			for (i = 9; i < `dw; i = i + 1)
				rf_reg[i] = `ZERO;
		  end
		else if(Read_en_i)
			Read_data_o <= rf_reg[Addr_i];
		else
			Read_data_o = `ZERO;
	end

endmodule