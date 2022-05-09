module PIPO #(
  parameter data_width = 16,
            reg_num    = 20
) (
  input logic clk, nrst, wr_ctrl, r_ctrl,
  input logic [data_width-1:0] in [reg_num-1:0],
  output logic [data_width-1:0] out [reg_num-1:0]
);
  logic [data_width-1:0] registers [reg_num-1:0];

  always_ff @(negedge clk, negedge nrst)
    begin
      if (!nrst)
        begin
          for (int i = 0; i < reg_num; i = i + 1)
            registers[i] <= 16'h0;              // clear registers
          end
      else 
        begin
        registers <= (wr_ctrl ) ? in : registers;
        out <= (r_ctrl ) ? registers : out;
        end
    end
endmodule