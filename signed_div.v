module signed_div(clk, reset, start, word1, word2, quotient, remainder, ready);
	parameter N=8, M=4, L=3;
	input clk, reset, start;
	input [N-1:0] word1;
	input [M-1:0] word2;
	output [N-1:0] quotient;
	output [M-1:0] remainder;
	output ready;
	
	wire load, shift, subshift, lt;
	
	signed_div_datapath #(N, M) u1 (clk, reset, load, shift, subshift, word1, word2, quotient, remainder, lt);
	signed_div_controller #(N, M, L) u2 (clk, reset, start, lt, load, shift, subshift, ready);
endmodule
