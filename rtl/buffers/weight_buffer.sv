module weight_buffer #(
  parameter data_width = 16
) (
  input  logic  clk, nrst, fifo_en,
  input  logic  [4:0] weight_dim,
  input  logic  [31:0] data_in,           //from AXI
  output logic  [data_width-1:0] data_out,
  output logic  out_vld,pe_en
);

logic [223:0] store;      // 15 elements * 16 bits = 224
logic [7:0] bit_count, next_bit_count, in_idx, out_idx;
logic [4:0] next_element_count, current_element_count;

always_ff @(posedge clk, negedge nrst) begin
  if (!nrst) 
  begin
    in_idx    <= '0;             // input pointer
    out_idx   <= '0;            // output pointer
    bit_count <= '0;          // number of stored bits
    out_vld   <= 1'b0;
    store     <= '0;
    pe_en     <= 1;
    next_element_count <= 0;
  end
  else 
  begin
    bit_count <= next_bit_count;
    current_element_count <= next_element_count;
    if (fifo_en)
    begin
      store[ in_idx +: 32] <= data_in;      //store 2 elements
      in_idx <= (in_idx + 32);
      if (in_idx > 224)
      begin
        in_idx <= 0;  
      end
    end
    out_vld <= (bit_count >= 16 || fifo_en);
    if (out_vld)
    begin
      out_idx <= (out_idx + 16);
      next_element_count <= next_element_count + 1;
      if (out_idx > 224)
      begin
        out_idx <= 0;  
      end
      pe_en = (next_element_count == weight_dim)? 0 : 1;
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

assign data_out = store[ out_idx +: 16 ] ;
  
endmodule