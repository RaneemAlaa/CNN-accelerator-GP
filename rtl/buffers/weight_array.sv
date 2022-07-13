module weight_array #(
  parameter col=32,
  data_width  = 16
) (
  input  logic  clk, nrst,
  input  logic  [col-1:0] fifo_en,
  input  logic  [4:0] weight_dim,
  input  var logic   [31:0] weight_in,           //from AXI
  output logic [data_width-1:0] weight_out [col-1:0],
  output logic  [15:0] out_vld,
  output  logic  [col-1:0] out_en
);
  genvar i;
  generate
    for (i = 0; i < col; i = i + 1)
    begin
      weight_buffer fifo(.clk(clk), 
                         .nrst(nrst),
                         .fifo_en(fifo_en[i]),
                         .pe_en(out_en[i]),
                         .weight_dim(weight_dim),
                         .data_in(weight_in),
                         .data_out(weight_out[i]),
                         .out_vld(out_vld[i]));
    end
  endgenerate
endmodule