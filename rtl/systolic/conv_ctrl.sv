module conv_ctrl #(
    parameter col = 32 , row = 32
  )(
    input  logic clk, nrst, conv_ctrl,
    input  logic [4:0] weight_dim,
    output logic conv_finish, w_ps, 
    output logic  out_en[col-1:0],
    output logic input_en [row-1:0]
  );

  enum logic [1:0] {  loading_weight = 2'b01,
                      loading_PS     = 2'b11 } current_state,next_state;

  logic[4:0] current_count, next_count;
  logic[4:0] current_i,next_i; //!number of PEs
  logic[5:0] next_clock_counter,current_clock_counter;//! signal detrmine when we will disenable the the systolic to take input 
  logic first_out; 

  always_ff @(posedge clk, negedge nrst) 
	begin
		if(!nrst)
    begin
      current_state <= loading_weight;
      current_count <= 4'b0;
      current_i<='0;
      current_clock_counter<='0;
    end
		else
    begin
      current_state <= next_state;
      current_count <= next_count;
      current_i<=next_i;
      current_clock_counter<=next_clock_counter;
    end 
	end


  always_comb
	begin 
	  next_count = current_count;
	  next_state = current_state;
    next_i=current_i;
    next_clock_counter=current_clock_counter;

	  unique case(current_state) 
			loading_weight: 
      begin
        next_state  = (conv_ctrl)? loading_PS : loading_weight;
        w_ps        = 1;
        conv_finish = 0;
        first_out   = 0;
	input_en = '{default:1};
      end

      loading_PS:
      begin
        w_ps = 0;
         next_clock_counter=next_clock_counter+1;
         if (next_clock_counter > 28 && next_clock_counter <55)
          begin 
		input_en [next_i] = 0;
 		next_i=current_i+1;
          end   
        if ( (next_count < weight_dim) && !first_out ) begin
          next_state  = loading_PS ;
          next_count  = current_count + 1;
        end 
        else
        begin
          conv_finish = 1;
          next_state  = loading_PS ;
          first_out   = 1;
        end
      end
      default:
      begin
        w_ps        = 1;
        conv_finish = 0;
        first_out   = 0;        				
      end
    endcase
	end
endmodule
