module systolic_top 
	#(parameter width = 16, col = 32, row = 32 )
	 ( 
	input  logic clk, nrst,conv_ctrl,weight_en[col-1:0],
	input  logic [4:0] weight_dim,
	input  var logic  [width-1:0] weight_input2 [col-1:0] ,
	input  var logic [width-1:0] feature_input2 [row-1:0],
	output logic [width-1:0] systolic_out [col-1:0],
	output logic out_en [col-1:0],
	output logic conv_finish
	);
logic w_ps,in_en[row-1:0];
conv_ctrl #(.col(col))
	ctrl_inst(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.input_en(in_en),
		.weight_dim(weight_dim),
		.w_ps(w_ps),
		.out_en(out_en),
		.conv_finish(conv_finish) 
		);
systolic_array #(.width(width),
	.col(col),
	.row(row))
	sys_inst(.clk_in2(clk),
		.nrst_in2(nrst),
		.ctrl_in2(w_ps),
		.weight_en(weight_en),
		.in_en(in_en),
		.weight_input2(weight_input2),
		.feature_input2(feature_input2),
		.systolic_out(systolic_out)
		);
endmodule 
