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
  output logic [data_width-1:0] out[weight_size-1:0],
  output logic  neighbour_out_flag [row-2:0]
);
  logic  [5:0] PU_No_i,round_i[row-1 : 0] ; 
 logic [data_width-1:0] neighbour_Out [(28*reg_num)-1:0];
 logic [data_width-1:0] neighbour_out [reg_num-1:0];
 logic [data_width-1:0] neighbour_in [reg_num-1:0];       //out from pu[x] & in to pu[x+1]
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
       
        .neighbour_out(neighbour_Out[reg_num-1:0]),
        .neighbour_out_flag(neighbour_out_flag[0]),
	      .out(Out[weight_size-1:0])
    );
    for (i = 1; i < row; i = i + 1) 
    begin:PU
assign neighbour_in_flag[i] = neighbour_out_flag[i-1];
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
        .PU_No(PU_No),
        .neighbour_in(neighbour_Out[(i*reg_num)-1:(i-1)*reg_num]),
        .neighbour_in_flag(neighbour_in_flag[i]),
        .neighbour_out(neighbour_Out[((i+1)*reg_num)-1:i*reg_num]),
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
default:out = out;
endcase
end

always_comb
begin
case(PU_No_lol)
0:neighbour_in[reg_num-1:0]=neighbour_Out[reg_num-1:0];
1:neighbour_in[reg_num-1:0]=neighbour_Out[(2*reg_num)-1:reg_num];
2:neighbour_in[reg_num-1:0]=neighbour_Out[(3*reg_num)-1:2*reg_num];
3:neighbour_in[reg_num-1:0]=neighbour_Out[(4*reg_num)-1:3*reg_num];
4:neighbour_in[reg_num-1:0]=neighbour_Out[(5*reg_num)-1:4*reg_num];
5:neighbour_in[reg_num-1:0]=neighbour_Out[(6*reg_num)-1:5*reg_num];
6:neighbour_in[reg_num-1:0]=neighbour_Out[(7*reg_num)-1:6*reg_num];
7:neighbour_in[reg_num-1:0]=neighbour_Out[(8*reg_num)-1:7*reg_num];
8:neighbour_in[reg_num-1:0]=neighbour_Out[(9*reg_num)-1:8*reg_num];
9:neighbour_in[reg_num-1:0]=neighbour_Out[(10*reg_num)-1:9*reg_num];
10:neighbour_in[reg_num-1:0]=neighbour_Out[(11*reg_num)-1:10*reg_num];
11:neighbour_in[reg_num-1:0]=neighbour_Out[(12*reg_num)-1:11*reg_num];
12:neighbour_in[reg_num-1:0]=neighbour_Out[(13*reg_num)-1:12*reg_num];
13:neighbour_in[reg_num-1:0]=neighbour_Out[(14*reg_num)-1:13*reg_num];
14:neighbour_in[reg_num-1:0]=neighbour_Out[(15*reg_num)-1:14*reg_num];
15:neighbour_in[reg_num-1:0]=neighbour_Out[(16*reg_num)-1:15*reg_num];
16:neighbour_in[reg_num-1:0]=neighbour_Out[(17*reg_num)-1:16*reg_num];
17:neighbour_in[reg_num-1:0]=neighbour_Out[(18*reg_num)-1:17*reg_num];
18:neighbour_in[reg_num-1:0]=neighbour_Out[(19*reg_num)-1:18*reg_num];
19:neighbour_in[reg_num-1:0]=neighbour_Out[(20*reg_num)-1:19*reg_num];
20:neighbour_in[reg_num-1:0]=neighbour_Out[(21*reg_num)-1:20*reg_num];
21:neighbour_in[reg_num-1:0]=neighbour_Out[(22*reg_num)-1:21*reg_num];
22:neighbour_in[reg_num-1:0]=neighbour_Out[(23*reg_num)-1:22*reg_num];
23:neighbour_in[reg_num-1:0]=neighbour_Out[(24*reg_num)-1:23*reg_num];
24:neighbour_in[reg_num-1:0]=neighbour_Out[(25*reg_num)-1:24*reg_num];
25:neighbour_in[reg_num-1:0]=neighbour_Out[(26*reg_num)-1:25*reg_num];
26:neighbour_in[reg_num-1:0]=neighbour_Out[(27*reg_num)-1:26*reg_num];

endcase
end
endmodule 
