module sys_ctrl_tb();
parameter width=8 , row=2 ,  col=2;

 logic   clk;
 logic	nrst;
 logic    w_ps;
 logic	[width-1:0] weight_input[col-1:0] ;
 logic	[width-1:0] feature_input [row-1:0];
 logic	[width-1:0] systolic_out [col-1:0];
sys_with_ctrl#(width , row , col) dut(.clk(clk),.rstn(nrst),.w_ps(w_ps), .weight_input(weight_input), .feature_input(feature_input), .systolic_out(systolic_out));
initial begin
 clk = 0;
 forever 
	#1 clk = !clk;
end

initial
begin
//initialization
nrst = 0;
w_ps=1;
weight_input[0]=0;
weight_input[1]=0;
feature_input[0]= 0;
feature_input[1] = 0;
//load weight in each PE
#2
nrst = 1;
w_ps=1;
weight_input[0]=2;//PE weights
weight_input[1]=1;
feature_input[0]=0;
feature_input[1]=0;
#2
weight_input[0]=3;//PE weights
weight_input[1]=4;
//start matrix_mul
#2
nrst=1;
w_ps=0;
weight_input[0]=0; 
weight_input[1]=0;
feature_input[0]=1;
feature_input[1]=0;
#2
nrst=1;
weight_input[0]=0; 
weight_input[1]=0;
feature_input[0]=1;
feature_input[1]=5;
#2
nrst=1;
weight_input[0]=0;
weight_input[1]=0;
feature_input[0]=0;
feature_input[1]=2;
#2
w_ps = 1; 
#10
$stop;
end
initial begin
$monitor("[%0t],clk = %b, reset= %b, w_ps= %b, weight_in= %p ,f_i= %p, out= %p",$time,clk,nrst,w_ps,weight_input,feature_input,systolic_out);

end
endmodule
