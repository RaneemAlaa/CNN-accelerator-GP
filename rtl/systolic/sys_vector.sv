module systolic_vector
  #(parameter width=8 , row = 2)(
  input clk_in1, nrst_in1, ctrl_in1,[width-1:0] weight_input1,[width-1:0] feature_input[row-1:0],
  output [width-1:0] vec_out , [width-1:0] feature_out1[row-1:0]
  );

//wire [row-1:0][width-1:0] feature_output;
wire [width-1:0] weight[row:0];


assign weight[0] = weight_input1;

assign vec_out=weight[row];


genvar i;
generate
    for (i=0; i<=row-1; i=i+1) begin PE
         p1(
        .clk_in(clk_in1),
        .nrst_in(nrst_in1),
        .ctrl_in(ctrl_in1),
        .weight_in(weight[i]),
        .feature_in(feature_input[i]),
        .partial_sum_out(weight[i+1]),
        .feature_out(feature_out1[i])
    );
end 
endgenerate	

endmodule
