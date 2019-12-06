// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: Decode Module

module decode #(
  parameter ADDRESS_BITS = 16
) (
  // Inputs from Fetch
  input [ADDRESS_BITS-1:0] PC,
  input [31:0] instruction,

  // Inputs from Execute/ALU
  input [ADDRESS_BITS-1:0] JALR_target,
  input branch,

  // Outputs to Fetch
  output next_PC_select,
  output [ADDRESS_BITS-1:0] target_PC,

  // Outputs to Reg File
  output [4:0] read_sel1,
  output [4:0] read_sel2,
  output [4:0] write_sel,
  output wEn,

  // Outputs to Execute/ALU
  output branch_op, // Tells ALU if this is a branch instruction
  output [31:0] imm32,
  output [1:0] op_A_sel,
  output op_B_sel,
  output [5:0] ALU_Control,

  // Outputs to Memory
  output mem_wEn,

  // Outputs to Writeback
  output wb_sel

);

localparam [6:0]R_TYPE  = 7'b0110011,
                I_TYPE  = 7'b0010011,
                STORE   = 7'b0100011,
                LOAD    = 7'b0000011,
                BRANCH  = 7'b1100011,
                JALR    = 7'b1100111,
                JAL     = 7'b1101111,
                AUIPC   = 7'b0010111,
                LUI     = 7'b0110111;


// These are internal wires that I used. You can use them but you do not have to.
// Wires you do not use can be deleted.
wire[6:0]  s_imm_msb;
wire[4:0]  s_imm_lsb;
wire[19:0] u_imm;
wire[11:0] i_imm_orig;
wire[19:0] uj_imm;
wire[11:0] s_imm_orig;
wire[12:0] sb_imm_orig;
wire[19:0] lui_imm;

wire[31:0] sb_imm_32;
wire[31:0] u_imm_32;
wire[31:0] i_imm_32;
wire[31:0] s_imm_32;
wire[31:0] uj_imm_32;
wire[31:0] lui_imm_32;

wire [6:0] opcode;
wire [6:0] funct7;
wire [2:0] funct3;
wire [1:0] extend_sel;
wire [ADDRESS_BITS-1:0] branch_target;
wire [ADDRESS_BITS-1:0] JAL_target;

//// Read registers
assign read_sel2  = instruction[24:20];
assign read_sel1  = (opcode == LUI) ? 5'b0 : instruction[19:15];

assign target_PC =  (opcode == BRANCH) ? sb_imm_32 + PC :
                    (opcode == JALR) ? {{JALR_target[15:1]}, 1'b0} :
                    PC + imm32;

///* Instruction decoding */
assign opcode = instruction[6:0];
assign funct7 = instruction[31:25];
assign funct3 = instruction[14:12];

///* Write register */
assign write_sel = instruction[11:7];

// Sign Extend
//assign imm32 = { {20{instruction[31]}}, instruction[31:20]};

/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

assign s_imm_msb = instruction[31:25];
assign s_imm_lsb = instruction[11:7];
assign u_imm = instruction[31:12];
assign i_imm_orig = instruction[31:20];
assign uj_imm = {instruction[31],instruction[19:12],instruction[20],instruction[30:21]};
assign s_imm_orig = {s_imm_msb,s_imm_lsb};
assign sb_imm_orig = {instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};

wire [4:0] shamt;
wire [31:0] shamt32;

assign shamt = i_imm_orig[4:0];
assign shamt32 = {{27{1'b0}},shamt};
assign lui_imm = instruction[31:12];
assign lui_imm_32 = { lui_imm, 12'b0 };

assign sb_imm_32 = {{19{sb_imm_orig[11]}}, sb_imm_orig};
assign u_imm_32 = { {12{u_imm[19]}},u_imm };
assign i_imm_32 = {{20{i_imm_orig[11]}}, i_imm_orig};
assign s_imm_32 = {{20{s_imm_orig[11]}}, s_imm_orig};
assign uj_imm_32 = { {11{u_imm[19]}}, {u_imm[19]},{u_imm[7:0]},{u_imm[8]},{u_imm[18:9]},1'b0};


assign ALU_Control = (opcode == R_TYPE) ? ( (funct3 == 3'b000) ?  ( (funct7 == 7'b0000000) ? 6'b000000 : 6'b001000 ) :
                                        (funct3 == 3'b001) ? 6'b000001 :
                                        (funct3 == 3'b010) ? 6'b000010 :
                                        (funct3 == 3'b011) ? 6'b000010 :
                                        (funct3 == 3'b100) ? 6'b000100 :
                                        (funct3 == 3'b101) ? ( (funct7 == 6'b000000) ? 6'b000101 : 6'b001101 ) :
                                        (funct3 == 3'b110) ? 6'b000110 :
                                        (funct3 == 3'b111) ? 6'b000111 : 6'b000000) :
                     (opcode == I_TYPE) ? ( (funct3 == 3'b000) ?  6'b000000 : //addi
                                        (funct3 == 3'b001) ? 6'b000001 : //slli
                                        (funct3 == 3'b010) ? 6'b000011 : //slti 
                                        (funct3 == 3'b011) ? 6'b000011 : //sltiu
                                        (funct3 == 3'b100) ? 6'b000100 : //xori
                                        (funct3 == 3'b101) ? ( (funct7 == 6'b010000) ? 6'b001101 : 6'b000101 ) : //srai srli
                                        (funct3 == 3'b110) ? 6'b000110 : //ori
                                        (funct3 == 3'b111) ? 6'b000111 : 6'b000000):
                     (opcode == STORE) ? ( (funct3 == 3'b010) ? 6'b000000 : 6'b000000) :
                     (opcode == LOAD) ? ( (funct3 == 3'b010) ? 6'b000000 : 6'b000000) :
                     (opcode == BRANCH) ? ( (funct3 == 3'b000) ? 6'b010000 :
                                        (funct3 == 3'b001) ? 6'b010001 :
                                        (funct3 == 3'b100) ? 6'b010100 :
                                        (funct3 == 3'b101) ? 6'b010101 :
                                        (funct3 == 3'b110) ? 6'b010110 :
                                        (funct3 == 3'b111) ? 6'b010111 : 6'b010000 ) :
                      (opcode == JALR) ? 6'b111111 :
                      (opcode == JAL) ? 6'b011111 :
                      (opcode == AUIPC) ? 6'b000000 :
                      (opcode == LUI) ? 6'b000000 : 6'b000000;


                      

assign wEn =    (opcode == R_TYPE) ? 1'b1 :
                (opcode == I_TYPE) ? 1'b1 :
                (opcode == STORE) ? 1'b0 :
                (opcode == LOAD) ? 1'b1 :
                (opcode == BRANCH) ? 1'b0 :
                (opcode == JALR) ? 1'b1 :
                (opcode == JAL) ? 1'b1 :
                (opcode == AUIPC) ? 1'b1 :
                (opcode == LUI) ? 1'b1 : 1'b1;
                
assign branch_op =  (opcode == R_TYPE) ? 1'b0 :
                    (opcode == I_TYPE) ? 1'b0 :
                    (opcode == STORE) ? 1'b0 :
                    (opcode == LOAD) ? 1'b0 :
                    (opcode == BRANCH) ? 1'b1 :
                    (opcode == JALR) ? 1'b0 :
                    (opcode == JAL) ? 1'b0 :
                    (opcode == AUIPC) ? 1'b0 :
                    (opcode == LUI) ? 1'b0 : 1'b0;

assign op_A_sel =   (opcode == R_TYPE) ? 2'b00 :
                    (opcode == I_TYPE) ? 2'b00 :
                    (opcode == STORE) ? 2'b00 :
                    (opcode == LOAD) ? 2'b00 :
                    (opcode == BRANCH) ? 2'b00 :
                    (opcode == JALR) ? 2'b10 :
                    (opcode == JAL) ? 2'b10 :
                    (opcode == AUIPC) ? 2'b01 :
                    (opcode == LUI) ? 2'b00 : 2'b00;
                
                
assign op_B_sel =   (opcode == R_TYPE) ? 1'b0 :
                    (opcode == I_TYPE) ? 1'b1 :
                    (opcode == STORE) ? 1'b1 :
                    (opcode == LOAD) ? 1'b1 :
                    (opcode == BRANCH) ? 1'b0 :
                    (opcode == JALR) ? 1'b1 :
                    (opcode == JAL) ? 1'b1 :
                    (opcode == AUIPC) ? 1'b1 :
                    (opcode == LUI) ? 1'b1 : 1'b1;
                    
                    
assign mem_wEn =    (opcode == R_TYPE) ? 1'b0 :
                    (opcode == I_TYPE) ? 1'b0 :
                    (opcode == STORE) ? 1'b1 :
                    (opcode == LOAD) ? 1'b0 :
                    (opcode == BRANCH) ? 1'b0 :
                    (opcode == JALR) ? 1'b0 :
                    (opcode == JAL) ? 1'b0 :
                    (opcode == AUIPC) ? 1'b0 :
                    (opcode == LUI) ? 1'b0 : 1'b0;
            

assign wb_sel =     (opcode == R_TYPE) ? 1'b0 :
                    (opcode == I_TYPE) ? 1'b0 :
                    (opcode == STORE) ? 1'b0 :
                    (opcode == LOAD) ? 1'b1 :
                    (opcode == BRANCH) ? 1'b0 :
                    (opcode == JALR) ? 1'b0 :
                    (opcode == JAL) ? 1'b0 :
                    (opcode == AUIPC) ? 1'b0 :
                    (opcode == LUI) ? 1'b0 : 1'b0;
                    
                    
assign next_PC_select =     (opcode == R_TYPE) ? 1'b0 :
                            (opcode == I_TYPE) ? 1'b0 :
                            (opcode == STORE) ? 1'b0 :
                            (opcode == LOAD) ? 1'b0 :
                            (branch == 1'b1) ? 1'b1 :
                            (opcode == JALR) ? 1'b1 :
                            (opcode == JAL) ? 1'b1 :
                            (opcode == AUIPC) ? 1'b0 :
                            (opcode == LUI) ? 1'b0 : 1'b0;
  
  
assign imm32 = opcode == I_TYPE && (funct3 == 3'b001 || funct3 == 3'b101) ? shamt32 :
                            opcode == I_TYPE || opcode == LOAD || opcode == JALR ? i_imm_32 :
                            opcode == AUIPC || opcode == LUI ? u_imm_32 :
                            opcode == STORE ? s_imm_32 :
                            opcode == BRANCH ? sb_imm_32 :
                            uj_imm_32;                              

endmodule
