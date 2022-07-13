module sub_tb #(  parameter data_width = 16,col = 32,row = 25)();
	logic clk,nrst,nrst2,fifo_en,conv_ctrl,flag,pu_en;
	logic [col-1:0] weight_en;   // fifo_en weight_array
	logic [4:0] weight_dim;
	logic [5:0] num_filter;
	logic   [31:0] weight_in;           //from AXI
	//logic [15:0] data_in [31:0];
	logic  [data_width-1:0]  new1;
	logic [row-1:0]out_vld;
	logic map_finish;
	logic [data_width-1:0] pooling_out[col-1:0];
    logic pooling_done[col-1:0];
    logic pooling_finish[col-1:0];
    int num;

    sub_mod dut(.clk(clk) , .nrst(nrst) , .fifo_en(fifo_en) , .conv_ctrl(conv_ctrl) , .pu_en(pu_en) , .flag(flag) , .weight_dim(weight_dim) , .num_filter(num_filter) , .new1(new1), .nrst2(nrst2)
    	, .pooling_done(pooling_done) , .pooling_out(pooling_out) , .pooling_finish(pooling_finish) , .weight_en(weight_en) , .weight_in(weight_in) , .map_finish(map_finish) , .out_vld(out_vld));
    int weight_inp[24:0],weight_inp2[24:0],mem [1023:0];
    int correct_pool [195:0];
    int correct_pool2 [195:0];
    int pooling_out_arr [$];
	int pooling_out_arr2 [$];
	int x ;
    initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
	end
	initial
	begin
	//initialization
	$readmemh("weight_in.txt",weight_inp);
	$readmemh("weight_in2.txt",weight_inp2);
	//weight_in = '{1,0,1,0,1,1,1,1,0,0,0,1,1,0,1,0,1,1,0,0,1,1,0,0,1};
	//weight_in2 = '{1,0,0,1,1,0,0,1,1,0,1,0,1,1,0,0,0,1,1,1,1,0,1,0,1};

	$readmemh("img.txt",mem,0,1023);
	$readmemh("correct_pool.txt",correct_pool);
	$readmemh("correct_pool2.txt",correct_pool2);
	nrst = 0;
	nrst2 = 0;
	conv_ctrl = 0;
	weight_dim = 25; 
	num_filter =2;
	fifo_en = 0;
	for (int i = 0; i < col; i++) begin
	//weight_input2[i] = $random;
	weight_en[i] = 0;
	end
	/*for (int j = 0; j < row; j++) begin
	data_in[j] = 0;
	end*/
	//conv_ctrl = 0 -->load weight in each PE
	#2
	nrst = 1;
	fork
		begin

		weight_en[0] = 1;
		for (int i = 0; i < 13; i++) begin
			weight_in = weight_inp[i];
			#2;
		end
		#26;
		weight_en[0] = 0;
		weight_en[1] = 1;
		for (int i = 0; i < 13; i++) begin
			
			weight_in = weight_inp2[i];
			#2;
		end
		#26;
		weight_en[1] = 0;
		nrst2 = 1;
		pu_en = 1;
		for (int i = 0; i < 1024; i++) begin
			#2
			new1 = mem[i];
			if (i == 164) begin
				
				fifo_en = 1;
				
				conv_ctrl = 1;
			end
		end
		#65;
		pu_en=0;		
		
		/*x = 0;
		for (int j = 0; j <784 ; j++) begin
			for (int i = 0; i < 25; i++) begin
				data_in[i] = mem[x+i];
			end
			x = x + 25; 
			#2;
		end	*/
		
		end
		begin
			@(posedge dut.conv_finish);  // indicate start pooling 
			for (int i = 0; i < 784; i++) begin
					if(pooling_done[0]) begin
					//@(posedge dut.sys_clk);
					pooling_out_arr.push_back(pooling_out[0]); //store output of first pooling
					end
					if(pooling_done[1]) begin
					//@(posedge dut.sys_clk);
					pooling_out_arr2.push_back(pooling_out[1]); //store output of first pooling
					end	
					@(negedge dut.sys_clk);
					#1;				
			end
		end
	join

	fork
		begin
			forever begin
				
				if(pooling_done[0]) begin

					if (pooling_out_arr.size() == 196) begin //size of array after pooling = 14*14 = 196
						break;
					end
					//@(posedge dut.sys_clk);
					pooling_out_arr.push_back(pooling_out[0]);
				end
				@(negedge dut.sys_clk);
				#1;		
			end
		end
		begin
			forever begin
				
				if(pooling_done[1]) begin
					if (pooling_out_arr2.size() == 196) begin
						break;
					end
					//@(posedge dut.sys_clk);
					pooling_out_arr2.push_back(pooling_out[1]);
				end
				@(negedge dut.sys_clk);
				#1;		
			end
		end

	join
	// check output of pooling with output of matlab 
	for (int i = 0; i <pooling_out_arr.size() ; i++) begin
		if (pooling_out_arr[i] != correct_pool[i]) begin
			$display("[%t] error in index %d,wrong = %d, correct = %d ",$time,i,pooling_out_arr[i],correct_pool[i]);
		end
		if (pooling_out_arr2[i] != correct_pool2[i]) begin
			//$display("e2rror in index %d,wrong = %d, correct = %d ",i,pooling_out_arr2[i],correct_pool2[i]);
		end
	end
	$display("size of pooling_out = %d",pooling_out_arr.size());
	$display("All pooling_out = %p",pooling_out_arr);
	$display("size of pooling_out2 = %d",pooling_out_arr2.size());
	$display("All pooling_out2 = %p",pooling_out_arr2);
	$stop;
	end
	initial begin
		$monitor("[%t],clk = %b,nrst = %b,sys_out = %d",$time,dut.sys_clk,nrst,dut.systolic_out[0]);
	end
endmodule