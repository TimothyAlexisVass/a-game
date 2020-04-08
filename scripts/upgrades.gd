extends Panel

enum check{UPGRADE, AFFORDABLE}

var upgrade_template = preload("res://scenes/upgrade.tscn")
var upgrade_objects_list = {}
var upgrade_object

var board_size_function = funcref(self, "board_size")

var open = [
	{
		"name": "board_size",
		"level": 0,
		"requirement": [5, 500, 2000000, 3000000000],
		"reward": [3, 4, 5, 6],
		"image": load("res://assets/upgrade_images/board_size.svg"),
		"description": ["Increase board size (3x3)", "Increase board size (4x4)", "Increase board size (5x5)", "Increase board size (6x6)"]
	},
		{
		"name": "tile_base",
		"level": 0,
		"requirement": [10, 1500, 2000000, 3000000000],
		"reward": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
		"image": load("res://assets/upgrade_images/tile_base.svg"),
		"description": ["Add numbers to the tiles\n(Greatly increased recycle profit)", "Double base value for tiles", "Increase base value to 3", "Increase base value to 4", "Increase base value to 5", "Increase base value to 6", "Increase base value to 7", "Increase base value to 8", "Increase base value to 9", "Increase base value to 10"]
	}
]

var completed = []

func _ready():
	for upgrade in open:
		upgrade_object = upgrade_template.instance()
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/ImageBackground/UpgradeImage").texture = upgrade["image"]
		upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").connect("pressed", self, "_on_UpgradeBuyButton_pressed", [upgrade])
		get_node("ScrollContainer/MarginContainer/VBoxContainer").add_child(upgrade_object)
		upgrade_objects_list[upgrade.name] = upgrade_object

func _on_CheckUpgrades_timeout():
	for upgrade in open:
		upgrade_object = upgrade_objects_list[upgrade.name]
		if Main.coins >= upgrade.requirement[upgrade.level]:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
		else:
			upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func _on_UpgradeBuyButton_pressed(upgrade):
	upgrade_object = upgrade_objects_list[upgrade.name]
	if Main.coins >= upgrade.requirement[upgrade.level]:
		perform_upgrade(upgrade)
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true

func perform_upgrade(upgrade):
	if upgrade.name == "board_size":
		Main.change_total(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Main.board_size = upgrade.reward[upgrade.level]
		Main.resize_tile_board()

	elif upgrade.name == "tile_base":
		Main.change_total(-upgrade.requirement[upgrade.level], get_global_mouse_position())
		Main.tile_base = upgrade.reward[upgrade.level]
	
	# Happens for all upgrades:
	upgrade.level += 1
	upgrade_object.get_node("Background/MarginContainer/Panel/HBoxContainer/PriceLabel").text = str(upgrade.requirement[upgrade.level])	
	upgrade_object.get_node("Background/MarginContainer/Panel/MarginContainer2/HBoxContainer/DescriptionLabel").text = str(upgrade.description[upgrade.level])

	if Main.coins >= upgrade.requirement[upgrade.level]:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = false
	else:
		upgrade_object.get_node("Background/MarginContainer/Panel/UpgradeBuyButton").disabled = true
