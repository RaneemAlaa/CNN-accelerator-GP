module pus_vector#(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
)(
  input logic clk,nrst,
  input logic  [data_width-1:0]  new1, new2,                            //data comes from AXI
  input logic  [address_num-1:0] adrs_in1, adrs_in2,
  output logic [data_width-1:0]  out [weight_size-1:0]
);

 logic [data_width-1:0] neighbour_out [row-2:0][reg_num-1:0];        //out from pu[x] & in to pu[x+1]

 //PU1
  PU1 pu1(
        .clk(clk),
        .nrst(nrst),
        .adrs_in1(adrs_in1),
        .adrs_in2(adrs_in2),
        .new1(new1),
        .new2(new2),
        .neighbour_out(neighbour_out[0]),
	      .out(out)
    );

 //PUs
  genvar i;
  generate
    for (i = 1; i < row; i = i + 1) 
    begin:PU 
      PUs pu(
        .clk(clk),
        .nrst(nrst),
        .adrs_in1(adrs_in1),
        .adrs_in2(adrs_in2),
        .new1(new1),
        .new2(new2),
        .neighbour_in(neighbour_out[i-1]),
        .neighbour_out(neighbour_out[i]),
	      .out(out)
    );
    end 
endgenerate	 

endmodule 