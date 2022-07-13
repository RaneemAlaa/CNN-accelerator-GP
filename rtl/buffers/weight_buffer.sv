module weight_buffer #(
  parameter data_width = 16
) (
  input  logic  clk, nrst, 
  input  logic  fifo_en,                    //!control signal to enable the FIFO storing the weight
  input  logic  [4:0] weight_dim,
  input  logic  [31:0] data_in,            //!weight from AXI
  output logic  [data_width-1:0] data_out, //!weights to systolic array
  output logic  out_vld,                   //!control signal that indicate the output is ready so the output pointer changes its position 
  output logic  pe_en                      //!control the systolic to enable or disenable for taking the weight 
);

logic [415:0] store;      //!15 elements * 16 bits = 224 >>>>> 13 element * 32 bits = 416
logic [9:0] bit_count, next_bit_count; //! number of bits stored in FIFO
logic [9:0] in_idx;       //!input pointer
logic [9:0] out_idx;      //!output pointer
logic [4:0] next_element_count, current_element_count;  //! number of elements stored in FIFO

always_ff @(posedge clk, negedge nrst) begin
  if (!nrst) 
  begin
    in_idx    <= '0;             
    out_idx   <= '0;
    bit_count <= '0;
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
      if (in_idx == 384)                  //223-32 >> 416-32
      begin
        in_idx <= 0;  
      end
    end
    out_vld <= (next_bit_count > 16 || fifo_en);
    if (out_vld)
    begin
      out_idx <= (out_idx + 16);
      next_element_count <= current_element_count + 1;
      if (out_idx == 400)               //223-16 >> 416 -16
      begin
        out_idx <= 0;  
      end
      pe_en = (next_element_count >= (weight_dim/2 +1))? 0 : 1;  // count increase each 2 clock cycle 
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