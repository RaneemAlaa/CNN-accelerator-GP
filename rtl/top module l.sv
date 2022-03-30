module top  (
	input logic clk,    // Clock
	input logic rst_n,  // Asynchronous reset active low
	input logic [31:0] axi_input, // input (from axi or APB)
	input logic [4 :0] weight_dim,
	input logic op_code,//what is the width of op code?
	output logic final_out
);

 logic [width-1:0] map_2_iarray[24:0] ;
 logic [width-1:0] warray_2_systoic ;
 logic [width-1:0] iarray_2_systolic[31:0];
 logic [width-1:0] systolic_out [col-1:0];
 logic [width-1:0] pooling_out[col-1:0]; 


 //dividing in_axi_input into two words
  new1 = in_axi_input [31:16];
  new2 = in_axi_input [15:0];

 
map_top G0 (.clck(clk) , .nrst(rst_n) , .start() , .new1(new1) , .new2(new2) , .out(map_2_iarray) ,.adrs_in1() ,.adrs_in2() );
input_array G1 (.clk(clk) , .nrst(rst_n) , .data_in(map_2_iarray) , .data_out(iarray_2_systolic) , .fifo_en() , .out_en() , .out_vld() ) ;
weight_array G2(.clk(clk) , .nrst(rst_n) , .fifo_en() , .weight_in(axi_input)  , .out_vld() , .out_en() , .weight_out(warray_2_systolic) );
systolic_top  G3 (.clk(clk) , .nrst(rst_n) ,.weight_dim(weight_dim) ,.conv_ctrl() ,.weight_en() ,.in_en() ,.weight_input2(warray_2_systoic) ,.feature_input2(iarray_2_systolic) , .systolic_out(systolic_out) ,.out_en() );
pooling_top G4 (.clk(clk) , .nrst(rst_n) , .start() ,.en()  ,.sys_out(systolic_out) ,.pooling_out(pooling_out) , .pooling_done());

