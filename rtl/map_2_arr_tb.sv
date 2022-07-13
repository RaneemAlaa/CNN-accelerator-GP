module map_2_arr_tb #(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
)();
	 logic clk, nrst,fifo_en,start;
     logic [24:0]out_vld;
     logic  [data_width-1:0]  new1;                            //data comes from AXI
 	 logic map_finish,flag;
	 logic  [15:0] data_out [24:0];
	 map_2_buffer dut(.clk(clk) , .data_out(data_out) , .fifo_en(fifo_en) , .flag(flag) , .map_finish(map_finish) , .new1(new1) , .nrst(nrst) , .out_vld(out_vld) , .start(start));
	 int mem [1023:0];
	 initial begin
	 	clk = 0;
 		forever 
    		#1 clk = !clk;
	 end
	 initial begin
		$readmemh("img.txt",mem);
		nrst = 0;
		fifo_en = 0;
		start = 0;
		#20
		nrst = 1;
		fork
			begin
				
		#2
		start = 1;
		for (int i = 0; i < 1024; i++) begin
			#2
			//new1 = mem[i];
			new1 = i;
			if (i == 163) begin
				fifo_en = 1;
			end
		end
		#25;
			end		
		join
	
		$stop;
	 end
	 initial begin
	 	$monitor("flag = %b,fifo_en =%b,new1 = %d,data_out = %p",flag, fifo_en, new1 , data_out);
	 end
endmodule 