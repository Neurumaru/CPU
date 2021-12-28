module lcd_decoder(instruction, line, length);
	input [31:0] instruction;
	output reg [16*8-1:0] line;
	output reg [3:0] length;
	
	wire [7:0] op_code;
	wire [7:0] operand1;
	wire [15:0] operand2;
	wire [15:0] operand1_ascii;
	wire [31:0] operand2_ascii;
	
	assign op_code = instruction[31:24];
	assign operand1 = instruction[23:16];
	assign operand2 = instruction[15:0];
	
	ascii_decoder_hex adh11 (operand1[7:4], 	operand1_ascii[15:8]);
	ascii_decoder_hex adh10 (operand1[3:0], 	operand1_ascii[7:0]);
	ascii_decoder_hex adh23 (operand2[15:12], operand2_ascii[31:24]);
	ascii_decoder_hex adh22 (operand2[11:8], 	operand2_ascii[23:16]);
	ascii_decoder_hex adh21 (operand2[7:4], 	operand2_ascii[15:8]);
	ascii_decoder_hex adh20 (operand2[3:0], 	operand2_ascii[7:0]);
	
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
					js_=44,		//if(S) pc <- operand2
					jns_=45,		//if(!S) pc <- operand2
					jc_=46,		//if(C) pc <- operand2
					jnc_=47,		//if(!C) pc <- operand2
					jo_=48,		//if(V) pc <- operand2
					jno_=49;		//if(!V) pc <- operand2
	
	always @(*) begin
		case(op_code)
			nop_:		begin line={"nop"}; length=3; end
			mov_:		begin line={"mov r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			lod_:		begin line={"lod r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=5+1+3+4; end
			sto_:		begin line={"sto r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=5+1+3+4; end
			push_: 	begin line={"push r", operand1_ascii[7:0]}; length=6+1; end
			pop_: 	begin line={"pop r", operand1_ascii[7:0]}; length=5+1; end
			cmp_: 	begin line={"cmp r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			inc_: 	begin line={"inc r", operand1_ascii[7:0]}; length=5+1; end
			dec_: 	begin line={"dec r", operand1_ascii[7:0]}; length=5+1; end
			neg_: 	begin line={"neg r", operand1_ascii[7:0]}; length=5+1; end
			add_:		begin line={"add r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			addi_: 	begin line={"addi r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=6+1+3+4; end
			sub_:		begin line={"sub r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			subi_: 	begin line={"subi r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=6+1+3+4; end
			mul_:		begin line={"mul r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			imul_: 	begin line={"imul r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=6+1+2+1; end
			div_:		begin line={"div r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			idiv_: 	begin line={"idiv r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=6+1+2+1; end
			not_: 	begin line={"not r", operand1_ascii[7:0]}; length=5+1; end
			shl_:		begin line={"shl r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			shli_: 	begin line={"shli r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=6+1+3+4; end
			shr_:		begin line={"shr r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			shri_: 	begin line={"shri r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=6+1+3+4; end
			sar_:		begin line={"sar r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			sari_: 	begin line={"sari r", operand1_ascii[7:0], " 0x", operand2_ascii}; length=6+1+3+4; end
			and_:		begin line={"and r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			test_: 	begin line={"test r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=6+1+2+1; end
			or_:		begin line={"or r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=4+1+2+1; end
			xor_:		begin line={"xor r", operand1_ascii[7:0], " r", operand2_ascii[7:0]}; length=5+1+2+1; end
			call_:	begin line={"call 0x", operand2_ascii}; length=7+4; end
			jmp_:		begin line={"jmp 0x", operand2_ascii}; length=6+4; end
			ret_:		begin line={"ret"}; length=3; end
			jz_:		begin line={"jz 0x", operand2_ascii}; length=5+4; end
			je_:		begin line={"je 0x", operand2_ascii}; length=5+4; end
			jne_:		begin line={"jne 0x", operand2_ascii}; length=6+4; end
			jnz_:		begin line={"jnz 0x", operand2_ascii}; length=6+4; end
			ja_:		begin line={"ja 0x", operand2_ascii}; length=5+4; end
			jb_:		begin line={"jb 0x", operand2_ascii}; length=5+4; end
			jbe_:		begin line={"jbe 0x", operand2_ascii}; length=6+4; end
			jae_:		begin line={"jae 0x", operand2_ascii}; length=6+4; end
			jg_:		begin line={"jg 0x", operand2_ascii}; length=5+4; end
			jl_:		begin line={"jl 0x", operand2_ascii}; length=5+4; end
			jle_:		begin line={"jle 0x", operand2_ascii}; length=6+4; end
			jge_:		begin line={"jge 0x", operand2_ascii}; length=6+4; end
			js_:		begin line={"js 0x", operand2_ascii}; length=5+4; end
			jns_:		begin line={"jns 0x", operand2_ascii}; length=6+4; end
			jc_:		begin line={"jc 0x", operand2_ascii}; length=5+4; end
			jnc_:		begin line={"jnc 0x", operand2_ascii}; length=6+4; end
			jo_:		begin line={"jo 0x", operand2_ascii}; length=5+4; end
			jno_:		begin line={"jno 0x", operand2_ascii}; length=6+4; end
			default: begin line={"nop"}; length=3; end
		endcase
	end
endmodule
