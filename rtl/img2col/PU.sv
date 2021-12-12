module PU1 #(
  parameter data_width  = 16,
            weight_size = 25,
	          address_num = 5, 
            reg_num     = 20
) (
  input  logic  clk, nrst, start, round,
  input  logic  [address_num-1:0] adrs_in1, adrs_in2,
  input  logic  [data_width-1:0] new1, new2,                       //data comes from AXI
  output logic  [data_width-1:0] neighbour_out [reg_num-1:0],     //data to neighbour PU
  output logic  [data_width-1:0] out [weight_size-1:0],
  output logic  neighbour_out_flag
);

logic wr_ctrl_g, r_ctrl_g, wr_ctrl_r, r_ctrl_r;
logic [data_width-1:0] out_g [24:0];
logic [data_width-1:0] in_r [reg_num-1:0];
logic [data_width-1:0] out_r [reg_num-1:0];


  //new reg
  regfile2in #(.reg_num(25)) g (.clk(clk),
                                .nrst(nrst),
                                .wr_ctrl(wr_ctrl_g),
                                .r_ctrl(r_ctrl_g),
                                .in1(new1),
                                .in2(new2),
                                .adrs_in1(adrs_in1),
                                .adrs_in2(adrs_in2),
                                .out(out_g));
  //reserved reg
  PIPO r (.clk(clk),
          .nrst(nrst),
          .wr_ctrl(wr_ctrl_r),
          .r_ctrl(r_ctrl_r),
          .in(in_r),
          .out(out_r)
  );

  //ctrl unit
	PU_control ctrl (
    .out_g (out_g),
    .in_r (in_r),
    .out_r (out_r),
    .clk(clk),
    .nrst(nrst),
    .start(start),
    .round(round),
    .adrs_in1(adrs_in1), 
    .adrs_in2(adrs_in2),
    .wr_ctrl_g (wr_ctrl_g),
    .r_ctrl_g(r_ctrl_g),
    .wr_ctrl_r(wr_ctrl_r),
    .r_ctrl_r(r_ctrl_r),
    .neighbour_out_flag(neighbour_out_flag), 
    .neighbour_out(neighbour_out),
    .out(out) 
  );

endmodule