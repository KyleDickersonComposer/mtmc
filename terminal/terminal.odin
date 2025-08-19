package mtmc_terminal

import "core:fmt"

parse_command :: proc(command: string) -> (Parsed_Command, Terminal_Error) {
	return {}, .Failed
}

print_help_text :: proc(command: string) {
	if command == "help" || command == "?" {
		fmt.println(
			"Type the commands below for more information on how to use them!\n",
			"Help listing:\n",
			"\tmtmc help\n",
			"\tcommands help\n",
			"\tinstructions help\n",
			"\tregisters help\n",
			"\tmemory help\n",
			"\tsyscalls help\n",
		)
	}

	if command == "mtmc help" {
		fmt.println(
			"The MonTana state Mini Computer is a virtual computer intended to show how digital computation works in a fun and visual way.\nThe MTSC combines ideas from the PDP-11, MIPS, Scott CPU, Game Boy and JVM to make a relatively simple 16-bit computer that can accomplish basic computing tasks.\nThe computer is displayed via a web interface that includes all the I/O such as console and display, visual representations of the computer state, and a built in code editor to construct and debug software for the computer.",
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
