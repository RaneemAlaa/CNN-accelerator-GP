module sys_mod_tb ;
	parameter width = 16, col = 32, row = 32  ;
	logic clk, nrst,conv_ctrl;
	logic [col-1:0]weight_en;
	logic [4:0] weight_dim;
	logic [width-1:0] weight_input2 [col-1:0] ;
	logic [width-1:0] feature_input2 [row-1:0];
	logic [width-1:0] systolic_out [col-1:0];
	logic conv_finish;
    systolic_top  #(.width(width),
	.col(col),
	.row(row))
	dut(.clk(clk),
		.nrst(nrst),
		.conv_ctrl(conv_ctrl),
		.weight_en(weight_en),
		.weight_dim(weight_dim),
		.weight_input2(weight_input2),
		.feature_input2(feature_input2),
		.systolic_out(systolic_out),
		.conv_finish(conv_finish)
		);
	int weight_in[24:0],weight_in2[24:0],in_row1 [783:0],in_row2 [783:0],in_row3 [783:0],in_row4 [783:0],in_row5 [783:0]
	,in_row6 [783:0],in_row7 [783:0],in_row8 [783:0],in_row9 [783:0],in_row10 [783:0],in_row11 [783:0],in_row12 [783:0]
	,in_row13 [783:0],in_row14 [783:0],in_row15 [783:0],in_row16 [783:0],in_row17 [783:0],in_row18 [783:0],in_row19 [783:0],in_row20 [783:0],in_row21 [783:0]
	,in_row22 [783:0],in_row23 [783:0],in_row24 [783:0],in_row25 [783:0],mem[19599:0];
	int sys_out_arr [$];
	int sys_out_arr2 [$];

initial begin
	clk = 0;
 	forever 
    	#1 clk = !clk;
end
initial
begin
//initialization
weight_in = '{1,0,1,0,1,1,1,1,0,0,0,1,1,0,1,0,1,1,0,0,1,1,0,0,1};
weight_in2 = '{1,0,0,1,1,0,0,1,1,0,1,0,1,1,0,0,0,1,1,1,1,0,1,0,1};

//$display("weight_in = %d",weight_in[2]);
 $readmemh("img_in.txt",mem);
 in_row1=mem[783:0];
 in_row2=mem[1567:784];
 in_row3=mem[2351:1568];
 in_row4=mem[3135:2352];
 in_row5=mem[3919:3136];
 in_row6=mem[4703:3920];
 in_row7=mem[5487:4704];
 in_row8=mem[6271:5488];
 in_row9=mem[7055:6272];
 in_row10=mem[7839:7056];
 in_row11=mem[8623:7840];
 in_row12=mem[9407:8624];
 in_row13=mem[10191:9408];
 in_row14=mem[10975:10192];
 in_row15=mem[11759:10976];
 in_row16=mem[12543:11760];
 in_row17=mem[13327:12544];
 in_row18=mem[14111:13328];
 in_row19=mem[14895:14112];
 in_row20=mem[15679:14896];
 in_row21=mem[16463:15680];
 in_row22=mem[17247:16464];
 in_row23=mem[18031:17248];
 in_row24=mem[18815:18032];
 in_row25=mem[19599:18816];

nrst = 0;
conv_ctrl = 0;
weight_dim = 25; 
for (int i = 0; i < col; i++) begin
	weight_input2[i] = $random;
	weight_en[i] = 0;
end
for (int j = 0; j < row; j++) begin
	feature_input2[j] = 0;
end
//conv_ctrl = 0 -->load weight in each PE
#2
nrst = 1;
weight_en[0] = 1;
weight_en[1] = 1;
for (int i = 0; i < 25; i++) begin
	@(negedge clk);
	if(i == 24)
		conv_ctrl = 1;

	weight_input2[0] = weight_in[i];
	weight_input2[1] = weight_in2[i];
	
end
for (int i = 0; i < 808; i++) begin
	if(conv_finish) begin
		@(posedge clk);
		sys_out_arr.push_back(systolic_out[0]);
		sys_out_arr2.push_back(systolic_out[1]);
	end	
	@(negedge clk);
	weight_en[0] = 0;
	weight_en[1] = 0;
	if (i >= 784) begin
		feature_input2[0] =$random;
	end
	else
		feature_input2[0] =in_row1[i];
	if (i == 0) begin
		continue;
	end
	if (i >= 785) begin
		feature_input2[1] =$random;
	end
	else
		feature_input2[1] =in_row2[i-1];
	
	if (i == 1) begin
		continue;
	end
	if (i >= 786) begin
		feature_input2[2] =$random;
	end
	else
		feature_input2[2] =in_row3[i-2];
	if (i == 2) begin
		continue;
	end
	if (i >= 787) begin
		feature_input2[3] =$random;
	end
	else
		feature_input2[3] =in_row4[i-3];
	
	if (i == 3) begin
		continue;
	end
	if (i >= 788) begin
		feature_input2[4] =$random;
	end
	else
		feature_input2[4] =in_row5[i-4];
	if (i == 4) begin
		continue;
	end
	if (i >= 789) begin
		feature_input2[5] =$random;
	end
	else
		feature_input2[5] =in_row6[i-5];
	if (i == 5) begin
		continue;
	end
	if (i >= 790) begin
		feature_input2[6] =$random;
	end
	else
		feature_input2[6] =in_row7[i-6];
	if (i == 6) begin
		continue;
	end
	if (i >= 791) begin
		feature_input2[7] =$random;
	end
	else
		feature_input2[7] =in_row8[i-7];
	if (i == 7) begin
		continue;
	end
	if (i >= 792) begin
		feature_input2[8] =$random;
	end
	else
		feature_input2[8] =in_row9[i-8];
	if (i == 8) begin
		continue;
	end
	if (i >= 793) begin
		feature_input2[9] =$random;
	end
	else
		feature_input2[9] =in_row10[i-9];
	if (i == 9) begin
		continue;
	end
	if (i >= 794) begin
		feature_input2[10] =$random;
	end
	else
		feature_input2[10] =in_row11[i-10];
	if (i == 10) begin
		continue;
	end

	if (i >= 795) begin
		feature_input2[11] =$random;
	end
	else
		feature_input2[11] =in_row12[i-11];
	if (i == 11) begin
		continue;
	end

	if (i >= 796) begin
		feature_input2[12] =$random;
	end
	else
		feature_input2[12] =in_row13[i-12];
	if (i == 12) begin
		continue;
	end

	if (i >= 797) begin
		feature_input2[13] =$random;
	end
	else
		feature_input2[13] =in_row14[i-13];
	if (i == 13) begin
		continue;
	end

	if (i >= 798) begin
		feature_input2[14] =$random;
	end
	else
		feature_input2[14] =in_row15[i-14];
	if (i == 14) begin
		continue;
	end
	if (i >= 799) begin
		feature_input2[15] =$random;
	end
	else
		feature_input2[15] =in_row16[i-15];
	if (i == 15) begin
		continue;
	end

	if (i >= 800) begin
		feature_input2[16] =$random;
	end
	else
		feature_input2[16] =in_row17[i-16];
	if (i == 16) begin
		continue;
	end
	if (i >= 801) begin
		feature_input2[17] =$random;
	end
	else
		feature_input2[17] =in_row18[i-17];
	if (i == 17) begin
		continue;
	end
	if (i >= 802) begin
		feature_input2[18] =$random;
	end
	else
		feature_input2[18] =in_row19[i-18];
	if (i == 18) begin
		continue;
	end
	if (i >= 803) begin
		feature_input2[19] =$random;
	end
	else
		feature_input2[19] =in_row20[i-19];
	if (i == 19) begin
		continue;
	end
	if (i >= 804) begin
		feature_input2[20] =$random;
	end
	else
		feature_input2[20] =in_row21[i-20];
	if (i == 20) begin
		continue;
	end
	if (i >= 805) begin
		feature_input2[21] =$random;
	end
	else
		feature_input2[21] =in_row22[i-21];
	if (i == 21) begin
		continue;
	end
	if (i >= 806) begin
		feature_input2[22] =$random;
	end
	else
		feature_input2[22] =in_row23[i-22];
	if (i == 22) begin
		continue;
	end
	if (i >= 807) begin
		feature_input2[23] =$random;
	end
	else
	feature_input2[23] =in_row24[i-23];
	if (i == 23) begin
		continue;
	end
	feature_input2[24] =in_row25[i-24];

end
for (int i = 0; i < 150; i++) begin
	/*if (sys_out_arr.size()==784) begin
		break;	
	end*/
	/*else*/ if(conv_finish) begin
		@(posedge clk);
		sys_out_arr.push_back(systolic_out[0]);
		sys_out_arr2.push_back(systolic_out[1]);
	end	

end
nrst = 0;
#10
$display("size of sys_out = %d",sys_out_arr.size());
$display("All sys_out = %p",sys_out_arr);
$display("size of sys_out2 = %d",sys_out_arr2.size());
$display("All sys_out2 = %p",sys_out_arr2);
$stop;
end

/*initial begin
//$monitor("[%0t],clk = %b, feature_input2 = %p",$time,clk,feature_input2);	
//$monitor("[%0t],clk = %b, reset= %b, ctrl= %b,w_ps =%b,conv_finish = %b ,first_out = %b, out= %d",$time,clk,nrst,conv_ctrl,dut.w_ps,dut.ctrl_inst.first_out,conv_finish,systolic_out[0]);
end*/
endmodule 
