module PUs #(
  parameter data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
) (
   input  logic  clk, nrst,start, neighbour_in_flag,wr_ctrl_g,act,
  input logic [5:0]round,PU_No,
  input logic  [address_num-1:0] adrs_in1, adrs_in2,
  input logic  [data_width-1:0]  new1,             //data comes from AXI
  input logic  [data_width-1:0]  neighbour_in [reg_num-1:0],       //data from neighbour PU
  output logic [data_width-1:0]  neighbour_out [reg_num-1:0],      //data to neighbour PU
  output logic [data_width-1:0]  out [weight_size-1:0],
  output  logic neighbour_out_flag,t_flag
);

logic  r_ctrl_g, wr_ctrl_r, r_ctrl_r, wr_ctrl_n, r_ctrl_n;
logic [data_width-1:0] out_g [4:0];
logic [data_width-1:0] in_r [reg_num-1:0];
logic [data_width-1:0] out_n [reg_num-1:0];
logic [data_width-1:0] out_r [reg_num-1:0];


  //new reg
  regfile1in #(.reg_num(5)) g (.clk(clk),
						.PU_No(PU_No),					
                                                .nrst(nrst),
                                                .wr_ctrl(wr_ctrl_g),
                                                .r_ctrl(r_ctrl_g),
                                                .in1(new1),
                                          	.act(act),
                                                .adrs_in1(adrs_in1),
                                                .adrs_in2(adrs_in2),
                                                .out(out_g));
   //neighbour reg
  PIPO  n (.clk(clk),
			   
                          .nrst(nrst),
                          .wr_ctrl(wr_ctrl_n),
                          .r_ctrl(r_ctrl_n),
                          .in(neighbour_in),
                          .out(out_n) );
  
  //reserved reg
  PIPO #(.reg_num(20)) r (.clk(clk),
                          .nrst(nrst),
                          .wr_ctrl(wr_ctrl_r),
                          .r_ctrl(r_ctrl_r),
                          .in(in_r),
                          .out(out_r)
  );

  //ctrl unit
  	PUs_control ctrl (
     .t_flag(t_flag),    
     .act(act),
    .out_g (out_g),
    .in_r (in_r),
    .out_r (out_r),
    .out_n(out_n),
    .clk(clk),
    .nrst(nrst),
    .start(start),
    .round(round),
    .neighbour_in_flag(neighbour_in_flag),
    .adrs_in1(adrs_in1), 
    .adrs_in2(adrs_in2),
    .wr_ctrl_g (wr_ctrl_g),
    .r_ctrl_g(r_ctrl_g),
    .wr_ctrl_r(wr_ctrl_r),
    .r_ctrl_r(r_ctrl_r),
    .wr_ctrl_n(wr_ctrl_n),
    .PU_No(PU_No),
    .r_ctrl_n(r_ctrl_n),
    .neighbour_out_flag(neighbour_out_flag), 
    .neighbour_out(neighbour_out),
    .out(out) 
  );
endmodule
