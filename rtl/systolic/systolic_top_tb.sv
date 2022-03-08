module systolic_top_tb ;
	parameter width = 8, col = 32, row = 32  ;
	logic clk, nrst,conv_ctrl,weight_en[col-1:0],in_en[row-1:0];
	logic [4:0] weight_dim;
	logic [width-1:0] weight_input2 [col-1:0] ;
	logic [width-1:0] feature_input2 [row-1:0];
	logic [width-1:0] systolic_out [col-1:0];
	logic out_en [col-1:0];
	logic conv_finish;
    systolic_top  #(.width(width),
	.col(col),
	.row(row))
	dut(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.weight_en(weight_en),
		//.in_en(in_en),
		.weight_dim(weight_dim),
		.weight_input2(weight_input2),
		.feature_input2(feature_input2),
		.systolic_out(systolic_out),
		.out_en(out_en),
		.conv_finish(conv_finish)
		);
	// Hint: testbench run for image 4*4 and filter 2*2 >> weight_dim = 4, output 3*3 >> 9 elements , so change condition of disable in conv_ctrl  
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
weight_dim = 4; 
for (int i = 0; i < col; i++) begin
	weight_input2[i] = $random;
end

for (int i = 0; i < col; i++) begin
	weight_en[i] = 0; 	// disable all column
end
for (int i = 0; i < row; i++) begin
	feature_input2[i] = $random;
end
//conv_ctrl = 0 -->load weight in each PE
#2
nrst = 1;
weight_en[0] = 1; // all column disable except first column
weight_input2[0]=4;//PE weights
weight_input2[1]=4;
weight_input2[2]=4;
weight_input2[3]=2;
#2
weight_input2[0]=3;//PE weights
weight_input2[1]=2;
weight_input2[2]=7;
weight_input2[3]=3;
#2
weight_input2[0]=2;//PE weights
weight_input2[1]=1;
weight_input2[2]=5;
weight_input2[3]=1;
#2
conv_ctrl = 1;
weight_input2[0]=1;//PE weights
weight_input2[1]=5;
weight_input2[2]=3;
weight_input2[3]=6;
#2
weight_en[0] = 0; // disable loading weights
feature_input2[0]=5;
#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=2;
feature_input2[1]=2;

#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=1;
feature_input2[1]=1;
feature_input2[2]=6;

#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=6;
feature_input2[1]=3;
feature_input2[2]=8;
feature_input2[3] = 8;
#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=8;
feature_input2[1]=8;
feature_input2[2]=1;
feature_input2[3] = 1;
#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=1;
feature_input2[1]=1;
feature_input2[2]=4;
feature_input2[3] = 0;
#2
nrst = 1;
conv_ctrl = 1;
feature_input2[0]=4;
feature_input2[1]=0;
feature_input2[2]=6;
feature_input2[3] = 6;
#2
feature_input2[0]=6;
feature_input2[1]=6;
feature_input2[2]=8;
feature_input2[3] = 8;
#2
feature_input2[0]=8;
feature_input2[1]=8;
feature_input2[2]=3;
feature_input2[3] = 2;
#2
feature_input2[1]=2;
feature_input2[2]=6;
feature_input2[3] = 6;
#2
feature_input2[2]=7;
feature_input2[3] = 7;
#2
feature_input2[3] = 4;
#100
nrst = 0;
#10
$stop;
end
initial begin
$monitor("[%0t],clk = %b, reset= %b, ctrl= %b,w_ps =%b ,weight_in= %p ,f_i= %p, out= %d",$time,clk,nrst,conv_ctrl,dut.w_ps,weight_input2,feature_input2,systolic_out[0]);
end
endmodule
 
