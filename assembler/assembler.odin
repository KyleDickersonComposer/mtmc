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
	if p.index >= len(p.data) do return

	i := 0
	for {
		peek := peek(p, i) or_return
		if peek == ' ' || peek == utf8.RUNE_EOF {
			str = utf8.runes_to_string(arr[:])
			return str, nil
		}

		if unicode.is_alpha(p.current) || unicode.is_number(p.current) {
			append(&arr, peek)
		}

		i += 1
	}

	log.error("failed to peek lexeme", arr)
	return "", .Failed_To_Eat_Lexeme
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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "add" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .add, line = p.line_number},
			)
			return nil
		}

		if peeked == "and" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "dec" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .dec, line = p.line_number},
			)
			return nil
		}

		if peeked == "debug" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .debug, line = p.line_number},
			)
			return nil
		}

		if peeked == "div" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .div, line = p.line_number},
			)
			return nil
		}

		if peeked == "dup" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .dup, line = p.line_number},
			)
			return nil
		}

		if peeked == "drop" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "eq" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .eq, line = p.line_number},
			)
			return nil
		}

		if peeked == "eqi" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "gt" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gt, line = p.line_number},
			)
			return nil
		}

		if peeked == "gti" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gti, line = p.line_number},
			)
			return nil
		}

		if peeked == "gte" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .gte, line = p.line_number},
			)
			return nil
		}

		if peeked == "gtei" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "inc" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .inc, line = p.line_number},
			)
			return nil
		}

		if peeked == "imm" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "jr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jr, line = p.line_number},
			)
			return nil
		}

		if peeked == "jz" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jz, line = p.line_number},
			)
			return nil
		}

		if peeked == "jnz" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .jnz, line = p.line_number},
			)
			return nil
		}

		if peeked == "jal" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "lnot" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lnot, line = p.line_number},
			)
			return nil
		}

		if peeked == "lt" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lt, line = p.line_number},
			)
			return nil
		}

		if peeked == "lte" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lte, line = p.line_number},
			)
			return nil
		}

		if peeked == "lti" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lti, line = p.line_number},
			)
			return nil
		}
		if peeked == "ltei" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .ltei, line = p.line_number},
			)
			return nil
		}

		if peeked == "lwr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lwr, line = p.line_number},
			)
			return nil
		}
		if peeked == "lbr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lbr, line = p.line_number},
			)
			return nil
		}

		if peeked == "lb" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lb, line = p.line_number},
			)
			return nil
		}
		if peeked == "lw" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lw, line = p.line_number},
			)
			return nil
		}

		if peeked == "lwo" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lwo, line = p.line_number},
			)
			return nil
		}
		if peeked == "lbo" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .lbo, line = p.line_number},
			)
			return nil
		}

		if peeked == "li" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .li, line = p.line_number},
			)
			return nil
		}
		if peeked == "la" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "mov" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mov, line = p.line_number},
			)
			return nil
		}

		if peeked == "mul" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mul, line = p.line_number},
			)
			return nil
		}
		if peeked == "mod" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .mod, line = p.line_number},
			)
			return nil
		}

		if peeked == "min" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .min, line = p.line_number},
			)
			return nil
		}
		if peeked == "max" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .max, line = p.line_number},
			)
			return nil
		}

		if peeked == "mcp" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "not" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .not, line = p.line_number},
			)
			return nil
		}

		if peeked == "neg" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .neg, line = p.line_number},
			)
			return nil
		}

		if peeked == "nop" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])
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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "or" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .or, line = p.line_number},
			)
			return nil
		}

		if peeked == "over" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "push" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .push, line = p.line_number},
			)
			return nil
		}

		if peeked == "pushi" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .pushi, line = p.line_number},
			)
			return nil
		}

		if peeked == "pop" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "rot" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .rot, line = p.line_number},
			)
			return nil
		}

		if peeked == "ret" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "seti" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)

			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .seti, line = p.line_number},
			)
			return nil
		}

		if peeked == "sub" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sub, line = p.line_number},
			)
			return nil
		}

		if peeked == "shl" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .shl, line = p.line_number},
			)
			return nil
		}

		if peeked == "shr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .shr, line = p.line_number},
			)
			return nil
		}

		if peeked == "swap" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swap, line = p.line_number},
			)
			return nil
		}

		if peeked == "sop" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sop, line = p.line_number},
			)
			return nil
		}
		if peeked == "swr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swr, line = p.line_number},
			)
			return nil
		}
		if peeked == "sbr" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sbr, line = p.line_number},
			)
			return nil
		}

		if peeked == "sw" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sw, line = p.line_number},
			)
			return nil
		}

		if peeked == "swo" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .swo, line = p.line_number},
			)
			return nil
		}

		if peeked == "sb" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sb, line = p.line_number},
			)
			return nil
		}
		if peeked == "sbo" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .sbo, line = p.line_number},
			)
			return nil
		}

		if peeked == "sys" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

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
		peeked := peek_lexeme(p) or_return
		defer delete(peeked)

		if peeked == "xor" {
			arr := eat_lexeme(p) or_return
			defer delete(arr)
			lexeme := utf8.runes_to_string(arr[:])

			append_elems(
				t,
				Token{type = .Instruction, lexeme = lexeme, value = .xor, line = p.line_number},
			)
			return nil
		}

		log.error("invalid instruction, got:", p.data, "on line:", p.line_number)
		return .Invalid_Instruction
	}

	return nil
}

tokenize_register :: proc(p: ^Parser, t: ^[dynamic]Token) -> Assembler_Error {
	return nil
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
