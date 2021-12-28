module button_pulse(clk, reset, button_in, button_out);
	input clk, reset;
	input button_in;
	output button_out;
	
	reg D0, D1;
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin D0 <= 0; D1 <= 0; end
		else begin D0 <= button_in; D1 <= D0; end
	end
	assign button_out = ~D0 & D1;
endmodule
