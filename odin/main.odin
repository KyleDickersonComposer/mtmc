package main

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

FONT_SIZE: i32 : 32

width, height, row_height, row_offset, column_width, column_offset: i32

calculate_layout :: proc() {
	width = rl.GetScreenWidth()
	height = rl.GetScreenHeight()
	row_height = height / 2
	row_offset = (row_height / 2)
	column_width = width / 3
	column_offset = (column_width / 2)
}


draw_centered_text_into_grid :: proc(pos: [2]i32, msg: cstring, font_size := FONT_SIZE) {
	msg_width := rl.MeasureText(msg, font_size)
	rl.DrawText(
		msg,
		(pos.x * column_width) + column_offset - (msg_width / 2),
		(pos.y * row_height) + row_offset - font_size,
		font_size,
		rl.BLACK,
	)
}

main :: proc() {

	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.InitWindow(0, 0, "Odin-MTMC")

	for !rl.WindowShouldClose() {
		calculate_layout()

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)

		draw_centered_text_into_grid({0, 0}, "PDP-11 Lights")
		draw_centered_text_into_grid({0, 1}, "Memory")
		draw_centered_text_into_grid({1, 0}, "Not a Gameboy")
		draw_centered_text_into_grid({1, 1}, "Terminal")
		draw_centered_text_into_grid({2, 0}, "Code Editor")
		draw_centered_text_into_grid({2, 1}, "Code Editor")

		rl.EndDrawing()
	}
}
