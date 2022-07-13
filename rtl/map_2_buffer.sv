module map_2_buffer#(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
)(	input logic clk, nrst,fifo_en,start,
    input logic [24:0]out_vld,
    input logic  [data_width-1:0]  new1,                            //data comes from AXI
 	output logic map_finish,flag,
	output var  [15:0] data_out [24:0]
  );
	logic  [15:0] map_2_arr [24:0] ;
	map_top g0(.clk(clk) , .flag(flag) , .map_finish(map_finish) , .new1(new1) , .nrst(nrst) , .start(start) , .out(map_2_arr));
	input_array g1(.clk(flag) , .nrst(nrst) , .data_out(data_out) , .fifo_en(fifo_en) , .out_vld(out_vld) , .data_in(map_2_arr));
endmodule