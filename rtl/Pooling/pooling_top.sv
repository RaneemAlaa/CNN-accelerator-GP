module max_avg_pooling
  #(  parameter data_width = 8)
   (   
       input clk,nrst,start,en,
       input [data_width-1:0]sys_out,pooling_out,
       output [data_width-1:0] out);

    logic [datawidth-1:0] x,z;

    assign x =(get_this_from_control1)?sys_out:out;


    regfile Register_File(
        .clk(clk)
        .nrst(nrst)
        .Wr_ctrl(get_this_from_control2)
        .in1(sys_out)
        .in2(out)
        .add_in1(get_this_from_control3)
        .add_in2(get_this_from_control4)
        .add_out(get_this_from_control5)
        .out(z)
    )   


    pooling max_avg_pooling (
        .in1(x)
        .in2(z)
        .en(en)
        .out(out)
    )
endmodule
