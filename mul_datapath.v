module mul_datapath(clk, reset, load, shift, addshift, sub, signed_mul, word1, word2, product, m0);
	parameter N=4;
	input clk, reset, load, shift, addshift, sub, signed_mul;
	input [N-1:0] word1, word2;
	output [2*N-1:0] product;
	output m0;
	
	reg [2*N-1:0] product;
	reg [N-1:0] multiplicand;
	wire [N:0] sum;
	wire [N:0] eproduct, emcand;
	
	assign m0 = product[0];
	
	assign eproduct = {product[2*N-1], product[2*N-1:N]};
	assign emcand = {multiplicand[N-1], multiplicand};
	
	assign sum = signed_mul ? (sub ? (eproduct - emcand) : (eproduct + emcand))
										: product[2*N-1:N] + multiplicand;
	
	always @ (posedge clk or posedge reset) begin
		if(reset) begin multiplicand <= 0; product <= 0; end
		else if(load) begin
			multiplicand <= word1;
			product <= {4'b0, word2};
		end
		else if(shift) begin
			product[2*N-1] <= signed_mul ? product[2*N-1] : 1'b0;
			product[2*N-2:0] <= product[2*N-1:1];
		end
		else if(addshift)
			product <= {sum, product[N-1:1]};
	end
endmodule
