package computer

import "core:fmt"
import "core:log"
import "core:os"

POSITIVE_OVERFLOW :: 32767
NEGATIVE_OVERFLOW :: -32768

init_computer :: proc(allocator := context.allocator) -> Computer {
	errors := make([dynamic]Debug_Error_Info, allocator)
	c := Computer {
		error_info = errors,
	}

	// NOTE: sp starts OOB then decrements by two bytes for each push
	c.Registers[Register.sp] = len(c.Memory)
	return c
}

shutdown_computer :: proc(c: ^Computer) {
	for s in c.error_info {
		delete(s.error_message)
	}

	delete(c.error_info)

	os.exit(0)
}

read_next_word :: proc(c: ^Computer) -> i16 {
	pc := c.Registers[Register.pc]

	if pc + 2 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to read word out-of-bounds"),
			},
		)

		return 0
	}

	first_byte := c.Memory[pc + 2]
	second_byte := c.Memory[pc + 3]

	word := ((u16(first_byte) << 8) | u16(second_byte))

	return i16(word)
}

read_next_byte :: proc(c: ^Computer) -> u8 {
	pc := c.Registers[Register.pc]

	if pc + 1 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to read byte out-of-bounds"),
			},
		)

		return 0
	}

	byte := c.Memory[pc + 2]

	return byte
}

write_next_word :: proc(c: ^Computer, value: i16, pc_offset: i16) {
	pc := c.Registers[Register.pc] + pc_offset

	if pc + 2 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to write word out-of-bounds"),
			},
		)

		return
	}

	raw := u16(value)

	c.Memory[pc] = u8(raw >> 8)
	c.Memory[pc + 1] = u8(raw)
}

check_is_odd :: proc(value: u16) -> bool {
	return value % 2 == 0
}

set_word_at_memory_address :: proc(c: ^Computer, address: u16, value: i16, offset: i16) {
	first_byte := u8(value >> 8)
	second_byte := u8(value)

	new_address := i16(address) + offset

	if new_address + 1 >= len(c.Memory) || new_address < 0 {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to write word out-of-bounds"),
			},
		)

		return
	}

	c.Memory[i16(address) + offset] = first_byte
	c.Memory[i16(address) + 1 + offset] = second_byte
}

set_byte_at_memory_address :: proc(c: ^Computer, address: u16, value: i16, offset: i16) {
	first_byte := u8(value)

	if (i16(address) + offset) >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to write byte out-of-bounds"),
			},
		)

		return
	}

	c.Memory[i16(address) + offset] = first_byte
}

read_word_at_memory_address :: proc(c: ^Computer, address: u16, offset: i16) -> i16 {
	if i16(address) + 1 + offset > len(c.Memory) || i16(address) + 1 + offset < 0 {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to read word out-of-bounds"),
			},
		)

		return 0
	}

	first_byte := c.Memory[i16(address) + offset]
	second_byte := c.Memory[i16(address) + offset + 1]

	word := (u16(first_byte) << 8) | u16(second_byte)

	return i16(word)
}

read_byte_at_memory_address :: proc(c: ^Computer, address: u16, offset: i16) -> u8 {
	if i16(address) + offset > len(c.Memory) || i16(address) + offset < 0 {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("tried to read byte out-of-bounds"),
			},
		)

		return 0
	}
	return c.Memory[i16(address) + offset]
}

push_word_at_stack_address :: proc(c: ^Computer, index_of_sp: u16, value: i16, sp_offset: i16) {
	if !check_is_odd(u16(sp_offset)) {
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


	offset_pointer_address(c, i16(index_of_sp), -2)

	sp := c.Registers[index_of_sp]

	first_byte := u8(value >> 8)
	second_byte := u8(value)

	c.Memory[sp + sp_offset] = first_byte
	c.Memory[sp + sp_offset + 1] = second_byte
}

decode_misc_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	op := i.second_nibble

	switch op {
	case 0b0000:
		return {type = .sys, instruction = i}, nil
	case 0b0001:
		return {type = .mov, instruction = i}, nil
	case 0b0010:
		return {type = .inc, instruction = i}, nil
	case 0b0011:
		return {type = .dec, instruction = i}, nil
	case 0b0100:
		return {type = .seti, instruction = i}, nil
	case 0b0101:
		return {type = .mcp, instruction = i}, nil
	case 0b1000:
		return {type = .debug, instruction = i}, nil
	case 0b1111:
		return {type = .nop, instruction = i}, nil
	}

	log.errorf("invalid misc instruction: %b", i)
	return {}, .Invalid_Misc_Instruction
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

	log.errorf("invalid ALU instruction: %b", i)
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

	log.errorf("invalid stack instruction: %b", i)
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

	log.errorf("invalid test instruction: %b", i)
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
		return {type = .sbr, instruction = i}, nil
	}

	log.errorf("invalid load_store_register instruction: %b", i)
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
	case 0b1111:
		return {type = .li, instruction = i}, nil
	}

	log.errorf("invalid load_store instruction: %b", i)
	return {}, .Invalid_Load_Store_Instruction
}

decode_jump_instruction :: proc(
	i: Instruction,
) -> (
	Decoded_Instruction,
	Instruction_Decoding_Error,
) {
	op := i.first_nibble & 0b11

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

	log.errorf("invalid jump instruction: %b", i)
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
	case 0x0:
		return decode_misc_instruction(instruction) or_return, nil
	case 0x1:
		return decode_ALU_instruction(instruction) or_return, nil
	case 0x2:
		return decode_stack_instruction(instruction) or_return, nil
	case 0x3:
		return decode_test_instruction(instruction) or_return, nil
	case 0x4 ..= 0x7:
		return decode_load_store_register_instruction(instruction) or_return, nil
	case 0x8:
		return decode_load_store_instruction(instruction) or_return, nil
	case 0x9:
		return {type = .jr, instruction = instruction}, nil
	case 0xC ..= 0xF:
		return decode_jump_instruction(instruction) or_return, nil
	}

	log.errorf("expected a valid instruction, got: %b", instruction_bytes)
	return {}, .Invalid_Top_Nibble
}

execute_syscall :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	third_nibble := i.instruction.third_nibble
	fourth_nibble := i.instruction.fourth_nibble
	syscall_code := (third_nibble << 8) | fourth_nibble

	// TODO: implement the syscalls, pull the stuff from the stack or the argument registers as needed etc...
	log.error("most syscalls aren't implemented right now")
	switch syscall_code {
	case 0x0:
		// syscall_exit(c, i)
		return nil
	case 0x1:
		// syscall_rint(c, i)
		return nil
	case 0x2:
		// syscall_wint(c, i)
		return nil
	case 0x3:
		// syscall_rstr(c, i)
		return nil
	case 0x4:
		// syscall_wchr(c, i)
		return nil
	case 0x5:
		// syscall_rchr(c, i)
		return nil
	case 0x6:
		// syscall_wstr(c, i)
		return nil
	case 0x7:
		// syscall_printf(c, i)
		return nil
	case 0x8:
		// syscall_atoi(c, i)
		return nil
	case 0x10:
		// syscall_rfile(c, i)
		return nil
	case 0x11:
		// syscall_wfile(c, i)
		return nil
	case 0x12:
		// cwd(c, i)
		return nil
	case 0x13:
		// syscall_chdir(c, i)
		return nil
	case 0x14:
		// syscall_dirent(c, i)
		return nil
	case 0x15:
		// syscall_dfile(c, i)
		return nil
	case 0x20:
		// syscall_rnd(c, i)
		return nil
	case 0x21:
		// syscall_sleep(c, i)
		return nil
	case 0x22:
		// syscall_timer(c, i)
		return nil
	case 0x30:
		// syscall_fbreset(c, i)
		return nil
	case 0x31:
		// syscall_fbstat(c, i)
		return nil
	case 0x32:
		// syscall_fbset(c, i)
		return nil
	case 0x33:
		// syscall_fbline(c, i)
		return nil
	case 0x34:
		// syscall_fbrect(c, i)
		return nil
	case 0x35:
		// syscall_fbflush(c, i)
		return nil
	case 0x3A:
		// syscall_joystick(c, i)
		return nil
	case 0x3B:
		// syscall_scolor(c, i)
		return nil
	case 0x40:
		// syscall_memcpy(c, i)
		return nil
	case 0x50:
		// syscall_drawing(c, i)
		return nil
	case 0xFF:
		// syscall_error(c, i)
		return nil
	}

	log.error("invalid syscall code:", syscall_code)
	return .Invalid_Syscall_Code
}

execute_mov :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	value := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = value
}

execute_inc :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	value := i.instruction.fourth_nibble

	c.Registers[assignment_register] += i16(value)
}

execute_dec :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	value := i.instruction.fourth_nibble

	c.Registers[assignment_register] += -i16(value)
}

execute_seti :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	value := i.instruction.fourth_nibble

	c.Registers[assignment_register] = i16(value)
}

execute_mcp :: proc(c: ^Computer, i: Decoded_Instruction) {
	// execute_memcpy(c, i)
}

execute_debug :: proc(c: ^Computer, i: Decoded_Instruction) {
	// execute_printf(c, i)
}

execute_nop :: proc(c: ^Computer, i: Decoded_Instruction) {
	// empty op
}

execute_misc_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .sys:
		execute_syscall(c, i)
		return nil
	case .mov:
		execute_mov(c, i)
		return nil
	case .inc:
		execute_inc(c, i)
		return nil
	case .dec:
		execute_dec(c, i)
		return nil
	case .seti:
		execute_seti(c, i)
		return nil
	case .mcp:
		execute_mcp(c, i)
		return nil
	case .debug:
		execute_debug(c, i)
		return nil
	case .nop:
		execute_nop(c, i)
		return nil
	}

	log.error("invalid misc instruction:", i)
	return .Failed_To_Execute_Instruction
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
		return false, .Invalid_Overflow_Check
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

		c.nan_flag = true
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

		c.nan_flag = true
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

	next_word := read_next_word(c)

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
			pc := c.Registers[Register.pc]

			c.nan_flag = true
			return nil
		}
		c.overflow_flag = check_overflow(first_operand, next_word, .mul) or_return
		c.Registers[assignment_register] = first_operand / next_word
		return nil
	case .mod:
		if next_word == 0 {
			pc := c.Registers[Register.pc]

			c.nan_flag = true
			return nil
		}
		c.overflow_flag = check_overflow(first_operand, next_word, .mul) or_return
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
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = pc,
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf(
					"immediate mode operation inside of another immediate mode operation isn't valid: %v",
					i,
				),
			},
		)
		return nil
	}

	log.error("invalid immediate mode ALU instruction:", i)
	return .Invalid_Operation
}

execute_ALU_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	// NOTE: reseting flags numerical flags here
	// TODO: Figure out where to set the flags, probably not here?
	c.nan_flag = false
	c.overflow_flag = false

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

offset_pointer_address :: proc(
	c: ^Computer,
	register_file_index: i16,
	offset: i16,
) -> Execution_Error {
	// TODO: we might not want this to error return an error?
	if register_file_index > 20 || register_file_index < 0 {
		log.error("invalid register_file_index", register_file_index)
		return .Failed_To_Execute_Instruction
	}

	// TODO: we might not want this to error return an error?
	if c.Registers[register_file_index] + offset > len(c.Memory) ||
	   c.Registers[register_file_index] + offset < 0 {
		log.errorf(
			"pointer offset causes out-of-bounds read, address->%v, offset: %v, we only have 4096 bytes of memory",
			c.Registers[register_file_index],
			offset,
		)
		return .Failed_To_Execute_Instruction
	}

	c.Registers[register_file_index] += offset
	return nil
}

execute_push :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	index_of_sp := i.instruction.fourth_nibble
	sp := c.Registers[index_of_sp]

	operand := c.Registers[i.instruction.third_nibble]

	push_word_at_stack_address(c, u16(index_of_sp), operand, 0)

	return nil
}

execute_pop :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	index_of_sp := i.instruction.fourth_nibble
	assignment_register := i.instruction.third_nibble

	sp := c.Registers[index_of_sp]

	c.Registers[assignment_register] = read_word_at_memory_address(c, u16(sp), 0)

	offset_pointer_address(c, i16(index_of_sp), +2) or_return

	return nil
}

execute_dup :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	index_of_sp := i.instruction.fourth_nibble
	sp := c.Registers[index_of_sp]

	top_word := read_word_at_memory_address(c, u16(sp), 0)

	push_word_at_stack_address(c, u16(index_of_sp), top_word, 0)

	return nil
}

execute_swap :: proc(c: ^Computer, i: Decoded_Instruction) {
	index_of_sp := i.instruction.fourth_nibble
	sp_value := c.Registers[index_of_sp]

	if c.Registers[index_of_sp] + 2 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("swap operation read memory that was out-of-bounds"),
			},
		)

		return
	}

	temp := read_word_at_memory_address(c, u16(sp_value), 0)
	value := read_word_at_memory_address(c, u16(sp_value), 2)

	set_word_at_memory_address(c, u16(sp_value), value, 0)
	set_word_at_memory_address(c, u16(sp_value), temp, 2)
}

execute_drop :: proc(c: ^Computer, i: Decoded_Instruction) {
	index_of_sp := i.instruction.fourth_nibble

	offset_pointer_address(c, i16(index_of_sp), 2)
}

execute_over :: proc(c: ^Computer, i: Decoded_Instruction) {
	index_of_sp := i.instruction.fourth_nibble
	sp_value := c.Registers[index_of_sp]

	if sp_value + 2 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("over operation read memory that was out-of-bounds"),
			},
		)

		return
	}

	over_copy := read_word_at_memory_address(c, u16(sp_value), 2)

	push_word_at_stack_address(c, u16(index_of_sp), over_copy, 0)
}

execute_rot :: proc(c: ^Computer, i: Decoded_Instruction) {
	index_of_sp := i.instruction.fourth_nibble
	sp_value := c.Registers[index_of_sp]

	if c.Registers[index_of_sp] + 4 > len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("rot operation read memory that was out-of-bounds"),
			},
		)

		return
	}

	temp := read_word_at_memory_address(c, u16(sp_value), 4)
	next_word := read_word_at_memory_address(c, u16(sp_value), 2)
	top_word := read_word_at_memory_address(c, u16(sp_value), 0)

	set_word_at_memory_address(c, u16(index_of_sp), temp, 0)
	set_word_at_memory_address(c, u16(index_of_sp), top_word, 2)
	set_word_at_memory_address(c, u16(index_of_sp), next_word, 4)
}

execute_sop :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	index_of_sp := i.instruction.fourth_nibble
	sp_value := c.Registers[index_of_sp]
	op := c.Registers[i.instruction.third_nibble]

	c.nan_flag = false
	c.overflow_flag = false

	if c.Registers[index_of_sp] + 2 >= len(c.Memory) {
		c.error_flag = true
		append(
			&c.error_info,
			Debug_Error_Info {
				pc = c.Registers[Register.pc],
				sp = c.Registers[Register.sp],
				error_message = fmt.aprintf("sop operation read memory that was out-of-bounds"),
			},
		)

		return nil
	}

	first_operand := read_word_at_memory_address(c, u16(sp_value), 0)
	second_operand := read_word_at_memory_address(c, u16(sp_value), 2)


	switch op {
	// add
	case 0b0000:
		c.overflow_flag = check_overflow(first_operand, second_operand, .add) or_return
		push_word_at_stack_address(c, u16(index_of_sp), first_operand + second_operand, 0)
		return nil
	//sub
	case 0b0001:
		c.overflow_flag = check_overflow(first_operand, second_operand, .sub) or_return
		push_word_at_stack_address(c, u16(index_of_sp), first_operand - second_operand, 0)
		return nil
	// mul
	case 0b0010:
		c.overflow_flag = check_overflow(first_operand, second_operand, .mul) or_return
		push_word_at_stack_address(c, u16(index_of_sp), first_operand * second_operand, 0)
		return nil
	// div
	case 0b0011:
		c.overflow_flag = check_overflow(first_operand, second_operand, .div) or_return
		if second_operand == 0 {
			c.nan_flag = true
		}
		push_word_at_stack_address(c, u16(index_of_sp), first_operand / second_operand, 0)
		return nil
	// mod
	case 0b0100:
		c.overflow_flag = check_overflow(first_operand, second_operand, .mod) or_return
		if second_operand == 0 {
			c.nan_flag = true
		}
		push_word_at_stack_address(c, u16(index_of_sp), first_operand % second_operand, 0)
		return nil
	// add
	case 0b0101:
		push_word_at_stack_address(c, u16(index_of_sp), first_operand & second_operand, 0)
		return nil
	// or
	case 0b0110:
		push_word_at_stack_address(c, u16(index_of_sp), first_operand | second_operand, 0)
		return nil
	// xor
	case 0b0111:
		push_word_at_stack_address(c, u16(index_of_sp), first_operand ~ second_operand, 0)
		return nil
	// shl
	case 0b1000:
		push_word_at_stack_address(c, u16(index_of_sp), first_operand << u16(second_operand), 0)
		return nil
	// shr
	case 0b1001:
		push_word_at_stack_address(c, u16(index_of_sp), first_operand >> u16(second_operand), 0)
		return nil
	// min
	case 0b1010:
		push_word_at_stack_address(c, u16(index_of_sp), min(first_operand, second_operand), 0)
		return nil
	// max
	case 0b1011:
		push_word_at_stack_address(c, u16(index_of_sp), max(first_operand, second_operand), 0)
		return nil
	// not
	case 0b1100:
		push_word_at_stack_address(c, u16(index_of_sp), ~first_operand, 0)
		return nil
	// lnot
	case 0b1101:
		value := 0
		if first_operand == 0 {
			value = 1
		}
		push_word_at_stack_address(c, u16(index_of_sp), i16(value), 0)
		return nil
	// neg
	case 0b1110:
		push_word_at_stack_address(c, u16(index_of_sp), -first_operand, 0)
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
	index_of_sp := i.instruction.fourth_nibble
	sp_value := c.Registers[i.instruction.fourth_nibble]
	pc := c.Registers[Register.pc]

	next_word := read_word_at_memory_address(c, u16(pc), 2)

	push_word_at_stack_address(c, u16(index_of_sp), next_word, 0)
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
	} else {
		c.test_flag = false
	}
}

execute_neq :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand != second_operand {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_gt :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand > second_operand {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_gte :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand >= second_operand {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_lt :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand < second_operand {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_lte :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := c.Registers[i.instruction.fourth_nibble]

	if first_operand <= second_operand {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_eqi :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand == i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_neqi :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand != i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}
}

execute_gti :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand > i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}

}

execute_gtei :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand >= i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}

}

execute_lti :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand < i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}

}

execute_ltei :: proc(c: ^Computer, i: Decoded_Instruction) {
	first_operand := c.Registers[i.instruction.third_nibble]
	second_operand := i.instruction.fourth_nibble

	if first_operand <= i16(second_operand) {
		c.test_flag = true
	} else {
		c.test_flag = false
	}

}

execute_test_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .eq:
		execute_eq(c, i)
		return nil
	case .neq:
		execute_neq(c, i)
		return nil
	case .gt:
		execute_gt(c, i)
		return nil
	case .gte:
		execute_gte(c, i)
		return nil
	case .lt:
		execute_lt(c, i)
		return nil
	case .lte:
		execute_lte(c, i)
		return nil
	case .eqi:
		execute_eqi(c, i)
		return nil
	case .neqi:
		execute_neqi(c, i)
		return nil
	case .gti:
		execute_gti(c, i)
		return nil
	case .gtei:
		execute_gtei(c, i)
		return nil
	case .lti:
		execute_lti(c, i)
		return nil
	case .ltei:
		execute_ltei(c, i)
		return nil
	}
	log.error("invalid test instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_load_word_register :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.second_nibble
	address := c.Registers[i.instruction.third_nibble]
	offset := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = read_word_at_memory_address(c, u16(address), offset)
}

execute_load_byte_register :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.second_nibble
	address := c.Registers[i.instruction.third_nibble]
	offset := c.Registers[i.instruction.fourth_nibble]

	c.Registers[assignment_register] = i16(read_byte_at_memory_address(c, u16(address), offset))
}

execute_store_word_register :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.second_nibble]
	address := c.Registers[i.instruction.third_nibble]
	offset := c.Registers[i.instruction.fourth_nibble]

	set_word_at_memory_address(c, u16(address), value, offset)
}

execute_store_byte_register :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.second_nibble]
	address := c.Registers[i.instruction.third_nibble]
	offset := c.Registers[i.instruction.fourth_nibble]

	set_byte_at_memory_address(c, u16(address), value, offset)
}

execute_load_store_register_instruction :: proc(
	c: ^Computer,
	i: Decoded_Instruction,
) -> Execution_Error {
	switch i.type {
	case .lwr:
		execute_load_word_register(c, i)
		return nil
	case .lbr:
		execute_load_byte_register(c, i)
		return nil
	case .swr:
		execute_store_word_register(c, i)
		return nil
	case .sbr:
		execute_store_byte_register(c, i)
		return nil
	}

	log.error("invalid load_store_register instruction:", i)
	return .Failed_To_Execute_Instruction
}

// TODO: need to handle dr register book keeping?
execute_load_word_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	next_word := read_next_word(c)

	c.Registers[assignment_register] = next_word
}

execute_load_word_offset_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	offset := c.Registers[i.instruction.fourth_nibble]


	value := read_word_at_memory_address(c, u16(c.Registers[Register.pc]), 2 + offset)

	c.Registers[assignment_register] = value
}

execute_load_byte_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	next_word := read_next_byte(c)

	c.Registers[assignment_register] = i16(next_word)
}

execute_load_byte_offset_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	offset := c.Registers[i.instruction.fourth_nibble]

	value := read_byte_at_memory_address(c, u16(c.Registers[Register.pc]), 2 + offset)

	c.Registers[assignment_register] = i16(value)
}

execute_store_word_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.third_nibble]
	address := read_next_word(c)

	set_word_at_memory_address(c, u16(address), value, 0)
}

execute_store_word_offset_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.third_nibble]
	address := read_next_word(c)
	offset := c.Registers[i.instruction.fourth_nibble]

	set_word_at_memory_address(c, u16(address), value, offset)
}

execute_store_byte_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.third_nibble]
	address := read_next_byte(c)

	set_byte_at_memory_address(c, u16(address), value, 0)
}

execute_store_byte_offset_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	value := c.Registers[i.instruction.third_nibble]
	address := read_next_byte(c)
	offset := c.Registers[i.instruction.fourth_nibble]

	set_byte_at_memory_address(c, u16(address), value, offset)
}


execute_load_immediate_instruction :: proc(c: ^Computer, i: Decoded_Instruction) {
	assignment_register := i.instruction.third_nibble
	value := read_next_word(c)

	c.Registers[assignment_register] = value
}

execute_load_store_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .lw:
		execute_load_word_instruction(c, i)
		return nil
	case .lwo:
		execute_load_word_offset_instruction(c, i)
		return nil
	case .lb:
		execute_load_byte_instruction(c, i)
		return nil
	case .lbo:
		execute_load_byte_offset_instruction(c, i)
		return nil
	case .sw:
		execute_store_word_instruction(c, i)
		return nil
	case .swo:
		execute_store_word_offset_instruction(c, i)
		return nil
	case .sb:
		execute_store_byte_instruction(c, i)
		return nil
	case .sbo:
		execute_store_byte_offset_instruction(c, i)
		return nil
	case .li:
		execute_load_immediate_instruction(c, i)
		return nil
	}

	log.error("invalid load_store instruction:", i)
	return .Failed_To_Execute_Instruction
}

execute_jump_register :: proc(c: ^Computer, i: Decoded_Instruction) {
	jump_to := c.Registers[i.instruction.fourth_nibble]

	c.Registers[Register.pc] = jump_to
}

get_jump_to_from_bottom_three_nibbles :: proc(i: Decoded_Instruction) -> i16 {
	jump_to :=
		i16(i.instruction.second_nibble << 8) |
		i16(i.instruction.third_nibble << 4) |
		i16(i.instruction.fourth_nibble)

	return jump_to
}

execute_jump :: proc(c: ^Computer, i: Decoded_Instruction) {
	jump_to := get_jump_to_from_bottom_three_nibbles(i)
	c.Registers[Register.pc] = jump_to
}

execute_jump_zero :: proc(c: ^Computer, i: Decoded_Instruction) {
	if c.test_flag == false {
		jump_to := get_jump_to_from_bottom_three_nibbles(i)
		c.Registers[Register.pc] = jump_to
	}
}

execute_jump_not_zero :: proc(c: ^Computer, i: Decoded_Instruction) {
	if c.test_flag == true {
		jump_to := get_jump_to_from_bottom_three_nibbles(i)
		c.Registers[Register.pc] = jump_to
	}
}

execute_jump_and_link :: proc(c: ^Computer, i: Decoded_Instruction) {
	jump_to := get_jump_to_from_bottom_three_nibbles(i)

	c.Registers[Register.ra] = c.Registers[Register.pc] + 1
	c.Registers[Register.pc] = jump_to
}

execute_jump_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Execution_Error {
	switch i.type {
	case .j:
		execute_jump(c, i)
		return nil
	case .jz:
		execute_jump_zero(c, i)
		return nil
	case .jnz:
		execute_jump_not_zero(c, i)
		return nil
	case .jal:
		execute_jump_and_link(c, i)
		return nil
	}

	log.error("invalid jump_register instruction:", i)
	return .Failed_To_Execute_Instruction
}

increment_pc :: proc(c: ^Computer, i: Decoded_Instruction) {
	switch i.type {
	case .j, .jr, .jz, .jnz, .jal:
		return
	case .mcp, .imm, .debug, .pushi, .eqi, .neqi, .gti, .gtei, .lti, .ltei:
		c.Registers[Register.pc] += 4
		return
	}

	c.Registers[Register.pc] += 2
}

execute_instruction :: proc(c: ^Computer, i: Decoded_Instruction) -> Computer_Error {
	switch v in i.type {
	case Miscellaneous_Instruction:
		execute_misc_instruction(c, i) or_return
	case ALU_Instruction:
		execute_ALU_instruction(c, i) or_return
	case Stack_Instruction:
		execute_stack_instruction(c, i) or_return
	case Test_Instruction:
		execute_test_instruction(c, i) or_return
	case Load_Store_Register_Instruction:
		execute_load_store_register_instruction(c, i) or_return
	case Load_Store_Instruction:
		execute_load_store_instruction(c, i) or_return
	case Jump_Register_Instruction:
		execute_jump_register(c, i)
	case Jump_Instruction:
		execute_jump_instruction(c, i) or_return
	}

	increment_pc(c, i)

	if len(c.error_info) > 0 || c.error_flag == true {
		return .Runtime_Errors_Occured
	} else {
		return nil
	}

	log.error("failed to execute instruction:", i)
	return .Failed_To_Execute_Instruction
}
