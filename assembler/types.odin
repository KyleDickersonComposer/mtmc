package assembler

Assembler_Error :: union {
	Parse_Error,
}

Parse_Error :: enum {
	Invalid_Rune,
}

Parsed_Command :: struct {}
