module pe#(parameter width = 8) (input clk,rst_n,ctrl,in_en,
	input [width-1:0]PE_in, feature_in,
	output  out_in,
	output logic [width-1:0]PE_out,feature_out);
logic [width-1:0]weight,tmp,tmp_in;
logic [width*2-1:0]mul_out; 
assign out_in = 1;  // always = 1 to make pe in next column take latest value (feature input when in_en = 1 or 0 when in_en = 0)  
always_ff @(posedge clk or negedge rst_n) begin 
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
		feature_out <= tmp_in;
		PE_out <= PE_in + tmp; 
	end
end
always_comb begin 
	if (in_en) begin
		tmp_in = feature_in;
	end
	else
		tmp_in = 0;
	mul_out = weight * tmp_in;
	tmp = mul_out [width-1:0];	//quantization
end
endmodule
