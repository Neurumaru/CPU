module mul(clk, reset, start, signed_mul, word1, word2, product, ready);
	parameter N=4, M=2; 
	input clk, reset, start, signed_mul;
	input [N-1:0] word1, word2;
	output [2*N-1:0] product;
	output ready;
	
	wire m0, load, shift, addshift, sub;
	
	mul_datapath #(N) u1 (clk, reset, load, shift, addshift, sub, signed_mul, word1, word2, product, m0);
	mul_controller #(N, M) u2 (clk, reset, start, m0, signed_mul, load, shift, addshift, sub, ready);
endmodule
