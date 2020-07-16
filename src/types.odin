package main

Vector2 :: [2]f32;

Game_State :: enum {
	Menu,
	Game
}

Player_Type :: enum {
	Player,
	AI, 
	Invalid
}

Game_Data :: struct {
	state: Game_State,
	difficulty: i32,
	player_score: i32,
	ai_score: i32,
}

Scene :: struct {
	data: rawptr,
	update_proc: proc(^Scene, f32),
	draw_proc: proc(^Scene)
}

Entity :: struct {
	x: i32,
	y: i32
}

Paddle :: struct {
	using entity: Entity,
	width: i32,
	height: i32,
	bounding_box: Bounding_Box
}

Ball :: struct {
	using entity: Entity,
	radius: f32,
	vel: Vector2,
	max_velY: f32,
	bounding_box: Bounding_Box
}

Bounding_Box :: struct {
	origin: Vector2,
	width, height: f32,
	center: Vector2
}

create_scene :: proc(data: rawptr, update: proc(^Scene, f32), draw: proc(^Scene)) -> Scene {
	scene: Scene;
	scene.data = data;
	scene.update_proc = update;
	scene.draw_proc = draw;

	return scene;
}

create_paddle :: proc(storage: ^Arena, x, y, width, height: i32) -> ^Paddle {
	paddle := (^Paddle)(arena_alloc(storage, size_of(Paddle), 4));
	paddle.x = x;
	paddle.y = y;
	paddle.width = width;
	paddle.height = height;

	paddle.bounding_box.origin[0] = f32(x);
	paddle.bounding_box.origin[1] = f32(y);
	paddle.bounding_box.width = f32(width);
	paddle.bounding_box.height = f32(height);
	paddle.bounding_box.center[0] = f32(x + width / 2);
	paddle.bounding_box.center[1] = f32(y + height / 2);

	return paddle;
}

create_ball :: proc(storage: ^Arena, x, y: i32, radius, velX, velY, max_velY: f32) -> ^Ball {
	ball := (^Ball)(arena_alloc(storage, size_of(Ball), 4));
	ball.x = x;
	ball.y = y;
	ball.radius = radius;
	ball.vel[0] = velX;
	ball.vel[1] = velY;
	ball.max_velY = max_velY;

	ball.bounding_box.origin[0] = f32(x) - radius;
	ball.bounding_box.origin[1] = f32(y) - radius;
	ball.bounding_box.width = f32(radius);
	ball.bounding_box.height = f32(radius);
	ball.bounding_box.center[0] = f32(x);
	ball.bounding_box.center[1] = f32(y);
	return ball;
}