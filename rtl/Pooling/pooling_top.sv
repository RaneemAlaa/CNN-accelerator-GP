module pooling_top
  #(  parameter data_width = 16,
      parameter col = 32,
      parameter address_num = 4
    )
   (   
       input clk,nrst,start,
       input en[col-1:0],
       input [data_width-1:0]sys_out[col-1:0],
       inout [data_width-1:0] pooling_out[col-1:0],
       output pooling_done[col-1:0],
       output pooling_finish[col-1:0];
    );

logic [data_width-1:0] x [col-1];
logic [data_width-1:0]z[col-1];
logic [data_width-1:0]out[col-1];
logic mux_en[col-1],Wr_ctrl1[col-1],Wr_ctrl2[col-1];
logic [address_num-1:0]add_in1[col-1];
logic [address_num-1:0]add_in2[col-1];
logic [address_num-1:0]add_out[col-1];

//instantiation and connection of all components of pooling unit excluding control

genvar i;
generate
    for(i=0;i<32;i=i+1)
    begin:pooling_unit 

         assign x[i] =(mux_en[i])?sys_out[i]:out[i]; // The mux that decides whether the input for the pooling operation will be the output of last operation or systolic array
//instantiation of the reg file 32 times
regfilePooling reg_file_Pooling(
            .clk(clk),
            .nrst(nrst),
            .wr_ctrl1(Wr_ctrl1[i]),
            .wr_ctrl2(Wr_ctrl2[i]),
            .in1(sys_out[i]),
            .in2(pooling_out[i]),
            .adrs_in1(add_in1[i]),
            .adrs_in2(add_in2[i]),
            .adrs_out(add_out[i]),
            .out(z[i])
        );

//instantiation of the pooling 32 times
        max_avg_pooling pooling (
            .in1(x[i]),
            .in2(z[i]),
            .en(en[i]),
            .out(pooling_out[i])
        );
    end:pooling_unit
endgenerate

//instantiation of control_unit that generates control signal for all 32 pooling units

pooling_control control(
         .clk(clk),
         .nrst(nrst),
         .start(start),
         .current_adrs1(add_in1[0]),
         .current_adrs2(add_in2[0]) ,
         .current_adrs_out(add_out[0]),
         .mux_en(mux_en[0]),
         .wr_ctrl1(Wr_ctrl1[0]),
         .wr_ctrl2(Wr_ctrl2[0]),
         .pool_done(pooling_done[0],
         .pooling_finish(pooling_finish[0]))
    );

    //instantiation of latches responsible for delay of control singal to reach each pooling unit at correct time

genvar j;
generate  
     for(j=1;j<32;j=j+1)
     begin:latch_vector

pooling_pipline pipeline(
         .enable(en[j-1]),
     .clk(clk),
     .nrst(nrst),

         .out_adrs1 (add_in1[j]), 
         .out_adrs2 (add_in2[j]),
         .out_adrs_out (add_out[j]), 
         .out_mux_en (mux_en[j]),
         .out_wr_ctrl1 (Wr_ctrl1[j]),
         .out_wr_ctrl2 (Wr_ctrl2[j]),
         .out_pool_done (pooling_done[j]),

         .in_adrs1 (add_in1[j-1]),
         .in_adrs2 (add_in2[j-1]),
         .in_adrs_out (add_out[j-1]),
         .in_mux_en (mux_en[j-1]),
         .in_wr_ctrl1 (Wr_ctrl1[j-1]),
         .in_wr_ctrl2 (Wr_ctrl2[j-1]),
         .in_pool_done (pooling_done[j-1]) );
    
    end:latch_vector
endgenerate
endmodule
