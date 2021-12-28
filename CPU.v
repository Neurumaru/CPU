module CPU(
			CLOCK_50, KEY, SW, 
			HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, LEDG,
			LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON, LCD_DATA);
	input CLOCK_50;
	input [3:0] KEY;
	input [17:0] SW;
	output [6:0] HEX7;
	output [6:0] HEX6;
	output [6:0] HEX5;
	output [6:0] HEX4;
	output [6:0] HEX3;
	output [6:0] HEX2;
	output [6:0] HEX1;
	output [6:0] HEX0;
	output [17:0] LEDR;
	output [8:0] LEDG;
	output LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON;
	output [7:0] LCD_DATA;

	wire clk;					//CLK_50		external clock
	wire mode;					//SW[17] 	0: io-mode, 1: execute-mode
	wire input_mode;			//SW[16]		0: op-code, operand, 1: operand
	wire [15:0] command;		//SW[15:0] 	32-bit instruction 
									//				(8bit op-code / 8bit operand or 16bit operand)
	wire reset;					//KEY[3]		reset
	wire up;						//KEY[2]		up key
	wire down;					//KEY[1]		down key
	wire insert;				//KEY[0]		insert instruction
	
	wire [15:0] address;
	wire [15:0] data;
	wire wren;
	wire [15:0] q;
	
	wire [15:0] address_IO;
	wire [15:0] data_IO;
	wire wren_IO;
	
	wire [15:0] address_core;
	wire [15:0] data_core;
	wire wren_core;
	
	wire [6:0] HEX7_IO;
	wire [6:0] HEX6_IO;
	wire [6:0] HEX5_IO;
	wire [6:0] HEX4_IO;
	wire [6:0] HEX3_IO;
	wire [6:0] HEX2_IO;
	wire [6:0] HEX1_IO;
	wire [6:0] HEX0_IO;
	wire [17:0] LEDR_IO;
	
	wire [6:0] HEX7_core;
	wire [6:0] HEX6_core;
	wire [6:0] HEX5_core;
	wire [6:0] HEX4_core;
	wire [6:0] HEX3_core;
	wire [6:0] HEX2_core;
	wire [6:0] HEX1_core;
	wire [6:0] HEX0_core;
	wire [17:0] LEDR_core;
	
	assign clk = CLOCK_50;
	assign mode = SW[17];
	assign input_mode = SW[16];
	assign command = SW[15:0];
	
	assign reset = ~KEY[3];
	button_pulse k2 (clk, reset, ~KEY[2], up);
	button_pulse k1 (clk, reset, ~KEY[1], down);
	button_pulse k0 (clk, reset, ~KEY[0], insert);
	
	assign address = mode ? address_core : address_IO;
	assign data = mode ? data_core : data_IO;
	assign wren = mode ? wren_core : wren_IO;
	
	assign HEX7 = mode ? HEX7_core : HEX7_IO;
	assign HEX6 = mode ? HEX6_core : HEX6_IO;
	assign HEX5 = mode ? HEX5_core : HEX5_IO;
	assign HEX4 = mode ? HEX4_core : HEX4_IO;
	assign HEX3 = mode ? HEX3_core : HEX3_IO;
	assign HEX2 = mode ? HEX2_core : HEX2_IO;
	assign HEX1 = mode ? HEX1_core : HEX1_IO;
	assign HEX0 = mode ? HEX0_core : HEX0_IO;
	assign LEDR = mode ? LEDR_core : LEDR_IO;
	
	ram u1	(address, clk, data, wren, q);
	IO	u2		(clk, reset, mode, input_mode, command, up, down, insert,
				 address_IO, data_IO, wren_IO, q,
				 HEX7_IO, HEX6_IO, HEX5_IO, HEX4_IO, HEX3_IO, HEX2_IO, HEX1_IO, HEX0_IO, LEDR_IO,
				 LCD_RS, LCD_RW, LCD_EN, LCD_ON, LCD_BLON, LCD_DATA);
	core u3	(clk, reset, mode, address_core, data_core, wren_core, q,
				 HEX7_core, HEX6_core, HEX5_core, HEX4_core, HEX3_core, HEX2_core, HEX1_core, HEX0_core, LEDR_core, LEDG);
endmodule
