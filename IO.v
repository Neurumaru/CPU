module IO(
			clk, reset, mode, input_mode, command, up, down, insert,
			address, data, wren, q,
			HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR,
			LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON, LCD_DATA);
	input clk, reset, mode, input_mode;
	input [15:0] command;
	input up, down, insert;
	
	output reg [15:0] address;
	output reg [15:0] data;
	output reg wren;
	input [15:0] q;
	
	output [6:0] HEX7;
	output [6:0] HEX6;
	output [6:0] HEX5;
	output [6:0] HEX4;
	output [6:0] HEX3;
	output [6:0] HEX2;
	output [6:0] HEX1;
	output [6:0] HEX0;
	output [17:0] LEDR;
	
	output LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON;
	output [7:0] LCD_DATA;
	
	assign LEDR[15:0] = pointer[15:0];
	//////////////////////////////////////////////////
	reg [15:0] pointer;
	//////////////////////////////////////////////////
	reg [3:0] state;
	localparam 	IDLE=0, 
					R0=1, R1=2, R2=3, R3=4, R4=5, R5=6,
					W0=7, W1=8;
					
	always @(posedge clk or posedge reset) begin
		if(reset) 	state <= R0; 
		else if(~mode) begin
			case(state)
				IDLE:	if(down & (pointer < 16'hFFFF - 2))
							state <= R0;
						else if(up & (pointer > 0))
							state <= R0;
						else if(insert)
							state <= W0;
				R0:	state <= R1;
				R1:	state <= R2;
				R2:	state <= R3;
				R3:	state <= R4;
				R4:	state <= R5;
				R5:	state <= IDLE;
				W0:	state <= W1;
				W1:	state <= R0;
				default:	state <= IDLE;
			endcase
		end
	end
	//////////////////////////////////////////////////
	always @(posedge clk or posedge reset) begin
		if(reset) begin 
			pointer <= mode ? pointer : 0; 
			address <= 0; 
			instruction1 <= 0;
			instruction2 <= 0;
			wren <= 0;
			reset_lcd <= 0;
		end
		else if (~mode) begin
			case(state)
				IDLE:	if(down & (pointer < 16'hFFFF - 2)) pointer <= pointer + 2;
						else if(up & (pointer > 0)) pointer <= pointer - 2;
						else reset_lcd <= 0;
				R0: begin address <= pointer; wren <= 0; end
				R1: begin address <= pointer + 1; end
				R2: begin address <= pointer + 2; instruction1[31:16] <= q; end
				R3: begin address <= pointer + 3; instruction1[15:0] <= q; end
				R4: begin instruction2[31:16] <= q; end
				R5: begin instruction2[15:0] <= q; reset_lcd <= 1; end
				W0: begin address <= pointer; data <= instruction[31:16]; wren <= 1; end
				W1: begin address <= pointer + 1; data <= instruction[15:0]; end
			endcase
		end
	end	
	//////////////////////////////////////////////////
	reg [31:0] instruction1;
	reg [31:0] instruction2;
	wire [16*8-1:0] line1;
	wire [16*8-1:0] line2;
	wire [3:0] length1;
	wire [3:0] length2;
	
	lcd_decoder l1 (instruction1, line1, length1);
	lcd_decoder l2 (instruction2, line2, length2);
	//////////////////////////////////////////////////
	reg reset_lcd;
	wire start, RS, done;
	wire [7:0] lcd_data;
		
	lcd_test 		lcd1	(clk, reset_lcd, start, RS, lcd_data, done,
								line1, length1, line2, length2);
	lcd_controller lcd2 (clk, reset, start, RS, lcd_data, done,
								LCD_RS, LCD_RW, LCD_EN, LCD_DATA);
	
	assign LCD_ON = 1'b1;
	assign LCD_BLON = 1'b1;
	//////////////////////////////////////////////////
	reg [31:0] instruction;
	
	always @(*) begin
		if(input_mode)	instruction[15:0] = command;
		else				instruction[31:16] = command;
	end
	
	led7seg led7 (~reset, instruction[31:28], HEX7);
	led7seg led6 (~reset, instruction[27:24], HEX6);
	led7seg led5 (~reset, instruction[23:20], HEX5);
	led7seg led4 (~reset, instruction[19:16], HEX4);
	led7seg led3 (~reset, instruction[15:12], HEX3);
	led7seg led2 (~reset, instruction[11:8], HEX2);
	led7seg led1 (~reset, instruction[7:4], HEX1);
	led7seg led0 (~reset, instruction[3:0], HEX0);
	//////////////////////////////////////////////////
endmodule
