extends Node2D

var width = 2
var height = 2
var scale_x = 4.0 / width
var scale_y = 4.0 / height
var start_x = 576 / (width + 2)
var start_y = 576 / (height + 2)
var offset_x = 4.0 / width * 128
var offset_y = 4.0 / height * 128

var income_timer
var move_timer
var moves
var move_enabled = false
var add_moves_amount = 1
var auto_add_moves

var starting_tiles = 1
var order = 0
var base = 0

var total = 0.0
var base_income = 0.0
var income = 0.0
var income_multiplier = 1

var full_grid_multiplier = 1
enum increment_type {ADD, PRIME, FIBONNACI, DOUBLE, MULTIPLY, ULTIMATE}
var increment = increment_type.ADD

onready var upgrades_button = get_node("/root/main/UpgradesButton")
onready var achievements_button = get_node("/root/main/AchievementsButton")
onready var move_timer_bar = get_node("/root/main/Info/MoveInfo/MoveTimerBar")
onready var moveinfo = get_node("/root/main/Info/MoveInfo")
var profit_indicator = preload("res://scenes/profit_indicator.tscn")
var show_profit

func _ready():
	if Main.width == 2:
		start_x += 16
		start_y += 16
		Main.moveinfo.visible = false
		Main.achievements_button.visible = false
		Main.upgrades_button.disabled = true
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parentheses").visible = false
	
	Main.full_grid_multiplier = Main.base * 3 + 1
	Main.moves = 100
	set_moves()
	set_total()
	
	Main.move_timer = 10
	Main.income_timer = 10
	get_node("/root/main/Info/MoveInfo/MoveTimer").set_wait_time(Main.move_timer)
	get_node("/root/main/Info/CoinsInfo/IncomeTimer").set_wait_time(Main.income_timer)
	
func _process(_delta):
	move_timer_bar.value = 100 * (Main.move_timer - get_node("/root/main/Info/MoveInfo/MoveTimer").time_left) / Main.move_timer

func grid_to_pixel(grid_position):
	return (Vector2(grid_position.x * offset_x + start_x,
					grid_position.y * offset_y + start_y))

func change_total(amount, position):
	Main.total += amount
	
	show_profit = profit_indicator.instance()
	show_profit.position = position
	if amount < 1 and amount > -1:	
		amount = str("%.2f" % (amount))
	elif amount < 10 and amount > -10:
		amount = str("%.1f" % (amount))
	else:
		print(amount)
		amount = str(int(amount))
	
	show_profit.value = amount
	show_profit.z_index = 999
	add_child(show_profit)
	set_total()

func set_total():
	var displaytotal
	if Main.income < 1:	
		displaytotal = str("%.2f" % (Main.total))
	elif Main.income < 10:
		displaytotal = str("%.1f" % (Main.total))
	else:
		displaytotal = str(int(Main.total))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").text = str(displaytotal)

func sget_total():
	return Main.total

func set_income(amount):
	var displayincome
	Main.income = (Main.base_income + amount) * Main.income_multiplier
	displayincome = Main.income / Main.income_timer
	
	if Main.income < 1:	
		displayincome = str("%.2f" % (displayincome))
	elif Main.income < 10:	
		displayincome = str("%.1f" % (displayincome))
	else:
		displayincome = str(int(displayincome))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").text = "(+" + displayincome + "/"

func make_move():
	if auto_add_moves and Main.moves == 0:
		change_total(-10, get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
		set_total()
	else:
		Main.moves -=1
		set_moves()

func set_moves():
	var indicator_color
	if Main.moves < 50:
		indicator_color = Color(1, Main.moves/50.0, 0)
	elif Main.moves >= 50 and Main.moves < 100:
		indicator_color = Color(1-(Main.moves-50)/50.0, 1, 0)
	else:
		indicator_color = Color(0,1,0)
		
	move_timer_bar.modulate = indicator_color
	get_node("/root/main/Info/MoveInfo/AddMovesButton").text = str(Main.moves)

func _on_IncomeTimer_timeout():
	if Main.income > 0:
		change_total(Main.income, get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").get_global_position() + Vector2(85,0))
	
func _on_MoveTimer_timeout():
	Main.moves += 1
	set_moves()
	
func _on_AddMovesButton_pressed():
	if Main.total > 10 * Main.add_moves_amount:
		Main.moves += 1 * Main.add_moves_amount
		change_total(-10 * Main.add_moves_amount, \
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/TotalLabel").get_global_position() + Vector2(60,0))
	set_moves()
	set_total()

func _on_MoveAmount_pressed():
#	if Main.add_moves_amount == 1 and Main.auto_add_moves == false:
#		Main.add_moves_amount = 5
#	elif Main.add_moves_amount == 5:
#		Main.add_moves_amount = 10
#	elif Main.add_moves_amount == 10:
#		Main.auto_add_moves = true
#		Main.add_moves_amount = 1
#	else:
#		Main.auto_add_moves = false
#		Main.add_moves_amount = 1
	
	Main.auto_add_moves = !Main.auto_add_moves
	
	if Main.auto_add_moves == true:
		get_node("/root/main/Info/MoveInfo/AddMovesButton/Amount").text = "AUTO"
	else:
		get_node("/root/main/Info/MoveInfo/AddMovesButton/Amount").text = "X" + str(Main.add_moves_amount)

func _on_MainTimer_timeout():
	# Refresh everything
	pass
