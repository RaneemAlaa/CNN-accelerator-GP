module PUs_control#(
    parameter data_width  = 16,
    parameter reg_num = 20 ,
    parameter address_num = 5,
    parameter weight_size = 25 
  )(input logic [data_width-1:0] out_g [4:0],
   output logic [data_width-1:0] in_r [reg_num-1:0],// the error here that it was an input
    input logic [data_width-1:0] out_r [reg_num-1:0],
    input logic [data_width-1:0] out_n [reg_num-1:0],
    input logic clk,nrst,start,neighbour_in_flag,
    input logic [5:0] round,
    input logic [address_num-1:0] adrs_in1, adrs_in2,wr_ctrl_g ,
    output logic  r_ctrl_g, wr_ctrl_r,r_ctrl_n, wr_ctrl_n , r_ctrl_r, neighbour_out_flag, 
    output logic [data_width-1:0] neighbour_out [reg_num-1:0],
    output logic [data_width-1:0] out [weight_size-1:0] 
);
logic [15:0] neighbour_out_zeros ; 

enum logic [1:0]  {idle=2'b00,
             write_g=2'b01,
             read_g=2'b10,
             write_r=2'b11} states ;

logic current_state , next_state ; 

always_ff@(posedge clk , negedge nrst)
begin     
      if(nrst)
        current_state<=idle;
      else
        current_state<=next_state;
end

   
 always@(*)
   begin
     case(current_state)
      
       idle: 
		    begin 
              wr_ctrl_n = 0;
              r_ctrl_n = 0;  
              wr_ctrl_r = 0;
              r_ctrl_r = 0;
              r_ctrl_g = 0;
               neighbour_out_flag= 0;
              next_state = start? write_g : idle;
		    end 
       write_g: 
		    begin
              wr_ctrl_n = neighbour_in_flag;
              r_ctrl_n  = 0;
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              r_ctrl_g  = 0;
               neighbour_out_flag= 0;
              next_state = ((adrs_in1==3'd4)&&wr_ctrl_g)? read_g : write_g;
			  end 
       read_g:
		begin 
              wr_ctrl_n = 0;
              r_ctrl_n  = 1;
              wr_ctrl_r = 0;
              r_ctrl_r  = 1;
              r_ctrl_g  = 1;
               neighbour_out_flag= 1;
              next_state = write_r;
              if(round==0) 
               begin
                assign neighbour_out = {out_n[3:1],out_g[0],out_n[7:5],out_g[2],out_n[11:9],out_g[3],out_n[15:13],out_g[4],out_n[19:17],out_g[5]};
                assign out = {out_n[3:0],out_g[0],out_n[7:4],out_g[1],out_n[11:8],out_g[2],out_n[15:12],out_g[3],out_n[19:16],out_g[4]};
                
               end
              else 
               begin 
		//assign neighbour_out_zeros= '{default:16'h0000} ; {16{1'b0}}
                assign neighbour_out = {out_n[19:17],out_g[4], 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0  }; 
                assign out = {out_r,out_n[19:16],out_g[4]};
               end
          end 


       write_r:
			begin 
             wr_ctrl_n = 0;
              r_ctrl_n = 0;
              wr_ctrl_r = 1;
              r_ctrl_r = 0;
              r_ctrl_g = 1;
               neighbour_out_flag=0;
              next_state = write_g;
              if(round==0)
           in_r = {out_n[7:4],out_g[1],out_n[11:8],out_g[2],out_n[15:12],out_g[3],out_n[19:16],out_g[4]};
              else
            in_r = {out_r[19:5], out_n[19:16],out_g[4]};
	end 
      endcase 
   end
endmodule
