module test_mapcontrol(); 
//the testbench for mapping controll 
logic clk,nrst,start ; 
logic [5:0] current_round,current_PU1_add,current_PU_No,current_row_No ; 

always
	#10 clk <= ~clk;


Map_Control map(
.clk(clk),
.nrst(nrst),
.start(start),
.current_round(current_round),
.current_PU1_add(current_PU1_add),
.current_PU_No(current_PU_No),
.current_row_No(current_row_No)) ; 

initial 
	begin 
		#0;          // added 
		clk = 0   ;  // added 
		nrst = 0  ;
		start = 0 ; 
		#10;         // make it 15 instead of 5 
		nrst = 1;
		start = 1 ; 
		#800000000 $finish; 
	end

initial 
	begin
		$monitor("thetime is = %t ,%b,%b,%b,%d,%d,%d,%d", $time,clk,nrst,start,current_round,current_PU1_add,current_PU_No,current_row_No); 
	end 
	
endmodule 
