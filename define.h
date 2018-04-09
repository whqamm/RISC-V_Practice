`define dw 32		// Data Width

`define RESET_EDGE	posedge
`define RESET_ON	1'b1
`define CLOCK_EDGE	posedge

`define ZERO    32'd0
`define ONE     32'd1

`define LOW     1'd0
`define HIGH    1'd1

`define CLEAR   1'b0
`define SET     1'b1

//ALU_op
`define aluop_nop	4'd0
`define aluop_add	4'd1
`define aluop_or	4'd2