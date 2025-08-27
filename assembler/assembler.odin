package assembler

// TODO: refactor this so that it doesn't use types from the other package
import com "../computer"

import "core:log"
import "core:reflect"
import "core:strconv"
import "core:strings"
import "core:unicode"
import "core:unicode/utf8"


load_binary :: proc(c: ^com.Computer, bin: Binary) -> com.Computer_Error {
	index := 0
	for word in bin.code_section {
		c.Memory[index] = u8(word >> 8)
		index += 1
		c.Memory[index] = u8(word)
		index += 1
	}

	for d in bin.data_section {
		c.Memory[index] = d
		index += 1
	}

	return nil
}

free_tokens :: proc(tokens: ^[dynamic]Token) {
	for t in tokens {
		delete(t.lexeme)
	}

	delete(tokens^)
}

// TODO: This is here because we have a cyclical import because we need to refactor the types from computer package out of this package.
execute_binary :: proc(c: ^com.Computer, bin: Binary) -> com.Computer_Error {
	cb := i16(len(bin.code_section) * 2)

	c.Registers[com.Register.cb] = cb

	for {
		if c.Registers[com.Register.pc] < c.Registers[com.Register.cb] {
			current_instruction := com.read_word_at_memory_address(
				c,
				u16(c.Registers[com.Register.pc]),
				0,
			)


			i := com.decode_instruction(u16(current_instruction)) or_return
			com.execute_instruction(c, i) or_return
		} else do break
	}

	return nil
}


init_parser :: proc(data: []rune) -> Parser {
	assert(len(data) > 0)

	return {data = data, current = data[0], line_number = 1}
}

peek_token :: proc(tp: ^Token_Parser) -> Token {
	if tp.index + 1 < len(tp.data) {
		return tp.data[tp.index + 1]
	}

	return {type = .EOF}
}

eat_token :: proc(tp: ^Token_Parser) {
	if tp.index >= len(tp.data) {
		log.error("eated out-of-bounds")
		return
	}

	tp.index += 1

	if tp.index >= len(tp.data) {
		tp.current = {
			type = .EOF,
		}
		return
	}

	tp.current = tp.data[tp.index]

}

parse_section :: proc(
	tp: ^Token_Parser,
	asm_nodes: ^[dynamic]Asm_Node,
	symbol_table: ^map[string]Label,
	allocator := context.allocator,
) -> (
	sec: Section,
	err: Assembler_Error,
) {
	if tp.current.type != .Directive {
		log.error("current token wasn't a directive", tp.current)
		return {}, .Failed_To_Parse_Section
	}

	if tp.current.lexeme == ".data" {
		s := Section{}
		s.kind = .Data

		labels := make([dynamic]Label)

		if tp.current.type == .Instruction {
			log.error("instructions aren't allowed in the data section")
			return {}, .Unexpected_Token
		}

		eat_token(tp)

		for {
			if tp.current.type == .Unknown {
				append(&labels, parse_label(tp, symbol_table) or_return)
			} else {
				s.labels = labels
				append(asm_nodes, s)
				return s, nil
			}
		}

		return {}, .Failed_To_Parse_Section
	}

	if tp.current.lexeme == ".code" {
		s := Section{}
		s.kind = .Code

		instructions := make([dynamic]Instruction)
		labels := make([dynamic]Label)

		eat_token(tp)

		for {
			if tp.current.type == .Instruction {
				append(&instructions, parse_instruction(tp, symbol_table) or_return)
			}

			if tp.current.type == .Unknown {
				append(&labels, parse_label(tp, symbol_table) or_return)
			}

			if tp.current.type == .EOF {
				s.instruction = instructions
				s.labels = labels
				append(asm_nodes, s)
				return s, nil
			}
		}

		return {}, .Failed_To_Parse_Section
	}

	log.error("directive that wasn't code or data", tp.current)
	return {}, .Failed_To_Parse_Section
}

match_instruction :: proc(t: Token) -> (com.Instruction_Kind, Assembler_Error) {
	if t.type != .Instruction {
		log.error("expected an token to be an instruction, got:", t)
		return nil, .Unexpected_Token
	}
	#partial switch v in t.value {
	case com.Miscellaneous_Instruction:
		return v, nil
	case com.ALU_Instruction:
		return v, nil
	case com.Stack_Instruction:
		return v, nil
	case com.Test_Instruction:
		return v, nil
	case com.Load_Store_Register_Instruction:
		return v, nil
	case com.Load_Store_Instruction:
		return v, nil
	case com.Jump_Register_Instruction:
		return v, nil
	case com.Jump_Instruction:
		return v, nil
	}

	log.error("unmatched instruction in token:", t)
	return {}, .Unexpected_Token
}

match_operand :: proc(t: Token) -> (Operand_Value, Assembler_Error) {
	if t.type != .Register &&
	   t.type != .Immediate_Integer &&
	   t.type != .Immediate_String &&
	   t.type != .Unknown {
		log.error("expected an token to be a valid instruction operand, got:", t)
		return nil, .Unexpected_Token
	}

	#partial switch v in t.value {
	case com.Register:
		return v, nil
	case int:
		return v, nil
	case string:
		return v, nil
	}

	log.error("unmatched instruction in token:", t)
	return {}, .Unexpected_Token
}

parse_instruction :: proc(
	tp: ^Token_Parser,
	symbol_table: ^map[string]Label,
) -> (
	instr: Instruction,
	err: Assembler_Error,
) {
	i := Instruction{}
	i.instruction = match_instruction(tp.current) or_return
	eat_token(tp)

	ops := make([dynamic]Operand)

	_, is_symbol := symbol_table[tp.current.lexeme]


	// TODO: this breaks with syscalls because we are treating syscall names as unknown right now. Maybe we can parse the syscall names before this point?
	if tp.current.type == .Unknown && !is_symbol {
		log.error("expected a valid instruction operand, got:", tp.current)
		return {}, .Unexpected_Token
	}

	for {
		if tp.current.type != .Register &&
		   tp.current.type != .Immediate_Integer &&
		   tp.current.type != .Immediate_String {
			i.operands = ops
			return i, nil
		}

		#partial switch tp.current.type {
		case .Register:
			append(&ops, Operand{type = .Register, value = match_operand(tp.current) or_return})
			eat_token(tp)
			continue

		case .Immediate_Integer:
			append(&ops, Operand{type = .Integer, value = match_operand(tp.current) or_return})
			eat_token(tp)
			continue

		case .Immediate_String:
			append(&ops, Operand{type = .String, value = match_operand(tp.current) or_return})
			eat_token(tp)
			continue

		case .EOF:
			return i, nil

		case:
			log.error("hit invalid operand")
		}
	}

	log.info("instruction:", i)
	log.info("current:", tp.current)

	return i, nil
}

parse_label :: proc(
	tp: ^Token_Parser,
	symbol_table: ^map[string]Label,
	allocator := context.allocator,
) -> (
	Label,
	Assembler_Error,
) {
	if tp.current.type == .Unknown {
		peeked := peek_token(tp)

		size := 0
		if tp.current.type == .Immediate_Integer do size = 2

		if peeked.value == ":" {
			n := strings.clone(tp.current.lexeme)
			eat_token(tp)
			eat_token(tp)

			if tp.current.type != .Instruction &&
			   tp.current.type != .Immediate_String &&
			   tp.current.type != .Immediate_Integer &&
			   tp.current.type != .Unknown {
				log.error(
					"need to implement the other types for labels, also need to handle type directives, got:",
					tp.current,
				)
				return {}, .Unexpected_Token
			}

			thing: Label

			#partial switch tp.current.type {
			case .Immediate_String:
				value := strings.clone(tp.current.lexeme)

				size = len(value) + 1

				thing = Label {
					name       = n,
					address    = tp.current_memory_address,
					value      = value,
					value_size = size,
				}

				symbol_table[n] = thing

				eat_token(tp)

			case .Immediate_Integer:
				thing = Label {
					name       = n,
					address    = tp.current_memory_address,
					value      = tp.current.value.(int),
					value_size = 2,
				}

				size = 2
				symbol_table[n] = thing

				eat_token(tp)

			case .Unknown, .Instruction:
				thing = Label {
					name       = n,
					address    = tp.current_memory_address,
					value_size = 0,
				}
				symbol_table[n] = thing

				size = 0

			case:
				log.error("label value is an invalid type:", thing)
				return {}, .Unexpected_Token
			}


			tp.current_memory_address += size

			return thing, nil
		}

		log.error("expected ':' after ", tp.current)
		return {}, .Unexpected_Token
	}

	return {}, .Failed_To_Parse_Label
}

build_binary :: proc(
	asm_nodes: ^[dynamic]Asm_Node,
	symbol_table: ^map[string]Label,
	allocator := context.allocator,
) -> (
	binary: Binary,
	err: Assembler_Error,
) {
	bin: Binary

	data := make([dynamic]u8)

	code := make([dynamic]u16)

	dummy_computer := com.init_computer()

	for node in asm_nodes {
		#partial switch v in node {
		case Section:
			if v.kind == .Data {
				for label in v.labels {
					if label.value != nil {
						switch v in label.value {
						case string:
							for r in v {
								append(&data, cast(u8)r)
							}
							append(&data, cast(u8)0)

						case int:
							append(&data, u8(v >> 8))
							append(&data, u8(v))

						case []u8:
							log.error("unhandled data_type: ", node, v)

						case []i16:
							log.error("unhandled data_type: ", node, v)
						}

					}
				}
			}

			if v.kind == .Code {
				for i in v.instruction {
					emit_from_AST(&code, i, node) or_return
				}
			}
		}
	}

	bin.data_section = data
	bin.code_section = code

	return bin, nil
}

assemble :: proc(
	computer: ^com.Computer,
	tokens: ^[dynamic]Token,
	allocator := context.allocator,
) -> (
	binary: Binary,
	err: Assembler_Error,
) {
	tp := Token_Parser {
		data    = tokens[:],
		current = tokens[0],
	}

	symbol_table := make(map[string]Label)

	asm_nodes := make([dynamic]Asm_Node)

	for {
		#partial switch tp.current.type {
		case .Directive:
			parse_section(&tp, &asm_nodes, &symbol_table) or_return
		case .Unknown:
			parse_label(&tp, &symbol_table) or_return
		case .EOF:
			return build_binary(&asm_nodes, &symbol_table)
		}
	}

	return {}, .Failed_To_Assemble_Binary
}


tokenize_asm :: proc(
	assembly: string,
	allocator := context.allocator,
) -> (
	toks: [dynamic]Token,
	err: Assembler_Error,
) {
	tokens := make([dynamic]Token)

	c := com.Computer{}

	split_strs := strings.split(assembly, "\n")
	defer delete(split_strs)

	for s in split_strs {
		tokenize_command(&c, &tokens, s) or_return
	}

	return tokens, nil
}

emit_immediate_ALU_instruction :: proc(c: ^com.Computer, tokens: ^[dynamic]Token) -> u16 {
	op := tokens[1]
	register := tokens[2]
	imm := tokens[3]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0001
	byte_code.second_nibble = 0b1111
	byte_code.third_nibble = cast(u16)register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)op.value.(com.ALU_Instruction)

	com.write_next_word(c, i16(imm.value.(int)))
	c.Registers[com.Register.dr] = i16(imm.value.(int))

	return cast(u16)byte_code
}

emit_two_token_ALU_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	first_register := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0001
	byte_code.second_nibble = cast(u16)inst.value.(com.ALU_Instruction)
	byte_code.third_nibble = cast(u16)first_register.value.(com.Register)

	return cast(u16)byte_code
}

emit_three_token_ALU_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	first_register := tokens[1]
	second_register := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0001
	byte_code.second_nibble = cast(u16)inst.value.(com.ALU_Instruction)
	byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)second_register.value.(com.Register)

	return cast(u16)byte_code
}

emit_stack_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = cast(u16)inst.value.(com.Stack_Instruction)
	byte_code.fourth_nibble = 0b1101

	return cast(u16)byte_code
}

emit_push_and_pop_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	register := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = cast(u16)inst.value.(com.Stack_Instruction)
	byte_code.third_nibble = cast(u16)register.value.(com.Register)
	byte_code.fourth_nibble = 0b1101

	return cast(u16)byte_code
}

emit_pushi_instruction :: proc(c: ^com.Computer, tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	imm := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = cast(u16)inst.value.(com.Stack_Instruction)
	byte_code.third_nibble = 0b0000
	byte_code.fourth_nibble = 0b1101

	com.write_next_word(c, i16(imm.value.(int)))
	c.Registers[com.Register.dr] = i16(imm.value.(int))

	return cast(u16)byte_code
}

emit_pushi_instruction_with_sp :: proc(c: ^com.Computer, tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	register := tokens[1]
	imm := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = cast(u16)inst.value.(com.Stack_Instruction)
	byte_code.third_nibble = 0b0000
	byte_code.fourth_nibble = cast(u16)register.value.(com.Register)

	com.write_next_word(c, i16(imm.value.(int)))
	c.Registers[com.Register.dr] = i16(imm.value.(int))

	return cast(u16)byte_code
}

emit_stack_instruction_with_sp :: proc(tokens: ^[dynamic]Token) -> u16 {
	inst := tokens[0]
	register := tokens[1]
	sp := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = cast(u16)inst.value.(com.Stack_Instruction)
	byte_code.third_nibble = cast(u16)register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)sp.value.(com.Register)

	return cast(u16)byte_code
}

emit_stack_ALU_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = 0b0111
	byte_code.third_nibble = cast(u16)op.value.(com.ALU_Instruction)
	byte_code.fourth_nibble = 0b1101

	return cast(u16)byte_code
}

emit_stack_ALU_instruction_with_sp :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[1]
	register := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0010
	byte_code.second_nibble = 0b0111
	byte_code.third_nibble = cast(u16)op.value.(com.ALU_Instruction)
	byte_code.fourth_nibble = cast(u16)register.value.(com.Register)

	return cast(u16)byte_code
}

emit_test_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	first_register := tokens[1]
	second_register := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0011
	byte_code.second_nibble = cast(u16)op.value.(com.Test_Instruction)
	byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)second_register.value.(com.Register)

	return cast(u16)byte_code
}

emit_immediate_test_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	first_register := tokens[1]
	last_nibble := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b0011
	byte_code.second_nibble = cast(u16)op.value.(com.Test_Instruction)
	byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)last_nibble.value.(int)

	return cast(u16)byte_code
}

emit_jump_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0].value.(com.Jump_Instruction)
	address := tokens[1]
	to_int := address.value.(int)

	second_nibble := u16((to_int & 0b111100000000) >> 8)
	third_nibble := u16((to_int & 0b000011110000) >> 4)
	fourth_nibble := u16(to_int & 0b000000001111)

	byte_code: com.Instruction

	// op is not the right thing! need to and it with low bits!
	byte_code.first_nibble = cast(u16)op | 0b1100
	byte_code.second_nibble = second_nibble
	byte_code.third_nibble = third_nibble
	byte_code.fourth_nibble = fourth_nibble

	return cast(u16)byte_code
}

emit_jump_register_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	register := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b1000
	byte_code.fourth_nibble = cast(u16)register.value.(com.Register)

	return cast(u16)byte_code
}

emit_load_store_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	register := tokens[1]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b1000
	byte_code.second_nibble = cast(u16)op.value.(com.Load_Store_Instruction)
	byte_code.third_nibble = cast(u16)register.value.(com.Register)

	return cast(u16)byte_code
}

emit_load_store_offset_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	first_register := tokens[1]
	second_register := tokens[3]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b1000
	byte_code.second_nibble = cast(u16)op.value.(com.Load_Store_Instruction)
	byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)second_register.value.(com.Register)

	return cast(u16)byte_code
}

emit_misc_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	if tokens[0].value == .mov {
		first_register := tokens[1]
		second_register := tokens[2]

		byte_code: com.Instruction

		byte_code.first_nibble = 0b0000
		byte_code.second_nibble = 0b0001
		byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
		byte_code.fourth_nibble = cast(u16)second_register.value.(com.Register)

		return cast(u16)byte_code
	}

	if tokens[0].value == .inc {
		op := tokens[0]
		register := tokens[1]
		int_value := tokens[2]

		byte_code: com.Instruction

		byte_code.first_nibble = 0b0000
		byte_code.second_nibble = cast(u16)op.value.(com.Miscellaneous_Instruction)
		byte_code.third_nibble = cast(u16)register.value.(com.Register)
		byte_code.fourth_nibble = cast(u16)int_value.value.(int)

		return cast(u16)byte_code
	}

	if tokens[0].value == .dec {
		op := tokens[0]
		register := tokens[1]
		int_value := tokens[2]

		byte_code: com.Instruction

		byte_code.first_nibble = 0b0000
		byte_code.second_nibble = cast(u16)op.value.(com.Miscellaneous_Instruction)
		byte_code.third_nibble = cast(u16)register.value.(com.Register)
		byte_code.fourth_nibble = cast(u16)int_value.value.(int)

		return cast(u16)byte_code
	}

	if tokens[0].value == .seti {
		first_register := tokens[1]
		int_value := tokens[2]

		byte_code: com.Instruction

		byte_code.first_nibble = 0b0000
		byte_code.second_nibble = 0b0100
		byte_code.third_nibble = cast(u16)first_register.value.(com.Register)
		byte_code.fourth_nibble = cast(u16)int_value.value.(int)

		return cast(u16)byte_code
	}

	log.error("failed to emit misc instruction")
	return 0
}

emit_load_register_instruction :: proc(tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	first_register := tokens[1]
	second_register := tokens[2]
	third_register := tokens[3]

	byte_code: com.Instruction

	byte_code.first_nibble = cast(u16)op.value.(com.Load_Store_Register_Instruction)
	byte_code.second_nibble = cast(u16)first_register.value.(com.Register)
	byte_code.third_nibble = cast(u16)second_register.value.(com.Register)
	byte_code.fourth_nibble = cast(u16)third_register.value.(com.Register)

	return cast(u16)byte_code
}

emit_immediate_load_store_instruction :: proc(c: ^com.Computer, tokens: ^[dynamic]Token) -> u16 {
	op := tokens[0]
	register := tokens[1]
	imm := tokens[2]

	byte_code: com.Instruction

	byte_code.first_nibble = 0b1000
	byte_code.second_nibble = 0b1111
	byte_code.third_nibble = cast(u16)register.value.(com.Register)
	byte_code.fourth_nibble = 0b0000

	com.write_next_word(c, i16(imm.value.(int)))
	c.Registers[com.Register.dr] = i16(imm.value.(int))

	return cast(u16)byte_code
}

word_or_register :: union {
	com.Register,
	i16,
}

// TODO: this type checking is too restrictive for some of these things. We should write another set of type checking functions that can be used for instructions that take more than on type as input and use them on at a per operand level.
type_check_instruction :: proc(tokens: ^[dynamic]Token, types: ..typeid) -> Assembler_Error {
	if len(types) == 0 || len(tokens) == 0 {
		log.error("expected more arguments")
		return .Bad_Command
	}

	if len(tokens) != len(types) {
		return .Type_Check_Failed
	}

	for expected_type, i in types {
		actual_type := reflect.union_variant_typeid(tokens[i].value)

		if actual_type != expected_type {
			log.errorf(
				"expected typeof(%v) -> %v, at index: %v, got: %v",
				tokens[i].value,
				expected_type,
				i,
				actual_type,
			)
			return .Type_Check_Failed
		}
	}

	return nil
}

emit_from_AST :: proc(
	buf: ^[dynamic]u16,
	i: Instruction,
	node: Asm_Node,
) -> (
	err: Assembler_Error,
) {
	ci: com.Instruction

	#partial switch v in i.instruction {
	case com.ALU_Instruction:
		#partial switch v {
		case .add:
			reg_A := i.operands[0].value.(com.Register)
			reg_B := i.operands[1].value.(com.Register)

			ci.first_nibble = 0b0001
			ci.second_nibble = cast(u16)v
			ci.third_nibble = cast(u16)reg_A
			ci.fourth_nibble = cast(u16)reg_B

			append(buf, cast(u16)ci)

			return nil

		case:
			log.error("unhandled instruction kind:", v, "probably not implemented yet!")
		}

	case com.Load_Store_Instruction:
		#partial switch v {
		case .li:
			reg_A := i.operands[0].value.(com.Register)
			value := i.operands[1].value.(int)

			ci.first_nibble = 0b1000
			ci.second_nibble = cast(u16)v
			ci.third_nibble = cast(u16)reg_A

			append(buf, cast(u16)ci)
			append(buf, cast(u16)value)

			return nil

		case:
			log.error("unhandled instruction kind:", v, "probably not implemented yet!")
		}

	}

	return .Invalid_Instruction
}

// TODO: completely refactor this to parse into an AST then call emit_from_AST!
emit_bytecode :: proc(
	c: ^com.Computer,
	tokens: ^[dynamic]Token,
	allocator := context.allocator,
) -> (
	instruction: u16,
	err: Assembler_Error,
) {
	token_count := len(tokens)

	if token_count == 4 {
		if tokens[0].value == .imm {
			type_check_instruction(
				tokens,
				typeid_of(com.ALU_Instruction),
				typeid_of(com.ALU_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
			) or_return

			return emit_immediate_ALU_instruction(c, tokens), nil
		}

		#partial switch v in tokens[0].value {
		case com.Load_Store_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Load_Store_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
				typeid_of(com.Register),
			) or_return

			return emit_load_store_offset_instruction(tokens), nil

		case com.Load_Store_Register_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Load_Store_Register_Instruction),
				typeid_of(com.Register),
				typeid_of(com.Register),
				typeid_of(com.Register),
			) or_return

			return emit_load_register_instruction(tokens), nil
		}
	}

	if token_count == 3 {
		if tokens[0].type != .Instruction {
			log.error("expected a valid instruction, got:", tokens[0].lexeme)

			return 0, .Invalid_Instruction
		}

		if tokens[0].value == .sop {
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.ALU_Instruction),
				typeid_of(com.Register),
			) or_return

			return emit_stack_ALU_instruction_with_sp(tokens), nil
		}

		if tokens[0].value == .pushi {
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
			) or_return

			return emit_pushi_instruction_with_sp(c, tokens), nil
		}

		if tokens[0].value == .li || tokens[0].value == .la {
			type_check_instruction(
				tokens,
				typeid_of(com.Load_Store_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
			) or_return

			return emit_immediate_load_store_instruction(c, tokens), nil
		}

		#partial switch _ in tokens[0].value {
		case com.ALU_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.ALU_Instruction),
				typeid_of(com.Register),
				typeid_of(com.Register),
			) or_return

			return emit_three_token_ALU_instruction(tokens), nil

		case com.Stack_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.Register),
				typeid_of(com.Register),
			) or_return

			return emit_stack_instruction_with_sp(tokens), nil

		case com.Miscellaneous_Instruction:
			if tokens[0].value == .mov {
				type_check_instruction(
					tokens,
					typeid_of(com.Miscellaneous_Instruction),
					typeid_of(com.Register),
					typeid_of(com.Register),
				) or_return

				return emit_misc_instruction(tokens), nil
			}

			type_check_instruction(
				tokens,
				typeid_of(com.Miscellaneous_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
			) or_return

			return emit_misc_instruction(tokens), nil

		case com.Test_Instruction:
			#partial switch v in tokens[2].value {
			case com.Register:
				type_check_instruction(
					tokens,
					typeid_of(com.Test_Instruction),
					typeid_of(com.Register),
					typeid_of(com.Register),
				) or_return

				return emit_test_instruction(tokens), nil

			case int:
				type_check_instruction(
					tokens,
					typeid_of(com.Test_Instruction),
					typeid_of(com.Register),
					typeid_of(int),
				) or_return

				return emit_immediate_test_instruction(tokens), nil
			}

		case com.Load_Store_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Load_Store_Instruction),
				typeid_of(com.Register),
				typeid_of(int),
			) or_return

			return emit_load_store_instruction(tokens), nil
		}
	}

	if token_count == 2 {
		if tokens[0].value == .push || tokens[0].value == .pop {
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.Register),
			) or_return
			return emit_push_and_pop_instruction(tokens), nil
		}

		if tokens[0].value == .sop {
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.ALU_Instruction),
			) or_return
			return emit_stack_ALU_instruction(tokens), nil
		}

		if tokens[0].value == .pushi {
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(int),
			) or_return

			return emit_pushi_instruction(c, tokens), nil
		}

		#partial switch v in tokens[0].value {
		case com.ALU_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.ALU_Instruction),
				typeid_of(com.Register),
			) or_return
			return emit_two_token_ALU_instruction(tokens), nil

		case com.Stack_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Stack_Instruction),
				typeid_of(com.Register),
			) or_return

			return emit_stack_instruction(tokens), nil

		case com.Jump_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Jump_Instruction),
				typeid_of(int),
			) or_return
			return emit_jump_instruction(tokens), nil
		case com.Jump_Register_Instruction:
			type_check_instruction(
				tokens,
				typeid_of(com.Jump_Register_Instruction),
				typeid_of(com.Register),
			) or_return

			return emit_jump_register_instruction(tokens), nil
		}
	}

	if token_count == 1 {
		#partial switch _ in tokens[0].value {
		case com.Stack_Instruction:
			type_check_instruction(tokens, typeid_of(com.Stack_Instruction)) or_return
			return emit_stack_instruction(tokens), nil
		}
	}

	log.error(tokens)
	return 0, .Invalid_Instruction
}

eat :: proc(p: ^Parser) -> (rune, Assembler_Error) {
	if p.index >= len(p.data) {
		log.error("tried to eat OOB")
		return '0', .Out_Of_Bounds_Read
	}

	r := p.data[p.index]
	p.index += 1

	if p.index < len(p.data) {
		p.current = p.data[p.index]
	} else {
		p.current = utf8.RUNE_EOF
	}

	return r, nil
}

peek :: proc(p: ^Parser, offset := 1) -> (rune, Assembler_Error) {
	if p.index + offset >= len(p.data) {
		return utf8.RUNE_EOF, nil
	}

	r := p.data[p.index + offset]

	return r, nil
}

peek_lexeme :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	str: string,
	err: Assembler_Error,
) {
	arr := make([dynamic]rune)
	defer delete(arr)

	if p.index >= len(p.data) do return

	i := 0
	for {
		peek := peek(p, i) or_return
		if peek == ' ' || peek == utf8.RUNE_EOF {
			str = utf8.runes_to_string(arr[:])
			return str, nil
		}

		if unicode.is_alpha(p.current) || unicode.is_number(p.current) || p.current == '_' {
			append(&arr, peek)
		}

		i += 1
	}

	log.error("failed to peek lexeme", arr)
	return "", .Failed_To_Eat_Lexeme
}

eat_string :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	arr: [dynamic]rune,
	err: Assembler_Error,
) {
	arr = make([dynamic]rune)
	for {
		if p.index >= len(p.data) do return

		if p.current == '"' || p.current == utf8.RUNE_EOF {
			return
		}

		append(&arr, eat(p) or_return)
	}

	log.error("failed to eat string", arr)
	return nil, .Failed_To_Eat_Lexeme
}

eat_line :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	arr: [dynamic]rune,
	err: Assembler_Error,
) {
	arr = make([dynamic]rune)
	for {
		if p.index >= len(p.data) do return

		if p.current == '\n' || p.current == utf8.RUNE_EOF {
			return
		}

		append(&arr, eat(p) or_return)
	}

	log.error("failed to eat line", arr)
	return nil, .Failed_To_Eat_Lexeme
}

eat_directive :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	arr: [dynamic]rune,
	err: Assembler_Error,
) {
	arr = make([dynamic]rune)
	for {
		if p.index > len(p.data) do return

		if unicode.is_alpha(p.current) || unicode.is_number(p.current) || p.current == '.' {
			append(&arr, eat(p) or_return)
		} else {
			return arr, nil
		}
	}

	log.error("failed to eat lexeme", arr)
	return nil, .Failed_To_Eat_Lexeme
}

eat_lexeme :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	arr: [dynamic]rune,
	err: Assembler_Error,
) {
	arr = make([dynamic]rune)
	for {
		if p.index > len(p.data) do return

		if unicode.is_alpha(p.current) || unicode.is_number(p.current) || p.current == '_' {
			append(&arr, eat(p) or_return)
		} else {
			return arr, nil
		}
	}

	log.error("failed to eat lexeme", arr)
	return nil, .Failed_To_Eat_Lexeme
}

eat_number :: proc(
	p: ^Parser,
	allocator := context.allocator,
) -> (
	arr: [dynamic]rune,
	err: Assembler_Error,
) {
	arr = make([dynamic]rune)
	for {
		if p.index >= len(p.data) do return

		if p.current == '-' && len(arr) == 0 {
			append(&arr, eat(p) or_return)
		}

		if unicode.is_number(p.current) ||
		   p.current == 'b' ||
		   p.current == 'x' ||
		   (p.current >= 'A' && p.current <= 'F') {
			append(&arr, eat(p) or_return)
		} else {
			return arr, nil
		}
	}

	log.error("failed to eat lexeme", arr)
	return nil, .Failed_To_Eat_Lexeme
}

tokenize_command :: proc(
	c: ^com.Computer,
	t: ^[dynamic]Token,
	i: string,
) -> (
	err: Assembler_Error,
) {
	if len(i) == 0 do return nil

	rs := utf8.string_to_runes(i)
	defer delete(rs)

	parser := init_parser(rs)
	p := &parser

	line_number := 1

	for {
		if p.current == utf8.RUNE_EOF {
			return
		}

		if p.current == '\n' {
			eat(p) or_return
			line_number += 1
			continue
		}

		if unicode.is_white_space(p.current) {
			eat(p) or_return
			continue
		}

		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		switch p.current {
		// a => add, and
		case 'a':
			if peeked == "add" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .add,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "and" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .and,
						line = p.line_number,
					},
				)
				continue
			}

		// d => dec, div, dup, drop, debug
		case 'd':
			if peeked == "dec" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .dec,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "debug" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .debug,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "div" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .div,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "dup" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .dup,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "drop" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .drop,
						line = p.line_number,
					},
				)
				continue
			}

		// e => eq, eqi
		case 'e':
			if peeked == "eq" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .eq, line = p.line_number},
				)
				continue
			}

			if peeked == "eqi" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .eqi,
						line = p.line_number,
					},
				)
				continue
			}

		// g => gt, gti, gte, gtei
		case 'g':
			if peeked == "gt" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .gt, line = p.line_number},
				)
				continue
			}

			if peeked == "gti" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .gti,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "gte" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .gte,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "gtei" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .gtei,
						line = p.line_number,
					},
				)
				continue
			}

		// i => inc, imm
		case 'i':
			if peeked == "inc" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .inc,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "imm" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .imm,
						line = p.line_number,
					},
				)
				continue
			}

		// j => jr, jz, jnz, jal
		case 'j':
			if peeked == "j" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .j, line = p.line_number},
				)
				continue
			}

			if peeked == "jr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .jr, line = p.line_number},
				)
				continue
			}

			if peeked == "jz" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .jz, line = p.line_number},
				)
				continue
			}

			if peeked == "jnz" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .jnz,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "jal" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .jal,
						line = p.line_number,
					},
				)
				continue
			}


		// l => lnot, lt, lte, lti, ltei, lwr, lbr, lw, lb, lwo, lbo, li, la
		case 'l':
			if peeked == "lnot" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lnot,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "lt" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .lt, line = p.line_number},
				)
				continue
			}

			if peeked == "lte" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lte,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "lti" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lti,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "ltei" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .ltei,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "lwr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lwr,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "lbr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lbr,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "lb" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .lb, line = p.line_number},
				)
				continue
			}
			if peeked == "lw" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .lw, line = p.line_number},
				)
				continue
			}

			if peeked == "lwo" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lwo,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "lbo" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .lbo,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "li" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .li, line = p.line_number},
				)
				continue
			}

			if peeked == "la" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .la, line = p.line_number},
				)
				continue
			}

		// m => mov, mul, mod, min, max, mcp
		case 'm':
			if peeked == "mov" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .mov,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "mul" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .mul,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "mod" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .mod,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "min" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .min,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "max" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .max,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "mcp" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .mcp,
						line = p.line_number,
					},
				)
				continue
			}

		// n => not, neg, nop
		case 'n':
			if peeked == "not" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .not,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "neg" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .neg,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "neq" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .neq,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "neqi" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .neqi,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "nop" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])
				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .nop,
						line = p.line_number,
					},
				)
				continue
			}

		// o => or, over
		case 'o':
			if peeked == "or" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .or, line = p.line_number},
				)
				continue
			}

			if peeked == "over" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .over,
						line = p.line_number,
					},
				)
				continue
			}

		// p => push, pop, pushi
		case 'p':
			if peeked == "push" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .push,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "pushi" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .pushi,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "pop" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .pop,
						line = p.line_number,
					},
				)
				continue
			}

		// r => rot, ret
		case 'r':
			if peeked == "rot" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .rot,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "ret" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .ret,
						line = p.line_number,
					},
				)
				continue
			}

		// s => seti, sub, shl, shr, swap, sop, swr, sbr, sw, swo, sb, sbo, sys
		case 's':
			if peeked == "seti" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)

				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .seti,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "sub" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .sub,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "shl" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .shl,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "shr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .shr,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "swap" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .swap,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "sop" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .sop,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "swr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .swr,
						line = p.line_number,
					},
				)
				continue
			}
			if peeked == "sbr" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .sbr,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "sw" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .sw, line = p.line_number},
				)
				continue
			}

			if peeked == "swo" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .swo,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "sb" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Instruction, lexeme = lexeme, value = .sb, line = p.line_number},
				)
				continue
			}

			if peeked == "sbo" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .sbo,
						line = p.line_number,
					},
				)
				continue
			}

			if peeked == "sys" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .sys,
						line = p.line_number,
					},
				)
				continue
			}

		// x => xor
		case 'x':
			if peeked == "xor" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token {
						type = .Instruction,
						lexeme = lexeme,
						value = .xor,
						line = p.line_number,
					},
				)
				continue
			}
		}

		switch p.current {
		case 't':
			if peeked == "t0" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t0, line = p.line_number},
				)
				continue
			}

			if peeked == "t1" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t1, line = p.line_number},
				)
				continue
			}

			if peeked == "t2" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t2, line = p.line_number},
				)
				continue
			}

			if peeked == "t3" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t3, line = p.line_number},
				)
				continue
			}

			if peeked == "t4" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t4, line = p.line_number},
				)
				continue
			}

			if peeked == "t5" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .t5, line = p.line_number},
				)
				continue
			}

		case 'a':
			if peeked == "a0" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .a0, line = p.line_number},
				)
				continue
			}

			if peeked == "a1" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .a1, line = p.line_number},
				)
				continue
			}

			if peeked == "a2" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .a2, line = p.line_number},
				)
				continue
			}

			if peeked == "a3" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .a3, line = p.line_number},
				)
				continue
			}

		case 'r':
			if peeked == "rv" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .rv, line = p.line_number},
				)
				continue
			}

			if peeked == "ra" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .ra, line = p.line_number},
				)
				continue
			}

		case 'f':
			if peeked == "fp" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .fp, line = p.line_number},
				)
				continue
			}

		case 's':
			if peeked == "sp" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .sp, line = p.line_number},
				)
				continue
			}

		case 'b':
			if peeked == "bp" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .bp, line = p.line_number},
				)
				continue
			}

		case 'p':
			if peeked == "pc" {
				arr := eat_lexeme(p) or_return
				defer delete(arr)
				lexeme := utf8.runes_to_string(arr[:])

				append_elems(
					t,
					Token{type = .Register, lexeme = lexeme, value = .pc, line = p.line_number},
				)
				continue
			}
		}

		if p.current == '"' {
			eat(p) or_return

			arr := eat_string(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
			append(
				t,
				Token {
					type = .Immediate_String,
					lexeme = lexeme,
					line = line_number,
					value = lexeme,
				},
			)

			eat(p) or_return
			continue
		}

		if p.current == ':' {
			lexeme := strings.clone(":")

			append(t, Token{type = .Symbol, lexeme = lexeme, value = ":", line = p.line_number})

			eat(p) or_return
			continue
		}

		if p.current == '.' {
			arr := eat_directive(p) or_return
			defer delete(arr)

			lexeme := utf8.runes_to_string(arr[:])

			append(t, Token{type = .Directive, lexeme = lexeme, line = p.line_number})

			continue
		}

		if p.current == '#' {
			arr := eat_line(p) or_return
			defer delete(arr)

			continue
		}

		if unicode.is_number(p.current) || p.current == '-' {
			arr := eat_number(p) or_return
			defer delete(arr)

			// NOTE: just a hyphen
			if len(arr) == 1 && !unicode.is_number(arr[0]) {
				log.error("invalid command, got '-'")
				continue
			}

			lexeme := utf8.runes_to_string(arr[:])
			append(
				t,
				Token {
					type = .Immediate_Integer,
					lexeme = lexeme,
					line = line_number,
					value = strconv.atoi(lexeme),
				},
			)
			continue
		}

		if len(peeked) > 1 {
			arr := eat_lexeme(p) or_return

			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append(t, Token{type = .Unknown, lexeme = lexeme, line = p.line_number})
			continue
		}

		eated := eat(p) or_return
		log.error("invalid command, got:", eated)
		clear(t)
		return
	}

	return nil
}
