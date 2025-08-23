package mtmc_terminal

import com "../computer/"
import "core:fmt"
import "core:log"

computer_state_print :: proc(c: ^com.Computer, command: string) {

	if command == "registers" {
		for reg, i in 0 ..< 16 {
			fmt.printf("%v: %v\n", reg, c.Registers[i])
		}
		return
	}

	if command == "flags" {
		fmt.printf("t: %d\n", cast(u8)c.test_flag)
		fmt.printf("o: %d\n", cast(u8)c.overflow_flag)
		fmt.printf("n: %d\n", cast(u8)c.nan_flag)
		fmt.printf("e: %d\n", cast(u8)c.error_flag)
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

print_help :: proc(command: string) {
	if command == "help" || command == "?" {
		fmt.println(
			"Type the commands below for more information on how to use them!\n",
			"Commands listing:\n",
			"\tregisters -> debug print of registers\n",
			"\tmemory -> debug print of memory\n",
			"\tflags -> debug print of flags\n",
			"\tinfo -> debug print of error_info\n",
			"\texit -> quit the program\n",
			"Help listing:\n",
			"\tmtmc help -> introduction to MTMC\n",
			"\tinstructions help -> introduction to MTMC's instruction set\n",
			"\tregisters help -> introduction to MTMC's instruction set\n",
			"\tmemory help -> introduction to MTMC's memory layout and semantics\n",
			"\tsyscalls help -> introduction to MTMC's syscalls\n",
		)
	}

	if command == "mtmc help" {
		fmt.println(
			"The MonTana state Mini Computer is a virtual computer intended to show how digital computation works in a fun and visual way.\n",
			"The MTSC combines ideas from the PDP-11, MIPS, Scott CPU, Game Boy and JVM to make a relatively simple 16-bit computer that can accomplish basic computing tasks.\n",
			"The computer is displayed via a web interface that includes all the I/O such as console and display, visual representations of the computer state, and a built in code editor to construct and debug software for the computer.",
		)
	}

	if command == "commands help" {
		fmt.println("not yet implemented")
	}
	if command == "instructions help" {
		fmt.println("not yet implemented")
	}
	if command == "registers help" {
		fmt.println("not yet implemented")
	}
	if command == "memory help" {
		fmt.println("not yet implemented")
	}
	if command == "syscalls help" {
		fmt.println("not yet implemented")
	}
}
