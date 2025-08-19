package computer

import "core:fmt"
import "core:log"

POSITIVE_OVERFLOW :: 32767
NEGATIVE_OVERFLOW :: -32768

init_computer :: proc(allocator := context.allocator) -> Computer {
	errors := make([dynamic]Debug_Error_Info, allocator)
	return Computer{error_info = errors}
}

shutdown_computer :: proc(c: ^Computer) {
	for s in c.error_info {
		delete(s.error_message)
	}

	delete(c.error_info)
}

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

decode_ALU_instruction :: proc(
	i: Instruction,
) -> (
	inst: Decoded_Instruction,
	err: Computer_Error,
) {
	switch i.second_nibble {
	case 0b0000:
		return Decoded_Instruction{type = .add, instruction = i}, nil
	case 0b0001:
		return Decoded_Instruction{type = .sub, instruction = i}, nil
	case 0b0010:
		return Decoded_Instruction{type = .mul, instruction = i}, nil
	case 0b0011:
		return Decoded_Instruction{type = .div, instruction = i}, nil
	case 0b0100:
		return Decoded_Instruction{type = .mod, instruction = i}, nil
	case 0b1111:
		return Decoded_Instruction{type = .imm, instruction = i}, nil

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
	// stack
	case 0x2:
	// test
	case 0x3:
	// load/store register
	case 0x4 ..= 0x7:
	// load/store
	case 0x8:
	//jump register
	case 0x9:
	// jump
	case 0xC ..= 0xF:
	case:
		log.errorf("expected a valid instruction, got: %b", instruction_bytes)
		return {}, .Invalid_Top_Nibble
	}

	log.error("hit failed in decode_instruction procedure")
	return {}, .Failed
}

check_overflow :: proc(
	first_operand: i16,
	second_operand: i16,
	op: ALU_Instruction,
) -> (
	bool,
	Execution_Error,
) {
	f := i64(first_operand)
	s := i64(second_operand)

	evaluation: i64

	#partial switch op {
	case .add:
		evaluation = f + s
	case .sub:
	case .mul:
	case .div:
		if second_operand == 0 {
			log.error(
				"hit weird edge case where you are checking an overflow for a division operation that should already have returned in the function call before this one",
			)
			return false, nil
		}
		evaluation = f / s

	case .mod:
		if second_operand == 0 {
			log.error(
				"hit weird edge case where you are checking an overflow for a modulo operation that should already have returned in the function call before this one",
			)
			return false, nil
		}
		evaluation = f % s
	case:
		log.error("invalid overflow check on operation that can't overflow, op:", op)
		return false, .Invalid_Overflow_Check_On_Operation_That_Will_Not_Overflow
	}


	if evaluation > POSITIVE_OVERFLOW || evaluation < NEGATIVE_OVERFLOW {
		return true, nil
	}
	return false, nil
}

execute_add :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.overflow_flag = check_overflow(first_operand, second_operand, .add) or_return

	c.Registers[assignment_register] = first_operand + second_operand

	return nil
}

execute_sub :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.overflow_flag = check_overflow(first_operand, second_operand, .sub) or_return

	c.Registers[assignment_register] = first_operand - second_operand

	return nil
}

execute_mul :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]
	overflow := i64(first_operand) * i64(second_operand)

	c.overflow_flag = check_overflow(first_operand, second_operand, .mul) or_return

	c.Registers[assignment_register] = first_operand * second_operand

	return nil
}

execute_div :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	if i.instruction.fourth_nibble == 0 {
		c.error_flag = true

		pc := c.Registers[Register.pc]
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				error_message = fmt.aprintf(
					"divide by zero at pc: 0x%04X (instruction %d)",
					pc,
					pc / 2,
				),
			},
		)
		return nil
	} else {
		first_operand := c.Registers[i.instruction.third_nibble]
		second_operand := c.Registers[i.instruction.fourth_nibble]
		overflow := i64(first_operand) / i64(second_operand)

		c.overflow_flag = check_overflow(first_operand, second_operand, .div) or_return

		c.Registers[assignment_register] = first_operand / second_operand
	}

	return nil
}

execute_mod :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	if i.instruction.fourth_nibble == 0 {
		c.error_flag = true

		pc := c.Registers[Register.pc]
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				error_message = fmt.aprintf(
					"mod by zero at pc: 0x%04X (instruction %d)",
					pc,
					pc / 2,
				),
			},
		)
		return nil
	} else {
		first_operand := c.Registers[i.instruction.third_nibble]
		second_operand := c.Registers[i.instruction.fourth_nibble]

		c.overflow_flag = check_overflow(first_operand, second_operand, .mod) or_return

		c.Registers[assignment_register] = first_operand % second_operand
	}

	return nil
}

execute_bitwise_and :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = first_operand & second_operand
}

execute_bitwise_or :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = first_operand | second_operand
}

execute_xor :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = first_operand ~ second_operand
}

execute_shl :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = first_operand << u16(second_operand)
}

execute_shr :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = first_operand >> u16(second_operand)
}

execute_min :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]
	c.Registers[assignment_register] = min(first_operand, second_operand)
}

execute_max :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]
	c.Registers[assignment_register] = max(first_operand, second_operand)
}

execute_bitwise_not :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	operand := c.Registers[i.instruction.third_nibble]

	c.Registers[assignment_register] = ~operand
}

execute_logical_not :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	operand := c.Registers[i.instruction.third_nibble]

	if operand == 0 {
		c.Registers[assignment_register] = 1
	} else {
		c.Registers[assignment_register] = 0
	}
}

execute_negate :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble

	operand := c.Registers[i.instruction.third_nibble]

	c.Registers[assignment_register] = -operand
}


execute_immediate_ALU_operation :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	op_nibble := i.instruction.fourth_nibble

	op := cast(ALU_Instruction)op_nibble

	pc := c.Registers[Register.pc]

	raw := u16(c.Memory[pc + 2]) << 8 | u16(c.Memory[pc + 3])
	next_word := i16(raw)
	log.info(next_word)

	switch op {
	case .add:
		check_overflow(first_operand, next_word, .add) or_return
		c.Registers[assignment_register] = first_operand + next_word
		return nil
	case .sub:
		check_overflow(first_operand, next_word, .add) or_return
		c.Registers[assignment_register] = first_operand - next_word
		return nil
	case .mul:
		check_overflow(first_operand, next_word, .mul) or_return
		c.Registers[assignment_register] = first_operand * next_word
		return nil
	case .div:
		check_overflow(first_operand, next_word, .div) or_return
		c.Registers[assignment_register] = first_operand / next_word
		return nil
	case .mod:
		check_overflow(first_operand, next_word, .mod) or_return
		c.Registers[assignment_register] = first_operand % next_word
		return nil
	case .and:
		c.Registers[assignment_register] = first_operand & next_word
		return nil
	case .or:
		c.Registers[assignment_register] = first_operand | next_word
		return nil
	case .xor:
		c.Registers[assignment_register] = first_operand ~ next_word
		return nil
	case .shl:
		c.Registers[assignment_register] = first_operand << u16(next_word)
		return nil
	case .shr:
		c.Registers[assignment_register] = first_operand >> u16(next_word)
		return nil
	case .min:
		c.Registers[assignment_register] = min(first_operand, next_word)
		return nil
	case .max:
		c.Registers[assignment_register] = max(first_operand, i16(next_word))
		return nil
	case .not:
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = pc,
				error_message = fmt.aprintf("unary operation in immediate mode are invalid"),
			},
		)
		return nil
	case .l_not:
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = pc,
				error_message = fmt.aprintf("unary operation in immediate mode are invalid"),
			},
		)
		return nil
	case .neg:
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = pc,
				error_message = fmt.aprintf("unary operation in immediate mode are invalid"),
			},
		)
		return nil
	case .imm:
		log.errorf("invalid op in imm instruction, got: %b", op)
		return .Invalid_Operation_In_Immediate_Mode_ALU_Instruction
	}

	log.error("hit failed in execute_immediate_ALU_instruction procedure")
	return .Failed
}


execute_ALU_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	// NOTE: reseting flags numerical flags here
	c.nan_flag = false
	c.overflow_flag = false
	c.test_flag = false

	switch i.type {
	case .add:
		execute_add(c, i)
		return nil
	case .sub:
		execute_sub(c, i)
		return nil
	case .mul:
		execute_mul(c, i)
		return nil
	case .div:
		execute_div(c, i)
		return nil
	case .mod:
		execute_mod(c, i)
		return nil
	case .and:
		execute_bitwise_and(c, i)
		return nil
	case .or:
		execute_bitwise_or(c, i)
		return nil
	case .xor:
		execute_xor(c, i)
		return nil
	case .shl:
		execute_shl(c, i)
		return nil
	case .shr:
		execute_shr(c, i)
		return nil
	case .min:
		execute_min(c, i)
		return nil
	case .max:
		execute_max(c, i)
		return nil
	case .not:
		execute_bitwise_not(c, i)
		return nil
	case .l_not:
		execute_logical_not(c, i)
		return nil
	case .neg:
		execute_negate(c, i)
		return nil
	case .imm:
		execute_immediate_ALU_operation(c, i)
		return nil
	}

	log.error("hit failed in execute_binary_instruction procedure")
	return .Failed
}

// TODO: I'm not sure about this union of enums match thing...
execute_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	switch v in i.type {
	case ALU_Instruction:
		execute_ALU_instruction(c, i)
		return nil
	}

	log.error("hit failed in execute_instruction procedure")
	return .Failed
}
