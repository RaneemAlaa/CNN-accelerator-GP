module input_array#(
    parameter I=16
 )(
    input  var  [15:0] data_in [24:0] ,
    input logic [24:0]out_vld,
    input logic fifo_en,clk,nrst,
    output var  [15:0] data_out [24:0]
);
always_ff @(posedge clk) begin
  if(fifo_en) begin
    data_out[0] <= data_in[0];
  end else begin
    data_out[0] <=0 ;
  end
end
genvar i;
  generate
    for (i = 1; i < 25; i = i + 1) 
    begin:input_buffer
      input_buffer #(.I((i+1)*16)) input_buffer (
        .clk(clk),
        .nrst(nrst),
        .fifo_en(fifo_en),
        .data_in(data_in[i]),
        .data_out(data_out[i]),
        .out_vld(out_vld[i])
    );
    end 
endgenerate  
endmodule 