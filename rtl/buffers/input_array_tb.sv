module input_array_tb ();
	logic[15:0] data_in [31:0] ;
    logic [31:0]out_vld;
    logic fifo_en,clk,nrst;
    logic  [15:0] data_out [31:0];
    int array [$];
    int j,k ;
    input_array dut(.data_in(data_in),.fifo_en(fifo_en),.clk(clk),.nrst(nrst),.out_vld(out_vld),.data_out(data_out));
    initial begin
    	clk = 0;
    	forever
    		#1 clk = !clk;
    end
    initial begin
        //reset
        j = 0;
        k = 0;
    	nrst = 0;
    	fifo_en = 0;
    	for (int i = 0; i < 32; i++) begin
    		data_in[i] = 0;
    	end
        @(posedge clk)
        $display("[%t],nrst = %b \n,fifo_en =%b \n,data_in = %p \n,out_vld =%b \n,data_out = %p \n",$time,nrst,fifo_en,data_in ,out_vld ,data_out);
    	@(negedge clk)
    	nrst = 1;
    	fifo_en = 1;
        @(posedge clk)
        $display("clk = %b,nrst = %b,fifo_en =%b",clk,nrst,fifo_en);
            repeat(33) begin
            @(negedge clk);
            for (int i = 0; i < 32; i++) begin
                data_in[i] = $urandom_range(1,100);
            end
            
            @(posedge clk)
            $display("[%t],data_in = %p \n,out_vld =%b \n,data_out = %p \n",$time,data_in ,out_vld ,data_out);
            if(j>=1)
            begin
                array.push_back(data_out[k]);
                k = k+1;
            
            end
            j = j+1;
            end
            $display("array = %p",array);
    	$stop;

    end
endmodule 
