//Author: Wang Huiquan
`include "timescale.v"
`include "define.h"

module riscv_pipe_ctrl(
    /*Input*/
    ID_rs1_i, ID_rs2_i,
    EX_rd_i, EX_RegWr_en,
    MEM_rd_i, MEM_RegWr_en,
    WB_rd_i, WB_RegWr_en,
    ID_Branch_en_i, EX_opcode_i,
    /*Output*/
    PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o,
    IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o
    );
    
    input [4:0] ID_rs1_i, ID_rs2_i;
    input [4:0] EX_rd_i;
    input EX_RegWr_en;
    input [4:0] MEM_rd_i;
    input MEM_RegWr_en;
    input [4:0] WB_rd_i;
    input WB_RegWr_en;
    input ID_Branch_en_i;
    input [6:0] EX_opcode_i;

    output PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o;
    output IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o;
    
    reg PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o;
    reg IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o;
    
    //the event of Read After Write Hazard
    wire even_RAWreg_IDEX, even_RAWreg_IDMEM, even_RAWreg_IDWB;
    wire even_RAWreg;
    wire even_Branch_stall;
    
    assign even_RAWreg_IDEX = ((ID_rs1_i==EX_rd_i && EX_RegWr_en==1'b1)||(ID_rs2_i==EX_rd_i && EX_RegWr_en==1'b1))? 1:0;
    assign even_RAWreg_IDMEM = ((ID_rs1_i==MEM_rd_i && MEM_RegWr_en==1'b1)||(ID_rs2_i==MEM_rd_i && MEM_RegWr_en==1'b1))? 1:0;
    assign even_RAWreg_IDWB = ((ID_rs1_i==WB_rd_i && WB_RegWr_en==1'b1)||(ID_rs2_i==WB_rd_i && WB_RegWr_en==1'b1))? 1:0;
    
    assign even_RAWreg = even_RAWreg_IDEX | even_RAWreg_IDMEM | even_RAWreg_IDWB;
    assign even_Branch_stall = ID_Branch_en_i && (EX_opcode_i!==7'b000_0000);
    
    always @(even_RAWreg, even_Branch_stall)
        case ({even_RAWreg, even_Branch_stall})
            2'b10: {PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o,
            IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o} = {9'b1_1000_0100};
            2'b01,2'b11: {PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o,
            IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o} = {9'b0_1000_0100};
            default	: {PC_stall_o, IFID_stall_o, IDEX_stall_o, EXMEM_stall_o, WB_stall_o,
            IFID_flush_o, IDEX_flush_o, EXMEM_flush_o, WB_flush_o} = {9'b0_0000_0000};
        endcase
    
endmodule
