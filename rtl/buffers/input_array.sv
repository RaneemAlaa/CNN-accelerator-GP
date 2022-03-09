module input_buffer #(
  parameter data_width = 16 ,I=0
) (
  input  logic  clk, nrst, fifo_en,
  input  logic  [31:0] data_in,           //from AXI
  output logic  [data_width-1:0] data_out,
  output logic out_vld
);

logic [I:0] store;      // 1 element * 16 bits = 224
logic  [7:0]bit_count,next_bit_count,in_idx,out_idx;

always_ff @(posedge clk, negedge nrst) begin
  if (!nrst) 
  begin
    in_idx <= '0;             // input pointer
    out_idx <= '0;            // output pointer
    bit_count <= '0;          // number of stored bits
    out_vld <= 1'b0;
  end
  else 
  begin
    bit_count <= next_bit_count;
    if (fifo_en)
    begin
      store[ in_idx +: 32] <= data_in;      //store 2 elements
      in_idx <= (in_idx + 32);
      if (in_idx == 192)
      begin
        in_idx <= 0;  
      end
    end
    out_vld <= (bit_count >= 16 || fifo_en);
    if (out_vld)
    begin
      out_idx <= (out_idx + 16);
      if (out_idx == 208)
      begin
        out_idx <= 0;  
      end
    end
  end
end

always_comb begin
  next_bit_count = bit_count;
  if (fifo_en) 
  begin
    next_bit_count += 32;
  end
  if (bit_count >= 16 || fifo_en)
  begin
    next_bit_count -= 16;
  end
end

assign data_out = store[ out_idx +: 16 ];
  
endmodule

module input_array#(
    
parameter I=0) (
    input  var[15:0] data_in [31:0] ,
    input logic [31:0]out_vld,
    input logic fifo_en,clk,nrst,
    output var [15:0] data_out [31:0]
);

genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) 
    begin:input_buffer
      input_buffer #(.I(i)) input_buffer (
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