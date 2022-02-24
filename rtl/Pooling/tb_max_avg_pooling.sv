module test_max_avg_pooling#(
     parameter data_width = 8)();

    logic [data_width-1:0] in1, in2 ; 
    logic en ; 
    logic [data_width-1:0] out ; 
 
  max_avg_pooling dut_max_avg_pooling(.in1(in1),.in2(in2),.en(en),.out(out));   

    initial begin
        integer i ; 
      for (i = 0 ; i < 20  ; i = i + 1  ) begin
            in1 = $random ; 
            in2 = $random ; 
            en =$urandom_range(0,1); 
          #10;
       end

    end 

    initial begin
 $monitor("time %0t  in1 %d  in2 %d  en %d  out %d",$time,in1 , in2 , en , out );
    end
endmodule 
