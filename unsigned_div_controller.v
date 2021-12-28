module unsigned_div_controller (clk, reset, start, lt, load, shift, subshift, ready);
	parameter N=8, M=4, L=3;
	input clk, reset, start, lt;
	output load, shift, subshift, ready;
	
	reg state;
	reg [L-1:0] count;
	localparam S0 = 0, S1 = 1;
	
	assign load = (state == S0) & start;
	assign shift = (state == S1) & lt;
	assign subshift = (state == S1) & ~lt;
	assign ready = (state == S0) & ~reset;
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin state <= S0; count <= 0; end
		else begin
			case(state)
				S0: if(start) begin state <= S1; count <= N - 1; end
				S1: if(count==0) state <= S0;
					 else count <= count - 1;
			endcase
		end
	end
endmodule
