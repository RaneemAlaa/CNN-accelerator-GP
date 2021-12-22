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
      if (in_idx == 192)
      begin
        in_idx <= 0;  
      end
    end
    out_vld <= (next_bit_count > 16 || fifo_en);
    if (out_vld)
    begin
      out_idx <= (out_idx + 16);
      next_element_count <= current_element_count + 1;
      if (out_idx == 208)
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
  

  
initial
$monitor("weight_buffer:::bit_count=%d  bit_count=%d  data_in=%h store=%h,in_idx=%b  ,out_idx=%b data_out=%h , out_vld=%b",bit_count,next_bit_count,data_in,store,in_idx,out_idx,data_out,out_vld);
  
endmodule



module weight_buffer_test;

	parameter data_width = 16;
	`define delay 10

   reg  clk, nrst, fifo_en;
   reg  [4:0] weight_dim;
   reg  [31:0] data_in;        //from AXI
   wire  [data_width-1:0] data_out;
   wire  out_vld,pe_en;


weight_buffer inst(.clk(clk),
		   .nrst(nrst),
		   .fifo_en(fifo_en),
		   .weight_dim(weight_dim),
		   .data_in(data_in),
		   .data_out(data_out),
		   .out_vld(out_vld),
		   .pe_en(pe_en)
		   );

	initial clk = 1;
	always #`delay clk = ~clk;


	initial
	begin
	
	//rst
	nrst=1'b0;

	
	//store
	#(`delay*2)
	nrst=1'b1;
	fifo_en=1'b1;
	data_in=32'h0002_0001;

	
	#(`delay*2)
	data_in=32'h0004_0003;
	
	#(`delay*2)
	data_in=32'h0006_0005;

	#(`delay*2)
	data_in=32'h0008_0007;

	#(`delay*2)
	data_in=32'h000a_0009;

	#(`delay*2)
	data_in=32'h000c_000b;
	
	#(`delay*2)
	data_in=32'h000e_000d;

	#(`delay*2)
	data_in=32'h0010_000f;
	
	#(`delay*2)
	data_in=32'h0030_0020;
	
	#(`delay*2)
	data_in=32'h0050_0040;

	#(`delay*2)
	data_in=32'h0070_0060;

	#(`delay*2)
	data_in=32'h0090_0080;
	
	

	#(`delay*2)
	fifo_en=1'b0;


	end


//initial
//$monitor("weight_buffer_test::: clk=%d  data_in=%h , data_out=%h , out_vld=%b",clk,data_in,data_out,out_vld);

endmodule
