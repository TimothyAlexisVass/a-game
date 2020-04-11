extends Panel

var upgrade_template = preload("res://scenes/upgrade.tscn")
var upgrade_objects_list = {}
var upgrade_object

var board_size_function = funcref(self, "board_size")

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
		"requirement": [50, 200, 5000, 100000, ],
		"reward": [Global.increment_type.PRIME, Global.increment_type.FIBONNACCI, Global.increment_type.DOUBLE, Global.increment_type.MULTIPLY, Global.increment_type.ULTIMATE],
		"image": load("res://assets/upgrade_images/increment.svg"),
		"description": ["Combined tiles increment as prime numbers.", "Combined tiles follow the Fibonnacci sequence", "Combined tile values are doubled", "Value is multiplied", "Value increases exponentially."]
	}
]

var completed_upgrades = []

func _ready():
	for upgrade in open_upgrades:
		upgrade_object = upgrade_template.instance()
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/ImageBackground/UpgradeImage").texture = upgrade["image"]
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").connect("pressed", self, "_on_UpgradeBuyButton_pressed", [upgrade])
		get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
		upgrade_objects_list[upgrade.name] = upgrade_object

func _on_MainTimer_timeout():
	for upgrade in open_upgrades:
		upgrade_object = upgrade_objects_list[upgrade.name]
		if Global.data.coins >= upgrade.requirement[upgrade.level]:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

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
		for tile in Main.all_tiles:
			tile.set_value()

	elif upgrade.name == "increment":
		Main.change_coins(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Global.data.increment = upgrade.reward[upgrade.level]

	# Happens for all upgrades:
	upgrade.level += 1
	_update_upgrade_object(upgrade)

func _update_upgrade_object(upgrade):
	upgrade_object = upgrade_objects_list[upgrade.name]
	upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])	
	upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])

	if Global.data.coins >= upgrade.requirement[upgrade.level]:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true
