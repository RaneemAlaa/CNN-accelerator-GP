module systolic_vector
  #(parameter width=8 , row = 3)(
  input clk_in1, nrst_in1, ctrl_in1,[width-1:0] weight_input1,[width-1:0] feature_input[row-1:0],
  output logic [width-1:0] vec_out , [width-1:0] feature_out1[row-1:0]
  );


logic [width-1:0] weight[row:0];


assign weight[0] = weight_input1;

assign vec_out=weight[row];
genvar i;
generate
    for (i=0; i<=row-1; i=i+1) begin 
        pe
         p1(
        .clk(clk_in1),
        .rst_n(nrst_in1),
        .ctrl(ctrl_in1),
        .PE_in(weight[i]),
        .feature_in(feature_input[i]),
        .PE_out(weight[i+1]),
        .feature_out(feature_out1[i])
    );
end 
endgenerate
endmodule
