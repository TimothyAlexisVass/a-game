extends Node

enum increment_type {ADD, PRIME, FIBONNACCI, DOUBLE, MULTIPLY, ULTIMATE}

var data = {
	"name": "Human",
	"increment": increment_type.ADD,
	"board_size": 2,
	"starting_tiles": 1,
	"tile_order": 0,
	"top_tile_order": 0,
	"tile_base": 0,
	"combinations_done": 0,
	"tile_levels": null,
	"income_timer": 12,
	"energy_timer": 10,
	"energy": 200,
	"total_moves": 0,
	"coins": 0.0,
	"total_coins": 0.0,
	"total_recycles": 0,
	"base_income": 0.0,
	"board_income": 0.0,
	"total_income": 0.0,
	"combination_multiplier": 0.01,
	"income_multiplier": 1,
	"full_board_multiplier": 1,
	"upgrades_levels": {},
	"achievements_levels": {}
}
