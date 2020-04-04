extends Node2D

enum increment_type {ADD, PRIME, FIBONNACI, DOUBLE, MULTIPLY, ULTIMATE}
var increment = increment_type.DOUBLE

var board_size = 2
var tile_scale
var tile_position
var tile_offset
	
var starting_tiles = 1
var order = 0
var base = 0

var tile_background = preload("res://scenes/tile_background.tscn")
var all_tile_backgrounds = null

var income_timer
var move_timer
var moves_left
var move_enabled = false
var add_moves_amount = 1
var auto_add_moves

var coins = 3000.0
var total_coins_ever = 3000.0
var base_income = 0.0
var board_income = 0.0
var total_income = 0.0
var income_multiplier = 1
var full_board_multiplier = 1

onready var tween = get_node("/root/main/Tween")
onready var upgrades_panel = get_node("/root/main/Upgrades")
onready var upgrades_button = get_node("/root/main/UpgradesButton")
onready var achievements_panel = get_node("/root/main/Achievements")
onready var achievements_button = get_node("/root/main/AchievementsButton")
onready var move_timer_bar = get_node("/root/main/Info/MoveInfo/MoveTimerBar")
onready var moveinfo = get_node("/root/main/Info/MoveInfo")
var profit_indicator = preload("res://scenes/profit_indicator.tscn")
var show_profit

func _ready():
	for button in get_tree().get_nodes_in_group("User Interface Buttons"):
		button.connect("pressed", Main, "_on_UI_button_pressed", [button])
		button.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	for timer in get_tree().get_nodes_in_group("Timers"):
		timer.connect("timeout", Main, "_on_Timer_timeout", [timer])
	
	set_board_variables()
	
	if Main.board_size == 2:
		Main.moveinfo.visible = false
		Main.achievements_button.visible = false
		Main.upgrades_button.disabled = true
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parenthesis").visible = false
	
	Main.full_board_multiplier = Main.base * 3 + 1
	Main.moves_left = 100
	set_moves()
	set_total()
	
	Main.move_timer = 10
	Main.income_timer = 10
	get_node("/root/main/MoveTimer").set_wait_time(Main.move_timer)
	get_node("/root/main/IncomeTimer").set_wait_time(Main.income_timer)
	
func _process(_delta):
	move_timer_bar.value = 100 * (Main.move_timer - get_node("/root/main/MoveTimer").time_left) / Main.move_timer

func set_board_variables():
	Main.tile_scale = 4.0 / Main.board_size
	Main.tile_position = 576 / (Main.board_size + 2)
	Main.tile_offset = 4.0 / Main.board_size * 128
	if Main.board_size == 2:
		Main.tile_position += 16

func generate_tile_backgrounds():
	#Generate the tile backgrounds
	if Main.all_tile_backgrounds == null:
		Main.all_tile_backgrounds = []
		for column in Main.board_size:
			for row in Main.board_size:
				var tile_bg = tile_background.instance()
				tile_bg.get_node("Panel").rect_scale = Vector2(Main.tile_scale, Main.tile_scale)
				tile_bg.get_node("Panel").rect_position = Vector2(-Main.tile_offset/2, -Main.tile_offset/2)
				get_node("/root/main/BoardBackground/TileBackgrounds").add_child(tile_bg)
				tile_bg.position = Main.board_to_pixel(Vector2(column, row))
				Main.all_tile_backgrounds.append(tile_bg)

func clear_tile_backgrounds():
	for tile_background in Main.all_tile_backgrounds:
		tile_background.queue_free()
	Main.all_tile_backgrounds = null

func board_to_pixel(board_position):
	return (Vector2(board_position.x * Main.tile_offset + Main.tile_position,
					board_position.y * Main.tile_offset + Main.tile_position))

func change_total(amount, position):
	Main.coins += amount
	if amount > 0:
		Main.total_coins_ever += amount
	
	show_profit = profit_indicator.instance()
	show_profit.position = position
	if amount < 1 and amount > -1:	
		amount = str("%.2f" % (amount))
	elif amount < 10 and amount > -10:
		amount = str("%.1f" % (amount))
	else:
		amount = str(int(amount))
	
	show_profit.value = amount
	show_profit.z_index = 999
	add_child(show_profit)
	set_total()

func set_total():
	var display_total
	if Main.total_income < 1:	
		display_total = str("%.2f" % (Main.coins))
	elif Main.total_income < 10:
		display_total = str("%.1f" % (Main.coins))
	else:
		display_total = str(int(Main.coins))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").text = str(display_total)

func set_income():
	var display_income
	Main.total_income = (Main.base_income + Main.board_income) * Main.income_multiplier
	display_income = Main.total_income / Main.income_timer
	
	if Main.total_income < 1:	
		display_income = str("%.2f" % (display_income))
	elif Main.total_income < 10:	
		display_income = str("%.1f" % (display_income))
	else:
		display_income = str(int(display_income))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").text = "(+" + display_income + "/"

func make_move():
	if auto_add_moves and Main.moves_left == 0:
		change_total(-10, get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
		set_total()
	else:
		Main.moves_left -=1
		set_moves()

func set_moves():
	var indicator_color
	if Main.moves_left < 50:
		indicator_color = Color(1, Main.moves_left/50.0, 0)
	elif Main.moves_left >= 50 and Main.moves_left < 100:
		indicator_color = Color(1-(Main.moves_left-50)/50.0, 1, 0)
	else:
		indicator_color = Color(0,1,0)
		
	move_timer_bar.modulate = indicator_color
	get_node("/root/main/Info/MoveInfo/AddMovesButton").text = str(Main.moves_left)

func _on_UI_button_pressed(button):
	if button.name == "AchievementsButton":
		Main.achievements_panel.visible = true
		Main.upgrades_button.visible = false
		Main.achievements_button.visible = false
		Main.move_enabled = false
		tween.interpolate_property(Main.achievements_panel, "rect_position", Vector2(16, 850), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
		tween.start()
	elif button.name == "UpgradesButton":
		Main.upgrades_panel.visible = true
		Main.upgrades_button.visible = false
		Main.achievements_button.visible = false
		Main.move_enabled = false
		tween.interpolate_property(Main.upgrades_panel, "rect_position", Vector2(16, 870), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
		tween.start()
	elif button.name == "CloseButton":
		Main.upgrades_button.visible = true
		Main.achievements_button.visible = true
		tween.interpolate_property(button.get_parent(), "rect_position", Vector2(16, 16), Vector2(16, 870), .6, tween.TRANS_EXPO, tween.EASE_OUT)
		tween.start()
		yield(get_tree().create_timer(.6), "timeout")
		Main.move_enabled = true
		button.get_parent().visible = false
	elif button.name == "MoveAmountButton":
		Main.auto_add_moves = !Main.auto_add_moves
		if Main.auto_add_moves == true:
			get_node("/root/main/Info/MoveInfo/AddMovesButton/MoveAmountButton").text = "AUTO"
		else:
			get_node("/root/main/Info/MoveInfo/AddMovesButton/MoveAmountButton").text = "X" + str(Main.add_moves_amount)
	elif button.name == "AddMovesButton":
		if Main.coins > 10 * Main.add_moves_amount:
			Main.moves_left += 1 * Main.add_moves_amount
			change_total(-10 * Main.add_moves_amount, \
			get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
		set_moves()
		set_total()
	elif button.name == "RecycleButton":
		get_node("/root/main/BoardBackground/TileBoard").recycle()

func _on_Timer_timeout(timer):
	if timer.name == "IncomeTimer":
		if Main.total_income > 0:
			change_total(Main.total_income, get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").get_global_position() + Vector2(85,0))
	elif timer.name == "MoveTimer":
		Main.moves_left += 1
		set_moves()
	elif timer.name == "MainTimer":
		# Refresh everything
		pass
