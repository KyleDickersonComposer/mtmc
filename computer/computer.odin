package computer

import "core:log"

match_register :: proc(register_as_byte: u8) -> (Register, Computer_Error) {
	switch register_as_byte {
	case 0:
		return .t0, nil
	case 1:
		return .t1, nil
	case 2:
		return .t2, nil
	case 3:
		return .t3, nil
	case 4:
		return .t4, nil
	case 5:
		return .t5, nil
	case 6:
		return .a0, nil
	case 7:
		return .a1, nil
	case 8:
		return .a2, nil
	case 9:
		return .a3, nil
	case 10:
		return .rv, nil
	case 11:
		return .ra, nil
	case 12:
		return .fp, nil
	case 13:
		return .sp, nil
	case 14:
		return .bp, nil
	case 15:
		return .pc, nil
	case 16:
		return .ir, nil
	case 17:
		return .dr, nil
	case 18:
		return .cb, nil
	case 19:
		return .db, nil
	case 20:
		return .io, nil

	case:
		log.error(
			"invalid register index: as bytes=%b, as hex=%x, as decimal=%d",
			register_as_byte,
			register_as_byte,
			register_as_byte,
		)
		return .t0, .Invalid_Encoding_Of_Register_Index
	}

	log.error("hit failed in match_register procedure")
	return .t0, .Failed
}

get_register_value :: proc(c: ^Computer, r: Register) -> i16 {
	return c.Registers[r]
}

set_register_value :: proc(c: ^Computer, r: Register, value: i16) {
	c.Registers[r] = value
}

decode_ALU_instruction :: proc(
	i: Instruction,
) -> (
	inst: Decoded_Instruction,
	err: Computer_Error,
) {
	first_operand := match_register(i.third_nibble) or_return
	second_operand := match_register(i.fourth_nibble) or_return

	switch i.second_nibble {
	case 0b0000:
		return Decoded_Instruction {
				instruction = .add,
				first_operand = first_operand,
				second_operand = second_operand,
				raw_instruction = i,
			},
			nil

	case 0b0001:
		return Decoded_Instruction {
				instruction = .sub,
				first_operand = first_operand,
				second_operand = second_operand,
				raw_instruction = i,
			},
			nil


	// NOTE: need to handle 2 word thing here. Meaning that it needs to not treat the fourth nibble as a register
	// imm
	case:
		log.errorf("invalid instruction: %b", i.second_nibble)
		return {}, .Invalid_ALU_Instruction
	}


	log.error("hit failed in decode_ALU_instruction procedure")
	return {}, .Failed
}

decode_instruction :: proc(
	instruction_bytes: u16,
) -> (
	inst: Decoded_Instruction,
	err: Computer_Error,
) {
	instruction := cast(Instruction)instruction_bytes

	switch instruction.first_nibble {
	case 0x0:
	// misc
	case 0x1:
		return decode_ALU_instruction(instruction) or_return, nil
	case 0x2:
	// stack
	case 0x3:
	// test
	case 0x4 ..= 0x7:
	// load/store register
	case 0x8:
	// load/store
	case 0x9:
	//jump register
	case 0xC ..= 0xF:
	// jump
	case:
		log.errorf("expected a valid instruction, got: %b", instruction_bytes)
		return {}, .Invalid_Top_Nibble
	}

	log.error("hit failed in decode_instruction procedure")
	return {}, .Failed
}


execute_binary_add :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) + get_register_value(c, i.second_operand)
}

execute_binary_sub :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) - get_register_value(c, i.second_operand)
}

execute_binary_mul :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) * get_register_value(c, i.second_operand)
}

execute_binary_div :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) / get_register_value(c, i.second_operand)
}

execute_binary_mod :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) % get_register_value(c, i.second_operand)
}

execute_binary_bitwise_and :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) & get_register_value(c, i.second_operand)
}

execute_binary_bitwise_or :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) | get_register_value(c, i.second_operand)
}

execute_binary_xor :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) ~ get_register_value(c, i.second_operand)
}

execute_binary_shl :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) << u16(get_register_value(c, i.second_operand))
}

execute_binary_shr :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) >> u16(get_register_value(c, i.second_operand))
}

execute_binary_min :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] = min(
		get_register_value(c, i.first_operand),
		get_register_value(c, i.second_operand),
	)
}

execute_binary_max :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] = max(
		get_register_value(c, i.first_operand),
		get_register_value(c, i.second_operand),
	)
}

execute_unary_bitwise_not :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] = ~get_register_value(c, i.first_operand)
}

execute_unary_logical_not :: proc(c: ^Computer, i: Decoded_Instruction) {
	r := get_register_value(c, i.first_operand)

	if r == 0 {
		c.Registers[i.first_operand] = 1
	} else {
		c.Registers[i.first_operand] = 0
	}
}

execute_unary_negate :: proc(c: ^Computer, i: Decoded_Instruction) {
	c.Registers[i.first_operand] = -get_register_value(c, i.first_operand)
}


execute_immediate_ALU_operation :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	assert(i.instruction == .imm)

	first_operand := i.raw_instruction.third_nibble
	op_nibble := i.raw_instruction.fourth_nibble

	op := cast(ALU_Instruction)op_nibble

	pc := c.Registers[Register.pc]

	next_word := u16(c.Memory[pc]) << 8 | u16(c.Memory[pc + 1])

	switch op {
	case .add:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) + i16(next_word)
		return nil
	case .sub:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) - i16(next_word)
		return nil
	case .mul:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) * i16(next_word)
		return nil
	case .div:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) / i16(next_word)
		return nil
	case .mod:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) % i16(next_word)
		return nil
	case .and:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) & i16(next_word)
		return nil
	case .or:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) | i16(next_word)
		return nil
	case .xor:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) ~ i16(next_word)
		return nil
	case .shl:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) << u16(next_word)
		return nil
	case .shr:
		c.Registers[first_operand] = i16(c.Registers[first_operand]) >> u16(next_word)
		return nil
	case .min:
		c.Registers[first_operand] = min(i16(c.Registers[first_operand]), i16(next_word))
		return nil
	case .max:
		c.Registers[first_operand] = max(i16(c.Registers[first_operand]), i16(next_word))
		return nil
	case .not:
		// TODO: need to setup error handling for the unary immediate mode things?
		log.error("unary operations shouldn't be performed in immediate mode")
		return .Invalid_ALU_Instruction
	case .l_not:
		log.error("unary operations shouldn't be performed in immediate mode")
		return .Invalid_ALU_Instruction
	case .neg:
		log.error("unary operations shouldn't be performed in immediate mode")
		return .Invalid_ALU_Instruction
	case .imm:
		log.errorf("invalid op in imm instruction, got: %b", op)
		return .Invalid_Operation_In_Immediate_Mode_ALU_Instruction
	}

	log.error("hit failed in execute_immediate_ALU_instruction procedure")
	return .Failed
}


execute_ALU_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	switch i.instruction {
	case .add:
		execute_binary_add(c, i)
		return nil
	case .sub:
		execute_binary_sub(c, i)
		return nil
	case .mul:
		execute_binary_mul(c, i)
		return nil
	case .div:
		execute_binary_div(c, i)
		return nil
	case .mod:
		execute_binary_mod(c, i)
		return nil
	case .and:
		execute_binary_bitwise_and(c, i)
		return nil
	case .or:
		execute_binary_bitwise_or(c, i)
		return nil
	case .xor:
		execute_binary_xor(c, i)
		return nil
	case .shl:
		execute_binary_shl(c, i)
		return nil
	case .shr:
		execute_binary_shr(c, i)
		return nil
	case .min:
		execute_binary_min(c, i)
		return nil
	case .max:
		execute_binary_max(c, i)
		return nil
	case .not:
		execute_unary_bitwise_not(c, i)
		return nil
	case .l_not:
		execute_unary_logical_not(c, i)
		return nil
	case .neg:
		execute_unary_negate(c, i)
		return nil
	case .imm:
		execute_immediate_ALU_operation(c, i)
		return nil
	}

	log.error("hit failed in execute_binary_instruction procedure")
	return .Failed
}

execute_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	switch v in i.instruction {
	case ALU_Instruction:
		execute_ALU_instruction(c, i)
		return nil
	}

	log.error("hit failed in execute_instruction procedure")
	return .Failed
}
