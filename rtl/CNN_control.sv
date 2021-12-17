module ctrl_cnn(
  input  logic clk, nrst, conv_finish,pu_finish ,pooling_finish, [13:0]op_code_i,
  output logic pu_en,conv_ctrl,pooling_ctrl,
  output logic [31:0] weight_en,
  output logic [5:0] weight_dim
);

  enum logic [2:0] { idle             = 3'b000,
                     conv             = 3'b001,
                     FC               = 3'b011,
		                 conv_pooling     = 3'b010,
	                   conv_pooling_FC  = 3'b110,
		                 out              = 3'b111 } next_state,current_state;

  enum logic [1:0]{ loading_weight_element = 2'b10,
                    loading_weight_filter  = 2'b11,
                    rst                    = 2'b00 }  next_state_2,current_state_2;

  logic [5:0] current_i, next_i, current_N, next_N;				  				  
  logic [6:0] current_count_img, next_count_img;
  logic [4:0] current_count_conv, next_count_conv;	
  
  assign weight_dim = op_code_i[13:9];

  always_ff @(posedge clk or negedge nrst) 
	begin
	  if(!nrst) 
    begin  
      current_state      <= idle;
	    current_count_img  <= 0;
      current_count_conv <= 0;
      current_i          <= 0;
	    current_state_2    <= loading_weight_element;  
      current_i          <= 0;
      current_N          <= 1;
    end
	  else
    begin
      current_state      <= next_state;
      current_count_img  <= next_count_img;
      current_count_conv <= next_count_conv;
      current_i          <= next_i;
	    current_state_2    <= next_state_2;
      current_N          <= next_N ;
      current_i          <= next_i;
    end 
	end				  

  always_comb
	begin
    next_state      = current_state;
	  next_count_img  = current_count_img;
	  next_count_conv = current_count_conv;
    next_state_2    = current_state_2;
    next_i          = current_i;
    next_N          = current_N;

    unique case(current_state) 
			idle:
      begin 
      	pooling_ctrl = 0;
     		pu_en        = 0;
        conv_ctrl    = 0;
        weight_en    ='0;

        unique case(op_code_i[2:0])
		  		3'b000:next_state = idle; 
          3'b001:next_state = conv;
          3'b011:next_state = FC;
          3'b010:next_state = conv_pooling;
          3'b110:next_state = conv_pooling_FC;
          3'b111:next_state = out;	
	      endcase	
      end

		  conv:
		  begin                             //filter buffering
		    pooling_ctrl = 0;
       	if (next_i < op_code_i[8:3]) // to make first buffer for filter on 
       	begin 
				  unique case(current_state_2) 
  				  loading_weight_element:
  					begin 
							next_state         = conv;
  						weight_en [next_i] = 1;
 						  if( next_i != 0)
         			begin 
          			weight_en[next_i-1] = 0; 
         			end

             	next_N       = current_N + 2;               //AXI sends 2 elements per clk 
       				if(next_N < op_code_i[13:9] - 1)         // no of element 
       				begin
                next_state_2 = loading_weight_element;
       				end 
       				else 
							begin
         				next_state_2 = loading_weight_filter;
       				end   
						end

 					  loading_weight_filter:
  					begin
 						  if(next_i < op_code_i[8:3])  // no of filter
   						begin
                weight_en [next_i] = 1;
 						    if(next_i != 0)
         			  begin 
          			  weight_en[next_i-1] = 0; 
         			  end
           			next_i       = current_i + 1;
           			next_N       = 1;
           			next_state_2 = loading_weight_element;
        			end
      			end
          endcase    
     		end 
              //image buffering
			  else 
				begin
			    pu_en          = 1;
          weight_en      = '0;	
          next_state     = conv;
			    next_count_img = current_count_img + 1;	
				  if (next_count_img > 7'd67)
				  begin
            conv_ctrl  = 1;
            pu_en      = (pu_finish)? 0 : 1;
            weight_en  = '0;
				    next_state = conv_finish? out : conv ;
          end
				end
		  end 
     
 
		  FC: 
		  begin 
        next_state = out;
      end

      conv_pooling:
		  begin                             //filter buffering
       	if (next_i < op_code_i[8:3]) // to make first buffer for filter on 
       	begin 
		      pooling_ctrl = 0;
				  unique case(current_state_2) 
  				  loading_weight_element:
  					begin 
							next_state            = conv;
  						weight_en [next_i] = 1;
 						  if(next_i != 0)
         			begin 
          			weight_en[next_i-1] = 0; 
         			end

              next_N       = current_N + 2;               //AXI sends 2 elements per clk 
       				if(next_N < op_code_i[13:9] - 1)         // no of element 
       				begin
                next_state_2 = loading_weight_element;
       				end 
       				else 
							begin
         				next_state_2 = loading_weight_filter;
       				end   
						end

 					  loading_weight_filter:
  					begin
 						  if(next_i < op_code_i[8:3])  // no of filter
   						begin
               	weight_en [next_i] = 1;
 						    if(next_i != 0)
         			  begin 
          			  weight_en[next_i-1] = 0; 
         			  end
           			next_i       = current_i + 1;
           			next_N       = 1;
           			next_state_2 = loading_weight_element;
        			end
      			end
          endcase    
     		end 
                    
            //image buffering
				else                           
				begin
					pu_en          = 1; 
          weight_en      = 0;
          pooling_ctrl   = 0;
          conv_ctrl      = 0;	
		      next_count_img = current_count_img + 1;
          next_state     = conv_pooling;

	        if ( next_count_img > 7'd67 ) 
				  begin
            if (next_count_conv < op_code_i[13:9]) 
            begin
              next_count_conv = current_count_conv+1;
              conv_ctrl       = 1;
              pooling_ctrl    = 0;
              weight_en       = 0;
              pu_en           = 1;
              next_state      = conv_pooling;
            end 
            else 
            begin
              pu_en        = (pu_finish)? 0 : 1;
              pooling_ctrl = 1;
              weight_en    = 0;
              conv_ctrl    = (conv_finish)? 0 : 1;
			        next_state   = (pooling_finish)? out : conv_pooling ;
            end
          end 
				end               
      end

		  out:
      begin 
        next_state = idle;
        pooling_ctrl=0;
        pu_en = 0;
        conv_ctrl=0;
        weight_en ='0;
        next_count_img = 0;
        next_count_conv=0;
        next_i=0;
      end    		  
	  endcase	
  end   
endmodule