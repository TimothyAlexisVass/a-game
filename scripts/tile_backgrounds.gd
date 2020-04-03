extends Node2D

var tile_background = preload("res://scenes/tile_background.tscn")

func _ready():
	for column in Main.board_size:
		for row in Main.board_size:
			var tile_bg = tile_background.instance()
			tile_bg.get_node("Panel").rect_scale = Vector2(Main.tile_scale, Main.tile_scale)
			tile_bg.get_node("Panel").rect_position = Vector2(-Main.tile_offset/2, -Main.tile_offset/2)
			add_child(tile_bg)
			tile_bg.position = Main.board_to_pixel(Vector2(column, row))
