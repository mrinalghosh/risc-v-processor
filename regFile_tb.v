// Name: Mrinal Ghosh - Alex Trinh
// BU ID: U33402990 - U58960291
// EC413 Project: Register File Test Bench

module regFile_tb();


/******************************************************************************
*                      Start Your Code Here
******************************************************************************/
// Test reading and writing to the register file here

wire [31:0] read_data1;
wire [31:0] read_data2;

reg clock;
reg reset;
reg wEn;
reg [4:0] read_sel1;
reg [4:0] read_sel2;
reg [4:0] write_sel;
reg [31:0] write_data;

initial begin
  clock = 1'b1;
  reset = 1'b1;
  
  //write first
  #30;
  reset = 1'b0;
  wEn = 1'b1;
  write_sel = 5'b11001;
  read_sel1 = 5'b11001;
  write_data = 32'hDEADBEEF;
  #10
  write_sel = 5'b10000;
  write_data = 32'hBEEFDEAD;
  #10
  write_sel = 5'b01111;
  write_data = 32'hFEEDBEAD;
  #10
  write_sel = 5'b00100;
  write_data = 32'hBADDADFF;
  #10
  wEn = 1'b0;
  #10
  read_sel1 = 5'b10000;
  read_sel2 = 5'b01111;
  #20
  
  wEn = 1'b1;
  write_sel = 5'b00001;
  write_data = 32'hFACADE;
  read_sel1 = 5'b00001;
  #10
  wEn = 1'b0;
  #10
  read_sel1 = 5'b00000;
  read_sel2 = 5'b00000;
  
end


always begin
    #15
    write_data <= write_data + 1'b1;
end

endmodule
