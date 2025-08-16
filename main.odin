package main

import "core:c"
import "core:fmt"
import rl "vendor:raylib"

width, height, row_height, row_offset, column_width, column_offset: i32

font: rl.Font
font_color := rl.BLACK
background_color := rl.WHITE
font_size: f32 = 40
base_font_size: f32 = 2 * font_size

music_font: rl.Font
music_font_size: f32 = 68
base_music_font_size: f32 = music_font_size * 2

symbols := []rune{'\uE050'}

calculate_layout :: proc() {
	width = rl.GetScreenWidth()
	height = rl.GetScreenHeight()

	row_height = height / 2
	row_offset = row_height / 2
	column_width = width / 3
	column_offset = column_width / 2
}

draw_centered_text_into_grid :: proc(pos: [2]i32, msg: cstring) {
	msg_width := rl.MeasureTextEx(font, msg, font_size, 0)

	pos_vec := [2]f32 {
		(f32(pos.x) * f32(column_width)) + f32(column_offset) - (msg_width.x / 2),
		f32(pos.y * row_height) + f32(row_offset) + font_size,
	}

	rl.DrawTextEx(font, msg, pos_vec, f32(font_size), 0, font_color)
}

main :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

	rl.InitWindow(0, 0, "Odin-MTMC")
	defer rl.CloseWindow()

	font = rl.LoadFontEx(
		"fonts/Courier_Prime/CourierPrime-Regular.ttf",
		i32(base_font_size),
		nil,
		0,
	)
	defer rl.UnloadFont(font)

	music_font = rl.LoadFontEx(
		"fonts/Bravura/Bravura.otf",
		i32(base_music_font_size),
		raw_data(symbols[:]),
		0,
	)
	defer rl.UnloadFont(music_font)

	for !rl.WindowShouldClose() {
		calculate_layout()

		rl.BeginDrawing()
		rl.ClearBackground(background_color)

		draw_centered_text_into_grid({0, 0}, "PDP-11 Lights")
		draw_centered_text_into_grid({0, 1}, "Memory")
		draw_centered_text_into_grid({1, 0}, "Not a Gameboy")
		draw_centered_text_into_grid({1, 1}, "Terminal")
		draw_centered_text_into_grid({2, 0}, "Code Editor")
		draw_centered_text_into_grid({2, 1}, "Code Editor")

		rl.DrawTextCodepoint(
			music_font,
			symbols[0],
			{f32(width / 2), f32(height / 2)},
			f32(base_music_font_size),
			font_color,
		)

		rl.EndDrawing()
	}
}
