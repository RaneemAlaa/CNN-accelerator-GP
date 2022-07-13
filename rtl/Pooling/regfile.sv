module regfilePooling#(
    parameter data_width = 16 ,
    reg_num = 16 , 
    address_num = 4 
)(
    input  logic clk, nrst, wr_ctrl1,wr_ctrl2,
    input  logic [data_width-1:0] in1,in2, 
    input  logic [address_num-1:0] adrs_in, adrs_out , 
    output reg [data_width-1:0] out
);


logic [data_width-1:0] registers [reg_num-1:0];

/*always_ff @ (negedge clk, negedge nrst) 
  begin
    if (!nrst)
    begin
        registers <= '{default:0};                          // clear register file
    end
        else
      begin
        registers[adrs_in] = (wr_ctrl2 ) ? in2 : registers[adrs_in];
        registers[4'hf] = (wr_ctrl1 ) ? in1 : registers[4'hf];
        out <= registers[adrs_out] ;   
      end
  end*/
  always_latch begin 
    if (!nrst) begin
        registers <= '{default:0};                          // clear register file
    end
    else if (!clk) begin
        registers[adrs_in] = (wr_ctrl2 ) ? in2 : registers[adrs_in];
        registers[4'hf] = (wr_ctrl1 ) ? in1 : registers[4'hf];
        out <= registers[adrs_out] ;   
    end
  end
endmodule