module Map_Control(
input logic clk,nrst,start,
output logic [5:0] round,PU1_add,PU_No,row_No
);


typedef enum logic [1:0]{ 
Idle =2'b00,
Buffering =2'b01,
Working =2'b10}states;
states current_state,next_state; // *** 


always_ff @(posedge clk, negedge nrst)
begin
if(!nrst)begin
  current_state <= Idle;
        
end
else
  current_state <= next_state;
end

always_comb
begin
  case(current_state)
     Idle:begin
        PU1_add=0;
        PU_No=0;
        row_No=0;
        round=0;
          if(start)
            next_state=Buffering;
          else
            next_state=current_state;
end
Buffering:
          begin
          if(PU1_add==5'd04 )begin
             PU_No=PU_No+1;
               if(row_No==4'd04)begin
                  next_state=Working;
                  round=0;
                  end
               else
                  next_state=current_state;
               if(PU_No==5'd27)begin
                  PU_No=0;
                  PU1_add=0;
                  row_No=row_No+1;
		  next_state=current_state; // ***
		 end
               else begin
		next_state=current_state; // ***
		 end
               end
          else begin
          PU1_add=PU1_add+1;
	  next_state=current_state;  // ***  
          end
         
end
Working:
begin
           row_No =4'd04;
        
           if(PU1_add==5'd04 )begin
           PU_No=PU_No+1;
               if(PU_No==5'd27)
               begin
               round=round+1;
               PU_No=0;
               PU1_add=0;
               if(round==27)
               next_state=Idle;
               else
               next_state=current_state  ;    
               end  
           end 
           else
           PU1_add=PU1_add+1; 
	   next_state=current_state; // ***

end

endcase 
end

endmodule
