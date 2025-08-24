package mtmc_terminal

import "../assembler/"
import com "../computer/"
import "core:fmt"
import "core:log"


execute_command :: proc(c: ^com.Computer, t: ^[dynamic]assembler.Token) -> Terminal_Error {
	first_lexeme := t[0].lexeme

	if first_lexeme == "help" {
		print_help()
		return nil
	}

	log.error("invalid command")
	return .Invalid_Command
}

computer_state_print :: proc(c: ^com.Computer, command: string) {
	if command == "registers" {
		for reg, i in 0 ..< 16 {
			fmt.printf("%v: %v\n", cast(com.Register)reg, c.Registers[i])
		}
		return
	}

	if command == "flags" {
		fmt.printf("test:     %d\n", cast(u8)c.test_flag)
		fmt.printf("overflow: %d\n", cast(u8)c.overflow_flag)
		fmt.printf("nan:      %d\n", cast(u8)c.nan_flag)
		fmt.printf("error:    %d\n", cast(u8)c.error_flag)
		return
	}

	if command == "info" {
		fmt.println(c.error_info)
		return
	}

	if command == "memory" {
		fmt.print("001: ")
		inc := 1
		for b, i in c.Memory {
			if i % 16 == 0 && i != 0 {
				inc += 1
				fmt.println()
				fmt.printf("%3d: %X  ", inc, b)
				continue
			}

			fmt.print(b, " ")
		}
		fmt.println()
		return
	}

}

print_help :: proc() {
	fmt.println(
		"Type the commands below for more information on how to use them!\n",
		"Commands listing:\n",
		"\tregisters -> debug print of registers\n",
		"\tmemory -> debug print of memory\n",
		"\tflags -> debug print of flags\n",
		"\tinfo -> debug print of error_info\n",
		"\texit -> quit the program\n",
	)
}
