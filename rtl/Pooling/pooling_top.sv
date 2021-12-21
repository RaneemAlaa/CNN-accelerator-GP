module pooling_top
  #(  parameter data_width = 16,
      parameter col = 32
    )
   (   
       input clk,nrst,start,en,
       input [data_width-1:0]sys_out[col-1],
       inout [data_width-1:0] pooling_out[col-1],
       output pooling_done[col-1]
    );

logic [data_width-1:0] x,z,out[col-1];
logic mux_en,Wr_ctrl1,Wr_ctrl2,add_in1,add_in2,add_out;
 
genvar i;
generate
    for(i=0;i<32;i=i+1)
    begin:pooling_unit 
         assign x[i] =(mux_en)?sys_out[i]:out[i];

regfilePooling reg_file_Pooling(
            .clk(clk),
            .nrst(nrst),
            .Wr_ctrl1(Wr_ctrl1),
            .wr_ctrl2(Wr_ctrl2),
            .in1(sys_out[i]),
            .in2(pooling_out[i]),
            .add_in1(add_in1),
            .add_in2(add_in2),
            .add_out(add_out),
            .out(z[i])
        );


        max_avg_pooling pooling (
            .in1(x[i]),
            .in2(z[i]),
            .en(en),
            .out(pooling_out[i])
        );
    end:pooling_unit
endgenerate



genvar j ; 
generate
    for(i=0; i < 31 ; i = i + 1 )
        begin : pipline // the first two rows fro inputs and the other two is for the out out 
            pooling_pipline pipe(.clk(clk),.nrst(nrst),.enable(enable),
            //////////////////
            .in_adrs1(add_in[i]),.in_adrs2(add_in[i]),.in_adrs_out(add_out[i]),
            .in_mux_en(mux_en[i]),.in_wr_ctrl1(Wr_ctrl[i]), .in_wr_ctrl2(Wr_ctrl[i]), .in_pool_done(pooling_done[i]) ,
            /////////////////
            .out_adrs1(out_adrs[i]),.out_adrs2(out_adrs[i]) , .out_adrs_out(out_adrs_out[i]) ,.out_mux_en(out_mux_en[i]) ,
            .out_wr_ctrl1(out_wr_ctrl1[i]), .out_wr_ctrl2(out_wr_ctrl2[i]), .out_pool_done(out_pool_done[i]) );
        end : pipline
endgenerate
