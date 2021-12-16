module pooling_control #(
    parameter   address_num = 4 , 
                sys_width = 28 
)(
    input  logic clk, nrst,start,
    output  logic [address_num-1:0] current_adrs1, current_adrs2 , current_adrs_out ,  
    output logic mux_en ,wr_ctrl1,wr_ctrl2,pool_done 
);

logic [address_num-1:0]    next_adrs1 , next_adrs2 , next_adrs_out   ; 
logic [4:0] current_col_counter  , next_col_counter,current_row_counter,next_row_counter  ; 
enum logic [1:0] {
                    idle = 2'b00,
                    buffering = 2'b01,  // in this state we will wate for 16 clock == 14 for first row +1 +1 
                    working = 2'b10 }current_state,next_state;

always_ff @(posedge clk, negedge nrst) begin
    if(!nrst)
        begin
            current_state <= idle ; 
            current_adrs1 <= 0 ;
            current_adrs2 <= 0 ;
            current_adrs_out <= 0 ;
            current_col_counter  <= 0 ;
            current_row_counter <= 0; 
        end
    else 
        begin
            current_state <= next_state ;
            current_adrs1 <= next_adrs1 ; 
            current_adrs2 <= next_adrs2 ;
            current_adrs_out <= next_adrs_out ;
            current_col_counter  <= next_col_counter;
            current_row_counter <= next_row_counter  ; 
        end
end                   

always_comb 
    begin
        unique case (current_state)

            idle : 
                begin
                    next_adrs1 = 0 ; 
                    next_adrs2 = 0 ;
                    next_adrs_out = 0 ;
                    next_col_counter  = 0 ; 
                    next_row_counter = 0;
                    pool_done=0;
                    if(start)
                        begin
                            next_state = buffering;
                        end
                    else
                        begin
                            next_state = current_state;
                        end 
                end 
            buffering :
                begin
                    mux_en=0;
                    next_col_counter =current_col_counter +1;
                    if(current_col_counter  == sys_width ) 
                        begin 
                            next_state = working ;
                            next_col_counter =0;
                            next_row_counter =current_row_counter+1;
                        end
                    else 
                        begin 
                          next_state=current_state;  
                        end
                    if(current_col_counter ==0)
                        begin
                            wr_ctrl1=1;
                            wr_ctrl2=0;
                            next_adrs_out=sys_width >> 2;
                            next_adrs1=4'hf;
                            if(next_row_counter==0)
                            pool_done=0;
                            else
                            pool_done=1;
                        end
                    else if( (current_col_counter [0]) ) // to even on odd clocks for workin for 14 times only 
                        begin
                            wr_ctrl1=0;
                            wr_ctrl2=0;
                            next_adrs_out=4'hf;
                            pool_done=0;
                        end   
                    else
                        begin
                            wr_ctrl1=1;
                            wr_ctrl2=1;
                            next_adrs1=4'hf;
                            next_adrs2=(current_col_counter  >> 1)-1;
                            pool_done=0;
                        end
                end
            working :
                begin
                    mux_en=!(current_col_counter [0]);
                    next_col_counter =current_col_counter +1;
                     if(current_col_counter  == sys_width ) 
                        begin 
                            next_state = buffering ;
                            next_col_counter =0; 
                            next_row_counter =current_row_counter+1;
                            if(current_row_counter==sys_width)
                            next_state = idle;
                            else
                            next_state=current_state;
                        end
                    if(current_col_counter ==0)
                        begin
                            wr_ctrl1=1;
                            wr_ctrl2=1;
                            next_adrs2=sys_width >> 1;
                            next_adrs1=4'hf;
                            pool_done=0;                           
                        end
                    if( (current_col_counter [0]) ) // to work on even clocks for workin for 14 times only 
                        begin
                            wr_ctrl1=0;
                            wr_ctrl2=0;
                            next_adrs_out=4'hf;
                            if(!(current_col_counter ==1))
                                pool_done=1;
                            else
                                pool_done=0;
                        end    
                    else
                        begin
                             wr_ctrl1=1;
                             wr_ctrl2=0;
                             next_adrs1=4'hf;
                             next_adrs2=(current_col_counter  >> 1)-1;
                             pool_done=0;
                        end    
                end
        endcase
    end
endmodule 