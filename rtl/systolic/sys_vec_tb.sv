module vec_test;

 	parameter width=8,row=2 ;

	logic clk_in1;
	logic nrst_in1;
	logic ctrl_in1;
	logic[width-1:0] weight_input1;
	logic [width-1:0] feature_input[row-1:0];
  logic [width-1:0] vec_out ;
	logic [width-1:0] feature_out1[row-1:0];

	systolic_vector vec_inst(.clk_in1(clk_in1) , 
		.nrst_in1(nrst_in1) , 
		.ctrl_in1(ctrl_in1) , 
		.weight_input1(weight_input1) , 
		.feature_input(feature_input) , 
		.vec_out(vec_out) , 
		.feature_out1(feature_out1)
		);

	initial begin
		clk_in1= 0;
	forever
		#1 clk_in1 = ~clk_in1;
	end

	initial
	begin
	//initialization
		nrst_in1=0;
		ctrl_in1=1;
		weight_input1=2;//PE weights
		feature_input[0]= 0;
		feature_input[1] = 0;
	//ctrl_in=1 -->load weight in  2 PE
		#2
		nrst_in1=1;
		ctrl_in1=1;
		weight_input1=1;//PE weights
		feature_input[0]= 0;
		feature_input[1] = 0;
		#2
		weight_input1=4;
	//Strat Matrix_mul
		#2
		nrst_in1=1;
		ctrl_in1=0;     // PE_out = partial_sum_out
		weight_input1=0;
		feature_input[0]=1;
		feature_input[1]=0;
		#2
		nrst_in1=1;
		ctrl_in1=0;
		weight_input1=0;
		feature_input[0]=1;
		feature_input[1]= 5;
		//input partial_sum_in
		#2
		nrst_in1=1;
		ctrl_in1=0;
		weight_input1=0;//partial_sum_in
		feature_input[0]=0;
		feature_input[1]=2;
		#2
		nrst_in1=0;
		#20; $stop;

	end
  initial begin
    $monitor("[%0t],clk = %b, nrst= %b, ctrl= %b, weight_in= %p ,f_i= %p, out= %p",$time,clk_in1,nrst_in1,ctrl_in1,weight_input1,feature_input,vec_out);

  end
endmodule
