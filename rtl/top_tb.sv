module top_tb #(  parameter data_width = 16,col = 32,row = 25)();
 	logic clk,nrst;
	logic [31:0] axi_input ;
	logic [13:0]op_code; 
    logic [data_width-1:0] out [col-1:0];

    //instantiate the design module and conncet variables with ports
    top dut(.clk(clk), .nrst(nrst) , .op_code(op_code) , .out(out) , .axi_input(axi_input));

    int weight_inp[25:0],weight_inp2[24:0],mem [1023:0];
    int correct_sys [783:0];
    int correct_sys2 [783:0];
    int correct_pool [195:0];
    int correct_pool2 [195:0];
    int out_arr [$];
	int out_arr2 [$];
	initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
	end
	initial begin
		//initialization
		$readmemh("weight_in.txt",weight_inp);  // fisrt filter
		$readmemh("weight_in2.txt",weight_inp2); // second filter
		$readmemh("img.txt",mem);  // input to mapping
		$readmemh("correct_sys.txt",correct_sys);	// output of systolic for first filter from matlab
 		$readmemh("correct_sys2.txt",correct_sys2); // output of systolic for second filter from matlab
 		$readmemh("correct_pool.txt",correct_pool); // output of pooling for first filter from matlab
		$readmemh("correct_pool2.txt",correct_pool2); // output of pooling for second filter from matlab
		nrst = 0;
		axi_input = 0;
		op_code   = 14'b00000_000000_000;
		/* [2:0] operation , [8:3] number of filters , [13:9] weight dimension
			operation = conv = 3'b001
			num_filters = 2
			weight_dimension = 25*/
			#2;
		fork
			begin
				nrst = 1;
				op_code = 14'b11001_000010_001;
				@(posedge dut.weight_en[0]);
				#1;
				for (int i = 0; i < 13; i++) begin  // load fisrt filter
						axi_input = weight_inp[i];
						#2;
				end
				@(posedge dut.weight_en[1]);
				#1;
				for (int i = 0; i < 13; i++) begin // load second filter
						axi_input = weight_inp2[i];
						#2;
				end
				@(posedge dut.pu_en)
				#1;
				for (int i = 0; i < 1024; i++) begin
						#2;
						axi_input = mem[i];
				end

			end	
			begin
				@(posedge dut.pooling_en[0]);  // indicate 1st output from systolic
				for(int i = 0; i<1000;i++) begin	
					@(posedge dut.sys_clk)
					#2;					
					if(dut.pooling_en[0]) begin
						if (out_arr.size() == 784) begin //size of array after conv
							break;
						end
						out_arr.push_back(dut.systolic_out[0]); //store output of first filter
					end

				end
			end
			begin
				@(posedge dut.pooling_en[1]);
				for(int i = 0; i<1000;i++) begin
					@(posedge dut.sys_clk)
					#2;
					if(dut.pooling_en[1]) begin
						if (out_arr2.size() == 784) begin
							break;
						end
						out_arr2.push_back(dut.systolic_out[1]); //store output of second filter
					end	
				end
			end
		join

				// check output of systolic with output of matlab 
		for (int i = 0; i <out_arr.size() ; i++) begin
			if (out_arr[i] != correct_sys[i]) begin
				$display("error in index %d,wrong = %d, correct = %d ",i,out_arr[i],correct_sys[i]);
			end
			if (out_arr2[i] != correct_sys2[i]) begin
				$display("e2rror in index %d,wrong = %d, correct = %d ",i,out_arr2[i],correct_sys2[i]);
			end
		end
		$display("size of sys_out = %d",out_arr.size());
		$display("All sys_out = %p",out_arr);
		$display("size of sys_out2 = %d",out_arr2.size());
		$display("All sys_out2 = %p",out_arr2);
		//$stop;

		//convolution and pooling 
		out_arr = {};  // delete all elements
		out_arr2 = {};
		nrst = 0;
		op_code = 14'b11001_000010_000;
		#2;
		fork
			begin
				nrst =1;
				op_code = 14'b11001_000010_010;
				@(posedge dut.weight_en[0]);
				#1;
				for (int i = 0; i < 13; i++) begin  // load fisrt filter
						axi_input = weight_inp[i];
						#2;
				end
				@(posedge dut.weight_en[1]);
				#1;
				for (int i = 0; i < 13; i++) begin // load second filter
						axi_input = weight_inp2[i];
						#2;
				end
				@(posedge dut.pu_en)
				#1;
				for (int i = 0; i < 1024; i++) begin
						#2;
						axi_input = mem[i];
						
				end

			end	
			begin
				@(posedge dut.pooling_ctrl);  // indicate start pooling 
				for (int i = 0; i < 784; i++) begin
						if(dut.pooling_done[0]) begin
						out_arr.push_back(out[0]); //store output of first pooling
						end
						if(dut.pooling_done[1]) begin
						out_arr2.push_back(out[1]); //store output of first pooling
						end	
						@(negedge dut.sys_clk);
						#1;				
				end
			end
		join
		fork
			begin
				for(int i = 0; i < 1000; i++) begin
					
					if(dut.pooling_done[0]) begin

						if (out_arr.size() == 196) begin //size of array after pooling = 14*14 = 196
							break;
						end
				
						out_arr.push_back(out[0]);
					end
					@(negedge dut.sys_clk);
					#1;		
				end
			end
			begin
				for(int i = 0; i < 1000; i++) begin
					
					if(dut.pooling_done[1]) begin
						if (out_arr2.size() == 196) begin
							break;
						end
						
						out_arr2.push_back(out[1]);
					end
					@(negedge dut.sys_clk);
					#1;		
				end
			end
		join
		// check output of pooling with output of matlab 
		for (int i = 0; i <out_arr.size() ; i++) begin
			if (out_arr[i] != correct_pool[i]) begin
				$display("error in index %d,wrong = %d, correct = %d ",i,out_arr[i],correct_pool[i]);
			end
			if (out_arr2[i] != correct_pool2[i]) begin
				$display("e2rror in index %d,wrong = %d, correct = %d ",i,out_arr2[i],correct_pool2[i]);
			end
		end
		$display("size of pooling_out = %d",out_arr.size());
		$display("All pooling_out = %p",out_arr);
		$display("size of pooling_out2 = %d",out_arr2.size());
		$display("All pooling_out2 = %p",out_arr2);
		$stop;
	end
	initial begin
		$monitor("[%t],clk = %b,nrst = %b,sys_out = %d",$time,dut.sys_clk,nrst,dut.systolic_out[0]);
	end
endmodule 