module systolic_top #(parameter width = 8, col = 3, row = 3 ) ( 
	input  logic clk, nrst,conv_ctrl,
	input  logic [4:0] weight_dim,
	input  var logic  [width-1:0] weight_input2 [col-1:0] ,
	input  var logic [width-1:0] feature_input2 [row-1:0],
	output logic [width-1:0] systolic_out [col-1:0],
	output logic conv_finish, w_ps, 
    output logic [col-1:0] out_en
	);
conv_ctrl #(.col(col))
	ctrl_inst(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.weight_dim(weight_dim),
		.conv_finish(conv_finish),
		.w_ps(w_ps),
		.out_en(out_en)
		);
systolic_array #(.width(width),
	.col(col),
	.row(row))
	sys_inst(.clk_in2(clk),
		.nrst_in2(nrst),
		.ctrl_in2(w_ps),
		.weight_input2(weight_input2),
		.feature_input2(feature_input2),
		.systolic_out(systolic_out)
		);
endmodule 
