extends Node2D

var order = Main.order
var value = 0
onready var animation = get_node("Animation")
onready var clear = get_node("Clear")

func _enter_tree():
	set_value()

func _ready():
	set_order(order)
	#self.scale = Vector2(Main.scale_x, Main.scale_y)
#	Grow the tile when entering the board
	animation.interpolate_property(self, "scale", Vector2(.3, .3), Vector2(Main.scale_x, Main.scale_y), .4, animation.TRANS_CIRC, animation.EASE_OUT)
	animation.start()

func set_order(number):
	order = number
	set_value()
	set_color()

func set_value():
	if Main.base == 0:
		value = .01
		get_node("Value").text = ""
	else:
		if Main.increment == Main.increment_type.ADD:
			value = Main.base * (order+1)
		elif Main.increment == Main.increment_type.DOUBLE:
			value = Main.base * pow(2, order)
		elif Main.increment == Main.increment_type.MULTIPLY:
			value = Main.base * pow(Main.base, order)
		else:
			value = pow(Main.base, order + 1)
	#	Set font size
		var number_length = 1 + floor(log(value)/log(10))
		var string = "res://assets/tile_fonts/length" + str(number_length) + ".tres"
		var font = load(string)
	
		get_node("Value").add_font_override("font", font)
		get_node("Value").text = str(value)

func set_color():
	var border_color
	var shadow_color
	var background_color

	match order:
		0:
			border_color = "3ca370"
			shadow_color = "8fde5d"
			background_color = "c6f65d"
		1:
			border_color = "1d585a"
			shadow_color = "3ca370"
			background_color = "8fde5d"
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
	animation.interpolate_property(self, "position", position, new_position, .5, animation.TRANS_ELASTIC, animation.EASE_OUT)
	animation.start()

func collect(new_position):
	animation.interpolate_property(self, "position", position, new_position, .5, animation.TRANS_ELASTIC, animation.EASE_OUT)
	animation.start
	animation.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .4, animation.TRANS_SINE, animation.EASE_OUT)
	animation.start()
	animation.interpolate_property(self, "scale", Vector2(1, 1), Vector2(0.3, 0.3), .5, animation.TRANS_ELASTIC, animation.EASE_OUT)
	animation.start()
	yield(get_tree().create_timer(.4), "timeout")
	self.queue_free()

func clear_tile():
	#Fade out and grow tile when cleared
	animation.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .4, animation.TRANS_SINE, animation.EASE_OUT)
	animation.start()
	animation.interpolate_property(self, "scale", Vector2(1, 1), Vector2(1.4 * Main.scale_x, 1.4 * Main.scale_y), .4, animation.TRANS_CIRC, animation.EASE_OUT)
	animation.start()
	yield(get_tree().create_timer(.4), "timeout")
	self.queue_free()
