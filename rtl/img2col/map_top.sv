module map_top #(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
) (
  input logic  clk,nrst,
  input logic  start,
  input logic  [data_width-1:0]  new1, new2,                            //data comes from AXI
  input logic  [address_num-1:0] adrs_in1, adrs_in2,
  output logic [data_width-1:0]  out [weight_size-1:0]
);
logic [5:0] round,PU1_add,PU_No,row_No;

logic [4:0] hoba;
assign hoba = (row_No*5)+PU1_add;

  pus_vector pus_vector(
      .round(round),
      .clk(clk),
      .nrst(nrst),
      .start(start),
      .PU_No(PU_No),
      .new1(new1),
      .new2(new2),                            //data comes from AXI
      .adrs_in1(adrs_in1),
      .adrs_in2(hoba),// used the useless port 
      .out(out)
  );

  Map_Control map_ctrl(
    .clk(clk),
    .nrst(nrst),
    .start(start),
    .current_round(round),
    .current_PU1_add(PU1_add),
    .current_PU_No(PU_No),
    .current_row_No(row_No)
  );
endmodule
