extends Node2D

# Movement Variables
enum directions {UP, DOWN, LEFT, RIGHT}
var movement = false
var touch_position = Vector2(0, 0)
var release_position = Vector2(0, 0)
var first_press = true
var tile
var tile2
var combine_value
var full_grid

# Tile Variables
var tile_template = preload("res://scenes/tile.tscn")
var tile_grid

func _ready():
	randomize()
	yield(get_tree().create_timer(1), "timeout")
	Main.move_enabled = true
	initialize_grid()

func _input(event):
	if Main.move_enabled == true:
		#Keyboard input
		if(event.is_action_pressed("ui_up")):
			update_grid(directions.UP)
		if(event.is_action_pressed("ui_down")):
			update_grid(directions.DOWN)
		if(event.is_action_pressed("ui_left")):
			update_grid(directions.LEFT)
		if(event.is_action_pressed("ui_right")):
			update_grid(directions.RIGHT)
		
		#Touch input
		if(event.is_action_pressed("ui_touch")):
			touch_position = (get_global_mouse_position())
		if(event.is_action_released("ui_touch")):
			release_position = (get_global_mouse_position())
			var difference = release_position - touch_position
	
			if abs(difference.x) <= abs(difference.y):
				if difference.y <= -25:
					update_grid(directions.UP)
				elif difference.y >= 25:
					update_grid(directions.DOWN)
			elif abs(difference.x) > abs(difference.y):
				if difference.x <= -25:
					update_grid(directions.LEFT)
				elif difference.x >= 25:
					update_grid(directions.RIGHT)
			
			# Print angle
			# var angle = rad2deg(atan2(difference.x, difference.y))
			# print("swipe angle: " + str(angle))

func combine_tiles(ctile, ctile2, column, row):
	add_tile(ctile.order + 1, column, row)
	
	ctile.queue_free()
	ctile2.move(Main.grid_to_pixel(Vector2(column, row)))
	ctile2.clear_tile()
	
	combine_value += 2 * ctile.value / 100.0
	Main.change_total(combine_value, ctile.position)
	movement = true
	
func move_tile(new_column, new_row, column, row, mtile):
	mtile.move(Main.grid_to_pixel(Vector2(new_column, new_row)))
	tile_grid[new_column][new_row] = mtile
	tile_grid[column][row] = null
	movement = true

func update_grid(direction):
	if Main.moves > 0 or Main.auto_add_moves and Main.total >= 10:
		if open_position_exists() or combination_possible():
			if direction == directions.UP:
				combine_up()
				move_up()
			elif direction == directions.DOWN:
				combine_down()
				move_down()
			elif direction == directions.LEFT:
				combine_left()
				move_left()
			elif direction == directions.RIGHT:
				combine_right()
				move_right()
			if movement:
				Main.make_move()
				add_tile_in_empty_position()
				calculate_income()
				movement = false
				get_node("../RecycleButton").visible = Main.moves == 0
				if !open_position_exists() and !combination_possible():
					get_node("../RecycleButton").visible = true
					full_grid = true

func calculate_income():
	var income = 0
	for column in range(Main.width):
		for row in range(Main.height):
			if tile_grid[column][row] != null and Main.base > 0:
				income += tile_grid[column][row].value / 100.0
	Main.set_income(income)

func combine_up():
	for column in Main.width:
		#First try to combine tiles
		#Each row from top before the last one
		for row in range(0, Main. height - 1):
			tile = tile_grid[column][row]
			if tile != null:
				#Try to find another tile below
				for check_row in range(row + 1, Main.height):
					tile2 = tile_grid[column][check_row]
					if tile2 != null:
						#Combine if they have the same order
						if tile.order == tile2.order:
							tile_grid[column][check_row] = null
							combine_tiles(tile, tile2, column, row)
							move_up()
						break

func combine_down():
	for column in Main.width:
		#First try to combine tiles
		#Each row from bottom before the last one
		for row in range(Main.height-1, 0, -1):
			tile = tile_grid[column][row]
			if tile != null:
				#Try to find another tile above
				for check_row in range(row-1, -1, -1):
					tile2 = tile_grid[column][check_row]
					if tile2 != null:
						#Combine if they have the same order
						if tile.order == tile2.order:
							tile_grid[column][check_row] = null
							combine_tiles(tile, tile2, column, row)
							move_down()
						break

func combine_left():
	for row in Main.height:
		#First try to combine tiles
		#Each column from left before the last one
		for column in range(Main.width - 1):
			tile = tile_grid[column][row]
			if tile != null:
				#Try to find another tile to the right
				for check_column in range(column + 1, Main.width):
					tile2 = tile_grid[check_column][row]
					if tile2 != null:
						#Combine if they have the same order
						if tile.order == tile2.order:
							tile_grid[check_column][row] = null
							combine_tiles(tile, tile2, column, row)
							move_left()
						break

func combine_right():
	for row in Main.height:
		#First try to combine tiles
		#Each column from right before the last one
		for column in range(Main.width-1, 0, -1):
			tile = tile_grid[column][row]
			if tile != null:
				#Try to find another tile to the left
				for check_column in range(column-1, -1, -1):
					tile2 = tile_grid[check_column][row]
					if tile2 != null:
						#Combine if they have the same order
						if tile.order == tile2.order:
							tile_grid[check_column][row] = null
							combine_tiles(tile, tile2, column, row)
							move_right()
						break
func move_left():
	for row in Main.height:
		#Each column from second left to right
		for column in range(1, Main.width):
			tile = tile_grid[column][row]
			if tile != null:
				if tile_grid[column-1][row] != null:
					continue
				#Check each position to the left of this tile
				for check_column in range(column-1, -1, -1):
					if tile_grid[check_column][row] == null and check_column == 0:
						move_tile(check_column, row, column, row, tile)
					elif tile_grid[check_column][row] != null:
						move_tile(check_column + 1, row, column, row, tile)
						break

func move_right():
	for row in Main.height:
		#Each column from second right to left
		for column in range(Main.width - 2, -1, -1):
			tile = tile_grid[column][row]
			if tile != null:
				if tile_grid[column + 1][row] != null:
					continue
				#Check each position to the right of this tile
				for check_column in range(column + 1, Main.width):
					if tile_grid[check_column][row] == null and check_column == Main.width-1:
						move_tile(check_column, row, column, row, tile)
					elif tile_grid[check_column][row] != null:
						move_tile(check_column - 1, row, column, row, tile)
						break

func move_up():
	for column in range(Main.width):
		#Each column from second top to bottom
		for row in range(1, Main.height):
			tile = tile_grid[column][row]
			if tile != null:
				if tile_grid[column][row-1] != null:
					continue
				#Check each position above this tile
				for check_row in range(row-1, -1, -1):
					if tile_grid[column][check_row] == null and check_row == 0:
						move_tile(column, check_row, column, row, tile)
					elif tile_grid[column][check_row] != null:
						move_tile(column, check_row + 1, column, row, tile)
						break

func move_down():
	for column in range(Main.width):
		#Each column from second bottom to top
		for row in range(Main.height - 2, -1, -1):
			tile = tile_grid[column][row]
			if tile != null:
				if tile_grid[column][row + 1] != null:
					continue
				#Check each position below this tile
				for check_row in range(row + 1, Main.height):
					if tile_grid[column][check_row] == null and check_row == Main.height-1:
						move_tile(column, check_row, column, row, tile)
					elif tile_grid[column][check_row] != null:
						move_tile(column, check_row - 1, column, row, tile)
						break

func open_position_exists():
	for column in Main.width:
		for tile in tile_grid[column]:
			if tile == null:
				return true
	return false

func combination_possible():
	# Check the four directions to see if the order matches
	for column in Main.width:
		for row in Main.height:
			if tile_grid[column][row] != null:
				var order = tile_grid[column][row].order
				if row > 0:
					if tile_grid[column][row - 1].order == order:
						return true
				if row < Main.width - 1:
					if tile_grid[column][row + 1].order == order:
						return true
				if column > 0:
					if tile_grid[column - 1][row].order == order:
						return true
				if column < Main.width - 1:
					if tile_grid[column + 1][row].order == order:
						return true
	return false

func add_tile(order, column, row):
	tile = tile_template.instance()
	tile.order = order
	add_child(tile)
	tile.position = Main.grid_to_pixel(Vector2(column, row))
	tile_grid[column][row] = tile

func add_tile_in_empty_position():
	# Make a new tile in an open position
	# Loop until a random open position is found
	while 1:
		var column = floor(rand_range(0, Main.width))
		var row = floor(rand_range(0, Main.height))
		if(tile_grid[column][row] == null):
			if rand_range(0, 1) < 0.9:
				add_tile(Main.order, column, row)
			else:
				add_tile(Main.order + 1, column, row)
			break

func initialize_grid():
	full_grid = false
	combine_value = 0.01
	get_node("../RecycleButton").visible = false
	
	tile_grid = []
	#Make tile_grid into 2D_array
	for column in Main.width:
		tile_grid.append([])
		for row in Main.height:
			tile_grid[column].append(null)
	
	for i in Main.starting_tiles:
		add_tile_in_empty_position()
		yield(get_tree().create_timer(.3), "timeout")
	
	Main.set_income(Main.base_income)
	calculate_income()

func _on_RecycleButton_pressed():
	Main.base_income = Main.income
	
	for column in tile_grid:
		for tile in column:
			if tile != null:
				yield(get_tree().create_timer(.05), "timeout")
				if full_grid:
					Main.change_total(tile.value * Main.full_grid_multiplier, tile.position)
				else:
					Main.change_total(tile.value, tile.position)
				tile.z_index = 999
				tile.collect_tile(get_node("/root/main/Info/CoinsInfo/CoinSprite").global_position + Vector2(50,0))
				tile = null
	
	initialize_grid()
