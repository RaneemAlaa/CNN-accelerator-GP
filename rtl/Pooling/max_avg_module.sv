module max_avg_pooling
  #(
     parameter data_width = 8
   )
   (
     input logic [data_width-1:0] in1, in2,
     input logic en,
     output logic [data_width-1:0] out
   );

  logic [data_width-1:0] max1,avg_out;

  always_comb
  begin
    avg_out = '0;
    if (en) // max pooling
    begin
      if (in1 > in2)
        max1 = in1;
      else
        max1 = in2;

 
    end
    else  // avg pooling
    begin
      avg_out = (in1 + in2 ) >> 1;
    end
  end

  assign out = (en) ? (max1) : avg_out;

endmodule