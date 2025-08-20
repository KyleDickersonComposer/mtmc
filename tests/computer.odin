package computer_test

import com "../computer"
import "core:fmt"
import "core:log"
import "core:testing"

@(test)
add_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}

	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// add t0 t1
	instruction_as_bytes: u16 = 0b0001_0000_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 + 27)
}

@(test)
sub_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// sub t0 t1
	instruction_as_bytes: u16 = 0b0001_0001_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 - 27)
}

@(test)
mul_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_0010_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 * 27)
}

@(test)
div_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_0011_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 / 27)
}

@(test)
mod_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// mod t0 t1
	instruction_as_bytes: u16 = 0b0001_0100_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 % 27)
}

@(test)
imm_add_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42

	com.set_next_word(&c, 27, 2)


	instruction_as_bytes: u16 = 0b0001_1111_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 + 27)
}
