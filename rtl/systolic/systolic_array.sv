module systolic_array
#(parameter width=16 , row=32 ,  col=32)(
  input clk_in2, nrst_in2,ctrl_in2,
  input [col-1:0]weight_en,
  input [row-1:0]in_en ,
  input [width-1:0] weight_input2 [col-1:0] ,[width-1:0] feature_input2 [row-1:0],
  output [width-1:0] systolic_out [col-1:0]
  );


logic  [width-1:0]feature_wires[row*(col+1):0];
logic  [row*(col+1):0] en_wires; // wires connect out_in to in_en  

assign feature_wires[row-1:0]=feature_input2;
assign en_wires[row-1:0]=in_en; 



genvar j;
generate
	for (j=0; j<=col-1; j=j+1) begin 
		
			systolic_vector #(.width(width),
			.row(row))
			p2(
        		.clk_in1(clk_in2),
        		.nrst_in1(nrst_in2),
       			.ctrl_in1(ctrl_in2),
			.weight_en(weight_en[j]),
       			.in_en(en_wires[(j+1)*row-1:j*row]),
       			.out_in(en_wires[(j+2)*row-1:(j+1)*row]),
        		.weight_input1(weight_input2[j]),
        		.feature_input(feature_wires[(j+1)*row-1:j*row]),
        		.vec_out(systolic_out[j]),
        		.feature_out1(feature_wires[(j+2)*row-1:(j+1)*row])
		 );
		
	end 

endgenerate		 
endmodule
