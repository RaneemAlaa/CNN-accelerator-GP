module regfilePooling#(
    parameter data_width = 16 ,
    reg_num = 16 , 
    address_num = 4 
)(
    input  logic clk, nrst, wr_ctrl1,wr_ctrl2,
    input  logic [data_width-1:0] in1,in2 , 
    input  logic [address_num-1:0] adrs_in1, adrs_in2 , adrs_out , 
    output logic [data_width-1:0] out
);


logic [data_width-1:0] registers [reg_num-1:0];

always_ff @ (posedge clk, negedge nrst) 
  begin
    if (!nrst)
    begin
      for (int i = 0; i < reg_num; i = i + 1)
        registers[i] <= 16'h0;                          // clear register file
    end
        else
      begin
        registers[adrs_in1] <= (wr_ctrl ) ? in1 : registers[adrs_in1];
        registers[adrs_in2] <= (wr_ctrl ) ? in2 : registers[adrs_in2];
        out <= registers[adrs_out] ;  
      end
  end

endmodule 
