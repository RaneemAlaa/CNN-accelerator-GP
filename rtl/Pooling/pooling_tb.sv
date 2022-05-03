module pooling_tb();
//syst_out syst_out1 ;
parameter data_width = 16, col = 32;
logic clk,nrst,start;
logic en [col-1:0];
logic [data_width-1:0]sys_out[col-1:0];
wire [data_width-1:0] pooling_out[col-1:0];
logic pooling_done[col-1:0];
logic pooling_finish[col-1:0];
int pooling_out_arr [$];
int pooling_out_arr2 [$];
int mem [783:0];
int correct_pool [195:0];
pooling_top dut(.clk(clk),
			.nrst(nrst),
			.start(start),
			.en(en),
			.sys_out(sys_out),
			.pooling_out(pooling_out),
			.pooling_done(pooling_done),
			.pooling_finish(pooling_finish));
initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
end
initial begin
	//syst_out1 = new();
	//initialization
	nrst = 0;
	start = 0;
	$readmemh("mem.txt",mem);
	$readmemh("correct_pool.txt",correct_pool);
	for(int i =0;i<32;i =i+1)begin	
		en[i] = 0;
		sys_out[i] = 0;
	end
	#2
	//$display("en = %p, sys_out= %p,pooling_out = %p,pooling_done= %p",en,sys_out,pooling_out,pooling_done);
	// start
	nrst = 1;
	start = 1;
	fork
		begin
			en[0] = 1;
			#1;
			for (int i = 0; i < 28*28; i++) begin
				
				//syst_out1.randomize();
				//sys_out = syst_out1.out; 
				//sys_out[0] = i;
				sys_out[0] = mem[i];
				if(pooling_done[0]) begin
					@(posedge clk);
					//$display("[%t],clk = %b,pooling_out = %d,pooling_done= %d",$time,clk,pooling_out[0],pooling_done[0]);
					pooling_out_arr.push_back(pooling_out[0]);
				end
				#2;
			end 
		end
		begin
			#2;
			en[1] = 1;
			#1
			for (int i = 0; i < 28*28; i++) begin
				
				//syst_out1.randomize();
				//sys_out = syst_out1.out; 
				sys_out[1] = i ;
				if(pooling_done[1]) begin
					@(posedge clk);
					//$display("[%t],clk = %b,pooling_out2 = %d,pooling_done2= %d",$time,clk,pooling_out[1],pooling_done[1]);
					pooling_out_arr2.push_back(pooling_out[1]);
				end
				#2;
			end 
		end
	join

	fork
		begin
			forever begin
				
				if(pooling_done[0]) begin

					if (pooling_out_arr.size() == 196) begin
						break;
					end
					@(posedge clk);
					//$display("[%t],clk = %b,pooling_out = %d,pooling_done= %d",$time,clk,pooling_out[0],pooling_done[0]);
					pooling_out_arr.push_back(pooling_out[0]);
				end
				#2;
			end
		end
		begin
			forever begin
				
				if(pooling_done[1]) begin
					if (pooling_out_arr2.size() == 196) begin
						break;
					end
					@(posedge clk);
					//$display("[%t],clk = %b,pooling_out2 = %d,pooling_done2= %d",$time,clk,pooling_out[1],pooling_done[1]);
					pooling_out_arr2.push_back(pooling_out[1]);
				end
				#2;
			end
		end
	join
	for (int i = 0; i <pooling_out_arr.size() ; i++) begin
		if (pooling_out_arr[i] != correct_pool[i]) begin
			$display("error in index %d,wrong = %d, correct = %d ",i,pooling_out_arr[i],correct_pool[i]);
		end
	end
	$display("size of pooling_out = %d",pooling_out_arr.size());
	$display("All pooling_out = %p",pooling_out_arr);
	$display("size of pooling_out2 = %d",pooling_out_arr2.size());
	$display("All pooling_out2 = %p",pooling_out_arr2);

	$stop;
end
endmodule