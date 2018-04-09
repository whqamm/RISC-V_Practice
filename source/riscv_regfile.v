//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module riscv_regfile
	(
		/* Input */
		clk_i			,
		rst_i			,
		/* Read frome the register file */
		// The read registers 
		RdIndex1_i		,	Data1_o			,   
		RdIndex2_i		,   Data2_o         ,
		/* Write to register file */
		WrIndex_i		,	Data_i			,
		Wr_i				// The write control
	);

	input [4:0]			RdIndex1_i		,
						RdIndex2_i		,
						WrIndex_i		;
	/////////////////////////////////
	input [`dw-1:0]		Data_i			;
	input				Wr_i			;
	input				clk_i			;
	input				rst_i			;
	
	output [`dw-1:0]	Data1_o			,
						Data2_o			;
	
/* --------------------------------------------------------------
	registers, wires declaration
   ------------------- */
	reg [`dw-1:0] rf_reg [0:`dw-1]	; // dw bits x 32 registers
	integer i;

/* --------------------------------------------------------------
	instances, statements
   ------------------- */
		
	// Write synchronously in the register file
	always@(`CLOCK_EDGE clk_i, `RESET_EDGE rst_i)
	begin
		if (rst_i == `RESET_ON)
		  begin
		    //rf_reg[0] = 32'd7;
		    //rf_reg[1] = 32'd12;
			for (i = 0; i < `dw; i = i + 1)
				rf_reg[i] = `ZERO;
		  end
		// write the register with new value if Wr_i is high
		else if(Wr_i)
			if (WrIndex_i != `ZERO)	/* Don't write in r[0]  */
				rf_reg[WrIndex_i] = Data_i;
	end
	// Read asynchronously from the register file
	assign Data1_o = rf_reg[RdIndex1_i];
	assign Data2_o = rf_reg[RdIndex2_i];
	
endmodule
