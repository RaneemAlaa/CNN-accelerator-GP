module conv_ctrl #(
    parameter col = 32 , row = 25
  )(
    input  logic clk, nrst, conv_ctrl,
    input  logic [4:0] weight_dim,
    input  logic [5:0] num_filter,
    output logic conv_finish, w_ps, 
    output logic [row-1:0] input_en,
    output logic  out_en[col-1:0]  // enable to pooling_units
  );

  enum logic [1:0] {  loading_weight = 2'b01,
                      loading_PS     = 2'b11 } current_state,next_state;

  logic[5:0] current_count, next_count;
  logic[4:0] current_i,next_i; //!number of PEs
  logic[4:0] current_index,next_index; //indux for output_enable
  logic[9:0] next_clock_counter,current_clock_counter;//! signal detrmine when we will disenable the the systolic to take input 
  logic first_out; 

  always_ff @(posedge clk, negedge nrst) 
  begin
    if(!nrst)
    begin
      current_state <= loading_weight;
      current_count <= 4'b0;
      current_i<='0;
      current_index<='0;
      current_clock_counter<='0;
    end
    else
    begin
      current_state <= next_state;
      current_count <= next_count;
      current_i<=next_i;
      current_index<=next_index;
      current_clock_counter<=next_clock_counter;
    end 
  end


  always_comb
  begin 
    next_count = current_count;
    next_state = current_state;
    next_i=current_i;
    next_clock_counter=current_clock_counter;
    next_index = current_index;

    case(current_state) 
      loading_weight: 
      begin
        if (conv_ctrl) 
        begin
          out_en = '{default:'0};
          input_en = 32'hFFFFFFFF;  
          next_state  = loading_PS ;
        end
        else
        begin
          next_state = loading_weight;
           input_en = 32'h00000000;
        end
        //next_state  = (conv_ctrl)? loading_PS : loading_weight;
        w_ps        = 1;
        conv_finish = 0;
        first_out   = 0;
       
      end

      loading_PS:
      begin
        w_ps = 0;
        next_clock_counter = next_clock_counter+1;
   if (next_clock_counter > 784 && next_clock_counter <810)
          begin 
            input_en [next_i] = 0;
            next_i=current_i+1;
          end   
        if ( (next_count < row-1) && !first_out ) begin  // conv_finish and out_enable be 1 before first output exist to start pooling_units in next clock cycle
          next_state  = loading_PS ;
          next_count  = current_count + 1;
          conv_finish = 0;
          first_out   = 0;
        end 
        else
        begin
          if (current_index < num_filter) begin
            out_en[current_index] = 1;
            next_index = current_index +1; 
          end
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
        input_en    = 32'b0;              
      end
    endcase
  end
endmodule