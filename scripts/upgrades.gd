extends Panel

var upgrade_template = preload("res://scenes/upgrade.tscn")
var upgrade_objects_list = {}
var upgrade_object

var open_upgrades = [
	{
		"name": "board_size",
		"level": 0,
		"requirement": [5, 500, 2000000, 3000000000],
		"reward": [3, 4, 5, 6],
		"image": load("res://assets/upgrade_images/board_size.svg"),
		"description": ["Increase board size (3x3)", "Increase board size (4x4)", "Increase board size (5x5)", "Increase board size (6x6)"],
	},
	{
		"name": "tile_base",
		"level": 0,
		"requirement": [6, 60, 150000, 2000000, 3000000000],
		"reward": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
		"image": load("res://assets/upgrade_images/tile_base.svg"),
		"description": ["Add numbers to the tiles\n(Greatly increased recycle profit)", "Increase base value to 1", "Increase base value to 2", "Increase base value to 3", "Increase base value to 4", "Increase base value to 5", "Increase base value to 6", "Increase base value to 7", "Increase base value to 8", "Increase base value to 9", "Increase base value to 10"]
	},
	{
		"name": "increment",
		"level": 0,
		"requirement": [200, 700, 5000, pow(10,12), pow(10,24)],
		"reward": [Global.increment_type.PRIME, Global.increment_type.FIBONNACCI, Global.increment_type.DOUBLE, Global.increment_type.MULTIPLY, Global.increment_type.ULTIMATE],
		"image": load("res://assets/upgrade_images/increment.svg"),
		"description": ["Combined tiles increment as prime numbers.", "Combined tiles follow the Fibonnacci sequence", "Combined tile values are doubled", "Value is multiplied", "Value increases exponentially."]
	},
	{
		"name": "move_timer",
		"level": 0,
		"requirement": [8, 20, 500, 2000, 80000, 160000, pow(2, 18), pow(2, 20), pow(2, 21), pow(2, 22)],
		"reward": [9, 8, 7, 6, 5, 4, 3, 2, 1, 0.5],
		"image": load("res://assets/upgrade_images/move_timer.svg"),
		"description": ["Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster.", "Gain moves faster."]
	}
]

var completed_upgrades = []

var hidden_upgrades = [
	"increment"
]

func _ready():
	for upgrade in open_upgrades:
		upgrade_object = upgrade_template.instance()
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/ImageBackground/UpgradeImage").texture = upgrade["image"]
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").connect("pressed", self, "_on_UpgradeBuyButton_pressed", [upgrade])
		get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
		upgrade_objects_list[upgrade.name] = upgrade_object
	for upgrade in hidden_upgrades:
		upgrade_objects_list[upgrade].visible = false

func _on_MainTimer_timeout():
	for upgrade in open_upgrades:
		upgrade_object = upgrade_objects_list[upgrade.name]
		if Global.data.coins >= upgrade.requirement[upgrade.level]:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true
	for upgrade in hidden_upgrades:
		if reveal(upgrade):
			upgrade_objects_list[upgrade].visible = true
			hidden_upgrades.erase(upgrade)

func reveal(upgrade):
	match(upgrade):
		"increment":
			for upgrade in open_upgrades:
				if upgrade.name == "tile_base" and upgrade.level > 0:
					return true

func _on_UpgradeBuyButton_pressed(upgrade):
	upgrade_object = upgrade_objects_list[upgrade.name]
	if Global.data.coins >= upgrade.requirement[upgrade.level]:
		_perform_upgrade(upgrade)
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func _perform_upgrade(upgrade):
	if upgrade.name == "board_size":
		Main.change_coins(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Global.data.board_size = upgrade.reward[upgrade.level]
		Main.resize_tile_board()

	elif upgrade.name == "tile_base":
		Main.change_coins(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Global.data.tile_base = upgrade.reward[upgrade.level]

	elif upgrade.name == "increment":
		Main.change_coins(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Global.data.increment = upgrade.reward[upgrade.level]

	elif upgrade.name == "move_timer":
		Main.change_coins(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Global.data.move_timer = upgrade.reward[upgrade.level]
		get_node("/root/main/MoveTimer").set_wait_time(Global.data.move_timer)

	# Happens for all upgrades:
	upgrade.level += 1
	if upgrade.level == upgrade.requirement.size():
		completed_upgrades.append(upgrade)
		open_upgrades.erase(upgrade)
		upgrade_objects_list[upgrade.name].queue_free()
	else:
		_update_upgrade_object(upgrade)

	sort_upgrades()

func _update_upgrade_object(upgrade):
	upgrade_object = upgrade_objects_list[upgrade.name]
	upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])	
	upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])

	if Global.data.coins >= upgrade.requirement[upgrade.level]:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func sort_upgrades():
	var sort_array = []
	for upgrade in open_upgrades:
		sort_array.append(upgrade.requirement[upgrade.level])
	sort_array.sort()
	
	for index in sort_array.size():
		for upgrade in open_upgrades:
			upgrade_object = upgrade_objects_list[upgrade.name]
			if upgrade.requirement[upgrade.level] == sort_array[index]:
				get_node("ScrollContainer/MarginContainer/VBoxContainer").move_child(upgrade_object, index)
