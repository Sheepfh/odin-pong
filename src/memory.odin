package main

import "core:fmt"
import "core:mem"

// TODO: Make a context allocator

kilobyte :: 1024;
megabyte :: kilobyte * 1024;
gigabyte :: megabyte * 1024;

Arena :: struct {
	memory: []byte,
	current_offset: int,
}

create_arena :: proc($size: int) -> Arena {
	arena: Arena;
	arena.memory = make([]byte, size);
	mem.zero(&arena.memory[0], size);
	return arena;
}

delete_arena :: proc(arena: ^Arena) {
	delete(arena.memory);
	arena.memory = {};
}

arena_alloc :: proc(arena: ^Arena, size: int, alignment: int) -> rawptr {
	if size == 0 {
		return nil;
	}

	start := mem.align_forward_int(arena.current_offset, alignment);

	if (start + size) > len(arena.memory) {
		panic("Arena out of memory");
	}

	arena.current_offset = start + size;
	ptr := &arena.memory[start];

	return ptr;
}