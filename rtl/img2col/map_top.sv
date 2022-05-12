module map_top #(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
) (
  input logic  clk,nrst,flag,
  input logic  start,
  input logic  [data_width-1:0]  new1, new2,                            //data comes from AXI
  output logic map_finish,
  output logic [data_width-1:0]  out [weight_size-1:0],
output logic [63:0] col_num
);
logic [5:0] round,PU1_add,row_No;
logic [5:0]PU_No;
logic  [address_num-1:0] adrs_in1, adrs_in2;
logic [4:0] hoba;
logic act;
 logic  [data_width-1:0] regin;
logic  neighbour_out_flag [row-1:0];
 logic  t_flag[row-1:0];
assign hoba = (row_No*5)+PU1_add;
assign col_num=PU1_add+PU_No; 
  pus_vector pus_vector(
      .round(round),
      .clk(clk),
      .t_flag(t_flag),
      .nrst(nrst),
      .start(start),
      .PU_No(PU_No),
      .new1(new1),
      //.new2(new2),                            //data comes from AXI
      .adrs_in1(row_No),
      .adrs_in2(hoba),// used the useless port 
      .out(out),
      .neighbour_out_flag(neighbour_out_flag ),
       .act(act)

  );

  Map_Control map_ctrl(
    .clk(clk),
    .t_flag(t_flag),
    .nrst(nrst),
    .start(start),
    .current_round(round),
    .current_PU1_add(PU1_add),
    .current_PU_No(PU_No),
    .current_row_No(row_No),
    .neighbour_out_flag (neighbour_out_flag),
    .act(act),
    .map_finish(map_finish) );
//hreg in (.clk(clk),
 //   .nrst(nrst),
 //   .reg_in({new1,new2}),
 //   .reg_out(regin)	);
endmodule
