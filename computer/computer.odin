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

read_next_word :: proc(c: ^Computer) -> i16 {
	pc := c.Registers[Register.pc]

	first_byte := c.Memory[pc + 2]
	second_byte := c.Memory[pc + 3]

	word := ((u16(first_byte) << 8) | u16(second_byte))

	return i16(word)
}

set_next_word :: proc(c: ^Computer, value: i16, pc_offset: i16) {
	pc := c.Registers[Register.pc] + pc_offset

	raw := u16(value)

	c.Memory[pc] = u8(raw >> 8)
	c.Memory[pc + 1] = u8(raw)
}

check_is_odd :: proc(value: u16) -> bool {
	return value % 2 == 0
}

push_word_at_stack_address :: proc(c: ^Computer, sp: u16, value: i16, sp_offset: u16) {
	if check_is_odd(sp_offset) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf(
					"offset the stack pointer by an odd number: %d, at sp:%d",
					sp_offset,
					c.Registers[Register.sp],
				),
			},
		)
	}

	raw := u16(value)

	c.Memory[sp - sp_offset] = u8(raw)
	c.Memory[sp - sp_offset - 1] = u8(raw >> 8)
}

read_word_at_stack_address :: proc(c: ^Computer, sp: u16, sp_offset: u16) -> i16 {
	if check_is_odd(sp_offset) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf(
					"offset the stack pointer by an odd number: %d, at sp:%d",
					sp_offset,
					c.Registers[Register.sp],
				),
			},
		)
	}

	first_byte := c.Memory[sp - sp_offset - 1]
	second_byte := c.Memory[sp - sp_offset]

	word := (u16(first_byte) << 8) | u16(second_byte)

	return i16(word)
}

decode_ALU_instruction :: proc(
	i: Instruction,
) -> (
	inst: Decoded_Instruction,
	err: Instruction_Decoding_Error,
) {
	switch i.second_nibble {
	case 0b0000:
		return {type = .add, instruction = i}, nil
	case 0b0001:
		return {type = .sub, instruction = i}, nil
	case 0b0010:
		return {type = .mul, instruction = i}, nil
	case 0b0011:
		return {type = .div, instruction = i}, nil
	case 0b0100:
		return {type = .mod, instruction = i}, nil
	case 0b0101:
		return {type = .and, instruction = i}, nil
	case 0b0110:
		return {type = .or, instruction = i}, nil
	case 0b0111:
		return {type = .xor, instruction = i}, nil
	case 0b1000:
		return {type = .shl, instruction = i}, nil
	case 0b1001:
		return {type = .shr, instruction = i}, nil
	case 0b1010:
		return {type = .min, instruction = i}, nil
	case 0b1011:
		return {type = .max, instruction = i}, nil
	case 0b1100:
		return {type = .not, instruction = i}, nil
	case 0b1101:
		return {type = .lnot, instruction = i}, nil
	case 0b1110:
		return {type = .neg, instruction = i}, nil
	case 0b1111:
		return {type = .imm, instruction = i}, nil
	}

	log.error("invalid ALU instruction second nibble:", i.second_nibble)
	return {}, .Invalid_ALU_Instruction
}

decode_stack_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	switch i.second_nibble {
	case 0b0000:
		return {type = .push, instruction = i}, nil
	case 0b0001:
		return {type = .pop, instruction = i}, nil
	case 0b0010:
		return {type = .dup, instruction = i}, nil
	case 0b0011:
		return {type = .swap, instruction = i}, nil
	case 0b0100:
		return {type = .drop, instruction = i}, nil
	case 0b0101:
		return {type = .over, instruction = i}, nil
	case 0b0110:
		return {type = .rot, instruction = i}, nil
	case 0b0111:
		return {type = .sop, instruction = i}, nil
	case 0b1111:
		return {type = .pushi, instruction = i}, nil
	}

	log.error("invalid stack instruction:", i)
	return {}, .Invalid_Stack_Instruction
}

decode_test_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {

	switch i.second_nibble {
	case 0b0000:
		return {type = .eq, instruction = i}, nil
	case 0b0001:
		return {type = .neq, instruction = i}, nil
	case 0b0010:
		return {type = .gt, instruction = i}, nil
	case 0b0011:
		return {type = .gte, instruction = i}, nil
	case 0b0100:
		return {type = .lt, instruction = i}, nil
	case 0b0101:
		return {type = .lte, instruction = i}, nil
	case 0b1000:
		return {type = .eqi, instruction = i}, nil
	case 0b1001:
		return {type = .neqi, instruction = i}, nil
	case 0b1010:
		return {type = .gti, instruction = i}, nil
	case 0b1011:
		return {type = .gtei, instruction = i}, nil
	case 0b1100:
		return {type = .lti, instruction = i}, nil
	case 0b1101:
		return {type = .ltei, instruction = i}, nil
	}

	log.error("invalid test instruction:", i)
	return {}, .Invalid_Test_Instruction
}

decode_load_store_register_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	op := i.first_nibble & 0b11

	switch op {
	case 0b00:
		return {type = .lwr, instruction = i}, nil
	case 0b01:
		return {type = .lbr, instruction = i}, nil
	case 0b10:
		return {type = .swr, instruction = i}, nil
	case 0b11:
		return {type = .lbr, instruction = i}, nil
	}

	log.error("invalid load_store_register instruction", i)
	return {}, .Invalid_Load_Store_Register_Instruction
}

decode_load_store_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	op := i.second_nibble

	switch op {
	case 0b0000:
		return {type = .lw, instruction = i}, nil
	case 0b0001:
		return {type = .lwo, instruction = i}, nil
	case 0b0010:
		return {type = .lb, instruction = i}, nil
	case 0b0011:
		return {type = .lbo, instruction = i}, nil
	case 0b0100:
		return {type = .sw, instruction = i}, nil
	case 0b0101:
		return {type = .swo, instruction = i}, nil
	case 0b0110:
		return {type = .sb, instruction = i}, nil
	case 0b0111:
		return {type = .sbo, instruction = i}, nil
	case 0b1000:
		return {type = .li, instruction = i}, nil
	}

	log.error("invalid load_store instruction", i)
	return {}, .Invalid_Load_Store_Instruction
}

decode_jump_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	op := i.first_nibble

	switch op {
	case 0b0000:
		return {type = .j, instruction = i}, nil
	case 0b0001:
		return {type = .jz, instruction = i}, nil
	case 0b0010:
		return {type = .jnz, instruction = i}, nil
	case 0b0011:
		return {type = .jal, instruction = i}, nil
	}

	log.error("invalid jump instruction", i)
	return {}, .Invalid_Jump_Instruction
}

decode_instruction :: proc(
	instruction_bytes: u16,
) -> (
	inst: Decoded_Instruction,
	err: Computer_Error,
) {
	instruction := cast(Instruction)instruction_bytes

	switch instruction.first_nibble {
	// misc
	case 0x0:
	case 0x1:
		return decode_ALU_instruction(instruction) or_return, nil
	case 0x2:
		return decode_stack_instruction(instruction) or_return, nil
	case 0x3:
		return decode_test_instruction(instruction) or_return, nil
	// load/store register
	case 0x4 ..= 0x7:
		return decode_load_store_register_instruction(instruction) or_return, nil
	// load/store
	case 0x8:
		return decode_load_store_instruction(instruction) or_return, nil
	// jump register
	case 0x9:
		return {type = .jr, instruction = instruction}, nil
	//jump
	case 0xC ..= 0xF:
		return decode_jump_instruction(instruction) or_return, nil
	}

	log.errorf("expected a valid instruction, got: %b", instruction_bytes)
	return {}, .Invalid_Top_Nibble
}

check_overflow :: proc(
	first_operand: i16,
	second_operand: i16,
	op: ALU_Instruction,
) -> (
	bool,
	Execution_Error,
) {
	f := i128(first_operand)
	s := i128(second_operand)

	evaluation: i128

	#partial switch op {
	case .add:
		evaluation = f + s
	case .sub:
		evaluation = f + s
	case .mul:
		evaluation = f * s
	case .div:
		evaluation = f / s
	case .mod:
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

	c.overflow_flag = check_overflow(first_operand, second_operand, .mul) or_return

	c.Registers[assignment_register] = first_operand * second_operand

	return nil
}

execute_div :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	if i.instruction.fourth_nibble == 0 {
		pc := c.Registers[Register.pc]

		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
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

		c.overflow_flag = check_overflow(first_operand, second_operand, .div) or_return

		c.Registers[assignment_register] = first_operand / second_operand
	}

	return nil
}

execute_mod :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	if i.instruction.fourth_nibble == 0 {
		pc := c.Registers[Register.pc]

		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
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


execute_immediate_ALU_operation :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	assignment_register := i.instruction.third_nibble

	first_operand := c.Registers[i.instruction.third_nibble]
	op_nibble := i.instruction.fourth_nibble

	op := cast(ALU_Instruction)op_nibble

	pc := c.Registers[Register.pc]

	raw := u16(c.Memory[pc + 2]) << 8 | u16(c.Memory[pc + 3])
	next_word := i16(raw)

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
		if next_word == 0 {
			c.overflow_flag = true
			return nil
		}
		check_overflow(first_operand, next_word, .div) or_return
		c.Registers[assignment_register] = first_operand / next_word
		return nil
	case .mod:
		if next_word == 0 {
			c.overflow_flag = true
			return nil
		}
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
		c.Registers[assignment_register] = max(first_operand, next_word)
		return nil
	case .not, .lnot, .neg:
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = pc,
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf(
					"unary operations in immediate mode are invalid: %v",
					i,
				),
			},
		)
		return nil
	case .imm:
		log.errorf("invalid op in imm instruction, got: %b", op)
		return .Invalid_Operation_In_Immediate_Mode_ALU_Instruction
	}

	log.error("invalid immediate mode ALU instruction:", i)
	return .Invalid_Operation_In_Immediate_Mode_ALU_Instruction
}


execute_ALU_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
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
	case .lnot:
		execute_logical_not(c, i)
		return nil
	case .neg:
		execute_negate(c, i)
		return nil
	case .imm:
		execute_immediate_ALU_operation(c, i)
		return nil
	}

	log.error("invalid ALU instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_push :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	c.Registers[sp] += -2

	operand := c.Registers[i.instruction.third_nibble]

	push_word_at_stack_address(c, sp, operand, 0)
}

execute_pop :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble
	assignment_register := i.instruction.third_nibble

	c.Registers[assignment_register] = read_word_at_stack_address(c, sp, 0)

	c.Registers[sp] += 2
}

execute_dup :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	top_word := read_word_at_stack_address(c, u16(c.Registers[sp]), 0)

	c.Registers[sp] += -2

	new_sp := c.Registers[sp]

	push_word_at_stack_address(c, u16(new_sp), top_word, 0)
}

execute_swap :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	if c.Registers[sp] + 2 > len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("swap operation read memory that was out of bounds"),
			},
		)

		return
	}

	temp := read_word_at_stack_address(c, sp, 0)
	bottom_word := (c.Registers[sp + 1] << 8) | c.Registers[sp + 2]

	push_word_at_stack_address(c, sp, i16(bottom_word), 0)

	push_word_at_stack_address(c, sp + 2, temp, 0)
}

execute_drop :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	c.Registers[Register.sp] += 2
}

execute_over :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	if c.Registers[sp] + 2 > len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("over operation read memory that was out of bounds"),
			},
		)

		return
	}

	over_copy := read_word_at_stack_address(c, sp + 2, 0)

	c.Registers[sp] += -2
	new_sp := c.Registers[sp]

	push_word_at_stack_address(c, sp, over_copy, 0)
}

execute_rot :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := i.instruction.fourth_nibble

	if c.Registers[sp] + 4 > len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("rot operation read memory that was out of bounds"),
			},
		)

		return
	}

	temp := read_word_at_stack_address(c, sp + 4, 0)

	push_word_at_stack_address(c, sp + 4, read_word_at_stack_address(c, sp + 2, 0), 0)
	push_word_at_stack_address(c, sp + 2, read_word_at_stack_address(c, sp, 0), 0)
	push_word_at_stack_address(c, sp, temp, 0)
}

execute_sop :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	sp := i.instruction.fourth_nibble
	op := i.instruction.third_nibble

	if c.Registers[sp] + 2 > len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("sop operation read memory that was out of bounds"),
			},
		)

		return nil
	}

	first_operand := read_word_at_stack_address(c, sp, 0)
	second_operand := read_word_at_stack_address(c, sp + 2, 0)

	switch op {
	// add
	case 0b0000:
		check_overflow(first_operand, second_operand, .add) or_return
		push_word_at_stack_address(c, sp, first_operand + second_operand, 0)
		return nil
	//sub
	case 0b0001:
		check_overflow(first_operand, second_operand, .sub) or_return
		push_word_at_stack_address(c, sp, first_operand - second_operand, 0)
		return nil
	// mul
	case 0b0010:
		check_overflow(first_operand, second_operand, .mul) or_return
		push_word_at_stack_address(c, sp, first_operand * second_operand, 0)
		return nil
	// div
	case 0b0011:
		check_overflow(first_operand, second_operand, .div) or_return
		push_word_at_stack_address(c, sp, first_operand / second_operand, 0)
		return nil
	// mod
	case 0b0100:
		check_overflow(first_operand, second_operand, .mod) or_return
		push_word_at_stack_address(c, sp, first_operand % second_operand, 0)
		return nil
	// add
	case 0b0101:
		push_word_at_stack_address(c, sp, first_operand & second_operand, 0)
		return nil
	// or
	case 0b0110:
		push_word_at_stack_address(c, sp, first_operand | second_operand, 0)
		return nil
	// xor
	case 0b0111:
		push_word_at_stack_address(c, sp, first_operand ~ second_operand, 0)
		return nil
	// shl
	case 0b1000:
		push_word_at_stack_address(c, sp, first_operand << u16(second_operand), 0)
		return nil
	// shr
	case 0b1001:
		push_word_at_stack_address(c, sp, first_operand >> u16(second_operand), 0)
		return nil
	// min
	case 0b1010:
		push_word_at_stack_address(c, sp, min(first_operand, second_operand), 0)
		return nil
	// max
	case 0b1011:
		push_word_at_stack_address(c, sp, max(first_operand, second_operand), 0)
		return nil
	// not
	case 0b1100:
		push_word_at_stack_address(c, sp, ~first_operand, 0)
		return nil
	// lnot
	case 0b1101:
		value := 0
		if first_operand == 0 {
			value = 1
		}
		push_word_at_stack_address(c, sp, i16(value), 0)
		return nil
	// neg
	case 0b1110:
		push_word_at_stack_address(c, sp, -first_operand, 0)
		return nil
	// imm
	case 0b1111:
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("invalid sop operator imm"),
			},
		)
		return nil

	}

	log.error("failed to exectue sop:", i)
	return .Failed_To_Execute_Instruction
}

execute_pushi :: proc(c: ^Computer, i: Decoded_Instruction) {
	sp := c.Registers[i.instruction.fourth_nibble]
	pc := c.Registers[Register.pc]

	c.Registers[sp] += -2

	new_sp := c.Registers[sp]

	raw := u16(c.Memory[pc + 2]) << 8 | u16(c.Memory[pc + 3])
	next_word := i16(raw)

	push_word_at_stack_address(c, u16(new_sp), next_word, 0)
}

execute_stack_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .push:
		execute_push(c, i)
		return nil
	case .pop:
		execute_pop(c, i)
		return nil
	case .dup:
		execute_dup(c, i)
		return nil
	case .swap:
		execute_swap(c, i)
		return nil
	case .drop:
		execute_drop(c, i)
		return nil
	case .over:
		execute_over(c, i)
		return nil
	case .rot:
		execute_rot(c, i)
		return nil
	case .sop:
		execute_sop(c, i)
		return nil
	case .pushi:
		execute_pushi(c, i)
		return nil
	}

	log.error("invalid stack instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_eq :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand == second_operand {
		c.test_flag = true
	}
}

execute_neq :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand != second_operand {
		c.test_flag = true
	}
}

execute_gt :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand > second_operand {
		c.test_flag = true
	}
}

execute_gte :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand >= second_operand {
		c.test_flag = true
	}
}

execute_lt :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand < second_operand {
		c.test_flag = true
	}
}

execute_lte :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand <= second_operand {
		c.test_flag = true
	}
}

execute_eqi :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand == second_operand {
		c.test_flag = true
	}
}

execute_neqi :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand != second_operand {
		c.test_flag = true
	}
}

execute_gti :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand > second_operand {
		c.test_flag = true
	}
}

execute_gtei :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand >= second_operand {
		c.test_flag = true
	}
}

execute_lti :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand < second_operand {
		c.test_flag = true
	}
}

execute_ltei :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := read_next_word(c)

	if first_operand <= second_operand {
		c.test_flag = true
	}
}

execute_test_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .eq:
		execute_eq(c, i)
	case .neq:
		execute_neq(c, i)
	case .gt:
		execute_gt(c, i)
	case .gte:
		execute_gte(c, i)
	case .lt:
		execute_lt(c, i)
	case .lte:
		execute_lte(c, i)
	case .eqi:
		execute_eqi(c, i)
	case .neqi:
		execute_neqi(c, i)
	case .gti:
		execute_gti(c, i)
	case .gtei:
		execute_gtei(c, i)
	case .lti:
		execute_lti(c, i)
	case .ltei:
		execute_ltei(c, i)
	}
	log.error("invalid test instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_load_store_register_instruction :: proc(
	c: ^Computer,
	i: Decoded_Instruction,
) -> Execution_Error {

	log.error("invalid load_store_register instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	// TODO: Implement rest
	#partial switch v in i.type {
	case ALU_Instruction:
		execute_ALU_instruction(c, i) or_return
		return nil
	case Stack_Instruction:
		execute_stack_instruction(c, i) or_return
		return nil
	case Test_Instruction:
		execute_test_instruction(c, i) or_return
		return nil
	case Load_Store_Register_Instruction:
		execute_load_store_register_instruction(c, i) or_return
		return nil

	}

	log.error("failed to execute instruction:", i)
	return .Failed_To_Execute_Instruction
}
