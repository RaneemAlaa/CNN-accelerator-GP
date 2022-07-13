module sub_mod
	#(  parameter data_width = 16,
      parameter col = 32,

      parameter row = 25
    )
    (
	input clk,nrst,nrst2,fifo_en,conv_ctrl,pu_en,
	input  logic [col-1:0] weight_en, // fifo_en weight_array
	input  logic [4:0] weight_dim,
	input  logic [5:0] num_filter,
	input  logic   [31:0] weight_in,           //from AXI
	//input  var logic  [data_width-1:0] weight_input2 [col-1:0] ,
	//input [15:0] data_in [31:0],
	input logic  [data_width-1:0]  new1,
	input logic [row-1:0]out_vld,
	output logic map_finish,flag,
	output logic [data_width-1:0] pooling_out[col-1:0],
    output logic pooling_done[col-1:0],
    output logic pooling_finish[col-1:0]
	);
	 logic [data_width-1:0] map_2_iarray [row-1:0];
	 logic  [data_width-1:0] weight_out [col-1:0] ;
	 logic  [15:0] w_out_vld;
	 logic  [col-1:0] w_out_en;
     logic out_en[col-1:0];
	 logic [data_width-1:0] systolic_out [col-1:0];
	 logic conv_finish;
	 logic [data_width-1:0] feature_input2 [row-1:0];
	 logic sys_clk;
	 assign sys_clk = (conv_ctrl)? flag:clk;
	 weight_array g0(.clk(clk), .nrst(nrst) , .out_vld(w_out_vld) , .fifo_en(weight_en) , .weight_dim(weight_dim) , .out_en(w_out_en), .weight_in(weight_in) , .weight_out(weight_out));
	map_top g1(.clk(clk) , .nrst(nrst2) , .start(pu_en) , .new1(new1), .flag(flag) , .map_finish(map_finish) , .out(map_2_iarray));
	  input_array g2(.clk(flag), .nrst(nrst) , .out_vld(out_vld) , .fifo_en(fifo_en) , .data_in(map_2_iarray) , .data_out(feature_input2));
	 systolic_top g3(.nrst(nrst),.clk(sys_clk),.conv_ctrl(conv_ctrl),.weight_en(w_out_en),.weight_dim(weight_dim), .weight_input2(weight_out),
	 	.feature_input2(feature_input2),.num_filter(num_filter),.out_en(out_en),.conv_finish(conv_finish),.systolic_out(systolic_out));
	  pooling_top g4(.clk(flag),.nrst(nrst),.start(conv_finish),.en(out_en),.sys_out(systolic_out),.pooling_done(pooling_done),.pooling_finish(pooling_finish), .pooling_out(pooling_out));
endmodule 