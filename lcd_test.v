module lcd_test(clk, reset, start, RS, data, done, line1, length1, line2, length2);
	input clk;
	input reset;
	output start, RS;
	output [7:0] data;
	input done;
	input [16*16-1:0] line1;
	input [3:0] length1;
	input [16*16-1:0] line2;
	input [3:0] length2;
	
	reg [3:0] index;
	reg [3:0] dindex;
	reg [7:0] data;
	reg [1:0] state;
	reg [1:0] delay;
	reg [17:0] count;
	reg RS, halt;
	wire start;
	wire idle;
	
	localparam INIT = 0;
	localparam LINE1 = INIT + 4;
	localparam LINE2 = LINE1 + 2;
	localparam LAST = LINE1 + 2;
	localparam S0=0, S1=1, S2=2, S3=3;
	
	localparam DELAY0 = 400000/20,
				  DELAY1 = 4100000/20;
//	localparam DELAY0 = 40/20,
//				  DELAY1 = 120/20;

	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			state <= S0;
			count <= 0;
			index <= INIT;
			dindex <= 0;
		end
		else begin
			case(state)
				S0: if(!halt) state <= S1;
				S1: state <= S2;
				S2: if(done) begin
						state <= S3;
						if(index==LINE1)
							dindex <= length1 - 1;
						else if(index==LINE2)
							dindex <= length2 - 1;
							
						if(dindex == 0) index <= index + 1;
						else dindex <= dindex - 1;
						
						if(delay) count <= DELAY1;
						else count <= DELAY0;
					end
				S3: if(count==0) state <= S0;
					 else count <= count -1;
				default: state <= 0;
			endcase
		end
	end
	
	assign start = (state==S1);
	
	always @* begin
		data = " ";
		halt = 0;
		delay = 0;
		RS = 1;
		case (index)
			INIT:		begin data=8'b0011_1100; RS=0; delay=1; end
			INIT+1:	begin data=8'b0000_1100; RS=0; delay=1; end
			INIT+2:	begin data=8'b0000_0110; RS=0; delay=1; end
			INIT+3:	begin data=8'b0000_0001; RS=0; delay=1; end
			LINE1:	begin data=8'b1000_0000; RS=0; end
			LINE1+1:	data = line1[8*dindex +: 8];
			LINE2:	begin data=8'b1100_0000; RS=0; end
			LINE2+1:	data = line2[8*dindex +: 8];
			LAST: 	halt = 1;
			default: halt = 1;
		endcase
	end
endmodule

		