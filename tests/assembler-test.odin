package tests

import "../assembler"
import com "../computer"

import "core:log"
import "core:testing"

@(test)
emit_add_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "add t0 t1"
	instruction_as_bytes: u16 = 0b0001_0000_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sub_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "sub t0 t1"
	instruction_as_bytes: u16 = 0b0001_0001_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_mul_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "mul t0 t1"
	instruction_as_bytes: u16 = 0b0001_0010_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_div_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "div t0 t1"
	instruction_as_bytes: u16 = 0b0001_0011_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_mod_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "mod t0 t1"
	instruction_as_bytes: u16 = 0b0001_0100_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_and_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "and t0 t1"
	instruction_as_bytes: u16 = 0b0001_0101_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_or_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "or t0 t1"
	instruction_as_bytes: u16 = 0b0001_0110_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_xor_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "xor t0 t1"
	instruction_as_bytes: u16 = 0b0001_0111_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_shl_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "shl t0 t1"
	instruction_as_bytes: u16 = 0b0001_1000_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_shr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "shr t0 t1"
	instruction_as_bytes: u16 = 0b0001_1001_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_min_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "min t0 t1"
	instruction_as_bytes: u16 = 0b0001_1010_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_max_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	command := "max t0 t1"
	instruction_as_bytes: u16 = 0b0001_1011_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_not_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42

	command := "not t0"
	instruction_as_bytes: u16 = 0b0001_1100_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lnot_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 1

	command := "lnot t0"
	instruction_as_bytes: u16 = 0b0001_1101_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_neg_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 1

	command := "neg t0"
	instruction_as_bytes: u16 = 0b0001_1110_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}
@(test)
emit_imm_add_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42

	command := "imm add t0 27"
	instruction_as_bytes: u16 = 0b0001_1111_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_push_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42

	command := "push t0"
	instruction_as_bytes: u16 = 0b0010_0000_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_pop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "pop t0"
	instruction_as_bytes: u16 = 0b0010_0001_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_dup_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "dup"
	instruction_as_bytes: u16 = 0b0010_0010_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_swap_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "swap"
	instruction_as_bytes: u16 = 0b0010_0011_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_drop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "drop"
	instruction_as_bytes: u16 = 0b0010_0100_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_over_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "over"
	instruction_as_bytes: u16 = 0b0010_0101_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_rot_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "rot"
	instruction_as_bytes: u16 = 0b0010_0110_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "sop add"
	instruction_as_bytes: u16 = 0b0010_0111_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_pushi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "pushi"
	instruction_as_bytes: u16 = 0b0010_1111_0000_1101

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_eq_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "eq t0 t1"
	instruction_as_bytes: u16 = 0b0011_0000_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_neq_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "neq t0 t1"
	instruction_as_bytes: u16 = 0b0011_0001_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_gt_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "gt t0 t1"
	instruction_as_bytes: u16 = 0b0011_0010_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_gte_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "gte t0 t1"
	instruction_as_bytes: u16 = 0b0011_0011_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lt_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lt t0 t1"
	instruction_as_bytes: u16 = 0b0011_0100_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lte_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lte t0 t1"
	instruction_as_bytes: u16 = 0b0011_0101_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_eqi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "eqi t0 1"
	instruction_as_bytes: u16 = 0b0011_1000_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_neqi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "neqi t0 1"
	instruction_as_bytes: u16 = 0b0011_1001_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_gti_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "gti t0 0"
	instruction_as_bytes: u16 = 0b0011_1010_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_gtei_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "gtei t0 0"
	instruction_as_bytes: u16 = 0b0011_1011_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lti_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lti t0 0"
	instruction_as_bytes: u16 = 0b0011_1100_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_ltei_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "ltei t0 0"
	instruction_as_bytes: u16 = 0b0011_1101_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lwr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lwr t0 t1 t2"
	instruction_as_bytes: u16 = 0b0100_0000_0001_0010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lbr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lbr t0 t1 t2"
	instruction_as_bytes: u16 = 0b0101_0000_0001_0010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_swr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "swr t0 t1 t2"
	instruction_as_bytes: u16 = 0b0110_0000_0001_0010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sbr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "sbr t0 t1 t2"
	instruction_as_bytes: u16 = 0b0111_0000_0001_0010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lw_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lw t0 42"
	instruction_as_bytes: u16 = 0b1000_0000_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lwo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lwo t0 42"
	instruction_as_bytes: u16 = 0b1000_0001_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lb_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lb t0 42"
	instruction_as_bytes: u16 = 0b1000_0010_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_lbo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "lbo t0 42"
	instruction_as_bytes: u16 = 0b1000_0011_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sw_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "sw t0 42"
	instruction_as_bytes: u16 = 0b1000_0100_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_swo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "swo t0 2"
	instruction_as_bytes: u16 = 0b1000_0101_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sb_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "sb t0 42"
	instruction_as_bytes: u16 = 0b1000_0110_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_sbo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "sbo t0 42"
	instruction_as_bytes: u16 = 0b1000_0111_0000_0001

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_li_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "li t0 42"
	instruction_as_bytes: u16 = 0b1000_1111_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_jr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "jr t0"

	instruction_as_bytes: u16 = 0b1001_1111_0000_0000

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_j_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "j 42"

	instruction_as_bytes: u16 = 0b1100_0000_0010_1010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_jz_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "jz 42"

	instruction_as_bytes: u16 = 0b1101_0000_0010_1010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_jnz_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "jnz 42"

	instruction_as_bytes: u16 = 0b1110_0000_0010_1010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}

@(test)
emit_jal_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	command := "jal 42"

	instruction_as_bytes: u16 = 0b1111_0000_0010_1010

	tokens := make([dynamic]assembler.Token)
	defer assembler.free_tokens(&tokens)

	tokenizer_error := assembler.tokenize_command(&c, &tokens, command)
	if tokenizer_error != nil {
		log.error(tokenizer_error)
		testing.fail(t)
	}

	byte_code, emit_error := assembler.emit_bytecode(&c, &tokens)
	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	testing.expect_value(t, byte_code, instruction_as_bytes)
}
