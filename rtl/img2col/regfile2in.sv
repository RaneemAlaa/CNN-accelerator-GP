module regfile2in #(
     parameter data_width = 16,
               reg_num    = 5,
               address_num= 5
) (
    input  logic clk, nrst,  r_ctrl,wr_ctrl,
    input  logic [data_width-1:0] in1, 
    input  logic [address_num-1:0] adrs_in1, adrs_in2,                   //address bus
    output logic [data_width-1:0] out [reg_num-1:0]// original was [4:0] but it's connection with out_g is fatal error cause out_g is [24:0]
);
   logic [data_width-1:0] registers [reg_num-1:0]; // original was [4:0] but it's connection with  out_g is fatal error cause out_g is [24:0]

  always_ff @ (posedge clk, negedge nrst) 
  begin
    if (!nrst)
    begin
      for (int i = 0; i < reg_num; i = i + 1)
        registers[i] <= 16'h0;                          // clear register file
    end
		else
      begin
        registers[adrs_in1] <= (wr_ctrl && !r_ctrl) ? in1 : registers[adrs_in1];
        out <= (r_ctrl && !wr_ctrl ) ? registers : out;
      end
  end
endmodule
