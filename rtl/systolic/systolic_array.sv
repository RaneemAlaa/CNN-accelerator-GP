module systolic_array
  #(parameter width=8 , row=2 ,  col=2)(//[row*col-1:0][col-1:0]ctrl_in2
  input clk_in2, nrst_in2,ctrl_in2, [width-1:0] weight_input2 [col-1:0] ,[width-1:0] feature_input2 [row-1:0],
  output [width-1:0] systolic_out [col-1:0]
  );

//wire [row-1:0][width-1:0] out;
//assign systolic_out = out[row-1];

wire  [width-1:0]feature_wires[row*(col+1):0];
//wire [row*col-1:0] [width-1:0]weight_wires;

assign feature_wires[row-1:0]=feature_input2;
//assign weight_wires[row-1:0]=weight_input2;

genvar j;
//genvar k;

generate
	for (j=0; j<=col-1; j=j+1) begin 
		
			systolic_vector p2(
        		.clk_in1(clk_in2),
        		.nrst_in1(nrst_in2),
       			.ctrl_in1(ctrl_in2),
        		.weight_input1(weight_input2[j]),
        		.feature_input(feature_wires[(j+1)*row-1:j*row]),
        		.vec_out(systolic_out[j]),
        		.feature_out1(feature_wires[(j+2)*row-1:(j+1)*row])
		 );
		
	end 


endgenerate
		 
endmodule
