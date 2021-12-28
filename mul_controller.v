module mul_controller (clk, reset, start, m0, signed_mul, load, shift, addshift, sub, ready);
	parameter N=4, M=2;
	input clk, reset, start, m0, signed_mul;
	output load, shift, addshift, sub, ready;
	
	reg state;
	reg [M-1:0] count;
	localparam S0 = 0, S1 = 1;
	
	always @ (posedge clk or posedge reset) begin
		if(reset) begin state <= S0; count <= 0; end
		else
			case (state)
				S0: if(start) begin state <= S1; count <= N-1; end
				S1: if(count==0) state <= S0; else count <= count-1;
			endcase
	end
	
	assign load = (state==S0) && start;
	assign shift = (state==S1) && ~m0;
	assign addshift = (state==S1) && m0;
	assign sub = (state==S1) && (count==0) && (signed_mul==1);
	assign ready = (state==S0) && ~reset;
endmodule
