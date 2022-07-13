module pooling_control #(
    parameter   address_num = 4 , 
                sys_width = 27 
)(
    input  logic clk, nrst,start,
    output  logic [address_num-1:0] adrs,adrs_out ,  
    output logic mux_en ,wr_ctrl1,wr_ctrl2,pool_done ,pooling_finish //wrctrl1 is for register #F only
);
//the required memory is (matrix size/2)+1  here we need (28/2)+1 = 15    but here we use memory its legth is 16 so there is one position didn't used 
// imp note the memory here is consists of 16 palces we use the first 14'th of them to stor the out of pooling two elemnts in buffering stage 
// and use the last elemnts the 16'th one to store the new value come from the systolic to the memory in odd clocks 
// we don't ust the 15'th element of the memory any way .. the index of this elemnt is 14 
logic [address_num-1:0]    next_adrs  , next_adrs_out   ; 
logic [4:0] current_col_counter  , next_col_counter,current_row_counter,next_row_counter  ; 
enum logic [1:0] {
                    idle = 2'b00,
                    buffering = 2'b01,  
                    working = 2'b10,
                    pooling_finished = 2'b11 }current_state,next_state;

always_ff @(posedge clk, negedge nrst) begin
    if(!nrst)
        begin
            current_state <= idle ; 
            /*current_adrs1 <= 0 ;
            current_adrs2 <= 0 ;
            current_adrs_out <= 0 ;*/
            current_col_counter  <= 0 ;
            current_row_counter <= 0;
        end
    else 
        begin
            current_state <= next_state ;
            /*current_adrs1 <= next_adrs1 ; 
            current_adrs2 <= next_adrs2 ;
            current_adrs_out <= next_adrs_out ;*/
            current_col_counter  <= next_col_counter;
            current_row_counter <= next_row_counter  ; 
        end
end                   

always_comb 
    begin
        unique case (current_state)

            idle : 
                begin
                    //adrs1 = 4'hf ; 
                    adrs = 4'h0 ;
                    adrs_out = 4'h0 ;
                    next_col_counter  = 0 ; 
                    next_row_counter = 0;
                    pool_done=0;
                    pooling_finish=0;
                    wr_ctrl1=0;
                    wr_ctrl1=0;
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
                    next_col_counter =current_col_counter +1;
                    pooling_finish=0;
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
                   if(current_col_counter ==0)//first clock in buffering is different as there is still 1 operation left over from working
                        begin
                            //mux_en=0;
                            wr_ctrl1=1;
                            wr_ctrl2=0;
                            //next_adrs_out=(sys_width >> 1);
                            adrs=4'h0;
                            if(next_row_counter==0) //first row won't have an output but every other one will as it generates last output left from working state
                            begin
                            pool_done=0;
                            mux_en=1;
                            adrs_out=4'hf;
                            end
                            else begin
                            pool_done=1;
                            mux_en=0;
                            adrs_out=(sys_width >> 1);
                            end
                        end 
                    else if( (current_col_counter [0]) ) // for odd counter read reg xF "the last one" 
                        begin
                            mux_en=1;
                            wr_ctrl1=0;
                            wr_ctrl2=1;
                            adrs_out=4'hf;
                            pool_done=0;
                            adrs=(current_col_counter  >> 1);
                        end   
                    else       // for even counter write reg (clk/2) and reg xF
                        begin
                            mux_en=1;
                            wr_ctrl1=1;
                            wr_ctrl2=0;
                            adrs_out=4'hf;
                            //adrs1=4'hf;  // always the same place the last elemnt 
                             // the first element in the memory and it will rais every odd clocks 
                            pool_done=0;
                        end
                    
                end
            working :
                begin
                    mux_en=(current_col_counter [0]);
                    next_col_counter =current_col_counter +1;
                     if(current_col_counter  == sys_width ) 
                        begin
                            if(current_row_counter==sys_width)begin 
                            next_state = pooling_finished;
                            //pooling_finish = 1 ; ///////  add the finish signal   
                            end
                            else begin 
                            next_state=buffering;      
                            //pooling_finish=0;//////// 
                            end 
                            
                            next_col_counter =0; 
                            next_row_counter =current_row_counter+1;

                        end
                    if(current_col_counter ==0)//first clock in working is different as there is still 1 operation left over from buffering
                        begin
                            wr_ctrl1=1;
                            wr_ctrl2=0;
                            adrs=(sys_width >> 1);
                            //adrs=4'hf;
                            adrs_out=4'hf;
                            pool_done=0;                           
                        end
                    else if( (current_col_counter [0]) ) // for odd counter read xF ////////
                        begin
                            wr_ctrl1=0;
                            wr_ctrl2=0;
                            adrs_out=4'hf;
                            pool_done=0;
                        end    
                    else  // for even counter write xF and read reg (clk/2)-1
                        begin
                             wr_ctrl1=1;
                             wr_ctrl2=0;
                             //adrs1=4'hf;
                             adrs_out=(current_col_counter  >> 1)-1;
                         if(!(current_col_counter ==1))
                             pool_done=1;
                         else
                             pool_done=0;
                        end    
                end
             pooling_finished:
                begin
                    mux_en=0;
                    wr_ctrl1=1;
                    wr_ctrl2=0;
                    adrs_out=(sys_width >> 1);
                    //adrs1=4'hf;
                    pooling_finish = 1 ;
                    pool_done = 1 ;
                    next_state = idle;
                end
        endcase
    end
endmodule 