//Author: Wang Huiquan
//This modeule is a branch decoder. It is used for generate signals for jump or branch instruction.
`include "timescale.v"
`include "define.h"

module riscv_bradecoder(
     Opcode_i,  // The opcode from instruction
     funct3_i,  // The funct3 from instruction
     Regdata1_i, //The rs1 data from regfile
     Regdata2_i, //The rs2 data from regfile
     Branch_en_o, //The signal for jump and branch
     PC_mux_sel_o //selection signal for the pc_mux
    );
    input [6:0] Opcode_i;
    input [2:0] funct3_i;
    input [`dw-1:0] Regdata1_i;
    input [`dw-1:0] Regdata2_i;
    
    output Branch_en_o;
    output [1:0] PC_mux_sel_o; //00 -- PC = PC+4, 01 -- PC = PC+4+imm
    
    reg Branch_en_o;
    reg [1:0] PC_mux_sel_o;
    
    wire rs1_eql_rs2 = (Regdata1_i==Regdata2_i)? 1:0;
    
    always @(Opcode_i,funct3_i,rs1_eql_rs2)
        casex({funct3_i, Opcode_i})
            10'bxxx_1101111: {Branch_en_o,PC_mux_sel_o} = 3'b1_01; //JAL
            10'b000_1100011: {Branch_en_o,PC_mux_sel_o} = {rs1_eql_rs2, 1'b0, rs1_eql_rs2}; //BEQ
            default: {Branch_en_o,PC_mux_sel_o} = 3'b0_00;
        endcase
    
endmodule
