package assembler

import com "../computer"

import "core:log"

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
	// The trie from Crafting Interpreters
	// starting chars:
	// a => add, and
	// d => dec, div, dup, drop, debug
	// e => eq, eqi
	// g => gt, gti, gte, gtei
	// i => inc, imm
	// j => jr, j, jz, jnz, jal
	// l => lnot, lt, lte, lti, ltei, lwr, lbr, lw, lb, lwo, lbo, li, la
	// m => mov, mul, mod, min, max, mcp
	// n => not, neg, nop
	// o => or, over
	// p => push, pop, pushi
	// r => rot, ret
	// s => seti, sub, shl, shr, swap, sop, swr, sbr, sw, swo, sb, sbo, sys
	// x => xor

	return nil
}

parse_instruction :: proc() -> Assembler_Error {
	return nil
}

parse_assembly_file :: proc() -> Assembler_Error {
	return nil
}

emit_assembler_instructions :: proc() -> ([]u8, Assembler_Error) {

	return nil, nil
}

parse_command :: proc(c: ^com.Computer, command: string) -> (Parsed_Command, Assembler_Error) {
	if len(command) == 0 do return {}, nil

	return {}, nil
}

execute_command :: proc(c: ^com.Computer, command: Parsed_Command) -> Assembler_Error {
	// throw the parsed command into the execute flow?
	// need to figure out how to set up things where we the pc and stuff?
	return nil
}
