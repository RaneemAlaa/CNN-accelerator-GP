module flag_counter #(
    parameter counter_bits=9
    
) (
    input logic clk,nrst,
    input logic start,map_finish,
    output logic  flag // set size of flag register
);
    logic [counter_bits-1:0] current_count,next_count;
    enum logic [1:0] {
                    idle = 2'b00,
                    count_to_159 = 2'b01,  
                    count_to_4 = 2'b10,
                    count_to_26 = 2'b11 }current_state,next_state;

    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst||map_finish) begin
            current_count<=0;
            current_state<=idle;
        end else begin
            current_count<=next_count;
            current_state<=next_state;
        end
    end

    always_comb begin
            case (current_state)
                idle:
                    begin
                        next_count=0;
                        flag=0;
                        if(start)
                            next_state=count_to_159;
                        else 
                            next_state=idle;   
                    end
                count_to_159:
                    begin
                        flag=0;
                        if (current_count==159) begin
                            next_state=count_to_4;
                            next_count=0;
                        end 
                        else begin
                            next_state=count_to_159;
                            next_count=current_count+1;
                        end
                    end
                count_to_4:
                    begin
                        
                        if (current_count==4) begin
                            next_state=count_to_26;
                            flag=1;
                            next_count=0;
                        end 
                        else begin
                            next_state=count_to_4;
                            flag=0;
                            next_count=current_count+1;
                        end 
                    end
                count_to_26:
                    begin
                        
                        if (current_count==26) begin
                            next_state=count_to_4;
                            flag=clk;
                            next_count=0;
                        end 
                        else begin
                            next_state=count_to_26;
                            flag=0;
                            next_count=current_count+1;
                        end 
                    end

              
            endcase
    end
endmodule