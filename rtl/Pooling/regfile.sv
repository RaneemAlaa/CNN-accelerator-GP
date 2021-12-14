module Register_File
  #(
     parameter data_width = 8
   )
  (
    input logic clk, nrst, Wr_ctrl,
    input logic [data_width-1:0] in1,in2,
    input logic [3:0] add_out,add_in1, add_in2, //address bus
    output logic [data_width-1:0] out
  );
  logic [data_width-1:0] registers [15:0];

  assign out = registers[add_out];

  always @ (posedge clk, negedge nrst) 
  begin
  registers[add_in1] = (Wr_ctrl) ? in : registers[add_in1];
  registers[add_in2] = (Wr_ctrl) ? in : registers[add_in2];
  end
endmodule