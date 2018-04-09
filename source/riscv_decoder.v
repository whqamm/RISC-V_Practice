//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module riscv_decoder
	(
		Instruction_i,
		//
		RegRs1_o,
		RegRs2_o,
		RegRd_o,
		Func7_o,
		Func3_o,
		opcode_o,
		//
		Immediate_o,
		RegWr_en_o, // 1--we need to write the RegFile in WB STAGE; 0---otherwise
		//
		Operand1_sel_o,  //selection for operand 1
		Operand2_sel_o,  //selection for operand 2
		data_mem_en_o,   //enable for data memory (Load/store)
		data_mem_wr,      //write or read signal for data memory (0--write, 1--read)
		memWr_en_o,  // enable the data memory to write the result in; (High active)
        memRd_en_o  // enable the data memory to read the data out; (High active)
	);
	
	input [`dw-1:0] Instruction_i;
	
	output [4:0] RegRs1_o; 
	output [4:0] RegRs2_o;
	output [4:0] RegRd_o;
	output [2:0] Func3_o;
	output [6:0] Func7_o;
	output [6:0] opcode_o;
	output [`dw-1:0] Immediate_o;
	output RegWr_en_o;
	
	output memWr_en_o;
    output memRd_en_o;
	reg memWr_en_o;
    reg memRd_en_o;
	
	
    output data_mem_en_o;   //enable for data memory (Load/store)
    output data_mem_wr;     //write or read signal for data memory (0--write, 1--read)
    
    reg data_mem_en_o;   //enable for data memory (Load/store)
    reg data_mem_wr;     //write or read signal for data memory (0--write, 1--read)
	
	output [2:0] Operand1_sel_o; //selection for operand 1
    output [2:0] Operand2_sel_o;  //selection for operand 2
    
    reg [2:0] Operand1_sel_o; //selection for operand 1
	reg [2:0] Operand2_sel_o;  //selection for operand 2
	
	reg RegWr_en_o;
	reg [`dw-1:0] Immediate_o;
	
	assign {Func7_o, RegRs2_o, RegRs1_o, Func3_o, RegRd_o, opcode_o} = Instruction_i;
	
	always @(Instruction_i)
		case(Instruction_i[6:0])
			7'b001_0011 : Immediate_o = {{20{Instruction_i[31]}},Instruction_i[31:20]}; //ORI
			7'b000_0011 : Immediate_o = {{20{0}},Instruction_i[31:20]};  //LOAD
			default: Immediate_o = `ZERO;
		endcase
	
	always @(opcode_o)
        case(opcode_o)
            default: Operand1_sel_o = 3'd0; //Operand1 is from RegFile
        endcase
        
	always @(opcode_o)
        case(opcode_o)
            7'b000_0011 : Operand2_sel_o = 3'd1; 
            default: Operand2_sel_o = 3'd0; //Operand2 is from RegFile
        endcase
	
	always @(opcode_o)
	   case(opcode_o)
	       7'b001_0011 : RegWr_en_o = 1'b1; //ORI
	       7'b011_0011 : RegWr_en_o = 1'b1; //ADD\SRA
	       7'b110_1111 : RegWr_en_o = 1'b1; //JAL
	       7'b000_0011 : RegWr_en_o = 1'b1; //LOAD
	       7'b110_0011 : RegWr_en_o = 1'b0;
	       7'b010_0011 : RegWr_en_o = 1'b0;
	       default: RegWr_en_o = 0;
	   endcase

    // data memory controller
    always @(opcode_o)
       case(opcode_o)
            7'b000_0011 : // Laod
                begin
                     memWr_en_o = 1'b0;
                     memRd_en_o = 1'b1;
                end
            7'b010_0011 : //Store
                begin
                    memWr_en_o = 1'b1;
                    memRd_en_o = 1'b0;
                end
            default: 
                begin
                    memWr_en_o = 1'b0;
                    memRd_en_o = 1'b0;
                end
        endcase

endmodule