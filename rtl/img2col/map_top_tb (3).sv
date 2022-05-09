module map_top_tb#(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
) ;
logic  clk,nrst,start;
logic  [data_width-1:0]  new1;                       //data comes from AXI
logic  [address_num-1:0] adrs_in1, adrs_in2;
logic [data_width-1:0]  out [weight_size-1:0];
logic [data_width-1:0]  mem [1023:0];
int unsigned j;
int flag;
int col_num;
map_top #(.row(row),
	.data_width(data_width),
	.weight_size(weight_size),
	.address_num(address_num),
	.reg_num(reg_num))
	dut(.clk(clk),
		.nrst(nrst),
		.start(start),
		.new1(new1),
		.new2(new2),
		.out(out),
.col_num(col_num));
initial begin
	clk = 0;
	forever
		#1 clk = !clk;
end
initial begin
	//initialization
	nrst = 0;
	start = 0;
	new1 = 0;
	
	j = 0;
	adrs_in1 = 0;
	adrs_in2 = 0;
	#2;
	nrst = 1;
	start = 1;
	for (  int i = 0; i < 400; i = i+1) begin
		adrs_in1 = j;
		new1 = i;
		

		if (j == 31) begin
			j = 0;
			flag = 1;
		end
	/*	else if((j == 4 )&& (flag == 1)) begin
			j = 0;
		end*/
		else 
			j = j+1;

		#2;
	end

	$stop;
end
initial begin
	//$monitor("[%t],clk = %b, colnum = %d  ",$time,clk,col_num);
$monitor("[%t],clk = %b, nrst = %b,start = %b,new1 = %d, new2 = %d, adrs_in1 = %d, out = %p  ",$time,clk,nrst,start,new1,new2,adrs_in1,out);
end
endmodule