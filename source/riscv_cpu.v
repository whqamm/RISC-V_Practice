//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module riscv_core 
	(
		clk_i,
		rst_i,
		//
		inst_addr_o,
		inst_in,
		data_addr_o,
        data_data_o, //The data to write into data memory
        data_data_i, //The data read from data memory
        data_Rd_en_o,
        data_Wr_en_o,
        Dbg_reg_index,
        Dbg_reg_data
	);
	//The ports for debug
	input [4:0] Dbg_reg_index;
    output [31:0] Dbg_reg_data;
	wire [4:0] Dbg_reg_index;
    wire [31:0] Dbg_reg_data;
	///////////////////////////////
	
	input clk_i, rst_i;
	input [`dw-1:0] inst_in;
	
	output [`dw-1:0] inst_addr_o;
	assign inst_addr_o = IF_PC;
	
    output [`dw-1:0] data_addr_o;
    output [`dw-1:0] data_data_o; //The data to write into data memory
    input [`dw-1:0]data_data_i; //The data read from data memory
    output data_Rd_en_o;
    output data_Wr_en_o;
    
    wire IFID_stall, IDEX_stall, EXMEM_stall, MEMWB_stall;
    wire IFID_flush, IDEX_flush, EXMEM_flush, MEMWB_flush;

//-----------------------------
// IF: Instruction Fetch STAGE
//-----------------------------
wire [`dw-1:0] IF_PC;
wire [`dw-1:0] IF_PCplus4;
reg [`dw-1:0] IF_mux_pc;
//////////
wire ID_Branch_en;
wire [1:0] ID_PC_mux_sel;
wire [`dw-1:0] PC_plus_Imm;

//assign PC_plus_Imm = ID_PCplus4 + (ID_Immediate<<1);
assign PC_plus_Imm = ID_PCplus4 + (ID_Immediate);
//assign IF_mux_pc = IF_PCplus4; //TODO: This mux should add a selection.
always @(ID_PC_mux_sel, IF_PCplus4, PC_plus_Imm)
    case(ID_PC_mux_sel)
        2'b00 : IF_mux_pc = IF_PCplus4;
        2'b01 : IF_mux_pc = PC_plus_Imm;
        default: IF_mux_pc = IF_PCplus4;
    endcase
//TODO：注意根据取指是否有延迟，看波形行事。

wire PC_stall;

riscv_pc unit_pc_IF
    (
        .clk_i(clk_i), 
        .rst_i(rst_i), 
        .mux_pc_i(IF_mux_pc), 
        .stall_i(PC_stall), 
        .PC_o(IF_PC), 
        .PC4_o(IF_PCplus4)
      );

//-----------------------------
// IF/ID PIPELINE
//-----------------------------	
wire [`dw-1:0] ID_PC;
wire [`dw-1:0] ID_inst;
wire [`dw-1:0] ID_PCplus4;

riscv_pipe #(`dw) IFID_PC(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IFID_stall), .flush_i(IFID_flush), .D_i(IF_PCplus4), .Q_o(ID_PCplus4));
riscv_pipe #(`dw) IFID_inst(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IFID_stall), .flush_i(IFID_flush), .D_i(inst_in), .Q_o(ID_inst));

//------------------------------
// ID: Instraction Decode STAGE
//------------------------------
wire [4:0] ID_RegRs1;
wire [4:0] ID_RegRs2;
wire [4:0] ID_RegRd;
wire [6:0] ID_Func7;
wire [2:0] ID_Func3;
wire [6:0] ID_opcode;
wire [`dw-1:0] ID_Immediate;
wire ID_RegWr_en;
wire [2:0]  ID_Operand1_sel; //selection for operand 1
wire [2:0]  ID_Operand2_sel;  //selection for operand 2
wire ID_memWr_en;
wire ID_memRd_en;

riscv_decoder unit_decoder_ID(
		.Instruction_i(ID_inst),
		.RegRs1_o(ID_RegRs1),
		.RegRs2_o(ID_RegRs2),
		.RegRd_o(ID_RegRd),
		.Func7_o(ID_Func7),
		.Func3_o(ID_Func3),
		.opcode_o(ID_opcode),       // opcode to ALU controller
		.Immediate_o(ID_Immediate), // the immediate number
		.RegWr_en_o(ID_RegWr_en),   // enable the regfile to write the result back
		.Operand1_sel_o(ID_Operand1_sel), //selection for operand 1
        .Operand2_sel_o(ID_Operand2_sel),  //selection for operand 2
        .memWr_en_o(ID_memWr_en),  // enable the data memory to write the result in; (High active)
        .memRd_en_o(ID_memRd_en)  // enable the data memory to read the data out; (High active)
	);

wire [`dw-1:0] ID_RegData1;
wire [`dw-1:0] ID_RegData2;

wire [`dw-1:0] ID_RegWrData;
wire [4:0] ID_RegWrAddr;
//wire ID_RegWr_en;

wire [`dw-1:0] WB_AluOut;
wire [4:0] WB_RegRd;
wire [`dw-1:0] WB_RegWrData;
wire WB_RegWr_en;


//The module of regfile
riscv_regfile unit_regfile_ID
        (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .RdIndex1_i(ID_RegRs1) ,   
            .Data1_o(ID_RegData1),   
            .RdIndex2_i(ID_RegRs2),
            .Data2_o(ID_RegData2),
            /* Write to register file */
            .WrIndex_i(WB_RegRd),
            .Data_i(WB_RegWrData),   // The data writing into regfile 
            .Wr_i(WB_RegWr_en),                // The write control
            //For debug
            .Dbg_index_i(Dbg_reg_index),
            .Dbg_data_o(Dbg_reg_data)
        );

//wire ID_Branch_en, ID_PC_mux_sel;

riscv_bradecoder unit_bradecoder_ID(
        .Opcode_i(ID_opcode),  // The opcode from instruction
        .funct3_i(ID_Func3),  // The funct3 from instruction
        .Regdata1_i(ID_RegData1), //The rs1 data from regfile
        .Regdata2_i(ID_RegData2), //The rs2 data from regfile
        .Branch_en_o(ID_Branch_en), //The signal for jump and branch
        .PC_mux_sel_o(ID_PC_mux_sel) //selection signal for the pc_mux
    );

//Combinational logic for operand selection
reg [`dw-1:0] ID_operand1;
reg [`dw-1:0] ID_operand2;

always @(ID_Operand1_sel or ID_RegData1 or ID_PCplus4 )
    case(ID_Operand1_sel)
        3'd0: ID_operand1 = ID_RegData1;
        3'd1: ID_operand1 = ID_PCplus4;
        default: ID_operand1 = ID_RegData1;
    endcase
    
always @(ID_Operand2_sel or ID_Immediate or ID_RegData2)
    case(ID_Operand2_sel)
        3'd0: ID_operand2 = ID_RegData2;
        3'd1: ID_operand2 = ID_Immediate;
        3'd2: ID_operand2 = `ZERO;
        default: ID_operand2 = ID_RegData2;
    endcase

//-------------------------------------
// ID/EX PIPELINE 
//-------------------------------------

wire [6:0] EX_opcode;
wire [2:0] EX_Func3;
wire [6:0] EX_Func7;
wire [`dw-1:0] EX_Immediate;
wire [`dw-1:0] EX_operand1;
wire [`dw-1:0] EX_operand2;
wire [4:0] EX_RegRd;
wire EX_RegWr_en;
wire EX_memWr_en;
wire EX_memRd_en;
wire [`dw-1:0] EX_rs2_data; // This data is used for store instruction

riscv_pipe #(7) IDEX_opcode(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_opcode), .Q_o(EX_opcode));
riscv_pipe #(3) IDEX_funct3(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_Func3), .Q_o(EX_Func3));
riscv_pipe #(7) IDEX_funct7(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_Func7), .Q_o(EX_Func7));
riscv_pipe #(`dw) IDEX_Immediate(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_Immediate), .Q_o(EX_Immediate));
riscv_pipe #(`dw) IDEX_operand1(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_operand1), .Q_o(EX_operand1));
riscv_pipe #(`dw) IDEX_operand2(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_operand2), .Q_o(EX_operand2));
riscv_pipe #(5) IDEX_RegRd(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_RegRd), .Q_o(EX_RegRd));
riscv_pipe IDEX_RegWr_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_RegWr_en), .Q_o(EX_RegWr_en));
riscv_pipe IDEX_memWr_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_memWr_en), .Q_o(EX_memWr_en));
riscv_pipe IDEX_memRd_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_memRd_en), .Q_o(EX_memRd_en));
riscv_pipe #(`dw) IDEX_rs2_data(.clk_i(clk_i), .rst_i(rst_i), .stall_i(IDEX_stall), .flush_i(IDEX_flush), .D_i(ID_RegData2), .Q_o(EX_rs2_data));

//----------------------------
// EX: Excution STAGE
//----------------------------
wire [3:0] EX_AluCtl;
riscv_aluctrl unit_aluctrl_EX
    (
        .opcode_i(EX_opcode),
        .funct3_i(EX_Func3),
        .funct7_i(EX_Func7),
        .AluCtl_o(EX_AluCtl)
    );

wire [`dw-1:0] EX_AluOut;

riscv_alu unit_alu_EX
    (
        .AluCtl_i(EX_AluCtl),
        .A_i(EX_operand1),
        .B_i(EX_operand2),
        .AluOut_o(EX_AluOut)
    );

//------------------------------
// EX/MEM PIPELINE
//------------------------------

wire MEM_memWr_en;
wire MEM_memRd_en;
wire [`dw-1:0] MEM_rs2_data;

wire [`dw-1:0] MEM_AluOut;
wire [4:0] MEM_RegRd;
wire [`dw-1:0] MEM_RegWrData;
wire MEM_RegWr_en;

wire [2:0] MEM_Func3;
wire [6:0] MEM_Func7;

riscv_pipe #(`dw) EXMEM_AluOut(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_AluOut), .Q_o(MEM_AluOut));
riscv_pipe #(5) EXMEM_RegRd(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_RegRd), .Q_o(MEM_RegRd));
riscv_pipe EXMEM_RegWr_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_RegWr_en), .Q_o(MEM_RegWr_en));
riscv_pipe EXMEM_memWr_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_memWr_en), .Q_o(MEM_memWr_en));
riscv_pipe EXMEM_memRd_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_memRd_en), .Q_o(MEM_memRd_en));
riscv_pipe #(`dw) EXMEM_rs2_data(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_rs2_data), .Q_o(MEM_rs2_data));
riscv_pipe #(3) EXMEM_funct3(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_Func3), .Q_o(MEM_Func3));
riscv_pipe #(7) EXMEM_funct7(.clk_i(clk_i), .rst_i(rst_i), .stall_i(EXMEM_stall), .flush_i(EXMEM_flush), .D_i(EX_Func7), .Q_o(MEM_Func7));
//------------------------------
// MEM: Memory STAGE
//------------------------------

wire [`dw-1:0] MEM_mem_addr;
wire [`dw-1:0] MEM_mem_WrData;
wire [`dw-1:0] MEM_mem_RdData;

wire [`dw-1:0] data_addr_o;
wire [`dw-1:0] data_data_o; //The data to write into data memory
wire [`dw-1:0]data_data_i; //The data read from data memory
wire data_Rd_en_o;
wire data_Wr_en_o;

assign data_addr_o = MEM_AluOut; //Load/Store addr = Reg(s1)+imm
assign data_data_o = MEM_rs2_data;
assign data_Rd_en_o = MEM_memRd_en;
assign data_Wr_en_o = MEM_memWr_en;

//------------------------------
// MEM/WB PIPELINE
//------------------------------
wire [`dw-1:0] WB_mem2reg;

wire [2:0] WB_Func3;
wire [6:0] WB_Func7;

riscv_pipe #(`dw) MEMWB_AluOut(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_AluOut), .Q_o(WB_AluOut));
riscv_pipe #(5) MEMWB_RegRd(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_RegRd), .Q_o(WB_RegRd));
riscv_pipe MEMWB_RegWr_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_RegWr_en), .Q_o(WB_RegWr_en));
riscv_pipe #(`dw) MEMWB_RegWr_data(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(data_data_i), .Q_o(WB_mem2reg));
riscv_pipe MEMWB_memRd_en(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_memRd_en), .Q_o(WB_memRd_en));
riscv_pipe #(3) MEMWB_funct3(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_Func3), .Q_o(WB_Func3));
riscv_pipe #(7) MEMWB_funct7(.clk_i(clk_i), .rst_i(rst_i), .stall_i(MEMWB_stall), .flush_i(MEMWB_flush), .D_i(MEM_Func7), .Q_o(WB_Func7));

//------------------------------
// WB: Write Back STAGE
//------------------------------
wire [`dw-1:0] WB_mem2reg_real;

assign WB_mem2reg_real = (WB_Func3==3'b001) ? {{16{WB_mem2reg[15]}},WB_mem2reg[15:0]} : WB_mem2reg;

assign WB_RegWrData = (WB_memRd_en)? WB_mem2reg_real : WB_AluOut; //select which data to write into regfile;


//-------------------------------
// The pipeline controller
//-------------------------------
//wire IFID_stall, IDEX_stall, EXMEM_stall, WB_stall;
//wire IFID_flush, IDEX_flush, EXMEM_flush, WB_flush;

riscv_pipe_ctrl unit_riscv_pipe_ctrl(
            /*Input*/
            .ID_rs1_i(ID_RegRs1), .ID_rs2_i(ID_RegRs2),
            .EX_rd_i(EX_RegRd), .EX_RegWr_en(EX_RegWr_en),
            .MEM_rd_i(MEM_RegRd), .MEM_RegWr_en(MEM_RegWr_en),
            .WB_rd_i(WB_RegRd), .WB_RegWr_en(WB_RegWr_en),
            .ID_Branch_en_i(ID_Branch_en), .EX_opcode_i(EX_opcode),
             /*Output*/
            .PC_stall_o(PC_stall), .IFID_stall_o(IFID_stall), .IDEX_stall_o(IDEX_stall), .EXMEM_stall_o(EXMEM_stall), .WB_stall_o(MEMWB_stall),
            .IFID_flush_o(IFID_flush), .IDEX_flush_o(IDEX_flush), .EXMEM_flush_o(EXMEM_flush), .WB_flush_o(MEMWB_flush)
        );
endmodule