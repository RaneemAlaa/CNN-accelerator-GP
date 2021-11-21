module PUs #(
  parameter data_width  = 16,
            weight_size = 25,
            address_num = 3,
            reg_num     = 20
) (
  input logic clk,nrst, wr_ctrl_g , r_ctrl_g, wr_ctrl_r , r_ctrl_r, wr_ctrl_n , r_ctrl_n,
  input logic [address_num-1:0] adrs_in1, adrs_in2,
  input logic [data_width-1:0] new1, new2,                       //data comes from AXI
  input logic [data_width-1:0] neighbour_in [reg_num-1:0],       //data from neighbour PU
  output logic [data_width-1:0] neighbour_out [reg_num-1:0],     //data to neighbour PU
  output logic [data_width-1:0] out [weight_size-1:0]
);

logic [data_width-1:0] out_g [4:0];
logic [data_width-1:0] in_r [reg_num-1:0];
logic [data_width-1:0] out_n [reg_num-1:0];
logic [data_width-1:0] out_r [reg_num-1:0];
//assign neighbour_out = {out[1:4], out[9:12], out[17:20], out[25:28], out[33:36]};

  //new reg
  regfile2in #(.reg_num(5), .address_num(3)) g (.clk(clk),
                                                .nrst(nrst),
                                                .wr_ctrl(wr_ctrl_g),
                                                .r_ctrl(r_ctrl_g),
                                                .in1(new1),
                                                .in2(new2),
                                                .adrs_in1(adrs_in1),
                                                .adrs_in2(adrs_in2),
                                                .out(out_g));
  //neighbour reg
  PIPO #(.reg_num(20)) n (.clk(clk),
                          .nrst(nrst),
                          .wr_ctrl(wr_ctrl_n),
                          .r_ctrl(r_ctrl_n),
                          .in(neighbour_in),
                          .out(out_n)
  );
  
  //reserved reg
  PIPO #(.reg_num(20)) r (.clk(clk),
                          .nrst(nrst),
                          .wr_ctrl(wr_ctrl_r),
                          .r_ctrl(r_ctrl_r),
                          .in(in_r),
                          .out(out_r)
  );

  //ctrl unit
endmodule