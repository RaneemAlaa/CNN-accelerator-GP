module pooling_pipline#(parameter   address_num = 4 )(
    input  logic clk, nrst,enable, 

    input  logic [address_num-1:0] in_adrs1, in_adrs2 , in_adrs_out ,  
    input  logic in_mux_en , in_wr_ctrl1, in_wr_ctrl2, in_pool_done ,

    output  logic [address_num-1:0] out_adrs1, out_adrs2 , out_adrs_out ,  
    output logic  out_mux_en , out_wr_ctrl1, out_wr_ctrl2, out_pool_done 
);

always_ff @(posedge clk, negedge nrst) 
    begin
            if (!nrst) 
                begin
                    out_adrs1 <= 0 ;
                    out_adrs2 <= 0 ;
                    out_adrs_out <= 0 ;
                    out_mux_en <= 0 ; 
                    out_mux_en <= 0 ;
                    out_wr_ctrl2 <= 0 ;
                    out_wr_ctrl2 <= 0 ;
                end
            else 
                begin
                    if(enable)
                        begin
                            out_adrs1 <= in_adrs1 ;
                            out_adrs2 <= in_adrs2 ;
                            out_adrs_out <= in_adrs_out ;
                            out_mux_en <= in_mux_en ;
                            out_wr_ctrl1 <= in_wr_ctrl1 ;
                            out_wr_ctrl2 <= in_wr_ctrl2 ;
                            out_pool_done <= in_pool_done ; 
                        end
                    else 
                        begin
                            out_adrs1 <= out_adrs1 ;
                            out_adrs2 <= out_adrs2 ;
                            out_adrs_out <= out_adrs_out ;
                            out_mux_en <= out_mux_en ;
                            out_wr_ctrl1 <= out_wr_ctrl1 ;
                            out_wr_ctrl2 <= out_wr_ctrl2 ;
                            out_pool_done <= out_pool_done ;
                        end
                end    
    end
endmodule