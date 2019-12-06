// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: Top Level Module

module top #(
  parameter ADDRESS_BITS = 16
) (
  input clock,
  input reset,

  output [31:0] wb_data
);


/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

// Fetch Wires
wire next_PC_select;
wire [ADDRESS_BITS-1:0] target_PC;
wire [ADDRESS_BITS-1:0] PC;

// Decode Wires
wire [31:0] instruction;
wire branch;
wire [4:0] read_sel1;
wire [4:0] read_sel2;
wire [4:0] write_sel;
wire wEn;
wire branch_op;
wire [31:0] imm32;
wire [1:0] op_A_sel;
wire op_B_sel;
wire [5:0] ALU_Control;
wire mem_wEn;
wire wb_sel;

// Reg File Wires
wire [31:0] read_data1;
wire [31:0] read_data2;
//wire [31:0] write_data;

// Execute Wires
wire [31:0] JALR_32;
wire [ADDRESS_BITS-1:0] JALR_target; // Assigned outside of ALU // HOW IS JALR_TARGET 16 bit output from ALU
wire [31:0] ALU_Result;
wire [31:0] operand_A;
wire [31:0] operand_B;
wire [31:0] wb_data_reg;

assign operand_A =  (op_A_sel == 2'b00) ? read_data1 : 
                    (op_A_sel == 2'b01) ? PC : 
                    (op_A_sel == 2'b10) ? PC+4 : read_data1;
                    
assign operand_B = (op_B_sel == 1'b0) ? read_data2 : imm32;

// Memory Wires
wire [31:0] d_read_data;

// Writeback wires
assign wb_data = wb_data_reg;
assign wb_data_reg = (wb_sel == 1'b1) ? d_read_data : ALU_Result;

assign JALR_target = JALR_32[15:0];
assign JALR_32 = imm32 + read_data1;

fetch #(
  .ADDRESS_BITS(ADDRESS_BITS)
) fetch_inst (
  .clock(clock),
  .reset(reset),
  .next_PC_select(next_PC_select),
  .target_PC(target_PC),
  .PC(PC)
);


decode #(
  .ADDRESS_BITS(ADDRESS_BITS)
) decode_unit (

  // Inputs from Fetch
  .PC(PC),
  .instruction(instruction),

  // Inputs from Execute/ALU
  .JALR_target(JALR_target), // 16 bits vs 32 bits
  .branch(branch),

  // Outputs to Fetch
  .next_PC_select(next_PC_select),
  .target_PC(target_PC),

  // Outputs to Reg File
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .wEn(wEn),

  // Outputs to Execute/ALU
  .branch_op(branch_op),
  .imm32(imm32),
  .op_A_sel(op_A_sel),
  .op_B_sel(op_B_sel),
  .ALU_Control(ALU_Control),

  // Outputs to Memory
  .mem_wEn(mem_wEn),

  // Outputs to Writeback
  .wb_sel(wb_sel)

);


regFile regFile_inst (
  .clock(clock),
  .reset(reset),
  .wEn(wEn), // Write Enable
  .write_data(wb_data),
  .read_sel1(read_sel1),
  .read_sel2(read_sel2),
  .write_sel(write_sel),
  .read_data1(read_data1),
  .read_data2(read_data2)
);



ALU alu_inst(
  .branch_op(branch_op),
  .ALU_Control(ALU_Control),
  .operand_A(operand_A),
  .operand_B(operand_B),
  .ALU_result(ALU_Result),
  .branch(branch)
);


ram #(
  .ADDR_WIDTH(ADDRESS_BITS)
) main_memory (
  .clock(clock),

  // Instruction Port
  .i_address(PC >> 2),
  .i_read_data(instruction),

  // Data Port
  .wEn(mem_wEn),
  .d_address(ALU_Result[15:0]),
  .d_write_data(read_data2),
  .d_read_data(d_read_data)
);

endmodule