package main

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

width, height, row_height, row_offset, column_width, column_offset: i32

font_size: i32 = 40
base_font_size: i32 = 2 * font_size

font: rl.Font

calculate_layout :: proc() {
	width = rl.GetScreenWidth()
	height = rl.GetScreenHeight()

	row_height = height / 2
	row_offset = row_height / 2
	column_width = width / 3
	column_offset = column_width / 2
}

draw_centered_text_into_grid :: proc(pos: [2]i32, msg: cstring) {
	msg_width := rl.MeasureText(msg, font_size)

	pos_vec := [2]f32 {
		f32((pos.x * column_width) + column_offset - (msg_width / 2)),
		f32((pos.y * row_height) + row_offset + font_size),
	}

	rl.DrawTextEx(font, msg, pos_vec, f32(font_size), 0, rl.WHITE)
}

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

	rl.InitWindow(0, 0, "Odin-MTMC")
	defer rl.CloseWindow()

	font = rl.LoadFontEx("fonts/Courier_Prime/CourierPrime-Regular.ttf", base_font_size, nil, 0)
	defer rl.UnloadFont(font)

	for !rl.WindowShouldClose() {
		calculate_layout()

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		draw_centered_text_into_grid({0, 0}, "PDP-11 Lights")
		draw_centered_text_into_grid({0, 1}, "Memory")
		draw_centered_text_into_grid({1, 0}, "Not a Gameboy")
		draw_centered_text_into_grid({1, 1}, "Terminal")
		draw_centered_text_into_grid({2, 0}, "Code Editor")
		draw_centered_text_into_grid({2, 1}, "Code Editor")

		rl.EndDrawing()
	}
}
