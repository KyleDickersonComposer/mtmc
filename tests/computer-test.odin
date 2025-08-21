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

	// imm add t0 27
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

@(test)
push_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42

	// push t0
	instruction_as_bytes: u16 = 0b0010_0000_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	sp := c.Registers[com.Register.sp]

	testing.expect_value(t, com.read_word_at_stack_address(&c, u16(sp), 0), 42)
}

@(test)
pop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	sp_value := c.Registers[com.Register.sp]

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)

	// pop t0
	instruction_as_bytes: u16 = 0b0010_0001_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	// properly moves the stack pointers after pop
	testing.expect_value(t, c.Registers[com.Register.sp], sp_value)

	testing.expect_value(t, c.Registers[com.Register.t0], 42)
}
