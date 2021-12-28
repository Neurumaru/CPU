module core(clk, reset, mode, address, data, wren, q,
				HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, LEDR, LEDG);
	input 					clk, reset, mode;
	output reg 	[15:0] 	address;
	output reg 	[15:0]	data;
	output reg 				wren;
	input 		[15:0] 	q;
	
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
	//////////////////////////////////////////////////
	assign LEDR[15:0] = PC[15:0];
	assign LEDG[3:0] = SREG[3:0];
	
	led7seg led7 (~reset, REG[31:28], HEX7);	//r1[15:12] is connected to HEX7
	led7seg led6 (~reset, REG[27:24], HEX6);	//r1[11:8] is connected to HEX6
	led7seg led5 (~reset, REG[23:20], HEX5);	//r1[7:4] is connected to HEX5
	led7seg led4 (~reset, REG[19:16], HEX4);	//r1[3:0] is connected to HEX4
	led7seg led3 (~reset, REG[15:12], HEX3);	//r0[15:12] is connected to HEX3
	led7seg led2 (~reset, REG[11:8], HEX2);	//r0[11:8] is connected to HEX2
	led7seg led1 (~reset, REG[7:4], HEX1);		//r0[7:4] is connected to HEX1
	led7seg led0 (~reset, REG[3:0], HEX0);		//r0[3:0] is connected to HEX0
	//////////////////////////////////////////////////
	reg [3:0] 	state;
	localparam 	IDLE=0,
					FETCH1=1, FETCH2=2, FETCH3=3, FETCH4=4, 
					DECODE=5, 
					EXECUTE1=6, EXECUTE2=7, EXECUTE3=8;
					
	always @(posedge clk or posedge reset) begin
		if(reset) begin state=IDLE; end
		else begin
			case(state)
				IDLE: if(mode) state <= FETCH1;
				FETCH1: state <= FETCH2;
				FETCH2: state <= FETCH3;
				FETCH3: state <= FETCH4;
				FETCH4: state <= DECODE;
				DECODE: state <= EXECUTE1;
				EXECUTE1: begin 
					case(op_code)
						nop_:		state <= IDLE;
						mov_:		state <= IDLE;
						//lod_:		state <= IDLE;
						sto_:		state <= IDLE;
						push_:	state <= IDLE;
						//pop_:		state <= IDLE;
						mul_:		if(mul_ready) state <= EXECUTE2;
						imul_:	if(mul_ready) state <= EXECUTE2;
						div_:		if(unsigned_div_ready) state <= EXECUTE2;
						idiv_:	if(signed_div_ready) state <= EXECUTE2;
						jmp_:		state <= IDLE;
						jz_:		state <= IDLE;
						je_:		state <= IDLE;
						jne_:		state <= IDLE;
						jnz_:		state <= IDLE;
						ja_:		state <= IDLE;
						jb_:		state <= IDLE;
						jbe_:		state <= IDLE;
						jae_:		state <= IDLE;
						jg_:		state <= IDLE;
						jl_:		state <= IDLE;
						jle_:		state <= IDLE;
						jge_:		state <= IDLE;
						js_:		state <= IDLE;
						jns_:		state <= IDLE;
						jc_:		state <= IDLE;
						jnc_:		state <= IDLE;
						jo_:		state <= IDLE;
						jno_:		state <= IDLE;
						default: state <= EXECUTE2;
					endcase
				end
				EXECUTE2: begin 
					case(op_code)
						ret_: 	state <= EXECUTE3;
						default: state <= IDLE;
					endcase
				end
				EXECUTE3: state <= IDLE;
			endcase
		end
	end
	//////////////////////////////////////////////////
	reg [15:0] 			PC;
	reg [31:0] 			IR;
	reg [15:0]			AC;
	reg [16*16-1:0]	REG;
	reg [3:0]			SREG;	//3: Z, 2: C, 1: V, 0: N
	reg [15:0]			SP;
	reg [15:0]			BP;
	
	wire [7:0] 	op_code;
	wire [7:0] 	operand1;
	wire [15:0]	operand2;
	wire [3:0]	reg1;
	wire [3:0]	reg2;
	
	wire Z, C, V, N;
	
	assign op_code = IR[31:24];
	assign operand1 = IR[23:16];
	assign operand2 = IR[15:0];
	assign reg1 = operand1[3:0];
	assign reg2 = operand2[3:0];
	
	assign Z = SREG[3];
	assign C = SREG[2];
	assign V = SREG[1];
	assign N = SREG[0];
	
	wire mul_start;
	wire singed_mul;
	wire [31:0] product;
	wire mul_ready;
	wire unsigned_div_start;
	wire [15:0] u_quotient;
	wire [15:0] u_remainder;
	wire unsigned_div_ready;
	wire singed_div_start;
	wire [15:0] s_quotient;
	wire [15:0] s_remainder;
	wire signed_div_ready;
	
	assign mul_start = (state == DECODE) & (op_code == mul_ || op_code == imul_);
	assign singed_mul = op_code == imul_;
	assign unsigned_div_start = (state == DECODE) & (op_code == div_);
	assign singed_div_start = (state == DECODE) & (op_code == idiv_);
	
	mul #(16, 4) m 					(clk, reset, mul_start, singed_mul, REG[16*reg1 +: 16], REG[16*reg2 +: 16], product, mul_ready);
	unsigned_div #(16, 16, 4) usd	(clk, reset, unsigned_div_start, REG[16*reg1 +: 16], REG[16*reg2 +: 16], u_quotient, u_remainder, unsigned_div_ready);
	signed_div #(16, 16, 4) sd		(clk, reset, singed_div_start, REG[16*reg1 +: 16], REG[16*reg2 +: 16], s_quotient, s_remainder, signed_div_ready);
	
	localparam 	nop_=0,
					mov_=1,		//operand1(reg) <- operand2(reg)
					lod_=2,		//operand1(reg) <- mem[operand2]
					sto_=3,		//operand1(reg) -> mem[operand2]
					push_=4,		//operand1(reg) -> sp, sp = sp - 1
					pop_=5,		//sp = sp + 1, operand1(reg) <- sp
					cmp_=6,		//operand1(reg) - operand2(reg)태 레지스터만 변경
					inc_=7,		//operand1(reg) = operand1(reg) + 1
					dec_=8,		//operand1(reg) = opearnd1(reg) - 1
					neg_=9,		//operand1(reg) = - operand1(reg)
					add_=10,		//operand1(reg) = operand1(reg) + operand2(reg)
					addi_=11,	//operand1(reg) = operand1(reg) + operand2
					sub_=12,		//operand1(reg) = operand1(reg) - operand2(reg)
					subi_=13,	//operand1(reg) = operand1(reg) - operand2
					mul_=14,		//operand1(reg) = operand1(reg) * operand2(reg) (unsigned)
					imul_=15,	//operand1(reg) = operand1(reg) * operand2(reg) (signed)
					div_=16,		//operand1(reg) = operand1(reg) / oeprand2(reg) (unsigned)
					idiv_=17,	//operand1(reg) = operand1(reg) / operand2(reg) (signed)
					not_=18,		//opearnd1(reg) = ~operand1(reg)
					shl_=19,		//operand1(reg) = operand1(reg) << operand2(reg)
					shli_=20,	//operand1(reg) = operand1(reg) << operand2
					shr_=21,		//operand1(reg) = operand1(reg) >> operand2(reg)
					shri_=22,	//operand1(reg) = operand1(reg) >> operand2
					sar_=23,		//operand1(reg) = operand1(reg) >> operand2(reg)상위 비트 유지
					sari_=24,	//operand1(reg) = operand1(reg) >> operand2위 비트 유지
					and_=25,		//operand1(reg) = operand1(reg) & operand2(reg) 
					test_=26,	//operand1(reg) & operand2(reg)레지스터만 변경
					or_=27,		//opearnd1(reg) = opearnd1(reg) | operand2(reg)
					xor_=28,		//operand1(reg) = operand1(reg) xor opearnd2(reg)
					call_=29,	//pc -> sp, sp = sp - 1, bp <- sp, pc <- operand2
					jmp_=30,		//pc <- operand2
					ret_=31,		//sp <- bp, sp = sp + 1, pc <- sp
					jz_=32,		//if(Z) pc <- operand2
					je_=33,		//if(Z) pc <- operand2
					jne_=34, 	//if(!Z) pc <- operand2
					jnz_=35,		//if(!Z) pc <- operand2
					ja_=36,		//if(!Z & !C) pc <- operand2
					jb_=37,		//if(C) pc <- operand2
					jbe_=38,		//if(Z | C) pc <- operand2
					jae_=39,		//if(!C) pc <- operand2
					jg_=40,		//if(!Z & !V) pc <- operand2
					jl_=41,		//if(V) pc <- operand2
					jle_=42,		//if(Z | V) pc <- operandw
					jge_=43,		//if(!V) pc <- operand2
					js_=44,		//if(N) pc <- operand2
					jns_=45,		//if(!N) pc <- operand2
					jc_=46,		//if(C) pc <- operand2
					jnc_=47,		//if(!C) pc <- operand2
					jo_=48,		//if(V) pc <- operand2
					jno_=49;		//if(!V) pc <- operand2

	
	always @(posedge clk or posedge reset) begin
		if(reset) begin PC <= 0; IR <= 0; REG <= 0; SREG <= 0; SP <= 16'hFFFF; BP <= 16'hFFFF; end
		else begin
			case(state)
				IDLE: begin wren <= 0; 								end
				FETCH1: begin address <= PC; wren <= 0;		end
				FETCH2: begin address <= PC + 1; 				end
				FETCH3: begin IR[31:16] <= q; 					end
				FETCH4: begin IR[15:0] <= q; PC <= PC + 2; 	end
				DECODE: begin 
					case(op_code)
						lod_:		begin address <= operand2; wren <= 0; 	end
						pop_:		begin address <= SP + 1; wren <= 0; 	end
						ret_:		begin address <= BP - 1; wren <= 0; 	end
					endcase
				end
				EXECUTE1: begin
					case(op_code)
						mov_:		begin REG[16*reg1 +: 16] <= REG[16*reg2 +: 16]; 																end
						sto_:		begin address <= operand2; data <= REG[16*reg1 +: 16]; wren <= 1; 										end
						push_: 	begin address <= SP; data <= REG[16*reg1 +: 16]; wren <= 1; SP <= SP - 1; 								end
						cmp_: 	begin {SREG[2], AC} <= REG[16*reg1 +: 16] - REG[16*reg2 +: 16]; 											end
						inc_: 	begin {SREG[2], AC} <= REG[16*reg1 +: 16] + 1; 																	end
						dec_: 	begin {SREG[2], AC} <= REG[16*reg1 +: 16] - 1; 																	end
						neg_: 	begin AC <= -REG[16*reg1 +: 16]; 																SREG[2] <= 0; 	end
						add_:		begin {SREG[2], AC} <= REG[16*reg1 +: 16] + REG[16*reg2 +: 16]; 											end
						addi_: 	begin AC <= REG[16*reg1 +: 16] + operand2;													SREG[2] <= 0;  end
						sub_:		begin {SREG[2], AC} <= REG[16*reg1 +: 16] - REG[16*reg2 +: 16]; 											end
						subi_: 	begin AC <= REG[16*reg1 +: 16] - operand2;													SREG[2] <= 0;  end
						not_: 	begin AC <= ~REG[16*reg1 +: 16]; 																SREG[2] <= 0; 	end
						shl_:		begin {SREG[2], AC} <= REG[16*reg1 +: 16] << REG[16*reg2 +: 4]; 											end
						shli_: 	begin {SREG[2], AC} <= REG[16*reg1 +: 16] << reg2; 															end
						shr_:		begin AC <= REG[16*reg1 +: 16] >> REG[16*reg2 +: 4]; 										SREG[2] <= 0; 	end
						shri_: 	begin AC <= REG[16*reg1 +: 16] >> reg2; 														SREG[2] <= 0; 	end
						sar_:		begin AC <= {{16{REG[16*reg1 + 15]}}, REG[16*reg1 +: 16]} >>> REG[16*reg2 +: 4]; SREG[2] <= 0; 	end
						sari_: 	begin AC <= {{16{REG[16*reg1 + 15]}}, REG[16*reg1 +: 16]} >>> reg2; 					SREG[2] <= 0; 	end
						and_:		begin AC <= REG[16*reg1 +: 16] & REG[16*reg2 +: 16]; 										SREG[2] <= 0; 	end
						test_: 	begin AC <= REG[16*reg1 +: 16] & REG[16*reg2 +: 16]; 										SREG[2] <= 0; 	end
						or_:		begin AC <= REG[16*reg1 +: 16] | REG[16*reg2 +: 16]; 										SREG[2] <= 0; 	end
						xor_:		begin AC <= REG[16*reg1 +: 16] ^ REG[16*reg2 +: 16]; 										SREG[2] <= 0; 	end
						call_:	begin address <= SP; data <= PC; wren <= 1;	PC <= operand2;												end
						jmp_:		begin PC <= operand2; 																									end
						ret_:		begin address <= BP; wren <= 0; 																						end
						jz_:		begin if(Z)			PC <= operand2;																					end
						je_:		begin if(Z)			PC <= operand2;																					end
						jne_:		begin if(~Z)		PC <= operand2;																					end
						jnz_:		begin if(~Z)		PC <= operand2;																					end
						ja_:		begin if(~Z & ~C)	PC <= operand2;																					end
						jb_:		begin if(C)			PC <= operand2;																					end
						jbe_:		begin if(Z | C)	PC <= operand2;																					end
						jae_:		begin if(~C)		PC <= operand2;																					end
						jg_:		begin if(~Z & ~V)	PC <= operand2;																					end
						jl_:		begin if(V)			PC <= operand2;																					end
						jle_:		begin if(Z | V)	PC <= operand2;																					end
						jge_:		begin if(~V)		PC <= operand2;																					end
						js_:		begin if(N)			PC <= operand2;																					end
						jns_:		begin if(~N)		PC <= operand2;																					end
						jc_:		begin if(C)			PC <= operand2;																					end
						jnc_:		begin if(~C)		PC <= operand2;																					end
						jo_:		begin if(V)			PC <= operand2;																					end
						jno_:		begin if(~V)		PC <= operand2;																					end
						default:	begin 																										SREG[2] <= 0;	end
					endcase
				end
				EXECUTE2: begin
					case(op_code)
						lod_:		begin REG[16*reg1 +: 16] <= q; 																																			end
						pop_: 	begin REG[16*reg1 +: 16] <= q; SP <= SP + 1; 																														end
						cmp_: 	begin 																											SREG[1:0] <= {AC ^ REG[16*reg1 +: 16], AC[15]}; end
						inc_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						dec_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						neg_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {1'b0, AC[15]}; 							end
						add_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {AC ^ REG[16*reg1 +: 16], AC[15]}; end
						addi_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {AC ^ REG[16*reg1 +: 16], AC[15]}; end
						sub_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {AC ^ REG[16*reg1 +: 16], AC[15]}; end
						subi_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {AC ^ REG[16*reg1 +: 16], AC[15]}; end
						mul_:		begin REG[16*reg1 +: 16] <= product[31:16]; REG[16*reg2 +: 16] <= product[15:0]; 		SREG[1:0] <= 0;											end
						imul_: 	begin REG[16*reg1 +: 16] <= product[31:16]; REG[16*reg2 +: 16] <= product[15:0]; 		SREG[1:0] <= {1'b0, product[31]};					end
						div_:		begin REG[16*reg1 +: 16] <= u_quotient[15:0]; REG[16*reg2 +: 16] <= u_remainder[15:0];	SREG[1:0] <= 0; 											end
						idiv_: 	begin REG[16*reg1 +: 16] <= s_quotient[15:0]; REG[16*reg2 +: 16] <= s_remainder[15:0];	SREG[1:0] <= {1'b0, s_quotient[15]}; 				end
						not_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						shl_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						shli_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						shr_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						shri_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						sar_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {1'b0, AC[15]}; 							end
						sari_: 	begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= {1'b0, AC[15]}; 							end
						and_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						test_: 	begin 																											SREG[1:0] <= 0; 											end
						or_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						xor_:		begin REG[16*reg1 +: 16] <= AC; 																			SREG[1:0] <= 0; 											end
						call_:	begin address <= SP - 1; data <= BP; wren <= 1; BP <= SP; SP <= SP - 2; 	 				 																end
						ret_:		begin BP <= q; SP <= BP; 																																					end
						default:	begin 																											SREG[1:0] <= 0; 											end
					endcase
					case(op_code)
						mul_:		begin SREG[3] <= (product == 0); 	end
						imul_: 	begin SREG[3] <= (product == 0); 	end
						div_:		begin SREG[3] <= (u_quotient == 0);	end
						idiv_: 	begin SREG[3] <= (s_quotient == 0);	end
						default:	begin	SREG[3] <= (AC == 0); 			end
					endcase
				end
				EXECUTE3: begin
					case(op_code)
						ret_:		begin PC <= q; end
					endcase
				end
			endcase
		end
	end
	//////////////////////////////////////////////////
endmodule
