module weight_array #(
  parameter col=32,
  data_width  = 16
) (
  input  logic  clk, nrst,
  input  logic  [col-1:0] out_en, fifo_en,
  input  logic  [31:0] weight_in,           //from AXI
  output logic  [data_width-1:0] weight_out,
  output logic  out_vld
);
  genvar i;
  generate
    for (i = 0; i < col; i = i + 1)
    begin
      weight_buffer fifo(.clk(clk), 
                         .nrst(nrst),
                         .fifo_en(fifo_en[i]),
                         .out_en(out_en[i]),
                         .data_in(weight_in),
                         .data_out(weight_out),
                         .out_vld(out_vld));
    end
  endgenerate
endmodule