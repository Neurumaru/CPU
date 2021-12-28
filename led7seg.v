module led7seg(enable, bcd, disp);
	input enable;
	input [3:0] bcd;
	output [6:0] disp;
	reg [6:0] display;
	
	assign disp = ~display;
	
	always @(*) begin
		if(enable) 
			case(bcd)
				0: 	display=7'b011_1111;
				1: 	display=7'b000_0110;
				2: 	display=7'b101_1011;
				3: 	display=7'b100_1111;
				4: 	display=7'b110_0110;
				5: 	display=7'b110_1101;
				6: 	display=7'b111_1101;
				7: 	display=7'b000_0111;
				8: 	display=7'b111_1111;
				9: 	display=7'b110_1111;
				10: 	display=7'b111_0111;
				11: 	display=7'b111_1100;
				12: 	display=7'b011_1001;
				13: 	display=7'b101_1110;
				14: 	display=7'b111_1001;
				15: 	display=7'b111_0001;
				default: display=7'b000_0000;
			endcase
		else
			display=7'b000_0000;
	end
endmodule
