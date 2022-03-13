module PU_control#(
    parameter data_width  = 16,
    parameter reg_num = 20 ,
    parameter address_num = 5 ,
    parameter weight_size = 25 
  )(input logic [data_width-1:0] out_g [weight_size-1:0],
    output logic [data_width-1:0] in_r [reg_num-1:0],
    input logic [data_width-1:0] out_r [reg_num-1:0],
    input logic clk,nrst,wr_ctrl_g,
    input logic start, 
    input logic [5:0] round ,
    input logic [address_num-1:0] adrs_in1, adrs_in2,
    output logic r_ctrl_g, wr_ctrl_r , r_ctrl_r, neighbour_out_flag , 
    output logic [data_width-1:0] neighbour_out [reg_num-1:0],
    output logic [data_width-1:0] out [weight_size-1:0] 
);
logic [data_width-1:0] neighbour_out_zeros [15:0];
assign neighbour_out_zeros ='{default:16'h0000};
enum logic [1:0]  {idle=2'b00,
             write_g=2'b01,
             read_g=2'b10,
             write_r=2'b11} states ;

logic [1:0]current_state , next_state ; 

always_ff@(posedge clk , negedge nrst)
begin     
      if(!nrst)
        current_state<=idle;
      else
        current_state<=next_state;
end

   
 always_comb
   begin
     next_state=current_state;
     case(current_state)
      
       idle: 
		    begin 
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              r_ctrl_g  = 0;
	    
               neighbour_out_flag = 0;
              next_state = start? write_g : idle;
		    end 
       write_g: 
		    begin
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              r_ctrl_g  = 0;
               neighbour_out_flag = 0;
              next_state = ((adrs_in1==5'd24)&&wr_ctrl_g)? read_g : write_g;
			  end 
       read_g:
		    begin 
              wr_ctrl_r = 0;
              r_ctrl_r  = 1;

              r_ctrl_g  = 1;
               neighbour_out_flag = 1;
              next_state = write_r;
              if(round == 0) 
               begin
                assign neighbour_out = {out_g[4:1], out_g[9:6], out_g[14:11], out_g[19:16], out_g[24:21]}; //kant 14
                assign out = {out_g};
                
               end
              else 
               begin 
                assign neighbour_out = {out_g[24:21],neighbour_out_zeros};
                assign out = {out_r, out_g[24:20]};
               end
          end 
       write_r:
			  begin 
              wr_ctrl_r = 1;
              r_ctrl_r  = 0;
              r_ctrl_g  = 1;
               neighbour_out_flag = 0;
              next_state = write_g;
              if(round==0)
                assign in_r = out_g[24:5];
              else
                assign in_r = {out_r[19:5], out_g[24:20]};
	end 
      endcase 
   end

endmodule 
