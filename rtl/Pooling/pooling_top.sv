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
pooling_control control(
         .clk(clk),
         .nrst(nrst),
         .start(start),
         .current_adrs1(add_in1),
         .current_adrs2(add_in2) ,
         .current_adrs_out(add_out),
         .mux_en(mux_en),
         .wr_ctrl1(Wr_ctrl1),
         .wr_ctrl2(Wr_ctrl2),
         .pool_done(pooling_done)
    );
endmodule
