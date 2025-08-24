package mtmc_terminal

import "../assembler/"
import com "../computer/"
import "core:fmt"
import "core:log"

execute_command :: proc(c: ^com.Computer, tokens: ^[dynamic]assembler.Token) -> Terminal_Error {
	if len(tokens) == 1 {
		first_lexeme := tokens[0].lexeme
		if first_lexeme == "help" {
			print_help()
			return nil
		}

		if first_lexeme == "registers" {
			print_registers_state(c)
			return nil
		}

		if first_lexeme == "flags" {
			print_flags_state(c)
			return nil
		}

		if first_lexeme == "memory" {
			print_memory_state(c)
			return nil
		}

		if first_lexeme == "info" {
			print_error_info(c)
			return nil
		}

		if first_lexeme == "exit" {
			com.shutdown_computer(c)
			return nil
		}
	}

	if len(tokens) == 2 {
		first_lexeme := tokens[0].lexeme
		second_lexeme := tokens[1].lexeme

		if second_lexeme == "help" {
			if first_lexeme == "commands" {
				// print_commands_help()
				return nil
			}

			if first_lexeme == "registers" {
				// print_registers_help()
				return nil
			}

			if first_lexeme == "flags" {
				// print_flags_help()
				return nil
			}
		}
	}

	if len(tokens) == 3 {
		first_lexeme := tokens[0].lexeme
		second_lexeme := tokens[1].lexeme
		third_lexeme := tokens[2].lexeme

		if first_lexeme == "set" {
			register := tokens[1].value

			#partial switch v in register {
			case com.Register:
				token_three := tokens[2]

				if token_three.type != .Immediate_Integer {
					log.error("expected third argument to be an register's index")
					return nil
				}

				c.Registers[v] = i16(token_three.value.(int))
				return nil


			case:
				log.error("expected second argument to be a register")
				return nil
			}

		}
	}

	log.error("invalid command")
	return .Invalid_Command
}

print_registers_state :: proc(c: ^com.Computer) {
	for reg, i in 0 ..< 16 {
		fmt.printf("%v: %v\n", cast(com.Register)reg, c.Registers[i])
	}
	return
}

print_flags_state :: proc(c: ^com.Computer) {
	fmt.printf("test:     %d\n", cast(u8)c.test_flag)
	fmt.printf("overflow: %d\n", cast(u8)c.overflow_flag)
	fmt.printf("nan:      %d\n", cast(u8)c.nan_flag)
	fmt.printf("error:    %d\n", cast(u8)c.error_flag)
	return
}

print_memory_state :: proc(c: ^com.Computer) {
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

print_error_info :: proc(c: ^com.Computer) {
	fmt.println(c.error_info)
	return
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
