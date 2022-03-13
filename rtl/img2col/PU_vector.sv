module pus_vector#(
  parameter row         = 28,
            data_width  = 16,
            weight_size = 25,
            address_num = 5,
            reg_num     = 20
)(
  input logic  clk,nrst,
  input logic  [5:0] PU_No,round, //  logic  [5:0] round[row-1 : 0] ; 
  input logic   start, 
  input logic  [data_width-1:0]  new1, new2,                      //data comes from AXI
  input logic  [address_num-1:0] adrs_in1, adrs_in2,
  output logic [data_width-1:0] out[weight_size-1:0]
);
  logic  [5:0] PU_No_i,round_i[row-1 : 0] ; 
 logic [data_width-1:0] neighbour_out [row-2:0][reg_num-1:0];        //out from pu[x] & in to pu[x+1]
 logic  neighbour_out_flag [row-2:0];
 logic  neighbour_in_flag  [row-2:0];
 logic wr_ctrl_g [row-2:0];
 logic [data_width-1:0] Out[(28*weight_size)-1:0];
 logic  [5:0] PU_No_lol;
//PU1
 assign wr_ctrl_g[0] = (PU_No==0)?1:0;
 

 //PUs
  genvar i;
  generate
 PU1 pu1(
        .clk(clk),
        .nrst(nrst),
        .start(start),
        .round(round),
        .wr_ctrl_g(wr_ctrl_g[0]),
        .adrs_in1(adrs_in2),/// adrs pu1 from control top module
        .adrs_in2(adrs_in1),
        .new1(new1),
        .new2(new2),
        .neighbour_out(neighbour_out[0]),
        .neighbour_out_flag(neighbour_out_flag[0]),
	      .out(Out[weight_size-1:0])
    );
    for (i = 1; i < row; i = i + 1) 
    begin:PU
      assign    wr_ctrl_g[i]= (PU_No==i)?1:0;
      PUs pu (
        .clk(clk),
        .nrst(nrst),
        .start(start),
        .round(round),
        .wr_ctrl_g(wr_ctrl_g[i]),
        .adrs_in1(adrs_in1),
        .adrs_in2(adrs_in2),
        .new1(new1),
        .new2(new2),
        .neighbour_in(neighbour_out[i-1]),
        .neighbour_in_flag(neighbour_out_flag[i-1]),
        .neighbour_out(neighbour_out[i]),
        .neighbour_out_flag(neighbour_out_flag[i]),
	      .out(Out[((i+1)*weight_size)-1:i*weight_size])
    );
    end
endgenerate	 
always@(PU_No)
begin
PU_No_lol <= PU_No;
end
always_comb
begin
case(PU_No_lol)
0:out[weight_size-1:0]=Out[weight_size-1:0];
1:out[weight_size-1:0]=Out[(2*weight_size)-1:weight_size];
2:out[weight_size-1:0]=Out[(3*weight_size)-1:2*weight_size];
3:out[weight_size-1:0]=Out[(4*weight_size)-1:3*weight_size];
4:out[weight_size-1:0]=Out[(5*weight_size)-1:4*weight_size];
5:out[weight_size-1:0]=Out[(6*weight_size)-1:5*weight_size];
6:out[weight_size-1:0]=Out[(7*weight_size)-1:6*weight_size];
7:out[weight_size-1:0]=Out[(8*weight_size)-1:7*weight_size];
8:out[weight_size-1:0]=Out[(9*weight_size)-1:8*weight_size];
9:out[weight_size-1:0]=Out[(10*weight_size)-1:9*weight_size];
10:out[weight_size-1:0]=Out[(11*weight_size)-1:10*weight_size];
11:out[weight_size-1:0]=Out[(12*weight_size)-1:11*weight_size];
12:out[weight_size-1:0]=Out[(13*weight_size)-1:12*weight_size];
13:out[weight_size-1:0]=Out[(14*weight_size)-1:13*weight_size];
14:out[weight_size-1:0]=Out[(15*weight_size)-1:14*weight_size];
15:out[weight_size-1:0]=Out[(16*weight_size)-1:15*weight_size];
16:out[weight_size-1:0]=Out[(17*weight_size)-1:16*weight_size];
17:out[weight_size-1:0]=Out[(18*weight_size)-1:17*weight_size];
18:out[weight_size-1:0]=Out[(19*weight_size)-1:18*weight_size];
19:out[weight_size-1:0]=Out[(20*weight_size)-1:19*weight_size];
20:out[weight_size-1:0]=Out[(21*weight_size)-1:20*weight_size];
21:out[weight_size-1:0]=Out[(22*weight_size)-1:21*weight_size];
22:out[weight_size-1:0]=Out[(23*weight_size)-1:22*weight_size];
23:out[weight_size-1:0]=Out[(24*weight_size)-1:23*weight_size];
24:out[weight_size-1:0]=Out[(25*weight_size)-1:24*weight_size];
25:out[weight_size-1:0]=Out[(26*weight_size)-1:25*weight_size];
26:out[weight_size-1:0]=Out[(27*weight_size)-1:26*weight_size];
27:out[weight_size-1:0]=Out[(28*weight_size)-1:27*weight_size];
default:out<=out;
endcase
end
endmodule 
