package main

import "core:fmt"
import "core:math"
import rl "shared:raylib-odin/raylib"

Game_Scene_State :: enum {
	Pause_Menu,
	Pause_Start,
	Play
}

Game_Scene_Data :: struct {
	state: Game_Scene_State,
	entities: ^[dynamic]^Entity,
	gui_elements: ^[dynamic]^UI_Element
}

game_update :: proc(game_scene: ^Scene, delta_time: f32) {
	data := cast(^Game_Scene_Data)game_scene.data;
	update_gui(data);
	if data.state != .Play {
		return;
	}

	// NOTE: not sure about this
	player := cast(^Paddle)data.entities[0];
	ai := cast(^Paddle)data.entities[1];
	ball := cast(^Ball)data.entities[2];

	update_player(player, delta_time);
	update_ai(ai, ball, delta_time);
	scored, type := update_ball(ball, player, ai, delta_time);

	if scored {
		data.state = .Pause_Start;
		score_point(type, data);
		reset_ball(ball);
		reset_paddles(player, ai);
	}
}

update_player :: proc(player: ^Paddle, delta_time: f32) {
	if rl.is_key_down(.W) {
		if player.y > 0 {
			player.y -= i32(500 * delta_time);
		} 
	}
	if rl.is_key_down(.S) {
		if player.y + player.height < SCREEN_HEIGHT {
			player.y += i32(500 * delta_time);
		}
	}
	player.bounding_box.origin[0] = f32(player.x);
	player.bounding_box.origin[1] = f32(player.y);
	player.bounding_box.center[0] = f32(player.x + player.width);
	player.bounding_box.center[1] = f32(player.y + player.height);
}

update_ai :: proc(ai: ^Paddle, ball: ^Ball, delta_time: f32){
	if ball.x < SCREEN_WIDTH / 2 + (100 / game_data.difficulty) {
		return;
	}
	ai_distance := ball.y - (ai.y + ai.height / 2);
	if ai_distance > 30 && ai.y + ai.height < SCREEN_HEIGHT {
		ai.y += i32(500 * delta_time);
	}
	else if ai_distance < -30 && ai.y > 0{
		ai.y -= i32(500 * delta_time);
	}
	ai.bounding_box.origin[0] = f32(ai.x);
	ai.bounding_box.origin[1] = f32(ai.y);
	ai.bounding_box.center[0] = f32(ai.x + ai.width);
	ai.bounding_box.center[1] = f32(ai.y + ai.height);
}

update_ball :: proc(ball: ^Ball, player, ai: ^Paddle, delta_time: f32) -> (bool, Player_Type) {
	// Check collisions with players
	player_collision: bool = false;
	ai_collision: bool = false;
	//point_scored: bool = false;
	//player_scoring : Player_Type; 

	ball_width: i32 = i32(ball.radius * 2);

	// NOTE: Only check collision on the relevant paddle given the current
	// ball position 
	if ball.x < SCREEN_WIDTH / 2 {
		player_collision = detect_collision(
			&ball.bounding_box, &player.bounding_box
		);
		if player_collision {
			dist := f32(ball.y) - f32(player.y + player.height / 2);
			dist = dist / f32(player.height / 2);

			ball.vel[1] = (dist * ball.max_velY); 
		}
	}
	else if ball.x > SCREEN_WIDTH / 2 {
		ai_collision = detect_collision(
			&ball.bounding_box, &ai.bounding_box
		);
		if ai_collision {
			dist := f32(ball.y) - f32(ai.y + ai.height / 2);
			dist = dist / f32(ai.height / 2);

			ball.vel[1] = dist * ball.max_velY; 
		}
	}

	if player_collision || ai_collision {
		ball.vel[0] *= -1;
		rl.play_sound(collision_sound);
	}
	if ball.y <= 0 || ball.y >= SCREEN_HEIGHT {
		ball.vel[1] *= -1;
		rl.play_sound(collision_sound);
	}

	if ball.x <= 0 {
		return true, .AI;
	}
	else if ball.x >= SCREEN_WIDTH
	{
		return true, .Player;
	}

	ball.x += i32(ball.vel[0] * delta_time);
	ball.y += i32(ball.vel[1] * delta_time);
	ball.bounding_box.origin[0] = f32(ball.x) - ball.radius;
	ball.bounding_box.origin[1] = f32(ball.y) - ball.radius;
	ball.bounding_box.center[0] = f32(ball.x);
	ball.bounding_box.center[1] = f32(ball.y);
	return false, .Invalid;
}

update_gui :: proc(data: ^Game_Scene_Data) {
	if rl.is_key_released(.ENTER) {
		switch data.state {
		case .Pause_Menu:
			data.state = .Play;
		case .Play:
			data.state = .Pause_Menu;
		case .Pause_Start:
			data.state = .Pause_Menu;
		}
	}

	if rl.is_key_released(.SPACE) && data.state == .Pause_Start {
		data.state = .Play;
	}
}

score_point :: proc(type: Player_Type, scene_data: ^Game_Scene_Data) {
	switch type {
	case .Player:
		player_score := cast(^Label)scene_data.gui_elements[0];
		game_data.player_score += 1;
		player_score.text = cstring(raw_data(fmt.tprintf("%d\x00", game_data.player_score)));

	case .AI:
		ai_score := cast(^Label)scene_data.gui_elements[1];
		game_data.ai_score += 1;
		ai_score.text = cstring(raw_data(fmt.tprintf("%d\x00", game_data.ai_score)));
	case .Invalid:
	}
}

reset_ball :: proc(ball: ^Ball) {
	ball.x = SCREEN_WIDTH / 2;
	ball.y = SCREEN_HEIGHT / 2;
	ball.vel[0] = -700;
	ball.vel[1] = 100;
}

reset_paddles :: proc(player, ai: ^Paddle) {
	player.y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
	ai.y = SCREEN_HEIGHT / 2 - PADDLE_HEIGHT / 2;
}


game_draw :: proc(game_scene: ^Scene) {
	data := cast(^Game_Scene_Data)game_scene.data;

	player := cast(^Paddle)data.entities[0];
	ai := cast(^Paddle)data.entities[1];
	ball := cast(^Ball)data.entities[2];

	rl.begin_drawing();
	rl.clear_background(rl.RAYWHITE);
	rl.draw_rectangle(
		player.x,
		player.y,
		player.width,
		player.height,
		ENTITY_COLOR
	);

	rl.draw_rectangle(
		ai.x,
		ai.y,
		ai.width,
		ai.height,
		ENTITY_COLOR
	);

	rl.draw_circle(
		ball.x,
		ball.y,
		ball.radius,
		ENTITY_COLOR
	);

	draw_gui(game_data, data);
	rl.end_drawing();
}

draw_gui :: proc(game_data: ^Game_Data, game_scene_data: ^Game_Scene_Data) {
	player_score := cast(^Label)game_scene_data.gui_elements[0];
	ai_score := cast(^Label)game_scene_data.gui_elements[1];

	rl.draw_rectangle(
			SCREEN_WIDTH / 2 - 2,
			0,
			4,
			SCREEN_HEIGHT,
			ENTITY_COLOR
	);

	rl.draw_rectangle(
			SCREEN_WIDTH / 2 - 75,
			0,
			150,
			50,
			ENTITY_COLOR
	);

	rl.draw_rectangle(
			SCREEN_WIDTH / 2 - 2,
			0,
			4,
			50,
			rl.RAYWHITE
	);

	rl.draw_text(
		player_score.text,
		player_score.x,
		player_score.y,
		player_score.font_size,
		player_score.color
	);

	rl.draw_text(
		ai_score.text,
		ai_score.x,
		ai_score.y,
		ai_score.font_size,
		ai_score.color
	);

	if game_scene_data.state == .Pause_Start {
		start_msg : cstring = "Press SPACE to start";
		origin_x : i32 = (SCREEN_WIDTH / 2) - (rl.measure_text(start_msg, 20) / 2);
		origin_y : i32 = SCREEN_HEIGHT - 30;
		rl.draw_text(
			start_msg,
			origin_x,
			origin_y,
			20,
			rl.DARKGRAY
		);
	}
}