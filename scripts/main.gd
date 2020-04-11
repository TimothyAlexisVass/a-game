extends Node2D

var save_string
var load_string
var global_data_byte_array
var exit_game

var tile_scale
var tile_position
var tile_offset

var move_enabled = false
var add_moves_amount = 1
var auto_add_moves = false

# Tile Variables
var tile_template = preload("res://scenes/tile.tscn")
var all_tiles = null
var tile_background = preload("res://scenes/tile_background.tscn")
var all_tile_backgrounds = null

var notification = preload("res://scenes/notification.tscn")
var display_notification_object
var profit_indicator = preload("res://scenes/profit_indicator.tscn")
var display_profit_object

onready var achievements_button = get_node("/root/main/AchievementsButton")
onready var achievements_panel = get_node("/root/main/Achievements")
onready var income_timer_bar = get_node("/root/main/Info/CoinsInfo/IncomeTimerBar")
onready var move_info = get_node("/root/main/Info/MoveInfo")
onready var move_timer_bar = get_node("/root/main/Info/MoveInfo/MoveTimerBar")
onready var notification_list = get_node("/root/main/Info/NotificationsInfo/ScrollContainer/MarginContainer/VBoxContainer")
onready var recycle_button = get_node("/root/main/RecycleButton")
onready var tile_board = get_node("/root/main/BoardBackground/TileBoard")
onready var tween = get_node("/root/main/Tween")
onready var upgrades_button = get_node("/root/main/UpgradesButton")
onready var upgrades_panel = get_node("/root/main/Upgrades")
onready var http_request_save = get_node("/root/main/HTTPRequestSave")
onready var http_request_load = get_node("/root/main/HTTPRequestLoad")

func _enter_tree():
	# This is to enable saving at exiting the game
	get_tree().set_auto_accept_quit(false)

func _ready():
	Main.recycle_button.visible = false
	Main.achievements_button.visible = false
	Main.upgrades_button.disabled = true
	if http_request_save.connect("request_completed", self, "_on_save_request_completed") == 0:
		print("HTTPRequestSave connected")
	if http_request_load.connect("request_completed", self, "_on_load_request_completed") == 0:
		print("HTTPRequestLoad connected")

	for button in get_tree().get_nodes_in_group("user_interface_button"):
		button.connect("pressed", Main, "_on_user_interface_button_pressed", [button])
		button.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	for timer in get_tree().get_nodes_in_group("Timers"):
		timer.connect("timeout", Main, "_on_Timer_timeout", [timer])

	load_game()

func _process(_delta):
	move_timer_bar.value = 100 * (Global.data.move_timer - get_node("/root/main/MoveTimer").time_left) / Global.data.move_timer
	income_timer_bar.value = 100 * (Global.data.income_timer - get_node("/root/main/IncomeTimer").time_left) / Global.data.income_timer

func _notification(item):
	if (item == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		exit_game = true
		save_game()

func set_board_variables():
	Main.tile_scale = 4.0 / Global.data.board_size
	Main.tile_position = 576 / (Global.data.board_size + 2)
	Main.tile_offset = Main.tile_scale * 128
	if Global.data.board_size == 2:
		Main.tile_position += 16

func generate_tile_backgrounds():
	#Generate the tile backgrounds
	if Main.all_tile_backgrounds == null:
		Main.all_tile_backgrounds = []
		for column in Global.data.board_size:
			for row in Global.data.board_size:
				var tile_background_object = tile_background.instance()
				tile_background_object.get_node("Panel").rect_scale = Vector2(Main.tile_scale, Main.tile_scale)
				tile_background_object.get_node("Panel").rect_position = Vector2(-Main.tile_offset/2, -Main.tile_offset/2)
				get_node("/root/main/BoardBackground/TileBackgrounds").add_child(tile_background_object)
				tile_background_object.position = Main.set_tile_position(Vector2(column, row))
				Main.all_tile_backgrounds.append(tile_background_object)

func resize_tile_board():
	for tile_background in Main.all_tile_backgrounds:
		tile_background.queue_free()
	Main.all_tile_backgrounds = null
	Main.set_board_variables()
	Main.generate_tile_backgrounds()
	
	Main.all_tiles.append([])
	for column in Global.data.board_size:
		for row in Global.data.board_size:
			if column == Global.data.board_size - 1 or row == Global.data.board_size - 1:
				Main.all_tiles[column].append(null)
			if Main.all_tiles[column][row] != null:
				Main.all_tiles[column][row].queue_free()
				tile_board.add_tile(Main.all_tiles[column][row].tile_order, column, row)

func set_tile_position(board_position):
	return (Vector2(board_position.x * Main.tile_offset + Main.tile_position,
					board_position.y * Main.tile_offset + Main.tile_position))

func display_notification(notification_text):
	display_notification_object = notification.instance()
	display_notification_object.text = notification_text
	display_notification_object.percent_visible = 0
	display_notification_object.modulate = Color("00ff00")

	# Allow 10 notifications in the list
	if notification_list.get_child_count() > 10:
		notification_list.get_child(10).queue_free()

	# Add notification and put it first in list
	notification_list.add_child(display_notification_object)
	notification_list.move_child(display_notification_object, 0)
	tween.interpolate_property(display_notification_object, "modulate", Color("00ff00"), Color("ffffff"), 7, tween.TRANS_LINEAR, tween.EASE_OUT)
	tween.interpolate_property(display_notification_object, "percent_visible", 0.0, 1.0, .7, tween.TRANS_LINEAR, tween.EASE_OUT)
	tween.start()

func change_coins(amount, position):
	Global.data.coins += amount
	if amount > 0:
		Global.data.total_coins += amount
	
	display_profit_object = profit_indicator.instance()
	display_profit_object.position = position
	if amount - int(amount) == 0:
		amount = str(int(amount))
	elif amount < 10 and amount > -10:	
		amount = str("%.2f" % (amount))
	else:
		amount = str(int(amount))
	
	display_profit_object.value = amount
	display_profit_object.z_index = 999
	add_child(display_profit_object)
	set_coins()

func set_coins():
	var display_total
	if Global.data.coins < 1:	
		display_total = str("%.2f" % (Global.data.coins))
	elif Global.data.coins < 10:
		display_total = str("%.1f" % (Global.data.coins))
	else:
		display_total = str(int(Global.data.coins))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").text = str(display_total)

func set_income():
	var income_per_second
	Global.data.total_income = (Global.data.base_income + Global.data.board_income) * Global.data.income_multiplier
	income_per_second = Global.data.total_income / Global.data.income_timer
	
	if Global.data.total_income < 1:	
		income_per_second = str("%.2f" % (income_per_second))
	elif Global.data.total_income < 10:	
		income_per_second = str("%.1f" % (income_per_second))
	else:
		income_per_second = str(int(income_per_second))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").text = "(+" + income_per_second + "/"

func set_moves():
	var indicator_color
	if Global.data.moves_left < 50:
		indicator_color = Color(1, Global.data.moves_left/50.0, 0)
	elif Global.data.moves_left >= 50 and Global.data.moves_left < 100:
		indicator_color = Color(1-(Global.data.moves_left-50)/50.0, 1, 0)
	else:
		indicator_color = Color(0,1,0)
		
	move_timer_bar.modulate = indicator_color
	get_node("/root/main/Info/MoveInfo/AddMovesButton").text = str(Global.data.moves_left)

func set_achievements_and_upgrades_levels():
	for achievement in achievements_panel.open_achievements:
		achievement.level = Global.data.achievements_levels[achievement.name]
	for upgrade in upgrades_panel.open_upgrades:
		upgrade.level = Global.data.upgrades_levels[upgrade.name]
		upgrades_panel._update_upgrade_object(upgrade)

func add_move_cost():
	if Global.data.coins < 1:
		return 0.1
	else:
		return Global.data.coins * 0.1

func make_move():
	if Main.auto_add_moves and Global.data.moves_left == 0:
		change_coins(-Main.add_move_cost(), get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
		set_coins()
	else:
		Global.data.moves_left -=1
		set_moves()

func _on_user_interface_button_pressed(button):
	if button.name == "AchievementsButton":
		Main.achievements_panel.visible = true
		Main.upgrades_button.visible = false
		Main.achievements_button.visible = false
		Main.move_enabled = false
		tween.interpolate_property(Main.achievements_panel, "rect_position", Vector2(16, 1080), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
		tween.start()
	elif button.name == "UpgradesButton":
		Main.upgrades_panel.visible = true
		Main.upgrades_button.visible = false
		Main.achievements_button.visible = false
		Main.move_enabled = false
		tween.interpolate_property(Main.upgrades_panel, "rect_position", Vector2(16, 1080), Vector2(16, 16), .6, tween.TRANS_EXPO, tween.EASE_OUT)
		tween.start()
	elif button.name == "CloseButton":
		Main.upgrades_button.visible = true
		Main.achievements_button.visible = true
		tween.interpolate_property(button.get_parent(), "rect_position", Vector2(16, 16), Vector2(16, 1080), .6, tween.TRANS_EXPO, tween.EASE_OUT)
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
		if Global.data.coins > Main.add_move_cost() * Main.add_moves_amount:
			Global.data.moves_left += 1 * Main.add_moves_amount
			Main.change_coins(-Main.add_move_cost() * Main.add_moves_amount, \
			get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
		set_moves()
		set_coins()
	elif button.name == "RecycleButton":
		tile_board.recycle()

func _on_Timer_timeout(timer):
	if timer.name == "IncomeTimer":
		if Global.data.total_income > 0:
			change_coins(Global.data.total_income, get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").get_global_position() + Vector2(85,0))
	elif timer.name == "MoveTimer":
		Global.data.moves_left += 1
		set_moves()
	elif timer.name == "MainTimer":
		Main.achievements_panel._on_MainTimer_timeout()
		Main.upgrades_panel._on_MainTimer_timeout()
	elif timer.name == "SaveTimer":
		save_game()

func save_game():
	global_data_byte_array = PoolByteArray()
	Global.data.tile_levels = []
	for column in Global.data.board_size:
		Global.data.tile_levels.append([])
		for row in Global.data.board_size:
			if Main.all_tiles[column][row] != null:
				Global.data.tile_levels[column].append(Main.all_tiles[column][row].tile_order)
			else:
				Global.data.tile_levels[column].append(null)
	
	for achievement in achievements_panel.open_achievements:
		Global.data.achievements_levels[achievement.name] = achievement.level
	for achievement in achievements_panel.completed_achievements:
		Global.data.achievements_levels[achievement.name] = achievement.level

	for upgrade in upgrades_panel.open_upgrades:
		Global.data.upgrades_levels[upgrade.name] = upgrade.level
	for upgrade in upgrades_panel.completed_upgrades:
		Global.data.upgrades_levels[upgrade.name] = upgrade.level

	for i in to_json(Global.data):
		global_data_byte_array.append(int(rand_range(33,127)))
		global_data_byte_array.append(int(rand_range(33,127)))
		global_data_byte_array.append(int(rand_range(33,127)))
		if rand_range(0,7) > 5:
			global_data_byte_array.append(ord("\n"))
		else:
			global_data_byte_array.append(int(rand_range(33,127)))
		global_data_byte_array.append(ord(i)-8)

	if http_request_save.request(	
						"http://www.freealization.com/save/save.php", # URL
						["Content-Type: application/json"], # Header
						false, # Use SSL
						HTTPClient.METHOD_POST, # Request method
						global_data_byte_array.get_string_from_ascii() # Body
					) == 0:
		print("Data sent...")

func load_game():
	global_data_byte_array = PoolByteArray()
	if http_request_load.request(	
						"http://www.freealization.com/save/load.php", # URL
						["Content-Type: application/json"], # Header
						false, # Use SSL
						HTTPClient.METHOD_GET # Request method
					) == 0:
		print("Data requested...")

func _on_save_request_completed(_result, response_code, _header, _body):
	if response_code == 200:
		print("Data saved successfully")
	if exit_game:
		get_tree().quit()

func _on_load_request_completed(_result, response_code, _header, body):
	if body.get_string_from_utf8() == "Unable to open file.":
		print("Server was unable to open file.")
	elif response_code == 200:
		print("Data successfully retrieved")
		load_string = body.get_string_from_utf8()
		for i in range(4,load_string.length(),5):
			global_data_byte_array.append(ord(load_string[i])+8)
		var data = parse_json(global_data_byte_array.get_string_from_ascii())

		if typeof(data) == TYPE_DICTIONARY:
			Global.data = data
			Main.all_tiles = []
			Main.set_achievements_and_upgrades_levels()
			Main.set_income()
			Main.set_coins()
			Main.set_moves()
		else:
			printerr("Need valid data")
		
	set_board_variables()
	tile_board.initialize_board()
	
	if Global.data.board_size == 2 and Global.data.coins < 1:
		Main.move_info.visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parenthesis").visible = false

	set_moves()
	set_coins()
	
	get_node("/root/main/MoveTimer").set_wait_time(Global.data.move_timer)
	get_node("/root/main/IncomeTimer").set_wait_time(Global.data.income_timer)
