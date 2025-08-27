package assembler

import com "../computer"

Assembler_Error :: union {
	Parse_Error,
}

Binary :: struct {
	data_section: [dynamic]u8,
	code_section: [dynamic]u16,
}

Token_Parser :: struct {
	data:                   []Token,
	index:                  int,
	current:                Token,
	current_memory_address: int,
}

Asm_Node :: union {
	Attribute,
	Directive,
	Section,
	Instruction,
	Label,
}

Attribute :: struct {
	kind:  Attribute_Kind,
	value: Attribute_Value,
}

Attribute_Kind :: enum {
	File,
	Global,
	Local,
	Line,
}

Attribute_Value :: union {
	string,
	int,
}

Directive :: struct {
	value: Directive_Value,
	kind:  Directive_Kind,
}

Directive_Value :: union {
	string,
	int,
}

Directive_Kind :: enum {
	Type,
}

Section :: struct {
	kind:        Section_Kind,
	labels:      [dynamic]Label,
	instruction: [dynamic]Instruction,
}

Section_Kind :: enum {
	Code,
	Data,
}

Instruction :: struct {
	instruction: com.Instruction_Kind,
	operands:    [dynamic]Operand,
}

// NOTE: address is relative to beginning of data section
Label :: struct {
	name:       string,
	value:      Label_Value_Kind,
	address:    int,
	value_size: int,
}

Label_Value_Kind :: union {
	int,
	string,
	[]u8,
	[]i16,
}

Operand :: struct {
	type:  Operand_Kind,
	value: Operand_Value,
}

Operand_Kind :: enum {
	Register,
	Integer,
	String,
	Label,
}

Operand_Value :: union {
	string,
	com.Register,
	int,
}

Parse_Error :: enum {
	Invalid_Rune,
	Out_Of_Bounds_Read,
	Failed_To_Eat_Lexeme,
	Bad_Command,
	Invalid_Instruction,
	Type_Check_Failed,
	Failed_To_Assemble_Binary,
	Failed_To_Parse_Section,
	Failed_To_Parse_Label,
	Unexpected_Token,
}

Token_Kind :: enum {
	Instruction,
	Register,
	Immediate_Integer,
	Immediate_String,
	Directive,
	Symbol,
	Comment,
	Unknown,
	EOF,
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
