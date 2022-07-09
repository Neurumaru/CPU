# CPU
2021-2 embedded hardware design project

## Features

### 1. Assembly programming using IO devices   
- Available to write instruction to RAM. It works in the following ways:
> 1. Specify instruction (op-code, operand1, operand2) using Switchs
> 2. Check the instruction through seven-segments LEDs
> 3. Check RAM address where the instruction will be written through LEDRs
> 4. Available to change RAM address by pushing KEYs (UP / DOWN)
> 5. Write the instruction by pushing a KEY (INSERT)

### 2. Run a assembly program   
- Switch to CPU mode and push a KEY (RESET)

## Instruction

|Instruction|Dec|Hex|Method|
|------|---|---|---|
|	nop	|	0	|	00	|		|
|	mov	|	1	|	01	|	operand1(reg) <- operand2(reg)	|
|	lod	|	2	|	02	|	operand1(reg) <- mem[operand2]	|
|	sto	|	3	|	03	|	operand1(reg) -> mem[operand2]	|
|	push	|	4	|	04	|	operand1(reg) -> sp, sp = sp - 1	|
|	pop	|	5	|	05	|	sp = sp + 1, operand1(reg) <- sp	|
|	cmp	|	6	|	06	|	operand1(reg) - operand2(reg)	|
|	inc	|	7	|	07	|	operand1(reg) = operand1(reg) + 1	|
|	dec	|	8	|	08	|	operand1(reg) = opearnd1(reg) - 1	|
|	neg	|	9	|	09	|	operand1(reg) = - operand1(reg)	|
|	add	|	10	|	0A	|	operand1(reg) = operand1(reg) + operand2(reg)	|
|	addi	|	11	|	0B	|	operand1(reg) = operand1(reg) + operand2	|
|	sub	|	12	|	0C	|	operand1(reg) = operand1(reg) - operand2(reg)	|
|	subi	|	13	|	0D	|	operand1(reg) = operand1(reg) - operand2	|
|	mul	|	14	|	0E	|	operand1(reg) = operand1(reg) * operand2(reg) (unsigned)	|
|	imul	|	15	|	0F	|	operand1(reg) = operand1(reg) * operand2(reg) (signed)	|
|	div	|	16	|	10	|	operand1(reg) = operand1(reg) / oeprand2(reg) (unsigned)	|
|	idiv	|	17	|	11	|	operand1(reg) = operand1(reg) / operand2(reg) (signed)	|
|	not	|	18	|	12	|	opearnd1(reg) = ~operand1(reg)	|
|	shl	|	19	|	13	|	operand1(reg) = operand1(reg) << operand2(reg)	|
|	shli	|	20	|	14	|	operand1(reg) = operand1(reg) << operand2	|
|	shr	|	21	|	15	|	operand1(reg) = operand1(reg) >> operand2(reg)	|
|	shri	|	22	|	16	|	operand1(reg) = operand1(reg) >> operand2	|
|	sar	|	23	|	17	|	operand1(reg) = operand1(reg) >> operand2(reg)	|
|	sari	|	24	|	18	|	operand1(reg) = operand1(reg) >> operand2	|
|	and	|	25	|	19	|	operand1(reg) = operand1(reg) & operand2(reg)	|
|	test	|	26	|	1A	|	operand1(reg) & operand2(reg)	|
|	or	|	27	|	1B	|	opearnd1(reg) = opearnd1(reg) | operand2(reg)	|
|	xor	|	28	|	1C	|	operand1(reg) = operand1(reg) xor opearnd2(reg)	|
|	call	|	29	|	1D	|	pc -> sp, sp = sp - 1, bp <- sp, pc <- operand2	|
|	jmp	|	30	|	1E	|	pc <- operand2	|
|	ret	|	31	|	1F	|	sp <- bp, sp = sp + 1, pc <- sp	|
|	jz	|	32	|	20	|	if(Z) pc <- operand2	|
|	je	|	33	|	21	|	if(Z) pc <- operand2	|
|	jne	|	34	|	22	|	if(!Z) pc <- operand2	|
|	jnz	|	35	|	23	|	if(!Z) pc <- operand2	|
|	ja	|	36	|	24	|	if(!Z & !C) pc <- operand2	|
|	jb	|	37	|	25	|	if(C) pc <- operand2	|
|	jbe	|	38	|	26	|	if(Z \| C) pc <- operand2	|
|	jae	|	39	|	27	|	if(!C) pc <- operand2	|
|	jg	|	40	|	28	|	if(!Z & !V) pc <- operand2	|
|	jl	|	41	|	29	|	if(V) pc <- operand2	|
|	jle	|	42	|	2A	|	if(Z \| V) pc <- operandw	|
|	jge	|	43	|	2B	|	if(!V) pc <- operand2	|
|	js	|	44	|	2C	|	if(S) pc <- operand2	|
|	jns	|	45	|	2D	|	if(!S) pc <- operand2	|
|	jc	|	46	|	2E	|	if(C) pc <- operand2	|
|	jnc	|	47	|	2F	|	if(!C) pc <- operand2	|
|	jo	|	48	|	30	|	if(V) pc <- operand2	|
|	jno	|	49	|	31	|	if(!V) pc <- operand2	|
