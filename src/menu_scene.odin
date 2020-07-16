package main

import "core:fmt"
import "core:math"
import rl "shared:raylib-odin/raylib"

menu_update :: proc(game_scene: ^Scene, delta_time: f32) {
	elements := cast(^[dynamic]^UI_Element)game_scene.data;

	play_button := cast(^Button)elements[0];

	if rl.get_mouse_x() >= play_button.x && rl.get_mouse_x() <= play_button.x + play_button.width &&
	   rl.get_mouse_y() >= play_button.y && rl.get_mouse_y() <= play_button.y + play_button.height {

	   	if rl.is_mouse_button_down(.LEFT_BUTTON) {
	   		play_button.current_color = play_button.press_color;
	   		start_game();
	   	}
	   	else {
	   		play_button.current_color = play_button.hightlight_color;
	   	}	
	}
	else {
		play_button.current_color = play_button.color;
	}
}

// Need simple gui support
menu_draw :: proc(menu_scene: ^Scene) {
	elements := cast(^[dynamic]^UI_Element)menu_scene.data;
	play_button := cast(^Button)elements[0];
	play_label := cast(^Label)elements[1];
	title_label := cast(^Label)elements[2];

	rl.begin_drawing();
	rl.clear_background(rl.RAYWHITE);

	rl.draw_rectangle(
		play_button.x,
		play_button.y,
		play_button.width,
		play_button.height,
		play_button.current_color
	);

	rl.draw_text(
		play_label.text,
		play_label.x,
		play_label.y,
		play_label.font_size,
		play_label.color
	);

	rl.draw_text(
		title_label.text,
		title_label.x,
		title_label.y,
		title_label.font_size,
		title_label.color
	);

	rl.end_drawing();
}

start_game :: proc() {
	game_data.state = Game_State.Game;
}