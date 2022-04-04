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

module input_array#(
    parameter I=16
 )(
    input  var  [15:0] data_in [31:0] ,
    input logic [31:0]out_vld,
    input logic fifo_en,clk,nrst,
    output var  [15:0] data_out [31:0]
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
    for (i = 1; i < 32; i = i + 1) 
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
