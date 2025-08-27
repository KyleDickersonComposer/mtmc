package tests

import "../assembler/"
import com "../computer/"

import "core:log"
import "core:mem"
import "core:mem/virtual"
import "core:testing"

@(test)
assembly_parsing_assembly_and_executing_returns_correct_result :: proc(t: ^testing.T) {
	c := com.init_computer()
	defer com.shutdown_computer(&c)

	arena: virtual.Arena

	alloc_err := virtual.arena_init_growing(&arena)
	if alloc_err != nil {
		log.error(alloc_err)
		testing.fail(t)
	}

	context.allocator = virtual.arena_allocator(&arena)

	defer virtual.arena_destroy(&arena)

	asm_data := `.data
	greeting: "hello world"

	address_of_42:
	number: 42 
	
	.code
	main:
		li t0 42
		li t1 27
		add t0 t1`


	tokens, parse_error := assembler.tokenize_asm(asm_data)

	if parse_error != nil {
		log.error(parse_error)
		testing.fail(t)
	}

	bin, emit_error := assembler.assemble(&c, &tokens)

	if emit_error != nil {
		log.error(emit_error)
		testing.fail(t)
	}

	load_error := assembler.load_binary(&c, bin)
	if load_error != nil {
		log.error(load_error)
		testing.fail(t)
	}

	execute_error := assembler.execute_binary(&c, bin)
	if execute_error != nil {
		log.error(execute_error)
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 + 27)
}
