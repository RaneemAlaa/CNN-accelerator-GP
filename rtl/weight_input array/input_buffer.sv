module input_buffer #(
  parameter data_width = 16 ,I=32
) (
  input  logic  clk, nrst, fifo_en,
  input  logic  [data_width-1:0] data_in,           //from AXI
  output logic  [data_width-1:0] data_out,
  output logic out_vld
);

logic [I-1:0] store;      // 1 element * 16 bits
logic  [8:0]bit_count,next_bit_count,in_idx,out_idx;
logic out_en;

always_ff @(posedge clk, negedge nrst) begin
  if (!nrst) 
  begin
    in_idx <= '0;             // input pointer
    out_idx <= '0;            // output pointer
    bit_count <= '0;          // number of stored bits
    out_vld <= 1'b0;
    out_en <= 1'b0;   
    store <= '{default:0};
  end
  else 
  begin
    bit_count <= next_bit_count;
    if (fifo_en)
    begin
      store[ in_idx +: data_width] <= data_in;      //store 1 element
      in_idx <= (in_idx + data_width);
      if (in_idx == (I-data_width))
      begin
        in_idx <= 0; 
      end
      if (in_idx == (I-2*data_width))
      begin
        out_en <=1; 
      end
      
    end
    out_vld <= out_en;
    if (out_vld)
    begin
      out_idx <= (out_idx + 16);
      if (out_idx == (I-data_width))
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
    next_bit_count += data_width;
  end
  if (bit_count >= 16 || fifo_en)
  begin
    next_bit_count -= 16;
  end
end

assign data_out = out_vld? store[ out_idx +: 16]: '0;
endmodule