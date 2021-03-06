//Author WangHuiquan
`include "timescale.v"
`include "define.h"

module riscv_cpu_top(clk_i, rst_i, pc_to_debug,
        Dbg_reg_index, Dbg_reg_data);

//The ports for debug
input [4:0] Dbg_reg_index;
output [31:0] Dbg_reg_data;
wire [4:0] Dbg_reg_index;
wire [31:0] Dbg_reg_data;
///////////////////////////////

input clk_i, rst_i;
output [7:0] pc_to_debug;
wire clk_i, rst_i;
wire [7:0] pc_to_debug;

//To inst memory
wire [`dw-1:0] inst_addr;
wire [`dw-1:0] instruction;

//To data memory
wire [`dw-1:0] data_mem_addr;
wire data_mem_Rd_en;
wire [`dw-1:0] data_mem_data_in;
wire data_mem_Wr_en;
wire [`dw-1:0] data_mem_data_out;

assign pc_to_debug = inst_addr[9:2];

riscv_core unit_riscv
	(
		.clk_i(clk_i),
		.rst_i(rst_i),
		.inst_addr_o(inst_addr),
		.inst_in(instruction),
		.data_addr_o(data_mem_addr),
		.data_data_o(data_mem_data_in), //The data to write into data memory
		.data_data_i(data_mem_data_out), //The data read from data memory
		.data_Rd_en_o(data_mem_Rd_en),
		.data_Wr_en_o(data_mem_Wr_en),
		.Dbg_reg_index(Dbg_reg_index),
        .Dbg_reg_data(Dbg_reg_data)
	);

test_inst_mem unit_inst_mem
	(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .Addr_i(inst_addr[6:2]),
        .Read_en_i(1'b1),
        .Read_data_o(instruction)
    );
   
test_data_mem unit_data_mem
        (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .Addr_i(data_mem_addr[4:0]),
            .Read_en_i(data_mem_Rd_en),
            .Read_data_o(data_mem_data_out),
            .Write_en_i(data_mem_Wr_en),
            .Wr_data_i(data_mem_data_in)
        );

endmodule
