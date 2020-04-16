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
var full_board

func _ready():
	randomize()

func _input(event):
	if Main.move_enabled == true:
		#Keyboard input
		if(event.is_action_pressed("ui_up")):
			update_board(directions.UP)
		if(event.is_action_pressed("ui_down")):
			update_board(directions.DOWN)
		if(event.is_action_pressed("ui_left")):
			update_board(directions.LEFT)
		if(event.is_action_pressed("ui_right")):
			update_board(directions.RIGHT)
		
		#Touch input
		if(event.is_action_pressed("ui_touch")):
			touch_position = (get_global_mouse_position())
		if(event.is_action_released("ui_touch")):
			release_position = (get_global_mouse_position())
			var difference = release_position - touch_position
	
			if abs(difference.x) <= abs(difference.y):
				if difference.y <= -25:
					update_board(directions.UP)
				elif difference.y >= 25:
					update_board(directions.DOWN)
			elif abs(difference.x) > abs(difference.y):
				if difference.x <= -25:
					update_board(directions.LEFT)
				elif difference.x >= 25:
					update_board(directions.RIGHT)
			
			# Print angle
			# var angle = rad2deg(atan2(difference.x, difference.y))
			# print("swipe angle: " + str(angle))

func combine_tiles(ctile, ctile2, column, row):
	# When tiles are combined,
	# the previous ones are cleared.
	ctile.queue_free()
	ctile2.move(Main.set_tile_position(Vector2(column, row)))
	ctile2.clear_tile()
	
	# and a new tile is created and added to Main.all_tiles[column][row]
	add_tile(ctile.tile_order + 1, column, row)
	Global.data.combinations_done += 1
	# coins are gained according to the value of the new tile
	combine_value = Global.data.combination_multiplier * Main.all_tiles[column][row].value
	Main.change_coins(combine_value, ctile.position)
	movement = true
	
func move_tile(new_column, new_row, column, row, mtile):
	mtile.move(Main.set_tile_position(Vector2(new_column, new_row)))
	Main.all_tiles[new_column][new_row] = mtile
	Main.all_tiles[column][row] = null
	movement = true

func update_board(direction):
	if Global.data.energy > 0 or Main.auto_add_energy and Global.data.coins >= Main.add_move_cost():
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
				calculate_board_income()
				movement = false
				check_if_recycle_should_be_enabled()

func check_if_recycle_should_be_enabled():
	Main.recycle_button.visible = Global.data.energy == 0
	if !open_position_exists() and !combination_possible():
		Main.recycle_button.visible = true
		full_board = true

func calculate_board_income():
	Global.data.board_income = 0
	for column in range(Global.data.board_size):
		for row in range(Global.data.board_size):
			if Main.all_tiles[column][row] != null and Global.data.base_income > 0:
				Global.data.board_income += Main.all_tiles[column][row].value / 100.0
	Main.set_income()

func combine_up():
	for column in Global.data.board_size:
		#First try to combine tiles
		#Each row from top before the last one
		for row in range(0, Global.data. board_size - 1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				#Try to find another tile below
				for check_row in range(row + 1, Global.data.board_size):
					tile2 = Main.all_tiles[column][check_row]
					if tile2 != null:
						#Combine if they have the same tile_order
						if tile.tile_order == tile2.tile_order:
							Main.all_tiles[column][check_row] = null
							combine_tiles(tile, tile2, column, row)
							move_up()
						break

func combine_down():
	for column in Global.data.board_size:
		#First try to combine tiles
		#Each row from bottom before the last one
		for row in range(Global.data.board_size-1, 0, -1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				#Try to find another tile above
				for check_row in range(row-1, -1, -1):
					tile2 = Main.all_tiles[column][check_row]
					if tile2 != null:
						#Combine if they have the same tile_order
						if tile.tile_order == tile2.tile_order:
							Main.all_tiles[column][check_row] = null
							combine_tiles(tile, tile2, column, row)
							move_down()
						break

func combine_left():
	for row in Global.data.board_size:
		#First try to combine tiles
		#Each column from left before the last one
		for column in range(Global.data.board_size - 1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				#Try to find another tile to the right
				for check_column in range(column + 1, Global.data.board_size):
					tile2 = Main.all_tiles[check_column][row]
					if tile2 != null:
						#Combine if they have the same tile_order
						if tile.tile_order == tile2.tile_order:
							Main.all_tiles[check_column][row] = null
							combine_tiles(tile, tile2, column, row)
							move_left()
						break

func combine_right():
	for row in Global.data.board_size:
		#First try to combine tiles
		#Each column from right before the last one
		for column in range(Global.data.board_size-1, 0, -1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				#Try to find another tile to the left
				for check_column in range(column-1, -1, -1):
					tile2 = Main.all_tiles[check_column][row]
					if tile2 != null:
						#Combine if they have the same tile_order
						if tile.tile_order == tile2.tile_order:
							Main.all_tiles[check_column][row] = null
							combine_tiles(tile, tile2, column, row)
							move_right()
						break

func move_left():
	for row in Global.data.board_size:
		#Each column from second left to right
		for column in range(1, Global.data.board_size):
			tile = Main.all_tiles[column][row]
			if tile != null:
				if Main.all_tiles[column-1][row] != null:
					continue
				#Check each position to the left of this tile
				for check_column in range(column-1, -1, -1):
					if Main.all_tiles[check_column][row] == null and check_column == 0:
						move_tile(check_column, row, column, row, tile)
					elif Main.all_tiles[check_column][row] != null:
						move_tile(check_column + 1, row, column, row, tile)
						break

func move_right():
	for row in Global.data.board_size:
		#Each column from second right to left
		for column in range(Global.data.board_size - 2, -1, -1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				if Main.all_tiles[column + 1][row] != null:
					continue
				#Check each position to the right of this tile
				for check_column in range(column + 1, Global.data.board_size):
					if Main.all_tiles[check_column][row] == null and check_column == Global.data.board_size-1:
						move_tile(check_column, row, column, row, tile)
					elif Main.all_tiles[check_column][row] != null:
						move_tile(check_column - 1, row, column, row, tile)
						break

func move_up():
	for column in range(Global.data.board_size):
		#Each column from second top to bottom
		for row in range(1, Global.data.board_size):
			tile = Main.all_tiles[column][row]
			if tile != null:
				if Main.all_tiles[column][row-1] != null:
					continue
				#Check each position above this tile
				for check_row in range(row-1, -1, -1):
					if Main.all_tiles[column][check_row] == null and check_row == 0:
						move_tile(column, check_row, column, row, tile)
					elif Main.all_tiles[column][check_row] != null:
						move_tile(column, check_row + 1, column, row, tile)
						break

func move_down():
	for column in range(Global.data.board_size):
		#Each column from second bottom to top
		for row in range(Global.data.board_size - 2, -1, -1):
			tile = Main.all_tiles[column][row]
			if tile != null:
				if Main.all_tiles[column][row + 1] != null:
					continue
				#Check each position below this tile
				for check_row in range(row + 1, Global.data.board_size):
					if Main.all_tiles[column][check_row] == null and check_row == Global.data.board_size-1:
						move_tile(column, check_row, column, row, tile)
					elif Main.all_tiles[column][check_row] != null:
						move_tile(column, check_row - 1, column, row, tile)
						break

func open_position_exists():
	for column in Global.data.board_size:
		for tile in Main.all_tiles[column]:
			if tile == null:
				return true
	return false

func combination_possible():
	# Check the four directions if there is a tile with the same tile_order
	for column in Global.data.board_size:
		for row in Global.data.board_size:
			if Main.all_tiles[column][row] != null:
				var tile_order = Main.all_tiles[column][row].tile_order
				if row > 0:
					if Main.all_tiles[column][row - 1].tile_order == tile_order:
						return true
				if row < Global.data.board_size - 1:
					if Main.all_tiles[column][row + 1].tile_order == tile_order:
						return true
				if column > 0:
					if Main.all_tiles[column - 1][row].tile_order == tile_order:
						return true
				if column < Global.data.board_size - 1:
					if Main.all_tiles[column + 1][row].tile_order == tile_order:
						return true
	return false

func add_tile(tile_order, column, row):
	if Main.all_tiles[column][row] != null:
		Main.all_tiles[column][row].queue_free()
	# Instance a new tile, set it's position, tile_order,
	tile = Main.tile_template.instance()
	tile.position = Main.set_tile_position(Vector2(column, row))
	tile.tile_order = tile_order
	# add it to the board
	add_child(tile)
	# and add it to the array
	Main.all_tiles[column][row] = tile

func add_tile_in_empty_position():
	# Make a new tile in an open position
	# Loop until a random open position is found
	while 1:
		var column = floor(rand_range(0, Global.data.board_size))
		var row = floor(rand_range(0, Global.data.board_size))
		if(Main.all_tiles[column][row] == null):
			# There is a 10% chance that the tile has a higher tile_order
			if rand_range(0, 1) < 0.9:
				add_tile(Global.data.tile_order, column, row)
			else:
				add_tile(Global.data.tile_order + 1, column, row)
			break

func initialize_board():
	Main.set_board_variables()
	Main.generate_tile_backgrounds()

	full_board = false

	if Main.all_tiles == null:
		#Wait 1 second before adding tiles
		yield(get_tree().create_timer(.5), "timeout")
		generate_empty_all_tiles_array()
		for i in Global.data.starting_tiles:
			yield(get_tree().create_timer(.1), "timeout")
			add_tile_in_empty_position()
	else:
		generate_empty_all_tiles_array()
		for column in Global.data.board_size:
			for row in Global.data.board_size:
				if Global.data.tile_levels[column][row] != null:
					add_tile(int(Global.data.tile_levels[column][row]), column, row)
	calculate_board_income()
	yield(get_tree().create_timer(.6), "timeout")
	Main.move_enabled = true
	check_if_recycle_should_be_enabled()

func generate_empty_all_tiles_array():
	Main.all_tiles = []
	#Make Main.all_tiles into 2D_array
	for column in Global.data.board_size:
		Main.all_tiles.append([])
		for row in Global.data.board_size:
			Main.all_tiles[column].append(null)

func recycle():
	Main.recycle_button.visible = false
	Global.data.base_income += Global.data.board_income
	Main.move_enabled = false
	Global.data.top_tile_order = 0

	for column in Global.data.board_size:
		for row in Global.data.board_size:
			tile = Main.all_tiles[column][row]
			if tile != null:
				yield(get_tree().create_timer(.05), "timeout")
				if Main.upgrades_panel.open_upgrades[1].level == 0:
					Main.change_coins(tile.value / 100.0, tile.position)
				elif full_board:
					Main.change_coins(tile.value * Global.data.full_board_multiplier, tile.position)
				else:
					Main.change_coins(tile.value, tile.position)
				tile.z_index = 999
				tile.collect_tile(get_node("/root/main/Info/CoinsInfo/CoinSprite").global_position + Vector2(50,0))
				Main.all_tiles[column][row] = null
	Main.all_tiles = null
	Global.data.total_recycles += 1
	initialize_board()
