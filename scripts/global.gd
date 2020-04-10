extends Node

enum increment_type {ADD, PRIME, FIBONNACCI, DOUBLE, MULTIPLY, ULTIMATE}

var data = {
	"increment": increment_type.ADD,
	"board_size": 2,
	"starting_tiles": 1,
	"tile_order": 0,
	"top_tile_order": 0,
	"tile_base": 0,
	"all_tiles": [],
	"tile_levels": [],
	"income_timer": 12,
	"move_timer": 10,
	"moves_left": 500,
	"coins": 0.0,
	"total_coins": 0.0,
	"total_recycles": 0,
	"base_income": 0.0,
	"board_income": 0.0,
	"total_income": 0.0,
	"income_multiplier": 1,
	"full_board_multiplier": 1,
	"upgrades_levels": {},
	"achievements_levels": {},
}
