module top_pooling
  #(  parameter data_width = 8)
   (   
       input clk,nrst,start,en,
       input [data_width-1:0]sys_out,
       Inout [data_width-1:0] pooling_out);
       output pooling_done;

    logic [datawidth-1:0] x,z;

    assign x =(get_this_from_control1)?sys_out:out;


    regfile Register_File(
        .clk(clk)
        .nrst(nrst)
        .Wr_ctrl1(get_this_from_control2)
        .wr_ctrl2(get_this_from_control3)
        .in1(sys_out)
        .in2(pooling_out)
        .add_in1(get_this_from_control4)
        .add_in2(get_this_from_control5)
        .add_out(get_this_from_control6)
        .out(z)
    )   


    pooling max_avg_pooling (
        .in1(x)
        .in2(z)
        .en(en)
        .out(pooling_out)
    )

    control pooling_control(
         .clk(clk) 
         .nrst(nrst)
         .start(start)
         .current_adrs1(get_this_from_control4)
         .current_adrs2(get_this_from_control5) 
         .current_adrs_out(get_this_from_control6)
         .mux_en(get_this_from_control1)
         .wr_ctrl1(get_this_from_control2)
         .wr_ctrl2(get_this_from_control3)
         .pool_done(pooling_done)
    )
endmodule
