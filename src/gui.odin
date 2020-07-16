package main

import rl "shared:raylib-odin/raylib"

UI_Element :: struct {
	x: i32,
	y: i32,
	width: i32,
	height: i32,
}

Button :: struct {
	using element: UI_Element,
	current_color: rl.Color,
	color: rl.Color,
	press_color: rl.Color,
	hightlight_color: rl.Color,
}

Label :: struct {
	using element: UI_Element,
	text: cstring,
	font_size: i32,
	color: rl.Color
}

create_button :: proc(storage: ^Arena, x, y, width, height: i32, color, press, hightlight: rl.Color) -> ^Button {
	button := (^Button)(arena_alloc(storage, size_of(Button), 4));
	button.x = x;
	button.y = y;
	button.width = width;
	button.height = height;
	button.color = color;
	button.current_color = color;
	button.press_color = press;
	button.hightlight_color = hightlight;

	return button;
}

create_label :: proc(storage: ^Arena, x, y: i32, text: cstring, font_size: i32, color: rl.Color) -> ^Label {
	label := (^Label)(arena_alloc(storage, size_of(Label), 4));
	label.x = x;
	label.y = y;
	label.width = rl.measure_text(text, font_size);
	label.height = font_size;
	label.text = text;
	label.font_size	 = font_size;
	label.color = color;

	return label;
}