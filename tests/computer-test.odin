package computer_test

import com "../computer"
import "core:fmt"
import "core:log"
import "core:testing"

@(test)
mov_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 42

	// mov a0 t0
	instruction_as_bytes: u16 = 0b0000_0001_0110_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.a0], 42)
}

@(test)
inc_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 40

	// inc t0
	instruction_as_bytes: u16 = 0b0000_0010_0000_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42)
}

@(test)
dec_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 44

	// dec t0
	instruction_as_bytes: u16 = 0b0000_0011_0000_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	log.info(d)

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 42)
}

@(test)
seti_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	// seti t0
	instruction_as_bytes: u16 = 0b0000_0100_0000_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	log.info(d)

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 2)
}

@(test)
add_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
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
	c := com.init_computer()
	c.Registers[com.Register.t0] = 42

	com.write_next_word(&c, 27, 2)

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

	value := com.read_word_at_memory_address(&c, u16(sp), 0)

	testing.expect_value(t, value, 42)
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

@(test)
dup_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)

	sp_value := c.Registers[com.Register.sp]

	// pop t0
	instruction_as_bytes: u16 = 0b0010_0010_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	new_sp := c.Registers[com.Register.sp]

	top := com.read_word_at_memory_address(&c, u16(new_sp), 0)
	second := com.read_word_at_memory_address(&c, u16(new_sp), 2)

	testing.expect_value(t, top, second)
	testing.expect_value(t, new_sp, sp_value - 2)
}

@(test)
swap_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)
	com.push_word_at_stack_address(&c, u16(com.Register.sp), 27, 0)

	// pop t0
	instruction_as_bytes: u16 = 0b0010_0011_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	new_sp := c.Registers[com.Register.sp]

	top := com.read_word_at_memory_address(&c, u16(new_sp), 0)
	bottom := com.read_word_at_memory_address(&c, u16(new_sp), 2)

	testing.expect_value(t, top, 42)
	testing.expect_value(t, bottom, 27)
}

@(test)
drop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 32000, 0)

	sp_value := c.Registers[com.Register.sp]

	// drop
	instruction_as_bytes: u16 = 0b0010_0100_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	word_at_sp := com.read_word_at_memory_address(&c, u16(sp_value), 0)

	testing.expect_value(t, c.Registers[com.Register.sp], sp_value + 2)
}

@(test)
over_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	initial_sp_value := c.Registers[com.Register.sp]

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)
	com.push_word_at_stack_address(&c, u16(com.Register.sp), 27, 0)

	sp_value := c.Registers[com.Register.sp]

	// over
	instruction_as_bytes: u16 = 0b0010_0101_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	new_sp_value := c.Registers[com.Register.sp]

	dupped_value := com.read_word_at_memory_address(&c, u16(new_sp_value), 0)

	testing.expect_value(t, dupped_value, 42)
	testing.expect_value(t, sp_value, initial_sp_value - 4)
}

@(test)
rot_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	index_of_sp := 13
	initial_sp_value := c.Registers[com.Register.sp]

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)
	com.push_word_at_stack_address(&c, u16(com.Register.sp), 27, 0)
	com.push_word_at_stack_address(&c, u16(com.Register.sp), 1, 0)

	sp_value := c.Registers[com.Register.sp]

	// rot
	instruction_as_bytes: u16 = 0b0010_0110_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}


	new_sp_value := c.Registers[com.Register.sp]


	top_word := com.read_word_at_memory_address(&c, u16(index_of_sp), 0)
	next_word := com.read_word_at_memory_address(&c, u16(index_of_sp), 2)
	bottom_word := com.read_word_at_memory_address(&c, u16(index_of_sp), 4)

	testing.expect_value(t, top_word, 42)
	testing.expect_value(t, next_word, 1)
	testing.expect_value(t, bottom_word, 27)
}

@(test)
sop_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.push_word_at_stack_address(&c, u16(com.Register.sp), 42, 0)
	com.push_word_at_stack_address(&c, u16(com.Register.sp), 27, 0)

	// sop add
	instruction_as_bytes: u16 = 0b0010_0111_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	sp_value := c.Registers[com.Register.sp]

	result := com.read_word_at_memory_address(&c, u16(sp_value), 0)

	testing.expect_value(t, result, 42 + 27)
}

@(test)
pushi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc_value := c.Registers[com.Register.pc]

	com.set_word_at_memory_address(&c, u16(pc_value), 42, 2)

	// pushi 42
	instruction_as_bytes: u16 = 0b0010_1111_0000_1101

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	sp_value := c.Registers[com.Register.sp]

	result := com.read_word_at_memory_address(&c, u16(sp_value), 0)

	testing.expect_value(t, result, 42)
}

@(test)
eq_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2
	c.Registers[com.Register.t1] = 2

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0000_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
neq_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2
	c.Registers[com.Register.t1] = 1

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0001_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
gt_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2
	c.Registers[com.Register.t1] = 1

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0010_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
gte_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2
	c.Registers[com.Register.t1] = 2

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0011_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
lt_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 1
	c.Registers[com.Register.t1] = 2

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0100_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
lte_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2
	c.Registers[com.Register.t1] = 2

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_0101_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
eqi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 1

	// eqi t1 1
	instruction_as_bytes: u16 = 0b0011_1000_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
neqi_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 0

	// neqi t0 1
	instruction_as_bytes: u16 = 0b0011_1001_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
gti_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 2

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_1010_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
gtei_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 1

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_1011_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
lti_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 0

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_1100_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}

@(test)
ltei_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 1

	// pushi 42
	instruction_as_bytes: u16 = 0b0011_1101_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.test_flag, true)
}


@(test)
lwr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.set_word_at_memory_address(&c, 40, 27000, 0)

	c.Registers[com.Register.t1] = 42
	c.Registers[com.Register.t2] = -2

	// lwr t0 t1 t2
	instruction_as_bytes: u16 = 0b0100_0000_0001_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 27000)
}

@(test)
lbr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	com.set_byte_at_memory_address(&c, 40, 27, 0)

	c.Registers[com.Register.t1] = 42
	c.Registers[com.Register.t2] = -2

	// lbr t0 t1 t2
	instruction_as_bytes: u16 = 0b0101_0000_0001_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.t0], 27)
}

@(test)
swr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()


	c.Registers[com.Register.t0] = 2700
	c.Registers[com.Register.t1] = 42
	c.Registers[com.Register.t2] = 42

	// swr t0 t1 t2
	instruction_as_bytes: u16 = 0b0110_0000_0001_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_word_at_memory_address(&c, 42 + 42, 0)

	testing.expect_value(t, value, 2700)
}

@(test)
sbr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 27
	c.Registers[com.Register.t1] = 42
	c.Registers[com.Register.t2] = 42

	// sbr t0 t1 t2
	instruction_as_bytes: u16 = 0b0111_0000_0001_0010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_byte_at_memory_address(&c, 42, 42)

	testing.expect_value(t, value, 27)
}

@(test)
lw_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	com.set_word_at_memory_address(&c, u16(pc), 42, 2)

	// lw t0 42
	instruction_as_bytes: u16 = 0b1000_0000_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := c.Registers[com.Register.t0]

	testing.expect_value(t, value, 42)
}

@(test)
lwo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	c.Registers[com.Register.t1] = 2

	com.set_word_at_memory_address(&c, u16(pc), 42, 4)

	// lw0 t0 42
	instruction_as_bytes: u16 = 0b1000_0001_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := c.Registers[com.Register.t0]

	testing.expect_value(t, value, 42)
}

@(test)
lb_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	com.set_byte_at_memory_address(&c, u16(pc), 42, 2)

	// lb t0 42
	instruction_as_bytes: u16 = 0b1000_0010_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := c.Registers[com.Register.t0]

	testing.expect_value(t, value, 42)
}

@(test)
lbo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	c.Registers[com.Register.t1] = 2

	com.set_byte_at_memory_address(&c, u16(pc), 42, 4)

	// lbo t0 42
	instruction_as_bytes: u16 = 0b1000_0011_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := c.Registers[com.Register.t0]

	testing.expect_value(t, value, 42)
}

@(test)
sw_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	c.Registers[com.Register.t0] = 27

	com.set_word_at_memory_address(&c, u16(pc), 42, 2)

	// sw t0 42
	instruction_as_bytes: u16 = 0b1000_0100_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_word_at_memory_address(&c, 42, 0)

	testing.expect_value(t, value, 27)
}

@(test)
swo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	c.Registers[com.Register.t0] = 27
	c.Registers[com.Register.t1] = 2

	com.set_word_at_memory_address(&c, u16(pc), 42, 2)

	// swo
	instruction_as_bytes: u16 = 0b1000_0101_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_word_at_memory_address(&c, 42 + 2, 0)

	testing.expect_value(t, value, 27)
}

@(test)
sb_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]
	c.Registers[com.Register.t0] = 27

	com.set_byte_at_memory_address(&c, u16(pc), 42, 2)

	// sb t0 42
	instruction_as_bytes: u16 = 0b1000_0110_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_byte_at_memory_address(&c, 42, 0)

	testing.expect_value(t, value, 27)
}

@(test)
sbo_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	c.Registers[com.Register.t0] = 27
	c.Registers[com.Register.t1] = 2

	com.set_byte_at_memory_address(&c, u16(pc), 42, 2)

	// sbo t0 42
	instruction_as_bytes: u16 = 0b1000_0111_0000_0001

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := com.read_byte_at_memory_address(&c, 42 + 2, 0)

	testing.expect_value(t, value, 27)
}

@(test)
li_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	pc := c.Registers[com.Register.pc]

	com.set_word_at_memory_address(&c, u16(pc), 42, 2)

	// li t0 42
	instruction_as_bytes: u16 = 0b1000_1111_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	value := c.Registers[com.Register.t0]

	testing.expect_value(t, value, 42)
}

@(test)
jr_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.Registers[com.Register.t0] = 42

	// jr
	instruction_as_bytes: u16 = 0b1001_1111_0000_0000

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.pc], 42)
}

@(test)
j_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	// j
	instruction_as_bytes: u16 = 0b1100_0000_0010_1010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.pc], 42)
}

@(test)
jz_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	// jz
	instruction_as_bytes: u16 = 0b1101_0000_0010_1010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.pc], 42)
}

@(test)
jnz_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	c.test_flag = true

	// jnz
	instruction_as_bytes: u16 = 0b1110_0000_0010_1010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.pc], 42)
}

@(test)
jal_instruction :: proc(t: ^testing.T) {
	c := com.init_computer()

	initial_pc := c.Registers[com.Register.pc]
	c.test_flag = true

	// jnz
	instruction_as_bytes: u16 = 0b1111_0000_0010_1010

	d, err := com.decode_instruction(instruction_as_bytes)
	if err != nil {
		testing.fail(t)
	}

	err = com.execute_instruction(&c, d)
	if err != nil {
		testing.fail(t)
	}

	testing.expect_value(t, c.Registers[com.Register.ra], initial_pc + 1)
	testing.expect_value(t, c.Registers[com.Register.pc], 42)
}
