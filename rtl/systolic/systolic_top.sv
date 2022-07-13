module systolic_top 
	#(parameter width = 16, col = 32, row = 25 )
	 ( 
	input  logic clk, nrst,conv_ctrl,
	input  logic [col-1:0] weight_en,
	input  logic [4:0] weight_dim,
	input  var logic  [width-1:0] weight_input2 [col-1:0] ,
	input  var logic [width-1:0] feature_input2 [row-1:0],
	input  logic [5:0] num_filter,
	output logic  out_en[col-1:0],
	output logic [width-1:0] systolic_out [col-1:0],
	output logic conv_finish
	);
logic w_ps;
logic [row-1:0] in_en;
conv_ctrl #(.col(col),
	.row(row))
	ctrl_inst(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.input_en(in_en),
		.weight_dim(weight_dim),
		.num_filter (num_filter),
		.out_en(out_en),
		.w_ps(w_ps),
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