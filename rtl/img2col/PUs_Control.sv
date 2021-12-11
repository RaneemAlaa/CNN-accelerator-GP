module PUs_control#(
    parameter data_width  = 16,
    parameter reg_num = 20 ,
    parameter address_num = 2 ,
    parameter weight_size = 25 
  )(input logic [data_width-1:0] out_g [24:0],
    input logic [data_width-1:0] in_r [reg_num-1:0],
    input logic [data_width-1:0] out_r [reg_num-1:0],
    input logic [data_width-1:0] out_n [reg_num-1:0],
    input logic clk,nrst,start,round,neightor_in_flag,
    input logic [address_num-1:0] adrs_in1, adrs_in2,
    output logic wr_ctrl_g , r_ctrl_g, wr_ctrl_r,r_ctrl_n, wr_ctrl_n , r_ctrl_r,neightor_out_flag , 
    output logic [data_width-1:0] neighbour_out [reg_num-1:0],
    output logic [data_width-1:0] out [weight_size-1:0] 
);


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

   
 always_comb
   begin
     case(current_state)
      
       idle: 
		    begin 
              wr_ctrl_n = 0;
              r_ctrl_n = 0;  
              wr_ctrl_r = 0;
              r_ctrl_r = 0;
              wr_ctrl_g = 0;
              r_ctrl_g = 0;
              neightor_out_flag = 0;
              next_state = start? write_g : idle;
		    end 
       write_g: 
		    begin
              wr_ctrl_n = neightor_in_flag;
              r_ctrl_n  = 0;
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              wr_ctrl_g = 1;
              r_ctrl_g  = 0;
              neightor_out_flag = 0;
              next_state = (adrs_in1==3'd4)? read_g : write_g;
			  end 
       read_g:
		begin 
              wr_ctrl_n = 0;
              r_ctrl_n  = 1;
              wr_ctrl_r = 0;
              r_ctrl_r  = 1;
              wr_ctrl_g = 0;
              r_ctrl_g  = 1;
              neightor_out_flag = 1;
              next_state = write_r;
              if(round==1) 
               begin
                assign neighbour_out = {out_n[1:3],out_g[0],out_n[5:7],out_g[2],out_n[9:11],out_g[3],out_n[13:15],out_g[4],out_n[17:19],out_g[5]};
                assign out = {out_n[0:3],out_g[0],out_n[4:7],out_g[1],out_n[8:11],out_g[2],out_n[12:15],out_g[3],out_n[16:19],out_g[4]};
                
               end
              else 
               begin 
                assign neighbour_out = {out_n[17:19],out_g[4]};
                assign out = {out_r,out_n[16:19],out_g[4]};
               end
          end 
       write_r:
			begin 
             wr_ctrl_n = 0;
              r_ctrl_n = 0;
              wr_ctrl_r = 1;
              r_ctrl_r = 0;
              wr_ctrl_g =0 ;
              r_ctrl_g = 1;
              neightor_out_flag =0;
              next_state = write_g;
              if(round==1)
                assign in_r = {out_n[4:7],out_g[1],out_n[8:11],out_g[2],out_n[12:15],out_g[3],out_n[16:19],out_g[4]};
              else
                assign in_r = {out_r[5:19], out_n[16:19],out_g[4]};
	end 
      endcase 
   end
endmodule
