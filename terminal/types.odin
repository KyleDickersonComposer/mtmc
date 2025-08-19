package mtmc_terminal

Terminal_Error :: union {
	Parse_Error,
}

Parse_Error :: enum {
	Failed,
}

Parsed_Command :: struct {}
