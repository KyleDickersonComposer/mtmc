package assembler

import com "../computer"

Assembler_Error :: union {
	Parse_Error,
}

Parse_Error :: enum {
	Invalid_Rune,
	Out_Of_Bounds_Read,
	Failed_To_Eat_Lexeme,
	Bad_Command,
	Invalid_Instruction,
}

Token_Kind :: enum {
	Instruction,
	Register,
	Immediate_Integer,
	Immediate_String,
	Syscall,
	Label,
}

Token :: struct {
	type:   Token_Kind,
	lexeme: string,
	value:  Token_Value,
	line:   int,
}

Token_Value :: union {
	com.Register,
	com.Miscellaneous_Instruction,
	com.ALU_Instruction,
	com.Stack_Instruction,
	com.Test_Instruction,
	com.Load_Store_Register_Instruction,
	com.Load_Store_Instruction,
	com.Jump_Register_Instruction,
	com.Jump_Instruction,
	int,
	string,
}

Parser :: struct {
	data:        []rune,
	index:       int,
	line_number: int,
	current:     rune,
}
