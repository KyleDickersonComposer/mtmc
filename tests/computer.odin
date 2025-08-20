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
and_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_0101_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 & 27)
}

@(test)
or_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_0110_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 | 27)
}

@(test)
xor_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42
	c.Registers[com.Register.t1] = 27

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_0111_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42 ~ 27)
}

@(test)
shl_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 4
	c.Registers[com.Register.t1] = 2

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1000_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 4 << 2)
}

@(test)
shr_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 4
	c.Registers[com.Register.t1] = 2

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1001_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 4 >> 2)
}

@(test)
min_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 4
	c.Registers[com.Register.t1] = 2

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1010_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], min(4, 2))
}

@(test)
max_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 4
	c.Registers[com.Register.t1] = 2

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1011_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], max(4, 2))
}

@(test)
not_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 42

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1100_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value: i16 = 42

	testing.expect_value(t, c.Registers[com.Register.t0], ~value)
}

@(test)
lnot_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 1

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1101_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 0)
}

@(test)
neg_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	c.Registers[com.Register.t0] = 1

	// div t0 t1
	instruction_as_bytes: u16 = 0b0001_1110_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], -1)
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
