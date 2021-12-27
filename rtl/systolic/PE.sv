module pe#(parameter width = 8) (input clk,rst_n,ctrl,
	input [width-1:0]PE_in, feature_in,
	output logic [width-1:0]PE_out,feature_out);
logic [width-1:0]weight,tmp;
logic [width*2-1:0]mul_out; 
always_ff @(posedge clk or negedge rst_n) begin : proc_
	if(~rst_n) begin
		 PE_out <= 0;
		 feature_out <= 0;
		 weight <= 0;
	end 
	else if (ctrl) begin
		 PE_out <= PE_in ;
		 weight <= PE_in;
		 feature_out <= 0;
	end
	else begin
		feature_out <= feature_in;
		PE_out <= PE_in + tmp; 
	end
end
always_comb begin 
	mul_out = weight * feature_in;
	tmp = mul_out [width-1:0];	//quantization
end
endmodule
