module ascii_decoder_hex(in, out);
	input [3:0] in;
	output [7:0] out;
	
	assign out = in < 10 ? {4'b0011, in} : {4'b0100, in} - 9;
endmodule
