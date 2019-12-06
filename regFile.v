// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: Register File

module regFile (
  input clock,
  input reset,
  input wEn, // Write Enable
  input [31:0] write_data,
  input [4:0] read_sel1,
  input [4:0] read_sel2,
  input [4:0] write_sel,
  output [31:0] read_data1,
  output [31:0] read_data2
);

reg   [31:0] reg_file[0:31];

/******************************************************************************
*                      Start Your Code Here
******************************************************************************/

initial reg_file[0] = 0; // x0 hardwired to 0

assign read_data1 = reg_file[read_sel1]; // output read1
assign read_data2 = reg_file[read_sel2]; // output read2

integer i;

always @(posedge clock) begin
    if (reset) begin // rewrite all registers to 0
        for (i = 0; i < 32; i = i + 1) begin
            reg_file[i] <= 32'b00000000000000000000000000000000;
        end
    end 
    
    else begin // register write to selected address if not reset
        if ((wEn==1'b1) && (write_sel!=5'b00000)) // if write enabled
            reg_file[write_sel] <= write_data;
    end
end

endmodule
