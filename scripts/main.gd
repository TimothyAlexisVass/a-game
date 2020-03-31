extends Node2D

var width = 2
var height = 2
var scale_x = 4.0 / width
var scale_y = 4.0 / height
var start_x = 576 / (width + 2)
var start_y = 576 / (height + 2)
var offset_x = 4.0 / width * 128
var offset_y = 4.0 / height * 128

var move_timer
var moves
var move_enabled = true
var starting_tiles = 1
var order = 0
var base = 0
var total = 0.30
var base_income = 0.0
var income = 0.0
var add_moves_amount = 1
var auto_add_moves
var full_grid_multiplier = 1
enum increment_type {ADD, DOUBLE, MULTIPLY, EXPONENTIAL}
var increment = increment_type.ADD

func _ready():
	if Main.width == 2:
		start_x += 16
		start_y += 16
		get_node("/root/main/Info/MoveInfo").visible = false
		get_node("/root/main/UpgradesButton").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/PerSecondLabel").visible = false
		get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/Parentheses").visible = false
	Main.full_grid_multiplier = Main.base * 3 + 1
	Main.moves = 100
	set_moves()
	move_timer = 10
	get_node("/root/main/Info/MoveInfo/MoveTimer").set_wait_time(move_timer)
	
func _process(_delta):
	get_node("/root/main/Info/MoveInfo/Margin/MoveTimerBar").rect_size \
	= Vector2( 80 + 454 * ( + (move_timer - get_node("/root/main/Info/MoveInfo/MoveTimer").time_left) / move_timer), 85)

func grid_to_pixel(grid_position):
	return (Vector2(grid_position.x * offset_x + start_x,
					grid_position.y * offset_y + start_y))

func increase_total(amount):
	Main.total += amount
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
	
	if Main.total >= 0.3:
		get_node("/root/main/UpgradesButton").visible = true

func set_income(amount):
	var displayincome
	Main.income = Main.base_income + amount
	if Main.income < 10:	
		displayincome = str("%.1f" % (Main.income))
	else:
		displayincome = str(int(Main.income))
	get_node("/root/main/Info/CoinsInfo/Margin/CoinsContainer/IncomeLabel").text = "(+" + displayincome + "/"

func make_move():
	if auto_add_moves and Main.moves == 0:
		Main.total -= 10
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
		
	get_node("/root/main/Info/MoveInfo/MovesIndicator").modulate = indicator_color
	get_node("/root/main/Info/MoveInfo/Margin/MoveTimerBar").modulate = indicator_color
	get_node("/root/main/Info/MoveInfo/Margin2/CenterContainer/MovesLabel").text = str(Main.moves)

func _on_IncomeTimer_timeout():
	increase_total(Main.income)
	
func _on_MoveTimer_timeout():
	Main.moves += 1
	set_moves()

func _on_AddMovesButton_pressed():
	if Main.total > 10 * Main.add_moves_amount:
		Main.moves += 1 * Main.add_moves_amount
		Main.total -= 10 * Main.add_moves_amount
	set_moves()
	set_total()

func _on_MoveAmount_pressed():
	if Main.add_moves_amount == 1 and Main.auto_add_moves == false:
		Main.add_moves_amount = 5
	elif Main.add_moves_amount == 5:
		Main.add_moves_amount = 10
	elif Main.add_moves_amount == 10:
		Main.auto_add_moves = true
		Main.add_moves_amount = 1
	else:
		Main.auto_add_moves = false
		Main.add_moves_amount = 1
	
	if Main.auto_add_moves == true:
		get_node("/root/main/Info/MoveInfo/AddMovesButton/Amount").text = "AUTO"
	else:
		get_node("/root/main/Info/MoveInfo/AddMovesButton/Amount").text = "X" + str(Main.add_moves_amount)
