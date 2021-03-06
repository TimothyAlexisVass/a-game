extends Node2D

var prime = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167]
var fibonnacci = [2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514299, 832040]

var number_length = 1
var tile_order: int
var value = 0
onready var tween = get_node("Tween")

func _enter_tree():
	set_value()
	# Scale is set to .1 because it will grow to 1
	# in _ready() when added to the board.
	self.scale = Vector2(.1, .1)

func _ready():
	# Grow the tile when added to the board
	tween.interpolate_property(self, "scale", Vector2(.1, .1), Vector2(Main.tile_scale, Main.tile_scale), .6, tween.TRANS_CUBIC, tween.EASE_OUT)
	tween.start()
	# Global.data.top_tile_order for tile_order achievement
	if tile_order > Global.data.top_tile_order:
		Global.data.top_tile_order = tile_order

func set_value():
	set_color()
	if Main.upgrades_panel.open_upgrades[1].level == 0:
		value = tile_order + 1
		get_node("Value").text = ""
	else:
		if Global.data.increment == Global.increment_type.ADD:
			if Global.data.tile_base == 0:
				value = (Global.data.tile_base + 1) * tile_order
			else:
				value = Global.data.tile_base * tile_order + 1
		elif Global.data.increment == Global.increment_type.PRIME:
			value = Global.data.tile_base * prime[tile_order]
		elif Global.data.increment == Global.increment_type.FIBONNACCI:
			value = Global.data.tile_base * fibonnacci[tile_order]
		elif Global.data.increment == Global.increment_type.DOUBLE:
			value = Global.data.tile_base * pow(2, tile_order + 1)
		elif Global.data.increment == Global.increment_type.MULTIPLY:
			value = pow(Global.data.tile_base, tile_order + 1)
		else:
			value = pow(Global.data.tile_base, tile_order * Global.data.tile_base)
		# Set font size
		if value > 0:
			number_length = 1 + floor(log(value)/log(10))
		var string = "res://assets/fonts/length" + str(number_length) + ".tres"
		var font = load(string)
	
		get_node("Value").add_font_override("font", font)
		get_node("Value").text = str(value)

func set_color():
	var border_color
	var shadow_color
	var background_color

	match tile_order:
		0:
			border_color = "0f773e"
			shadow_color = "3bd300"
			background_color = "8fff2f"
		1:
			border_color = "1d585a"
			shadow_color = "3ca370"
			background_color = "3bd300"
		2:
			border_color = "1b3e3f"
			shadow_color = "3d6e70"
			background_color = "3ca370"
		3:
			border_color = "3b4bab"
			shadow_color = "4da6ff"
			background_color = "66ffe3"
		4:
			border_color = "322947"
			shadow_color = "4b5bab"
			background_color = "4da6ff"
		5:
			border_color = "231d32"
			shadow_color = "473b78"
			background_color = "4b5bab"
		6:
			border_color = "611506"
			shadow_color = "d01c1a"
			background_color = "fb692a"
		7:
			border_color = "4c040b"
			shadow_color = "920716"
			background_color = "d01c1a"
		8:
			border_color = "1f0205"
			shadow_color = "54040d"
			background_color = "920716"
		9:
			border_color = "e14d36"
			shadow_color = "f2a70a"
			background_color = "f2ef23"
		10:
			border_color = "a12d16"
			shadow_color = "f2640a"
			background_color = "f2a70a"
		11:
			border_color = "79205c"
			shadow_color = "bf3391"
			background_color = "ff66ce"
		12:
			border_color = "5e1d4f"
			shadow_color = "892a73"
			background_color = "bf3391"
		13:
			border_color = "341032"
			shadow_color = "4e184a"
			background_color = "892a73"
		14:
			border_color = "e10000"
			shadow_color = "ff8452"
			background_color = "ffb570"
		15:
			border_color = "b20028"
			shadow_color = "ff3b26"
			background_color = "ff8452"
		_:
			border_color = "333333"
			shadow_color = "bbbbbb"
			background_color = "ffffff"

	get_node("Border").modulate = Color(border_color)
	get_node("Shadow").modulate = Color(shadow_color)
	get_node("Background").modulate = Color(background_color)

func move(new_position):
	tween.interpolate_property(self, "position", position, new_position, .5, tween.TRANS_ELASTIC, tween.EASE_OUT)
	tween.start()

func collect_tile(new_position):
	tween.interpolate_property(self, "position", position, new_position, .5, tween.TRANS_ELASTIC, tween.EASE_OUT)
	tween.start()
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .4, tween.TRANS_SINE, tween.EASE_OUT)
	tween.start()
	tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0.3, 0.3), .5, tween.TRANS_CIRC, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.5), "timeout")
	self.queue_free()

func clear_tile():
	#Fade out and grow tile when cleared
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .4, tween.TRANS_SINE, tween.EASE_OUT)
	tween.start()
	tween.interpolate_property(self, "scale", Vector2(1, 1), Vector2(1.4 * Main.tile_scale, 1.4 * Main.tile_scale), 1, tween.TRANS_CIRC, tween.EASE_OUT)
	tween.start()
	yield(get_tree().create_timer(.7), "timeout")
	self.queue_free()
