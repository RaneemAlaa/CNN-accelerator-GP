module top  #(parameter width = 16, col = 32, row = 25)
    (
	input logic clk,    // Clock
	input logic nrst,  // Asynchronous reset active low
	input logic [31:0] axi_input, // input (from axi or APB)
	input logic [13:0]op_code, 
    output logic [width-1:0] out [col-1:0]
);
 logic flag,fifo_en,nrst2;
 logic [width-1:0] map_2_iarray[row-1:0] ;
 logic [width-1:0] warray_2_systoic [col-1:0] ;
 logic [width-1:0] iarray_2_systolic[row-1:0];
 logic [width-1:0] systolic_out [col-1:0];
 logic [width-1:0] pooling_out[col-1:0]; 
 logic [4:0] weight_dim;
 logic [5:0] num_filter;
 logic pu_en,conv_ctrl,pooling_ctrl;
 logic [col-1:0] weight_en;
 logic conv_finish; //! first output of conv ctrl indicates that the conv is finished
 logic pu_finish ;  //! output of PU ctrl indicates that the mapping is finished
 logic pooling_finish[31:0]; //! output of pooling ctrl indicates that the pooling is finished
 logic pooling_done[col-1:0];
 logic pooling_en [col-1:0];
 logic [col-1:0] sys_en;
 logic  [15:0] out_vld_w;
 logic  [row-1:0] out_vld_i;
 logic [width-1:0] new1 ;
 //dividing in_axi_input into two words
 assign new1 = axi_input [width-1:0];
 //assign new2 = axi_input [15:0];
 logic sys_clk;
 assign sys_clk = (conv_ctrl)? flag:clk;
 always_comb begin
    if (!nrst) begin
        out = '{default:'0};
    end
    else if(op_code[2:0]==3'b001) begin
        out = systolic_out;
    end
    else if(op_code[2:0]==3'b010) begin
        out = pooling_out;
    end
 
 end

ctrl_cnn G0 (.clk(clk),.nrst(nrst),.conv_finish(conv_finish),.pu_finish(pu_finish),.pooling_finish(pooling_finish), .fifo_en(fifo_en), .nrst2(nrst2),
    .op_code_i(op_code),.pu_en(pu_en),.conv_ctrl(conv_ctrl),.pooling_ctrl(pooling_ctrl),.weight_en(weight_en),.weight_dim(weight_dim),.num_filter(num_filter));


map_top G1 (.clk(clk) , .nrst(nrst2) , .flag(flag), .start(pu_en) , .new1(new1) , .map_finish(pu_finish), .out(map_2_iarray));

input_array G2 (.clk(flag) , .nrst(nrst) , .data_in(map_2_iarray) , .data_out(iarray_2_systolic) , .fifo_en(fifo_en) , .out_vld(out_vld_i) ) ;

weight_array G3(.clk(clk) , .nrst(nrst) , .fifo_en(weight_en) , .weight_in(axi_input)  , .out_vld(out_vld_w) , .out_en(sys_en) ,.weight_out(warray_2_systoic), .weight_dim(weight_dim) );


systolic_top  G4 (.clk(sys_clk) , .nrst(nrst) ,.weight_dim(weight_dim) ,.conv_ctrl(conv_ctrl) ,.num_filter(num_filter),.conv_finish(conv_finish),
    .weight_en(sys_en) ,.weight_input2(warray_2_systoic) ,.feature_input2(iarray_2_systolic) , .systolic_out(systolic_out) ,.out_en(pooling_en) );


pooling_top G5 (.clk(flag) , .nrst(nrst) , .start(pooling_ctrl) ,.en(pooling_en)  ,.sys_out(systolic_out) ,.pooling_out(pooling_out) , .pooling_done(pooling_done) , .pooling_finish(pooling_finish));

endmodule 