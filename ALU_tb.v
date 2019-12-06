// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: ALU Test Bench

module ALU_tb();
reg branch_op;
reg [5:0] ctrl;
reg [31:0] opA, opB;

wire [31:0] result;
wire branch;

ALU dut (
  .branch_op(branch_op),
  .ALU_Control(ctrl),
  .operand_A(opA),
  .operand_B(opB),
  .ALU_result(result),
  .branch(branch)
);

initial begin
  branch_op = 1'b0;
  ctrl = 6'b000000;
  opA = 4;
  opB = 5;

  #10
  $display("ALU Result 4 + 5 (9): %d",result); // add addi lw sw lui auipc
  #10
  
  ctrl = 6'b000010;
  #10
  $display("ALU Result 4 < 5 (1): %d",result); // SLTI
  #10
  opB = 32'hffffffff;
  #10
  $display("ALU Result 4 < -1 (0): %d",result); // SLTI


/******************************************************************************
*                      Add Test Cases Here
******************************************************************************/


  branch_op = 1'b0;
  opB = 6;
  opA = 9;
  ctrl = 6'b001000; // SUB
  #10
  $display("ALU Result 9 - 6 (3): %d",result);
  $display("Branch (0): %b", branch);

  branch_op = 1'b1;
  opB = 32'hffffffff;
  opA = 32'hffffffff;
  ctrl = 6'b010_000; // BEQ
  #10
  $display("ALU Result (BEQ): %d",result);
  $display("Branch (should be 1): %b", branch);
  
  branch_op = 1'b0;
  opB = 12;
  opA = 6;
  ctrl = 6'b000100; // b/w XOR
  #10
  $display("ALU Result 1100 (12) ^ 0110 (6) (should be 10): %d",result);
  $display("Branch (0): %b", branch);
  
  branch_op = 1'b0;
  opB = 10;
  opA = 5;
  ctrl = 6'b000111; // b/w AND
  #10
  $display("ALU Result 1010 (10) & 0101 (5) (should be 0): %d",result);
  $display("Branch (should be 0): %b", branch);
  
  branch_op = 1'b0;
  opB = 2;
  opA = 4;
  ctrl = 6'b000001; // SLL
  #10
  $display("ALU Result 100 << 2 (16): %d",result);
  $display("Branch (should be 0): %b", branch);  
  
  branch_op = 1'b0;
  opB = 3;
  opA = 66;
  ctrl = 6'b000101; // SRL - right logical
  #10
  $display("ALU Result 1000010 >> 3 (8): %d",result);
  $display("Branch (should be 0): %b", branch);  
  
  branch_op = 1'b0;
  opB = 3;
  opA = -66;
  ctrl = 6'b001101; // SRAI - shift right immediate
  #10
  $display("ALU Result -66 >> 3 (MAX-8): %d",result);
  $display("Branch (should be 0): %b", branch);  
  
  branch_op = 1'b0;
  opB = 17;
  opA = 30;
  ctrl = 6'b000110; // ORI
  #10
  $display("ALU Result 10001 | 11110 (31): %d",result);
  $display("Branch (should be 0): %b", branch);  
  
  branch_op = 1'b0;
  opB = 13;
  opA = 13;
  ctrl = 6'b000000; // ADD
  #10
  $display("ALU Result 13 + 13 (26): %d",result);
  $display("Branch (0): %b", branch);
  
  branch_op = 1'b1;
  opB = 32'hfffffffa;
  opA = 32'hffffffff;
  ctrl = 6'b010001; // bne T
  #10
  $display("ALU Result (BNE TRUE): %d",result);
  $display("Branch (should be 1): %b", branch);
  
  branch_op = 1'b1;
  opB = 32'hffffffff;
  opA = 32'hffffffff;
  ctrl = 6'b010001; // bne F
  #10
  $display("ALU Result (BNE FALSE): %d",result);
  $display("Branch (should be 0): %b", branch);   
  
  branch_op = 1'b1;
  opB = 31;
  opA = 32;
  ctrl = 6'b010101; // BGE
  #10
  $display("ALU Result (branch if 32 >= 31): %d",result);
  $display("Branch (should be 1): %b", branch);  

  branch_op = 1'b0;
  opB = 31;
  opA = 32;
  ctrl = 6'b111111; // JALR
  #10
  $display("ALU Result (pass 32 through): %d",result);
  $display("Branch (should be 0): %b", branch);

  
  branch_op = 1'b0;
  opB = 8;
  opA = 10;
  ctrl = 6'b000000; // ADD
  #10
  $display("ALU Result 10 + 8 (18): %d",result);
  $display("Branch (0): %b", branch);
  
  #10
  $stop();

end

endmodule
