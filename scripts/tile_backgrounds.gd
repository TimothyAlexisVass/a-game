extends Node2D

var tile_background = preload("res://scenes/tile_background.tscn")

func _ready():
	for column in Main.width:
		for row in Main.height:
			var tile_bg = tile_background.instance()
			tile_bg.get_node("Panel").rect_scale = Vector2(Main.scale_x, Main.scale_y)
			tile_bg.get_node("Panel").rect_position = Vector2(-Main.offset_x/2, -Main.offset_y/2)
			add_child(tile_bg)
			tile_bg.position = Main.grid_to_pixel(Vector2(column, row))
