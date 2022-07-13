module PUs_control#(
    parameter data_width  = 16,
    parameter reg_num = 20 ,
    parameter address_num = 5,
    parameter weight_size = 25 
  )(input logic [data_width-1:0] out_g [4:0],
   output logic [data_width-1:0] in_r [reg_num-1:0],// the error here that it was an input
    input logic [data_width-1:0] out_r [reg_num-1:0],
    input logic [data_width-1:0] out_n [reg_num-1:0],
    input logic clk,nrst,start,neighbour_in_flag,wr_ctrl_g ,act,
    input logic [5:0] round,PU_No,
    input logic [address_num-1:0] adrs_in1, adrs_in2,
    output logic  r_ctrl_g, wr_ctrl_r,r_ctrl_n, wr_ctrl_n , r_ctrl_r, neighbour_out_flag,t_flag, 
    output logic [data_width-1:0] neighbour_out [reg_num-1:0],
    output logic [data_width-1:0] out [weight_size-1:0] 
);
logic [15:0] neighbour_out_zeros,c,PU_No_m ; 

enum logic [2:0]  {idle=3'b000,
             write_g=3'b001,
             read_g=3'b010,
             write_r=3'b011,
             prepare_n=3'b100,
	     prepare_r=3'b111,
	     prepare_g=3'b101,
	     finish_r=3'b110	 } states ;

logic[2:0] current_state , next_state ; 

always_ff@(posedge clk , negedge nrst)
begin     
      if(!nrst)
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
              r_ctrl_g = 0;
             t_flag = 0;
		 neighbour_out_flag= 0;
              next_state = start?  write_g: idle;
		    end 
     
	write_g: 
		    begin
              wr_ctrl_n = 1;
              r_ctrl_n  = 0;
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              r_ctrl_g  = 0;
               neighbour_out_flag = 0;
              next_state = ((adrs_in1==4)&&wr_ctrl_g)?  read_g : write_g;
		if (next_state==read_g)
			t_flag=1;
			  end

	read_g:
		begin 
              PU_No_m=PU_No;      
              wr_ctrl_n = 1;
              r_ctrl_n  = 1;
              wr_ctrl_r = 0;
              r_ctrl_r  = 0;
              r_ctrl_g  = 1;
              neighbour_out_flag = 1;
              next_state =  prepare_r;
		t_flag=0;
 
		 
		//out_n={out_n[19:17],0,out_n[15:13],0,out_n[11:9],out_g[2],out_n[7:5],out_g[3],out_n[3:1],out_g[4]}
               if(round == 0||((round==1)&&(PU_No==0)))  
                 begin
		 out = {out_g[4],out_n[3:0],out_g[3],out_n[7:4],out_g[2],out_n[11:8],out_g[1],out_n[15:12],out_g[0],out_n[19:16]};
          neighbour_out = {out_g[0],out_n[19:17],out_g[1],out_n[15:13],out_g[2],out_n[11:9],out_g[3],out_n[7:5],out_g[4],out_n[3:1]};
		end
//  if(PU_No_m == 1)
		
		//else if(PU_No_m == 2)
		//  assign neighbour_out = {out_n[19:18],out_n[16],out_g[0],out_n[15:14],out_n[12],out_g[1],out_n[11:10],out_n[8],out_g[2],out_n[7:6],out_n[4],out_g[3],out_n[3:2],out_n[0],out_g[4]};
		//else if(PU_No_m == 3)
		//  assign neighbour_out = {out_n[19],out_n[17:16],out_g[0],out_n[15],out_n[13:12],out_g[1],out_n[11],out_n[9:8],out_g[2],out_n[7],out_n[5:4],out_g[3],out_n[3],out_n[1:0],out_g[4]};
		//else 
             //assign neighbour_out = {out_n[18:16],out_g[0],out_n[14:12],out_g[1],out_n[10:8],out_g[2],out_n[6:4],out_g[3],out_n[2:0],out_g[4]};
               //end
              else 
		begin
		 out = {out_g[4],out_n[19:16],out_r};
               //if(PU_No_m == 1)  
		//assign neighbour_out_zeros= '{default:16'h0000} ; {16{1'b0}}
                 neighbour_out = {out_g[4],out_n[19:17], 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0  }; 
               // else if(PU_No_m == 2) 
		//assign neighbour_out = {out_n[19:18],out_n[16],out_g[4], 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0  }; 
		//else if(PU_No_m == 3) 
		//assign neighbour_out = {out_n[19],out_n[17:16],out_g[4], 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0  }; 	
		//else 
		//assign neighbour_out = {out_n[18:16],out_g[4], 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0  }; 





//assign out = {out_r[19:16],out_g[4],out_r[15:12],out_g[3],out_n[11:8],out_g[2],out_n[15:12],out_g[1],out_n[19:16],out_g[0]};
               end
          end 

	prepare_r:
	 

	begin
  wr_ctrl_n = 1;
   r_ctrl_n = 1;
    r_ctrl_g = 0;
	t_flag=0;
    next_state = write_r; 
    end
       write_r:
			begin 
             wr_ctrl_n = 1;
              r_ctrl_n = 1;
              wr_ctrl_r =0;
              r_ctrl_r =1;
              r_ctrl_g = 0;
		t_flag=0;
               neighbour_out_flag=0;
              next_state = prepare_n;
              if(round==0||((round==1)&&(PU_No==0)))
           in_r = {out_g[4],out_n[3:0],out_g[3],out_n[7:4],out_g[2],out_n[11:8],out_g[1],out_n[15:12]};
           
	    else //if(round==1)
               in_r = {out_g[4],out_n[19:16],out_g[3],out_r[18:15],out_g[2],out_r[13:10],out_g[1],out_r[8:5]};             
	 
	   //else if(round==2)
           //    assign in_r = {out_r[19:16],out_r[15:12],out_r[11:8],out_r[3:0],out_n[19:16]};
	
	   //else if(round==3)
           //     assign in_r = {out_r[19:16],out_r[15:12],out_r[7:4],out_r[3:0],out_n[19:16]};
	
	   //else if(round==4)
           //    assign in_r = {out_r[19:16],out_r[11:8],out_r[7:4],out_r[3:0],out_n[19:16]};
	
           //else 
           // assign in_r = {out_r[15:12],out_r[11:8],out_r[7:4],out_r[3:0],out_n[19:16]};
	
end 
prepare_n: begin
	      wr_ctrl_r = 1;
              r_ctrl_r =1;
	      wr_ctrl_n = 1;
	      r_ctrl_n = 1;
 next_state = prepare_g;
end
 prepare_g: begin
	      wr_ctrl_r = 1;
              r_ctrl_r =0;
	    wr_ctrl_n = 1;
	    r_ctrl_n = 1;
 next_state = finish_r;
end
finish_r:begin
             wr_ctrl_r = 1;
              r_ctrl_r =0;
	    wr_ctrl_n = 0;
	    r_ctrl_n = 0;
 next_state = write_g;

end
      endcase 
   end
endmodule
