module sys_flag_tb #(  parameter data_width = 16,col = 32,row = 25)();
	logic clk,nrst,fifo_en,conv_ctrl,flag,start;
	logic [col-1:0] weight_en;   // fifo_en weight_array
	logic [4:0] weight_dim;
	logic [5:0] num_filter;		// num of filters will be loaded
	logic   [31:0] weight_in;           //from AXI
	logic [data_width-1:0] map_2_iarray [row-1:0];
	logic [data_width-1:0] pooling_out[col-1:0];
    logic pooling_done[col-1:0];
    logic pooling_finish[col-1:0];
    int x;
    sys_flag dut(.clk(clk), .nrst(nrst) , .fifo_en(fifo_en) , .weight_en(weight_en)  , .weight_in(weight_in) , .conv_ctrl(conv_ctrl) , .start(start) , .pooling_done(pooling_done) , .pooling_out(pooling_out) , .pooling_finish(pooling_finish) , .map_2_iarray(map_2_iarray) , .num_filter(num_filter) , .weight_dim(weight_dim));
  	int weight_inp[24:0],weight_inp2[24:0],mem [19599:0];
  	/*int pooling_out_arr [$];
	int pooling_out_arr2 [$];
	int correct_pool [783:0];
	int correct_pool2 [783:0];*/
	int correct_pool [195:0];
    int correct_pool2 [195:0];
    int pooling_out_arr [$];
	int pooling_out_arr2 [$];
  	initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
	end
	initial begin
		//initialization
		$readmemh("weight_in.txt",weight_inp);  // fisrt filter
		$readmemh("weight_in2.txt",weight_inp2); // second filter
		$readmemh("img_in.txt",mem,0,19599);  // input to buffer after mapping (data from matlab)
		/*$readmemh("check1.txt",correct_pool);
 		$readmemh("check2.txt",correct_pool2);*/
 		$readmemh("correct_pool.txt",correct_pool); // output of pooling for first filter from matlab
		$readmemh("correct_pool2.txt",correct_pool2); // output of pooling for second filter from matlab
		nrst = 0; 
		conv_ctrl = 0;
		weight_dim = 25; 
		num_filter =2;
		fifo_en = 0;
		for (int i = 0; i < col; i++) begin  // disable all weight_en
			weight_en[i] = 0;
		end
		for (int i = 0; i < row; i++) begin 
			map_2_iarray[i] = 0;
		end
		#2
		nrst = 1;
		fork  
		begin

			weight_en[0] = 1;  // load fisrt filter
			for (int i = 0; i < 13; i++) begin
				weight_in = weight_inp[i];
				#2;
			end
			#26;               // load weights take 26 clock cycle 
			weight_en[0] = 0;
			weight_en[1] = 1;  // load second filter
			for (int i = 0; i < 13; i++) begin
				
				weight_in = weight_inp2[i];
				#2;
			end
			#26;
			weight_en[1] = 0;
			start = 1;   // start mapping (flag_counter)
			x = 0;
			#326;   	//first output from mapping after 163 clock cycle
			conv_ctrl = 1;  // start loading_ps
			fifo_en = 1;   // enable input_array
			for (int j = 0; j <784 ; j++) begin  // loop acts as mapping_module (size of array after convolution = 28*28 = 784) 
				@(posedge dut.flag); // flag is the clock of the system now 
				for (int i = 0; i < 25; i++) begin
					map_2_iarray[i] = mem[x+i];   
				end
				/*if (j == 163) begin
					conv_ctrl = 1;
					fifo_en = 1;
				end*/
				x = x + 25; 
			end	
			#25;
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
			$display("error in index %d,wrong = %d, correct = %d ",i,pooling_out_arr[i],correct_pool[i]);
		end
		if (pooling_out_arr2[i] != correct_pool2[i]) begin
			$display("e2rror in index %d,wrong = %d, correct = %d ",i,pooling_out_arr2[i],correct_pool2[i]);
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