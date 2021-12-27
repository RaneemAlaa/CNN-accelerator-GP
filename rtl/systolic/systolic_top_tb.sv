module systolic_top_tb ;
	parameter width = 8, col = 3, row = 3  ;
	logic clk, nrst,conv_ctrl;
	logic [4:0] weight_dim;
	logic [width-1:0] weight_input2 [col-1:0] ;
	logic [width-1:0] feature_input2 [row-1:0];
	logic [width-1:0] systolic_out [col-1:0];
	logic conv_finish, w_ps; 
    logic [col-1:0] out_en;
    systolic_top  #(.width(width),
	.col(col),
	.row(row))
	dut(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.weight_dim(weight_dim),
		.weight_input2(weight_input2),
		.feature_input2(feature_input2),
		.systolic_out(systolic_out),
		.conv_finish(conv_finish),
		.w_ps(w_ps),
		.out_en(out_en)
		);
initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
end
initial
begin
//initialization
nrst = 0;
conv_ctrl = 0;
weight_dim = 9; 
weight_input2[0]=0;
weight_input2[1]=0;
weight_input2[2]=0;
feature_input2[0]= 0;
feature_input2[1] = 0;
feature_input2[2] = 0;
//conv_ctrl = 0 -->load weight in each PE
#2
nrst = 1;
conv_ctrl = 0;
weight_dim = 9; 
weight_input2[0]=2;//PE weights
weight_input2[1]=1;
weight_input2[2]=3;
feature_input2[0]= 0;
feature_input2[1] = 0;
feature_input2[2] = 0;
#2
weight_input2[0]=5;//PE weights
weight_input2[1]=1;
weight_input2[2]=6;
#2
conv_ctrl = 1;
weight_input2[0]=3;//PE weights
weight_input2[1]=2;
weight_input2[2]=1;
//conv_ctrl = 1 -->start matrix_mul
#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0; 
weight_input2[1]=0;
weight_input2[2]=0;
feature_input2[0]=1;
feature_input2[1]=0;
feature_input2[2]=0;

#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0; 
weight_input2[1]=0;
feature_input2[0]=1;
feature_input2[1]=5;
feature_input2[2]=0;
#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0;
weight_input2[1]=0;
feature_input2[0]=2;
feature_input2[1]=4;
feature_input2[2]=2;

#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0;
weight_input2[1]=0;
feature_input2[0]=0;
feature_input2[1]=1;
feature_input2[2]=3;
#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0;
weight_input2[1]=0;
feature_input2[0]=0;
feature_input2[1]=0;
feature_input2[2]=6;
#2
nrst = 1;
conv_ctrl = 1;
weight_input2[0]=0;
weight_input2[1]=0;
feature_input2[0]=0;
feature_input2[1]=0;
feature_input2[2]=0;
#10
nrst = 0;
#10
$stop;
end
initial begin
$monitor("[%0t],clk = %b, reset= %b, ctrl= %b,w_ps =%b ,weight_in= %p ,f_i= %p, out= %p,conv_finish = %b",$time,clk,nrst,conv_ctrl,w_ps,weight_input2,feature_input2,systolic_out,conv_finish);
end
endmodule
 
