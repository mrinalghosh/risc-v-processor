// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: ALU

module ALU (
  input branch_op,
  input [5:0]  ALU_Control,
  input [31:0] operand_A,
  input [31:0] operand_B,
  output [31:0] ALU_result,
  output branch
);

assign ALU_result =     ALU_Control == 6'b000000 ? (operand_A + operand_B) :
                        ALU_Control == 6'b001000 ? (operand_A - operand_B) :
                        ALU_Control == 6'b000010 ? ($signed(operand_A) < $signed(operand_B)) :
                        ALU_Control == 6'b000011 ? (operand_A < operand_B) :
                        ALU_Control == 6'b000100 ? (operand_A ^ operand_B) :
                        ALU_Control == 6'b000111 ? (operand_A & operand_B) :
                        ALU_Control == 6'b000001 ? (operand_A << operand_B[4:0]) :
                        ALU_Control == 6'b000101 ? (operand_A >> operand_B[4:0]) :
                        ALU_Control == 6'b001101 ? ($signed(operand_A) >> operand_B[4:0]) :
                        ALU_Control == 6'b000110 ? (operand_A | operand_B) :
                        ALU_Control == 6'b010000 ? (operand_A + operand_B) :
                        ALU_Control == 6'b010001 ? (operand_A + operand_B) :
                        ALU_Control == 6'b010100 ? (operand_A + operand_B) :
                        ALU_Control == 6'b010101 ? (operand_A + operand_B) :
                        ALU_Control == 6'b010110 ? (operand_A + operand_B) :
                        ALU_Control == 6'b010111 ? (operand_A + operand_B) :
                        ALU_Control == 6'b011111 ? (operand_A) :
                        ALU_Control == 6'b111111 ? (operand_A) : (operand_A + operand_B);

assign branch =     ALU_Control == 6'b000000 ? 0 :
                    ALU_Control == 6'b001000 ? 0 :
                    ALU_Control == 6'b000010 ? 0 :
                    ALU_Control == 6'b000011 ? 0 :
                    ALU_Control == 6'b000100 ? 0 :
                    ALU_Control == 6'b000111 ? 0 :
                    ALU_Control == 6'b000001 ? 0 :
                    ALU_Control == 6'b000101 ? 0 :
                    ALU_Control == 6'b001101 ? 0 :
                    ALU_Control == 6'b000110 ? 0 :
                    ALU_Control == 6'b010000 ? ((operand_A == operand_B) ? 1 : 0) :
                    ALU_Control == 6'b010001 ? ((operand_A != operand_B) ? 1 : 0) :
                    ALU_Control == 6'b010100 ? (($signed(operand_A) < $signed(operand_B)) ? 1 : 0) :
                    ALU_Control == 6'b010101 ? (($signed(operand_A) >= $signed(operand_B)) ? 1 : 0) :
                    ALU_Control == 6'b010110 ? ((operand_A < operand_B) ? 1 : 0) :
                    ALU_Control == 6'b010111 ? ((operand_A >= operand_B) ? 1 : 0) :
                    ALU_Control == 6'b011111 ? 0 :
                    ALU_Control == 6'b111111 ? 0 : 0;

endmodule