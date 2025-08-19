package computer

import "core:fmt"
import "core:log"

match_register :: proc(register_as_byte: u8) -> (User_Facing_Registers, Error) {
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

	case:
		log.error(
			"invalid register index: as bytes=%b, as hex=%x, as decimal=%d",
			register_as_byte,
			register_as_byte,
			register_as_byte,
		)
		return .t0, .Invalid_Encoding_Of_Register_Index
	}

	return .t0, .Failed
}

get_register_value :: proc(c: ^Computer, r: User_Facing_Registers) -> i16 {
	return c.Registers[r]
}

set_register_value :: proc(c: ^Computer, r: User_Facing_Registers, value: i16) {
	c.Registers[r] = value
}

decode_alu_instruction :: proc(i: Instruction) -> (inst: Decoded_Instruction, err: Error) {
	first_operand := match_register(i.third_nibble) or_return
	second_operand := match_register(i.fourth_nibble) or_return

	fmt.println(i)

	switch i.second_nibble {
	case 0b0000:
		return Decoded_Binary_Instruction {
				operation = .add,
				first_operand = first_operand,
				second_operand = second_operand,
			},
			nil

	case 0b0001:
		return Decoded_Binary_Instruction {
				operation = .sub,
				first_operand = first_operand,
				second_operand = second_operand,
			},
			nil


	// NOTE: need to handle 2 word thing here. Meaning that it needs to not treat the fourth nibble as a register
	// imm
	case:
		log.errorf("invalid instruction: %b", i.second_nibble)
		return {}, .Invalid_Alu_Instruction
	}

	return {}, .Failed
}

decode_instruction :: proc(instruction_bytes: u16) -> (inst: Decoded_Instruction, err: Error) {
	instruction := cast(Instruction)instruction_bytes

	fmt.println("wtf?", instruction)

	switch instruction.first_nibble {
	case 0x0:
	// misc
	case 0x1:
		return decode_alu_instruction(instruction) or_return, nil
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

	return {}, .Failed
}


execute_binary_add :: proc(c: ^Computer, i: Decoded_Binary_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) + get_register_value(c, i.second_operand)
}

execute_binary_sub :: proc(c: ^Computer, i: Decoded_Binary_Instruction) {
	c.Registers[i.first_operand] =
		get_register_value(c, i.first_operand) - get_register_value(c, i.second_operand)
}

execute_binary_instruction :: proc(c: ^Computer, instruction: Decoded_Instruction) -> Error {
	switch v in instruction {
	case Decoded_Binary_Instruction:
		#partial switch v.operation {
		case .add:
			execute_binary_add(c, v)
			return nil
		case .sub:
			execute_binary_sub(c, v)
			return nil
		}
	case Decoded_Unary_Instruction:
	case Decoded_Two_Word_Instruction:
	}
	return .Failed
}

execute_instruction :: proc(c: ^Computer, instruction: Decoded_Instruction) -> Error {
	switch v in instruction {
	case Decoded_Binary_Instruction:
		execute_binary_instruction(c, instruction) or_return
		return nil

	case Decoded_Unary_Instruction:
	case Decoded_Two_Word_Instruction:
	case:
		log.error("decoded instruction was invalid, got:", instruction)
		return .Invalid_Decoded_Instruction
	}

	return .Failed
}
