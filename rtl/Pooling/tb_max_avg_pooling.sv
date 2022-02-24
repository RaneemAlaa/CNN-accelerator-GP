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


// random output 
/* 
# time 0  in1  36  in2 129  en 0  out  82
# time 10  in1   9  in2  99  en 0  out  54
# time 20  in1  13  in2 141  en 0  out  77
# time 30  in1 101  in2  18  en 0  out  59
# time 40  in1   1  in2  13  en 0  out   7
# time 50  in1 118  in2  61  en 0  out  89
# time 60  in1 237  in2 140  en 0  out  60
# time 70  in1 249  in2 198  en 0  out  95
# time 80  in1 197  in2 170  en 1  out 197
# time 90  in1 229  in2 119  en 0  out  46
# time 100  in1  18  in2 143  en 0  out  80
# time 110  in1 242  in2 206  en 0  out  96
# time 120  in1 232  in2 197  en 1  out 232
# time 130  in1  92  in2 189  en 0  out  12
# time 140  in1  45  in2 101  en 1  out 101
# time 150  in1  99  in2  10  en 0  out  54
# time 160  in1 128  in2  32  en 0  out  80
# time 170  in1 170  in2 157  en 1  out 170
# time 180  in1 150  in2  19  en 1  out 150
# time 190  in1  13  in2  83  en 1  out  83
*/ 
