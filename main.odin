package main

import "core:c"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

HEADLESS :: #config(HEADLESS, false)

width, height, row_height, row_offset, column_width, column_offset: i32

font: rl.Font
font_color := rl.BLACK
background_color := rl.WHITE
font_size: f32 = 40
base_font_size: f32 = 2 * font_size

music_font: rl.Font
music_font_size: f32 = 100
base_music_font_size: f32 = music_font_size * 2

symbols: []rune

Error :: enum {
	IO_Error,
}

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

graphics_init :: proc() {
	rl.SetConfigFlags(rl.ConfigFlags{.WINDOW_RESIZABLE, .WINDOW_HIGHDPI})

	symbols = make([]rune, 0xF3FF - 0xE000)
	for i in 0 ..< len(symbols) {
		symbols[i] = rune(0xE000 + i)
	}

	rl.InitWindow(0, 0, "Odin-MTMC")

	font = rl.LoadFontEx(
		"fonts/Courier_Prime/CourierPrime-Regular.ttf",
		i32(base_font_size),
		nil,
		0,
	)

	music_font = rl.LoadFontEx(
		"fonts/Bravura/Bravura.otf",
		i32(base_music_font_size),
		raw_data(symbols),
		i32(len(symbols)),
	)
}

graphics_shutdown :: proc() {
	rl.UnloadFont(font)
	rl.UnloadFont(music_font)
	delete(symbols)
	rl.CloseWindow()
}

update :: proc(running: ^bool, buf: []u8) -> Error {
	when HEADLESS {
		fmt.print("> ")
		count, err := os.read(os.stdin, buf)
		if err != nil {
			log.error("failed to read from stdin")
			return .IO_Error
		}

		input := strings.trim_space(transmute(string)buf[:count])

		if input == "hello" {
			fmt.println("Hi! I'm MTMC.")
		}

		if input == "help" || input == "?" {
			fmt.println("No one can help you here!")
		}

		if input == "exit" {
			fmt.println("Buh-bye now!")
			os.exit(0)
		}

	}
	return nil
}

render :: proc() {
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
		symbols[80],
		{f32(width / 2), f32(height / 2)},
		music_font_size,
		font_color,
	)

	rl.EndDrawing()
}

main_loop :: proc() {
	running := true

	io_buf: [256]byte

	when !HEADLESS {
		graphics_init()
		defer graphics_shutdown()
	}

	for running {
		update(&running, io_buf[:])

		when !HEADLESS {
			if rl.WindowShouldClose() do running = false
			render()
		}
	}
}


main :: proc() {
	context.logger = log.create_console_logger()

	main_loop()
}
