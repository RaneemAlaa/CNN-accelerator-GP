module weight_buffer #(
  parameter data_width = 16
) (
  input  logic  clk, nrst, weight_en, out_en,
  input  logic  [31:0] data_in,           //from AXI
  output logic  [data_width-1:0] data_out,
  output logic out_vld
);

logic [223:0] store;      // 15 elements * 16 bits = 224
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
    if (weight_en)
    begin
      store[ in_idx +: 32] <= data_in;      //store 2 elements
      in_idx <= (in_idx + 32) % 224;
    end
    out_vld <= (bit_count >= 16 || weight_en);
    if (out_vld)
    begin
      out_idx <= (out_idx + 16) % 224;
    end
  end
end

always_comb begin
  next_bit_count = bit_count;
  if (weight_en) 
  begin
    next_bit_count += 32;
  end
  if (bit_count >= 16 || weight_en)
  begin
    next_bit_count -= 16;
  end
end

assign data_out = out_en? store[ out_idx +: 16 ] : data_out;
  
endmodule