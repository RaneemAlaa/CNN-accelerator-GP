module conv_ctrl #(
    parameter col = 32
  )(
    input  logic clk, nrst, conv_ctrl,
    input  logic [4:0] weight_dim,
    output logic conv_finish, w_ps, 
    output logic [col-1:0] out_en
  );

  enum logic [1:0] {  loading_weight = 2'b01,
                      loading_PS     = 2'b11 } current_state,next_state;

  logic[4:0] current_count, next_count;
  logic first_out; 

  always_ff @(posedge clk, negedge nrst) 
	begin
		if(!nrst)
    begin
      current_state <= loading_weight;
      current_count <= 4'b0;
    end
		else
    begin
      current_state <= next_state;
      current_count <= next_count;
    end 
	end


  always_comb
	begin 
	  next_count = current_count;
	  next_state = current_state;

	  unique case(current_state) 
			loading_weight: 
      begin
        next_state  = (conv_ctrl)? loading_PS : loading_weight;
        w_ps        = 1;
        conv_finish = 0;
        first_out   = 0;
      end

      loading_PS:
      begin
        w_ps = 0;
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