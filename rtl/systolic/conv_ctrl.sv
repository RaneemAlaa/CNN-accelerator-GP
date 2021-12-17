module conv_ctrl #(
    parameter col = 32
  )(
    input  logic clk, nrst,conv_ctrl, 
    input  logic [4:0] weight_dim,
    output logic conv_finish,
    output logic [col-1:0] w_ps, out_en
  );

  enum logic [1:0] {  loading_weight = 2'b01,
                      loading_PS     = 2'b11 } current_state,next_state;

  logic[4:0] current_count, next_count, conv_clks;

  always_comb
  begin
    unique case (weight_dim)
      5'd25: conv_clks = 5'd28;
      5'd16: conv_clks = 5'd29;
      5'd9 : conv_clks = 5'd30;
      5'd4 : conv_clks = 5'd31;
    endcase
  end

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
        w_ps [31:0] = '1;
        conv_finish = 0;
      end

      loading_PS:
      begin
        w_ps [31:0] = '0;
			  next_state  = loading_PS ;
        next_count  = current_count + 1;
        conv_finish = (next_count == conv_clks)? 1:0;
      end   				
		  endcase
	end
endmodule