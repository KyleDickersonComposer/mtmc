package assembler

import com "../computer"
import "core:log"
import "core:strconv"
import "core:unicode"
import "core:unicode/utf8"

parse_data_section :: proc(
	c: ^com.Computer,
	p: ^Parsed_Command,
	command: []rune,
) -> Assembler_Error {

	return nil
}

parse_code_section :: proc(
	c: ^com.Computer,
	p: ^Parsed_Command,
	command: string,
) -> Assembler_Error {

	return nil
}

parse_assembly_file :: proc() -> Assembler_Error {
	return nil
}

emit_assembler_instructions :: proc() -> ([]u8, Assembler_Error) {
	return nil, nil
}

init_parser :: proc(data: []rune) -> Parser {
	assert(len(data) > 0)

	return {data = data, current = data[0], line_number = 1}
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

	log.info("eated:", r)

	return r, nil
}

peek :: proc(p: ^Parser) -> (rune, Assembler_Error) {
	if p.index + 1 >= len(p.data) {
		log.error("tried to eat OOB")
		return '0', .Out_Of_Bounds_Read
	}

	r := p.data[p.index + 1]

	return r, nil
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
		if p.index >= len(p.data) do return

		if unicode.is_alpha(p.current) || unicode.is_number(p.current) {
			append(&arr, eat(p) or_return)
		} else {
			return arr, nil
		}
	}

	log.error("failed to eat lexeme", arr)
	return nil, .Failed_To_Eat_Lexeme
}

execute_command :: proc(c: ^com.Computer, command: Parsed_Command) -> Assembler_Error {
	// throw the parsed command into the execute flow?
	// need to figure out how to set up things where we the pc and stuff?
	return nil
}

tokenize_instruction :: proc(p: ^Parser, t: ^[dynamic]Token) -> Assembler_Error {
	if p.current == 'j' && len(p.data) == 1 {
		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		append_elems(
			t,
			Token{type = .Instruction, lexeme = lexeme, value = .j, line = p.line_number},
		)
		return nil
	}

	switch p.current {
	// a => add, and
	case 'a':
		next := peek(p) or_return

		if next != 'd' && next != 'n' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "add" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .add, line = p.line_number},
			)
			return nil
		}

		if lexeme == "and" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .and, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// d => dec, div, dup, drop, debug
	case 'd':
		next := peek(p) or_return

		if next != 'e' && next != 'i' && next != 'u' && next != 'r' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "dec" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .dec, line = p.line_number},
			)
			return nil
		}

		if next == 'e' && lexeme == "debug" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .debug, line = p.line_number},
			)
			return nil
		}

		if next == 'i' && lexeme == "div" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .div, line = p.line_number},
			)
			return nil
		}

		if next == 'u' && lexeme == "dup" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .dup, line = p.line_number},
			)
			return nil
		}

		if next == 'r' && lexeme == "drop" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .drop, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// e => eq, eqi
	case 'e':
		next := peek(p) or_return

		if next != 'q' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if next != 'q' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		if next == 'q' && lexeme == "eq" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .eq, line = p.line_number},
			)
			return nil
		}

		if next == 'q' && lexeme == "eqi" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .eqi, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// g => gt, gti, gte, gtei
	case 'g':
		next := peek(p) or_return

		if next != 't' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if next == 't' && lexeme == "gt" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gt, line = p.line_number},
			)
			return nil
		}

		if next == 't' && lexeme == "gti" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gti, line = p.line_number},
			)
			return nil
		}

		if next == 't' && lexeme == "gte" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gte, line = p.line_number},
			)
			return nil
		}

		if next == 't' && lexeme == "gtei" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gtei, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// i => inc, imm
	case 'i':
		next := peek(p) or_return

		if next != 'n' && next != 'm' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if next == 'n' && lexeme == "inc" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .inc, line = p.line_number},
			)
			return nil
		}

		if next == 'm' && lexeme == "imm" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .imm, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// j => jr, jz, jnz, jal
	case 'j':
		next := peek(p) or_return

		if next != 'r' && next != 'z' && next != 'n' && next != 'a' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "jr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jr, line = p.line_number},
			)
			return nil
		}

		if lexeme == "jz" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jz, line = p.line_number},
			)
			return nil
		}

		if lexeme == "jnz" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jnz, line = p.line_number},
			)
			return nil
		}
		if lexeme == "jal" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jal, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// l => lnot, lt, lte, lti, ltei, lwr, lbr, lw, lb, lwo, lbo, li, la
	case 'l':
		next := peek(p) or_return

		if next != 't' && next != 'n' && next != 'w' && next != 'b' && next != 'a' && next != 'i' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "lnot" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lnot, line = p.line_number},
			)
			return nil
		}

		if lexeme == "lt" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lt, line = p.line_number},
			)
			return nil
		}
		if lexeme == "lte" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lte, line = p.line_number},
			)
			return nil
		}

		if lexeme == "lti" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lti, line = p.line_number},
			)
			return nil
		}
		if lexeme == "ltei" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .ltei, line = p.line_number},
			)
			return nil
		}

		if lexeme == "lwr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lwr, line = p.line_number},
			)
			return nil
		}
		if lexeme == "lbr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lbr, line = p.line_number},
			)
			return nil
		}

		if lexeme == "lb" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lb, line = p.line_number},
			)
			return nil
		}
		if lexeme == "lw" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lw, line = p.line_number},
			)
			return nil
		}

		if lexeme == "lwo" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lwo, line = p.line_number},
			)
			return nil
		}
		if lexeme == "lbo" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lbo, line = p.line_number},
			)
			return nil
		}

		if lexeme == "li" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .li, line = p.line_number},
			)
			return nil
		}
		if lexeme == "la" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .la, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// m => mov, mul, mod, min, max, mcp
	case 'm':
		next := peek(p) or_return

		if next != 'o' && next != 'u' && next != 'o' && next != 'i' && next != 'a' && next != 'c' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "mov" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mov, line = p.line_number},
			)
			return nil
		}

		if lexeme == "mul" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mul, line = p.line_number},
			)
			return nil
		}
		if lexeme == "mod" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mod, line = p.line_number},
			)
			return nil
		}

		if lexeme == "min" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .min, line = p.line_number},
			)
			return nil
		}
		if lexeme == "max" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .max, line = p.line_number},
			)
			return nil
		}

		if lexeme == "mcp" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mcp, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// n => not, neg, nop
	case 'n':
		next := peek(p) or_return

		if next != 'e' && next != 'o' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "not" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .neg, line = p.line_number},
			)
			return nil
		}

		if lexeme == "neg" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .neg, line = p.line_number},
			)
			return nil
		}

		if lexeme == "nop" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .nop, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// o => or, over
	case 'o':
		next := peek(p) or_return

		if next != 'r' && next != 'v' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "or" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .or, line = p.line_number},
			)
			return nil
		}

		if lexeme == "over" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .over, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// p => push, pop, pushi
	case 'p':
		next := peek(p) or_return

		if next != 'o' && next != 'u' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "push" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .push, line = p.line_number},
			)
			return nil
		}

		if lexeme == "pushi" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .pushi, line = p.line_number},
			)
			return nil
		}

		if lexeme == "pop" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .pop, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// r => rot, ret
	case 'r':
		next := peek(p) or_return

		if next != 'e' && next != 'o' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "rot" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .rot, line = p.line_number},
			)
			return nil
		}

		if lexeme == "ret" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .ret, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// s => seti, sub, shl, shr, swap, sop, swr, sbr, sw, swo, sb, sbo, sys
	case 's':
		next := peek(p) or_return

		if next != 'e' &&
		   next != 'u' &&
		   next != 'h' &&
		   next != 'w' &&
		   next != 'b' &&
		   next != 'y' &&
		   next != 'o' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "seti" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .seti, line = p.line_number},
			)
			return nil
		}

		if lexeme == "sub" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sub, line = p.line_number},
			)
			return nil
		}

		if lexeme == "shl" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .shl, line = p.line_number},
			)
			return nil
		}

		if lexeme == "shr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .shr, line = p.line_number},
			)
			return nil
		}
		if lexeme == "swap" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swap, line = p.line_number},
			)
			return nil
		}
		if lexeme == "sop" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sop, line = p.line_number},
			)
			return nil
		}
		if lexeme == "swr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swr, line = p.line_number},
			)
			return nil
		}
		if lexeme == "sbr" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sbr, line = p.line_number},
			)
			return nil
		}
		if lexeme == "sw" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sw, line = p.line_number},
			)
			return nil
		}

		if lexeme == "swo" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swo, line = p.line_number},
			)
			return nil
		}

		if lexeme == "sb" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sb, line = p.line_number},
			)
			return nil
		}
		if lexeme == "sbo" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sbo, line = p.line_number},
			)
			return nil
		}
		if lexeme == "sys" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sys, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction

	// x => xor
	case 'x':
		next := peek(p) or_return

		if next != 'o' {
			log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
			return .Invalid_Instruction
		}

		arr := eat_lexeme(p) or_return
		lexeme := utf8.runes_to_string(arr[:])

		if lexeme == "xor" {
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .xor, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction
	}

	log.error("hit bottom of instruction parse switch")
	log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
	return .Invalid_Instruction
}

tokenize_command :: proc(
	c: ^com.Computer,
	t: ^[dynamic]Token,
	i: string,
) -> (
	parsed: Parsed_Command,
	err: Assembler_Error,
) {
	if len(i) == 0 do return {}, nil

	rs := utf8.string_to_runes(i)
	defer delete(rs)

	parser := init_parser(rs)
	p := &parser

	line_number := 1

	for {
		if p.current == utf8.RUNE_EOF do return

		if p.current == '\n' {
			eat(p) or_return
			line_number += 1
			continue
		}

		if unicode.is_white_space(p.current) {
			eat(p) or_return
			continue
		}

		tokenize_instruction(p, t) or_return

		if p.current == '"' {
			eat(p) or_return

			arr := eat_lexeme(p) or_return
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

		if unicode.is_number(p.current) {
			arr := eat_lexeme(p) or_return
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
	}


	return {}, nil
}
