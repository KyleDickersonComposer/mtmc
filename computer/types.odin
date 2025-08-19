package computer

Error :: union {
	Instruction_Decoding_Error,
}

Instruction_Decoding_Error :: enum {
	Failed,
	Invalid_Top_Nibble,
	Invalid_Alu_Instruction,
	Invalid_Encoding_Of_Register_Index,
	Invalid_Decoded_Instruction,
}

Computer :: struct {
	Memory:        [4096]byte,
	Registers:     [20]i16,
	test_flag:     bool,
	overflow_flag: bool,
	nan_flag:      bool,
	error_flag:    bool,
}

User_Facing_Registers :: enum {
	t0,
	t1,
	t2,
	t3,
	t4,
	t5,
	a0,
	a1,
	a2,
	a3,
	rv,
	ra,
	fp,
	sp,
	bp,
	pc,
}

Syscall :: enum {
	exit     = 0x00,
	rint     = 0x01,
	wint     = 0x02,
	rstr     = 0x03,
	wchr     = 0x04,
	rchr     = 0x05,
	wstr     = 0x06,
	printf   = 0x07,
	atoi     = 0x08,
	rfile    = 0x10,
	wfile    = 0x11,
	cwd      = 0x12,
	chdir    = 0x13,
	dirent   = 0x14,
	dfile    = 0x05,
	rnd      = 0x20,
	sleep    = 0x21,
	timer    = 0x22,
	fbreset  = 0x30,
	fbstat   = 0x31,
	fbset    = 0x32,
	fbline   = 0x33,
	fbrect   = 0x34,
	fbflush  = 0x35,
	joystick = 0x3A,
	scolor   = 0x3B,
	memcpy   = 0x40,
	drawing  = 0x50,
	error    = 0xFF,
}

Instruction :: bit_field u16 {
	fourth_nibble: u8 | 4,
	third_nibble:  u8 | 4,
	second_nibble: u8 | 4,
	first_nibble:  u8 | 4,
}

Decoded_Instruction :: union {
	Decoded_Binary_Instruction,
	Decoded_Unary_Instruction,
	Decoded_Two_Word_Instruction,
}

Decoded_Binary_Instruction :: struct {
	operation:      ALU_Instruction,
	first_operand:  User_Facing_Registers,
	second_operand: User_Facing_Registers,
}

Decoded_Unary_Instruction :: struct {}
Decoded_Two_Word_Instruction :: struct {}

Two_Word_Instruction :: enum {
	mcp,
	imm,
	debug, // this is weird one (probably faking it is fine?)
	pushi,
	eqi,
	neqi,
	gti,
	gtei,
	lti,
	ltei,
}

Miscellaneous_Instruction :: enum {
	sys,
	mov,
	inv,
	dec,
	seti,
	mcp,
	debug,
	nop = 0b1111,
}


ALU_Instruction :: enum {
	add,
	sub,
	mul,
	div,
	mod,
	and,
	or,
	xor,
	shl,
	shr,
	min,
	max,
	not,
	l_not,
	neg,
	imm,
}

Stack_Instruction :: enum {
	push,
	pop,
	dup,
	swap,
	drop,
	over,
	rot,
	sop,
	pushi = 0b1111,
}

Test_Instruction :: enum {
	eq,
	neq,
	gt,
	gte,
	lt,
	lte,
	eqi = 0b1000,
	neqi,
	gti,
	gtei,
	lti,
	ltei,
}

// NOTE: special instructions with `top_nibble` that is 2 bits.
Load_Store_Register_Instruction :: enum {
	lwr = 0b0100,
	lbr = 0b0101,
	swr = 0b0110,
	sbr = 0b0111,
}

Load_Store_Instruction :: enum {
	lw,
	lwo,
	lb,
	lbo,
	sw,
	swo,
	sb,
	sbo,
	li,
	la,
}

Jump_Register_Instruction :: enum {
	jr,
	ret,
}

// NOTE: Jumps to the address encoded in the lower three bytes.
Jump_Instruction :: enum {
	j,
	jz,
	jnz,
	jal,
}

IO_Mapping :: enum {
	up     = 0x80,
	down   = 0x40,
	left   = 0x20,
	right  = 0x10,
	start  = 0x08,
	select = 0x04,
	b      = 0x02,
	a      = 0x01,
}
