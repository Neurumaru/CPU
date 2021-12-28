module lcd_controller(clk, reset, start, RS, data, done,
								LCD_RS, LCD_RW, LCD_E, LCD_data);
	input clk;
	input reset, start;
	input RS;
	input [7:0] data;
	output done;
	output LCD_RS, LCD_RW, LCD_E;
	output [7:0] LCD_data;
	
	reg [2:0] state;
	reg [3:0] count;
	localparam S0=0, S1=1, S2=2, S3=4, S4=3;
	localparam WIDTH_E = 12;
	
	assign LCD_RS = RS;
	assign LCD_RW = 1'b0;
	assign LCD_data = data;
	
	always @(posedge clk or posedge reset) begin
		if(reset) begin state <= S0; count <= 0; end
		else
			case (state)
				S0: if(start) state <= S1;
				S1: state <= S2;
				S2: begin state <= S3; count = WIDTH_E - 1; end
			   S3: if (count==0) state <= S4;
					 else count <= count - 1;
				S4: state <= S0;
				default: state <= S0;
			endcase
	end
	
	assign LCD_E = (state==S3);
	assign done = (state==S4);
endmodule
