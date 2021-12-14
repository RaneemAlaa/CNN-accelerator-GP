module Map_Control(
  input logic clk,nrst,start,
  output logic [5:0] current_round,current_PU1_add,current_PU_No,current_row_No
);


  enum logic [1:0]{ Idle      =2'b00,
                    Buffering =2'b01,
                    Working   =2'b10 }  next_state,current_state;

logic [5:0] next_PU1_add, next_PU_No, next_row_No, next_round ;
  always_ff @(posedge clk, negedge nrst)
  begin
    if(!nrst)begin
      current_state <= Idle;
      current_PU1_add <=0;
      current_PU_No <=0; 
      current_row_No <=0; 
      current_round <=0;      
    end
    else
    begin
      current_state   <= next_state;
      current_PU1_add <= next_PU1_add;
      current_PU_No   <= next_PU_No;
      current_row_No  <= next_row_No;
      current_round   <= next_round;
    end
  end

  always_comb
  begin
    next_state = current_state;
    next_PU1_add= current_PU1_add;
    next_PU_No=current_PU_No;
    next_row_No=current_row_No;
    next_round=current_round;
    unique case(current_state)
      Idle:
      begin
        next_PU1_add = 0;
        next_PU_No   = 0;
        next_row_No  = 0;
        next_round   = 0;
        if(start)
        begin
          next_state = Buffering;
        end
        else
        begin
          next_state = current_state;
        end
      end

      Buffering:
      begin
        if( next_PU1_add < 6'd04 )
        begin
          next_PU1_add = next_PU1_add + 1;
          next_state = Buffering;
        end
        else
        begin
          if( next_PU_No == 5'd27)
            begin
              next_PU_No   = 0;
              next_PU1_add = 0;
              next_row_No  = next_row_No + 1;
		          next_state=current_state;
            end
          else 
          begin
            next_PU_No = next_PU_No + 1;
            if( next_row_No == 4'd04)
            begin
            next_state = Working;
            next_round = 0;
            end
            else
            begin
              next_state = current_state;
            end
          end
        end
      end

    Working:
     begin
           if( next_PU1_add < 6'd04 )
             begin
              next_PU1_add = next_PU1_add + 1;
              next_state = current_state;
             end
           else
            begin
          if( next_PU_No == 5'd27)
            begin
              next_PU_No   = 0;
              next_PU1_add = 0;
              next_round  = next_round + 1;
		          next_state=current_state;
            end
          else 
          begin
            next_PU_No = next_PU_No + 1;
            if( next_round == 4'd27)
            begin
            next_state = Idle;
            next_round = current_round;
            end
            else
            begin
              next_state = current_state;
            end
          end
        end
      end

endcase 
end

endmodule
