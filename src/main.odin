package main

import "core:fmt"
import "core:math"
import rl "shared:raylib-odin/raylib"

SCREEN_WIDTH :: 800;
SCREEN_HEIGHT :: 450;

PADDLE_WIDTH :: 10;
PADDLE_HEIGHT :: 100;

ENTITY_COLOR :: rl.LIGHTGRAY;

//Global variables
game_data: ^Game_Data;
collision_sound: rl.Sound;

main :: proc() {
	perm_storage := create_arena(4 * megabyte);
	delta_time: f32;

	rl.init_window(SCREEN_WIDTH, SCREEN_HEIGHT, "Odin Pong");

	rl.set_target_fps(60);
	rl.init_audio_device();
	collision_sound = rl.load_sound("res/pong.wav");
	defer rl.unload_sound(collision_sound);
	defer rl.close_audio_device();
	rl.set_sound_volume(collision_sound, 0.1);
	//
	// Initialize global game state
	game_data = (^Game_Data)(arena_alloc(&perm_storage, size_of(Game_Data), 4));
	game_data.state = Game_State.Menu;
	game_data.difficulty = 4;
	game_data.player_score = 0;
	game_data.ai_score = 0;

	//
	// Initialize menu scene
	menu_data : [dynamic]^UI_Element;
	defer delete(menu_data);

	play_button := create_button(
		&perm_storage, 
		SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 50, 200, 100,
		ENTITY_COLOR, rl.DARKGRAY, rl.GRAY
	);
	append(&menu_data, play_button);

	label_origin_x: i32 = 
		(play_button.x + play_button.width / 2) - (rl.measure_text("Play", 40) / 2);
	label_origin_y: i32 = 
		(play_button.y + play_button.height / 2) - (40 / 2);
	play_label := create_label(
		&perm_storage,
		label_origin_x, label_origin_y, "Play", 40, rl.DARKGRAY
	);
	append(&menu_data, play_label);

	title_origin_x: i32 = 
		(SCREEN_WIDTH / 2) - (rl.measure_text("Pong", 60) / 2);
	title_origin_y: i32 = 
		(SCREEN_HEIGHT / 2 - 150) - (40 / 2);
	title_label := create_label(
		&perm_storage,
		title_origin_x, title_origin_y, "Pong", 60, rl.DARKGRAY
	);
	append(&menu_data, title_label);

	menu_scene := create_scene(&menu_data, menu_update, menu_draw);

	//
	// Initialize game scene
	game_scene_data : Game_Scene_Data;
	entities: [dynamic]^Entity;
	defer delete(entities);
	
	player_paddle := create_paddle(
		&perm_storage, 20, (SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2), PADDLE_WIDTH, PADDLE_HEIGHT
	);
	append(&entities, player_paddle);

	ai_paddle := create_paddle(
		&perm_storage, SCREEN_WIDTH - 20, (SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2), PADDLE_WIDTH, PADDLE_HEIGHT
	);
	append(&entities, ai_paddle);

	ball := create_ball(
		&perm_storage, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, 5, -700, 100, 300
	);
	append(&entities, ball);

	//gui
	gui_elements: [dynamic]^UI_Element;
	defer delete(gui_elements);

	player_score_origin_x : i32 = 
		(SCREEN_WIDTH / 2 - 75 / 2) - (rl.measure_text("0", 40) / 2);
	player_score_origin_y : i32 = (50 / 2) - (40 / 2);
	p_score_label := create_label(
		&perm_storage,
		player_score_origin_x, player_score_origin_y, "0", 40, rl.DARKGRAY
	);
	append(&gui_elements, p_score_label);

	ai_score_origin_x : i32 = 
		(SCREEN_WIDTH / 2 + 75 / 2) - (rl.measure_text("0", 40) / 2);
	ai_score_origin_y : i32 = (50 / 2) - (40 / 2);
	ai_score_label := create_label(
		&perm_storage,
		ai_score_origin_x, ai_score_origin_y, "0", 40, rl.DARKGRAY
	);
	append(&gui_elements, ai_score_label);

	game_scene_data.entities = &entities;
	game_scene_data.gui_elements = &gui_elements;
	game_scene_data.state = .Pause_Start;

	game_scene := create_scene(&game_scene_data, game_update, game_draw);

	for !rl.window_should_close() {

		delta_time = rl.get_frame_time();

		switch game_data.state {
		case .Menu:
			menu_scene.update_proc(&menu_scene, delta_time);
			menu_scene.draw_proc(&menu_scene);
		case .Game:
			game_scene.update_proc(&game_scene, delta_time);
			game_scene.draw_proc(&game_scene);
		}
		
	}

	rl.close_window();
	delete_arena(&perm_storage);
}

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