module systolic_vector
  #(parameter width=8 , row = 4)(
  input clk_in1, nrst_in1, ctrl_in1,weight_en,in_en[row-1:0],[width-1:0] weight_input1,[width-1:0] feature_input[row-1:0],
  output logic out_in[row-1:0],
  output logic [width-1:0] vec_out , [width-1:0] feature_out1[row-1:0]
  );


logic [width-1:0] weight[row:0];


assign weight[0] = (weight_en)? weight_input1:'b0;

assign vec_out=weight[row];
genvar i;
generate
    for (i=0; i<=row-1; i=i+1) begin 
        pe #(.width(width))
         p1(
        .clk(clk_in1),
        .rst_n(nrst_in1),
        .ctrl(ctrl_in1),
        .in_en(in_en[i]),
        .out_in(out_in[i]),
        .PE_in(weight[i]),
        .feature_in(feature_input[i]),
        .PE_out(weight[i+1]),
        .feature_out(feature_out1[i])
    );
end 
endgenerate
endmodule
