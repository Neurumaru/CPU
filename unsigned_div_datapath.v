module unsigned_div_datapath(clk, reset, load, shift, subshift, word1, word2, quotient, remainder, lt);
	parameter N=8, M=4;
	input clk, reset, load, shift, subshift;
	input [N-1:0] word1;
	input [M-1:0] word2;
	output [N-1:0] quotient;
	output [M-1:0] remainder;
	output lt;
	
	reg [N+M-1:0] dividend;
	reg [M-1:0] divisor;
	wire [M:0] diff;
	
	assign diff = dividend[N+M-1:N-1] - divisor;
	assign lt = dividend[N+M-1:N-1] < divisor;
	
	assign quotient = dividend[N-1:0];
	assign remainder = dividend[N+M-1:N];
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin dividend <= 0; divisor <= 0; end
		else if(load) begin dividend <= word1; divisor <= word2; end
		else if(shift)
			dividend = {dividend[N+M-1:0], 1'b0};
		else if(subshift)
			dividend = {diff[M-1:0], dividend[N-2:0], 1'b1};
	end
endmodule
