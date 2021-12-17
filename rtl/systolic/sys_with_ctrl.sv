module sys_with_ctrl#(parameter width=8 , row = 2, col=2) (input clk,rstn,w_ps,[width-1:0] weight_input [col-1:0],[width-1:0] feature_input[row-1:0],output [width-1:0] systolic_out [col-1:0]);
wire cntl;
sys_ctrl #(.H(row)) contol(.clk(clk),.w_ps(w_ps),.rstn(rstn),.ctrl_out(cntl));
systolic_array #(.width(width),.row(row),.col(col)) sys(.clk_in2(clk),.nrst_in2(rstn),.ctrl_in2(cntl),.weight_input2(weight_input) ,.feature_input2(feature_input),.systolic_out(systolic_out));
endmodule
