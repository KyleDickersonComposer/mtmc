package computer_test

import com "../computer"
import "core:fmt"
import "core:log"
import "core:testing"

@(test)
add_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	com.set_register_value(&c, .t0, 42)
	com.set_register_value(&c, .t1, 27)

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

	testing.expect_value(t, com.get_register_value(&c, .t0), 69)
}

@(test)
sub_instruction :: proc(t: ^testing.T) {
	c := com.Computer{}
	com.set_register_value(&c, .t0, 42)
	com.set_register_value(&c, .t1, 27)

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

	testing.expect_value(t, com.get_register_value(&c, .t0), 15)
}
